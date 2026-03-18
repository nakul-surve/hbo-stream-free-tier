#!/bin/bash

echo "🧪 Testing HBO-Stream Application"
echo "=================================="

cd ../../terraform/environments/dev
ALB_DNS=$(terraform output -raw application_url 2>/dev/null)

echo ""
echo "Testing endpoints..."

# Test backend health
echo -n "Backend health: "
HEALTH=$(curl -s "${ALB_DNS}/api/health")
if echo "$HEALTH" | jq -e '.status == "healthy"' > /dev/null 2>&1; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
fi

# Test backend root
echo -n "Backend root: "
if curl -s "${ALB_DNS}/api/" | jq -e '.message == "HBO Stream API"' > /dev/null 2>&1; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
fi

# Test frontend
echo -n "Frontend: "
if curl -s "${ALB_DNS}/" | grep -q "HBO Stream" ; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
fi

# Test videos endpoint
echo -n "Videos API: "
if curl -s "${ALB_DNS}/api/videos" | jq -e 'type == "array"' > /dev/null 2>&1; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
fi

echo ""
echo "Application URL: ${ALB_DNS}"
echo ""
echo "Open in browser to see the UI!"
