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

## 🚀 Deployment Steps (سهل جداً!)

### 1. في Dokploy Dashboard:
- أنشئ Project جديد
- اختر نوع: **Docker Compose**
- أدخل رابط الـ Repository
- Dokploy سيقوم بكل شيء تلقائياً!

### 2. إضافة Environment Variables (اختياري):
- إذا أردت تغيير الإعدادات الافتراضية، أضف المتغيرات من القائمة أعلاه
- **الأهم**: `APP_URL` - ضع النطاق الفعلي
- **الأهم**: `CORS_ALLOWED_ORIGINS` - ضع النطاق الفعلي

### 3. إعدادات تلقائية:
- ✅ Database يتم إنشاؤه تلقائياً
- ✅ Migrations يتم تشغيلها تلقائياً عند البدء
- ✅ APP_KEY يتم توليده تلقائياً إذا لم يكن موجوداً
- ✅ SSL يتم إعداده تلقائياً من Dokploy

### 4. بعد النشر الأول (اختياري):
إذا أردت إضافة بيانات تجريبية:

```bash
php artisan install:velstore --with-import
```

أو يدوياً:

```bash
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

