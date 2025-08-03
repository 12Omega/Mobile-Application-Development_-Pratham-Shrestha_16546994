import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parkease/core/viewmodels/home_viewmodel.dart';
import 'package:parkease/ui/router.dart';
import 'package:parkease/ui/shared/app_theme.dart';
import 'package:parkease/ui/widgets/active_booking_card.dart';
import 'package:parkease/ui/widgets/custom_app_bar.dart';
import 'package:parkease/ui/widgets/custom_bottom_navigation.dart';
import 'package:parkease/ui/widgets/parking_lot_card.dart';
import 'package:parkease/ui/widgets/search_bar.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    await Provider.of<HomeViewModel>(context, listen: false).refreshData();
  }

  void _onSearch(String query) {
    if (query.isNotEmpty) {
      Provider.of<HomeViewModel>(context, listen: false)
          .searchParkingLots(query);
    }
  }

  void _onNavigationItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // Home
        break;
      case 1: // Map
        context.go(AppRoutes.map);
        break;
      case 2: // Bookings
        context.go(AppRoutes.bookingHistory);
        break;
      case 3: // Profile
        context.go(AppRoutes.profile);
        break;
    }
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildNotificationsSheet(),
    );
  }

  Widget _buildNotificationsSheet() {
    // Sample notifications data
    final notifications = [
      {
        'title': 'Booking Reminder',
        'message': 'Your parking session at Downtown Mall starts in 30 minutes',
        'time': '2 min ago',
        'icon': Icons.access_time,
        'color': Colors.blue,
      },
      {
        'title': 'Payment Successful',
        'message':
            'Payment of \$5.50 for Central Plaza parking has been processed',
        'time': '1 hour ago',
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
      {
        'title': 'New Parking Spot Available',
        'message': 'A spot just opened up near your favorite location',
        'time': '3 hours ago',
        'icon': Icons.local_parking,
        'color': Colors.orange,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Mark all as read
                  Navigator.pop(context);
                },
                child: const Text('Mark all as read'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...notifications.map((notification) => _buildNotificationItem(
                notification['title'] as String,
                notification['message'] as String,
                notification['time'] as String,
                notification['icon'] as IconData,
                notification['color'] as Color,
              )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to full notifications screen
              },
              child: const Text('View All Notifications'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
      String title, String message, String time, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'ParkEase',
            showBackButton: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: _showNotifications,
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refreshData,
            child: viewModel.isLoading && viewModel.nearbyParkingLots.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(viewModel),
          ),
          bottomNavigationBar: CustomBottomNavigation(
            currentIndex: _selectedIndex,
            onTap: _onNavigationItemTapped,
          ),
        );
      },
    );
  }

  Widget _buildContent(HomeViewModel viewModel) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Welcome message
        if (viewModel.user != null)
          Text(
            'Hello, ${viewModel.user!.name.split(' ')[0]}!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

        const SizedBox(height: 16),

        // Search bar
        CustomSearchBar(
          controller: _searchController,
          hintText: 'Search for parking spots',
          onSearch: _onSearch,
        ),

        const SizedBox(height: 24),

        // Active bookings section
        if (viewModel.activeBookings.isNotEmpty) ...[
          _buildSectionHeader('Active Bookings', onSeeAllPressed: () {
            context.go(AppRoutes.bookingHistory);
          }),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: viewModel.activeBookings.length,
              itemBuilder: (context, index) {
                final booking = viewModel.activeBookings[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: ActiveBookingCard(
                    booking: booking,
                    onTap: () {
                      context.go(
                          '${AppRoutes.bookingDetails.replaceAll(':id', '')}${booking.id}');
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Nearby parking section
        _buildSectionHeader('Nearby Parking', onSeeAllPressed: () {
          context.go(AppRoutes.map);
        }),

        const SizedBox(height: 12),

        if (viewModel.nearbyParkingLots.isEmpty && !viewModel.isLoading)
          _buildEmptyState('No parking lots found nearby', Icons.location_off),

        ...viewModel.nearbyParkingLots.map((parkingLot) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ParkingLotCard(
              parkingLot: parkingLot,
              onTap: () {
                context.go(
                    '${AppRoutes.parkingDetails.replaceAll(':id', '')}${parkingLot.id}');
              },
            ),
          );
        }).toList(),

        // Filter options
        if (viewModel.nearbyParkingLots.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFilterButton(
                'Distance',
                Icons.near_me,
                () => viewModel.sortParkingLotsByDistance(),
              ),
              _buildFilterButton(
                'Price',
                Icons.attach_money,
                () => viewModel.sortParkingLotsByPrice(),
              ),
              _buildFilterButton(
                'Availability',
                Icons.check_circle_outline,
                () => viewModel.sortParkingLotsByAvailability(),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAllPressed}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (onSeeAllPressed != null)
          TextButton(
            onPressed: onSeeAllPressed,
            child: Text(
              'See All',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterButton(
      String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
