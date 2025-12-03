
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
class RealTimeLocationTracking extends StatefulWidget {
  const RealTimeLocationTracking({super.key});

  @override
  State<RealTimeLocationTracking> createState() => _RealTimeLocationTrackingState();
}

class _RealTimeLocationTrackingState extends State<RealTimeLocationTracking> {

  GoogleMapController? _mapController;
  final List<LatLng> _polylinePoints = [];
  LatLng? _currentLatLng;
  Timer? _currentLocationTimer;


  @override
  void initState() {
    super.initState();
    _getPermission();
  }



  void _locationTracking() async {
    await _currentLocation();

    _currentLocationTimer = Timer.periodic(
      const Duration(seconds: 10),
          (timer) {
        _currentLocation();
      },
    );
  }



  Future<void> _currentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
    );

    LatLng newLatLng = LatLng(position.latitude, position.longitude);
    _polylinePoints.add(newLatLng);
    setState(() {
      _currentLatLng = newLatLng;
    });

    if (_mapController != null) {
      _mapController!.animateCamera(
          CameraUpdate.newLatLng(newLatLng)
      );
    }
  }



  Future<void> _getPermission() async {
    await Geolocator.requestPermission();
    _locationTracking();
  }



  @override
  void dispose() {
    _currentLocationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Real Time Location Tracking'),
        centerTitle: true,
      ),
      body: Stack(
          children: [
            _currentLatLng == null
                ? Center(child: CircularProgressIndicator())
                : GoogleMap(
                mapType: MapType.normal,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                trafficEnabled: true,
                zoomControlsEnabled: true,
                initialCameraPosition: CameraPosition(
                    zoom: 16,
                    target: _currentLatLng!,
                ),
                onTap: (LatLng latLng) {
                  print('Tapped on : $latLng');
                },
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                markers: {
                  Marker(
                      markerId: MarkerId('Current Location'),
                      position: _currentLatLng!,
                      infoWindow: InfoWindow(
                        title: 'My Current Location',
                        snippet: "${_currentLatLng!.latitude}, ${_currentLatLng!
                            .longitude}",
                        onTap: () {},
                      )
                  ),
                },

                polylines: {
                  Polyline(
                    polylineId: PolylineId('tracking path'),
                    points: _polylinePoints,
                    width: 4,
                    color: Colors.red,
                  )
                },
            ),



            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: Text(
                  _currentLatLng == null
                      ? "Location..."
                      : "My Current Location\n${_currentLatLng!.latitude}, ${_currentLatLng!.longitude}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ]
      ),
    );
  }


}
