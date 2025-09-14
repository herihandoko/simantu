module.exports = {
  apps: [{
    name: 'simantu-backend',
    script: 'server/server.js',
    cwd: '/var/www/simantu',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 5001
    },
    env_production: {
      NODE_ENV: 'production',
      PORT: 5001
    },
    env_development: {
      NODE_ENV: 'development',
      PORT: 5001
    },
    // Logging
    error_file: '/var/log/pm2/simantu-error.log',
    out_file: '/var/log/pm2/simantu-out.log',
    log_file: '/var/log/pm2/simantu-combined.log',
    time: true,
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    
    // Memory and CPU
    max_memory_restart: '1G',
    node_args: '--max-old-space-size=1024',
    
    // Restart policy
    min_uptime: '10s',
    max_restarts: 10,
    restart_delay: 4000,
    
    // Monitoring
    watch: false,
    ignore_watch: ['node_modules', 'logs', '*.log'],
    
    // Advanced features
    kill_timeout: 5000,
    listen_timeout: 3000,
    shutdown_with_message: true,
    
    // Health check
    health_check_grace_period: 3000,
    
    // Source map support
    source_map_support: true,
    
    // Instance variables
    instance_var: 'INSTANCE_ID',
    
    // Process title
    process_title: 'simantu-backend',
    
    // Auto restart on file change (disabled for production)
    watch_options: {
      usePolling: true,
      interval: 1000
    }
  }],
  
  // Deployment configuration
  deploy: {
    production: {
      user: 'ubuntu',
      host: '103.215.154.196',
      ref: 'origin/main',
      repo: 'https://github.com/herihandoko/simantu.git',
      path: '/var/www/simantu',
      'pre-deploy-local': '',
      'post-deploy': 'npm install && npm run build && pm2 reload ecosystem.config.js --env production',
      'pre-setup': ''
    },
    staging: {
      user: 'ubuntu',
      host: 'staging-server-ip',
      ref: 'origin/develop',
      repo: 'https://github.com/herihandoko/simantu.git',
      path: '/var/www/simantu-staging',
      'post-deploy': 'npm install && npm run build && pm2 reload ecosystem.config.js --env staging'
    }
  }
};
