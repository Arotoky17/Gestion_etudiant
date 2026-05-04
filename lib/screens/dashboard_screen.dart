import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../services/student_service.dart';
import '../widgets/student_card.dart';
import '../providers/theme_provider.dart';
import 'student_form_screen.dart';
import 'student_detail_screen.dart';
import 'login_screen.dart';
import '../services/pdf_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedMajor;
  String? _selectedLevel;
  bool _ascending = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openForm({Student? student}) async {
    final saved = await Navigator.of(context).push<bool>(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => StudentFormScreen(student: student),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutQuint;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );
    if (saved == true) {
      setState(() {});
    }
  }

  void _deleteStudent(Student student) async {
    await StudentService.deleteStudent(student.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${student.fullName} supprimé'),
          action: SnackBarAction(
            label: 'Annuler',
            onPressed: () async {
              await StudentService.addStudent(student);
              setState(() {});
            },
          ),
        ),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Student>>(
      future: StudentService.getStudents(),
      builder: (context, snapshot) {
        final students = snapshot.data ?? [];
        
        // Filtering
        var filteredStudents = students.where((s) {
          final matchesSearch = s.fullName.toLowerCase().contains(_searchQuery.toLowerCase());
          final matchesMajor = _selectedMajor == null || s.major == _selectedMajor;
          final matchesLevel = _selectedLevel == null || s.level == _selectedLevel;
          return matchesSearch && matchesMajor && matchesLevel;
        }).toList();

        // Sorting
        filteredStudents.sort((a, b) {
          int cmp = a.averageGrade.compareTo(b.averageGrade);
          return _ascending ? cmp : -cmp;
        });

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(students),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildSearchBar(),
                  ),
                ),
                if (filteredStudents.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final student = filteredStudents[index];
                        return Dismissible(
                          key: Key(student.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Colors.red,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) => _deleteStudent(student),
                          child: StudentCard(
                            student: student,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => StudentDetailScreen(student: student)),
                            ),
                          ),
                        );
                      },
                      childCount: filteredStudents.length,
                    ),
                  ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openForm(),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(List<Student> students) {
    final stats = _calculateStats(students);
    return SliverAppBar(
      expandedHeight: 220.0,
      floating: false,
      pinned: true,
      centerTitle: true,
      title: const Text('Gestion Étudiant'),
      actions: [
        IconButton(
          icon: const Icon(Icons.picture_as_pdf),
          onPressed: () => PDFService.exportStudentList(students),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 80, left: 16, right: 16, bottom: 16),
            child: Row(
              children: [
                Expanded(child: _buildStatCard('Total', stats['total'].toString(), Icons.people)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard('Moyenne', stats['avgGrade'].toStringAsFixed(1), Icons.star)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard('Présence', '${stats['avgAttendance'].toStringAsFixed(0)}%', Icons.check_circle)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateStats(List<Student> students) {
    if (students.isEmpty) return {'total': 0, 'avgGrade': 0.0, 'avgAttendance': 0.0};
    double totalGrade = 0;
    double totalAttendance = 0;
    for (var s in students) {
      totalGrade += s.averageGrade;
      totalAttendance += s.attendanceRate;
    }
    return {
      'total': students.length,
      'avgGrade': totalGrade / students.length,
      'avgAttendance': totalAttendance / students.length,
    };
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Column(
      children: [
        SearchBar(
          controller: _searchController,
          hintText: 'Rechercher un étudiant...',
          onChanged: (value) => setState(() => _searchQuery = value),
          leading: const Icon(Icons.search),
          trailing: [
            IconButton(
              icon: Icon(_ascending ? Icons.arrow_upward : Icons.arrow_downward),
              onPressed: () => setState(() => _ascending = !_ascending),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('Tous', _selectedMajor == null, () => setState(() => _selectedMajor = null)),
              const SizedBox(width: 8),
              _buildFilterChip('Informatique', _selectedMajor == 'Informatique', () => setState(() => _selectedMajor = 'Informatique')),
              const SizedBox(width: 8),
              _buildFilterChip('Gestion', _selectedMajor == 'Gestion', () => setState(() => _selectedMajor = 'Gestion')),
              const SizedBox(width: 8),
              _buildFilterChip('L1', _selectedLevel == 'L1', () => setState(() => _selectedLevel = 'L1')),
              const SizedBox(width: 8),
              _buildFilterChip('L2', _selectedLevel == 'L2', () => setState(() => _selectedLevel = 'L2')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 2),
            builder: (context, double value, child) {
              return Transform.translate(
                offset: Offset(0, 10 * (1 - value.abs())),
                child: child,
              );
            },
            child: SvgPicture.asset(
              'assets/images/empty_state.svg',
              height: 200,
            ),
          ),
          const SizedBox(height: 24),
          const Text('Aucun étudiant pour l\'instant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _openForm(),
            child: const Text('Ajouter le premier étudiant'),
          ),
        ],
      ),
    );
  }
}
