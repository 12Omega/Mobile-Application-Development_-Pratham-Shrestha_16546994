import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parkease/core/models/booking_model.dart';
import 'package:parkease/ui/shared/app_theme.dart';

class ActiveBookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;

  const ActiveBookingCard({
    Key? key,
    required this.booking,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Parking lot name
                Text(
                  booking.parkingLotName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Spot number
                Row(
                  children: [
                    const Icon(
                      Icons.local_parking,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Spot ${booking.spotNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Time remaining
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTimeRange(booking.bookingDetails.startTime,
                          booking.bookingDetails.endTime),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Action button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Status indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        booking.status.capitalize(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    // View details button
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            booking.isActive ? 'Check Out' : 'View Details',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            booking.isActive
                                ? Icons.logout
                                : Icons.arrow_forward,
                            color: AppTheme.primaryColor,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimeRange(DateTime start, DateTime end) {
    final formatter = DateFormat('h:mm a');
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
