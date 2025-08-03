const mongoose = require('mongoose');
const User = require('../models/User');
const ParkingLot = require('../models/ParkingLot');
const Booking = require('../models/Booking');

// Sample users data
const usersData = [
  {
    name: 'John Smith',
    email: 'john.smith@email.com',
    password: 'password123',
    phone: '+1-555-0101',
    role: 'user',
    vehicleInfo: {
      licensePlate: 'ABC123',
      vehicleType: 'car',
      color: 'Blue',
      model: 'Honda Civic'
    }
  },
  {
    name: 'Sarah Johnson',
    email: 'sarah.johnson@email.com',
    password: 'password123',
    phone: '+1-555-0102',
    role: 'user',
    vehicleInfo: {
      licensePlate: 'XYZ789',
      vehicleType: 'car',
      color: 'Red',
      model: 'Toyota Camry'
    }
  },
  {
    name: 'Mike Davis',
    email: 'mike.davis@email.com',
    password: 'password123',
    phone: '+1-555-0103',
    role: 'user',
    vehicleInfo: {
      licensePlate: 'DEF456',
      vehicleType: 'truck',
      color: 'Black',
      model: 'Ford F-150'
    }
  },
  {
    name: 'Emily Wilson',
    email: 'emily.wilson@email.com',
    password: 'password123',
    phone: '+1-555-0104',
    role: 'user',
    vehicleInfo: {
      licensePlate: 'GHI789',
      vehicleType: 'car',
      color: 'White',
      model: 'BMW 3 Series'
    }
  },
  {
    name: 'David Brown',
    email: 'david.brown@email.com',
    password: 'password123',
    phone: '+1-555-0105',
    role: 'user',
    vehicleInfo: {
      licensePlate: 'JKL012',
      vehicleType: 'motorcycle',
      color: 'Green',
      model: 'Harley Davidson'
    }
  },
  {
    name: 'Lisa Garcia',
    email: 'lisa.garcia@email.com',
    password: 'password123',
    phone: '+1-555-0106',
    role: 'user',
    vehicleInfo: {
      licensePlate: 'MNO345',
      vehicleType: 'car',
      color: 'Silver',
      model: 'Mercedes C-Class'
    }
  },
  {
    name: 'Admin User',
    email: 'admin@parkease.com',
    password: 'admin123',
    phone: '+1-555-0001',
    role: 'admin',
    vehicleInfo: {
      licensePlate: 'ADMIN01',
      vehicleType: 'car',
      color: 'Black',
      model: 'Tesla Model S'
    }
  }
];

// Generate parking spots for a lot
const generateParkingSpots = (totalSpots, lotCoords) => {
  const spots = [];
  const spotTypes = ['regular', 'disabled', 'electric', 'compact'];
  
  for (let i = 1; i <= totalSpots; i++) {
    const spotNumber = `A${i.toString().padStart(2, '0')}`;
    let type = 'regular';
    
    // Assign special spot types
    if (i <= 2) type = 'disabled';
    else if (i <= 6) type = 'electric';
    else if (i <= 10) type = 'compact';
    
    spots.push({
      spotNumber,
      type,
      isAvailable: Math.random() > 0.3, // 70% available
      isReserved: false,
      coordinates: {
        latitude: lotCoords.latitude + (Math.random() - 0.5) * 0.001,
        longitude: lotCoords.longitude + (Math.random() - 0.5) * 0.001
      }
    });
  }
  
  return spots;
};

