const request = require('supertest');
const mongoose = require('mongoose');
const app = require('../src/server');
const User = require('../src/models/User');
const ParkingLot = require('../src/models/ParkingLot');

describe('Parking Routes', () => {
  let userToken;
  let adminToken;
  let testUser;
  let testAdmin;
  let testParkingLot;

  beforeAll(async () => {
    const MONGODB_URI = process.env.MONGODB_TEST_URI || 'mongodb://localhost:27017/parkease_test';
    await mongoose.connect(MONGODB_URI);
  });

  beforeEach(async () => {
    // Clean up database
    await User.deleteMany({});
    await ParkingLot.deleteMany({});

    // Create test user
    const userResponse = await request(app)
      .post('/api/auth/register')
      .send({
        name: 'Test User',
        email: 'user@test.com',
        password: 'password123',
        phone: '+1234567890',
        vehicleInfo: {
          licensePlate: 'USER123',
          vehicleType: 'car'
        }
      });

    userToken = userResponse.body.data.token;
    testUser = userResponse.body.data.user;

    // Create test admin
    const adminResponse = await request(app)
      .post('/api/auth/register')
      .send({
        name: 'Test Admin',
        email: 'admin@test.com',
        password: 'password123',
        phone: '+1234567891',
        vehicleInfo: {
          licensePlate: 'ADMIN123',
          vehicleType: 'car'
        }
      });

    adminToken = adminResponse.body.data.token;
    testAdmin = adminResponse.body.data.user;
l(async () => {
    await mongoose.connection.close();
  });

  describe('POST /api/parking', () => {
    const validParkingLotData = {
      name: 'Downtown Parking',
      address: {
        street: '123 Main St',
        city: 'Anytown',
        state: 'CA',
        zipCode: '12345'
      },
      location: {
        type: 'Point',
        coordinates: [-122.4194, 37.7749] // San Francisco coordinates
      },
      totalSpots: 50,
      pricing: {
        hourlyRate: 5.00,
        dailyRate: 30.00
      },
      amenities: ['covered', 'security'],
      operatingHours: {
        open: '06:00',
        close: '22:00'
      },
      contactInfo: {
        phone: '+1234567892',
        email: 'info@downtownparking.com'
      }
    };

    it('should create parking lot as admin', async () => {
      const response = await request(app)
        .post('/api/parking')
        .set('Authorization', `Bearer ${adminToken}`)
        .send(validParkingLotData)
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.data.parkingLot.name).toBe(validParkingLotData.name);
      expect(response.body.data.parkingLot.spots).toHaveLength(50);
      expect(response.body.data.parkingLot.availableSpots).toBe(50);
    });

    it('should not create parking lot as regular user', async () => {
      const response = await request(app)
        .post('/api/parking')
        .set('Authorization', `Bearer ${userToken}`)
        .send(validParkingLotData)
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Admin privileges required');
    });

    it('should not create parking lot without authentication', async () => {
      const response = await request(app)
        .post('/api/parking')
        .send(validParkingLotData)
        .expect(401);

      expect(response.body.success).toBe(false);
    });

    it('should not create parking lot with invalid data', async () => {
      const invalidData = { ...validParkingLotData };
      delete invalidData.name;

      const response = await request(app)
        .post('/api/parking')
        .set('Authorization', `Bearer ${adminToken}`)
        .send(invalidData)
        .expect(400);

      expect(response.body.success).toBe(false);
    });
  });

  describe('GET /api/parking/nearby', () => {
    beforeEach(async () => {
      // Create a parking lot for testing
      await request(app)
        .post('/api/parking')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          name: 'Test Parking',
          address: {
            street: '123 Test St',
            city: 'Test City',
            state: 'CA',
            zipCode: '12345'
          },
          location: {
            type: 'Point',
            coordinates: [-122.4194, 37.7749]
          },
          totalSpots: 20,
          pricing: {
            hourlyRate: 4.00,
            dailyRate: 25.00
          },
          operatingHours: {
            open: '06:00',
            close: '22:00'
          }
        });
    });

    it('should get nearby parking lots', async () => {
      const response = await request(app)
        .get('/api/parking/nearby')
        .set('Authorization', `Bearer ${userToken}`)
        .query({
          longitude: -122.4194,
          latitude: 37.7749,
          radius: 5000
        })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.parkingLots).toHaveLength(1);
    });

    it('should require longitude and latitude', async () => {
      const response = await request(app)
        .get('/api/parking/nearby')
        .set('Authorization', `Bearer ${userToken}`)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Longitude and latitude are required');
    });

    it('should not get nearby parking lots without authentication', async () => {
      const response = await request(app)
        .get('/api/parking/nearby')
        .query({
          longitude: -122.4194,
          latitude: 37.7749
        })
        .expect(401);

      expect(response.body.success).toBe(false);
    });
  });

  describe('GET /api/parking/:id', () => {
    let parkingLotId;

    beforeEach(async () => {
      const response = await request(app)
        .post('/api/parking')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          name: 'Test Parking',
          address: {
            street: '123 Test St',
            city: 'Test City',
            state: 'CA',
            zipCode: '12345'
          },
          location: {
            type: 'Point',
            coordinates: [-122.4194, 37.7749]
          },
          totalSpots: 20,
          pricing: {
            hourlyRate: 4.00,
            dailyRate: 25.00
          },
          operatingHours: {
            open: '06:00',
            close: '22:00'
          }
        });

      parkingLotId = response.body.data.parkingLot._id;
    });

    it('should get parking lot details', async () => {
      const response = await request(app)
        .get(`/api/parking/${parkingLotId}`)
        .set('Authorization', `Bearer ${userToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.parkingLot._id).toBe(parkingLotId);
      expect(response.body.data.parkingLot.managedBy).toBeDefined();
    });

    it('should return 404 for non-existent parking lot', async () => {
      const fakeId = new mongoose.Types.ObjectId();
      const response = await request(app)
        .get(`/api/parking/${fakeId}`)
        .set('Authorization', `Bearer ${userToken}`)
        .expect(404);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('not found');
    });
  });

  describe('GET /api/parking/:id/availability', () => {
    let parkingLotId;

    beforeEach(async () => {
      const response = await request(app)
        .post('/api/parking')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          name: 'Test Parking',
          address: {
            street: '123 Test St',
            city: 'Test City',
            state: 'CA',
            zipCode: '12345'
          },
          location: {
            type: 'Point',
            coordinates: [-122.4194, 37.7749]
          },
          totalSpots: 20,
          pricing: {
            hourlyRate: 4.00,
            dailyRate: 25.00
          },
          operatingHours: {
            open: '06:00',
            close: '22:00'
          }
        });

      parkingLotId = response.body.data.parkingLot._id;
    });

    it('should get parking lot availability', async () => {
      const response = await request(app)
        .get(`/api/parking/${parkingLotId}/availability`)
        .set('Authorization', `Bearer ${userToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.totalSpots).toBe(20);
      expect(response.body.data.availableSpots).toBe(20);
      expect(response.body.data.occupancyRate).toBe('0.0');
      expect(response.body.data.spotsByType).toBeDefined();
    });
  });

  describe('POST /api/parking/:id/reserve', () => {
    let parkingLotId;

    beforeEach(async () => {
      const response = await request(app)
        .post('/api/parking')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          name: 'Test Parking',
          address: {
            street: '123 Test St',
            city: 'Test City',
            state: 'CA',
            zipCode: '12345'
          },
          location: {
            type: 'Point',
            coordinates: [-122.4194, 37.7749]
          },
          totalSpots: 20,
          pricing: {
            hourlyRate: 4.00,
            dailyRate: 25.00
          },
          operatingHours: {
            open: '06:00',
            close: '22:00'
          }
        });

      parkingLotId = response.body.data.parkingLot._id;
    });

    it('should reserve a parking spot', async () => {
      const response = await request(app)
        .post(`/api/parking/${parkingLotId}/reserve`)
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          spotNumber: 'A001',
          duration: 120 // 2 hours
        })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.spotNumber).toBe('A001');
      expect(response.body.data.reservedUntil).toBeDefined();
    });

    it('should not reserve without spot number', async () => {
      const response = await request(app)
        .post(`/api/parking/${parkingLotId}/reserve`)
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          duration: 120
        })
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('required');
    });

    it('should not reserve non-existent spot', async () => {
      const response = await request(app)
        .post(`/api/parking/${parkingLotId}/reserve`)
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          spotNumber: 'Z999',
          duration: 120
        })
        .expect(404);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('not found');
    });
  });
});     .set('Authorization', `Bearer ${adminToken}`)
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.data.parkingLot.name).toBe(validParkingLotData.name);
      expect(response.body.data.parkingLot.spots).toHaveLength(20);
    });

    it('should not create parking lot as regular user', async () => {
      const response = await request(app)
        .post('/api/parking')
        .send(validParkingLotData)
        .set('Authorization', `Bearer ${userToken}`)
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Admin privileges required');
    });

    it('should validate required fields', async () => {
      const invalidData = { ...validParkingLotData };
      delete invalidData.name;

      const response = await request(app)
        .post('/api/parking')
        .send(invalidData)
        .set('Authorization', `Bearer ${adminToken}`)
        .expect(400);

      expect(response.body.success).toBe(false);
    });
  });

  describe('GET /api/parking/:id/availability', () => {
    it('should get parking lot availability', async () => {
      const response = await request(app)
        .get(`/api/parking/${testParkingLot._id}/availability`)
        .set('Authorization', `Bearer ${userToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.totalSpots).toBe(10);
      expect(response.body.data.availableSpots).toBe(10);
      expect(response.body.data.occupancyRate).toBe('0.0');
      expect(response.body.data.spotsByType).toBeDefined();
    });
  });

  describe('POST /api/parking/:id/reserve', () => {
    it('should reserve a parking spo 120 // 2 hours
        })
        .set('Authorization', `Bearer ${userToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.spotNumber).toBe('A001');
      expect(response.body.data.reservedUntil).toBeDefined();
    });

    it('should not reserve already reserved spot', async () => {
      // Reserve spot first
      await request(app)
        .post(`/api/parking/${testParkingLot._id}/reserve`)
        .send({
          spotNumber: 'A001',
          duration: 120
        })
        .set('Authorization', `Bearer ${userToken}`);

      // Try to reserve same spot
      const response = await request(app)
        .post(`/api/parking/${testParkingLot._id}/reserve`)
        .send({
          spotNumber: 'A001',
          duration: 120
        })
        .set('Authorization', `Bearer ${userToken}`)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('not available');
    });

    it('should require spot number and duration', async () => {
      const response = await request(app)
        .post(`/api/parking/${testParkingLot._id}/reserve`)
        .send({})
        .set('Authorization', `Bearer ${userToken}`)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('required');
    });
  });
});