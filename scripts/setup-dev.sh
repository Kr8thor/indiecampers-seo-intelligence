#!/bin/bash
# Development environment setup script for IndieCampers SEO Intelligence

set -e  # Exit on error

echo ""
echo "🚀 Setting up IndieCampers SEO Intelligence development environment..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ============================================
# Check prerequisites
# ============================================
echo "📋 Checking prerequisites..."

# Check Node.js
if command -v node >/dev/null 2>&1; then
  NODE_VERSION=$(node --version)
  echo -e "${GREEN}✅ Node.js installed: $NODE_VERSION${NC}"
else
  echo -e "${RED}❌ Node.js is required but not installed.${NC}"
  echo "   Please install Node.js 18+ from https://nodejs.org/"
  exit 1
fi

# Check Git
if command -v git >/dev/null 2>&1; then
  GIT_VERSION=$(git --version)
  echo -e "${GREEN}✅ Git installed: $GIT_VERSION${NC}"
else
  echo -e "${RED}❌ Git is required but not installed.${NC}"
  echo "   Please install Git from https://git-scm.com/"
  exit 1
fi

# Check Python (for JSON validation)
if command -v python3 >/dev/null 2>&1; then
  PYTHON_VERSION=$(python3 --version)
  echo -e "${GREEN}✅ Python3 installed: $PYTHON_VERSION${NC}"
else
  echo -e "${YELLOW}⚠️  Python3 not found (optional, used for JSON validation)${NC}"
fi

echo ""

# ============================================
# Install dependencies
# ============================================
if [ -f package.json ]; then
  echo "📦 Installing npm dependencies..."

  if command -v npm >/dev/null 2>&1; then
    npm install
    echo -e "${GREEN}✅ Dependencies installed${NC}"
  else
    echo -e "${YELLOW}⚠️  npm not found, skipping dependency installation${NC}"
  fi
else
  echo -e "${YELLOW}⚠️  package.json not found, skipping npm install${NC}"
fi

echo ""

# ============================================
# Setup environment file
# ============================================
if [ ! -f .env ]; then
  if [ -f .env.example ]; then
    echo "📝 Creating .env file from template..."
    cp .env.example .env
    echo -e "${GREEN}✅ .env file created${NC}"
    echo -e "${YELLOW}⚠️  Please edit .env with your actual credentials${NC}"
  else
    echo -e "${YELLOW}⚠️  .env.example not found, skipping .env creation${NC}"
  fi
else
  echo -e "${GREEN}✅ .env file already exists${NC}"
fi

echo ""

# ============================================
# Validate workflow files
# ============================================
echo "🔍 Validating workflow files..."

WORKFLOW_ERRORS=0

if [ -d workflows ]; then
  for file in workflows/*.json; do
    if [ -f "$file" ]; then
      if command -v python3 >/dev/null 2>&1; then
        if python3 -m json.tool "$file" > /dev/null 2>&1; then
          echo -e "${GREEN}✅ $file is valid JSON${NC}"
        else
          echo -e "${RED}❌ $file has JSON syntax errors${NC}"
          WORKFLOW_ERRORS=$((WORKFLOW_ERRORS + 1))
        fi
      else
        echo -e "${YELLOW}⚠️  Cannot validate $file (Python3 not available)${NC}"
      fi
    fi
  done
else
  echo -e "${YELLOW}⚠️  workflows directory not found${NC}"
fi

echo ""

# ============================================
# Run tests (if available)
# ============================================
if [ -f tests/integration-test.js ]; then
  echo "🧪 Running integration tests..."

  if node tests/integration-test.js; then
    echo -e "${GREEN}✅ All tests passed${NC}"
  else
    echo -e "${RED}❌ Some tests failed${NC}"
    echo "   Please review test output above"
  fi
else
  echo -e "${YELLOW}⚠️  Integration tests not found, skipping${NC}"
fi

echo ""

# ============================================
# Create necessary directories
# ============================================
echo "📁 Creating necessary directories..."

mkdir -p scripts
mkdir -p tests
mkdir -p workflows
mkdir -p docs

echo -e "${GREEN}✅ Directories created${NC}"

echo ""

# ============================================
# Setup Git hooks (if in git repo)
# ============================================
if [ -d .git ]; then
  echo "🔗 Setting up Git hooks..."

  # Create pre-commit hook
  HOOK_FILE=".git/hooks/pre-commit"

  cat > "$HOOK_FILE" << 'EOF'
#!/bin/sh
# Pre-commit hook for IndieCampers SEO Intelligence

echo "🔍 Running pre-commit checks..."

# Validate workflow JSON files
for file in workflows/*.json; do
  if [ -f "$file" ]; then
    if ! python3 -m json.tool "$file" > /dev/null 2>&1; then
      echo "❌ Invalid JSON: $file"
      exit 1
    fi
  fi
done

# Check for secrets
if git diff --cached --name-only | xargs grep -l "sk-\|password.*=.*['\"].\{8,\}\|eyJhbGc" 2>/dev/null; then
  echo "❌ Possible secrets detected! Please review and remove."
  exit 1
fi

echo "✅ Pre-commit checks passed"
EOF

  chmod +x "$HOOK_FILE"
  echo -e "${GREEN}✅ Git pre-commit hook installed${NC}"
else
  echo -e "${YELLOW}⚠️  Not a git repository, skipping Git hooks setup${NC}"
fi

echo ""

# ============================================
# Summary and next steps
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Development environment setup complete!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 Next steps:"
echo ""
echo "1. Edit .env with your credentials:"
echo "   nano .env"
echo ""
echo "2. Review documentation:"
echo "   - README.md - Project overview"
echo "   - docs/SETUP.md - Detailed setup guide"
echo "   - docs/QUICK_START.md - Quick start guide"
echo ""
echo "3. Validate your setup:"
echo "   npm test"
echo "   npm run validate:all"
echo ""
echo "4. Import workflow to n8n:"
echo "   - Open n8n dashboard"
echo "   - Workflows → Add Workflow → Import from File"
echo "   - Select workflows/Authority_Collector_Supabase.json"
echo ""
echo "5. Configure credentials in n8n:"
echo "   - DataForSEO API"
echo "   - Supabase"
echo "   - Slack (optional)"
echo ""

if [ $WORKFLOW_ERRORS -gt 0 ]; then
  echo -e "${YELLOW}⚠️  Warning: $WORKFLOW_ERRORS workflow file(s) have JSON errors${NC}"
  echo "   Please fix these before importing to n8n"
  echo ""
fi

echo "Need help? Check docs/ directory or open a GitHub issue"
echo ""
