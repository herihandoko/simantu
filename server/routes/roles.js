const express = require('express')
const { body, validationResult } = require('express-validator')
const db = require('../config/database')
const { authenticateToken } = require('../middleware/auth')

const router = express.Router()

// Get all roles
router.get('/', authenticateToken, async (req, res) => {
  try {
    const [roles] = await db.execute(`
      SELECT r.*, COUNT(u.id) as user_count
      FROM roles r 
      LEFT JOIN users u ON r.id = u.role_id 
      GROUP BY r.id
      ORDER BY r.created_at DESC
    `)

    // Handle permissions - they might be JSON string or already an array
    const rolesWithParsedPermissions = roles.map(role => {
      try {
        let permissions = []
        if (role.permissions) {
          if (typeof role.permissions === 'string') {
            permissions = JSON.parse(role.permissions)
          } else if (Array.isArray(role.permissions)) {
            permissions = role.permissions
          }
        }
        return {
          ...role,
          permissions
        }
        } catch (parseError) {
          return {
            ...role,
            permissions: []
          }
        }
    })

    res.json(rolesWithParsedPermissions)
  } catch (error) {
    console.error('Get roles error:', error)
    res.status(500).json({ message: 'Server error', error: error.message })
  }
})

// Get role by ID
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const [roles] = await db.execute(
      'SELECT * FROM roles WHERE id = ?',
      [req.params.id]
    )

    if (roles.length === 0) {
      return res.status(404).json({ message: 'Role not found' })
    }

    res.json(roles[0])
  } catch (error) {
    console.error('Get role error:', error)
    res.status(500).json({ message: 'Server error' })
  }
})

// Create role
router.post('/', authenticateToken, [
  body('name').trim().isLength({ min: 2 }).withMessage('Name must be at least 2 characters'),
  body('description').optional().trim().isLength({ max: 500 }).withMessage('Description too long'),
  body('permissions').optional().isArray().withMessage('Permissions must be an array')
], async (req, res) => {
  try {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ message: 'Validation failed', errors: errors.array() })
    }

    const { name, description, permissions } = req.body

    // Check if role name already exists
    const [existingRoles] = await db.execute(
      'SELECT id FROM roles WHERE name = ?',
      [name]
    )

    if (existingRoles.length > 0) {
      return res.status(400).json({ message: 'Role name already exists' })
    }

    // Create role
    const [result] = await db.execute(
      'INSERT INTO roles (name, description, permissions) VALUES (?, ?, ?)',
      [name, description || null, JSON.stringify(permissions || [])]
    )

    // Get created role
    const [roles] = await db.execute(
      'SELECT * FROM roles WHERE id = ?',
      [result.insertId]
    )

    const role = roles[0]
    role.permissions = typeof role.permissions === 'string' ? JSON.parse(role.permissions || '[]') : role.permissions

    res.status(201).json(role)
  } catch (error) {
    console.error('Create role error:', error)
    res.status(500).json({ message: 'Server error' })
  }
})

// Update role
router.put('/:id', authenticateToken, [
  body('name').optional().trim().isLength({ min: 2 }).withMessage('Name must be at least 2 characters'),
  body('description').optional().trim().isLength({ max: 500 }).withMessage('Description too long'),
  body('permissions').optional().isArray().withMessage('Permissions must be an array')
], async (req, res) => {
  try {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ message: 'Validation failed', errors: errors.array() })
    }

    const { name, description, permissions } = req.body
    const roleId = req.params.id

    // Check if role exists
    const [existingRoles] = await db.execute(
      'SELECT id FROM roles WHERE id = ?',
      [roleId]
    )

    if (existingRoles.length === 0) {
      return res.status(404).json({ message: 'Role not found' })
    }

    // Check if role name already exists (excluding current role)
    if (name) {
      const [nameCheck] = await db.execute(
        'SELECT id FROM roles WHERE name = ? AND id != ?',
        [name, roleId]
      )

      if (nameCheck.length > 0) {
        return res.status(400).json({ message: 'Role name already exists' })
      }
    }

    // Build update query
    const updates = []
    const values = []

    if (name) {
      updates.push('name = ?')
      values.push(name)
    }
    if (description !== undefined) {
      updates.push('description = ?')
      values.push(description)
    }
    if (permissions !== undefined) {
      updates.push('permissions = ?')
      values.push(JSON.stringify(permissions))
    }

    if (updates.length === 0) {
      return res.status(400).json({ message: 'No fields to update' })
    }

    updates.push('updated_at = NOW()')
    values.push(roleId)

    await db.execute(
      `UPDATE roles SET ${updates.join(', ')} WHERE id = ?`,
      values
    )

    // Get updated role
    const [roles] = await db.execute(
      'SELECT * FROM roles WHERE id = ?',
      [roleId]
    )

    const role = roles[0]
    role.permissions = typeof role.permissions === 'string' ? JSON.parse(role.permissions || '[]') : role.permissions

    res.json(role)
  } catch (error) {
    console.error('Update role error:', error)
    res.status(500).json({ message: 'Server error' })
  }
})

// Delete role
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const roleId = req.params.id

    // Check if role exists
    const [roles] = await db.execute(
      'SELECT id FROM roles WHERE id = ?',
      [roleId]
    )

    if (roles.length === 0) {
      return res.status(404).json({ message: 'Role not found' })
    }

    // Check if role is being used by any users
    const [users] = await db.execute(
      'SELECT id FROM users WHERE role_id = ?',
      [roleId]
    )

    if (users.length > 0) {
      return res.status(400).json({ 
        message: 'Cannot delete role that is assigned to users',
        userCount: users.length
      })
    }

    await db.execute('DELETE FROM roles WHERE id = ?', [roleId])

    res.json({ message: 'Role deleted successfully' })
  } catch (error) {
    console.error('Delete role error:', error)
    res.status(500).json({ message: 'Server error' })
  }
})

module.exports = router
