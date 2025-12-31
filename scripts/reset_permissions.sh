#!/usr/bin/env bash
# Reset and re-enable CopyCopy permissions

echo "🔄 CopyCopy Permission Reset Script"
echo "=================================="
echo ""

# Kill CopyCopy if running
pkill -x CopyCopy 2>/dev/null && echo "✅ Killed CopyCopy process" || echo "ℹ️  CopyCopy not running"

# Remove from TCC database
echo ""
echo "🗑️  Removing from Accessibility..."
sudo tccutil reset Accessibility com.copycopy.CopyCopy 2>/dev/null || true

echo "🗑️  Removing from Input Monitoring..."
sudo tccutil reset InputMonitoring com.copycopy.CopyCopy 2>/dev/null || true

echo ""
echo "✅ Permissions reset"
echo ""
echo "📝 Next steps:"
echo "1. Open System Settings → Privacy & Security"
echo "2. Go to Accessibility → Click + → Add CopyCopy from /Applications"
echo "3. Toggle CopyCopy ON"
echo "4. Also do the same for Input Monitoring if needed"
echo "5. Restart CopyCopy"
