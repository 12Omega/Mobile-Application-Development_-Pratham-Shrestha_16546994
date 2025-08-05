const axios = require('axios');

async function testLogin() {
  try {
    console.log('🧪 Testing login endpoint...');
    
    const response = await axios.post('http://localhost:3000/api/auth/login', {
      email: 'john.smith@email.com',
      password: 'password123'
    });
    
    console.log('✅ Login successful!');
    console.log('📊 Response:', {
      success: response.data.success,
      message: response.data.message,
      user: response.data.data.user.name,
      email: response.data.data.user.email,
      token: response.data.data.token ? 'Token received' : 'No token'
    });
    
  } catch (error) {
    if (error.response) {
      console.log('❌ Login failed:', error.response.data);
    } else if (error.code === 'ECONNREFUSED') {
      console.log('❌ Backend server is not running!');
      console.log('💡 Start the backend with: npm start');
    } else {
      console.log('❌ Error:', error.message);
    }
  }
}

testLogin();