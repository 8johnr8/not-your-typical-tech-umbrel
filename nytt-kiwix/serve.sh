#!/bin/sh
# Keeps a kiwix library in sync with the ZIM files found in $ZIM_DIR and serves it.

ZIM_DIR="${ZIM_DIR:-/data}"
RESCAN_INTERVAL="${RESCAN_INTERVAL:-60}"
STATE_DIR=/tmp/kiwix
LIBRARY="$STATE_DIR/library.xml"

mkdir -p "$STATE_DIR"

# Rebuilds the library only when a ZIM file was added, removed or changed. Size and
# modification time are part of the fingerprint so a ZIM that was still downloading on
# the previous scan is picked up once it finishes.
sync_library() {
  find -L "$ZIM_DIR" -type f -iname '*.zim' -exec stat -c '%s %Y %n' {} + 2>/dev/null | sort > "$STATE_DIR/zims.new"

  if [ -f "$LIBRARY" ] && cmp -s "$STATE_DIR/zims.new" "$STATE_DIR/zims"; then
    rm -f "$STATE_DIR/zims.new"
    return
  fi

  rm -f "$STATE_DIR/library.new.xml"
  count=0
  while IFS= read -r line; do
    zim="${line#* * }"
    if kiwix-manage "$STATE_DIR/library.new.xml" add "$zim" >/dev/null 2>&1; then
      count=$((count + 1))
    else
      echo "Skipping unreadable ZIM file (incomplete download?): $zim"
    fi
  done < "$STATE_DIR/zims.new"

  if [ ! -f "$STATE_DIR/library.new.xml" ]; then
    printf '<library version="20110515">\n</library>\n' > "$STATE_DIR/library.new.xml"
  fi

  mv "$STATE_DIR/library.new.xml" "$LIBRARY"
  mv "$STATE_DIR/zims.new" "$STATE_DIR/zims"

  if [ "$count" -eq 0 ]; then
    echo "No ZIM files found in the selected folder yet. Add some with the Files app; they will show up automatically."
  else
    echo "Serving $count ZIM file(s)."
  fi
}

sync_library

kiwix-serve --port=8080 --library --monitorLibrary "$LIBRARY" &
server_pid=$!

while kill -0 "$server_pid" 2>/dev/null; do
  sleep "$RESCAN_INTERVAL"
  sync_library
done

wait "$server_pid"
exit $?
