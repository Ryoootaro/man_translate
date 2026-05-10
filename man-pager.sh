#!/bin/bash
#man-pager.sh - manのカスタムページャー
#lessでmanを表示し, Tキーで日本語訳を別画面で開く

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
TRANSLATE_SCRIPT="$SCRIPT_DIR/man-translate.sh"

# man-translate.shの場所を確認
if [ ! -x "$TRANSLATE_SCRIPT" ]; then
    # フォールバック: PATHから探す
    TRANSLATE_SCRIPT="$(command -v man-translate.sh 2>/dev/null || echo "")"
    if [ -z "$TRANSLATE_SCRIPT" ]; then
        echo "man-translate.shが見つかりません"
        exit 1
    fi
fi

# manの内容を一時ファイルに保存
TMPFILE=$(mktemp /tmp/man-content-XXXXXX.txt)
trap 'rm -f $TMPFILE' EXIT

cat > "$TMPFILE"

# lessキーバインド設定ファイルを一時生成
LESSKETFILE=$(mktemp /tmp/lesskey-XXXXXX)
trap 'rm -f "$TMPFILE" "$LESSKEYFILE"' EXIT

# lesskey形式でTキーに翻訳コマンドを割り当て
# !コマンド: lessの中でシェルコマンドを実行
cat > "$LESSKEYFILE" << EOF
#command
t !$TRANSLATE_SCRIPT $TMPFILE | less -R
T !$TRANSLATE_SCRIPT $TMPFILE | less -R
EOF

lesskey -o "${LESSKEYFILE}.bin" "$LESSKEYFILE" 2>/dev/null || true

echo "" >> "$TMPFILE"
echo "──────────────────────────────────────────────────" >> "$TMPFILE"
echo "  💡 ヒント: [t] または [T] キーで日本語翻訳を表示" >> "$TMPFILE"
echo "──────────────────────────────────────────────────" >> "$TMPFILE"

# lessで表示(-R: ANSIカラー対応, lesskey設定を読み込む)
if [ -f "${LESSKEYFILE}.bin" ]; then
    LESSKEY="${LESSKEYFILE}.bin" less -R "$TMPFILE"
else
    # lesskeyが使えない環境向けフォールバック
    # !コマンドで代替(lessの中で !<command> を打つと実行できる)
    less -R "$TMPFILE"
fi
