import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:parkease/core/models/booking_model.dart';
import 'package:parkease/core/viewmodels/booking_viewmodel.dart';
import 'package:parkease/ui/router.dart';
import 'package:parkease/ui/shared/app_theme.dart';
import 'package:parkease/ui/widgets/custom_app_bar.dart';
import 'package:parkease/ui/widgets/custom_bottom_navigation.dart';
import 'package:provider/provider.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({Key? key}) : super(key: key);

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    await Provider.of<BookingViewModel>(context, listen: false)
        .getUserBookings(refresh: true);
  }

  void _onNavigationItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // Home
        context.go(AppRoutes.home);
        break;
      case 1: // Map
        context.go(AppRoutes.map);
        break;
      case 2: // Bookings
        break;
      case 3: // Profile
        context.go(AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'My Bookings',
            showBackButton: false,
          ),
          body: Column(
            children: [
              // Tab bar
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppTheme.primaryColor,
                  tabs: const [
                    Tab(text: 'Active'),
                    Tab(text: 'Upcoming'),
                    Tab(text: 'Past'),
                  ],
                ),
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookingsList(
                        viewModel.getActiveBookings(), viewModel, 'active'),
                    _buildBookingsList(
                        viewModel.getUpcomingBookings(), viewModel, 'upcoming'),
                    _buildBookingsList(
                        viewModel.getCompletedBookings(), viewModel, 'past'),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: CustomBottomNavigation(
            currentIndex: _selectedIndex,
            onTap: _onNavigationItemTapped,
          ),
        );
      },
    );
  }

  Widget _buildBookingsList(
      List<Booking> bookings, BookingViewModel viewModel, String type) {
    if (viewModel.isLoading && bookings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bookings.isEmpty) {
      return _buildEmptyState(type);
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _buildBookingCard(booking);
        },
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          context.go(
              '${AppRoutes.bookingDetails.replaceAll(':id', '')}${booking.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusBadge(booking.status),
                  Text(
                    DateFormat('MMM d, yyyy')
                        .format(booking.bookingDetails.startTime),
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Parking lot name
              Text(
                booking.parkingLotName,
                style: const TextStyle(
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
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Spot ${booking.spotNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Time
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTimeRange(booking.bookingDetails.startTime,
                        booking.bookingDetails.endTime),
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Vehicle
              Row(
                children: [
                  const Icon(
                    Icons.directions_car,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    booking.vehicleInfo.licensePlate,
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Price and action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    booking.formattedTotalAmount,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  _buildActionButton(booking),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;

    switch (status) {
      case 'active':
        color = Colors.green;
        break;
      case 'reserved':
        color = AppTheme.primaryColor;
        break;
      case 'completed':
        color = Colors.blue;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.capitalize(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildActionButton(Booking booking) {
    if (booking.isActive) {
      return ElevatedButton.icon(
        onPressed: () {
          context.go(
              '${AppRoutes.bookingDetails.replaceAll(':id', '')}${booking.id}');
        },
        icon: const Icon(Icons.logout, size: 16),
        label: const Text('Check Out'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (booking.isReserved) {
      return ElevatedButton.icon(
        onPressed: () {
          context.go(
              '${AppRoutes.bookingDetails.replaceAll(':id', '')}${booking.id}');
        },
        icon: const Icon(Icons.login, size: 16),
        label: const Text('Check In'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return OutlinedButton(
        onPressed: () {
          context.go(
              '${AppRoutes.bookingDetails.replaceAll(':id', '')}${booking.id}');
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.grey[700],
          side: BorderSide(color: Colors.grey[300]!),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: const Text('Details'),
      );
    }
  }

  Widget _buildEmptyState(String type) {
    String message;
    IconData icon;

    switch (type) {
      case 'active':
        message = 'No active bookings';
        icon = Icons.directions_car_outlined;
        break;
      case 'upcoming':
        message = 'No upcoming bookings';
        icon = Icons.event_available_outlined;
        break;
      case 'past':
        message = 'No past bookings';
        icon = Icons.history;
        break;
      default:
        message = 'No bookings found';
        icon = Icons.local_parking_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              context.go(AppRoutes.map);
            },
            icon: const Icon(Icons.search),
            label: const Text('Find Parking'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
            ),
          ),
        ],
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
