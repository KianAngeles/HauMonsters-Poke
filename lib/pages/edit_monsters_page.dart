import 'package:flutter/material.dart';
import 'package:pokemap/models/monster_model.dart';
import 'package:pokemap/pages/edit_monster_page.dart';
import 'package:pokemap/services/api_service.dart';

class EditMonstersPage extends StatefulWidget {
  const EditMonstersPage({super.key});

  @override
  State<EditMonstersPage> createState() => _EditMonstersPageState();
}

class _EditMonstersPageState extends State<EditMonstersPage> {
  final _apiService = ApiService();

  List<Monster> _monsters = const <Monster>[];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMonsters();
  }

  Future<void> _loadMonsters() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final monsters = await _apiService.getMonsters();
      if (!mounted) {
        return;
      }
      setState(() {
        _monsters = monsters;
      });
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

  Future<void> _openEditMonster(Monster monster) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => EditMonsterPage(monster: monster),
      ),
    );

    if (updated == true && mounted) {
      _loadMonsters();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monster updated successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Monsters')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMonsters,
              child: _errorMessage != null && _monsters.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      children: [
                        _EmptyState(
                          message: _errorMessage!,
                          actionLabel: 'Try Again',
                          onPressed: _loadMonsters,
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final monster = _monsters[index];
                        final imageUrl =
                            ApiService.resolveImageUrl(monster.pictureUrl);

                        return Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: _MonsterThumbnail(imageUrl: imageUrl),
                            title: Text(monster.monsterName),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${monster.monsterType}\nLat: ${monster.spawnLatitude.toStringAsFixed(6)}\nLng: ${monster.spawnLongitude.toStringAsFixed(6)}\nRadius: ${monster.spawnRadiusMeters.toStringAsFixed(0)} m',
                              ),
                            ),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _openEditMonster(monster),
                            ),
                            onTap: () => _openEditMonster(monster),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemCount: _monsters.length,
                    ),
            ),
    );
  }
}

class _MonsterThumbnail extends StatelessWidget {
  const _MonsterThumbnail({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 64,
        height: 64,
        child: imageUrl == null
            ? Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported_outlined),
              )
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.warning_amber_outlined, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onPressed,
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
