const bcrypt = require('bcryptjs');

async function createHashedPassword() {
  const password = 'password123';
  const salt = await bcrypt.genSalt(12);
  const hashedPassword = await bcrypt.hash(password, salt);
  
  console.log('Hashed password for "password123":');
  console.log(hashedPassword);
  
  // Create the complete user object
  const testUser = {
    name: "Test User",
    email: "testuser@example.com",
    password: hashedPassword,
    phone: "+1234567890",
    role: "user",
    vehicleInfo: {
      licensePlate: "TEST123",
      vehicleType: "car",
      color: "blue",
      model: "Toyota Camry"
    },
    preferences: {
      notifications: true,
      theme: "system"
    },
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date()
  };
  
  console.log('\nComplete user object to insert:');
  console.log(JSON.stringify(testUser, null, 2));
}

createHashedPassword().catch(console.error);