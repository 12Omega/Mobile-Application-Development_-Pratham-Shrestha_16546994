const express = require('express');
const Joi = require('joi');
const ParkingLot = require('../models/ParkingLot');
const { auth, adminAuth } = require('../middleware/auth');

const router = express.Router();

// Validation schemas
const createParkingLotSchema = Joi.object({
  name: Joi.string().min(2).max(100).required(),
  address: Joi.object({
    street: Joi.string().required(),
    city: Joi.string().required(),
    state: Joi.string().required(),
    zipCode: Joi.string().required(),
    country: Joi.string().default('USA')
  }).required(),
  location: Joi.object({
    type: Joi.string().valid('Point').required(),
    coordinates: Joi.array().items(Joi.number()).length(2).required()
  }).required(),
  totalSpots: Joi.number().min(1).required(),
  pricing: Joi.object({
    hourlyRate: Joi.number().min(0).required(),
    dailyRate: Joi.number().min(0).required(),
    currency: Joi.string().default('USD')
  }).required(),
  amenities: Joi.array().items(
    Joi.string().valid('covered', 'security', 'ev_charging', 'valet', 'car_wash', '24_hour')
  ),
  operatingHours: Joi.object({
    open: Joi.string().pattern(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/).required(),
    close: Joi.string().pattern(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/).required(),
    is24Hours: Joi.boolean().default(false)
  }).required(),
  contactInfo: Joi.object({
    phone: Joi.string(),
    email: Joi.string().email()
  })
});

// @route   GET /api/parking/nearby
// @desc    Get nearby parking lots
// @access  Private
router.get('/nearby', auth, async (req, res, next) => {
  try {
    const { longitude, latitude, radius = 5000 } = req.query;

    if (!longitude || !latitude) {
      return res.status(400).json({
        success: false,
        message: 'Longitude and latitude are required'
      });
    }

    const parkingLots = await ParkingLot.findNearby(
      parseFloat(longitude),
      parseFloat(latitude),
      parseInt(radius)
    );

    res.json({
      success: true,
      count: parkingLots.length,
      data: { parkingLots }
    });
  } catch (error) {
    next(error);
  }
});

// @route   GET /api/parking/:id
// @desc    Get parking lot details
// @access  Private
router.get('/:id', auth, async (req, res, next) => {
  try {
    const parkingLot = await ParkingLot.findById(req.params.id)
      .populate('managedBy', 'name email');

    if (!parkingLot) {
      return res.status(404).json({
        success: false,
        message: 'Parking lot not found'
      });
    }

    res.json({
      success: true,
      data: { parkingLot }
    });
  } catch (error) {
    next(error);
  }
});

// @route   POST /api/parking
// @desc    Create parking lot
// @access  Admin
router.post('/', adminAuth, async (req, res, next) => {
  try {
    const { error } = createParkingLotSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        message: error.details[0].message
      });
    }

    const parkingLotData = {
      ...req.body,
      managedBy: req.user._id,
      availableSpots: req.body.totalSpots
    };

    // Generate parking spots
    const spots = [];
    for (let i = 1; i <= req.body.totalSpots; i++) {
      spots.push({
        spotNumber: `A${i.toString().padStart(3, '0')}`,
        type: 'regular',
        isAvailable: true,
        isReserved: false
      });
    }
    parkingLotData.spots = spots;

    const parkingLot = await ParkingLot.create(parkingLotData);

    res.status(201).json({
      success: true,
      message: 'Parking lot created successfully',
      data: { parkingLot }
    });
  } catch (error) {
    next(error);
  }
});

// @route   PUT /api/parking/:id
// @desc    Update parking lot
// @access  Admin
router.put('/:id', adminAuth, async (req, res, next) => {
  try {
    const parkingLot = await ParkingLot.findById(req.params.id);

    if (!parkingLot) {
      return res.status(404).json({
        success: false,
        message: 'Parking lot not found'
      });
    }

    // Check if user is the manager or super admin
    if (parkingLot.managedBy.toString() !== req.user._id.toString() && req.user.role !== 'super_admin') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to update this parking lot'
      });
    }

    const updatedParkingLot = await ParkingLot.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );

    res.json({
      success: true,
      message: 'Parking lot updated successfully',
      data: { parkingLot: updatedParkingLot }
    });
  } catch (error) {
    next(error);
  }
});

// @route   GET /api/parking/:id/availability
// @desc    Get real-time availability
// @access  Private
router.get('/:id/availability', auth, async (req, res, next) => {
  try {
    const parkingLot = await ParkingLot.findById(req.params.id);

    if (!parkingLot) {
      return res.status(404).json({
        success: false,
        message: 'Parking lot not found'
      });
    }

    const availableSpots = parkingLot.spots.filter(spot => 
      spot.isAvailable && !spot.isReserved
    );

    const spotsByType = parkingLot.spots.reduce((acc, spot) => {
      if (!acc[spot.type]) {
        acc[spot.type] = { total: 0, available: 0 };
      }
      acc[spot.type].total++;
      if (spot.isAvailable && !spot.isReserved) {
        acc[spot.type].available++;
      }
      return acc;
    }, {});

    res.json({
      success: true,
      data: {
        totalSpots: parkingLot.totalSpots,
        availableSpots: availableSpots.length,
        occupancyRate: ((parkingLot.totalSpots - availableSpots.length) / parkingLot.totalSpots * 100).toFixed(1),
        spotsByType,
        lastUpdated: new Date()
      }
    });
  } catch (error) {
    next(error);
  }
});

// @route   POST /api/parking/:id/reserve
// @desc    Reserve a parking spot
// @access  Private
router.post('/:id/reserve', auth, async (req, res, next) => {
  try {
    const { spotNumber, duration } = req.body;

    if (!spotNumber || !duration) {
      return res.status(400).json({
        success: false,
        message: 'Spot number and duration are required'
      });
    }

    const parkingLot = await ParkingLot.findById(req.params.id);

    if (!parkingLot) {
      return res.status(404).json({
        success: false,
        message: 'Parking lot not found'
      });
    }

    const spot = parkingLot.spots.find(s => s.spotNumber === spotNumber);

    if (!spot) {
      return res.status(404).json({
        success: false,
        message: 'Parking spot not found'
      });
    }

    if (!spot.isAvailable || spot.isReserved) {
      return res.status(400).json({
        success: false,
        message: 'Parking spot is not available'
      });
    }

    // Reserve the spot for 15 minutes to complete booking
    spot.isReserved = true;
    spot.reservedBy = req.user._id;
    spot.reservedUntil = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes

    await parkingLot.updateAvailableSpots();

    res.json({
      success: true,
      message: 'Spot reserved successfully',
      data: {
        spotNumber,
        reservedUntil: spot.reservedUntil,
        parkingLot: {
          id: parkingLot._id,
          name: parkingLot.name,
          address: parkingLot.address
        }
      }
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;