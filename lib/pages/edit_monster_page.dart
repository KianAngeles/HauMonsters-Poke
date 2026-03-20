import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:pokemap/models/monster_model.dart';
import 'package:pokemap/services/api_service.dart';

class EditMonsterPage extends StatefulWidget {
  const EditMonsterPage({
    super.key,
    required this.monster,
  });

  final Monster monster;

  @override
  State<EditMonsterPage> createState() => _EditMonsterPageState();
}

class _EditMonsterPageState extends State<EditMonsterPage> {
  final _formKey = GlobalKey<FormState>();
  final _mapController = MapController();
  final _imagePicker = ImagePicker();
  final _apiService = ApiService();

  late final TextEditingController _nameController;
  late final TextEditingController _typeController;
  late final TextEditingController _radiusController;

  late LatLng _mapCenter;
  late LatLng _selectedPoint;
  File? _selectedImage;
  bool _isSubmitting = false;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.monster.monsterName);
    _typeController = TextEditingController(text: widget.monster.monsterType);
    _radiusController = TextEditingController(
      text: widget.monster.spawnRadiusMeters.toStringAsFixed(0),
    );
    _selectedPoint = LatLng(
      widget.monster.spawnLatitude,
      widget.monster.spawnLongitude,
    );
    _mapCenter = _selectedPoint;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (pickedFile == null || !mounted) {
        return;
      }
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } catch (error) {
      _showSnackBar('Unable to select image: $error');
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLocating = true;
    });

    final location = await _requestCurrentLocation();
    if (!mounted) {
      return;
    }

    setState(() {
      _isLocating = false;
      if (location != null) {
        _selectedPoint = location;
        _mapCenter = location;
      }
    });

    if (location != null) {
      _mapController.move(location, 16);
    } else {
      _showSnackBar('Current location is unavailable.');
    }
  }

  Future<void> _updateMonster() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final radius = double.tryParse(_radiusController.text.trim());
    if (radius == null || radius <= 0) {
      _showSnackBar('Enter a valid spawn radius.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      var imageUrl = widget.monster.pictureUrl;

      if (_selectedImage != null) {
        final uploadResult =
            await _apiService.uploadMonsterImage(_selectedImage!);
        if (!uploadResult.success) {
          _showSnackBar(uploadResult.message);
          return;
        }
        imageUrl = uploadResult.data ?? imageUrl;
      }

      final result = await _apiService.updateMonster(
        monsterId: widget.monster.monsterId,
        monsterName: _nameController.text.trim(),
        monsterType: _typeController.text.trim(),
        spawnLatitude: _selectedPoint.latitude,
        spawnLongitude: _selectedPoint.longitude,
        spawnRadiusMeters: radius,
        pictureUrl: imageUrl,
      );

      if (!result.success) {
        _showSnackBar(result.message);
        return;
      }

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (error) {
      _showSnackBar('Failed to update monster: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
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

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final radius =
        double.tryParse(_radiusController.text.trim()) ??
            widget.monster.spawnRadiusMeters;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Monster')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FormSection(
                title: 'Monster Details',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Monster Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Monster name is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _typeController,
                      decoration: const InputDecoration(
                        labelText: 'Monster Type',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Monster type is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _radiusController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Spawn Radius (meters)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        final parsed = double.tryParse(value?.trim() ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Enter a valid radius.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _FormSection(
                title: 'Spawn Point',
                trailing: TextButton.icon(
                  onPressed: _isLocating ? null : _useCurrentLocation,
                  icon: _isLocating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location_outlined),
                  label: const Text('Use Current Location'),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 320,
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _mapCenter,
                            initialZoom: 16,
                            onTap: (_, point) {
                              setState(() {
                                _selectedPoint = point;
                              });
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.pokemap',
                            ),
                            CircleLayer(
                              circles: [
                                CircleMarker(
                                  point: _selectedPoint,
                                  radius: radius,
                                  useRadiusInMeter: true,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.18),
                                  borderColor:
                                      Theme.of(context).colorScheme.primary,
                                  borderStrokeWidth: 2,
                                ),
                              ],
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _selectedPoint,
                                  width: 54,
                                  height: 54,
                                  child: Icon(
                                    Icons.location_pin,
                                    size: 42,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ],
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
                    const SizedBox(height: 12),
                    Text(
                      'Selected: ${_selectedPoint.latitude.toStringAsFixed(6)}, ${_selectedPoint.longitude.toStringAsFixed(6)}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _FormSection(
                title: 'Monster Image',
                child: Column(
                  children: [
                    _EditImagePreview(
                      localImage: _selectedImage,
                      networkImageUrl: widget.monster.pictureUrl,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _isSubmitting
                                ? null
                                : () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.photo_camera_outlined),
                            label: const Text('Camera'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isSubmitting
                                ? null
                                : () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Gallery'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSubmitting ? null : _updateMonster,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_isSubmitting ? 'Updating...' : 'Update Monster'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _EditImagePreview extends StatelessWidget {
  const _EditImagePreview({
    this.localImage,
    this.networkImageUrl,
  });

  final File? localImage;
  final String? networkImageUrl;

  @override
  Widget build(BuildContext context) {
    final resolvedNetworkImage = ApiService.resolveImageUrl(networkImageUrl);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: localImage != null
            ? Image.file(localImage!, fit: BoxFit.cover)
            : resolvedNetworkImage == null
                ? Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: const Text('No image available'),
                  )
                : Image.network(
                    resolvedNetworkImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      alignment: Alignment.center,
                      child: const Text('Image preview unavailable'),
                    ),
                  ),
      ),
    );
  }
}
