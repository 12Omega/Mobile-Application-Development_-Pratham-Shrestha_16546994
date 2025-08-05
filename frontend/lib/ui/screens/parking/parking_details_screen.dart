import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parkease/core/models/parking_model.dart';
import 'package:parkease/core/viewmodels/parking_viewmodel.dart';
import 'package:parkease/ui/router.dart';
import 'package:parkease/ui/shared/app_theme.dart';
import 'package:parkease/ui/widgets/custom_app_bar.dart';
import 'package:parkease/ui/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class ParkingDetailsScreen extends StatefulWidget {
  final String parkingId;

  const ParkingDetailsScreen({
    Key? key,
    required this.parkingId,
  }) : super(key: key);

  @override
  State<ParkingDetailsScreen> createState() => _ParkingDetailsScreenState();
}

class _ParkingDetailsScreenState extends State<ParkingDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedSpot;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadParkingLotDetails();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadParkingLotDetails() async {
    final viewModel = Provider.of<ParkingViewModel>(context, listen: false);
    await viewModel.getParkingLotDetails(widget.parkingId);
    await viewModel.getParkingLotAvailability(widget.parkingId);
  }

  void _selectSpot(String spotNumber) {
    setState(() {
      _selectedSpot = spotNumber;
    });
  }

  Future<void> _reserveSpot() async {
    if (_selectedSpot == null) return;

    final viewModel = Provider.of<ParkingViewModel>(context, listen: false);
    final success =
        await viewModel.reserveParkingSpot(widget.parkingId, _selectedSpot!);

    if (success && mounted) {
      context.go(
        AppRoutes.createBooking,
        extra: {
          'parkingId': widget.parkingId,
          'spotNumber': _selectedSpot,
        },
      );
    }
  }

  Future<void> _toggleFavorite(ParkingLot? parkingLot) async {
    if (parkingLot == null) return;

    final viewModel = Provider.of<ParkingViewModel>(context, listen: false);
    final success = await viewModel.toggleFavorite(parkingLot.id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            parkingLot.isFavorite
                ? 'Removed from favorites'
                : 'Added to favorites',
          ),
          backgroundColor: parkingLot.isFavorite ? Colors.grey : Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ParkingViewModel>(
      builder: (context, viewModel, child) {
        final parkingLot = viewModel.selectedParkingLot;

        return Scaffold(
          appBar: CustomAppBar(
            title: parkingLot?.name ?? 'Parking Details',
            actions: [
              if (parkingLot != null)
                IconButton(
                  icon: Icon(
                    parkingLot.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: parkingLot.isFavorite ? Colors.red : null,
                  ),
                  onPressed: () => _toggleFavorite(parkingLot),
                ),
            ],
          ),
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : parkingLot == null
                  ? _buildErrorState()
                  : _buildContent(context, viewModel, parkingLot),
          bottomNavigationBar: parkingLot != null
              ? _buildBottomBar(context, viewModel, parkingLot)
              : null,
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load parking details',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Retry',
            onPressed: _loadParkingLotDetails,
            width: 120,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, ParkingViewModel viewModel, ParkingLot parkingLot) {
    return Column(
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
              Tab(text: 'Details'),
              Tab(text: 'Spots'),
              Tab(text: 'Reviews'),
            ],
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDetailsTab(context, parkingLot),
              _buildSpotsTab(context, viewModel, parkingLot),
              _buildReviewsTab(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsTab(BuildContext context, ParkingLot parkingLot) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map preview
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: parkingLot.latLng,
                  zoom: 16,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId(parkingLot.id),
                    position: parkingLot.latLng,
                    infoWindow: InfoWindow(title: parkingLot.name),
                  ),
                },
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                myLocationButtonEnabled: false,
                liteModeEnabled: true,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Address
          _buildInfoSection(
            'Address',
            Icons.location_on_outlined,
            parkingLot.fullAddress,
          ),

          const SizedBox(height: 16),

          // Operating hours
          _buildInfoSection(
            'Operating Hours',
            Icons.access_time,
            parkingLot.operatingHoursText,
          ),

          const SizedBox(height: 16),

          // Pricing
          _buildInfoSection(
            'Pricing',
            Icons.attach_money,
            '${parkingLot.formattedHourlyRate}/hour • \${parkingLot.pricing.dailyRate.toStringAsFixed(2)}/day',
          ),

          const SizedBox(height: 16),

          // Availability
          _buildInfoSection(
            'Availability',
            Icons.local_parking,
            '${parkingLot.availableSpots} out of ${parkingLot.totalSpots} spots available',
            trailing: _buildAvailabilityIndicator(parkingLot),
          ),

          const SizedBox(height: 24),

          // Amenities
          const Text(
            'Amenities',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (parkingLot.hasCovered)
                _buildAmenityChip('Covered', Icons.umbrella),
              if (parkingLot.hasElectricCharging)
                _buildAmenityChip('EV Charging', Icons.electric_car),
              if (parkingLot.hasSecurity)
                _buildAmenityChip('Security', Icons.security),
              if (parkingLot.is24Hours)
                _buildAmenityChip('24/7 Access', Icons.access_time),
              if (parkingLot.amenities.contains('valet'))
                _buildAmenityChip('Valet', Icons.directions_car),
              if (parkingLot.amenities.contains('car_wash'))
                _buildAmenityChip('Car Wash', Icons.local_car_wash),
            ],
          ),

          const SizedBox(height: 24),

          // Contact info
          if (parkingLot.contactInfo.phone != null ||
              parkingLot.contactInfo.email != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (parkingLot.contactInfo.phone != null)
                  _buildInfoSection(
                    'Phone',
                    Icons.phone,
                    parkingLot.contactInfo.phone!,
                  ),
                if (parkingLot.contactInfo.email != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _buildInfoSection(
                      'Email',
                      Icons.email,
                      parkingLot.contactInfo.email!,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSpotsTab(
      BuildContext context, ParkingViewModel viewModel, ParkingLot parkingLot) {
    final availabilityData = viewModel.availabilityData;

    if (availabilityData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final spotsByType =
        availabilityData['spotsByType'] as Map<String, dynamic>? ?? {};

    return Column(
      children: [
        // Spot type filters
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSpotTypeFilter('All', true),
              _buildSpotTypeFilter('Regular', false),
              _buildSpotTypeFilter('Disabled', false),
              _buildSpotTypeFilter('Electric', false),
            ],
          ),
        ),

        // Spot type summary
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: spotsByType.entries.map((entry) {
              final type = entry.key;
              final data = entry.value;
              return _buildSpotTypeSummary(
                type,
                data['available'],
                data['total'],
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Spots grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: parkingLot.spots.length,
            itemBuilder: (context, index) {
              final spot = parkingLot.spots[index];
              return _buildSpotItem(spot);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsTab(BuildContext context) {
    // This would be implemented with actual review data
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.star_border,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No reviews yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
      BuildContext context, ParkingViewModel viewModel, ParkingLot parkingLot) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Price info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    parkingLot.formattedHourlyRate,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Text(
                    'per hour',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Reserve button
            Expanded(
              flex: 2,
              child: CustomButton(
                text: _selectedSpot != null
                    ? 'Reserve Spot ${_selectedSpot}'
                    : 'Select a Spot',
                onPressed: _selectedSpot != null
                    ? _reserveSpot
                    : () {
                        _tabController.animateTo(1); // Switch to spots tab
                      },
                isLoading: viewModel.isLoading,
                icon: Icons.local_parking,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, IconData icon, String content,
      {Widget? trailing}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[700],
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
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildAvailabilityIndicator(ParkingLot parkingLot) {
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

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildAmenityChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[700],
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotTypeFilter(String label, bool isSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        // Filter spots by type
      },
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildSpotTypeSummary(String type, int available, int total) {
    final percentage = (available / total * 100).toInt();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                type.capitalize(),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$available/$total available',
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: available / total,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
                _getAvailabilityColor(percentage)),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotItem(ParkingSpot spot) {
    final isAvailable = spot.isAvailableForBooking;
    final isSelected = _selectedSpot == spot.spotNumber;

    Color backgroundColor;
    Color textColor;

    if (isSelected) {
      backgroundColor = AppTheme.primaryColor;
      textColor = Colors.white;
    } else if (isAvailable) {
      backgroundColor = Colors.white;
      textColor = Colors.black;
    } else {
      backgroundColor = Colors.grey[300]!;
      textColor = Colors.grey[700]!;
    }

    return GestureDetector(
      onTap: isAvailable ? () => _selectSpot(spot.spotNumber) : null,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            spot.spotNumber,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Color _getAvailabilityColor(int percentage) {
    if (percentage > 50) {
      return Colors.green;
    } else if (percentage > 20) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
