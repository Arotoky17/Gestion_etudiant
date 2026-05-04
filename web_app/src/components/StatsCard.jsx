import React from 'react';
import { motion } from 'framer-motion';

const StatsCard = ({ title, value, icon: Icon, unit = "" }) => (
  <motion.div 
    initial={{ opacity: 0, y: 20 }}
    animate={{ opacity: 1, y: 0 }}
    whileHover={{ y: -5, scale: 1.02 }}
    className="stats-card"
  >
    <div className="stats-icon">
      <Icon size={24} />
    </div>
    <div className="stats-info">
      <h3>{title}</h3>
      <p>{value}{unit}</p>
    </div>
    <div className="silver-shimmer" />
  </motion.div>
);

export default StatsCard;
