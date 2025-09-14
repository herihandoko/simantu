const express = require('express')
const db = require('../config/database')
const { authenticateToken } = require('../middleware/auth')

const router = express.Router()

// Helper function to format date for MySQL
const formatDateForMySQL = (dateString) => {
  if (!dateString) return null
  return new Date(dateString).toISOString().split('T')[0] // Convert to YYYY-MM-DD format
}

// Get all OPD
router.get('/opd', authenticateToken, async (req, res) => {
  try {
    const [opd] = await db.execute('SELECT * FROM opd ORDER BY nama_opd')
    res.json(opd)
  } catch (error) {
    console.error('Get OPD error:', error)
    res.status(500).json({ message: 'Server error', error: error.message })
  }
})

// Get all Tenaga Ahli (from users table with role 'Tenaga Ahli')
router.get('/tenaga-ahli', authenticateToken, async (req, res) => {
  try {
    const [tenagaAhli] = await db.execute(`
      SELECT u.id, u.name, u.email, r.name as role_name
      FROM users u 
      JOIN roles r ON u.role_id = r.id 
      WHERE r.name = 'Tenaga Ahli'
      ORDER BY u.name
    `)
    res.json(tenagaAhli)
  } catch (error) {
    console.error('Get Tenaga Ahli error:', error)
    res.status(500).json({ message: 'Server error', error: error.message })
  }
})

// Get all tasks
router.get('/', authenticateToken, async (req, res) => {
  try {
    const [tasks] = await db.execute(`
      SELECT t.*, 
             u1.name as assigned_to_name, 
             u2.name as created_by_name,
             o.nama_opd,
             o.kode_opd,
             u3.name as tenaga_ahli_nama,
             u3.email as tenaga_ahli_email
      FROM tasks t 
      LEFT JOIN users u1 ON t.assigned_to = u1.id 
      LEFT JOIN users u2 ON t.created_by = u2.id
      LEFT JOIN opd o ON t.opd_id = o.id
      LEFT JOIN users u3 ON t.tenaga_ahli_id = u3.id
      ORDER BY t.created_at DESC
    `)
    res.json(tasks)
  } catch (error) {
    console.error('Get tasks error:', error)
    res.status(500).json({ message: 'Server error', error: error.message })
  }
})

// Get task by ID
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const [tasks] = await db.execute(`
      SELECT t.*, 
             u1.name as assigned_to_name, 
             u2.name as created_by_name
      FROM tasks t 
      LEFT JOIN users u1 ON t.assigned_to = u1.id 
      LEFT JOIN users u2 ON t.created_by = u2.id
      WHERE t.id = ?
    `, [req.params.id])
    
    if (tasks.length === 0) {
      return res.status(404).json({ message: 'Task not found' })
    }
    
    res.json(tasks[0])
  } catch (error) {
    console.error('Get task error:', error)
    res.status(500).json({ message: 'Server error', error: error.message })
  }
})

// Create new task
router.post('/', authenticateToken, async (req, res) => {
  try {
    const { 
      nama_pekerjaan, 
      status, 
      tugas, 
      uraian_tugas, 
      prioritas, 
      opd_id, 
      tenaga_ahli_id, 
      tanggal_selesai,
      estimasi_durasi,
      progress_percentage,
      tags,
      estimated_hours,
      start_date,
      milestone,
      risk_level,
      complexity
    } = req.body
    
    if (!nama_pekerjaan) {
      return res.status(400).json({ message: 'Nama Pekerjaan is required' })
    }
    
    // Generate task_id with auto-increment
    const [countResult] = await db.execute('SELECT COUNT(*) as count FROM tasks')
    const taskId = `TASK-${String(countResult[0].count + 1).padStart(4, '0')}`
    
    const [result] = await db.execute(`
      INSERT INTO tasks (
        task_id, title, nama_pekerjaan, status, tugas, uraian_tugas, 
        priority, opd_id, tenaga_ahli_id, tanggal_selesai, created_by,
        estimasi_durasi, progress_percentage, tags, estimated_hours,
        start_date, milestone, risk_level, complexity
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `, [
      taskId, nama_pekerjaan, nama_pekerjaan, status || 'pending', tugas, uraian_tugas,
      prioritas || 'medium', opd_id, tenaga_ahli_id, formatDateForMySQL(tanggal_selesai), req.user.id,
      estimasi_durasi, progress_percentage || 0, JSON.stringify(tags), estimated_hours,
      formatDateForMySQL(start_date), milestone, risk_level || 'low', complexity || 'moderate'
    ])
    
    const [newTask] = await db.execute(`
      SELECT t.*, 
             u1.name as assigned_to_name, 
             u2.name as created_by_name,
             o.nama_opd,
             o.kode_opd,
             u3.name as tenaga_ahli_nama,
             u3.email as tenaga_ahli_email
      FROM tasks t 
      LEFT JOIN users u1 ON t.assigned_to = u1.id 
      LEFT JOIN users u2 ON t.created_by = u2.id
      LEFT JOIN opd o ON t.opd_id = o.id
      LEFT JOIN users u3 ON t.tenaga_ahli_id = u3.id
      WHERE t.id = ?
    `, [result.insertId])
    
    res.status(201).json(newTask[0])
  } catch (error) {
    console.error('Create task error:', error)
    res.status(500).json({ message: 'Server error', error: error.message })
  }
})

