# Benchmark Script Plan: Node.js/npm vs Bun

## Overview
Create a standalone bash script that automates performance comparison between the master branch (Node.js/npm) and the feature/bun-migration branch (Bun).

## Script Name
`benchmark-node-vs-bun.sh`

## Features

### 1. Prerequisites Check
- Verify we're in the sq-web repository
- Check that `node` and `npm` are installed
- Check that `bun` is installed
- Verify both branches exist (master, feature/bun-migration)
- Check for required commands: `git`, `curl`, `bc` (for math)
- Save current branch and git state for restoration

### 2. Test Functions

#### 2.1 Clean Environment Function
```bash
clean_env() {
  - Remove node_modules/
  - Remove package-lock.json / bun.lockb
  - Remove public/ and resources/ directories
  - Kill any running Hugo processes on port 1313
}
```

#### 2.2 Install Benchmark Function
```bash
benchmark_install() {
  - Run install command (npm install or bun install)
  - Measure wall-clock time using `time` command
  - Capture real, user, sys times
  - Count number of packages installed
  - Measure node_modules size
  - Record lockfile size
}
```

#### 2.3 Server Startup Benchmark Function
```bash
benchmark_server_start() {
  - Clean build artifacts
  - Start server in background
  - Record start time
  - Poll localhost:1313 with curl until server responds (max 120s timeout)
  - Record time when server first responds with HTTP 200
  - Calculate startup duration
}
```

#### 2.4 Site Verification Function
```bash
verify_site() {
  - Check homepage (/) returns HTTP 200
  - Verify HTML contains expected content:
    * "sq" in title or body
    * Valid HTML structure (has <html>, <body>, etc.)
    * CSS and JS assets load (check for .css and .js references)
  - Check a docs page (/docs/) returns HTTP 200
  - Record success/failure for each check
}
```

#### 2.5 Cleanup Function
```bash
cleanup() {
  - Find and kill Hugo server process
  - Wait for port 1313 to be free
  - Remove build artifacts
}
```

### 3. Test Execution Flow

#### Phase 1: Test Master Branch (Node.js/npm)
```
1. Checkout master branch
2. Clean environment
3. Benchmark npm install (3 runs for average)
4. Benchmark server startup (3 runs for average)
5. Verify site functionality
6. Cleanup
7. Store results
```

#### Phase 2: Test Feature Branch (Bun)
```
1. Checkout feature/bun-migration branch
2. Clean environment
3. Benchmark bun install (3 runs for average)
4. Benchmark server startup (3 runs for average)
5. Verify site functionality
6. Cleanup
7. Store results
```

#### Phase 3: Compare Results
```
1. Calculate averages for each metric
2. Calculate percentage improvements
3. Create comparison table
4. Generate summary
```

### 4. Output Format

#### Console Output (stdout)
```
===========================================
 Node.js/npm vs Bun Performance Benchmark
===========================================

Testing Environment:
- Repository: sq-web
- Node.js Version: vX.X.X
- npm Version: X.X.X
- Bun Version: X.X.X
- Date: YYYY-MM-DD HH:MM:SS

-------------------------------------------
Phase 1: Testing master (Node.js/npm)
-------------------------------------------
[1/3] Install attempt 1... XX.XXs
[2/3] Install attempt 2... XX.XXs
[3/3] Install attempt 3... XX.XXs
Average install time: XX.XXs

[1/3] Server start attempt 1... XX.XXs
[2/3] Server start attempt 2... XX.XXs
[3/3] Server start attempt 3... XX.XXs
Average server start: XX.XXs

Site verification:
✓ Homepage loads (HTTP 200)
✓ Homepage contains expected content
✓ Docs page loads (HTTP 200)
✓ CSS/JS assets referenced

Metrics:
- Packages installed: XXX
- node_modules size: XXX MB
- Lockfile size: XXX MB

-------------------------------------------
Phase 2: Testing feature/bun-migration (Bun)
-------------------------------------------
[Similar output as Phase 1]

-------------------------------------------
Performance Comparison
-------------------------------------------

| Metric              | npm (master) | Bun (feature) | Improvement |
|---------------------|--------------|---------------|-------------|
| Install Time        | XX.XXs       | XX.XXs        | XX.X% faster|
| Server Start Time   | XX.XXs       | XX.XXs        | XX.X% faster|
| node_modules Size   | XXX MB       | XXX MB        | XX.X% smaller|
| Lockfile Size       | X.X MB       | X.X MB        | XX.X% smaller|

Summary:
✓ Bun is XX.Xx faster at installing dependencies
✓ Bun is XX.Xx faster at server startup
✓ Both versions successfully serve the site
✓ All site verification checks passed

Results saved to: benchmark-results-TIMESTAMP.txt
```

