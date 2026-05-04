import 'package:flutter/material.dart';
import '../services/classe_service.dart';
import '../models/classe.dart';

class ClasseManagementScreen extends StatefulWidget {
  const ClasseManagementScreen({Key? key}) : super(key: key);

  @override
  State<ClasseManagementScreen> createState() => _ClasseManagementScreenState();
}

class _ClasseManagementScreenState extends State<ClasseManagementScreen> {
  void _refresh() {
    setState(() {});
  }

  void _deleteClasse(String id) {
    ClasseService.deleteClasse(id);
    _refresh();
  }

  void _showAddClasseDialog() {
    final nameController = TextEditingController();
    final filiereController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter une classe'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nom de la classe'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: filiereController,
                  decoration: const InputDecoration(labelText: 'Filière'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && filiereController.text.isNotEmpty) {
                  final classe = Classe(
                    id: 'CLS${DateTime.now().millisecondsSinceEpoch}',
                    name: nameController.text,
                    filiere: filiereController.text,
                    studentCount: 0,
                  );
                  ClasseService.addClass(classe);
                  _refresh();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final classes = ClasseService.classes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des classes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total des classes', style: TextStyle(color: Colors.grey[700])),
                        Text(classes.length.toString(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _showAddClasseDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: classes.isEmpty
                  ? Center(
                      child: Text('Aucune classe', style: TextStyle(color: Colors.grey[700])),
                    )
                  : ListView.separated(
                      itemCount: classes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final classe = classes[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF3E5BFF),
                              child: Text(classe.name.substring(0, 1), style: const TextStyle(color: Colors.white)),
                            ),
                            title: Text(classe.name),
                            subtitle: Text('${classe.filiere} - ${classe.studentCount} étudiants'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteClasse(classe.id),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddClasseDialog,
        label: const Text('Nouvelle classe'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
