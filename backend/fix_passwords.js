const mongoose = require('mongoose');
const User = require('./src/models/User');
const bcrypt = require('bcryptjs');
require('dotenv').config();

async function fixPasswords() {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/parkease');
    console.log('✅ Connected to database');
    
    const users = await User.find({});
    console.log(`📊 Found ${users.length} users to fix`);
    
    for (const user of users) {
      // Hash the password properly
      const salt = await bcrypt.genSalt(12);
      const hashedPassword = await bcrypt.hash('password123', salt);
      
      // Update user with properly hashed password
      await User.findByIdAndUpdate(user._id, { 
        password: hashedPassword 
      });
      
      console.log(`✅ Fixed password for: ${user.email}`);
    }
    
    // Fix admin password separately
    const adminUser = await User.findOne({ email: 'admin@parkease.com' });
    if (adminUser) {
      const salt = await bcrypt.genSalt(12);
      const hashedAdminPassword = await bcrypt.hash('admin123', salt);
      
      await User.findByIdAndUpdate(adminUser._id, { 
        password: hashedAdminPassword 
      });
      
      console.log('✅ Fixed admin password');
    }
    
    console.log('\n🎉 All passwords fixed!');
    console.log('\n🔐 Test Credentials:');
    console.log('Regular users: password123');
    console.log('Admin: admin123');
    
    // Test one password
    const testUser = await User.findOne({ email: 'john.smith@email.com' }).select('+password');
    if (testUser) {
      const isValid = await testUser.comparePassword('password123');
      console.log(`\n🧪 Password test: ${isValid ? '✅ SUCCESS' : '❌ FAILED'}`);
    }
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

fixPasswords();