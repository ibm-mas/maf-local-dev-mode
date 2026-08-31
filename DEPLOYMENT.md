# Deployment Guide

This guide covers deploying the IBM Maximo Application Framework Local Configuration documentation site to GitHub Pages.

## Quick Deployment

### Prerequisites

1. Repository created at `https://github.com/ibm-mas/maf-local-dev-mode`
2. Push access to the repository
3. All files committed to the `main` branch

### Steps

1. **Push to GitHub:**
   ```bash
   cd maf-local-dev-mode
   git add .
   git commit -m "Initial GitHub Pages site"
   git push origin main
   ```

2. **Enable GitHub Pages:**
   - Go to: https://github.com/ibm-mas/maf-local-dev-mode/settings/pages
   - Under "Source":
     - Branch: `main`
     - Folder: `/docs`
   - Click "Save"

3. **Wait for Deployment:**
   - GitHub will build and deploy automatically (1-2 minutes)
   - Check status at: https://github.com/ibm-mas/maf-local-dev-mode/deployments

4. **Verify Site:**
   - Visit: https://ibm-mas.github.io/maf-local-dev-mode/
   - Test all pages and links
   - Verify scripts are accessible

## File Checklist

Ensure all these files are present before deploying:

### HTML Pages
- ✅ `docs/index.html` - Landing page
- ✅ `docs/install.html` - Installation guide
- ✅ `docs/features.html` - Features documentation
- ✅ `docs/manual.html` - Manual installation

### Styles
- ✅ `docs/css/main.css` - Core styles (717 lines)
- ✅ `docs/css/responsive.css` - Responsive design (200 lines)

### JavaScript
- ✅ `docs/js/main.js` - Interactive features (268 lines)

### Scripts
- ✅ `docs/scripts/install.sh` - Automated installer (254 lines)
- ✅ `docs/scripts/get-credentials.sh` - OpenShift credentials (213 lines)

### Configuration
- ✅ `docs/.nojekyll` - Disable Jekyll processing
- ✅ `README.md` - Repository documentation

## Testing Before Deployment

### Local Testing

1. **Test HTML Pages:**
   ```bash
   cd docs
   python3 -m http.server 8000
   # Visit http://localhost:8000
   ```

2. **Test All Links:**
   - Navigate through all pages
   - Click all navigation links
   - Test external links
   - Verify footer links

3. **Test Responsive Design:**
   - Desktop (1920x1080)
   - Tablet (768x1024)
   - Mobile (375x667)

4. **Test Scripts:**
   ```bash
   # Test install script help
   bash docs/scripts/install.sh --help
      ```

### Accessibility Testing

- ✅ Keyboard navigation works
- ✅ Skip links present
- ✅ ARIA labels on interactive elements
- ✅ Color contrast meets WCAG AA
- ✅ Focus indicators visible

## Post-Deployment Verification

### Immediate Checks

1. **Site Loads:**
   ```bash
   curl -I https://ibm-mas.github.io/maf-local-dev-mode/
   # Should return 200 OK
   ```

2. **All Pages Accessible:**
   - https://ibm-mas.github.io/maf-local-dev-mode/
   - https://ibm-mas.github.io/maf-local-dev-mode/install.html
   - https://ibm-mas.github.io/maf-local-dev-mode/features.html
   - https://ibm-mas.github.io/maf-local-dev-mode/manual.html

3. **Scripts Downloadable:**
   ```bash
   curl -fsSL https://ibm-mas.github.io/maf-local-dev-mode/scripts/install.sh | head -5
   ```

4. **Assets Load:**
   - CSS files load without 404s
   - JavaScript loads and executes
   - Fonts load from Google Fonts

### Functional Testing

1. **Copy-to-Clipboard:**
   - Click copy buttons on code blocks
   - Verify clipboard content

2. **Mobile Menu:**
   - Toggle mobile navigation
   - Verify menu opens/closes

3. **Smooth Scrolling:**
   - Click anchor links
   - Verify smooth scroll behavior

4. **External Links:**
   - Test GitHub repository links
   - Verify they open in new tabs

## Troubleshooting

### Site Not Loading

**Problem:** 404 error on main page

**Solutions:**
1. Verify GitHub Pages is enabled
2. Check branch is set to `main`
3. Confirm folder is set to `/docs`
4. Wait 2-3 minutes for propagation

### Styles Not Applied

**Problem:** Site loads but looks unstyled

**Solutions:**
1. Check browser console for CSS 404s
2. Verify CSS files are in `/docs/css/`
3. Check file paths in HTML are relative
4. Clear browser cache

### Scripts Return 404

**Problem:** Installation scripts not downloadable

**Solutions:**
1. Verify scripts are in `/docs/scripts/`
2. Check file permissions (should be 644)
3. Ensure `.sh` extension is present
4. Test with full URL

### Mobile Menu Not Working

**Problem:** JavaScript features not working

**Solutions:**
1. Check browser console for JS errors
2. Verify `main.js` is loading
3. Check file path in HTML
4. Test in different browsers

## Updating the Site

### Content Updates

1. Edit HTML files locally
2. Test changes locally
3. Commit and push:
   ```bash
   git add docs/
   git commit -m "Update content"
   git push origin main
   ```
4. Wait 1-2 minutes for deployment

### Script Updates

1. Edit scripts in `docs/scripts/`
2. Test locally before committing
3. Update version numbers if needed
4. Commit and push

### Style Updates

1. Edit CSS files
2. Test responsive design
3. Verify accessibility
4. Commit and push

## Monitoring

### GitHub Actions (Optional)

Create `.github/workflows/pages.yml` for automated checks:

```yaml
name: Deploy GitHub Pages

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Validate HTML
        run: |
          # Add HTML validation
          
      - name: Test Scripts
        run: |
          bash docs/scripts/install.sh --help
```

### Analytics (Optional)

Add Google Analytics or similar:

1. Get tracking ID
2. Add to all HTML pages before `</head>`:
   ```html
   <!-- Google Analytics -->
   <script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
   <script>
     window.dataLayer = window.dataLayer || [];
     function gtag(){dataLayer.push(arguments);}
     gtag('js', new Date());
     gtag('config', 'GA_MEASUREMENT_ID');
   </script>
   ```

## Rollback Procedure

If deployment causes issues:

1. **Revert to Previous Commit:**
   ```bash
   git revert HEAD
   git push origin main
   ```

2. **Or Reset to Specific Commit:**
   ```bash
   git reset --hard <commit-hash>
   git push --force origin main
   ```

3. **Verify Rollback:**
   - Check site loads correctly
   - Test critical functionality

## Support

- **GitHub Pages Docs:** https://docs.github.com/en/pages
- **Repository Issues:** https://github.com/ibm-mas/maf-local-dev-mode/issues
- **Status Page:** https://www.githubstatus.com/

## Next Steps

After successful deployment:

1. ✅ Announce site to team
2. ✅ Update extension documentation with site URL
3. ✅ Monitor for issues in first 24 hours
4. ✅ Gather user feedback
5. ✅ Plan content updates based on feedback