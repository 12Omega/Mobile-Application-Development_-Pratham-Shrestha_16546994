const mongoose = require('mongoose');
const User = require('../models/User');
const ParkingLot = require('../models/ParkingLot');
const Booking = require('../models/Booking');
const { usersData, parkingLotsData, generateParkingSpots, generateBookingData } = require('./seedData');

// Connect to MongoDB
const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/parkease', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('✅ MongoDB connected successfully');
  } catch (error) {
    console.error('❌ MongoDB connection error:', error);
    process.exit(1);
  }
};

// Clear existing data
const clearDatabase = async () => {
  try {
    await User.deleteMany({});
    await ParkingLot.deleteMany({});
    await Booking.deleteMany({});
    console.log('🗑️  Cleared existing data');
  } catch (error) {
    console.error('❌ Error clearing database:', error);
    throw error;
  }
};

// Seed users
const seedUsers = async () => {
  try {
    const users = await User.insertMany(usersData);
    console.log(`👥 Created ${users.length} users`);
    return users;
  } catch (error) {
    console.error('❌ Error seeding users:', error);
    throw error;
  }
};

// Seed parking lots
const seedParkingLots = async (users) => {
  try {
    const adminUser = users.find(user => user.role === 'admin');
    
    const parkingLotsWithSpots = parkingLotsData.map(lot => {
      const spots = generateParkingSpots(lot.totalSpots, {
        latitude: lot.location.coordinates[1],
        longitude: lot.location.coordinates[0]
      });
      
      const availableSpots = spots.filter(spot => spot.isAvailable && !spot.isReserved).length;
      
      return {
        ...lot,
        spots,
        availableSpots,
        managedBy: adminUser._id
      };
    });
    
    const parkingLots = await ParkingLot.insertMany(parkingLotsWithSpots);
    console.log(`🅿️  Created ${parkingLots.length} parking lots`);
    return parkingLots;
  } catch (error) {
    console.error('❌ Error seeding parking lots:', error);
    throw error;
  }
};

// Seed bookings
const seedBookings = async (users, parkingLots) => {
  try {
    const bookingData = generateBookingData(users, parkingLots);
    const bookings = await Booking.insertMany(bookingData);
    console.log(`📅 Created ${bookings.length} bookings`);
    return bookings;
  } catch (error) {
    console.error('❌ Error seeding bookings:', error);
    throw error;
  }
};

// Main seeding function
const seedDatabase = async () => {
  try {
    console.log('🌱 Starting database seeding...\n');
    
    await connectDB();
    await clearDatabase();
    
    const users = await seedUsers();
    const parkingLots = await seedParkingLots(users);
    const bookings = await seedBookings(users, parkingLots);
    
    console.log('\n✅ Database seeding completed successfully!');
    console.log('\n📊 Summary:');
    console.log(`   Users: ${users.length}`);
    console.log(`   Parking Lots: ${parkingLots.length}`);
    console.log(`   Bookings: ${bookings.length}`);
    console.log(`   Total Parking Spots: ${parkingLots.reduce((sum, lot) => sum + lot.totalSpots, 0)}`);
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Database seeding failed:', error);
    process.exit(1);
  }
};

// Run if called directly
if (require.main === module) {
  require('dotenv').config();
  seedDatabase();
}

module.exports = { seedDatabase };