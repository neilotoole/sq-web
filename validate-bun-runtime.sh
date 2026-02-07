#!/bin/bash
#
# validate-bun-runtime.sh
#
# Quick validation script to test that all Bun scripts work correctly
# after migrating from Node.js/npm to Bun.
#
# Usage: ./validate-bun-runtime.sh
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0

print_test() {
    echo -e "${YELLOW}Testing:${NC} $1"
}

print_pass() {
    echo -e "${GREEN}✓ PASS:${NC} $1"
    PASSED=$((PASSED + 1))
}

print_fail() {
    echo -e "${RED}✗ FAIL:${NC} $1"
    FAILED=$((FAILED + 1))
}

echo "========================================"
echo " Bun Runtime Validation"
echo "========================================"
echo

# Check Bun is installed
print_test "Bun installation"
if command -v bun &> /dev/null; then
    BUN_VERSION=$(bun --version)
    print_pass "Bun installed (v$BUN_VERSION)"
else
    print_fail "Bun not installed"
    echo "Install Bun: curl -fsSL https://bun.sh/install | bash"
    exit 1
fi

# Check we're in the right directory
print_test "Project directory"
if [[ -f "package.json" ]] && command grep -q '"name": "sq.io"' package.json; then
    print_pass "In sq-web project directory"
else
    print_fail "Not in sq-web project directory"
    exit 1
fi

echo
echo "----------------------------------------"
echo " Installing dependencies"
echo "----------------------------------------"

print_test "bun install"
if bun install > /dev/null 2>&1; then
    print_pass "Dependencies installed"
else
    print_fail "bun install failed"
fi

echo
echo "----------------------------------------"
echo " Testing package.json scripts"
echo "----------------------------------------"

# Test: bun run check
print_test "bun run check (Hugo version)"
if bun run check > /dev/null 2>&1; then
    HUGO_VERSION=$(bun run --silent check 2>&1 | command grep -o 'hugo v[0-9.]*' | head -1)
    print_pass "Hugo check passed ($HUGO_VERSION)"
else
    print_fail "bun run check failed"
fi

# Test: bun run clean
print_test "bun run clean"
if bun run clean > /dev/null 2>&1; then
    print_pass "Clean completed"
else
    print_fail "bun run clean failed"
fi

# Test: bun run lint:scripts
print_test "bun run lint:scripts (ESLint)"
if bun run lint:scripts > /dev/null 2>&1; then
    print_pass "ESLint passed"
else
    print_fail "bun run lint:scripts failed"
fi

# Test: bun run lint:styles
print_test "bun run lint:styles (Stylelint)"
if bun run lint:styles > /dev/null 2>&1; then
    print_pass "Stylelint passed"
else
    print_fail "bun run lint:styles failed"
fi

# Test: bun run lint:markdown
print_test "bun run lint:markdown (markdownlint)"
if bun run lint:markdown > /dev/null 2>&1; then
    print_pass "markdownlint passed"
else
    print_fail "bun run lint:markdown failed"
fi

# Test: bun run build
print_test "bun run build (Hugo production build)"
if bun run build > /dev/null 2>&1; then
    if [[ -d "public" ]] && [[ -f "public/index.html" ]]; then
        PAGE_COUNT=$(find public -name "*.html" | wc -l | tr -d ' ')
        print_pass "Build completed ($PAGE_COUNT HTML files)"
    else
        print_fail "Build completed but public/ is missing or empty"
    fi
else
    print_fail "bun run build failed"
fi

# Verify public/_redirects exists
print_test "postbuild (_redirects appended)"
if [[ -f "public/_redirects" ]]; then
    print_pass "_redirects file exists"
else
    print_fail "public/_redirects missing"
fi

echo
echo "========================================"
echo " Summary"
echo "========================================"
echo
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"
echo

if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC} Bun migration is working correctly."
    exit 0
else
    echo -e "${RED}Some tests failed.${NC} Review the output above."
    exit 1
fi
