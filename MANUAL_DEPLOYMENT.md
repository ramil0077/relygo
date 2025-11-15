# Manual Deployment Guide for Collaborators

Since you're a collaborator and the repository might not show in Netlify, here are alternative deployment methods:

## Method 1: Drag & Drop Deployment (Easiest)

1. **Build the project:**
   ```bash
   flutter build web --release
   ```

2. **Go to Netlify Drop:**
   - Visit: https://app.netlify.com/drop
   - Drag and drop the entire `build/web` folder
   - Wait for deployment (takes 1-2 minutes)
   - Your site will be live at `https://random-name.netlify.app`

3. **Get a custom name (optional):**
   - After deployment, go to Site settings → Change site name
   - Choose a custom name like `relygo-admin.netlify.app`

## Method 2: Netlify CLI (Recommended for Updates)

### Initial Setup:

1. **Install Netlify CLI:**
   ```bash
   npm install -g netlify-cli
   ```
   (If you don't have Node.js, download from https://nodejs.org/)

2. **Login to Netlify:**
   ```bash
   netlify login
   ```
   This will open your browser to authenticate.

3. **Build your project:**
   ```bash
   flutter build web --release
   ```

4. **Deploy:**
   ```bash
   netlify deploy --prod --dir=build/web
   ```

5. **Follow the prompts:**
   - If it's your first time, it will ask to create a new site
   - Choose a site name or let Netlify generate one
   - Your site will be deployed!

### For Updates:

Just run these commands again:
```bash
flutter build web --release
netlify deploy --prod --dir=build/web
```

## Method 3: Manual Git Push (If you have write access)

1. **Fork or Clone the repository:**
   ```bash
   git clone <repository-url>
   cd relygo
   ```

2. **Create a new branch:**
   ```bash
   git checkout -b web-deployment
   ```

3. **Build and commit:**
   ```bash
   flutter build web --release
   git add build/web
   git commit -m "Add web build"
   git push origin web-deployment
   ```

4. **In Netlify:**
   - Go to https://app.netlify.com
   - Click "Add new site" → "Import an existing project"
   - Connect to your Git provider
   - Select your fork/branch
   - Configure:
     - Build command: `flutter build web --release`
     - Publish directory: `build/web`
   - Deploy!

## Method 4: Using GitHub Actions (Advanced)

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Netlify

on:
  push:
    branches: [ main, master ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.8.1'
      - run: flutter pub get
      - run: flutter build web --release
      - uses: netlify/actions/cli@master
        with:
          args: deploy --dir=build/web --prod
        env:
          NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
          NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}
```

Then add secrets in GitHub repository settings.

## Quick Reference Commands

```bash
# Build for web
flutter build web --release

# Deploy via CLI (first time)
netlify deploy --prod --dir=build/web

# Deploy via CLI (updates)
netlify deploy --prod --dir=build/web

# Check deployment status
netlify status

# Open site in browser
netlify open:site
```

## Troubleshooting

### "netlify: command not found"
- Install Node.js: https://nodejs.org/
- Then install CLI: `npm install -g netlify-cli`

### Build fails
```bash
flutter clean
flutter pub get
flutter build web --release
```

### Site not updating
- Clear browser cache
- Check Netlify deploy logs
- Ensure you're deploying to the correct directory (`build/web`)

### Custom Domain
1. Go to Site settings → Domain management
2. Add custom domain
3. Follow DNS instructions

## Recommended: Method 1 (Drag & Drop)

For quick deployment without setup:
1. Build: `flutter build web --release`
2. Go to: https://app.netlify.com/drop
3. Drag `build/web` folder
4. Done!

---

**Note:** For regular updates, Method 2 (CLI) is best as it remembers your site and makes updates easy.

