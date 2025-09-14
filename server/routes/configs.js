const express = require('express')
const { body, validationResult } = require('express-validator')
const db = require('../config/database')
const { authenticateToken } = require('../middleware/auth')

const router = express.Router()

// Get all configurations
router.get('/', authenticateToken, async (req, res) => {
  try {
    const [configs] = await db.execute(`
      SELECT * FROM configurations 
      ORDER BY category, key_name
    `)

    res.json(configs)
  } catch (error) {
    console.error('Get configs error:', error)
    res.status(500).json({ message: 'Server error' })
  }
})

// Get configuration by ID
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const [configs] = await db.execute(
      'SELECT * FROM configurations WHERE id = ?',
      [req.params.id]
    )

    if (configs.length === 0) {
      return res.status(404).json({ message: 'Configuration not found' })
    }

    res.json(configs[0])
  } catch (error) {
    console.error('Get config error:', error)
    res.status(500).json({ message: 'Server error' })
  }
})

// Get configurations by category
router.get('/category/:category', authenticateToken, async (req, res) => {
  try {
    const [configs] = await db.execute(
      'SELECT * FROM configurations WHERE category = ? ORDER BY key_name',
      [req.params.category]
    )

    res.json(configs)
  } catch (error) {
    console.error('Get configs by category error:', error)
    res.status(500).json({ message: 'Server error' })
  }
})

// Create configuration
router.post('/', authenticateToken, [
  body('key_name').trim().isLength({ min: 1 }).withMessage('Key name is required'),
  body('value').trim().isLength({ min: 1 }).withMessage('Value is required'),
  body('category').trim().isLength({ min: 1 }).withMessage('Category is required'),
  body('description').optional().trim().isLength({ max: 500 }).withMessage('Description too long'),
  body('data_type').optional().isIn(['string', 'number', 'boolean', 'json']).withMessage('Invalid data type')
], async (req, res) => {
  try {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ message: 'Validation failed', errors: errors.array() })
    }

    const { key_name, value, category, description, data_type } = req.body

    // Check if key already exists in the same category
    const [existingConfigs] = await db.execute(
      'SELECT id FROM configurations WHERE key_name = ? AND category = ?',
      [key_name, category]
    )

    if (existingConfigs.length > 0) {
      return res.status(400).json({ message: 'Configuration key already exists in this category' })
    }

    // Validate value based on data type
    let validatedValue = value
    if (data_type === 'number') {
      if (isNaN(value)) {
        return res.status(400).json({ message: 'Value must be a valid number' })
      }
      validatedValue = parseFloat(value)
    } else if (data_type === 'boolean') {
      validatedValue = value.toLowerCase() === 'true'
    } else if (data_type === 'json') {
      try {
        JSON.parse(value)
      } catch (e) {
        return res.status(400).json({ message: 'Value must be valid JSON' })
      }
    }

    // Create configuration
    const [result] = await db.execute(
      'INSERT INTO configurations (key_name, value, category, description, data_type) VALUES (?, ?, ?, ?, ?)',
      [key_name, validatedValue, category, description || null, data_type || 'string']
    )

    // Get created configuration
    const [configs] = await db.execute(
      'SELECT * FROM configurations WHERE id = ?',
      [result.insertId]
    )

    res.status(201).json(configs[0])
  } catch (error) {
    console.error('Create config error:', error)
    res.status(500).json({ message: 'Server error' })
  }
})

// Update configuration
router.put('/:id', authenticateToken, [
  body('key_name').optional().trim().isLength({ min: 1 }).withMessage('Key name cannot be empty'),
  body('value').optional().trim().isLength({ min: 1 }).withMessage('Value cannot be empty'),
  body('category').optional().trim().isLength({ min: 1 }).withMessage('Category cannot be empty'),
  body('description').optional().trim().isLength({ max: 500 }).withMessage('Description too long'),
  body('data_type').optional().isIn(['string', 'number', 'boolean', 'json']).withMessage('Invalid data type')
], async (req, res) => {
  try {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ message: 'Validation failed', errors: errors.array() })
    }

    const { key_name, value, category, description, data_type } = req.body
    const configId = req.params.id

    // Check if configuration exists
    const [existingConfigs] = await db.execute(
      'SELECT id FROM configurations WHERE id = ?',
      [configId]
    )

    if (existingConfigs.length === 0) {
      return res.status(404).json({ message: 'Configuration not found' })
    }

    // Check if key already exists in the same category (excluding current config)
    if (key_name && category) {
      const [keyCheck] = await db.execute(
        'SELECT id FROM configurations WHERE key_name = ? AND category = ? AND id != ?',
        [key_name, category, configId]
      )

      if (keyCheck.length > 0) {
        return res.status(400).json({ message: 'Configuration key already exists in this category' })
      }
    }

    // Validate value based on data type
    let validatedValue = value
    if (value && data_type === 'number') {
      if (isNaN(value)) {
        return res.status(400).json({ message: 'Value must be a valid number' })
      }
      validatedValue = parseFloat(value)
    } else if (value && data_type === 'boolean') {
      validatedValue = value.toLowerCase() === 'true'
    } else if (value && data_type === 'json') {
      try {
        JSON.parse(value)
      } catch (e) {
        return res.status(400).json({ message: 'Value must be valid JSON' })
      }
    }

    // Build update query
    const updates = []
    const values = []

    if (key_name) {
      updates.push('key_name = ?')
      values.push(key_name)
    }
    if (value) {
      updates.push('value = ?')
      values.push(validatedValue)
    }
    if (category) {
      updates.push('category = ?')
      values.push(category)
    }
    if (description !== undefined) {
      updates.push('description = ?')
      values.push(description)
    }
    if (data_type) {
      updates.push('data_type = ?')
      values.push(data_type)
    }

    if (updates.length === 0) {
      return res.status(400).json({ message: 'No fields to update' })
    }

    updates.push('updated_at = NOW()')
    values.push(configId)

    await db.execute(
      `UPDATE configurations SET ${updates.join(', ')} WHERE id = ?`,
      values
    )

    // Get updated configuration
    const [configs] = await db.execute(
      'SELECT * FROM configurations WHERE id = ?',
      [configId]
    )

    res.json(configs[0])
  } catch (error) {
    console.error('Update config error:', error)
    res.status(500).json({ message: 'Server error' })
  }
})

// Delete configuration
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const configId = req.params.id

    // Check if configuration exists
    const [configs] = await db.execute(
      'SELECT id FROM configurations WHERE id = ?',
      [configId]
    )

    if (configs.length === 0) {
      return res.status(404).json({ message: 'Configuration not found' })
    }

    await db.execute('DELETE FROM configurations WHERE id = ?', [configId])

    res.json({ message: 'Configuration deleted successfully' })
  } catch (error) {
    console.error('Delete config error:', error)
    res.status(500).json({ message: 'Server error' })
  }
})

module.exports = router