// Update task
router.put('/:id', authenticateToken, async (req, res) => {
  try {
    const { 
      nama_pekerjaan, 
      status, 
      tugas, 
      uraian_tugas, 
      prioritas, 
      opd_id, 
      tenaga_ahli_id, 
      tanggal_selesai,
      estimasi_durasi,
      progress_percentage,
      tags,
      estimated_hours,
      start_date,
      milestone,
      risk_level,
      complexity
    } = req.body
    
    if (!nama_pekerjaan) {
      return res.status(400).json({ message: 'Nama Pekerjaan is required' })
    }
    
    const [result] = await db.execute(`
      UPDATE tasks 
      SET nama_pekerjaan = ?, status = ?, tugas = ?, uraian_tugas = ?, 
          priority = ?, opd_id = ?, tenaga_ahli_id = ?, tanggal_selesai = ?, 
          estimasi_durasi = ?, progress_percentage = ?, tags = ?, estimated_hours = ?,
          start_date = ?, milestone = ?, risk_level = ?, complexity = ?,
          updated_at = CURRENT_TIMESTAMP
      WHERE id = ?
    `, [nama_pekerjaan, status, tugas, uraian_tugas, prioritas, opd_id, tenaga_ahli_id, formatDateForMySQL(tanggal_selesai),
        estimasi_durasi, progress_percentage, JSON.stringify(tags), estimated_hours,
        formatDateForMySQL(start_date), milestone, risk_level, complexity, req.params.id])
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Task not found' })
    }
    
    // If status is completed, set completed_at
    if (status === 'completed') {
      await db.execute(`
        UPDATE tasks 
        SET completed_at = CURRENT_TIMESTAMP 
        WHERE id = ?
      `, [req.params.id])
    } else {
      await db.execute(`
        UPDATE tasks 
        SET completed_at = NULL 
        WHERE id = ?
      `, [req.params.id])
    }
    
    const [updatedTask] = await db.execute(`
      SELECT t.*, 
             u1.name as assigned_to_name, 
             u2.name as created_by_name,
             o.nama_opd,
             o.kode_opd,
             u3.name as tenaga_ahli_nama,
             u3.email as tenaga_ahli_email
      FROM tasks t 
      LEFT JOIN users u1 ON t.assigned_to = u1.id 
      LEFT JOIN users u2 ON t.created_by = u2.id
      LEFT JOIN opd o ON t.opd_id = o.id
      LEFT JOIN users u3 ON t.tenaga_ahli_id = u3.id
      WHERE t.id = ?
    `, [req.params.id])
    
    res.json(updatedTask[0])
  } catch (error) {
    console.error('Update task error:', error)
    res.status(500).json({ message: 'Server error', error: error.message })
  }
})

// Delete task
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const [result] = await db.execute('DELETE FROM tasks WHERE id = ?', [req.params.id])
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Task not found' })
    }
    
    res.json({ message: 'Task deleted successfully' })
  } catch (error) {
    console.error('Delete task error:', error)
    res.status(500).json({ message: 'Server error', error: error.message })
  }
})

