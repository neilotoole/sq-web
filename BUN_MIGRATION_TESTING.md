# Bun Migration Testing Guide

This guide provides step-by-step instructions for testing the migration from Node.js/npm to Bun.

## Prerequisites

Before starting, ensure you have:
- Bun 1.2+ installed ([installation instructions](https://bun.sh/docs/installation))
- The `sq` CLI tool installed (for command help generation testing)
- Git access to push to remote for Netlify testing

### Installing Bun

```bash
# macOS/Linux
curl -fsSL https://bun.sh/install | bash

# Or using Homebrew (macOS)
brew install oven-sh/bun/bun

# Verify installation
bun --version
```

## Phase 1: Local Environment Setup

### 1.1 Clean Previous Installation

```bash
# Remove node_modules and any npm artifacts
rm -rf node_modules/
rm -f package-lock.json  # Should already be deleted in this branch

# Verify clean slate
ls -la | grep -E "node_modules|package-lock"
# Should return no results
```

### 1.2 Install Dependencies with Bun

```bash
# Install all dependencies using Bun
bun install

# Expected output:
# - Should show Bun downloading packages
# - Should create bun.lockb file
# - Should create node_modules/ directory
# - Should run postinstall script (hugo-installer)

# Verify lockfile was created
ls -lh bun.lockb
# Should show a binary lockfile exists

# Verify Hugo was installed
ls -la node_modules/.bin/hugo/
# Should show Hugo binary
```

### 1.3 Verify Hugo Installation

```bash
# Check Hugo version using Bun script
bun run check

# Expected output should show:
# - npm version (Bun compatibility layer)
# - Hugo version (should be 0.122.0 or similar)
```

**✅ Success Criteria:**
- `bun.lockb` file created
- No errors during installation
- Hugo binary exists in `node_modules/.bin/hugo/`
- `bun run check` shows Hugo version

**❌ Common Issues:**
- If Hugo installation fails, check that `hugo-installer` package is compatible
- If postinstall script fails, manually check `node_modules/.bin/hugo/`

## Phase 2: Development Server Testing

### 2.1 Start Development Server

```bash
# Start the dev server
bun start

# Expected behavior:
# - Should run prestart (clean)
# - Should start Hugo server
# - May take 1+ minute on first run
# - Should output: "Web Server is available at http://localhost:1313/"
```

**✅ Success Criteria:**
- Server starts without errors
- No warnings about missing modules
- Console shows Hugo version and server URL

**❌ Common Issues:**
- If "exec-bin" errors occur, the package may not be Bun-compatible
- If port 1313 is busy, kill any existing Hugo processes

### 2.2 Test Live Site

Open browser to `http://localhost:1313` and verify:

1. **Homepage loads correctly**
   - No 404 errors
   - CSS is applied (site looks styled, not plain HTML)
   - Navigation menu works

2. **Documentation pages load**
   - Navigate to Docs section
   - Click through several pages
   - Check that syntax highlighting works

3. **Asciinema recordings work**
   - Find a page with terminal recordings
   - Verify the player loads and can be played

4. **Search functionality**
   - Try searching for "sql"
   - Verify results appear

5. **Hot reload works**
   - Keep server running
   - Edit a markdown file in `content/en/docs/`
   - Save and verify browser auto-refreshes

**✅ Success Criteria:**
- All pages load correctly
- All assets load (CSS, JS, images)
- No console errors in browser
- Hot reload works

### 2.3 Stop Server

```bash
# Press Ctrl+C to stop the server
# Verify it stops cleanly without hanging
```

## Phase 3: Build Testing

### 3.1 Production Build

```bash
# Run production build
bun run build

# Expected behavior:
# - Should run prebuild (clean)
# - Should run Hugo with --gc --minify flags
# - Should run postbuild (append redirects)
# - Should output to ./public directory

# Expected output should show:
# - "Building sites..."
# - Statistics (pages, taxonomies, etc.)
# - "Total in XXms"
```

### 3.2 Verify Build Output

```bash
# Check that public directory was created
ls -la public/

# Verify key files exist
ls public/index.html        # Homepage
ls public/docs/             # Docs section
ls public/_redirects        # Redirects file
ls public/sitemap.xml       # Sitemap

# Check that _redirects was properly appended
cat public/_redirects
# Should contain redirects from static/_redirects
```

### 3.3 Preview Built Site

```bash
# Preview the built site locally
bun run preview

# Expected behavior:
# - Should run prepreview (clean)
# - Should build with local base URL
# - Should start serve on port 1313
# - Should output: "Serving public/ on http://localhost:1313"
```

Test the preview:
- Open `http://localhost:1313` in browser
- Click through several pages
- Verify all links work (no 404s)
- Stop with Ctrl+C

**✅ Success Criteria:**
- Build completes without errors
- All expected files in `public/` directory
- Preview server works correctly
- Site functions identically to dev server

**❌ Common Issues:**
- If build fails with "command not found", check Hugo installation
- If postbuild fails, verify `shx` package is installed

## Phase 4: Linting and Quality Checks

### 4.1 JavaScript Linting

```bash
# Lint JavaScript files
bun run lint:scripts

# Expected: Should pass with no errors
# (or show any existing linting issues)

# Test auto-fix
bun run lint:scripts-fix

# Should auto-fix any fixable issues
```

### 4.2 Style Linting

```bash
# Lint SCSS files
bun run lint:styles

# Expected: Should pass with no errors

# Test auto-fix
bun run lint:styles-fix

# Should auto-fix any fixable issues
```

### 4.3 Markdown Linting

```bash
# Lint markdown files
bun run lint:markdown

# Expected: Should check all .md files
# May show warnings for existing issues (acceptable)

# Test auto-fix
bun run lint:markdown-fix

# Should auto-fix any fixable markdown issues
```

### 4.4 Link Checking

```bash
# Run link checker (this will take several minutes)
bun run lint:links

# Expected behavior:
# - Builds fresh site to ./.serve-lint
# - Starts local server on port 31317
# - Runs linkinator against local build
# - Shows progress checking links
# - Reports any broken links

# Note: Some external links may fail due to rate limiting
# Check linkinator.config.json for excluded domains
```

**✅ Success Criteria:**
- All linters run successfully
- No new linting errors introduced
- Link checker completes (some external link failures are expected)

### 4.5 Run Full Test Suite

```bash
# Run all linters together
bun test

# or
bun run lint

# Expected: Runs all linters in sequence
```

**✅ Success Criteria:**
- All linters complete
- No unexpected errors

## Phase 5: Content Generation Testing

### 5.1 Command Help Generation

```bash
# Regenerate sq command help (requires sq CLI installed)
bun run gen:cmd-help

# Expected behavior:
# - Runs generate-cmd-help.sh script
# - Executes sq commands with --help flag
# - Generates .help.txt files in content/en/docs/cmd/

# Verify files were generated
ls -la content/en/docs/cmd/*.help.txt | head -5

# Check git diff to see changes
git diff content/en/docs/cmd/
```

**Note:** Only run this if you have the `sq` CLI installed. If not installed, skip this test.

### 5.2 Syntax CSS Generation

```bash
# Regenerate syntax highlighting CSS
bun run gen:syntax-css

# Expected behavior:
# - Runs generate-syntax-css.sh script
# - Generates SCSS files for Nord theme
# - Updates assets/scss/components/_syntax*.scss

# Check for changes
git diff assets/scss/components/_syntax.scss
git diff assets/scss/components/_syntax-dark.scss
```

**✅ Success Criteria:**
- Scripts run without errors
- Generated files are created/updated
- If no changes, that's expected (means files were already up-to-date)

## Phase 6: Netlify Deployment Testing

### 6.1 Commit Changes

```bash
# Check status
git status

# Should show:
# - Modified: package.json, netlify.toml, linkinator.sh, CLAUDE.md
# - Deleted: package-lock.json
# - Untracked: bun.lockb (if not already added)

# Stage all changes
git add .

# Commit
git commit -m "Migrate from Node.js/npm to Bun

- Update package.json: change engines to Bun 1.2+, update all npx to bunx
- Update netlify.toml: add BUN_VERSION, change build commands to use bun
- Update linkinator.sh: replace npx with bunx
- Delete package-lock.json
- Add bun.lockb (binary lockfile)
- Update CLAUDE.md documentation to reflect Bun usage

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# Push to remote
git push origin feature/bun-migration
```

### 6.2 Create Deploy Preview

```bash
# Create PR or push to branch that triggers Netlify preview
# Option 1: Use GitHub CLI
gh pr create --title "Migrate to Bun" --body "See BUN_MIGRATION_TESTING.md for testing details"

# Option 2: Create PR through GitHub web interface
```

### 6.3 Monitor Netlify Build

1. Go to Netlify dashboard
2. Find the deploy preview for your branch
3. Click on the build to see logs

**Expected in build logs:**
- Netlify should detect `bun.lockb`
- Should show "Installing dependencies with Bun"
- Should run `bun install`
- Should execute `bun run build`
- Hugo should build successfully
- Build should complete in similar time to npm (or faster)

### 6.4 Test Deploy Preview

Once deploy succeeds:

1. Click "Preview deploy" link
2. Test the following:
   - Homepage loads
   - Documentation pages load
   - Navigation works
   - Search works
   - Asciinema recordings play
   - All assets load (CSS, JS, images)
   - Links work correctly
   - Check browser console for errors

3. Test Lighthouse (if enabled):
   - Check Lighthouse report at `/reports/lighthouse.html`
   - Verify scores are similar to previous builds

**✅ Success Criteria:**
- Netlify build completes successfully
- Deploy preview works identically to previous version
- No build errors or warnings
- Site functions correctly on preview URL

**❌ Common Issues:**
- If Netlify doesn't detect Bun, ensure `bun.lockb` is committed
- If build fails, check Netlify logs for specific error
- If Hugo version mismatch, verify HUGO_VERSION in netlify.toml

### 6.5 Test Netlify Dev (Optional)

```bash
# Install Netlify CLI if not already installed
bun add -g netlify-cli

# Run Netlify dev locally
netlify dev

# This simulates Netlify environment locally
# Test that it works the same as `bun start`
```

## Phase 7: Performance Comparison

### 7.1 Measure Install Time

```bash
# Clean install with Bun
rm -rf node_modules bun.lockb
time bun install

# Note the total time
# Expected: Faster than npm (typically 2-5x faster)
```

### 7.2 Measure Build Time

```bash
# Clean build
rm -rf public resources
time bun run build

# Note the total time
# Compare to previous npm build times (should be similar or faster)
```

### 7.3 Measure Dev Server Startup

```bash
# Clean start
rm -rf public resources
time (bun start &)
# Let it fully start, then Ctrl+C

# Note the startup time
# Should be similar to npm start
```

**📊 Document Results:**
Create a comparison table:
```
| Operation       | npm (baseline) | Bun      | Improvement |
|-----------------|----------------|----------|-------------|
| Install         | XX.Xs          | YY.Ys    | Z.Zx faster |
| Build           | XX.Xs          | YY.Ys    | Z.Zx faster |
| Dev Start       | XX.Xs          | YY.Ys    | Z.Zx faster |
```

## Phase 8: Final Verification

### 8.1 Verify All Scripts Work

Run each script from package.json to ensure they all work:

```bash
bun run create          # (skip if it requires args)
bun start               # Test, then Ctrl+C
bun run build           # Test
bun run build:preview   # Test
bun run build:local     # Test
bun run preview         # Test, then Ctrl+C
bun run clean           # Test
bun run lint            # Test
bun run test            # Test
bun run check           # Test
bun run env             # Test
```

**✅ Success Criteria:**
- All scripts execute without errors
- Scripts produce expected output
- No "command not found" errors

### 8.2 Verify Migration Completeness

Check for any remaining npm references:

```bash
# Search for npm/npx in scripts
grep -r "npm " ./*.sh || echo "No npm found in shell scripts"
grep -r "npx " ./*.sh || echo "No npx found in shell scripts"

# Check package.json
cat package.json | grep "npx" || echo "No npx in package.json"

# Should all show "No npm/npx found" or only in comments/docs
```

### 8.3 Documentation Check

Verify all documentation updated:

```bash
# Check if CLAUDE.md was updated
git diff master CLAUDE.md

# Should show changes from npm to bun

# Check if README mentions npm (if exists)
[ -f README.md ] && cat README.md | grep -i npm || echo "No README or no npm mentions"
```

## Phase 9: Rollback Plan (If Needed)

If critical issues are found and you need to rollback:

```bash
# Switch back to master
git checkout master

# Or revert the migration commit
git revert <commit-hash>

# Or keep the branch for future fixes
git checkout -b feature/bun-migration-fixes
```

## Summary Checklist

Use this checklist to track testing progress:

- [ ] Phase 1: Local Environment Setup
  - [ ] Clean installation completed
  - [ ] bun.lockb created
  - [ ] Hugo installed successfully

- [ ] Phase 2: Development Server Testing
  - [ ] Dev server starts
  - [ ] Site loads correctly
  - [ ] Hot reload works

- [ ] Phase 3: Build Testing
  - [ ] Production build succeeds
  - [ ] Preview build works
  - [ ] All files generated correctly

- [ ] Phase 4: Linting and Quality Checks
  - [ ] JavaScript linting works
  - [ ] Style linting works
  - [ ] Markdown linting works
  - [ ] Link checking works

- [ ] Phase 5: Content Generation Testing
  - [ ] Command help generation works (if applicable)
  - [ ] Syntax CSS generation works

- [ ] Phase 6: Netlify Deployment Testing
  - [ ] Changes committed and pushed
  - [ ] Netlify build succeeds
  - [ ] Deploy preview works correctly

- [ ] Phase 7: Performance Comparison
  - [ ] Install time measured
  - [ ] Build time measured
  - [ ] Performance documented

- [ ] Phase 8: Final Verification
  - [ ] All scripts tested
  - [ ] No remaining npm references
  - [ ] Documentation updated

## Sign-off

Once all phases are complete and all checkboxes are marked, the migration can be considered successful and ready for merge to master.

**Tester Name:** _______________
**Date:** _______________
**Result:** ☐ Pass  ☐ Fail (see issues below)

**Issues Found:**
```
(List any issues encountered during testing)
```

**Performance Results:**
```
(Paste performance comparison table from Phase 7)
```
