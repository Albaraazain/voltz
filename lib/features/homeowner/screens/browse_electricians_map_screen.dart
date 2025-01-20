import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/widgets/map_view.dart';
import '../../../models/location_model.dart';
import '../../../providers/database_provider.dart';
import '../../../core/services/location_service.dart';
import '../widgets/electrician_map_card.dart';

class BrowseElectriciansMapScreen extends StatefulWidget {
  const BrowseElectriciansMapScreen({super.key});

  @override
  State<BrowseElectriciansMapScreen> createState() =>
      _BrowseElectriciansMapScreenState();
}

class _BrowseElectriciansMapScreenState
    extends State<BrowseElectriciansMapScreen> {
  Set<Marker> _markers = {};
  LocationModel? _currentLocation;
  String? _selectedElectricianId;
  bool _isLoading = true;
  final _defaultLocation = const LocationModel(
    latitude: 25.2048, // Default to Dubai's coordinates
    longitude: 55.2708,
  );

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    setState(() => _isLoading = true);

    try {
      // Get current location
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        _currentLocation = LocationModel(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }

      // Load electricians
      await _loadElectricians();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load map data: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadElectricians() async {
    final dbProvider = context.read<DatabaseProvider>();
    final electricians = dbProvider.electricians;

    // Create markers with spread out positions for electricians without location
    double offsetLat = 0;
    double offsetLng = 0;
    const double OFFSET_STEP = 0.01; // Roughly 1km

    final markers = electricians.map((electrician) {
      late final LatLng position;

      if (electrician.location != null) {
        position = LatLng(
          electrician.location!.latitude,
          electrician.location!.longitude,
        );
      } else {
        // If no location, spread markers around current location or default location
        final baseLocation = _currentLocation ?? _defaultLocation;
        position = LatLng(
          baseLocation.latitude + offsetLat,
          baseLocation.longitude + offsetLng,
        );

        // Update offsets for next marker without location
        offsetLat += OFFSET_STEP;
        if (offsetLat > OFFSET_STEP * 3) {
          offsetLat = 0;
          offsetLng += OFFSET_STEP;
        }
      }

      return Marker(
        markerId: MarkerId('electrician_${electrician.id}'),
        position: position,
        onTap: () => _onMarkerTapped(electrician.id),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
    }).toSet();

    setState(() => _markers = markers);
  }

  void _onMarkerTapped(String electricianId) {
    setState(() => _selectedElectricianId = electricianId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          if (_isLoading)
            Container(
              color: AppColors.background,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.accent),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading map...',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            MapView(
              initialLatitude:
                  _currentLocation?.latitude ?? _defaultLocation.latitude,
              initialLongitude:
                  _currentLocation?.longitude ?? _defaultLocation.longitude,
              markers: _markers,
              showMyLocation: true,
              initialZoom: 13,
            ),

          // Top Bar Container
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Back Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                Icons.arrow_back,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Search Bar
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search area...',
                              hintStyle: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: AppColors.accent,
                                size: 20,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Filter Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // TODO: Implement filter functionality
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                Icons.tune,
                                color: AppColors.accent,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Selected Electrician Card
          if (_selectedElectricianId != null)
            Positioned(
              bottom: 32,
              left: 16,
              right: 16,
              child: ElectricianMapCard(
                electricianId: _selectedElectricianId!,
                onClose: () => setState(() => _selectedElectricianId = null),
              ),
            ),
        ],
      ),
    );
  }
}
