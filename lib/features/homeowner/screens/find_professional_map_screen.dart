import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/widgets/map_view.dart';
import '../../../models/location_model.dart';
import '../../../models/service_model.dart';
import '../../../providers/database_provider.dart';
import '../../../core/services/location_service.dart';
import 'dart:math';

enum SearchState {
  searching,
  found,
  confirmed,
  failed,
}

class FindProfessionalMapScreen extends StatefulWidget {
  final Service service;
  final int hours;
  final String? additionalNotes;
  final double maxBudgetPerHour;
  final DateTime scheduledDate;
  final TimeOfDay scheduledTime;

  const FindProfessionalMapScreen({
    super.key,
    required this.service,
    required this.hours,
    required this.maxBudgetPerHour,
    required this.scheduledDate,
    required this.scheduledTime,
    this.additionalNotes,
  });

  @override
  State<FindProfessionalMapScreen> createState() =>
      _FindProfessionalMapScreenState();
}

class _FindProfessionalMapScreenState extends State<FindProfessionalMapScreen>
    with SingleTickerProviderStateMixin {
  Set<Marker> _markers = {};
  LocationModel? _currentLocation;
  String? _selectedProfessionalId;
  bool _isLoading = true;
  SearchState _searchState = SearchState.searching;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final _defaultLocation = const LocationModel(
    latitude: 41.0082, // Istanbul's coordinates
    longitude: 28.9784,
  );

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _setupAnimations();
    _startSearching();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    _slideController.forward();
  }

  Future<void> _initializeMap() async {
    setState(() => _isLoading = true);

    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        _currentLocation = LocationModel(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }

      await _loadProfessionals();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load map data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadProfessionals() async {
    final dbProvider = context.read<DatabaseProvider>();
    final professionals = dbProvider.electricians.where((e) =>
        e.isAvailable &&
        e.hourlyRate <= widget.maxBudgetPerHour &&
        e.services.contains(widget.service.id));

    // Create a spiral pattern around Istanbul for better distribution
    double angle = 0;
    double radius = 0.002; // Start close to center (about 200m)
    const double ANGLE_STEP = 60; // 60 degrees per step
    const double RADIUS_STEP = 0.001; // About 100m per step
    const double MAX_RADIUS = 0.02; // Maximum ~2km radius

    final markers = professionals.map((professional) {
      late final LatLng position;

      if (professional.location != null) {
        position = LatLng(
          professional.location!.latitude,
          professional.location!.longitude,
        );
      } else {
        // Calculate position in a spiral pattern around Istanbul
        final baseLocation = _currentLocation ?? _defaultLocation;
        final double rad = angle * (3.14159 / 180); // Convert to radians
        position = LatLng(
          baseLocation.latitude + (radius * cos(rad)),
          baseLocation.longitude + (radius * sin(rad)),
        );

        // Update spiral parameters
        angle += ANGLE_STEP;
        radius += RADIUS_STEP;
        if (radius > MAX_RADIUS) {
          radius = 0.002; // Reset and start a new spiral
        }
      }

      return Marker(
        markerId: MarkerId('professional_${professional.id}'),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _selectedProfessionalId == professional.id
              ? BitmapDescriptor.hueGreen // Highlight selected professional
              : BitmapDescriptor.hueBlue,
        ),
      );
    }).toSet();

    setState(() => _markers = markers);
  }

  Future<void> _startSearching() async {
    // Simulate searching for professionals
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // For demo, randomly select a professional
    final dbProvider = context.read<DatabaseProvider>();
    final availableProfessionals = dbProvider.electricians
        .where((e) =>
            e.isAvailable &&
            e.hourlyRate <= widget.maxBudgetPerHour &&
            e.services.contains(widget.service.id))
        .toList();

    if (availableProfessionals.isEmpty) {
      setState(() => _searchState = SearchState.failed);
      return;
    }

    final selectedProfessional = availableProfessionals[
        DateTime.now().millisecond % availableProfessionals.length];
    setState(() {
      _selectedProfessionalId = selectedProfessional.id;
      _searchState = SearchState.found;
    });

    // Auto-reject if not confirmed within 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _searchState == SearchState.found) {
        setState(() => _searchState = SearchState.searching);
        _startSearching();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
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
              child: const Center(
                child: CircularProgressIndicator(),
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

          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: Container(
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
          ),

          // Bottom Card
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _buildBottomCardContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCardContent() {
    switch (_searchState) {
      case SearchState.searching:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Finding available professionals...',
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This may take a few moments',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );

      case SearchState.found:
        final professional = context
            .read<DatabaseProvider>()
            .electricians
            .firstWhere((e) => e.id == _selectedProfessionalId);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: professional.profileImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            professional.profileImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.person,
                          color: AppColors.accent,
                          size: 32,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        professional.profile.name,
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            professional.rating.toStringAsFixed(1),
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            ' (${professional.jobsCompleted} jobs)',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _searchState = SearchState.searching;
                        _selectedProfessionalId = null;
                      });
                      _startSearching();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Skip'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _searchState = SearchState.confirmed);
                      // TODO: Implement job confirmation
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/homeowner/dashboard',
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ],
        );

      case SearchState.failed:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'No professionals available',
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your budget or schedule',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Go Back'),
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
