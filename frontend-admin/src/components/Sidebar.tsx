'use client';

import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { LayoutDashboard, LogOut, BookOpen, Layers, Users, HelpCircle } from 'lucide-react';
import styles from './Sidebar.module.css';
import { useEffect, useState } from 'react';

const MENU_ITEMS = [
  { name: 'Dashboard', path: '/', icon: LayoutDashboard },
  { name: 'Categories', path: '/categories', icon: Layers },
  { name: 'Lessons', path: '/lessons', icon: BookOpen },
  { name: 'Questions', path: '/questions', icon: HelpCircle },
  { name: 'Users', path: '/users', icon: Users },
];

export default function Sidebar({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  const isLogin = pathname === '/login';

  const handleLogout = () => {
    localStorage.removeItem('admin_token');
    router.push('/login');
  };

  if (!mounted) return null;

  if (isLogin) {
    return <main className={styles.container}>{children}</main>;
  }

  return (
    <div className={styles.container}>
      <aside className={styles.sidebar}>
        <div className={styles.logo}>
          <div className={styles.logoIcon}>
            <LayoutDashboard size={24} />
          </div>
          <span>Poydor Admin</span>
        </div>
        
        <nav className={styles.nav}>
          {MENU_ITEMS.map((item) => {
            const Icon = item.icon;
            const isActive = pathname === item.path || (item.path !== '/' && pathname.startsWith(item.path));
            
            return (
              <Link
                key={item.path}
                href={item.path}
                className={`${styles.navItem} ${isActive ? styles.navItemActive : ''}`}
              >
                <Icon size={20} />
                {item.name}
              </Link>
            );
          })}
        </nav>

        <button onClick={handleLogout} className={styles.logoutBtn}>
          <LogOut size={20} />
          Logout
        </button>
      </aside>
      <main className={styles.main}>
        <div className="animate-fade-in">
          {children}
        </div>
      </main>
    </div>
  );
}
