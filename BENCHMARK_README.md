# Benchmark Script Documentation

## Overview

The `benchmark-node-vs-bun.sh` script provides comprehensive performance comparison between Node.js/npm (master branch) and Bun (feature/bun-migration branch).

## Configuration

To compare different branches, edit the configuration section at the top of the script:

```bash
# Branch configuration - change these to compare different branches
NPM_BRANCH="master"                    # Branch using Node.js/npm
BUN_BRANCH="feature/bun-migration"     # Branch using Bun
NPM_RUNTIME="npm"                      # Runtime name for npm branch
BUN_RUNTIME="bun"                      # Runtime name for Bun branch
```

**Example: Compare different branches**
```bash
NPM_BRANCH="develop"
BUN_BRANCH="feature/new-bun-version"
```

**Example: Compare npm vs pnpm**
```bash
NPM_BRANCH="main"
BUN_BRANCH="feature/pnpm"
NPM_RUNTIME="npm"
BUN_RUNTIME="pnpm"
```

## Quick Start

```bash
# Run with default settings (3 iterations)
./benchmark-node-vs-bun.sh

# Run single iteration (faster, less accurate)
./benchmark-node-vs-bun.sh -1

# Run with custom iterations
./benchmark-node-vs-bun.sh -r 5

# Skip confirmation prompt
./benchmark-node-vs-bun.sh --no-confirm

# Verbose output
./benchmark-node-vs-bun.sh -v

# Clean up old benchmark results
./benchmark-node-vs-bun.sh --cleanup

# Clean up without confirmation
./benchmark-node-vs-bun.sh --cleanup --no-confirm
```

## Cleanup

The benchmark script includes a cleanup feature to remove old benchmark results and build artifacts:

```bash
# Interactive cleanup (asks for confirmation)
./benchmark-node-vs-bun.sh --cleanup

# Automatic cleanup (no confirmation)
./benchmark-node-vs-bun.sh --cleanup --no-confirm
```

**What gets cleaned up:**
- All `benchmark-results-*.txt` files
- All `benchmark-run*.log` files
- `node_modules/` directory
- `public/` directory
- `resources/` directory
- `.serve-lint/` directory
- `package-lock.json`, `bun.lockb`, `bun.lock` files

**Example output:**
```
Benchmark Cleanup

ℹ Scanning for benchmark artifacts...

Benchmark result files found:
  - benchmark-results-20260121-152314.txt (3.9K, Jan 21 15:37)

Build artifacts found:
  - node_modules/ (705M)
  - resources/ (19M)

Remove all 3 item(s)? [y/N] y

ℹ Cleaning up...
✓ Removed benchmark-results-20260121-152314.txt
✓ Removed node_modules/
✓ Removed resources/

✓ Cleanup complete!
```

## Metrics Measured

The script benchmarks the following operations:

### 1. **Dependency Installation**
- Measures time for `npm install` vs `bun install`
- Runs from completely clean state (no cache)
- Multiple iterations for statistical accuracy

### 2. **Development Server Startup**
- Measures time from `npm start` / `bun start` to server responding
- Tests actual time until HTTP 200 response on localhost:1313
- Not just process start, but full server ready time

### 3. **Production Build**
- Measures time for `npm run build` / `bun run build`
- Includes Hugo build with --gc --minify flags
- Tests actual production deployment scenario

### 4. **Linting**
- Measures combined time for all linters:
  - ESLint (JavaScript)
  - Stylelint (SCSS)
  - markdownlint (Markdown)
- Link checker excluded (too slow for benchmark)

### 5. **Size Metrics**
- node_modules directory size
- Lockfile size (package-lock.json vs bun.lockb)
- Number of packages installed

### 6. **Functionality Verification**
- Homepage loads (HTTP 200)
- Homepage contains expected content
- Docs page loads
- CSS/JS assets referenced

## Command-Line Options

