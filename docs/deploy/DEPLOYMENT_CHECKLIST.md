# Deployment Checklist

Use this checklist to ensure your game is ready for web deployment.

## ✅ Prerequisites

- [ ] Godot 4.x installed
  ```bash
  godot --version
  ```
  
- [ ] Godot web export templates installed
  - Open Godot Editor → Editor → Manage Export Templates → Download
  
- [ ] Node.js 18+ installed
  ```bash
  node --version
  ```
  
- [ ] Git repository initialized
  ```bash
  git status
  ```

## ✅ Initial Setup (One Time)

- [ ] Run setup script
  ```bash
  ./scripts/setup_web.sh
  ```
  
- [ ] Verify web directory structure
  ```bash
  ls web/app web/public
  ```
  
- [ ] Install Next.js dependencies
  ```bash
  cd web && npm install
  ```

## ✅ Before First Deploy

### Test Godot Export

- [ ] Open project in Godot Editor
  ```bash
  godot -e
  ```
  
- [ ] Test game runs in editor (F5)

- [ ] Export to web manually (first time)
  - Project → Export
  - Select "Web" preset
  - Click "Export Project"
  - Verify files in `web/public/godot/`

- [ ] Or use export script
  ```bash
  ./scripts/export_web.sh
  ```

### Test Local Build

- [ ] Start development server
  ```bash
  cd web && npm run dev
  ```
  
- [ ] Open browser to http://localhost:3000

- [ ] Verify game loads (watch console for errors)

- [ ] Test game functionality
  - [ ] Input (mouse, keyboard) works
  - [ ] Audio plays
  - [ ] UI is responsive
  - [ ] No console errors

- [ ] Test production build
  ```bash
  npm run build
  npm run start
  ```

## ✅ Pre-Deployment Checks

### Code Quality

- [ ] Game has no critical bugs
- [ ] All scenes load correctly
- [ ] No error spam in console
- [ ] Performance is acceptable

### Configuration

- [ ] `export_presets.cfg` is correct
  - [ ] Export path: `web/public/godot/aitherworks.html`
  - [ ] Threading enabled (if needed)
  - [ ] Compression enabled
  
- [ ] `next.config.ts` has CORS headers
  ```typescript
  'Cross-Origin-Embedder-Policy': 'require-corp'
  'Cross-Origin-Opener-Policy': 'same-origin'
  ```
  
- [ ] `.gitignore` excludes build outputs
  - [ ] `web/public/godot/`
  - [ ] `web/out/`
  - [ ] `web/.next/`

### Assets

- [ ] All assets properly imported in Godot
- [ ] No missing .import files
- [ ] Textures compressed (if large)
- [ ] Audio files optimized (not 96kHz WAV)

## ✅ Deployment to Vercel

### GitHub Method

- [ ] Repository pushed to GitHub
  ```bash
  git push origin main
  ```
  
- [ ] Connect to Vercel
  - Go to https://vercel.com
  - Click "Import Project"
  - Select GitHub repository
  
- [ ] Configure project
  - [ ] Framework: Next.js
  - [ ] Root Directory: `web`
  - [ ] Build Command: `npm run build`
  - [ ] Output Directory: `out`
  
- [ ] Click "Deploy"

- [ ] Wait for build to complete

- [ ] Open deployment URL

- [ ] Test game in deployed environment

### CLI Method

- [ ] Install Vercel CLI
  ```bash
  npm install -g vercel
  ```
  
- [ ] Login to Vercel
  ```bash
  vercel login
  ```
  
- [ ] Deploy from web directory
  ```bash
  cd web
  vercel --prod
  ```
  
- [ ] Follow prompts

- [ ] Open deployment URL

## ✅ Post-Deployment Testing

### Browser Testing

Test in multiple browsers:
- [ ] Chrome/Edge (Chromium)
- [ ] Firefox
- [ ] Safari (macOS/iOS)
- [ ] Mobile browsers

For each browser:
- [ ] Game loads without errors
- [ ] Graphics render correctly
- [ ] Audio plays
- [ ] Input works
- [ ] Performance is acceptable

### Device Testing

- [ ] Desktop (1920x1080)
- [ ] Laptop (1440x900)
- [ ] Tablet (iPad)
- [ ] Mobile (iPhone/Android)

