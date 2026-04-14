'use client';

import { useState, useEffect } from 'react';
import { api } from '@/lib/axios';
import { Plus, Edit2, Trash2, X } from 'lucide-react';
import styles from '@/components/Shared.module.css';

interface Category {
  id: number;
  name: string;
}

export default function CategoriesPage() {
  const [categories, setCategories] = useState<Category[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  
  // Modal state
  const [showModal, setShowModal] = useState(false);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [categoryName, setCategoryName] = useState('');

  const fetchCategories = async () => {
    try {
      setIsLoading(true);
      const res = await api.get('/admin/categories');
      setCategories(res.data || []);
    } catch (err) {
      console.error('Failed to fetch categories', err);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchCategories();
  }, []);

  const openAddModal = () => {
    setEditingId(null);
    setCategoryName('');
    setShowModal(true);
  };

  const openEditModal = (cat: Category) => {
    setEditingId(cat.id);
    setCategoryName(cat.name);
    setShowModal(true);
  };

  const closeModal = () => {
    setShowModal(false);
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (editingId) {
        await api.put(`/admin/categories/${editingId}`, { name: categoryName });
      } else {
        await api.post('/admin/categories', { name: categoryName });
      }
      closeModal();
      fetchCategories();
    } catch (err) {
      console.error('Save failed', err);
    }
  };

  const handleDelete = async (id: number) => {
    if (!window.confirm('Are you sure you want to delete this category?')) return;
    try {
      await api.delete(`/admin/categories/${id}`);
      fetchCategories();
    } catch (err) {
      console.error('Delete failed', err);
    }
  };

  return (
    <div>
      <div className={styles.header}>
        <h1 className="page-title" style={{ marginBottom: 0 }}>Categories</h1>
        <button className="btn-primary" onClick={openAddModal}>
          <Plus size={18} /> Add Category
        </button>
      </div>

      <div className={`${styles.tableContainer} animate-slide-up`}>
        <table className={styles.table}>
          <thead>
            <tr>
              <th>ID</th>
              <th>Name</th>
              <th style={{ width: '120px' }}>Actions</th>
            </tr>
          </thead>
          <tbody>
            {isLoading ? (
              <tr key="loading">
                <td colSpan={3} style={{ textAlign: 'center', color: 'var(--text-tertiary)' }}>Loading...</td>
              </tr>
            ) : categories.length === 0 ? (
              <tr key="empty">
                <td colSpan={3} style={{ textAlign: 'center', color: 'var(--text-tertiary)' }}>No categories found.</td>
              </tr>
            ) : (
              categories.map(cat => (
                <tr key={cat.id}>
                  <td>{cat.id}</td>
                  <td>{cat.name}</td>
                  <td>
                    <div className={styles.actions}>
                      <button className={styles.iconBtn} onClick={() => openEditModal(cat)} title="Edit">
                        <Edit2 size={18} />
                      </button>
                      <button className={`${styles.iconBtn} ${styles.iconBtnDanger}`} onClick={() => handleDelete(cat.id)} title="Delete">
                        <Trash2 size={18} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {showModal && (
        <div className={styles.modalOverlay}>
          <div className={`${styles.modalContent} animate-slide-up`}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <h2 className={styles.modalTitle}>{editingId ? 'Edit Category' : 'New Category'}</h2>
              <button className={styles.iconBtn} onClick={closeModal}>
                <X size={20} />
              </button>
            </div>
            
            <form onSubmit={handleSave} style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
              <div>
                <label style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--text-secondary)', fontSize: '0.875rem' }}>Category Name</label>
                <input
                  type="text"
                  className="input-base"
                  value={categoryName}
                  onChange={e => setCategoryName(e.target.value)}
                  placeholder="e.g. Mathematics"
                  required
                />
              </div>
              
              <div className={styles.modalFooter}>
                <button type="button" className="btn-secondary" onClick={closeModal}>Cancel</button>
                <button type="submit" className="btn-primary">Save Category</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
