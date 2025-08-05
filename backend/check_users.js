const mongoose = require('mongoose');
const User = require('./src/models/User');
require('dotenv').config();

async function checkUsers() {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/parkease');
    console.log('✅ Connected to database');
    
    const users = await User.find({}, 'email name role');
    console.log(`\n📊 Found ${users.length} users in database:`);
    
    if (users.length === 0) {
      console.log('❌ No users found! Database needs to be seeded.');
    } else {
      users.forEach(user => {
        console.log(`- ${user.email} (${user.name}) - Role: ${user.role}`);
      });
    }
    
    // Test password for first user
    if (users.length > 0) {
      const testUser = await User.findOne({ email: 'john.smith@email.com' }).select('+password');
      if (testUser) {
        console.log('\n🔐 Testing password for john.smith@email.com...');
        const isValid = await testUser.comparePassword('password123');
        console.log(`Password test result: ${isValid ? '✅ Valid' : '❌ Invalid'}`);
      }
    }
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

checkUsers();