// Sample parking lots data (various locations)
const parkingLotsData = [
  {
    name: 'Downtown Business Center',
    address: {
      street: '123 Main Street',
      city: 'New York',
      state: 'NY',
      zipCode: '10001',
      country: 'USA'
    },
    location: {
      type: 'Point',
      coordinates: [-74.0060, 40.7128] // NYC coordinates
    },
    totalSpots: 50,
    pricing: {
      hourlyRate: 8.50,
      dailyRate: 45.00,
      currency: 'USD'
    },
    amenities: ['covered', 'security', 'ev_charging', '24_hour'],
    operatingHours: {
      open: '00:00',
      close: '23:59',
      is24Hours: true
    },
    contactInfo: {
      phone: '+1-555-1001',
      email: 'downtown@parkease.com'
    }
  },
  {
    name: 'Shopping Mall Parking',
    address: {
      street: '456 Commerce Ave',
      city: 'Los Angeles',
      state: 'CA',
      zipCode: '90210',
      country: 'USA'
    },
    location: {
      type: 'Point',
      coordinates: [-118.2437, 34.0522] // LA coordinates
    },
    totalSpots: 120,
    pricing: {
      hourlyRate: 5.00,
      dailyRate: 25.00,
      currency: 'USD'
    },
    amenities: ['covered', 'security', 'car_wash'],
    operatingHours: {
      open: '06:00',
      close: '22:00',
      is24Hours: false
    },
    contactInfo: {
      phone: '+1-555-1002',
      email: 'mall@parkease.com'
    }
  },
  {
    name: 'Airport Long-term Parking',
    address: {
      street: '789 Airport Blvd',
      city: 'Chicago',
      state: 'IL',
      zipCode: '60601',
      country: 'USA'
    },
    location: {
      type: 'Point',
      coordinates: [-87.6298, 41.8781] // Chicago coordinates
    },
    totalSpots: 200,
    pricing: {
      hourlyRate: 12.00,
      dailyRate: 85.00,
      currency: 'USD'
    },
    amenities: ['security', 'valet', '24_hour'],
    operatingHours: {
      open: '00:00',
      close: '23:59',
      is24Hours: true
    },
    contactInfo: {
      phone: '+1-555-1003',
      email: 'airport@parkease.com'
    }
  },
  {
    name: 'University Campus Parking',
    address: {
      street: '321 College Way',
      city: 'Boston',
      state: 'MA',
      zipCode: '02101',
      country: 'USA'
    },
    location: {
      type: 'Point',
      coordinates: [-71.0589, 42.3601] // Boston coordinates
    },
    totalSpots: 80,
    pricing: {
      hourlyRate: 3.50,
      dailyRate: 15.00,
      currency: 'USD'
    },
    amenities: ['ev_charging', 'security'],
    operatingHours: {
      open: '05:00',
      close: '23:00',
      is24Hours: false
    },
    contactInfo: {
      phone: '+1-555-1004',
      email: 'campus@parkease.com'
    }
  },
  {
    name: 'Medical Center Parking',
    address: {
      street: '654 Health Drive',
      city: 'Miami',
      state: 'FL',
      zipCode: '33101',
      country: 'USA'
    },
    location: {
      type: 'Point',
      coordinates: [-80.1918, 25.7617] // Miami coordinates
    },
    totalSpots: 150,
    pricing: {
      hourlyRate: 6.00,
      dailyRate: 35.00,
      currency: 'USD'
    },
    amenities: ['covered', 'security', 'valet', '24_hour'],
    operatingHours: {
      open: '00:00',
      close: '23:59',
      is24Hours: true
    },
    contactInfo: {
      phone: '+1-555-1005',
      email: 'medical@parkease.com'
    }
  },
  {
    name: 'Sports Stadium Parking',
    address: {
      street: '987 Stadium Way',
      city: 'Denver',
      state: 'CO',
      zipCode: '80201',
      country: 'USA'
    },
    location: {
      type: 'Point',
      coordinates: [-104.9903, 39.7392] // Denver coordinates
    },
    totalSpots: 300,
    pricing: {
      hourlyRate: 15.00,
      dailyRate: 75.00,
      currency: 'USD'
    },
    amenities: ['security'],
    operatingHours: {
      open: '06:00',
      close: '24:00',
      is24Hours: false
    },
    contactInfo: {
      phone: '+1-555-1006',
      email: 'stadium@parkease.com'
    }
  },
  {
    name: 'Beach Resort Parking',
    address: {
      street: '147 Ocean View Blvd',
      city: 'San Diego',
      state: 'CA',
      zipCode: '92101',
      country: 'USA'
    },
    location: {
      type: 'Point',
      coordinates: [-117.1611, 32.7157] // San Diego coordinates
    },
    totalSpots: 75,
    pricing: {
      hourlyRate: 10.00,
      dailyRate: 50.00,
      currency: 'USD'
    },
    amenities: ['valet', 'car_wash'],
    operatingHours: {
      open: '06:00',
      close: '22:00',
      is24Hours: false
    },
    contactInfo: {
      phone: '+1-555-1007',
      email: 'beach@parkease.com'
    }
  },
  {
    name: 'Tech Hub Parking',
    address: {
      street: '258 Innovation Street',
      city: 'Seattle',
      state: 'WA',
      zipCode: '98101',
      country: 'USA'
    },
    location: {
      type: 'Point',
      coordinates: [-122.3321, 47.6062] // Seattle coordinates
    },
    totalSpots: 100,
    pricing: {
      hourlyRate: 7.50,
      dailyRate: 40.00,
      currency: 'USD'
    },
    amenities: ['covered', 'ev_charging', 'security'],
    operatingHours: {
      open: '05:00',
      close: '23:00',
      is24Hours: false
    },
    contactInfo: {
      phone: '+1-555-1008',
      email: 'tech@parkease.com'
    }
  }
];