### Network Testing

- [ ] Fast connection (home/office)
- [ ] Slow 3G (Chrome DevTools throttling)
- [ ] Check load time (should be < 10 seconds on good connection)

### Feature Testing

- [ ] All game features work
- [ ] Save/load works (if applicable)
- [ ] Multiplayer works (if applicable)
- [ ] No memory leaks (play for 10+ minutes)

## ✅ Performance Optimization

If game is slow or large:

### Reduce File Size

- [ ] Use release build (not debug)
  - Check `export_presets.cfg` uses release template
  
- [ ] Enable texture compression
  ```ini
  vram_texture_compression/for_desktop=true
  ```
  
- [ ] Compress audio files
  - Convert WAV to OGG
  - Use 44.1kHz or lower sample rate
  
- [ ] Remove unused assets
  - Check export filter in preset

### Improve Load Time

- [ ] Enable Vercel CDN (automatic)
- [ ] Verify Brotli/Gzip compression (automatic on Vercel)
- [ ] Consider splash screen with tips during load

### Improve Runtime Performance

- [ ] Enable threading in export preset
  ```ini
  variant/thread_support=true
  ```
  
- [ ] Profile with Chrome DevTools
  - Performance tab → Record while playing
  
- [ ] Optimize GDScript
  - Use @onready for nodes
  - Avoid _process() when possible
  - Pool objects instead of create/free

## ✅ Production Readiness

### User Experience

- [ ] Loading screen looks good
- [ ] Game is immediately playable
- [ ] Controls are obvious or explained
- [ ] No broken features

### SEO & Sharing

- [ ] Page title is descriptive (`web/app/layout.tsx`)
- [ ] Meta description added
- [ ] OpenGraph tags for social sharing
- [ ] Favicon added (`web/app/favicon.ico`)

### Analytics (Optional)

- [ ] Add Vercel Analytics
  ```bash
  npm install @vercel/analytics
  ```
  
- [ ] Or Google Analytics

### Monitoring

- [ ] Check Vercel dashboard for errors
- [ ] Set up error tracking (Sentry, etc.)
- [ ] Monitor bandwidth usage

## ✅ Continuous Deployment

### Automated Workflow

- [ ] Push to GitHub automatically deploys to Vercel
- [ ] Test on preview deployments (feature branches)
- [ ] Merge to main deploys to production

### Update Process

For each update:
1. [ ] Make changes in Godot
2. [ ] Test locally (`./scripts/export_web.sh && cd web && npm run dev`)
3. [ ] Commit and push
4. [ ] Verify deployment on Vercel
5. [ ] Test live site

## ✅ Optional Enhancements

### Custom Domain

- [ ] Buy domain
- [ ] Add to Vercel project
- [ ] Configure DNS
- [ ] Verify HTTPS works

### Progressive Web App

- [ ] Enable PWA in `export_presets.cfg`
  ```ini
  progressive_web_app/enabled=true
  progressive_web_app/icon_144x144="res://icon.png"
  ```

### Game Analytics

- [ ] Track player sessions
- [ ] Monitor level completion
- [ ] A/B test features

### Community

- [ ] Add feedback form
- [ ] Set up Discord/forum
- [ ] Create press kit
- [ ] Share on social media

## 🐛 Troubleshooting

If something goes wrong:

### Build Fails

- [ ] Check Godot export manually in editor
- [ ] Verify export templates installed
- [ ] Check `export_presets.cfg` syntax
- [ ] Look at Vercel build logs

### Game Doesn't Load

- [ ] Check browser console (F12)
- [ ] Verify files exist in deployment
- [ ] Test in different browser
- [ ] Check CORS headers being sent

### Performance Issues

- [ ] Use release build, not debug
- [ ] Check texture compression enabled
- [ ] Profile in Chrome DevTools
- [ ] Test on slower machine

## 📚 References

- [ ] Read `docs/web_deployment.md`
- [ ] Read `docs/web_deployment_quickstart.md`
- [ ] Read `docs/wasm_build_explained.md`
- [ ] Bookmark Godot web export docs
- [ ] Bookmark Vercel docs

---

**Deployment Status**: ⬜ Not Started | 🟨 In Progress | ✅ Complete

Mark items as you complete them. Good luck! 🚀

