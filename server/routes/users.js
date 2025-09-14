const express = require('express')
const bcrypt = require('bcryptjs')
const { body, validationResult } = require('express-validator')
const db = require('../config/database')
const { authenticateToken } = require('../middleware/auth')

const router = express.Router()

// Get all users
router.get('/', authenticateToken, async (req, res) => {
  try {
    const [users] = await db.execute(`
      SELECT u.id, u.name, u.email, u.role_id, u.created_at, u.updated_at, r.name as role_name
      FROM users u 
      LEFT JOIN roles r ON u.role_id = r.id 
      ORDER BY u.created_at DESC
    `)

    const formattedUsers = users.map(user => ({
      ...user,
      role: user.role_name
    }))

    res.json(formattedUsers)
  } catch (error) {
    console.error('Get users error:', error)
    res.status(500).json({ message: 'Server error' })
  }
})

// Get user by ID
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const [users] = await db.execute(`
      SELECT u.id, u.name, u.email, u.role_id, u.created_at, u.updated_at, r.name as role_name
      FROM users u 
      LEFT JOIN roles r ON u.role_id = r.id 
      WHERE u.id = ?
    `, [req.params.id])

    if (users.length === 0) {
      return res.status(404).json({ message: 'User not found' })
    }

    const user = users[0]
    user.role = user.role_name
    delete user.role_name

    res.json(user)
  } catch (error) {
    console.error('Get user error:', error)
    res.status(500).json({ message: 'Server error' })
  }
})

// Create user
router.post('/', authenticateToken, [
  body('name').trim().isLength({ min: 2 }).withMessage('Name must be at least 2 characters'),
  body('email').isEmail().normalizeEmail().withMessage('Valid email required'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
  body('role_id').isInt().withMessage('Valid role ID required')
], async (req, res) => {
  try {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ message: 'Validation failed', errors: errors.array() })
    }

    const { name, email, password, role_id } = req.body

    // Check if email already exists
    const [existingUsers] = await db.execute(
      'SELECT id FROM users WHERE email = ?',
      [email]
    )

    if (existingUsers.length > 0) {
      return res.status(400).json({ message: 'Email already exists' })
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 12)

    // Create user
    const [result] = await db.execute(
      'INSERT INTO users (name, email, password, role_id) VALUES (?, ?, ?, ?)',
      [name, email, hashedPassword, role_id]
    )

    // Get created user
    const [users] = await db.execute(`
      SELECT u.id, u.name, u.email, u.role_id, u.created_at, u.updated_at, r.name as role_name
      FROM users u 
      LEFT JOIN roles r ON u.role_id = r.id 
      WHERE u.id = ?
    `, [result.insertId])

    const user = users[0]
    user.role = user.role_name
    delete user.role_name

    res.status(201).json(user)
  } catch (error) {
    console.error('Create user error:', error)
    res.status(500).json({ message: 'Server error' })
  }
})

// Update user
router.put('/:id', authenticateToken, [
  body('name').optional().trim().isLength({ min: 2 }).withMessage('Name must be at least 2 characters'),
  body('email').optional().isEmail().normalizeEmail().withMessage('Valid email required'),
  body('password').optional().isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
  body('role_id').optional().isInt().withMessage('Valid role ID required')
], async (req, res) => {
  try {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ message: 'Validation failed', errors: errors.array() })
    }

    const { name, email, password, role_id } = req.body
    const userId = req.params.id

    // Check if user exists
    const [existingUsers] = await db.execute(
      'SELECT id FROM users WHERE id = ?',
      [userId]
    )

    if (existingUsers.length === 0) {
      return res.status(404).json({ message: 'User not found' })
    }

    // Check if email already exists (excluding current user)
    if (email) {
      const [emailCheck] = await db.execute(
        'SELECT id FROM users WHERE email = ? AND id != ?',
        [email, userId]
      )

      if (emailCheck.length > 0) {
        return res.status(400).json({ message: 'Email already exists' })
      }
    }

    // Build update query
    const updates = []
    const values = []

    if (name) {
      updates.push('name = ?')
      values.push(name)
    }
    if (email) {
      updates.push('email = ?')
      values.push(email)
    }
    if (password) {
      const hashedPassword = await bcrypt.hash(password, 12)
      updates.push('password = ?')
      values.push(hashedPassword)
    }
    if (role_id) {
      updates.push('role_id = ?')
      values.push(role_id)
    }

    if (updates.length === 0) {
      return res.status(400).json({ message: 'No fields to update' })
    }

    updates.push('updated_at = NOW()')
    values.push(userId)

    await db.execute(
      `UPDATE users SET ${updates.join(', ')} WHERE id = ?`,
      values
    )

    // Get updated user
    const [users] = await db.execute(`
      SELECT u.id, u.name, u.email, u.role_id, u.created_at, u.updated_at, r.name as role_name
      FROM users u 
      LEFT JOIN roles r ON u.role_id = r.id 
      WHERE u.id = ?
    `, [userId])

    const user = users[0]
    user.role = user.role_name
    delete user.role_name

    res.json(user)
  } catch (error) {
    console.error('Update user error:', error)
    res.status(500).json({ message: 'Server error' })
  }
})

// Delete user
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const userId = req.params.id

    // Check if user exists
    const [users] = await db.execute(
      'SELECT id FROM users WHERE id = ?',
      [userId]
    )

    if (users.length === 0) {
      return res.status(404).json({ message: 'User not found' })
    }

    // Don't allow deleting own account
    if (parseInt(userId) === req.user.id) {
      return res.status(400).json({ message: 'Cannot delete your own account' })
    }

    await db.execute('DELETE FROM users WHERE id = ?', [userId])

    res.json({ message: 'User deleted successfully' })
  } catch (error) {
    console.error('Delete user error:', error)
    res.status(500).json({ message: 'Server error' })
  }
})

module.exports = router
