const express = require('express');
const Joi = require('joi');
const Booking = require('../models/Booking');
const ParkingLot = require('../models/ParkingLot');
const { auth } = require('../middleware/auth');

const router = express.Router();

// Validation schema
const createBookingSchema = Joi.object({
  parkingLotId: Joi.string().required(),
  spotNumber: Joi.string().required(),
  startTime: Joi.date().iso().required(),
  endTime: Joi.date().iso().required(),
  vehicleInfo: Joi.object({
    licensePlate: Joi.string().required(),
    vehicleType: Joi.string().valid('car', 'motorcycle', 'truck').required(),
    color: Joi.string(),
    model: Joi.string()
  }).required(),
  paymentMethod: Joi.string().valid('card', 'wallet', 'cash').required()
});

// @route   POST /api/bookings
// @desc    Create a new booking
// @access  Private
router.post('/', auth, async (req, res, next) => {
  try {
    const { error } = createBookingSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        message: error.details[0].message
      });
    }

    const { parkingLotId, spotNumber, startTime, endTime, vehicleInfo, paymentMethod } = req.body;

    // Validate parking lot and spot
    const parkingLot = await ParkingLot.findById(parkingLotId);
    if (!parkingLot) {
      return res.status(404).json({
        success: false,
        message: 'Parking lot not found'
      });
    }

    const spot = parkingLot.spots.find(s => s.spotNumber === spotNumber);
    if (!spot || !spot.isReserved || spot.reservedBy.toString() !== req.user._id.toString()) {
      return res.status(400).json({
        success: false,
        message: 'Spot is not reserved by you or reservation expired'
      });
    }

    // Calculate duration and pricing
    const start = new Date(startTime);
    const end = new Date(endTime);
    const duration = Math.ceil((end - start) / (1000 * 60)); // minutes
    
    if (duration <= 0) {
      return res.status(400).json({
        success: false,
        message: 'End time must be after start time'
      });
    }

    const hours = Math.ceil(duration / 60);
    const baseAmount = hours * parkingLot.pricing.hourlyRate;
    const taxes = baseAmount * 0.08; // 8% tax
    const fees = 2.50; // Processing fee
    const totalAmount = baseAmount + taxes + fees;

    // Create booking
    const booking = new Booking({
      user: req.user._id,
      parkingLot: parkingLotId,
      spotNumber,
      vehicleInfo,
      bookingDetails: {
        startTime: start,
        endTime: end,
        duration
      },
      pricing: {
        baseAmount,
        taxes,
        fees,
        totalAmount,
        currency: parkingLot.pricing.currency
      },
      payment: {
        method: paymentMethod,
        status: 'pending'
      }
    });

    booking.generateQRCode();
    await booking.save();

    // Update spot status
    spot.isAvailable = false;
    spot.isReserved = false;
    spot.reservedBy = null;
    spot.reservedUntil = null;
    
    await parkingLot.updateAvailableSpots();

    res.status(201).json({
      success: true,
      message: 'Booking created successfully',
      data: { booking }
    });
  } catch (error) {
    next(error);
  }
});

// @route   GET /api/bookings
// @desc    Get user's bookings
// @access  Private
router.get('/', auth, async (req, res, next) => {
  try {
    const { status, page = 1, limit = 10 } = req.query;
    
    const query = { user: req.user._id };
    if (status) {
      query.status = status;
    }

    const bookings = await Booking.find(query)
      .populate('parkingLot', 'name address location pricing')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await Booking.countDocuments(query);

    res.json({
      success: true,
      count: bookings.length,
      total,
      data: { bookings }
    });
  } catch (error) {
    next(error);
  }
});

// @route   GET /api/bookings/:id
// @desc    Get booking details
// @access  Private
router.get('/:id', auth, async (req, res, next) => {
  try {
    const booking = await Booking.findById(req.params.id)
      .populate('user', 'name email phone')
      .populate('parkingLot', 'name address location pricing contactInfo');

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: 'Booking not found'
      });
    }

    // Check if user owns this booking or is admin
    if (booking.user._id.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to view this booking'
      });
    }

    res.json({
      success: true,
      data: { booking }
    });
  } catch (error) {
    next(error);
  }
});

