import 'package:flutter/material.dart';
import 'package:parkease/core/models/parking_model.dart';
import 'package:parkease/ui/shared/app_theme.dart';

class ParkingLotCard extends StatelessWidget {
  final ParkingLot parkingLot;
  final VoidCallback onTap;

  const ParkingLotCard({
    Key? key,
    required this.parkingLot,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      parkingLot.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      parkingLot.formattedHourlyRate + '/hr',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Address
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      parkingLot.fullAddress,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Operating hours
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    parkingLot.operatingHoursText,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Availability and amenities
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Availability indicator
                  _buildAvailabilityIndicator(context),

                  // Amenities
                  Row(
                    children: [
                      if (parkingLot.hasCovered)
                        _buildAmenityIcon(Icons.umbrella, 'Covered'),
                      if (parkingLot.hasElectricCharging)
                        _buildAmenityIcon(Icons.electric_car, 'EV Charging'),
                      if (parkingLot.hasSecurity)
                        _buildAmenityIcon(Icons.security, 'Security'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityIndicator(BuildContext context) {
    final availabilityPercentage =
        parkingLot.availableSpots / parkingLot.totalSpots;

    Color color;

    if (availabilityPercentage > 0.5) {
      color = Colors.green;
    } else if (availabilityPercentage > 0.2) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${parkingLot.availableSpots}/${parkingLot.totalSpots} spots',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAmenityIcon(IconData icon, String tooltip) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Tooltip(
        message: tooltip,
        child: Icon(
          icon,
          size: 20,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}