// Add comment to task
router.post('/:id/comments', authenticateToken, async (req, res) => {
  try {
    const { comment } = req.body
    
    if (!comment) {
      return res.status(400).json({ message: 'Comment is required' })
    }
    
    const [result] = await db.execute(`
      INSERT INTO task_comments (task_id, user_id, comment)
      VALUES (?, ?, ?)
    `, [req.params.id, req.user.id, comment])
    
    const [newComment] = await db.execute(`
      SELECT tc.*, u.name as user_name, u.email as user_email
      FROM task_comments tc
      JOIN users u ON tc.user_id = u.id
      WHERE tc.id = ?
    `, [result.insertId])
    
    res.status(201).json(newComment[0])
  } catch (error) {
    console.error('Add comment error:', error)
    res.status(500).json({ message: 'Server error', error: error.message })
  }
})

// Get task comments
router.get('/:id/comments', authenticateToken, async (req, res) => {
  try {
    const [comments] = await db.execute(`
      SELECT tc.*, u.name as user_name, u.email as user_email
      FROM task_comments tc
      JOIN users u ON tc.user_id = u.id
      WHERE tc.task_id = ?
      ORDER BY tc.created_at ASC
    `, [req.params.id])
    
    res.json(comments)
  } catch (error) {
    console.error('Get comments error:', error)
    res.status(500).json({ message: 'Server error', error: error.message })
  }
})

// Update task progress
router.patch('/:id/progress', authenticateToken, async (req, res) => {
  try {
    const { progress_percentage } = req.body
    
    if (progress_percentage < 0 || progress_percentage > 100) {
      return res.status(400).json({ message: 'Progress must be between 0 and 100' })
    }
    
    const [result] = await db.execute(`
      UPDATE tasks 
      SET progress_percentage = ?, updated_at = CURRENT_TIMESTAMP
      WHERE id = ?
    `, [progress_percentage, req.params.id])
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Task not found' })
    }
    
    // Log the progress update
    await db.execute(`
      INSERT INTO task_history (task_id, user_id, action, new_value)
      VALUES (?, ?, 'progress_update', ?)
    `, [req.params.id, req.user.id, JSON.stringify({ progress_percentage })])
    
    res.json({ message: 'Progress updated successfully' })
  } catch (error) {
    console.error('Update progress error:', error)
    res.status(500).json({ message: 'Server error', error: error.message })
  }
})

// Get task analytics
router.get('/analytics/overview', authenticateToken, async (req, res) => {
  try {
    const [stats] = await db.execute(`
      SELECT 
        COUNT(*) as total_tasks,
        SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending_tasks,
        SUM(CASE WHEN status = 'in_progress' THEN 1 ELSE 0 END) as in_progress_tasks,
        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed_tasks,
        SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) as cancelled_tasks,
        SUM(CASE WHEN due_date < CURDATE() AND status != 'completed' THEN 1 ELSE 0 END) as overdue_tasks
      FROM tasks
    `)
    
    const [priorityStats] = await db.execute(`
      SELECT 
        priority,
        COUNT(*) as count
      FROM tasks
      GROUP BY priority
    `)
    
    const [opdStats] = await db.execute(`
      SELECT 
        o.nama_opd,
        COUNT(t.id) as task_count,
        AVG(t.progress_percentage) as avg_progress
      FROM opd o
      LEFT JOIN tasks t ON o.id = t.opd_id
      GROUP BY o.id, o.nama_opd
      ORDER BY task_count DESC
    `)
    
    // Get expert performance data
    const [expertStats] = await db.execute(`
      SELECT 
        u.id,
        u.name,
        u.email,
        COUNT(t.id) as task_count,
        AVG(t.progress_percentage) as avg_progress
      FROM users u
      LEFT JOIN tasks t ON u.id = t.tenaga_ahli_id
      WHERE u.role_id = (SELECT id FROM roles WHERE name = 'Tenaga Ahli')
      GROUP BY u.id, u.name, u.email
      HAVING task_count > 0
      ORDER BY avg_progress DESC
    `)
    
    // Get upcoming deadlines (next 7 days)
    const [upcomingDeadlines] = await db.execute(`
      SELECT 
        t.id,
        t.nama_pekerjaan,
        t.tanggal_selesai,
        t.progress_percentage,
        u.name as tenaga_ahli_nama
      FROM tasks t
      LEFT JOIN users u ON t.tenaga_ahli_id = u.id
      WHERE t.tanggal_selesai BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
        AND t.status NOT IN ('completed', 'cancelled')
      ORDER BY t.tanggal_selesai ASC
      LIMIT 10
    `)
    
    res.json({
      overview: stats[0],
      priorityBreakdown: priorityStats,
      opdBreakdown: opdStats,
      expertPerformance: expertStats,
      upcomingDeadlines: upcomingDeadlines
    })
  } catch (error) {
    console.error('Get analytics error:', error)
    res.status(500).json({ message: 'Server error', error: error.message })
  }
})

