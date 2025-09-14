require('dotenv').config()
const express = require('express')
const cors = require('cors')
const db = require('./config/database')

// Import routes
const authRoutes = require('./routes/auth')
const userRoutes = require('./routes/users')
const roleRoutes = require('./routes/roles')
const configRoutes = require('./routes/configs')
const taskRoutes = require('./routes/tasks')
const opdRoutes = require('./routes/opd')
const healthRoutes = require('./routes/health')

const app = express()
const PORT = process.env.PORT || 3000

// Middleware
app.use(cors())
app.use(express.json())
app.use(express.urlencoded({ extended: true }))

// Routes
app.use('/api/auth', authRoutes)
app.use('/api/users', userRoutes)
app.use('/api/roles', roleRoutes)
app.use('/api/configs', configRoutes)
app.use('/api/tasks', taskRoutes)
app.use('/api/opd', opdRoutes)
app.use('/api/health', healthRoutes)

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack)
  res.status(500).json({ message: 'Something went wrong!' })
})

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ message: 'Route not found' })
})

// Test database connection
async function testDatabaseConnection() {
  try {
    const connection = await db.getConnection()
    console.log('✅ Database connected successfully')
    connection.release()
  } catch (error) {
    console.error('❌ Database connection failed:', error.message)
    process.exit(1)
  }
}

// Start server
app.listen(PORT, async () => {
  console.log(`🚀 SIMANTU Server running on port ${PORT}`)
  await testDatabaseConnection()
  console.log(`📊 API available at http://localhost:${PORT}/api`)
})
