const express = require('express')
const bcrypt = require('bcryptjs')
const jwt = require('jsonwebtoken')
const { body, validationResult } = require('express-validator')
const db = require('../config/database')
const { authenticateToken } = require('../middleware/auth')

const router = express.Router()

// Login
router.post('/login', [
  body('email').isEmail(),
  body('password').isLength({ min: 6 })
], async (req, res) => {
  try {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ message: 'Invalid input data' })
    }

    const { email, password } = req.body

    // Find user
    const [users] = await db.execute(
      'SELECT u.*, r.name as role_name FROM users u LEFT JOIN roles r ON u.role_id = r.id WHERE u.email = ?',
      [email]
    )

    if (users.length === 0) {
      return res.status(401).json({ message: 'Invalid credentials' })
    }

    const user = users[0]

    // Check password
    const isValidPassword = await bcrypt.compare(password, user.password)
    if (!isValidPassword) {
      return res.status(401).json({ message: 'Invalid credentials' })
    }

    // Generate token
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET || 'fallback_secret',
      { expiresIn: '24h' }
    )

    // Get role permissions
    const [roles] = await db.execute(
      'SELECT permissions FROM roles WHERE id = ?',
      [user.role_id]
    )
    
    let permissions = []
    if (roles.length > 0 && roles[0].permissions) {
      try {
        permissions = typeof roles[0].permissions === 'string' 
          ? JSON.parse(roles[0].permissions) 
          : roles[0].permissions
      } catch (error) {
        console.error('Error parsing permissions:', error)
        permissions = []
      }
    }

    // Return user data without password
    const { password: _, ...userWithoutPassword } = user
    userWithoutPassword.role = userWithoutPassword.role_name
    userWithoutPassword.permissions = permissions
    delete userWithoutPassword.role_name

    res.json({
      token,
      user: userWithoutPassword
    })
  } catch (error) {
    console.error('Login error:', error)
    res.status(500).json({ message: 'Server error' })
  }
})

// Get current user
router.get('/me', authenticateToken, async (req, res) => {
  try {
    const [users] = await db.execute(
      'SELECT u.id, u.name, u.email, u.role_id, r.name as role_name, r.permissions FROM users u LEFT JOIN roles r ON u.role_id = r.id WHERE u.id = ?',
      [req.user.id]
    )

    if (users.length === 0) {
      return res.status(404).json({ message: 'User not found' })
    }

    const user = users[0]
    user.role = user.role_name
    
    // Parse permissions
    let permissions = []
    if (user.permissions) {
      try {
        permissions = typeof user.permissions === 'string' 
          ? JSON.parse(user.permissions) 
          : user.permissions
      } catch (error) {
        console.error('Error parsing permissions:', error)
        permissions = []
      }
    }
    user.permissions = permissions
    
    delete user.role_name

    res.json(user)
  } catch (error) {
    console.error('Get user error:', error)
    res.status(500).json({ message: 'Server error' })
  }
})

module.exports = router
