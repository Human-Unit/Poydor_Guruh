import React from 'react';

export default function Home() {
  return (
    <div>
      <h1 className="page-title animate-slide-up">Dashboard</h1>
      <div className="animate-fade-in" style={{ backgroundColor: 'var(--bg-surface)', padding: '1.5rem', borderRadius: 'var(--radius-lg)' }}>
        <p style={{ color: 'var(--text-secondary)' }}>
          Welcome to the Poydor Admin Dashboard. Select an entity from the sidebar to start managing data.
        </p>
      </div>
    </div>
  );
}
