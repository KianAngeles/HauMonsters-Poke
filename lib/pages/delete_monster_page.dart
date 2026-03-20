import 'package:flutter/material.dart';
import 'package:pokemap/models/monster_model.dart';
import 'package:pokemap/services/api_service.dart';

class DeleteMonsterPage extends StatefulWidget {
  const DeleteMonsterPage({super.key});

  @override
  State<DeleteMonsterPage> createState() => _DeleteMonsterPageState();
}

class _DeleteMonsterPageState extends State<DeleteMonsterPage> {
  final _apiService = ApiService();

  List<Monster> _monsters = const <Monster>[];
  bool _isLoading = true;
  String? _errorMessage;
  int? _deletingMonsterId;

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

  Future<void> _confirmDelete(Monster monster) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Monster'),
          content: Text(
            'Delete ${monster.monsterName} from the monster list?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    setState(() {
      _deletingMonsterId = monster.monsterId;
    });

    final result = await _apiService.deleteMonster(monster.monsterId);

    if (!mounted) {
      return;
    }

    setState(() {
      _deletingMonsterId = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );

    if (result.success) {
      _loadMonsters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delete Monsters')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMonsters,
              child: _errorMessage != null && _monsters.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      children: [
                        _DeleteEmptyState(
                          message: _errorMessage!,
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
                        final isDeleting =
                            _deletingMonsterId == monster.monsterId;

                        return Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: _DeleteImage(imageUrl: imageUrl),
                            title: Text(monster.monsterName),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(monster.monsterType),
                            ),
                            trailing: isDeleting
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : IconButton(
                                    onPressed: () => _confirmDelete(monster),
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                  ),
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

class _DeleteImage extends StatelessWidget {
  const _DeleteImage({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 60,
        height: 60,
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

class _DeleteEmptyState extends StatelessWidget {
  const _DeleteEmptyState({
    required this.message,
    required this.onPressed,
  });

  final String message;
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
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
