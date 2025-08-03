import '../../core/models/vehicle.dart';
import '../../core/services/vehicle_repository.dart';
import '../remote/api_service.dart';
import '../models/vehicle_dto.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final ApiService _apiService;

  VehicleRepositoryImpl(this._apiService);

  @override
  Future<List<Vehicle>> getUserVehicles(String userId) async {
    try {
      final vehicleDtos = await _apiService.getUserVehicles(userId);
      return vehicleDtos.map(_mapVehicleDtoToVehicle).toList();
    } catch (e) {
      throw Exception('Failed to get user vehicles: $e');
    }
  }

  @override
  Future<Vehicle> addVehicle(String userId, Vehicle vehicle) async {
    try {
      final vehicleData = {
        'make': vehicle.make,
        'model': vehicle.model,
        'year': vehicle.year,
        'color': vehicle.color,
        'licensePlate': vehicle.licensePlate,
        'nickname': vehicle.nickname,
      };

      final vehicleDto = await _apiService.addVehicle(userId, vehicleData);
      return _mapVehicleDtoToVehicle(vehicleDto);
    } catch (e) {
      throw Exception('Failed to add vehicle: $e');
    }
  }

  @override
  Future<Vehicle> updateVehicle(Vehicle vehicle) async {
    try {
      final vehicleData = {
        'make': vehicle.make,
        'model': vehicle.model,
        'year': vehicle.year,
        'color': vehicle.color,
        'licensePlate': vehicle.licensePlate,
        'nickname': vehicle.nickname,
      };

      final vehicleDto =
          await _apiService.updateVehicle(vehicle.id, vehicleData);
      return _mapVehicleDtoToVehicle(vehicleDto);
    } catch (e) {
      throw Exception('Failed to update vehicle: $e');
    }
  }

  @override
  Future<void> deleteVehicle(String vehicleId) async {
    try {
      await _apiService.deleteVehicle(vehicleId);
    } catch (e) {
      throw Exception('Failed to delete vehicle: $e');
    }
  }

  Vehicle _mapVehicleDtoToVehicle(VehicleDto dto) {
    return Vehicle(
      id: dto.id,
      userId: dto.userId,
      make: dto.make,
      model: dto.model,
      year: dto.year,
      color: dto.color,
      licensePlate: dto.licensePlate,
      nickname: dto.nickname ?? '', // Handle nullable nickname
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }
}
