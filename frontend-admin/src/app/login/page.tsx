'use client';

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import { api } from '@/lib/axios';
import styles from './page.module.css';

export default function LoginPage() {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const router = useRouter();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      // The Go backend /users/login returns a token
      const res = await api.post('/users/login', {
        email: username,
        username,
        password,
      });

      // Usually it returns { token: "..." }
      if (res.data.token) {
        localStorage.setItem('admin_token', res.data.token);
        
        // Let's also check if they are an admin.
        // For security, true role verification should be done server-side on every request.
        // We'll proceed to the dashboard. If they lack admin role, the API calls will just 403/401.
        router.push('/');
      } else {
        setError('Login failed, no token received');
      }
    } catch (err) {
      const axiosError = err as { response?: { data?: { error?: string } } };
      setError(axiosError.response?.data?.error || 'Invalid credentials');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className={styles.container}>
      <div className={`${styles.loginCard} animate-slide-up`}>
        <h1 className={styles.title}>Admin Login</h1>
        
        <form onSubmit={handleLogin} className={styles.form}>
          {error && <div className={styles.error}>{error}</div>}
          
          <div className={styles.formGroup}>
            <label className={styles.label}>Username</label>
            <input
              type="text"
              className="input-base"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              placeholder="admin123"
              required
            />
          </div>

          <div className={styles.formGroup}>
            <label className={styles.label}>Password</label>
            <input
              type="password"
              className="input-base"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="••••••••"
              required
            />
          </div>

          <button type="submit" className={`btn-primary ${styles.btnFull}`} disabled={loading}>
            {loading ? 'Logging in...' : 'Sign In'}
          </button>
        </form>
      </div>
    </div>
  );
}
