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
        Center(child: _problemList()),
        Positioned(bottom: 24, right: 24, child: _addProblemListButton()),
      ],
    );
  }

  Widget _problemList() {
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
          itemBuilder: (context, index) => Card(
            child: InkWell(
              onTap: () {
                context.go('/problem-lists/${snapshot.data![index].name}');
              },
              child: ListTile(
                title: Text(snapshot.data![index].name),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _addProblemListButton() {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.primary,
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
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
                  onPressed: () {
                    if (_problemListName == null || _problemListName == '') {
                      return;
                    }
                    _problemListRepository.add(
                      ProblemList(name: _problemListName!),
                    );
                    setState(() {
                      _problemListName = null;
                    });
                    Navigator.pop(context);
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
