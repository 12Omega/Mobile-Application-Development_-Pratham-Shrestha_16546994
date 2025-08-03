const express = require('express');
const User = require('../models/User');
const Booking = require('../models/Booking');
const { auth, adminAuth } = require('../middleware/auth');

const router = express.Router();

// @route   GET /api/users/profile
// @desc    Get user profile
// @access  Private
router.get('/profile', auth, async (req, res) => {
  res.json({
    success: true,
    data: { user: req.user }
  });
});

// @route   GET /api/users/dashboard
// @desc    Get user dashboard data
// @access  Private
router.get('/dashboard', auth, async (req, res, next) => {
  try {
    const userId = req.user._id;

    // Get booking statistics
    const [totalBookings, activeBookings, completedBookings, cancelledBookings] = await Promise.all([
      Booking.countDocuments({ user: userId }),
      Booking.countDocuments({ user: userId, status: 'active' }),
      Booking.countDocuments({ user: userId, status: 'completed' }),
      Booking.countDocuments({ user: userId, status: 'cancelled' })
    ]);

    // Get recent bookings
    const recentBookings = await Booking.find({ user: userId })
      .populate('parkingLot', 'name address')
      .sort({ createdAt: -1 })
      .limit(5);

    // Calculate total spent
    const completedBookingsWithAmount = await Booking.find({ 
      user: userId, 
      status: 'completed',
      'payment.status': 'completed'
    });
    
    const totalSpent = completedBookingsWithAmount.reduce((sum, booking) => 
      sum + booking.pricing.totalAmount, 0
    );

    // Get current active booking
    const currentBooking = await Booking.findOne({ 
      user: userId, 
      status: 'active' 
    }).populate('parkingLot', 'name address location');

    res.json({
      success: true,
      data: {
        statistics: {
          totalBookings,
          activeBookings,
          completedBookings,
          cancelledBookings,
          totalSpent: totalSpent.toFixed(2)
        },
        recentBookings,
        currentBooking
      }
    });
  } catch (error) {
    next(error);
  }
});

// @route   GET /api/users
// @desc    Get all users (Admin only)
// @access  Admin
router.get('/', adminAuth, async (req, res, next) => {
  try {
    const { page = 1, limit = 10, search, role } = req.query;
    
    const query = {};
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } }
      ];
    }
    if (role) {
      query.role = role;
    }

    const users = await User.find(query)
      .select('-password')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await User.countDocuments(query);

    res.json({
      success: true,
      count: users.length,
      total,
      pages: Math.ceil(total / limit),
      currentPage: page,
      data: { users }
    });
  } catch (error) {
    next(error);
  }
});

// @route   PUT /api/users/profile
// @desc    Update user profile
// @access  Private
router.put('/profile', auth, async (req, res, next) => {
  try {
    const { name, phone, vehicleInfo, preferences } = req.body;
    
    const updateData = {};
    if (name) updateData.name = name;
    if (phone) updateData.phone = phone;
    if (vehicleInfo) updateData.vehicleInfo = vehicleInfo;
    if (preferences) updateData.preferences = preferences;

    const user = await User.findByIdAndUpdate(
      req.user._id,
      updateData,
      { new: true, runValidators: true }
    ).select('-password');

    res.json({
      success: true,
      message: 'Profile updated successfully',
      data: { user }
    });
  } catch (error) {
    next(error);
  }
});

// @route   GET /api/users/:id (Admin only)
// @desc    Get user by ID
// @access  Admin
router.get('/:id', adminAuth, async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id).select('-password');
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Get user's booking statistics
    const bookingStats = await Booking.aggregate([
      { $match: { user: user._id } },
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 },
          totalAmount: { $sum: '$pricing.totalAmount' }
        }
      }
    ]);

    res.json({
      success: true,
      data: { 
        user,
        bookingStats
      }
    });
  } catch (error) {
    next(error);
  }
});

// @route   PUT /api/users/:id/status (Admin only)
// @desc    Update user status (activate/deactivate)
// @access  Admin
router.put('/:id/status', adminAuth, async (req, res, next) => {
  try {
    const { isActive } = req.body;
    
    if (typeof isActive !== 'boolean') {
      return res.status(400).json({
        success: false,
        message: 'isActive must be a boolean value'
      });
    }

    const user = await User.findByIdAndUpdate(
      req.params.id,
      { isActive },
      { new: true, runValidators: true }
    ).select('-password');

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.json({
      success: true,
      message: `User ${isActive ? 'activated' : 'deactivated'} successfully`,
      data: { user }
    });
  } catch (error) {
    next(error);
  }
});

// @route   DELETE /api/users/profile
// @desc    Delete user account
// @access  Private
router.delete('/profile', auth, async (req, res, next) => {
  try {
    // Check for active bookings
    const activeBookings = await Booking.countDocuments({ 
      user: req.user._id, 
      status: { $in: ['reserved', 'active'] }
    });

    if (activeBookings > 0) {
      return res.status(400).json({
        success: false,
        message: 'Cannot delete account with active bookings. Please complete or cancel them first.'
      });
    }

    // Soft delete - deactivate account
    await User.findByIdAndUpdate(req.user._id, { isActive: false });

    res.json({
      success: true,
      message: 'Account deactivated successfully'
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;