import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:leet_repeat_mobile_cross_platform/data/models/problem_list.dart';
import 'package:leet_repeat_mobile_cross_platform/data/repositories/problem_list_repository.dart';

class ProblemListsScreen extends StatefulWidget {
  const ProblemListsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ProblemListsScreenState();
}

class _ProblemListsScreenState extends State<ProblemListsScreen> {
  final ProblemListRepository _problemListRepository = ProblemListRepository();
  String? _problemListName = '';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            _searchBar(),
            Expanded(child: Center(child: _problemLists())),
          ],
        ),
        Positioned(bottom: 24, right: 24, child: _addProblemListButton()),
      ],
    );
  }

  Widget _problemLists() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return FutureBuilder(
      future: _problemListRepository.getAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.list_alt_outlined, size: 48, color: cs.outline),
                const SizedBox(height: 12),
                Text(
                  'No lists yet',
                  style: tt.bodyLarge?.copyWith(color: cs.outline),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap + to create your first list',
                  style: tt.bodySmall?.copyWith(color: cs.outline),
                ),
              ],
            ),
          );
        }

        final filteredLists = snapshot.data!
            .where(
              (list) =>
                  list.name.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();

        if (filteredLists.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off_outlined, size: 48, color: cs.outline),
                const SizedBox(height: 12),
                Text(
                  'No lists found',
                  style: tt.bodyLarge?.copyWith(color: cs.outline),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
          itemCount: filteredLists.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = filteredLists[index];

            return Dismissible(
              key: ValueKey(item.id),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (dCtx) => AlertDialog(
                    title: const Text('Delete list?'),
                    content: const Text('List and progress will be deleted.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dCtx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: cs.error),
                        onPressed: () => Navigator.pop(dCtx, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                return ok ?? false;
              },
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: cs.errorContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.delete_outline, color: cs.onErrorContainer),
              ),
              onDismissed: (_) async {
                await _problemListRepository.delete(item.id!);
                if (!mounted) return;
                setState(() {});
              },
              child: Card(
                elevation: 0,
                color: cs.primaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.push('/problem-lists/${item.id}'),
                  onLongPress: () => _openActionsSheet(item),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          color: cs.onPrimaryContainer,
                          size: 28,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: tt.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: cs.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Hold to rename • Swipe to delete',
                                style: tt.labelSmall?.copyWith(
                                  color: cs.onPrimaryContainer.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: cs.onPrimaryContainer.withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openActionsSheet(ProblemList item) {
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Icon(Icons.edit_outlined, color: cs.primary),
            title: const Text('Rename'),
            onTap: () {
              Navigator.pop(sheetCtx);
              _openRenameDialog(item);
            },
          ),
        ),
      ),
    );
  }

  void _openRenameDialog(ProblemList item) {
    final controller = TextEditingController(text: item.name);

    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Rename list'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              final nav = Navigator.of(dCtx);
              await _problemListRepository.rename(item.id!, name);
              if (!mounted) return;
              nav.pop();
              setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _addProblemListButton() {
    final cs = Theme.of(context).colorScheme;

    return FloatingActionButton(
      backgroundColor: cs.primary,
      onPressed: () {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('New Problem List'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) =>
                      setState(() => _problemListName = value),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'List name...',
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      if (_problemListName == null ||
                          _problemListName!.isEmpty) {
                        return;
                      }
                      final nav = Navigator.of(dialogContext);
                      await _problemListRepository.add(
                        ProblemList(name: _problemListName!),
                      );
                      if (!mounted) return;
                      nav.pop();
                      setState(() => _problemListName = null);
                    },
                    child: const Text('Create'),
                  ),
                ),
              ],
            ),
          ),
        );
        setState(() {});
      },
      child: const Icon(Icons.add),
    );
  }

  Widget _searchBar() {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 0),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search lists...',
          prefixIcon: Icon(Icons.search, color: cs.outline),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close, color: cs.outline),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
