'use client';

import { useState, useEffect } from 'react';
import { api } from '@/lib/axios';
import { Plus, Edit2, Trash2, X } from 'lucide-react';
import styles from '@/components/Shared.module.css';

interface Lesson {
  ID: number;
  Name: string;
}

interface Question {
  ID: number;
  Text: string;
  OptionA: string;
  OptionB: string;
  OptionC: string;
  OptionD: string;
  CorrectAnswer: number;
  LessonID: number;
  Lesson: Lesson;
}

export default function QuestionsPage() {
  const [questions, setQuestions] = useState<Question[]>([]);
  const [lessons, setLessons] = useState<Lesson[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  
  // Modal state
  const [showModal, setShowModal] = useState(false);
  const [editingId, setEditingId] = useState<number | null>(null);
  
  // Form state
  const [lessonId, setLessonId] = useState<number | ''>('');
  const [text, setText] = useState('');
  const [optA, setOptA] = useState('');
  const [optB, setOptB] = useState('');
  const [optC, setOptC] = useState('');
  const [optD, setOptD] = useState('');
  const [correct, setCorrect] = useState<number>(0);

  const fetchData = async () => {
    try {
      setIsLoading(true);
      // Backend didn't explicitly expose GET /admin/questions. 
      // But we can get lessons and maybe questions are fetched via lessons or another endpoint.
      // Wait, let's assume there is GET /admin/questions or we fetch them all if not.
      // Looking at routes, admin has: admin.POST, admin.PUT, admin.DELETE for questions. 
      // There is NO admin.GET("/questions"). ONLY GET /lessons/:id/questions as user route!
      // This is an issue with the backend. 
      // Wait! The user said "где реализованы все функции вязтые с endpoint-ов". 
      // Admin doesn't have a GET all questions endpoint. We will have to fetch them via lessons if needed, or if there's no endpoint, we can't display a global list easily unless we iterate lessons.
      // Let's fetch all lessons, then fetch questions for each lesson, and flatten them into one list.
      const res = await api.get('/admin/lessons');
      const fetchedLessons: Lesson[] = res.data || [];
      setLessons(fetchedLessons);

      const allQs: Question[] = [];
      for (const t of fetchedLessons) {
        try {
          const qRes = await api.get(`/users/lessons/${t.ID}/questions`);
          const qs = qRes.data || [];
          qs.forEach((q: any) => allQs.push({...q, Lesson: t}));
        } catch (e) {
          // Ignore if 404 or empty
        }
      }
      setQuestions(allQs);
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
    setLessonId(lessons.length > 0 ? lessons[0].ID : '');
    setText('');
    setOptA(''); setOptB(''); setOptC(''); setOptD('');
    setCorrect(0);
    setShowModal(true);
  };

  const openEditModal = (q: Question) => {
    setEditingId(q.ID);
    setLessonId(q.LessonID);
    setText(q.Text);
    setOptA(q.OptionA); setOptB(q.OptionB); setOptC(q.OptionC); setOptD(q.OptionD);
    setCorrect(q.CorrectAnswer);
    setShowModal(true);
  };

  const closeModal = () => {
    setShowModal(false);
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!lessonId) return;
    
    const payload = {
      lesson_id: lessonId,
      text,
      option_a: optA,
      option_b: optB,
      option_c: optC,
      option_d: optD,
      correct_answer: correct
    };

    try {
      if (editingId) {
        await api.put(`/admin/questions/${editingId}`, payload);
      } else {
        await api.post('/admin/questions', payload);
      }
      closeModal();
      fetchData();
    } catch (err) {
      console.error('Save failed', err);
    }
  };

  const handleDelete = async (id: number) => {
    if (!window.confirm('Are you sure you want to delete this question?')) return;
    try {
      await api.delete(`/admin/questions/${id}`);
      fetchData();
    } catch (err) {
      console.error('Delete failed', err);
    }
  };

  return (
    <div>
      <div className={styles.header}>
        <h1 className="page-title" style={{ marginBottom: 0 }}>Questions</h1>
        <button className="btn-primary" onClick={openAddModal}>
          <Plus size={18} /> Add Question
        </button>
      </div>

      <div className={`${styles.tableContainer} animate-slide-up`}>
        <table className={styles.table}>
          <thead>
            <tr>
              <th>ID</th>
              <th>Question Text</th>
              <th>Lesson</th>
              <th style={{ width: '120px' }}>Actions</th>
            </tr>
          </thead>
          <tbody>
            {isLoading ? (
              <tr>
                <td colSpan={4} style={{ textAlign: 'center', color: 'var(--text-tertiary)' }}>Loading...</td>
              </tr>
            ) : questions.length === 0 ? (
              <tr>
                <td colSpan={4} style={{ textAlign: 'center', color: 'var(--text-tertiary)' }}>No questions found.</td>
              </tr>
            ) : (
              questions.map(q => (
                <tr key={q.ID}>
                  <td>{q.ID}</td>
                  <td style={{ maxWidth: 300, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{q.Text}</td>
                  <td>{q.Lesson?.Name || 'Unknown'}</td>
                  <td>
                    <div className={styles.actions}>
                      <button className={styles.iconBtn} onClick={() => openEditModal(q)} title="Edit">
                        <Edit2 size={18} />
                      </button>
                      <button className={`${styles.iconBtn} ${styles.iconBtnDanger}`} onClick={() => handleDelete(q.ID)} title="Delete">
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
          <div className={`${styles.modalContent} animate-slide-up`} style={{ maxWidth: 600 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <h2 className={styles.modalTitle}>{editingId ? 'Edit Question' : 'New Question'}</h2>
              <button className={styles.iconBtn} onClick={closeModal}>
                <X size={20} />
              </button>
            </div>
            
            <form onSubmit={handleSave} style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
              <div className={styles.formGroup}>
                <label className={styles.label}>Lesson</label>
                <select 
                  className={styles.selectBase}
                  value={lessonId} 
                  onChange={e => setLessonId(Number(e.target.value))} 
                  required
                >
                  <option value="" disabled>Select a lesson</option>
                  {lessons.map(les => (
                    <option key={les.ID} value={les.ID}>{les.Name}</option>
                  ))}
                </select>
              </div>

              <div className={styles.formGroup}>
                <label className={styles.label}>Question Text</label>
                <textarea
                  className="input-base"
                  value={text}
                  onChange={e => setText(e.target.value)}
                  placeholder="What is 2+2?"
                  rows={2}
                  required
                />
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
                <div className={styles.formGroup}>
                  <label className={styles.label}>Option A</label>
                  <input type="text" className="input-base" value={optA} onChange={e => setOptA(e.target.value)} required />
                </div>
                <div className={styles.formGroup}>
                  <label className={styles.label}>Option B</label>
                  <input type="text" className="input-base" value={optB} onChange={e => setOptB(e.target.value)} required />
                </div>
                <div className={styles.formGroup}>
                  <label className={styles.label}>Option C</label>
                  <input type="text" className="input-base" value={optC} onChange={e => setOptC(e.target.value)} required />
                </div>
                <div className={styles.formGroup}>
                  <label className={styles.label}>Option D</label>
                  <input type="text" className="input-base" value={optD} onChange={e => setOptD(e.target.value)} required />
                </div>
              </div>

              <div className={styles.formGroup}>
                <label className={styles.label}>Correct Answer Index</label>
                <select 
                  className={styles.selectBase}
                  value={correct} 
                  onChange={e => setCorrect(Number(e.target.value))} 
                  required
                >
                  <option value={0}>Option A</option>
                  <option value={1}>Option B</option>
                  <option value={2}>Option C</option>
                  <option value={3}>Option D</option>
                </select>
              </div>
              
              <div className={styles.modalFooter}>
                <button type="button" className="btn-secondary" onClick={closeModal}>Cancel</button>
                <button type="submit" className="btn-primary">Save Question</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
