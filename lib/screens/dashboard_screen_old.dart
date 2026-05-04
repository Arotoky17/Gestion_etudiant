import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../services/student_service.dart';
import '../widgets/student_card.dart';
import '../providers/theme_provider.dart';
import 'student_form_screen.dart';
import 'student_detail_screen.dart';
import 'grade_management_screen.dart';
import 'classe_management_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _searchController = TextEditingController();
  String _search = '';
  List<Student> _students = [];
  bool _isLoading = true;
  Map<String, dynamic> _statistics = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final students = await StudentService.getStudents();
      final stats = await StudentService.getStatistics();
      setState(() {
        _students = students;
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Handle error
    }
  }

  void _refresh() {
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openForm({Student? student}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => StudentFormScreen(student: student)),
    );
    if (saved == true) {
      _refresh();
    }
  }

  void _deleteStudent(String id) async {
    await StudentService.deleteStudent(id);
    _refresh();
  }

  List<Student> get _filteredStudents {
    if (_search.trim().isEmpty) return _students;
    final query = _search.toLowerCase();
    return _students.where((student) {
      return student.fullName.toLowerCase().contains(query) ||
          student.classe.toLowerCase().contains(query) ||
          student.email.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: Text('Tableau de bord', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1E293B),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
            tooltip: 'Se déconnecter',
          )
        ],
      ),
      body: _isLoading
          ? _buildLoadingView()
          : RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
                _refresh();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 20),
                      _buildSummaryCards(context),
                      const SizedBox(height: 16),
                      _buildNavigationButtons(context),
                      const SizedBox(height: 16),
                      _buildSearchBar(context),
                      const SizedBox(height: 16),
                      _buildStudentList(),
                      const SizedBox(height: 80), // Espace pour le FAB
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        label: const Text('Ajouter étudiant'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF3E5BFF),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF3E5BFF),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 40,
                      color: Color(0xFF3E5BFF),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Administrateur',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'École Primaire Excellence',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    icon: Icons.dashboard,
                    title: 'Tableau de bord',
                    isSelected: true,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  _buildDrawerItem(
                    icon: Icons.people,
                    title: 'Étudiants',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  _buildDrawerItem(
                    icon: Icons.grade,
                    title: 'Notes',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const GradeManagementScreen()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.school,
                    title: 'Classes',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ClasseManagementScreen()),
                      );
                    },
                  ),
                  const Divider(),
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return _buildDrawerItem(
                        icon: themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        title: themeProvider.isDarkMode ? 'Mode Clair' : 'Mode Sombre',
                        onTap: () {
                          themeProvider.toggleTheme();
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings,
                    title: 'Paramètres',
                    onTap: () {},
                  ),
                  _buildDrawerItem(
                    icon: Icons.help,
                    title: 'Aide',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF3E5BFF) : Colors.grey.shade600,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFF3E5BFF) : Colors.grey.shade800,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: const Color(0xFF3E5BFF).withOpacity(0.1),
      onTap: onTap,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF3E5BFF),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.blue.shade100.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bienvenue Directeur', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Gestion complète de vos étudiants.', style: const TextStyle(color: Colors.white70, fontSize: 15)),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildMetric(context, 'Étudiants', _statistics['totalStudents']?.toString() ?? '0'),
              const SizedBox(width: 16),
              _buildMetric(context, 'Moyenne', '${(_statistics['averageGrade'] as double?)?.toStringAsFixed(1) ?? '0.0'}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(BuildContext context, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return AnimationLimiter(
      child: Column(
        children: [
          Row(
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                _buildSummaryCard(
                  context,
                  'Total Étudiants',
                  _statistics['totalStudents']?.toString() ?? '0',
                  Icons.people,
                  const Color(0xFF3E5BFF),
                  'Étudiants inscrits'
                ),
                const SizedBox(width: 12),
                _buildSummaryCard(
                  context,
                  'Moyenne Générale',
                  '${(_statistics['averageGrade'] as double?)?.toStringAsFixed(1) ?? '0.0'}/20',
                  Icons.grade,
                  const Color(0xFF00B894),
                  'Performance moyenne'
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                horizontalOffset: -50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                _buildSummaryCard(
                  context,
                  'Taux Présence',
                  '${_statistics['averageAttendance'] ?? 0}%',
                  Icons.check_circle,
                  const Color(0xFFF39C12),
                  'Assiduité moyenne'
                ),
                const SizedBox(width: 12),
                _buildSummaryCard(
                  context,
                  'Classes',
                  (_statistics['classes'] as List?)?.length.toString() ?? '0',
                  Icons.school,
                  const Color(0xFF9B59B6),
                  'Classes actives'
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value, IconData icon, Color color, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.1), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildNavButton('Notes', Icons.grade, () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GradeManagementScreen()));
          }),
          const SizedBox(width: 8),
          _buildNavButton('Classes', Icons.school, () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ClasseManagementScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildNavButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3E5BFF),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _search = value),
      decoration: InputDecoration(
        hintText: 'Rechercher un étudiant, classe ou email',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildStudentList() {
    final students = _filteredStudents;
    if (students.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(Icons.school_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Aucun étudiant trouvé.',
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }
    return AnimationLimiter(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: students.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final student = students[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: StudentCard(
                  student: student,
                  onEdit: () => _openForm(student: student),
                  onDelete: () => _showDeleteDialog(student),
                  onViewDetails: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => StudentDetailScreen(student: student)),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(Student student) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer étudiant'),
          content: Text('Voulez-vous supprimer ${student.fullName} ?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () {
                _deleteStudent(student.id);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const SizedBox(height: 20),
          // Summary cards skeleton
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Navigation buttons skeleton
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),
          // Search bar skeleton
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 16),
          // Student list skeleton
          ...List.generate(3, (index) => Container(
            height: 80,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
          )),
        ],
      ),
    );
  }
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}
