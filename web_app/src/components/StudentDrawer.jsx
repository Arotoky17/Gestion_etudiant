import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Mail, BookOpen, Clock, Edit, Trash2 } from 'lucide-react';

const StudentDrawer = ({ student, isOpen, onClose, onDelete }) => {
  if (!isOpen || !student) return null;

  return (
    <AnimatePresence>
      <motion.div 
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className="overlay"
        onClick={onClose}
      />
      <motion.div 
        initial={{ x: '100%' }}
        animate={{ x: 0 }}
        exit={{ x: '100%' }}
        transition={{ type: 'spring', damping: 25, stiffness: 200 }}
        className="drawer"
      >
        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '2rem' }}>
          <h2 style={{ fontSize: '1.5rem' }}>Détails Étudiant</h2>
          <button onClick={onClose}><X size={24} /></button>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '1.5rem', marginBottom: '3rem' }}>
          <div className="avatar" style={{ width: 80, height: 80, fontSize: '2rem' }}>
            {student.firstName[0]}{student.lastName[0]}
          </div>
          <div>
            <h3 style={{ fontSize: '1.75rem' }}>{student.firstName} {student.lastName}</h3>
            <p style={{ color: 'var(--text-secondary)' }}>{student.major} • {student.level}</p>
          </div>
        </div>

        <div style={{ display: 'grid', gap: '2rem' }}>
          <section>
            <h4 style={{ color: 'var(--text-secondary)', marginBottom: '1rem', textTransform: 'uppercase', fontSize: '0.75rem' }}>Contact</h4>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
              <Mail size={18} color="var(--silver)" />
              <span>{student.contact}</span>
            </div>
          </section>

          <section>
            <h4 style={{ color: 'var(--text-secondary)', marginBottom: '1rem', textTransform: 'uppercase', fontSize: '0.75rem' }}>Notes par Matière</h4>
            <div style={{ display: 'grid', gap: '0.75rem' }}>
              {student.grades.map((g, i) => (
                <div key={i} style={{ display: 'flex', justifyContent: 'space-between', padding: '1rem', background: 'var(--bg-card)', borderRadius: '12px', border: '1px solid var(--border-color)' }}>
                  <span>{g.subject}</span>
                  <span style={{ fontWeight: 700, color: g.score >= 10 ? 'var(--success-text)' : 'var(--danger-text)' }}>{g.score}/20</span>
                </div>
              ))}
            </div>
          </section>

          <section>
            <h4 style={{ color: 'var(--text-secondary)', marginBottom: '1rem', textTransform: 'uppercase', fontSize: '0.75rem' }}>Historique</h4>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
              <Clock size={18} color="var(--silver)" />
              <span>Dernière présence : Aujourd'hui</span>
            </div>
          </section>
        </div>

        <div style={{ marginTop: 'auto', display: 'flex', gap: '1rem', paddingTop: '3rem' }}>
          <button className="btn btn-secondary" style={{ flex: 1 }}>
            <Edit size={18} /> Modifier
          </button>
          <button 
            className="btn" 
            style={{ flex: 1, background: 'var(--danger-bg)', color: 'var(--danger-text)', border: '1px solid var(--danger-text)' }}
            onClick={() => {
              if (window.confirm('Supprimer cet étudiant ?')) {
                onDelete(student.id);
                onClose();
              }
            }}
          >
            <Trash2 size={18} /> Supprimer
          </button>
        </div>
      </motion.div>
    </AnimatePresence>
  );
};

export default StudentDrawer;
