// LEGACY STUB FILE - TO BE REMOVED DURING MIGRATION
// This file exists only to satisfy legacy imports
// Use Clean Architecture version in features/profile/ instead

import '../models/vehicle.dart';

abstract class VehicleRepository {
  Future<List<Vehicle>> getUserVehicles(String userId);
  Future<Vehicle> addVehicle(String userId, Vehicle vehicle);
  Future<Vehicle> updateVehicle(Vehicle vehicle);
  Future<void> deleteVehicle(String vehicleId);
}
