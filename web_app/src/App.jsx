import React, { useState, useEffect, useMemo } from 'react';
import { 
  Users, 
  GraduationCap, 
  Clock, 
  CheckCircle, 
  Search, 
  Plus, 
  Download, 
  Upload, 
  BarChart2, 
  Filter,
  List
} from 'lucide-react';
import StatsCard from './components/StatsCard';
import DataTable from './components/DataTable';
import StudentDrawer from './components/StudentDrawer';
import Analytics from './components/Analytics';
import { MOCK_STUDENTS } from './data';
import { motion, AnimatePresence } from 'framer-motion';
import Papa from 'papaparse';
import { jsPDF } from 'jspdf';
import 'jspdf-autotable';

function App() {
  const [students, setStudents] = useState(() => {
    const saved = localStorage.getItem('students');
    return saved ? JSON.parse(saved) : MOCK_STUDENTS;
  });

  const [search, setSearch] = useState('');
  const [filterMajor, setFilterMajor] = useState('all');
  const [filterLevel, setFilterLevel] = useState('all');
  const [sortConfig, setSortConfig] = useState({ key: 'lastName', direction: 'asc' });
  const [selectedStudent, setSelectedStudent] = useState(null);
  const [isDrawerOpen, setIsDrawerOpen] = useState(false);
  const [view, setView] = useState('list'); // 'list' or 'analytics'
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage, setItemsPerPage] = useState(20);

  // Persistence
  useEffect(() => {
    localStorage.setItem('students', JSON.stringify(students));
  }, [students]);

  // Derived stats
  const stats = useMemo(() => {
    const total = students.length;
    const avg = total > 0 ? students.reduce((acc, s) => acc + s.averageGrade, 0) / total : 0;
    const attendance = total > 0 ? students.reduce((acc, s) => acc + s.attendanceRate, 0) / total : 0;
    const successCount = students.filter(s => s.averageGrade >= 10 && s.attendanceRate >= 70).length;
    const successRate = total > 0 ? (successCount / total) * 100 : 0;

    return { total, avg: avg.toFixed(1), attendance: attendance.toFixed(0), successRate: successRate.toFixed(0) };
  }, [students]);

  // Filtering & Sorting
  const filteredStudents = useMemo(() => {
    return students
      .filter(s => {
        const matchesSearch = `${s.firstName} ${s.lastName}`.toLowerCase().includes(search.toLowerCase());
        const matchesMajor = filterMajor === 'all' || s.major === filterMajor;
        const matchesLevel = filterLevel === 'all' || s.level === filterLevel;
        return matchesSearch && matchesMajor && matchesLevel;
      })
      .sort((a, b) => {
        if (a[sortConfig.key] < b[sortConfig.key]) return sortConfig.direction === 'asc' ? -1 : 1;
        if (a[sortConfig.key] > b[sortConfig.key]) return sortConfig.direction === 'asc' ? 1 : -1;
        return 0;
      });
  }, [students, search, filterMajor, filterLevel, sortConfig]);

  // Pagination
  const paginatedStudents = useMemo(() => {
    const start = (currentPage - 1) * itemsPerPage;
    return filteredStudents.slice(start, start + itemsPerPage);
  }, [filteredStudents, currentPage, itemsPerPage]);

  const totalPages = Math.ceil(filteredStudents.length / itemsPerPage);

  const handleSort = (key) => {
    setSortConfig(prev => ({
      key,
      direction: prev.key === key && prev.direction === 'asc' ? 'desc' : 'asc'
    }));
  };

  const handleDelete = (id) => {
    setStudents(prev => prev.filter(s => s.id !== id));
  };

  const handleImport = (e) => {
    const file = e.target.files[0];
    if (file) {
      Papa.parse(file, {
        header: true,
        complete: (results) => {
          const imported = results.data.map(row => ({
            id: Math.random().toString(36).substr(2, 9),
            firstName: row.prenom || 'N/A',
            lastName: row.nom || 'N/A',
            major: row.filiere || 'Informatique',
            level: row.niveau || 'L1',
            averageGrade: parseFloat(row.moyenne) || 0,
            attendanceRate: parseFloat(row.presence) || 0,
            contact: row.contact || '',
            grades: []
          }));
          setStudents(prev => [...imported, ...prev]);
        }
      });
    }
  };

  const handleExport = () => {
    const doc = new jsPDF();
    doc.text("Liste des Étudiants - Rapport Argent", 14, 15);
    
    const tableData = filteredStudents.map(s => [
      `${s.firstName} ${s.lastName}`,
      s.major,
      s.level,
      s.averageGrade.toFixed(1),
      `${s.attendanceRate}%`,
      s.averageGrade >= 10 && s.attendanceRate >= 70 ? 'Admis' : 'À risque'
    ]);

    doc.autoTable({
      head: [['Nom', 'Filière', 'Niveau', 'Moyenne', 'Présence', 'Statut']],
      body: tableData,
      startY: 25,
      theme: 'grid',
      headStyles: { fillColor: [42, 42, 54] }
    });

    doc.save(`export_etudiants_${new Date().toLocaleDateString()}.pdf`);
  };

  return (
    <div className="app-container">
      <header>
        <div className="header-top">
          <div className="header-title">
            <h1>Gestion Étudiant</h1>
            <p style={{ color: 'var(--text-secondary)' }}>Dashboard Admin • Silver Edition</p>
          </div>
          <div style={{ display: 'flex', gap: '1rem' }}>
            <button className="btn btn-secondary" onClick={() => setView(view === 'list' ? 'analytics' : 'list')}>
              {view === 'list' ? <BarChart2 size={20} /> : <List size={20} />}
              {view === 'list' ? 'Analytique' : 'Liste'}
            </button>
            <button className="btn btn-primary">
              <Plus size={20} /> Ajouter Étudiant
            </button>
          </div>
        </div>

        <div className="stats-grid">
          <StatsCard title="Total Étudiants" value={stats.total} icon={Users} />
          <StatsCard title="Moyenne Générale" value={stats.avg} unit="/20" icon={GraduationCap} />
          <StatsCard title="Taux Présence" value={stats.attendance} unit="%" icon={Clock} />
          <StatsCard title="Taux Réussite" value={stats.successRate} unit="%" icon={CheckCircle} />
        </div>
      </header>

      <main>
        <div className="action-bar">
          <div className="search-container">
            <Search className="search-icon" size={18} />
            <input 
              type="text" 
              placeholder="Rechercher un étudiant..." 
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>

          <div className="filters-group">
            <select value={filterMajor} onChange={(e) => setFilterMajor(e.target.value)}>
              <option value="all">Toutes les filières</option>
              <option value="Informatique">Informatique</option>
              <option value="Gestion">Gestion</option>
              <option value="Droit">Droit</option>
            </select>
            <select value={filterLevel} onChange={(e) => setFilterLevel(e.target.value)}>
              <option value="all">Tous les niveaux</option>
              <option value="L1">L1</option>
              <option value="L2">L2</option>
              <option value="L3">L3</option>
              <option value="M1">M1</option>
              <option value="M2">M2</option>
            </select>
          </div>

          <div style={{ display: 'flex', gap: '0.75rem' }}>
            <label className="btn btn-secondary" style={{ cursor: 'pointer' }}>
              <Upload size={18} /> Importer
              <input type="file" hidden accept=".csv" onChange={handleImport} />
            </label>
            <button className="btn btn-secondary" onClick={handleExport}>
              <Download size={18} /> Export PDF
            </button>
          </div>
        </div>

        <AnimatePresence mode="wait">
          {view === 'list' ? (
            <motion.div
              key="list"
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 20 }}
            >
              <DataTable 
                students={paginatedStudents} 
                onSort={handleSort}
                sortConfig={sortConfig}
                onSelectStudent={(s) => { setSelectedStudent(s); setIsDrawerOpen(true); }}
              />

              <div className="pagination">
                <div style={{ color: 'var(--text-secondary)', fontSize: '0.85rem' }}>
                  Affichage de {paginatedStudents.length} sur {filteredStudents.length} étudiants
                </div>
                <div style={{ display: 'flex', gap: '0.5rem' }}>
                  <button 
                    className="btn btn-secondary" 
                    disabled={currentPage === 1}
                    onClick={() => setCurrentPage(prev => prev - 1)}
                  >
                    Précédent
                  </button>
                  <button 
                    className="btn btn-secondary" 
                    disabled={currentPage === totalPages}
                    onClick={() => setCurrentPage(prev => prev + 1)}
                  >
                    Suivant
                  </button>
                </div>
              </div>
            </motion.div>
          ) : (
            <motion.div
              key="analytics"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
            >
              <Analytics students={filteredStudents} />
            </motion.div>
          )}
        </AnimatePresence>
      </main>

      <StudentDrawer 
        student={selectedStudent}
        isOpen={isDrawerOpen}
        onClose={() => setIsDrawerOpen(false)}
        onDelete={handleDelete}
      />
    </div>
  );
}

export default App;
