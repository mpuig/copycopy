#!/usr/bin/env bash
# Diagnostic script for CopyCopy double-copy issue

echo "🔍 CopyCopy Double-Copy Diagnostic"
echo "===================================="
echo ""

# 1. Check if app is running
if pgrep -x CopyCopy > /dev/null; then
    echo "✅ CopyCopy is running (PID: $(pgrep -x CopyCopy))"
else
    echo "❌ CopyCopy is NOT running"
    echo "   Please start the app first"
    exit 1
fi

echo ""
echo "📋 Accessibility Permission:"
echo "   Checking if app is authorized in TCC database..."
if [ "$EUID" -ne 0 ]; then
    # Non-root user: check if we can query (macOS Sonoma+)
    if command -v tccutil &> /dev/null; then
        if tccutil list Accessibility 2>&1 | grep -q "com.copycopy.CopyCopy"; then
            echo "✅ Accessibility permission granted"
        else
            echo "❌ Accessibility NOT granted in database"
            echo "   → This is why double-⌘C doesn't work!"
        fi
    else
        echo "⚠️  Cannot check permissions (older macOS)"
    fi
else
    echo "⚠️  Running as root - skipping permission check"
fi

echo ""
echo "📝 Console Logs (last 60 seconds):"
log show --predicate 'process == "CopyCopy"' --last 60s --style compact 2>&1 | grep -E "CopyEvent|AppModel|Accessibility|trigger" || echo "   No recent logs found"

echo ""
echo "⚙️  App Preferences:"
echo "   doubleCopyThresholdMs: $(defaults read com.copycopy.CopyCopy doubleCopyThresholdMs 2>/dev/null || echo "not set")"
echo "   openPopoverOnDoubleCopy: $(defaults read com.copycopy.CopyCopy openPopoverOnDoubleCopy 2>/dev/null || echo "not set")"
echo "   debugMenuEnabled: $(defaults read com.copycopy.CopyCopy debugMenuEnabled 2>/dev/null || echo "not set")"

echo ""
echo "💡 Next Steps:"
echo "   1. If permissions missing: Run ./scripts/reset_permissions.sh"
echo "   2. If no logs: Try restarting CopyCopy"
echo "   3. Check Console.app for error messages"
echo "   4. Right-click menu bar icon → Settings → Debug tab"
