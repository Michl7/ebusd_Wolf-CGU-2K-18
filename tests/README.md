# tests

Offline tests of [`config/encon/08.csv`](../config/encon/08.csv). They need only an ebusd binary (≥ 24.1), no eBUS adapter: ebusd is started with an unreachable device and `--inject=stop`, decodes the given telegrams and stops.

| Script | What it checks | Expected output |
|---|---|---|
| [`inject-test.sh`](inject-test.sh) | device identification (manufacturer 0x40, empty ID → `encon/08.csv`) and one telegram per message with typical values | [`expected.txt`](expected.txt) |
| [`replay-test.sh`](replay-test.sh) | 390 **real** telegrams from [`raw/telegrams-24h.txt`](../raw/telegrams-24h.txt) – every message of the configuration occurs | [`expected-replay.txt`](expected-replay.txt): 390 decoded, 0 unknown |

## Result (October 2026, ebusd 26.1)

The real telegrams were decoded with this configuration **and** with the configuration that has been running on the test installation since October 2026 (German names, values shown in Home Assistant). All 390 telegrams gave **identical values** in both configurations.
