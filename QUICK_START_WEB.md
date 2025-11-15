# Quick Start - Web Deployment

## 🚀 Fastest Way to Deploy (Works for Collaborators Too!)

### Step 1: Build
```bash
flutter build web --release
```

### Step 2: Deploy (No Git Required!)
1. Go to https://app.netlify.com/drop
2. Drag and drop the `build/web` folder
3. Done! Your site is live 🎉

> **Note:** This method works even if you're a collaborator and the repo doesn't show in Netlify!

## 📋 What's Included

✅ **All Admin Features**
- Dashboard with statistics
- User management
- Driver management  
- Booking management
- Complaints handling
- Feedback/reviews
- Chat system

✅ **User & Driver Features**
- Registration & Login
- Profile management
- Booking history
- Chat functionality

❌ **Excluded (Mobile Only)**
- Payment (shows message on web)
- Location tracking (shows message on web)

## 🔧 Build Command

```bash
flutter build web --release --base-href /
```

## 📁 Important Files

- `netlify.toml` - Netlify configuration
- `web/_redirects` - SPA routing
- `lib/utils/platform_utils.dart` - Platform detection

## 🌐 After Deployment

Your site will be available at:
- `https://your-site-name.netlify.app`
- Custom domain can be added in Netlify settings

## ⚙️ Environment Setup

No special environment variables needed for basic deployment. Firebase configuration is handled in `firebase_options.dart`.

---

For detailed instructions, see `WEB_DEPLOYMENT.md`

