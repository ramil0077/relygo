# Deployment Guide for RelyGo Web Application

## Overview
This guide explains how to deploy the RelyGo web application (admin dashboard and landing page) after making changes.

## Prerequisites
- Flutter SDK installed
- Firebase project configured
- Web hosting service (Firebase Hosting, Netlify, Vercel, etc.)

## Deployment Steps

### Option 1: Firebase Hosting (Recommended)

1. **Build the web application:**
   ```bash
   flutter build web --release
   ```
   This creates optimized production files in the `build/web` directory.

2. **Install Firebase CLI (if not already installed):**
   ```bash
   npm install -g firebase-tools
   ```

3. **Login to Firebase:**
   ```bash
   firebase login
   ```

4. **Initialize Firebase Hosting (if not already done):**
   ```bash
   firebase init hosting
   ```
   - Select your Firebase project
   - Set `build/web` as the public directory
   - Configure as a single-page app: **Yes**
   - Set up automatic builds and deploys with GitHub: **No** (or Yes if you want CI/CD)

5. **Deploy to Firebase:**
   ```bash
   firebase deploy --only hosting
   ```

6. **Your site will be available at:**
   - `https://your-project-id.web.app`
   - `https://your-project-id.firebaseapp.com`

### Option 2: Netlify

1. **Build the web application:**
   ```bash
   flutter build web --release
   ```

2. **Install Netlify CLI (if not already installed):**
   ```bash
   npm install -g netlify-cli
   ```

3. **Login to Netlify:**
   ```bash
   netlify login
   ```

4. **Deploy:**
   ```bash
   netlify deploy --prod --dir=build/web
   ```

   Or use the Netlify dashboard:
   - Go to https://app.netlify.com
   - Drag and drop the `build/web` folder
   - Or connect your Git repository for automatic deployments

### Option 3: Vercel

1. **Build the web application:**
   ```bash
   flutter build web --release
   ```

2. **Install Vercel CLI (if not already installed):**
   ```bash
   npm install -g vercel
   ```

3. **Deploy:**
   ```bash
   vercel --prod build/web
   ```

### Option 4: Traditional Web Hosting (cPanel, FTP, etc.)

1. **Build the web application:**
   ```bash
   flutter build web --release
   ```

2. **Upload files:**
   - Upload all files from `build/web` directory to your web server's public directory (usually `public_html` or `www`)
   - Ensure `index.html` is in the root directory

3. **Configure server:**
   - Make sure your server supports SPA (Single Page Application) routing
   - Configure URL rewriting to redirect all routes to `index.html`

## After Making Changes

**Yes, you need to redeploy after making changes!**

### Quick Redeploy Process:

1. **Make your changes** to the codebase

2. **Test locally:**
   ```bash
   flutter run -d chrome
   ```

3. **Build for production:**
   ```bash
   flutter build web --release
   ```

4. **Deploy again:**
   - **Firebase:** `firebase deploy --only hosting`
   - **Netlify:** `netlify deploy --prod --dir=build/web`
   - **Vercel:** `vercel --prod build/web`
   - **FTP:** Upload the new `build/web` files

### Automated Deployment (CI/CD)

For automatic deployments on every push to your repository:

#### GitHub Actions (Firebase Hosting)
Create `.github/workflows/deploy.yml`:
```yaml
name: Deploy to Firebase Hosting

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      - run: flutter pub get
      - run: flutter build web --release
      - uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          projectId: your-project-id
```

#### Netlify
- Connect your Git repository in Netlify dashboard
- Set build command: `flutter build web --release`
- Set publish directory: `build/web`
- Netlify will automatically deploy on every push

## Important Notes

1. **Build Command:** Always use `flutter build web --release` for production builds
2. **Base URL:** If deploying to a subdirectory, update `web/index.html` base href
3. **Environment Variables:** Use `--dart-define` for environment-specific configs
4. **Caching:** Clear browser cache after deployment if changes don't appear
5. **Firebase Rules:** Ensure Firestore security rules allow admin access

## Troubleshooting

### Changes not appearing?
- Clear browser cache (Ctrl+Shift+Delete)
- Hard refresh (Ctrl+F5)
- Check if build completed successfully
- Verify deployment was successful in hosting dashboard

### Build errors?
- Run `flutter clean`
- Run `flutter pub get`
- Check for any missing dependencies
- Verify Flutter version compatibility

### Routing issues?
- Ensure your hosting service supports SPA routing
- Configure URL rewriting to redirect to `index.html`

## Quick Reference

```bash
# Clean build
flutter clean
flutter pub get

# Build for web
flutter build web --release

# Deploy to Firebase
firebase deploy --only hosting

# Deploy to Netlify
netlify deploy --prod --dir=build/web

# Deploy to Vercel
vercel --prod build/web
```

---

**Remember:** After any code changes, you must rebuild and redeploy for the changes to appear on your live website!