```
-h, --help           Show help message
-r, --runs N         Number of test runs per metric (default: 3)
-t, --timeout N      Server startup timeout in seconds (default: 120)
-n, --no-confirm     Skip confirmation prompt
-d, --dry-run        Show what would be done (not implemented)
-v, --verbose        Show detailed output during tests
-1, --single         Run tests only once (equivalent to -r 1)
```

## How It Works

### Test Flow

1. **Prerequisites Check**
   - Verifies git, node, npm, bun are installed
   - Confirms both branches exist
   - Shows version information

2. **Git State Preservation**
   - Saves current branch
   - Stashes uncommitted changes if needed
   - Restores everything at the end

3. **Master Branch Testing (npm)**
   - Checks out master branch
   - Runs N iterations of each benchmark
   - Verifies site functionality
   - Collects metrics

4. **Feature Branch Testing (Bun)**
   - Checks out feature/bun-migration branch
   - Runs N iterations of each benchmark
   - Verifies site functionality
   - Collects metrics

5. **Results Comparison**
   - Calculates averages
   - Computes percentage improvements
   - Generates comparison table
   - Provides summary

6. **Cleanup**
   - Stops any running servers
   - Restores original branch
   - Restores uncommitted changes

### Clean State Guarantee

Each test iteration starts with:
- Deleted node_modules/
- Deleted lockfiles
- Deleted build artifacts (public/, resources/)
- Killed server processes
- Fresh install from package.json

This ensures fair comparison with no caching effects.

## Output

### Console Output

The script provides real-time progress updates:

```
===========================================
 Node.js/npm vs Bun Performance Benchmark
===========================================

Testing Environment:
- Repository: sq-web
- Node.js Version: v22.x.x
- npm Version: 10.x.x
- Bun Version: 1.x.x

-------------------------------------------
Testing master (npm)
-------------------------------------------
  [1/3] Installing dependencies... 45.23s
  [2/3] Installing dependencies... 44.87s
  [3/3] Installing dependencies... 45.01s

  [1/3] Starting server... 12.34s
  [2/3] Starting server... 11.98s
  [3/3] Starting server... 12.15s

  [1/3] Building production site... 8.45s
  [2/3] Building production site... 8.39s
  [3/3] Building production site... 8.42s

  [1/3] Running linters... 15.67s
  [2/3] Running linters... 15.54s
  [3/3] Running linters... 15.61s

✓ Homepage loads (HTTP 200)
✓ Homepage contains expected content
✓ Docs page loads (HTTP 200)
✓ CSS/JS assets referenced

[Similar output for feature/bun-migration]

-------------------------------------------
Performance Comparison
-------------------------------------------

┌─────────────────────────┬──────────────┬──────────────┬─────────────────┐
│ Metric                  │ npm (master) │ Bun (feature)│ Improvement     │
├─────────────────────────┼──────────────┼──────────────┼─────────────────┤
│ Install Time            │      45.04s  │       8.23s  │ 81.7% faster    │
│ Server Start Time       │      12.16s  │      11.89s  │ 2.2% faster     │
│ Production Build Time   │       8.42s  │       8.15s  │ 3.2% faster     │
│ Linting Time            │      15.61s  │      14.87s  │ 4.7% faster     │
│ node_modules Size       │      287 MB  │      287 MB  │ Same            │
│ Lockfile Size           │     1.70 MB  │     0.28 MB  │ 83.5% faster    │
│ Site Verification       │        4/4   │        4/4   │ Both pass       │
└─────────────────────────┴──────────────┴──────────────┴─────────────────┘

Summary:
✓ Bun is 5.5x faster at installing dependencies
✓ Bun is 1.0x faster at production builds
✓ Bun is 1.0x faster at running linters
✓ Both versions successfully serve the site
✓ All site verification checks passed

ℹ Results saved to: benchmark-results-20260120-203000.txt
```

### File Output

Results are saved to `benchmark-results-YYYYMMDD-HHMMSS.txt` containing:
- Complete console output
- All timing data
- Comparison table
- Summary

