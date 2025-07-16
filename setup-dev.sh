#!/bin/bash
# Development environment setup script
# This script sets up pre-commit hooks and development dependencies

set -e

echo "🚀 Setting up development environment..."

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "📦 Creating Python virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "🔄 Activating virtual environment..."
source venv/bin/activate

# Install Python dependencies
echo "📥 Installing Python dependencies..."
pip install -r requirements.txt

# Install pre-commit hooks
echo "🪝 Installing pre-commit hooks..."
pre-commit install

# Run pre-commit on all files to ensure everything is set up correctly
echo "🔍 Running pre-commit on all files..."
pre-commit run --all-files || {
    echo "⚠️  Some pre-commit checks failed. This is normal for first-time setup."
    echo "📝 Please fix any issues and commit your changes."
}

echo "✅ Development environment setup complete!"
echo ""
echo "Next steps:"
echo "1. Activate the virtual environment: source venv/bin/activate"
echo "2. Run security scans manually: make check-security"
echo "3. Pre-commit hooks will now run automatically on each commit"
echo "4. Run pre-commit manually: pre-commit run --all-files"
