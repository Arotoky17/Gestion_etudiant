import React from 'react';
import { 
  BarChart, 
  Bar, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer,
  LineChart,
  Line
} from 'recharts';

const Analytics = ({ students }) => {
  // Data for Histogram (Grade distribution)
  const distribution = [
    { range: '0-5', count: students.filter(s => s.averageGrade < 5).length },
    { range: '5-10', count: students.filter(s => s.averageGrade >= 5 && s.averageGrade < 10).length },
    { range: '10-12', count: students.filter(s => s.averageGrade >= 10 && s.averageGrade < 12).length },
    { range: '12-14', count: students.filter(s => s.averageGrade >= 12 && s.averageGrade < 14).length },
    { range: '14-16', count: students.filter(s => s.averageGrade >= 14 && s.averageGrade < 16).length },
    { range: '16-20', count: students.filter(s => s.averageGrade >= 16).length },
  ];

  // Mock monthly attendance data
  const attendanceHistory = [
    { month: 'Sept', rate: 92 },
    { month: 'Oct', rate: 88 },
    { month: 'Nov', rate: 85 },
    { month: 'Dec', rate: 78 },
    { month: 'Jan', rate: 82 },
    { month: 'Feb', rate: 90 },
  ];

  return (
    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(400px, 1fr))', gap: '2rem', marginTop: '3rem' }}>
      <div className="table-container" style={{ padding: '2rem', height: '400px' }}>
        <h3 style={{ marginBottom: '2rem', color: 'var(--text-secondary)' }}>Distribution des Notes</h3>
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={distribution}>
            <CartesianGrid strokeDasharray="3 3" stroke="var(--border-color)" vertical={false} />
            <XAxis dataKey="range" stroke="var(--text-secondary)" fontSize={12} />
            <YAxis stroke="var(--text-secondary)" fontSize={12} />
            <Tooltip 
              contentStyle={{ background: 'var(--bg-card)', border: '1px solid var(--border-color)', borderRadius: '12px' }}
              itemStyle={{ color: 'var(--silver)' }}
            />
            <Bar dataKey="count" fill="var(--silver)" radius={[4, 4, 0, 0]} />
          </BarChart>
        </ResponsiveContainer>
      </div>

      <div className="table-container" style={{ padding: '2rem', height: '400px' }}>
        <h3 style={{ marginBottom: '2rem', color: 'var(--text-secondary)' }}>Évolution Présence Mensuelle</h3>
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={attendanceHistory}>
            <CartesianGrid strokeDasharray="3 3" stroke="var(--border-color)" vertical={false} />
            <XAxis dataKey="month" stroke="var(--text-secondary)" fontSize={12} />
            <YAxis stroke="var(--text-secondary)" fontSize={12} domain={[0, 100]} />
            <Tooltip 
              contentStyle={{ background: 'var(--bg-card)', border: '1px solid var(--border-color)', borderRadius: '12px' }}
            />
            <Line type="monotone" dataKey="rate" stroke="var(--silver)" strokeWidth={3} dot={{ fill: 'var(--silver)' }} />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
};

export default Analytics;
