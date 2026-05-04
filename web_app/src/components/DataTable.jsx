import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ChevronUp, ChevronDown, User } from 'lucide-react';

const DataTable = ({ students, onSort, sortConfig, onSelectStudent }) => {
  
  const getStatusBadge = (student, isMajor) => {
    if (isMajor) return <span className="badge badge-silver">Major</span>;
    if (student.averageGrade >= 10 && student.attendanceRate >= 70) {
      return <span className="badge badge-success">Admis</span>;
    }
    if (student.averageGrade < 10 || student.attendanceRate < 70) {
      return <span className="badge badge-alert">À risque</span>;
    }
    return null;
  };

  const getInitials = (student) => {
    return `${student.firstName[0]}${student.lastName[0]}`.toUpperCase();
  };

  const maxGrade = Math.max(...students.map(s => s.averageGrade));

  return (
    <div className="table-container">
      <table>
        <thead>
          <tr>
            <th onClick={() => onSort('lastName')}>
              Étudiant {sortConfig.key === 'lastName' && (sortConfig.direction === 'asc' ? <ChevronUp size={14} /> : <ChevronDown size={14} />)}
            </th>
            <th onClick={() => onSort('major')}>Filière</th>
            <th onClick={() => onSort('level')}>Niveau</th>
            <th onClick={() => onSort('averageGrade')}>Moyenne</th>
            <th onClick={() => onSort('attendanceRate')}>Présence</th>
            <th>Statut</th>
          </tr>
        </thead>
        <tbody>
          <AnimatePresence mode='wait'>
            {students.map((student) => (
              <motion.tr 
                key={student.id}
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                whileHover={{ backgroundColor: 'rgba(255, 255, 255, 0.02)' }}
                onClick={() => onSelectStudent(student)}
                style={{ cursor: 'pointer' }}
              >
                <td>
                  <div className="student-cell">
                    <div className="avatar">{getInitials(student)}</div>
                    <div>
                      <div style={{ fontWeight: 600 }}>{student.firstName} {student.lastName}</div>
                      <div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>{student.id}</div>
                    </div>
                  </div>
                </td>
                <td>{student.major}</td>
                <td>{student.level}</td>
                <td style={{ fontWeight: 600 }}>{student.averageGrade.toFixed(1)}</td>
                <td>{student.attendanceRate}%</td>
                <td>{getStatusBadge(student, student.averageGrade === maxGrade)}</td>
              </motion.tr>
            ))}
          </AnimatePresence>
        </tbody>
      </table>
    </div>
  );
};

export default DataTable;
