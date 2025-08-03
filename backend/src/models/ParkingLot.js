const mongoose = require('mongoose');

const parkingSpotSchema = new mongoose.Schema({
  spotNumber: {
    type: String,
    required: true
  },
  type: {
    type: String,
    enum: ['regular', 'disabled', 'electric', 'compact'],
    default: 'regular'
  },
  isAvailable: {
    type: Boolean,
    default: true
  },
  isReserved: {
    type: Boolean,
    default: false
  },
  reservedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null
  },
  reservedUntil: {
    type: Date,
    default: null
  },
  coordinates: {
    latitude: Number,
    longitude: Number
  }
});

const parkingLotSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Parking lot name is required'],
    trim: true
  },
  address: {
    street: { type: String, required: true },
    city: { type: String, required: true },
    state: { type: String, required: true },
    zipCode: { type: String, required: true },
    country: { type: String, default: 'USA' }
  },
  location: {
    type: {
      type: String,
      enum: ['Point'],
      required: true
    },
    coordinates: {
      type: [Number], // [longitude, latitude]
      required: true
    }
  },
  totalSpots: {
    type: Number,
    required: true,
    min: 1
  },
  availableSpots: {
    type: Number,
    required: true,
    min: 0
  },
  spots: [parkingSpotSchema],
  pricing: {
    hourlyRate: {
      type: Number,
      required: true,
      min: 0
    },
    dailyRate: {
      type: Number,
      required: true,
      min: 0
    },
    currency: {
      type: String,
      default: 'USD'
    }
  },
  amenities: [{
    type: String,
    enum: ['covered', 'security', 'ev_charging', 'valet', 'car_wash', '24_hour']
  }],
  operatingHours: {
    open: { type: String, required: true }, // "06:00"
    close: { type: String, required: true }, // "22:00"
    is24Hours: { type: Boolean, default: false }
  },
  contactInfo: {
    phone: String,
    email: String
  },
  isActive: {
    type: Boolean,
    default: true
  },
  managedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  }
}, {
  timestamps: true
});

// Create geospatial index for location-based queries
parkingLotSchema.index({ location: '2dsphere' });

// Update available spots count
parkingLotSchema.methods.updateAvailableSpots = function() {
  this.availableSpots = this.spots.filter(spot => spot.isAvailable && !spot.isReserved).length;
  return this.save();
};

// Find nearby parking lots
parkingLotSchema.statics.findNearby = function(longitude, latitude, maxDistance = 5000) {
  return this.find({
    location: {
      $near: {
        $geometry: {
          type: 'Point',
          coordinates: [longitude, latitude]
        },
        $maxDistance: maxDistance
      }
    },
    isActive: true
  });
};

module.exports = mongoose.model('ParkingLot', parkingLotSchema);