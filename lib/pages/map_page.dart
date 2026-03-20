import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:pokemap/models/monster_model.dart';
import 'package:pokemap/services/api_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _apiService = ApiService();
  final _mapController = MapController();

  List<Monster> _monsters = const <Monster>[];
  bool _isLoading = true;
  String? _errorMessage;
  LatLng _mapCenter = ApiService.defaultMapCenter;

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final monsters = await _apiService.getMonsters();
      final currentLocation = await _requestCurrentLocation();

      if (!mounted) {
        return;
      }

      final center = currentLocation ??
          (monsters.isNotEmpty
              ? LatLng(monsters.first.spawnLatitude, monsters.first.spawnLongitude)
              : ApiService.defaultMapCenter);

      setState(() {
        _monsters = monsters;
        _mapCenter = center;
      });

      _mapController.move(center, 15);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<LatLng?> _requestCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      return null;
    }
  }

  void _showMonsterInfo(Monster monster) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final imageUrl = ApiService.resolveImageUrl(monster.pictureUrl);
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color:
                            Theme.of(context).colorScheme.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: const Text('Image preview unavailable'),
                      ),
                    ),
                  ),
                ),
              if (imageUrl != null) const SizedBox(height: 16),
              Text(
                monster.monsterName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text('Type: ${monster.monsterType}'),
              Text(
                'Coordinates: ${monster.spawnLatitude.toStringAsFixed(6)}, ${monster.spawnLongitude.toStringAsFixed(6)}',
              ),
              Text(
                'Spawn Radius: ${monster.spawnRadiusMeters.toStringAsFixed(0)} meters',
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Show Monster Map'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadMapData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          const Icon(Icons.map_outlined),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage == null
                                  ? '${_monsters.length} monster spawn point(s) loaded.'
                                  : 'Map loaded with fallback center. $_errorMessage',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _mapCenter,
                          initialZoom: 15,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.pokemap',
                          ),
                          CircleLayer(
                            circles: _monsters
                                .where((monster) => monster.spawnRadiusMeters > 0)
                                .map(
                                  (monster) => CircleMarker(
                                    point: LatLng(
                                      monster.spawnLatitude,
                                      monster.spawnLongitude,
                                    ),
                                    radius: monster.spawnRadiusMeters,
                                    useRadiusInMeter: true,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.12),
                                    borderColor:
                                        Theme.of(context).colorScheme.primary,
                                    borderStrokeWidth: 1.5,
                                  ),
                                )
                                .toList(),
                          ),
                          MarkerLayer(
                            markers: _monsters
                                .map(
                                  (monster) => Marker(
                                    width: 72,
                                    height: 72,
                                    point: LatLng(
                                      monster.spawnLatitude,
                                      monster.spawnLongitude,
                                    ),
                                    child: GestureDetector(
                                      onTap: () => _showMonsterInfo(monster),
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              monster.monsterName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.location_on,
                                            size: 38,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const RichAttributionWidget(
                            attributions: [
                              TextSourceAttribution(
                                'OpenStreetMap contributors',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
