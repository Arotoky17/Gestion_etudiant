import '../models/classe.dart';

class ClasseService {
  static final List<Classe> _classes = [
    Classe(
      id: 'CLS001',
      name: 'Terminale S',
      filiere: 'Scientifique',
      studentCount: 2,
    ),
    Classe(
      id: 'CLS002',
      name: 'Première ES',
      filiere: 'Économique',
      studentCount: 1,
    ),
  ];

  static List<Classe> get classes => List.unmodifiable(_classes);

  static void addClass(Classe classe) {
    _classes.add(classe);
  }

  static void updateClasse(Classe classe) {
    final index = _classes.indexWhere((item) => item.id == classe.id);
    if (index >= 0) {
      _classes[index] = classe;
    }
  }

  static void deleteClasse(String id) {
    _classes.removeWhere((classe) => classe.id == id);
  }

  static int get totalClasses => _classes.length;
}
