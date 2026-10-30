# docs

Decoding of the eBUS traffic of a **Wolf CGU-2K-18** gas combi boiler with a **Wolf ART** room controller.

All findings come from one installation: eBUS telegram log (ebusd SQLite log), 5022 scans, controlled tests (changing parameters on the ART, chimney sweep mode, provoked error E008, hot water draws, gas meter readings) and the Wolf installation manuals of the boiler and the ART.

## Contents

| Document | Content |
|---|---|
| [hardware-and-setup.md](hardware-and-setup.md) | Devices, bus addresses, adapter, ebusd setup |
| [telegrams.md](telegrams.md) | Broadcasts and ART ↔ boiler telegrams: 0503, 0800, 0507, fe01, 0704 – byte layout, operating modes, status bits, operating status bit field |
| [5022-reference.md](5022-reference.md) | Manufacturer read command 5022: request format and all known numbers; parameter write 5023 (reference only) |
| [parameters.md](parameters.md) | Boiler parameters HG01–HG25: meaning, 5022 number, encoding |
| [errors.md](errors.md) | Error codes, error broadcast, error history |
| [behaviour.md](behaviour.md) | Observed behaviour: start phase, burner cycle lock, pump run-on, maximum temperatures, hot water, power-up |
| [standard-comparison.md](standard-comparison.md) | Comparison with the eBUS standard telegrams and the official Wolf file of ebusd-configuration; real device identification |
| [open-questions.md](open-questions.md) | Unknown and unconfirmed values – help welcome |

## Confidence legend

| Mark | Meaning |
|---|---|
| ✅ | **confirmed** – verified by a controlled test or by several independent observations |
| 🟡 | **probable** – consistent observations and plausible, but not proven |
| ❓ | **unknown** – value seen, meaning open |

## Conventions

- Hex values are written as `0x0d` or as byte sequences `08 50 22`.
- 16-bit values on the bus are little-endian (low byte first).
- Names in `code style` like `FlowTemp` are the message names of [`config/encon/08.csv`](../config/encon/08.csv).
- HGxx are the parameter codes of the boiler manual.
