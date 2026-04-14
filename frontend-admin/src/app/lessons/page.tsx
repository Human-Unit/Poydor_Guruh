'use client';

import { useState, useEffect } from 'react';
import { api } from '@/lib/axios';
import { Plus, Edit2, Trash2, X } from 'lucide-react';
import styles from '@/components/Shared.module.css';

interface Category {
  id: number;
  name: string;
}

interface Lesson {
  id: number;
  name: string;
  category_id: number;
  category: Category;
}

export default function LessonsPage() {
  const [lessons, setLessons] = useState<Lesson[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  
  // Modal state
  const [showModal, setShowModal] = useState(false);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [lessonName, setLessonName] = useState('');
  const [categoryId, setCategoryId] = useState<number | ''>('');

  const fetchData = async () => {
    try {
      setIsLoading(true);
      const [lessRes, catRes] = await Promise.all([
        api.get('/admin/lessons'),
        api.get('/admin/categories')
      ]);
      setLessons(lessRes.data || []);
      setCategories(catRes.data || []);
    } catch (err) {
      console.error('Failed to fetch data', err);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const openAddModal = () => {
    setEditingId(null);
    setLessonName('');
    setCategoryId(categories.length > 0 ? categories[0].id : '');
    setShowModal(true);
  };

  const openEditModal = (lesson: Lesson) => {
    setEditingId(lesson.id);
    setLessonName(lesson.name);
    setCategoryId(lesson.category_id);
    setShowModal(true);
  };

  const closeModal = () => {
    setShowModal(false);
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!categoryId) return;
    try {
      if (editingId) {
        await api.put(`/admin/lessons/${editingId}`, { name: lessonName, category_id: categoryId });
      } else {
        await api.post('/admin/lessons', { name: lessonName, category_id: categoryId });
      }
      closeModal();
      fetchData();
    } catch (err) {
      console.error('Save failed', err);
    }
  };

  const handleDelete = async (id: number) => {
    if (!window.confirm('Are you sure you want to delete this lesson?')) return;
    try {
      await api.delete(`/admin/lessons/${id}`);
      fetchData();
    } catch (err) {
      console.error('Delete failed', err);
    }
  };

  return (
    <div>
      <div className={styles.header}>
        <h1 className="page-title" style={{ marginBottom: 0 }}>Lessons</h1>
        <button className="btn-primary" onClick={openAddModal}>
          <Plus size={18} /> Add Lesson
        </button>
      </div>

      <div className={`${styles.tableContainer} animate-slide-up`}>
        <table className={styles.table}>
          <thead>
            <tr>
              <th>ID</th>
              <th>Name</th>
              <th>Category</th>
              <th style={{ width: '120px' }}>Actions</th>
            </tr>
          </thead>
          <tbody>
            {isLoading ? (
              <tr key="loading">
                <td colSpan={4} style={{ textAlign: 'center', color: 'var(--text-tertiary)' }}>Loading...</td>
              </tr>
            ) : lessons.length === 0 ? (
              <tr key="empty">
                <td colSpan={4} style={{ textAlign: 'center', color: 'var(--text-tertiary)' }}>No lessons found.</td>
              </tr>
            ) : (
              lessons.map(les => (
                <tr key={les.id}>
                  <td>{les.id}</td>
                  <td>{les.name}</td>
                  <td>{les.category?.name || 'Unknown'}</td>
                  <td>
                    <div className={styles.actions}>
                      <button className={styles.iconBtn} onClick={() => openEditModal(les)} title="Edit">
                        <Edit2 size={18} />
                      </button>
                      <button className={`${styles.iconBtn} ${styles.iconBtnDanger}`} onClick={() => handleDelete(les.id)} title="Delete">
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
              <h2 className={styles.modalTitle}>{editingId ? 'Edit Lesson' : 'New Lesson'}</h2>
              <button className={styles.iconBtn} onClick={closeModal}>
                <X size={20} />
              </button>
            </div>
            
            <form onSubmit={handleSave} style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
              <div className={styles.formGroup}>
                <label className={styles.label}>Lesson Name</label>
                <input
                  type="text"
                  className="input-base"
                  value={lessonName}
                  onChange={e => setLessonName(e.target.value)}
                  placeholder="e.g. Algebra Basics"
                  required
                />
              </div>

              <div className={styles.formGroup}>
                <label className={styles.label}>Category</label>
                <select 
                  className={styles.selectBase}
                  value={categoryId} 
                  onChange={e => setCategoryId(Number(e.target.value))} 
                  required
                >
                  <option value="" disabled>Select a category</option>
                  {categories.map(cat => (
                    <option key={cat.id} value={cat.id}>{cat.name}</option>
                  ))}
                </select>
              </div>
              
              <div className={styles.modalFooter}>
                <button type="button" className="btn-secondary" onClick={closeModal}>Cancel</button>
                <button type="submit" className="btn-primary">Save Lesson</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
