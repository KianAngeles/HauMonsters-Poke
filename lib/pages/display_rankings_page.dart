import 'package:flutter/material.dart';
import 'package:pokemap/models/player_ranking_model.dart';
import 'package:pokemap/services/api_service.dart';

class DisplayRankingsPage extends StatefulWidget {
  const DisplayRankingsPage({super.key});

  @override
  State<DisplayRankingsPage> createState() => _DisplayRankingsPageState();
}

class _DisplayRankingsPageState extends State<DisplayRankingsPage> {
  final _apiService = ApiService();

  List<PlayerRanking> _rankings = const <PlayerRanking>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRankings();
  }

  Future<void> _loadRankings() async {
    setState(() {
      _isLoading = true;
    });

    final rankings = await _apiService.getPlayerRankings();

    if (!mounted) {
      return;
    }

    setState(() {
      _rankings = rankings;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top Monster Hunters')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rankings.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.leaderboard_outlined, size: 44),
                            const SizedBox(height: 14),
                            Text(
                              'No player rankings returned by the API yet.',
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRankings,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final ranking = _rankings[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text('${ranking.rank}'),
                          ),
                          title: Text(ranking.playerName),
                          subtitle: Text(
                            '${ranking.monstersCaught} monsters caught',
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemCount: _rankings.length,
                  ),
                ),
    );
  }
}
