# config

ebusd configuration for the **Wolf CGU-2K-18** (with Wolf ART). Only **reads** values.

## Installation

1. Copy this folder (with the subfolder `encon/`) to the ebusd host, or point ebusd to a checkout of this repository.
2. Start ebusd with the folder as configuration path:

   ```
   ebusd --configpath=/path/to/config ...
   ```

3. ebusd scans the boiler, finds manufacturer 0x40 (ENCON) with an empty device ID and loads `encon/08.csv`.
   Check the log for: `read scan config file encon/08.csv for ID ""`.

The file has been checked with ebusd 26.1 (`--checkconfig`) and with 394 real telegrams of the test installation, see [`tests/`](../tests/).

## Messages

| Circuit | Name | Source | Status |
|---|---|---|---|
| boiler | `BurnerStatus` (Mode, StatusBits, Power, FlowTemp) | broadcast 0503 | ✅ (StatusBits 08/30 🟡) |
| boiler | `BoilerStatus` (BoilerTempSetpoint, OutsideTemp, OperatingStatus, HwcTempSetpoint) | 0800 boiler → ART | ✅ (OutsideTemp 🟡) |
| boiler | `ErrorBroadcast` (text, e.g. `E008`) | broadcast fe01, only on change | ✅ |
| art | `ControllerStatus` (Status, FlowTempSetpoint A01, HwcTempSetpoint P03) | 0507 ART → boiler | ✅ |
| art | `ControllerData` (FlowTempSetpoint, HwcTempSetpoint P03) | 0800 ART → boiler | ✅ |
| boiler | `FlowTemp`, `HwcTemp`, `BoilerTempSetpoint`, `HwcTempSetpoint`, `ErrorStatus` | 5022 read | ✅ |
| boiler | `FlowTemp2`, `OutsideTemp` | 5022 read | 🟡 |
| boiler | `ModulationStatus` | 5022 read | 🟡 hypothesis |
| boiler | `HG01_…` – `HG17_…` (14 parameters visible on the ART) | 5022 read | ✅ |
| boiler | `HG10_EbusAddressStatus`, `HG11_HwcQuickStartTemp`, `HG12_GasTypeMode`, `HG21_BoilerTempMin` (not visible on the ART, numbers from the official Wolf file) | 5022 read | 🟡 |
| boiler | `BurnerStarts`, `OperatingHours` | 5022 read | ✅ |
| boiler | `BurnerHours` | 5022 read | 🟡 |
| boiler | `ErrorHistoryLastStatus`, `ErrorHistoryLastHours` | 5022 read | ✅ (extra byte ❓) |

✅ confirmed · 🟡 probable · ❓ unknown. Details in [`docs/`](../docs/).

Notes:
- HG02–HG04 are raw values 0–255: percent = raw / 2.55 (e.g. 128 = 50 %).
- `ErrorHistoryLastHours` is an operating hour, not a time stamp: the error happened about `OperatingHours − ErrorHistoryLastHours` hours ago (±1 h).
- After a boiler power-up, `BoilerStatus` reports 5 °C / 53 °C for about 40 s.

## Polling

All 5022 messages are defined as plain `r` (read on demand) – nothing is polled by default. The broadcasts arrive without polling.

ebusd polls messages that have a priority (`r1` … `r9`), one message every `--pollinterval` seconds (default 5–6 s per message). Every polled message makes the round longer: with 5 messages each value is read about every 30 s, with 20 messages only every ~2 min.

Recommended setup:

| Group | Messages | How |
|---|---|---|
| fast | `FlowTemp`, `FlowTemp2`, `HwcTemp`, `ErrorStatus`, `ModulationStatus` | change `r` to `r1` in your copy of the CSV |
| slow | HG parameters, counters, error history | read on demand, e.g. hourly via `ebusctl read -f <name>` or MQTT `ebusd/boiler/<name>/get` |

Keep the number of polled messages small – the bus is shared with the ART and the boiler.

## Home Assistant / MQTT

The message names contain words like `Temp`, `Status`, `Power`, `Mode`, `Timer`, `Hours` and `Starts`, so the default `mqtt-hassio.cfg` (`filter-name`) passes them. Text fields are not passed by the default configuration, therefore `ErrorBroadcast` does not appear in Home Assistant – use `ErrorStatus` (numeric error code) instead.

Important: with the default `mqtt-hassio.cfg`, the Home Assistant integration itself polls every known message with priority up to 5 (`filter-seen = 5`). To keep the bus quiet and use the polling setup above, start ebusd with `--mqttvar=filter-seen=1`.

## Not included

- Parameter writes (5023) – documented in `docs/` for reference only.
- Unknown 5022 numbers and installation-specific values.