// Get user-specific analytics (for tenaga ahli)
router.get('/analytics/user/:userId', authenticateToken, async (req, res) => {
  try {
    const userId = req.params.userId
    
    const [userStats] = await db.execute(`
      SELECT 
        COUNT(*) as total_assigned_tasks,
        SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending_tasks,
        SUM(CASE WHEN status = 'in_progress' THEN 1 ELSE 0 END) as in_progress_tasks,
        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed_tasks,
        AVG(progress_percentage) as avg_progress,
        SUM(CASE WHEN tanggal_selesai < CURDATE() AND status != 'completed' THEN 1 ELSE 0 END) as overdue_tasks,
        SUM(estimated_hours) as total_estimated_hours,
        SUM(actual_hours) as total_actual_hours
      FROM tasks
      WHERE tenaga_ahli_id = ?
    `, [userId])
    
    const [recentTasks] = await db.execute(`
      SELECT t.*, o.nama_opd, o.kode_opd
      FROM tasks t
      LEFT JOIN opd o ON t.opd_id = o.id
      WHERE t.tenaga_ahli_id = ?
      ORDER BY t.updated_at DESC
      LIMIT 10
    `, [userId])
    
    res.json({
      userStats: userStats[0],
      recentTasks
    })
  } catch (error) {
    console.error('Get user analytics error:', error)
    res.status(500).json({ message: 'Server error', error: error.message })
  }
})

// Export tasks to Excel
router.get('/export/excel', authenticateToken, async (req, res) => {
  try {
    const [tasks] = await db.execute(`
      SELECT t.*, 
             u1.name as assigned_to_name, 
             u2.name as created_by_name,
             o.nama_opd,
             o.kode_opd,
             u3.name as tenaga_ahli_nama,
             u3.email as tenaga_ahli_email
      FROM tasks t 
      LEFT JOIN users u1 ON t.assigned_to = u1.id 
      LEFT JOIN users u2 ON t.created_by = u2.id
      LEFT JOIN opd o ON t.opd_id = o.id
      LEFT JOIN users u3 ON t.tenaga_ahli_id = u3.id
      ORDER BY t.created_at DESC
    `)

    // Simple CSV export (can be enhanced with proper Excel library)
    const csvHeader = 'ID Tugas,Nama Pekerjaan,Status,Progress,Prioritas,OPD,Tenaga Ahli,Durasi Estimasi,Tanggal Mulai,Tanggal Selesai,Budget,Risk Level,Complexity,Created At\n'
    
    const csvData = tasks.map(task => {
      return [
        task.task_id || `TASK-${task.id}`,
        `"${task.nama_pekerjaan || task.tugas || ''}"`,
        task.status,
        task.progress_percentage || 0,
        task.prioritas || task.priority || 'medium',
        `"${task.nama_opd || ''}"`,
        `"${task.tenaga_ahli_nama || ''}"`,
        task.estimasi_durasi || '',
        task.start_date || '',
        task.tanggal_selesai || task.due_date || '',
        task.budget || '',
        task.risk_level || 'low',
        task.complexity || 'moderate',
        task.created_at
      ].join(',')
    }).join('\n')

    const csvContent = csvHeader + csvData

    res.setHeader('Content-Type', 'text/csv')
    res.setHeader('Content-Disposition', 'attachment; filename="tasks_export.csv"')
    res.send(csvContent)
  } catch (error) {
    console.error('Export Excel error:', error)
    res.status(500).json({ message: 'Server error', error: error.message })
  }
})

