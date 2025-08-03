import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parkease/core/models/parking_model.dart';
import 'package:parkease/core/viewmodels/map_viewmodel.dart';
import 'package:parkease/ui/router.dart';
import 'package:parkease/ui/shared/app_theme.dart';
import 'package:parkease/ui/widgets/custom_app_bar.dart';
import 'package:parkease/ui/widgets/custom_bottom_navigation.dart';
import 'package:parkease/ui/widgets/search_bar.dart';
import 'package:parkease/ui/widgets/performance_monitor.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 1;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.isNotEmpty) {
      Provider.of<MapViewModel>(context, listen: false).searchLocation(query);
    }
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
        break;
      case 2: // Bookings
        context.go(AppRoutes.bookingHistory);
        break;
      case 3: // Profile
        context.go(AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PerformanceMonitor(
      screenName: 'MapScreen',
      child: Consumer<MapViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
          appBar: CustomAppBar(
            title: 'Find Parking',
            showBackButton: false,
          ),
          body: Stack(
            children: [
              // Google Map
              _buildMap(viewModel),

              // Search bar
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: CustomSearchBar(
                  controller: _searchController,
                  hintText: 'Search for location',
                  onSearch: _onSearch,
                  onFilterPressed: () {
                    _showFilterBottomSheet(context);
                  },
                ),
              ),

              // Action buttons
              Positioned(
                bottom: 100,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Refresh button
                    FloatingActionButton(
                      heroTag: "refresh",
                      onPressed: () {
                        viewModel.refreshMapData();
                      },
                      backgroundColor: Colors.white,
                      child: viewModel.isLoading 
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primaryColor,
                              ),
                            )
                          : Icon(
                              Icons.refresh,
                              color: AppTheme.primaryColor,
                            ),
                    ),
                    const SizedBox(height: 8),
                    // My location button
                    FloatingActionButton(
                      heroTag: "location",
                      onPressed: () {
                        viewModel.moveToUserLocation();
                      },
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.my_location,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Selected parking lot info
              if (viewModel.selectedParkingLot != null)
                _buildParkingLotInfo(context, viewModel.selectedParkingLot!),
            ],
          ),
          bottomNavigationBar: CustomBottomNavigation(
            currentIndex: _selectedIndex,
            onTap: _onNavigationItemTapped,
          ),
        );
        },
      ),
    );
  }

  Widget _buildMap(MapViewModel viewModel) {
    if (viewModel.initialCameraPosition == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading map...'),
          ],
        ),
      );
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              viewModel.errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                viewModel.refreshMapData();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Check if Google Maps API key is properly configured
    if (viewModel.initialCameraPosition!.target.latitude == 40.7128 && 
        viewModel.initialCameraPosition!.target.longitude == -74.0060) {
      // Show list view when using development mode (no real Google Maps API key)
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Map view unavailable - showing parking lots in list format',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildParkingLotsList(viewModel),
          ),
        ],
      );
    }

    try {
      return GoogleMap(
        initialCameraPosition: viewModel.initialCameraPosition!,
        markers: viewModel.markers,
        myLocationEnabled: false, // Disabled to reduce ImageReader warnings
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        compassEnabled: false, // Disabled to reduce resource usage
        liteModeEnabled: true, // Enable lite mode for better performance
        buildingsEnabled: false, // Disable 3D buildings to reduce memory usage
        trafficEnabled: false, // Disable traffic to reduce network calls
        onMapCreated: (controller) {
          viewModel.setMapController(controller);
        },
        onTap: (_) {
          viewModel.clearSelectedParkingLot();
        },
      );
    } catch (e) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Map failed to load - showing parking lots in list format',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildParkingLotsList(viewModel),
          ),
        ],
      );
    }
  }

  Widget _buildParkingLotsList(MapViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading parking lots...'),
          ],
        ),
      );
    }

    if (viewModel.parkingLots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_parking_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No parking lots found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching in a different area',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.parkingLots.length,
      itemBuilder: (context, index) {
        final parkingLot = viewModel.parkingLots[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(
                Icons.local_parking,
                color: Colors.white,
              ),
            ),
            title: Text(
              parkingLot.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(parkingLot.fullAddress),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getAvailabilityColor(parkingLot),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${parkingLot.availableSpots}/${parkingLot.totalSpots} spots',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Text(
              parkingLot.formattedHourlyRate + '/hr',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              context.go(
                  '${AppRoutes.parkingDetails.replaceAll(':id', '')}${parkingLot.id}');
            },
          ),
        );
      },
    );
  }

  Widget _buildParkingLotInfo(BuildContext context, ParkingLot parkingLot) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Name and price
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

            const SizedBox(height: 8),

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

            // Availability
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getAvailabilityColor(parkingLot),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${parkingLot.availableSpots}/${parkingLot.totalSpots} spots available',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _getDirections(parkingLot);
                    },
                    icon: const Icon(Icons.directions),
                    label: const Text('Directions'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: BorderSide(color: AppTheme.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.go(
                          '${AppRoutes.parkingDetails.replaceAll(':id', '')}${parkingLot.id}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getAvailabilityColor(ParkingLot parkingLot) {
    final availabilityPercentage =
        parkingLot.availableSpots / parkingLot.totalSpots;

    if (availabilityPercentage > 0.5) {
      return Colors.green;
    } else if (availabilityPercentage > 0.2) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  void _getDirections(ParkingLot parkingLot) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DirectionsBottomSheet(parkingLot: parkingLot),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filter Parking Lots',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Filter options
              _buildFilterOption('EV Charging', Icons.electric_car),
              _buildFilterOption('Covered Parking', Icons.umbrella),
              _buildFilterOption('Security', Icons.security),
              _buildFilterOption('24/7 Access', Icons.access_time),

              const SizedBox(height: 24),

              // Apply button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Apply filters
                    Provider.of<MapViewModel>(context, listen: false)
                        .filterParkingLots(['ev_charging', 'covered']);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[700],
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
          const Spacer(),
          Switch(
            value: false,
            onChanged: (value) {},
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }
}

// Extension for MapViewModel
extension MapViewModelExtension on MapViewModel {
  void filterParkingLots(List<String> amenities) {
    // Implementation would be added to the MapViewModel class
  }
}

// Directions Bottom Sheet
class DirectionsBottomSheet extends StatelessWidget {
  final ParkingLot parkingLot;

  const DirectionsBottomSheet({Key? key, required this.parkingLot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Get Directions',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Destination info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.local_parking,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parkingLot.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        parkingLot.fullAddress,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Navigation options
          const Text(
            'Choose Navigation App',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Google Maps
          _buildNavigationOption(
            context,
            'Google Maps',
            Icons.map,
            Colors.green,
            () => _openGoogleMaps(context),
          ),
          
          // Apple Maps
          _buildNavigationOption(
            context,
            'Apple Maps',
            Icons.navigation,
            Colors.blue,
            () => _openAppleMaps(context),
          ),
          
          // Waze
          _buildNavigationOption(
            context,
            'Waze',
            Icons.traffic,
            Colors.purple,
            () => _openWaze(context),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNavigationOption(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _openGoogleMaps(BuildContext context) async {
    final lat = parkingLot.latLng.latitude;
    final lng = parkingLot.latLng.longitude;
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=${parkingLot.name}';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        Navigator.pop(context);
      } else {
        _showErrorSnackBar(context, 'Could not open Google Maps');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Error opening Google Maps');
    }
  }

  void _openAppleMaps(BuildContext context) async {
    final lat = parkingLot.latLng.latitude;
    final lng = parkingLot.latLng.longitude;
    final url = 'https://maps.apple.com/?daddr=$lat,$lng&dirflg=d';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        Navigator.pop(context);
      } else {
        _showErrorSnackBar(context, 'Could not open Apple Maps');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Error opening Apple Maps');
    }
  }

  void _openWaze(BuildContext context) async {
    final lat = parkingLot.latLng.latitude;
    final lng = parkingLot.latLng.longitude;
    final url = 'https://waze.com/ul?ll=$lat,$lng&navigate=yes';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        Navigator.pop(context);
      } else {
        _showErrorSnackBar(context, 'Could not open Waze');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Error opening Waze');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