## Safety Features

### 1. Git State Preservation
- Original branch automatically restored
- Uncommitted changes stashed and restored
- Safe to run on dirty working tree

### 2. Cleanup on Exit
- Cleanup runs even if script interrupted (Ctrl+C)
- Kills all Hugo server processes
- Removes build artifacts

### 3. Non-Destructive
- Only modifies temporary files (node_modules, public, etc.)
- Never modifies source code
- Restores everything at completion

### 4. Error Handling
- Graceful handling of server startup failures
- Continues testing even if one metric fails
- Records failures in results

## Interpreting Results

### Expected Results

Based on Bun's performance characteristics:

- **Install Time**: 70-85% faster (Bun's biggest advantage)
- **Server Startup**: Similar or slightly faster (Hugo-dependent)
- **Build Time**: Similar or slightly faster (Hugo-dependent)
- **Linting**: Similar (depends on tool compatibility)
- **Lockfile Size**: ~80% smaller (binary vs text format)

### Variability

Results may vary due to:
- System load during testing
- Disk I/O performance
- Network conditions (for fresh installs)
- First run vs subsequent runs

Running multiple iterations (default 3) helps reduce variability.

### When to Re-run

Re-run benchmarks after:
- Adding/removing dependencies
- System performance changes
- Updating Node.js, npm, or Bun versions
- Changing Hugo version

## Troubleshooting

### Port 1313 Already in Use

```bash
# Kill existing Hugo processes
pkill -f "hugo server"

# Or find and kill specific process
lsof -ti:1313 | xargs kill -9
```

### Server Fails to Start

- Check Hugo is installed: `./node_modules/.bin/hugo/hugo version`
- Increase timeout: `./benchmark-node-vs-bun.sh -t 180`
- Run with verbose: `./benchmark-node-vs-bun.sh -v`

### Git State Not Restored

```bash
# Manually restore
git checkout <your-branch>
git stash list  # Find benchmark stash
git stash pop stash@{0}  # Restore if needed
```

### Results Seem Wrong

- Run with more iterations: `./benchmark-node-vs-bun.sh -r 5`
- Close other applications to reduce system load
- Run verbose to see detailed output: `./benchmark-node-vs-bun.sh -v`

## Performance Tips

### Quick Benchmark
```bash
# Single iteration (faster, less accurate)
./benchmark-node-vs-bun.sh -1 --no-confirm
```

### Accurate Benchmark
```bash
# More iterations for statistical significance
./benchmark-node-vs-bun.sh -r 5
```

### CI/CD Integration
```bash
# Automated run without prompts
./benchmark-node-vs-bun.sh --no-confirm -r 3 > benchmark.log
```

## Example Results File

The output file contains the complete benchmark run:

```
benchmark-results-20260120-203000.txt
- Full console output
- All individual timing measurements
- Comparison table
- Summary with speedup calculations
- Timestamp and environment info
```

## Dependencies

Required commands:
- `git` - Version control
- `node` - Node.js runtime
- `npm` - Node package manager
- `bun` - Bun runtime
- `curl` - HTTP testing
- `bc` - Floating point calculations

All are checked during prerequisites verification.

## Notes

- **Cache-free testing**: Each run starts completely clean
- **Real-world simulation**: Tests actual developer workflow
- **Fair comparison**: Identical conditions for both runtimes
- **Multiple iterations**: Reduces impact of system variability
- **Comprehensive**: Covers install, dev, build, and lint workflows

## Future Enhancements

Potential additions:
- Memory usage tracking
- CPU usage monitoring
- Warm cache testing (vs current cold cache only)
- Build size comparison
- Link checker performance (currently excluded as too slow)
- Graph/chart generation

## Contributing

If you find issues or have suggestions:
1. Test the script thoroughly
2. Document the issue
3. Propose improvements
4. Submit with test results

---

For questions or issues with the benchmark script, refer to this documentation or examine the script comments.