// Export user tasks to Excel
router.get('/export/user/:userId/excel', authenticateToken, async (req, res) => {
  try {
    const userId = req.params.userId
    
    const [tasks] = await db.execute(`
      SELECT t.*, 
             u1.name as assigned_to_name, 
             u2.name as created_by_name,
             o.nama_opd,
             o.kode_opd,
             u3.name as tenaga_ahli_nama,
             u3.email as tenaga_ahli_email
      FROM tasks t 
      LEFT JOIN users u1 ON t.assigned_to = u1.id 
      LEFT JOIN users u2 ON t.created_by = u2.id
      LEFT JOIN opd o ON t.opd_id = o.id
      LEFT JOIN users u3 ON t.tenaga_ahli_id = u3.id
      WHERE t.tenaga_ahli_id = ?
      ORDER BY t.created_at DESC
    `, [userId])

    // Get user info
    const [users] = await db.execute('SELECT name, email FROM users WHERE id = ?', [userId])
    const user = users[0]

    // Simple CSV export
    const csvHeader = 'ID Tugas,Nama Pekerjaan,Status,Progress,Prioritas,OPD,Durasi Estimasi,Tanggal Mulai,Tanggal Selesai,Budget,Risk Level,Complexity,Created At\n'
    
    const csvData = tasks.map(task => {
      return [
        task.task_id || `TASK-${task.id}`,
        `"${task.nama_pekerjaan || task.tugas || ''}"`,
        task.status,
        task.progress_percentage || 0,
        task.prioritas || task.priority || 'medium',
        `"${task.nama_opd || ''}"`,
        task.estimasi_durasi || '',
        task.start_date || '',
        task.tanggal_selesai || task.due_date || '',
        task.budget || '',
        task.risk_level || 'low',
        task.complexity || 'moderate',
        task.created_at
      ].join(',')
    }).join('\n')

    const csvContent = csvHeader + csvData

    res.setHeader('Content-Type', 'text/csv')
    res.setHeader('Content-Disposition', `attachment; filename="tasks_${user?.name?.replace(/\s+/g, '_') || 'user'}_export.csv"`)
    res.send(csvContent)
  } catch (error) {
    console.error('Export user Excel error:', error)
    res.status(500).json({ message: 'Server error', error: error.message })
  }
})

// Get performance metrics
router.get('/metrics/performance', authenticateToken, async (req, res) => {
  try {
    const [metrics] = await db.execute(`
      SELECT 
        COUNT(*) as total_tasks,
        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed_tasks,
        SUM(CASE WHEN status = 'in_progress' THEN 1 ELSE 0 END) as in_progress_tasks,
        SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending_tasks,
        SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) as cancelled_tasks,
        AVG(progress_percentage) as avg_progress,
        SUM(CASE WHEN tanggal_selesai < CURDATE() AND status != 'completed' THEN 1 ELSE 0 END) as overdue_tasks,
        SUM(estimated_hours) as total_estimated_hours,
        SUM(actual_hours) as total_actual_hours,
        SUM(budget) as total_budget,
        SUM(actual_cost) as total_actual_cost
      FROM tasks
    `)

    const [userMetrics] = await db.execute(`
      SELECT 
        u.id,
        u.name,
        u.email,
        COUNT(t.id) as total_tasks,
        SUM(CASE WHEN t.status = 'completed' THEN 1 ELSE 0 END) as completed_tasks,
        AVG(t.progress_percentage) as avg_progress,
        SUM(t.estimated_hours) as total_estimated_hours,
        SUM(t.actual_hours) as total_actual_hours
      FROM users u
      LEFT JOIN tasks t ON u.id = t.tenaga_ahli_id
      WHERE u.role_id IN (SELECT id FROM roles WHERE name = 'Tenaga Ahli')
      GROUP BY u.id, u.name, u.email
      ORDER BY completed_tasks DESC
    `)

    const [opdMetrics] = await db.execute(`
      SELECT 
        o.id,
        o.nama_opd,
        o.kode_opd,
        COUNT(t.id) as total_tasks,
        SUM(CASE WHEN t.status = 'completed' THEN 1 ELSE 0 END) as completed_tasks,
        AVG(t.progress_percentage) as avg_progress,
        SUM(t.budget) as total_budget
      FROM opd o
      LEFT JOIN tasks t ON o.id = t.opd_id
      GROUP BY o.id, o.nama_opd, o.kode_opd
      ORDER BY total_tasks DESC
    `)

    res.json({
      overview: metrics[0],
      userPerformance: userMetrics,
      opdPerformance: opdMetrics
    })
  } catch (error) {
    console.error('Get performance metrics error:', error)
    res.status(500).json({ message: 'Server error', error: error.message })
  }
})

module.exports = router