// Function to generate random booking data
const generateBookingData = (users, parkingLots) => {
  const bookings = [];
  const statuses = ['reserved', 'active', 'completed', 'cancelled'];
  const paymentMethods = ['card', 'wallet', 'cash'];
  const paymentStatuses = ['pending', 'completed', 'failed'];
  
  // Generate 50 bookings
  for (let i = 0; i < 50; i++) {
    const user = users[Math.floor(Math.random() * users.length)];
    const parkingLot = parkingLots[Math.floor(Math.random() * parkingLots.length)];
    const spot = parkingLot.spots[Math.floor(Math.random() * parkingLot.spots.length)];
    
    const startTime = new Date();
    startTime.setDate(startTime.getDate() + Math.floor(Math.random() * 30) - 15); // ±15 days
    startTime.setHours(Math.floor(Math.random() * 24), Math.floor(Math.random() * 60));
    
    const duration = (Math.floor(Math.random() * 8) + 1) * 60; // 1-8 hours in minutes
    const endTime = new Date(startTime.getTime() + duration * 60000);
    
    const baseAmount = parkingLot.pricing.hourlyRate * (duration / 60);
    const taxes = baseAmount * 0.08; // 8% tax
    const fees = 2.50; // Service fee
    const totalAmount = baseAmount + taxes + fees;
    
    const status = statuses[Math.floor(Math.random() * statuses.length)];
    const paymentMethod = paymentMethods[Math.floor(Math.random() * paymentMethods.length)];
    const paymentStatus = paymentStatuses[Math.floor(Math.random() * paymentStatuses.length)];
    
    const booking = {
      user: user._id,
      parkingLot: parkingLot._id,
      spotNumber: spot.spotNumber,
      vehicleInfo: {
        licensePlate: user.vehicleInfo.licensePlate,
        vehicleType: user.vehicleInfo.vehicleType,
        color: user.vehicleInfo.color,
        model: user.vehicleInfo.model
      },
      bookingDetails: {
        startTime,
        endTime,
        duration,
        actualStartTime: status === 'active' || status === 'completed' ? startTime : null,
        actualEndTime: status === 'completed' ? endTime : null
      },
      pricing: {
        baseAmount: Math.round(baseAmount * 100) / 100,
        taxes: Math.round(taxes * 100) / 100,
        fees,
        totalAmount: Math.round(totalAmount * 100) / 100,
        currency: 'USD'
      },
      payment: {
        method: paymentMethod,
        status: paymentStatus,
        transactionId: paymentStatus === 'completed' ? `txn_${Math.random().toString(36).substr(2, 9)}` : null,
        paidAt: paymentStatus === 'completed' ? new Date() : null
      },
      status,
      qrCode: Math.random().toString(36).substr(2, 16),
      notifications: {
        reminderSent: Math.random() > 0.5,
        arrivalNotified: status === 'active' || status === 'completed',
        completionNotified: status === 'completed'
      },
      feedback: status === 'completed' && Math.random() > 0.3 ? {
        rating: Math.floor(Math.random() * 5) + 1,
        comment: [
          'Great parking experience!',
          'Easy to find and book.',
          'Could be cleaner.',
          'Perfect location.',
          'Good value for money.',
          'Will use again.'
        ][Math.floor(Math.random() * 6)],
        submittedAt: new Date()
      } : undefined,
      cancellation: status === 'cancelled' ? {
        cancelledAt: new Date(),
        reason: [
          'Plans changed',
          'Found alternative parking',
          'Emergency',
          'Weather conditions'
        ][Math.floor(Math.random() * 4)],
        refundEligible: Math.random() > 0.5
      } : undefined
    };
    
    bookings.push(booking);
  }
  
  return bookings;
};

module.exports = {
  usersData,
  parkingLotsData,
  generateParkingSpots,
  generateBookingData
};