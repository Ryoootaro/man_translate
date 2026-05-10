#!/bin/bash
# man-translate.sh - manページをOllamaで日本が翻訳するスクリプト

# Ollamaが起動しているか確認
if ! ollama list &>/dev/null; then
    echo "Ollamaが見つからないか起動していません"
    echo " 'ollama serve'で起動してください'"
    exit 1
fi

# 利用可能な最初のモデルを取得
MODEL="mistral:latest"

# 入力ファイルまたは標準入力から取得
if [ -n "${1:-}" ] && [ -f "$1" ]; then
    CONTENT=$(cat "$1")
else
    CONTENT=$(cat)
fi

if [ -z "$CONTENT" ]; then
    echo "翻訳するコンテンツがありません"
    exit 1
fi

# 長すぎる場合は先頭部分だけ使う（トークン節約）
MAX_CHARS=8000
if [ ${#CONTENT} -gt $MAX_CHARS ]; then
  CONTENT="${CONTENT:0:$MAX_CHARS}"$'\n\n...(長いため省略されました)'
fi
 
PROMPT="以下はLinuxのmanページの内容です。日本語に翻訳してください。
ルール:
- コマンド名・オプション名・ファイルパスなどの技術用語はそのまま残す
- セクション構造（NAME, SYNOPSIS, DESCRIPTION など）は日本語に訳す
- 読みやすく整形する
 
manページの内容:
---
${CONTENT}
---"
 
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📖 manページ 日本語翻訳  [モデル: $MODEL]"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

ollama run "$MODEL" "$PROMPT"