#### File Output
- Filename: `benchmark-results-YYYYMMDD-HHMMSS.txt`
- Contains: Same content as console output
- Location: Repository root directory
- Format: Plain text with box drawing characters for tables

### 5. Error Handling

- **Branch doesn't exist**: Exit with error message
- **Install fails**: Record error, continue to next test if possible
- **Server fails to start**: Record error after timeout (120s)
- **Site verification fails**: Record which checks failed, continue
- **Port 1313 busy**: Attempt to kill process, retry once
- **Git state restoration fails**: Warn user about manual cleanup needed

### 6. Safety Features

- **Stash uncommitted changes** before switching branches
- **Restore original branch** at end
- **Restore git state** (pop stash if created)
- **Cleanup trap** to ensure cleanup runs even if script interrupted (Ctrl+C)
- **Confirmation prompt** (optional flag `--no-confirm` to skip)
- **Dry-run mode** (optional flag `--dry-run` to show what would be done)

### 7. Script Options

```bash
Usage: ./benchmark-node-vs-bun.sh [OPTIONS]

Options:
  -h, --help           Show this help message
  -n, --no-confirm     Skip confirmation prompt
  -d, --dry-run        Show what would be done without executing
  -r, --runs N         Number of test runs per metric (default: 3)
  -t, --timeout N      Server startup timeout in seconds (default: 120)
  -v, --verbose        Show detailed output during tests
```

### 8. Testing Approach

#### Multiple Runs
- Default: 3 runs per test
- Calculates average and shows all individual runs
- Helps account for system variability
- First run may be slower due to cold start (noted in results)

#### Clean Slate
- Each test run starts with completely clean environment
- No cached data between runs
- Ensures fair comparison

#### Real-World Simulation
- Tests actual developer workflow:
  1. Clone/checkout
  2. Install dependencies
  3. Start dev server
  4. Verify site works

## Implementation Considerations

### Timing Accuracy
- Use `/usr/bin/time -p` for precise timing
- Use `date +%s.%N` for nanosecond precision (if available)
- Fallback to `date +%s` for second precision

### Server Ready Detection
- Poll with curl in a loop
- Check for HTTP 200 response
- Timeout after configured seconds (default 120)
- Don't just check if process started, verify server is actually serving

### Process Management
- Use `jobs -p` to track background processes
- Kill using PID, not `pkill` (more precise)
- Wait for port to be free before next test

### Cross-Platform Compatibility
- Use `/usr/bin/time` instead of bash `time` builtin (more portable)
- Check for GNU vs BSD `time` differences
- Use `curl` instead of `wget` (more common on macOS)
- Handle differences in `du` command (macOS vs Linux)

## Example Output Structure

```
benchmark-results-20260120-203000.txt
│
├── Environment Info
├── Master Branch Results
│   ├── Install Times (3 runs + average)
│   ├── Server Start Times (3 runs + average)
│   ├── Site Verification Results
│   └── Metrics (sizes, package count)
├── Feature Branch Results
│   ├── Install Times (3 runs + average)
│   ├── Server Start Times (3 runs + average)
│   ├── Site Verification Results
│   └── Metrics (sizes, package count)
├── Comparison Table
└── Summary
```

## Script Size Estimate
- Approximately 400-500 lines
- Well-commented
- Modular functions
- Easy to maintain and extend

## Advantages of This Approach

1. **Fully Automated** - No manual intervention required
2. **Reproducible** - Same test conditions every time
3. **Fair Comparison** - Clean slate for each test
4. **Real-World** - Tests actual developer workflow
5. **Comprehensive** - Measures multiple metrics
6. **Safe** - Restores original state
7. **Documented** - Results saved to file
8. **Verifies Functionality** - Not just speed, but correctness

## Questions for Review

1. Should we test on a cold cache (first install) vs warm cache (subsequent installs)?
2. Do you want to include build time benchmarks as well?
3. Should we test with Hugo module updates (`hugo mod get`)?
4. Do you want memory usage metrics during server runtime?
5. Should we include a visual graph/chart in the output (using ASCII art)?
6. Do you want to test linting performance as well?

Please review and let me know if you'd like any adjustments to the plan!
