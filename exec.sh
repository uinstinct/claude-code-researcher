#!/bin/bash

read -p "Enter your Claude API key: " api_key

if [ -z "$api_key" ]; then
    echo "Error: API key cannot be empty"
    exit 1
fi

mkdir -p ~/.claude

if [ ! -f ~/.claude/settings.json ]; then
    cat > ~/.claude/settings.json << 'EOF'
{
  "apiKeyHelper": "~/.claude/anthropic_key.sh"
}
EOF
    echo "Created ~/.claude/settings.json"
else
    echo "~/.claude/settings.json already exists, skipping creation"
fi

cat > ~/.claude/anthropic_key.sh << EOF
#!/bin/bash
echo "$api_key"
EOF

chmod +x ~/.claude/anthropic_key.sh

echo "Setup complete!"
echo "- Settings file: ~/.claude/settings.json"
echo "- API key helper: ~/.claude/anthropic_key.sh (executable)"

