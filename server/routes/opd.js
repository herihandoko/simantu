const express = require('express')
const db = require('../config/database')
const { authenticateToken } = require('../middleware/auth')

const router = express.Router()

// Get all OPD
router.get('/', authenticateToken, async (req, res) => {
  try {
    const [opd] = await db.execute('SELECT * FROM opd ORDER BY nama_opd')
    res.json(opd)
  } catch (error) {
    console.error('Get OPD error:', error)
    res.status(500).json({ message: 'Server error', error: error.message })
  }
})

// Get OPD by ID
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const [opd] = await db.execute('SELECT * FROM opd WHERE id = ?', [req.params.id])
    
    if (opd.length === 0) {
      return res.status(404).json({ message: 'OPD not found' })
    }
    
    res.json(opd[0])
  } catch (error) {
    console.error('Get OPD error:', error)
    res.status(500).json({ message: 'Server error', error: error.message })
  }
})

// Create new OPD
router.post('/', authenticateToken, async (req, res) => {
  try {
    const { kode_opd, nama_opd } = req.body
    
    if (!kode_opd || !nama_opd) {
      return res.status(400).json({ message: 'Kode OPD and Nama OPD are required' })
    }
    
    // Check if kode_opd already exists
    const [existingOPD] = await db.execute('SELECT id FROM opd WHERE kode_opd = ?', [kode_opd.toUpperCase()])
    if (existingOPD.length > 0) {
      return res.status(400).json({ message: 'Kode OPD already exists' })
    }
    
    const [result] = await db.execute(`
      INSERT INTO opd (kode_opd, nama_opd)
      VALUES (?, ?)
    `, [kode_opd.toUpperCase(), nama_opd])
    
    const [newOPD] = await db.execute('SELECT * FROM opd WHERE id = ?', [result.insertId])
    
    res.status(201).json(newOPD[0])
  } catch (error) {
    console.error('Create OPD error:', error)
    res.status(500).json({ message: 'Server error', error: error.message })
  }
})

// Update OPD
router.put('/:id', authenticateToken, async (req, res) => {
  try {
    const { kode_opd, nama_opd } = req.body
    
    if (!kode_opd || !nama_opd) {
      return res.status(400).json({ message: 'Kode OPD and Nama OPD are required' })
    }
    
    // Check if kode_opd already exists (excluding current record)
    const [existingOPD] = await db.execute('SELECT id FROM opd WHERE kode_opd = ? AND id != ?', [kode_opd.toUpperCase(), req.params.id])
    if (existingOPD.length > 0) {
      return res.status(400).json({ message: 'Kode OPD already exists' })
    }
    
    const [result] = await db.execute(`
      UPDATE opd 
      SET kode_opd = ?, nama_opd = ?
      WHERE id = ?
    `, [kode_opd.toUpperCase(), nama_opd, req.params.id])
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'OPD not found' })
    }
    
    const [updatedOPD] = await db.execute('SELECT * FROM opd WHERE id = ?', [req.params.id])
    
    res.json(updatedOPD[0])
  } catch (error) {
    console.error('Update OPD error:', error)
    res.status(500).json({ message: 'Server error', error: error.message })
  }
})

// Delete OPD
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    // Check if OPD is being used in tasks
    const [tasksUsingOPD] = await db.execute('SELECT COUNT(*) as count FROM tasks WHERE nama_opd = (SELECT nama_opd FROM opd WHERE id = ?)', [req.params.id])
    
    if (tasksUsingOPD[0].count > 0) {
      return res.status(400).json({ message: 'Cannot delete OPD because it is being used in tasks' })
    }
    
    const [result] = await db.execute('DELETE FROM opd WHERE id = ?', [req.params.id])
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'OPD not found' })
    }
    
    res.json({ message: 'OPD deleted successfully' })
  } catch (error) {
    console.error('Delete OPD error:', error)
    res.status(500).json({ message: 'Server error', error: error.message })
  }
})

module.exports = router
