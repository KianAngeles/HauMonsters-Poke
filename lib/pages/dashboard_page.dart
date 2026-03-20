import 'package:flutter/material.dart';
import 'package:pokemap/pages/add_monster_page.dart';
import 'package:pokemap/pages/catch_monster_page.dart';
import 'package:pokemap/pages/delete_monster_page.dart';
import 'package:pokemap/pages/display_rankings_page.dart';
import 'package:pokemap/pages/edit_monsters_page.dart';
import 'package:pokemap/pages/map_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    const dashboardColors = <Color>[
      Color(0xFFD63A32),
      Color(0xFF2A75BB),
      Color(0xFFFFCB05),
      Color(0xFF4CAF50),
      Color(0xFF8E44AD),
      Color(0xFFEF6C00),
    ];

    final items = <_DashboardItem>[
      _DashboardItem(
        title: 'Add Monsters',
        subtitle: 'Create new monster spawn points',
        icon: Icons.add_circle_outline,
        pageBuilder: () => const AddMonsterPage(),
      ),
      _DashboardItem(
        title: 'Catch Monsters',
        subtitle: 'Placeholder exam page',
        icon: Icons.sports_martial_arts_outlined,
        pageBuilder: () => const CatchMonsterPage(),
      ),
      _DashboardItem(
        title: 'Edit Monsters',
        subtitle: 'Review and update monster details',
        icon: Icons.edit_outlined,
        pageBuilder: () => const EditMonstersPage(),
      ),
      _DashboardItem(
        title: 'Delete Monsters',
        subtitle: 'Remove monsters from the roster',
        icon: Icons.delete_outline,
        pageBuilder: () => const DeleteMonsterPage(),
      ),
      _DashboardItem(
        title: 'View Top Monster Hunters',
        subtitle: 'Player rankings overview',
        icon: Icons.leaderboard_outlined,
        pageBuilder: () => const DisplayRankingsPage(),
      ),
      _DashboardItem(
        title: 'Show Monster Map',
        subtitle: 'Locate all current monster spawns',
        icon: Icons.map_outlined,
        pageBuilder: () => const MapPage(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Monster Control Center')),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.12),
                      child: Icon(
                        Icons.catching_pokemon,
                        size: 30,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'HAUMonsters',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '6ADET Finals Monster Module',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    for (final item in items)
                      ListTile(
                        leading: Icon(item.icon),
                        title: Text(item.title),
                        subtitle: Text(item.subtitle),
                        onTap: () {
                          Navigator.pop(context);
                          _openPage(context, item.pageBuilder());
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF4D5), Color(0xFFFBEDE9), Color(0xFFF4F8FF)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -50,
              right: -40,
              child: IgnorePointer(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD63A32).withValues(alpha: 0.12),
                      width: 12,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 34,
              right: 38,
              child: IgnorePointer(
                child: Container(
                  width: 100,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A75BB).withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -28,
              left: -18,
              child: IgnorePointer(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFCB05).withValues(alpha: 0.16),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFD63A32),
                            Color(0xFFB62828),
                            Color(0xFF2A75BB),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Monster Operations',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Manage the monster roster, update spawn points, upload monster images, and verify map placement before your exam demo.',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.92,
                                        ),
                                        height: 1.35,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 18),
                          Container(
                            width: 74,
                            height: 74,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.35),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.catching_pokemon,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const spacing = 14.0;
                        final crossAxisCount = constraints.maxWidth >= 900
                            ? 3
                            : 2;
                        final mainAxisExtent = constraints.maxWidth >= 900
                            ? 220.0
                            : constraints.maxWidth >= 640
                            ? 214.0
                            : 258.0;

                        return GridView.builder(
                          padding: const EdgeInsets.only(bottom: 4),
                          itemCount: items.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: spacing,
                                crossAxisSpacing: spacing,
                                mainAxisExtent: mainAxisExtent,
                              ),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final tint =
                                dashboardColors[index % dashboardColors.length];

                            return Card(
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () =>
                                    _openPage(context, item.pageBuilder()),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: tint.withValues(
                                                alpha: 0.14,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Icon(
                                              item.icon,
                                              size: 28,
                                              color: tint,
                                            ),
                                          ),
                                          const Spacer(),
                                          Icon(
                                            Icons.arrow_outward_rounded,
                                            color: tint.withValues(alpha: 0.72),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        item.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              height: 1.15,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: Text(
                                          item.subtitle,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                height: 1.32,
                                                color: Colors.black87,
                                              ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: tint.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: Text(
                                          'Open',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                color: tint,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}

class _DashboardItem {
  const _DashboardItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.pageBuilder,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget Function() pageBuilder;
}
