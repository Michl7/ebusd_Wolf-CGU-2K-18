#!/bin/sh
# Offline test of config/encon/08.csv without an eBUS adapter.
# Injects telegrams into ebusd and prints the decoded values.
# Usage: tests/inject-test.sh [path/to/ebusd]   (ebusd >= 24.1)
#
# Telegram format: master part / slave part  (QQ ZZ PB SB NN DD.. / NN DD..)
# The values are typical values of the test installation (see tests/expected.txt).

EBUSD=${1:-ebusd}
CONFIG=$(cd "$(dirname "$0")/../config" && pwd)
TMP=${TMPDIR:-/tmp}

echo "== device identification (expect: encon/08.csv for ID \"\") =="
"$EBUSD" --checkconfig --configpath="$CONFIG" --scanconfig --inject=stop \
  "FF08070400/0A40011c002001ffffffff" 2>&1 | grep -E "scan config|found messages|ERR"

echo "== decoding =="
timeout 15 "$EBUSD" -f --configpath="$CONFIG" --scanconfig=off -d tcp:127.0.0.1:1 --readonly \
  --pidfile="$TMP/ebusd-inject-test.pid" --log=all:notice --inject=stop \
  "03fe050308010779648c80ffd8/" \
  "03fe050308020779648c80ffd8/" \
  "03f1080008003e00d800180037/00" \
  "f103050709bb04a0050080ff6eff/00" \
  "f103080008005a005a00120037/00" \
  "03fefe010a45303038202020202020/" \
  "3108502203000d00/02c201" "3108502203005803/02d601" "3108502203005903/021e02" \
  "3108502203000200/026c02" "3108502203000300/022602" "3108502203000c00/0270fe" \
  "3108502203000100/020000" "3108502203009303/02b300" \
  "3108502203002200/025000" "3108502203005a01/026400" "3108502203005901/02ff00" \
  "3108502203003f01/028000" "310850220300000a/021400" "3108502203004101/020000" \
  "3108502203004201/021e00" "3108502203002700/02bc02" "3108502203004301/020700" \
  "3108502203005b0a/020100" "310850220300bf0a/020800" "3108502203004001/023200" \
  "3108502203005501/022d00" "3108502203005601/025000" \
  "3108502203007801/020100" "3108502203006a01/026400" "3108502203006b01/020100" "3108502203001f00/029001" \
  "3108502203002602/029c7b" "3108502203002802/02ede5" "3108502203002a02/028409" \
  "3108502203003d02/02081f" "3108502203003e02/02d0e5" \
  2>&1 | grep -E "received (update-)?read|unknown" | sed 's/^.*\] //'
