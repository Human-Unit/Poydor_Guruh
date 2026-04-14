'use client';

import { useState, useEffect } from 'react';
import { api } from '@/lib/axios';
import styles from '@/components/Shared.module.css';

interface User {
  ID: number;
  name: string;
  username: string;
  email: string;
  role: string;
  CreatedAt: string;
}

export default function UsersPage() {
  const [users, setUsers] = useState<User[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  const fetchUsers = async () => {
    try {
      setIsLoading(true);
      const res = await api.get('/admin/users');
      setUsers(res.data || []);
    } catch (err) {
      console.error('Failed to fetch users', err);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  return (
    <div>
      <div className={styles.header}>
        <h1 className="page-title" style={{ marginBottom: 0 }}>Registered Users</h1>
      </div>

      <div className={`${styles.tableContainer} animate-slide-up`}>
        <table className={styles.table}>
          <thead>
            <tr>
              <th>ID</th>
              <th>Name</th>
              <th>Username</th>
              <th>Email</th>
              <th>Role</th>
              <th>Joined Date</th>
            </tr>
          </thead>
          <tbody>
            {isLoading ? (
              <tr>
                <td colSpan={6} style={{ textAlign: 'center', color: 'var(--text-tertiary)' }}>Loading...</td>
              </tr>
            ) : users.length === 0 ? (
              <tr>
                <td colSpan={6} style={{ textAlign: 'center', color: 'var(--text-tertiary)' }}>No users found.</td>
              </tr>
            ) : (
              users.map(user => (
                <tr key={user.ID}>
                  <td>{user.ID}</td>
                  <td>{user.name}</td>
                  <td>{user.username}</td>
                  <td>{user.email}</td>
                  <td>
                    <span style={{ 
                      padding: '0.25rem 0.5rem', 
                      borderRadius: 'var(--radius-sm)', 
                      fontSize: '0.75rem',
                      backgroundColor: user.role === 'admin' ? 'rgba(94, 106, 210, 0.2)' : 'rgba(255,255,255,0.1)',
                      color: user.role === 'admin' ? 'var(--accent-hover)' : 'var(--text-secondary)'
                    }}>
                      {user.role}
                    </span>
                  </td>
                  <td>{new Date(user.CreatedAt).toLocaleDateString()}</td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
