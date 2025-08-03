const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  parkingLot: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'ParkingLot',
    required: true
  },
  spotNumber: {
    type: String,
    required: true
  },
  vehicleInfo: {
    licensePlate: { type: String, required: true },
    vehicleType: { type: String, required: true },
    color: String,
    model: String
  },
  bookingDetails: {
    startTime: {
      type: Date,
      required: true
    },
    endTime: {
      type: Date,
      required: true
    },
    duration: {
      type: Number, // in minutes
      required: true
    },
    actualStartTime: Date,
    actualEndTime: Date
  },
  pricing: {
    baseAmount: {
      type: Number,
      required: true,
      min: 0
    },
    taxes: {
      type: Number,
      default: 0,
      min: 0
    },
    fees: {
      type: Number,
      default: 0,
      min: 0
    },
    totalAmount: {
      type: Number,
      required: true,
      min: 0
    },
    currency: {
      type: String,
      default: 'USD'
    }
  },
  payment: {
    method: {
      type: String,
      enum: ['card', 'wallet', 'cash'],
      required: true
    },
    status: {
      type: String,
      enum: ['pending', 'completed', 'failed', 'refunded'],
      default: 'pending'
    },
    transactionId: String,
    paidAt: Date,
    refundedAt: Date,
    refundAmount: Number
  },
  status: {
    type: String,
    enum: ['reserved', 'active', 'completed', 'cancelled', 'no_show'],
    default: 'reserved'
  },
  qrCode: {
    type: String,
    unique: true
  },
  notifications: {
    reminderSent: { type: Boolean, default: false },
    arrivalNotified: { type: Boolean, default: false },
    completionNotified: { type: Boolean, default: false }
  },
  feedback: {
    rating: {
      type: Number,
      min: 1,
      max: 5
    },
    comment: String,
    submittedAt: Date
  },
  cancellation: {
    cancelledAt: Date,
    reason: String,
    refundEligible: { type: Boolean, default: false }
  }
}, {
  timestamps: true
});

// Indexes for efficient queries
bookingSchema.index({ user: 1, createdAt: -1 });
bookingSchema.index({ parkingLot: 1, 'bookingDetails.startTime': 1 });
bookingSchema.index({ status: 1 });
bookingSchema.index({ qrCode: 1 });

// Generate QR code for booking
bookingSchema.methods.generateQRCode = function() {
  const crypto = require('crypto');
  this.qrCode = crypto.randomBytes(16).toString('hex');
  return this.qrCode;
};

// Calculate total amount
bookingSchema.methods.calculateTotal = function() {
  this.pricing.totalAmount = this.pricing.baseAmount + this.pricing.taxes + this.pricing.fees;
  return this.pricing.totalAmount;
};

// Check if booking is active
bookingSchema.methods.isActive = function() {
  const now = new Date();
  return this.status === 'active' && 
         this.bookingDetails.startTime <= now && 
         this.bookingDetails.endTime >= now;
};

// Check if booking can be cancelled
bookingSchema.methods.canBeCancelled = function() {
  const now = new Date();
  const timeDiff = this.bookingDetails.startTime.getTime() - now.getTime();
  const hoursUntilStart = timeDiff / (1000 * 60 * 60);
  
  return this.status === 'reserved' && hoursUntilStart >= 1; // Can cancel up to 1 hour before
};

module.exports = mongoose.model('Booking', bookingSchema);