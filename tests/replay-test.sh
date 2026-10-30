#!/bin/sh
# Replays the real telegrams from raw/telegrams-24h.txt into ebusd and prints a summary of the decoded messages.
# Usage: tests/replay-test.sh [path/to/ebusd]   (tested with ebusd 26.1)
EBUSD=${1:-ebusd}
BASE=$(cd "$(dirname "$0")/.." && pwd)
TMP=${TMPDIR:-/tmp}
MSGS=$(grep -v '^#' "$BASE/raw/telegrams-24h.txt" | cut -d'|' -f2,3 | sed 's/^MM|\(.*\/\)$/\100/; s/^[A-Z]*|//')
# shellcheck disable=SC2086
timeout 60 "$EBUSD" -f --configpath="$BASE/config" --scanconfig=off -d tcp:127.0.0.1:1 --readonly \
  --pidfile="$TMP/ebusd-replay-test.pid" --log=all:notice --inject=stop $MSGS 2>&1 \
  | grep -E "received (update-)?read|unknown" | sed 's/^.*\] //; s/ QQ=31//' > "$TMP/ebusd-replay.out"
echo "decoded: $(grep -c 'read' "$TMP/ebusd-replay.out")  unknown: $(grep -c unknown "$TMP/ebusd-replay.out")"
sed 's/:.*//' "$TMP/ebusd-replay.out" | sort | uniq -c | sort -rn
