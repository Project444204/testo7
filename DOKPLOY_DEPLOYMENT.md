# Velstore Deployment Guide for Dokploy

## 📋 Environment Variables Required in Dokploy

Add these environment variables in your Dokploy dashboard:

```env
APP_NAME=Velstore
APP_ENV=production
APP_KEY=base64:your-generated-key-here
APP_DEBUG=false
APP_URL=https://your-domain.dokploy.app

LOG_CHANNEL=stack
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=velstore
DB_USERNAME=velstore_user
DB_PASSWORD=strong_password_here

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=database
SESSION_DRIVER=file
SESSION_LIFETIME=120

# CORS Configuration - IMPORTANT!
CORS_ALLOWED_ORIGINS=https://your-domain.dokploy.app,https://www.your-domain.dokploy.app
CORS_SUPPORTS_CREDENTIALS=true

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="${APP_NAME}"

VITE_APP_NAME="${APP_NAME}"
```

## 🚀 Deployment Steps

### 1. Create Project in Dokploy
- Project Type: **Docker Compose**
- Project Name: `velstore`

### 2. Setup Database Service
- Create MySQL database in Dokploy
- Service name: `db`
- Add database credentials to environment variables

### 3. Configure Environment Variables
- Copy all variables from above
- Replace `your-domain.dokploy.app` with your actual domain
- Generate `APP_KEY` using: `php artisan key:generate`

### 4. Setup Domain
- Add your domain in Dokploy
- SSL will be configured automatically

### 5. First Time Setup (After Deployment)

Connect to your container and run:

```bash
php artisan install:velstore --with-import
```

Or manually:

```bash
php artisan key:generate
php artisan migrate
php artisan db:seed
```

## 📁 Files Structure

```
velstore/
├── Dockerfile                 ✅ Created
├── docker-compose.yml         ✅ Created
├── docker/
│   ├── nginx.conf            ✅ Created
│   └── start.sh              ✅ Created
├── config/
│   └── cors.php              ✅ Updated (uses env variables)
└── DOKPLOY_DEPLOYMENT.md     ✅ This file
```

## ⚠️ Important Notes

1. **CORS Configuration**: Make sure to set `CORS_ALLOWED_ORIGINS` with your actual domain
2. **Database**: Use service name `db` (not `localhost`) in `DB_HOST`
3. **Storage Permissions**: Ensure `storage/` and `bootstrap/cache/` have write permissions
4. **SSL/HTTPS**: Dokploy handles SSL automatically, ensure `APP_URL` uses `https://`

## 🔧 Troubleshooting

### CORS Errors
- Check `CORS_ALLOWED_ORIGINS` includes your domain
- Set `CORS_SUPPORTS_CREDENTIALS=true`

### Database Connection
- Verify `DB_HOST=db` (service name)
- Check database service is healthy
- Ensure credentials match in environment variables

### Storage Issues
- Run: `chmod -R 755 storage bootstrap/cache`
- Check volume mounts in docker-compose.yml

## 📝 Post-Deployment Checklist

- [ ] Environment variables configured
- [ ] Database created and connected
- [ ] Domain configured with SSL
- [ ] Migrations run successfully
- [ ] CORS working from frontend
- [ ] Storage permissions set
- [ ] Application accessible via domain

