import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';

class MapView extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final double initialZoom;
  final bool showMyLocation;
  final Set<Marker>? markers;
  final Set<Polyline>? polylines;
  final void Function(LatLng)? onTap;
  final void Function(GoogleMapController)? onMapCreated;

  const MapView({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialZoom = 14.0,
    this.showMyLocation = true,
    this.markers,
    this.polylines,
    this.onTap,
    this.onMapCreated,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? _controller;
  LatLng? _initialPosition;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _initialPosition =
          LatLng(widget.initialLatitude!, widget.initialLongitude!);
      setState(() {});
      return;
    }

    final position = await LocationService.getCurrentLocation();
    if (position != null) {
      _initialPosition = LatLng(position.latitude, position.longitude);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initialPosition == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _initialPosition!,
        zoom: widget.initialZoom,
      ),
      myLocationEnabled: widget.showMyLocation,
      myLocationButtonEnabled: widget.showMyLocation,
      zoomControlsEnabled: true,
      markers: widget.markers ?? {},
      polylines: widget.polylines ?? {},
      onTap: widget.onTap,
      onMapCreated: (GoogleMapController controller) {
        _controller = controller;
        if (widget.onMapCreated != null) {
          widget.onMapCreated!(controller);
        }
      },
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
