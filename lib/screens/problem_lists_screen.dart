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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(child: _problemLists()),
        Positioned(bottom: 24, right: 24, child: _addProblemListButton()),
      ],
    );
  }

  Widget _problemLists() {
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
          return const Center(child: Text('No lists yet!'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final item = snapshot.data![index];

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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.redAccent,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) async {
                await _problemListRepository.delete(item.id!);
                if (!mounted) return;
                setState(() {});
              },
              child: Card(
                child: InkWell(
                  onTap: () {
                    context.go('/problem-lists/${snapshot.data![index].id}');
                  },
                  onLongPress: () => _openActionsSheet(item),
                  child: ListTile(
                    title: Text(snapshot.data![index].name),
                    trailing: const Icon(Icons.chevron_right),
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
    showModalBottomSheet(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(sheetCtx);
                _openRenameDialog(item);
              },
            ),
          ],
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
          TextButton(
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
    return FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.primary,
      onPressed: () {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Add Problem List'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _problemListName = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Name...',
                  ),
                ),
                MaterialButton(
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () async {
                    if (_problemListName == null || _problemListName == '') {
                      return;
                    }

                    final nav = Navigator.of(dialogContext);

                    await _problemListRepository.add(
                      ProblemList(name: _problemListName!),
                    );

                    if (!mounted) return;
                    nav.pop();

                    setState(() {
                      _problemListName = null;
                    });
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(color: Colors.white),
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
}
