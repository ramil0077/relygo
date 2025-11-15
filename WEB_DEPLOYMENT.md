# RelyGo Web Deployment Guide

This guide will help you deploy the RelyGo web application to Netlify for free.

> **Note for Collaborators:** If your repository is not showing in Netlify, see `MANUAL_DEPLOYMENT.md` for alternative deployment methods.

## Prerequisites

1. **Flutter SDK** (version 3.8.1 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Verify installation: `flutter --version`

2. **Git** (for version control)
   - Download from: https://git-scm.com/downloads

3. **Netlify Account** (free)
   - Sign up at: https://app.netlify.com/signup

## Features Available on Web

✅ **Available:**
- Admin Dashboard (all features)
- User Dashboard
- Driver Dashboard
- User Registration & Login
- Driver Registration & Login
- Admin Login
- User Management
- Driver Management
- Booking Management
- Complaints Management
- Feedback/Reviews
- Chat System
- All CRUD operations
- Responsive Design

❌ **Not Available (Mobile Only):**
- Payment Integration (Razorpay)
- Real-time Location Tracking
- GPS-based features

## Local Build & Test

Before deploying, test the web build locally:

```bash
# 1. Get dependencies
flutter pub get

# 2. Build for web
flutter build web --release

# 3. Test locally (optional)
# Serve the build/web directory using any local server
# For example, using Python:
cd build/web
python -m http.server 8000
# Then open http://localhost:8000 in your browser
```

## Deployment to Netlify

### Option 1: Deploy via Netlify CLI (Recommended)

1. **Install Netlify CLI:**
   ```bash
   npm install -g netlify-cli
   ```

2. **Login to Netlify:**
   ```bash
   netlify login
   ```

3. **Build the project:**
   ```bash
   flutter build web --release
   ```

4. **Deploy:**
   ```bash
   netlify deploy --prod --dir=build/web
   ```

5. **Follow the prompts** to create a new site or link to an existing one.

### Option 2: Deploy via Netlify Dashboard (Git-based)

1. **Push your code to GitHub/GitLab/Bitbucket:**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin <your-repo-url>
   git push -u origin main
   ```

2. **Connect to Netlify:**
   - Go to https://app.netlify.com
   - Click "Add new site" → "Import an existing project"
   - Connect your Git provider
   - Select your repository

3. **Configure Build Settings:**
   - **Build command:** `flutter build web --release`
   - **Publish directory:** `build/web`
   - **Base directory:** (leave empty or set to root)

4. **Set Environment Variables (if needed):**
   - Go to Site settings → Environment variables
   - Add any required Firebase or API keys

5. **Deploy:**
   - Click "Deploy site"
   - Netlify will automatically build and deploy

### Option 3: Drag & Drop Deployment

1. **Build the project:**
   ```bash
   flutter build web --release
   ```

2. **Go to Netlify:**
   - Visit https://app.netlify.com/drop
   - Drag and drop the `build/web` folder
   - Your site will be deployed instantly!

## Configuration Files

The following files are already configured for Netlify:

- **`netlify.toml`** - Netlify build configuration
- **`web/_redirects`** - SPA routing configuration

## Post-Deployment

1. **Custom Domain (Optional):**
   - Go to Site settings → Domain management
   - Add your custom domain
   - Follow Netlify's DNS instructions

2. **SSL Certificate:**
   - Netlify automatically provides SSL certificates
   - Your site will be HTTPS by default

3. **Environment Variables:**
   - If you need different Firebase configs for production
   - Go to Site settings → Environment variables
   - Add variables like `FIREBASE_API_KEY`, etc.

## Troubleshooting

### Build Fails

1. **Check Flutter version:**
   ```bash
   flutter --version
   ```
   Ensure you're using Flutter 3.8.1 or higher.

2. **Clean and rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter build web --release
   ```

3. **Check for errors:**
   ```bash
   flutter analyze
   ```

### Routing Issues

- The `web/_redirects` file handles SPA routing
- All routes redirect to `index.html` with 200 status
- This ensures Flutter's routing works correctly

### Firebase Configuration

- Ensure `firebase_options.dart` includes web configuration
- Check Firebase Console → Project Settings → General → Your apps
- Verify web app is registered

### Performance Optimization

1. **Enable caching:**
   - Netlify automatically caches static assets
   - Check Site settings → Build & deploy → Post processing

2. **CDN:**
   - Netlify uses a global CDN automatically
   - No additional configuration needed

## Continuous Deployment

Netlify automatically deploys when you push to your connected Git repository:

1. Push changes to your main branch
2. Netlify detects the push
3. Builds the project automatically
4. Deploys the new version
5. Sends you a notification

## Monitoring

- **Deploy logs:** Available in Netlify dashboard
- **Analytics:** Available in Netlify dashboard (may require paid plan)
- **Error tracking:** Check browser console and Netlify logs

## Support

For issues:
1. Check Netlify status: https://www.netlifystatus.com/
2. Check Flutter web documentation: https://flutter.dev/web
3. Netlify documentation: https://docs.netlify.com/

## Notes

- **Free Tier Limits:**
  - 100 GB bandwidth/month
  - 300 build minutes/month
  - Unlimited sites
  - Automatic HTTPS

- **Build Time:**
  - First build: ~5-10 minutes
  - Subsequent builds: ~3-5 minutes

- **File Size:**
  - Initial load: ~2-5 MB (compressed)
  - Subsequent loads: Cached by browser

## Quick Commands Reference

```bash
# Build for web
flutter build web --release

# Deploy to Netlify (CLI)
netlify deploy --prod --dir=build/web

# Test locally
cd build/web && python -m http.server 8000

# Check Flutter version
flutter --version

# Clean build
flutter clean && flutter pub get
```

---

**Happy Deploying! 🚀**

