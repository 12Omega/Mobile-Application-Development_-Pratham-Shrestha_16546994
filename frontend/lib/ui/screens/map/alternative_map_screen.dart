import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
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

class AlternativeMapScreen extends StatefulWidget {
  const AlternativeMapScreen({Key? key}) : super(key: key);

  @override
  State<AlternativeMapScreen> createState() => _AlternativeMapScreenState();
}

class _AlternativeMapScreenState extends State<AlternativeMapScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    // MapViewModel initializes automatically in constructor
  }

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
      screenName: 'AlternativeMapScreen',
      child: Consumer<MapViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: const CustomAppBar(
              title: 'Find Parking',
              showBackButton: false,
            ),
            body: Stack(
              children: [
                // OpenStreetMap
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
                          _moveToUserLocation(viewModel);
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

    // Use the initial camera position from viewModel
    final center = latlong.LatLng(
      viewModel.initialCameraPosition!.target.latitude,
      viewModel.initialCameraPosition!.target.longitude,
    );

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 15.0,
        minZoom: 10.0,
        maxZoom: 18.0,
        onTap: (tapPosition, point) {
          viewModel.clearSelectedParkingLot();
        },
      ),
      children: [
        // OpenStreetMap tile layer
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.parkease',
          maxZoom: 18,
        ),
        
        // Parking lot markers
        MarkerLayer(
          markers: _buildParkingMarkers(viewModel),
        ),
        
        // User location marker (if available from markers)
        MarkerLayer(
          markers: _buildUserLocationMarkers(viewModel),
        ),
      ],
    );
  }

  List<Marker> _buildUserLocationMarkers(MapViewModel viewModel) {
    // Extract user location marker from viewModel markers if available
    final userMarker = viewModel.markers
        .where((marker) => marker.markerId.value == 'user_location')
        .firstOrNull;
    
    if (userMarker != null) {
      return [
        Marker(
          point: latlong.LatLng(userMarker.position.latitude, userMarker.position.longitude),
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ];
    }
    return [];
  }

  List<Marker> _buildParkingMarkers(MapViewModel viewModel) {
    return viewModel.parkingLots.map((parkingLot) {
      final isSelected = viewModel.selectedParkingLot?.id == parkingLot.id;
      final availabilityColor = _getAvailabilityColor(parkingLot);

      return Marker(
        point: latlong.LatLng(parkingLot.latLng.latitude, parkingLot.latLng.longitude),
        width: isSelected ? 60 : 50,
        height: isSelected ? 60 : 50,
        child: GestureDetector(
          onTap: () {
            viewModel.selectParkingLot(parkingLot);
          },
          child: Container(
            decoration: BoxDecoration(
              color: availabilityColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : Colors.white,
                width: isSelected ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_parking,
                    color: Colors.white,
                    size: isSelected ? 20 : 16,
                  ),
                  if (isSelected)
                    Text(
                      parkingLot.availableSpots.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
    final availabilityPercentage = parkingLot.availableSpots / parkingLot.totalSpots;

    if (availabilityPercentage > 0.5) {
      return Colors.green;
    } else if (availabilityPercentage > 0.2) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  void _moveToUserLocation(MapViewModel viewModel) {
    viewModel.moveToUserLocation();
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
              _buildFilterOption('EV Charging', Icons.electric_car),
              _buildFilterOption('Covered Parking', Icons.umbrella),
              _buildFilterOption('Security', Icons.security),
              _buildFilterOption('24/7 Access', Icons.access_time),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Filter functionality would be implemented in MapViewModel
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Filters applied')),
                    );
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

// Directions Bottom Sheet
class DirectionsBottomSheet extends StatelessWidget {
  final ParkingLot parkingLot;

  const DirectionsBottomSheet({Key? key, required this.parkingLot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
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
          
          // Scrollable navigation options
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Google Maps
                  _buildNavigationOption(
                    context,
                    'Google Maps',
                    Icons.map,
                    Colors.green,
                    () => _openGoogleMaps(context),
                  ),
                  
                  // Apple Maps (iOS) / Default Maps
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
                  
                  // In-app directions
                  _buildNavigationOption(
                    context,
                    'In-App Directions',
                    Icons.directions,
                    AppTheme.primaryColor,
                    () => _showInAppDirections(context),
                  ),
                ],
              ),
            ),
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

  void _showInAppDirections(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => InAppDirectionsSheet(
          parkingLot: parkingLot,
          scrollController: scrollController,
        ),
      ),
    );
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

// In-App Directions Sheet
class InAppDirectionsSheet extends StatefulWidget {
  final ParkingLot parkingLot;
  final ScrollController scrollController;

  const InAppDirectionsSheet({
    Key? key,
    required this.parkingLot,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<InAppDirectionsSheet> createState() => _InAppDirectionsSheetState();
}

class _InAppDirectionsSheetState extends State<InAppDirectionsSheet> {
  final List<DirectionStep> _directions = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _estimatedTime = '';
  String _totalDistance = '';

  @override
  void initState() {
    super.initState();
    _loadDirections();
  }

  Future<void> _loadDirections() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate loading directions
    await Future.delayed(const Duration(seconds: 1));

    // Mock directions data
    final mockDirections = [
      DirectionStep(
        instruction: 'Head north on Main Street',
        distance: '0.2 mi',
        duration: '1 min',
        icon: Icons.straight,
      ),
      DirectionStep(
        instruction: 'Turn right onto Broadway',
        distance: '0.5 mi',
        duration: '2 min',
        icon: Icons.turn_right,
      ),
      DirectionStep(
        instruction: 'Continue straight for 3 blocks',
        distance: '0.3 mi',
        duration: '1 min',
        icon: Icons.straight,
      ),
      DirectionStep(
        instruction: 'Turn left onto Park Avenue',
        distance: '0.1 mi',
        duration: '30 sec',
        icon: Icons.turn_left,
      ),
      DirectionStep(
        instruction: 'Destination will be on your right',
        distance: '0.1 mi',
        duration: '30 sec',
        icon: Icons.location_on,
      ),
    ];

    setState(() {
      _directions.clear();
      _directions.addAll(mockDirections);
      _estimatedTime = '5 min';
      _totalDistance = '1.2 mi';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Directions',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Route summary
          if (!_isLoading) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.directions_car, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Route to ${widget.parkingLot.name}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$_totalDistance • $_estimatedTime',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Start navigation
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Navigation started!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Start'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Directions list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(_errorMessage!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadDirections,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: widget.scrollController,
                        itemCount: _directions.length,
                        itemBuilder: (context, index) {
                          final step = _directions[index];
                          return _buildDirectionStep(step, index);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionStep(DirectionStep step, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number and icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Icon(
                step.icon,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Step details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.instruction,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${step.distance} • ${step.duration}',
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
    );
  }
}

// Direction Step Model
class DirectionStep {
  final String instruction;
  final String distance;
  final String duration;
  final IconData icon;

  DirectionStep({
    required this.instruction,
    required this.distance,
    required this.duration,
    required this.icon,
  });
}