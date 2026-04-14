'use client';

import React, { useEffect, useState } from 'react';
import { api } from '@/lib/axios';
import { Users, Layers, BookOpen, HelpCircle } from 'lucide-react';
import styles from './page.module.css';

interface Stats {
  users: number;
  categories: number;
  lessons: number;
  questions: number;
}

export default function Home() {
  const [stats, setStats] = useState<Stats | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const [u, c, l, q] = await Promise.all([
          api.get('/admin/users'),
          api.get('/admin/categories'),
          api.get('/admin/lessons'),
          api.get('/admin/questions')
        ]);
        setStats({
          users: u.data?.length || 0,
          categories: c.data?.length || 0,
          lessons: l.data?.length || 0,
          questions: q.data?.length || 0
        });
      } catch (err) {
        console.error('Failed to fetch stats', err);
      } finally {
        setLoading(false);
      }
    };
    fetchStats();
  }, []);

  const statCards = [
    { label: 'Total Users', value: stats?.users ?? 0, icon: Users, color: '#5e6ad2' },
    { label: 'Categories', value: stats?.categories ?? 0, icon: Layers, color: '#198754' },
    { label: 'Lessons', value: stats?.lessons ?? 0, icon: BookOpen, color: '#ffc107' },
    { label: 'Questions', value: stats?.questions ?? 0, icon: HelpCircle, color: '#dc3545' },
  ];

  return (
    <div>
      <h1 className="page-title animate-slide-up">Dashboard Overview</h1>
      
      <div className={styles.statsGrid}>
        {statCards.map((card, i) => (
          <div 
            key={card.label} 
            className={`${styles.statCard} animate-slide-up`} 
            style={{ animationDelay: `${i * 0.1}s` }}
          >
            <div className={styles.statIcon} style={{ backgroundColor: `${card.color}20`, color: card.color }}>
              <card.icon size={24} />
            </div>
            <div className={styles.statInfo}>
              <span className={styles.statLabel}>{card.label}</span>
              <span className={styles.statValue}>{loading ? '...' : card.value}</span>
            </div>
          </div>
        ))}
      </div>

      <div className={`${styles.welcomeCard} animate-fade-in`}>
        <h2>Welcome back, Admin</h2>
        <p>
          Manage your educational content and monitor user activity from this central hub.
          Use the sidebar to navigate through different sections of the platform.
        </p>
      </div>
    </div>
  );
}