// @route   PUT /api/bookings/:id/cancel
// @desc    Cancel a booking
// @access  Private
router.put('/:id/cancel', auth, async (req, res, next) => {
  try {
    const booking = await Booking.findById(req.params.id);

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: 'Booking not found'
      });
    }

    if (booking.user.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to cancel this booking'
      });
    }

    if (!booking.canBeCancelled()) {
      return res.status(400).json({
        success: false,
        message: 'Booking cannot be cancelled (too close to start time or already active)'
      });
    }

    // Update booking status
    booking.status = 'cancelled';
    booking.cancellation = {
      cancelledAt: new Date(),
      reason: req.body.reason || 'User cancelled',
      refundEligible: true
    };

    // Update payment status for refund processing
    if (booking.payment.status === 'completed') {
      booking.payment.status = 'refunded';
      booking.payment.refundedAt = new Date();
      booking.payment.refundAmount = booking.pricing.totalAmount;
    }

    await booking.save();

    // Free up the parking spot
    const parkingLot = await ParkingLot.findById(booking.parkingLot);
    if (parkingLot) {
      const spot = parkingLot.spots.find(s => s.spotNumber === booking.spotNumber);
      if (spot) {
        spot.isAvailable = true;
        spot.isReserved = false;
        spot.reservedBy = null;
        spot.reservedUntil = null;
        await parkingLot.updateAvailableSpots();
      }
    }

    res.json({
      success: true,
      message: 'Booking cancelled successfully',
      data: { booking }
    });
  } catch (error) {
    next(error);
  }
});

// @route   PUT /api/bookings/:id/checkin
// @desc    Check in to parking spot
// @access  Private
router.put('/:id/checkin', auth, async (req, res, next) => {
  try {
    const booking = await Booking.findById(req.params.id);

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: 'Booking not found'
      });
    }

    if (booking.user.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to check in to this booking'
      });
    }

    if (booking.status !== 'reserved') {
      return res.status(400).json({
        success: false,
        message: 'Booking is not in reserved status'
      });
    }

    // Update booking status
    booking.status = 'active';
    booking.bookingDetails.actualStartTime = new Date();
    booking.notifications.arrivalNotified = true;

    await booking.save();

    res.json({
      success: true,
      message: 'Checked in successfully',
      data: { booking }
    });
  } catch (error) {
    next(error);
  }
});

// @route   PUT /api/bookings/:id/checkout
// @desc    Check out from parking spot
// @access  Private
router.put('/:id/checkout', auth, async (req, res, next) => {
  try {
    const booking = await Booking.findById(req.params.id);

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: 'Booking not found'
      });
    }

    if (booking.user.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized access to booking'
      });
    }

    if (booking.status !== 'active') {
      return res.status(400).json({
        success: false,
        message: 'Booking is not in active status'
      });
    }

    // Update booking status
    booking.status = 'completed';
    booking.bookingDetails.actualEndTime = new Date();
    await booking.save();

    // Free up the parking spot
    const parkingLot = await ParkingLot.findById(booking.parkingLot);
    const spot = parkingLot.spots.find(s => s.spotNumber === booking.spotNumber);
    if (spot) {
      spot.isAvailable = true;
      await parkingLot.updateAvailableSpots();
    }

    res.json({
      success: true,
      message: 'Checked out successfully',
      data: { booking }
    });
  } catch (error) {
    next(error);
  }
});

// @route   POST /api/bookings/:id/feedback
// @desc    Submit booking feedback
// @access  Private
router.post('/:id/feedback', auth, async (req, res, next) => {
  try {
    const { rating, comment } = req.body;

    if (!rating || rating < 1 || rating > 5) {
      return res.status(400).json({
        success: false,
        message: 'Rating must be between 1 and 5'
      });
    }

    const booking = await Booking.findById(req.params.id);

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: 'Booking not found'
      });
    }

    if (booking.user.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to provide feedback for this booking'
      });
    }

    if (booking.status !== 'completed') {
      return res.status(400).json({
        success: false,
        message: 'Can only provide feedback for completed bookings'
      });
    }

    booking.feedback = {
      rating,
      comment,
      submittedAt: new Date()
    };

    await booking.save();

    res.json({
      success: true,
      message: 'Feedback submitted successfully',
      data: { booking }
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;