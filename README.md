# man_translate

`man` ページを `Ollama` で日本語に翻訳するための小さなツール集です。

- `man-translate.sh`: `man` ページの内容を日本語に翻訳するスクリプト
- `man-pager.sh`: `less` で `man` を表示しながら、キー操作で翻訳を開くカスタムページャー

## 必要なもの

- macOS / Linux
- `bash`
- `less`
- `mktemp`
- `realpath`
- `col`
- [`Ollama`](https://ollama.com/)
- `Ollama` 上で利用できるモデル

このリポジトリのスクリプトは `mistral:latest` を使う前提になっています。

## セットアップ

1. `Ollama` をインストールします。
2. `Ollama` を起動します。

```bash
ollama serve
```

3. 必要なモデルを取得します。

```bash
ollama pull mistral:latest
```

4. スクリプトに実行権限を付けます。

```bash
chmod +x man-translate.sh man-pager.sh
```

5. 必要なら `PATH` の通った場所に配置します。

```bash
mkdir -p ~/.local/bin
cp man-translate.sh man-pager.sh ~/.local/bin/
chmod +x ~/.local/bin/man-translate.sh ~/.local/bin/man-pager.sh
```

## 使い方

### 1. `man` の出力を直接翻訳する

```bash
man ls | ./man-translate.sh
```

ファイルを渡すこともできます。

```bash
./man-translate.sh man.txt
```

### `manj malloc` のように使う

この環境では、`~/.zshrc` に `manj` 関数が定義されていました。`man` の出力を整形して一時ファイルに保存し、翻訳結果を `less` で開く形です。

```bash
manj() {
  local tmpfile=$(mktemp /tmp/man-translate-XXXXXX)
  man "$@" | col -bx > "$tmpfile"
  ~/.local/bin/man-translate.sh "$tmpfile" | less -R
  rm -f "$tmpfile"
}
```

この定義があれば、次のように使えます。

```bash
manj malloc
manj printf
```

`~/.zshrc` に追加したあとは、`source ~/.zshrc` を実行するかシェルを開き直してください。

## 2. `man` 閲覧中に翻訳を開く

`MANPAGER` に `man-pager.sh` を指定すると、`man` 表示中に `t` または `T` キーで翻訳を開けます。

```bash
export MANPAGER="/absolute/path/to/man-pager.sh"
man ls
```

毎回設定したくない場合は、`~/.zshrc` などに追記してください。

```bash
export MANPAGER="/absolute/path/to/man-pager.sh"
```

## 動作の流れ

1. `man` の内容を受け取る
2. 長すぎる場合は先頭約 8000 文字に切り詰める
3. `Ollama` に翻訳プロンプトを渡す
4. 日本語訳を標準出力に表示する

`man-pager.sh` を使う場合は、一時ファイルに `man` の内容を保存し、`less` のキーバインドから `man-translate.sh` を呼び出します。

## 注意点

- `Ollama` が起動していない場合は動作しません。
- モデル名は `man-translate.sh` 内の `MODEL="mistral:latest"` で固定されています。
- 長い `man` ページは一部省略して翻訳します。
- 翻訳品質は使用モデルに依存します。

## ライセンス

ライセンス表記がまだないため、必要なら追加してください。
