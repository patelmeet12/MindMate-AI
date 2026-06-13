import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';

class ShellScaffold extends ConsumerWidget {
  final Widget child;

  const ShellScaffold({super.key, required this.child});

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/journal')) return 1;
    if (location.startsWith('/mindfulness')) return 2;
    if (location.startsWith('/chat')) return 3;
    if (location.startsWith('/insights')) return 4;
    return 0; // Default is dashboard
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/journal');
        break;
      case 2:
        context.go('/mindfulness');
        break;
      case 3:
        context.go('/chat');
        break;
      case 4:
        context.go('/insights');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = ref.watch(themeProvider).isDark;
    final isHighContrast = ref.watch(themeProvider).isHighContrast;
    final selectedIndex = _getSelectedIndex(context);

    // Responsive design width check
    final isWide = MediaQuery.of(context).size.width >= 850;

    final navItems = [
      const NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      const NavigationDestination(
        icon: Icon(Icons.edit_note_outlined),
        selectedIcon: Icon(Icons.edit_note),
        label: 'AI Journal',
      ),
      const NavigationDestination(
        icon: Icon(Icons.spa_outlined),
        selectedIcon: Icon(Icons.spa),
        label: 'Mindfulness',
      ),
      const NavigationDestination(
        icon: Icon(Icons.chat_bubble_outline),
        selectedIcon: Icon(Icons.chat_bubble),
        label: 'Companion',
      ),
      const NavigationDestination(
        icon: Icon(Icons.trending_up_outlined),
        selectedIcon: Icon(Icons.trending_up),
        label: 'Insights',
      ),
    ];

    Widget buildThemeSettings() {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Theme Toggle
            Semantics(
              button: true,
              label: 'Toggle Light and Dark Mode Button',
              child: ListTile(
                dense: true,
                leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode, size: 20),
                title: Text(isDark ? 'Light Mode' : 'Dark Mode', style: const TextStyle(fontSize: 13)),
                onTap: () {
                  ref.read(themeProvider.notifier).toggleTheme();
                },
              ),
            ),
            // High Contrast Toggle
            Semantics(
              button: true,
              label: 'Toggle High Contrast Mode Button',
              child: ListTile(
                dense: true,
                leading: Icon(isHighContrast ? Icons.visibility_off : Icons.visibility, size: 20),
                title: Text(isHighContrast ? 'Standard Contrast' : 'High Contrast', style: const TextStyle(fontSize: 13)),
                onTap: () {
                  ref.read(themeProvider.notifier).toggleHighContrast();
                },
              ),
            ),
            const Divider(),
            // Profile Reset
            Semantics(
              button: true,
              label: 'Reset Profile Button',
              hint: 'Resets profile configurations and logs',
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.logout, size: 20, color: Colors.redAccent),
                title: const Text('Reset Profile', style: TextStyle(fontSize: 13, color: Colors.redAccent)),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Reset MindMate AI?'),
                      content: const Text('This will delete your student profile, all mood logs, study stats, and journal entries. This action is irreversible.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref.read(profileProvider.notifier).clearData();
                  }
                },
              ),
            ),
          ],
        ),
      );
    }

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            // Custom sidebar
            Container(
              width: 250,
              color: colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  // App Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Icon(Icons.spa, color: colorScheme.primary, size: 32),
                        const SizedBox(width: 12),
                        Text(
                          'MindMate AI',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.primary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Navigation Links
                  Expanded(
                    child: ListView.builder(
                      itemCount: navItems.length,
                      itemBuilder: (context, idx) {
                        final item = navItems[idx];
                        final isSelected = selectedIndex == idx;
                        return Semantics(
                          selected: isSelected,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _onItemTapped(idx, context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? colorScheme.primary.withOpacity(isHighContrast ? 1.0 : 0.12)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected ? (item.selectedIcon as Icon).icon : (item.icon as Icon).icon,
                                      color: isSelected 
                                          ? (isHighContrast ? Colors.black : colorScheme.primary)
                                          : colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      item.label,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: isSelected
                                            ? (isHighContrast ? Colors.black : colorScheme.primary)
                                            : colorScheme.onSurface,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  buildThemeSettings(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            const VerticalDivider(width: 1, thickness: 1),
            // Sub-pages main body
            Expanded(child: child),
          ],
        ),
      );
    }

    // Mobile / Narrow layouts
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.spa, color: colorScheme.primary, size: 24),
            const SizedBox(width: 8),
            const Text('MindMate AI'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => SafeArea(
                  child: buildThemeSettings(),
                ),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: Semantics(
        label: 'Mobile Bottom Navigation Bar',
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (idx) => _onItemTapped(idx, context),
          destinations: navItems,
        ),
      ),
    );
  }
}
