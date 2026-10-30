# ebusd configuration for Wolf CGU-2K-18

ebusd configuration and eBUS decoding for the **Wolf CGU-2K-18** gas combi boiler with **Wolf ART** room controller.

## What this repository is about

The CGU-2K-18 identifies itself on the eBUS as manufacturer 0x40 (ENCON) and is not covered by the official [ebusd-configuration](https://github.com/john30/ebusd-configuration). This repository provides everything needed to read its data with [ebusd](https://github.com/john30/ebusd):

- a ready-to-use, read-only ebusd configuration ([`config/encon/08.csv`](config/encon/08.csv)): burner status, flow and hot water temperatures, setpoints, error code, parameters HG01–HG21, counters and error history
- a documented decoding of the eBUS traffic: which telegram, byte and 5022 number means what, and how certain each finding is (✅ confirmed · 🟡 probable · ❓ unknown)
- examples for `ebusctl`, MQTT and Home Assistant, and offline tests with real telegrams

All findings come from observing one real installation (telegram log, 5022 scans, controlled tests on the ART and the boiler, gas meter readings) and from the Wolf installation manuals.

## Quick start

1. Copy the folder [`config/`](config/) to your ebusd host.
2. Start ebusd with `--configpath=/path/to/config` – it detects the boiler and loads `encon/08.csv`.
3. Read a value: `ebusctl read -f FlowTemp`.

Details: [config/README.md](config/README.md) and [docs/hardware-and-setup.md](docs/hardware-and-setup.md).

## Repository structure

| Path | Content |
|---|---|
| [`config/`](config/) | ebusd configuration (use as `--configpath`) and polling recommendation |
| [`docs/`](docs/) | eBUS decoding: telegrams, 5022 numbers, parameters, error codes, behaviour, open questions |
| [`examples/`](examples/) | query examples (`ebusctl`, MQTT, Home Assistant) |
| [`raw/`](raw/) | anonymised raw data (scan results, real telegrams) |
| [`tests/`](tests/) | offline tests of the configuration with injected and real telegrams |

## Contributing

Observations from other installations (other CGU/CGB models, firmware versions, outside or storage sensors) are welcome – see [docs/open-questions.md](docs/open-questions.md) and open an issue with your telegrams or 5022 values.

## Made with Claude

This repository and all analyses behind it – decoding of the telegram log, 5022 scans, evaluation of the tests, configuration, documentation and examples – were created together with [Claude](https://claude.ai) (Anthropic), an AI assistant. The tests on the boiler and the ART were carried out and checked by a human on the real installation.

## Disclaimer

This is an independent community project. It is **not affiliated with, endorsed by or supported by** Wolf GmbH or any other manufacturer. All product names and trademarks belong to their respective owners.

The information was obtained by observing the eBUS of one installation. It may be incomplete or wrong for other devices, firmware versions or configurations. **Use it at your own risk.**

The configuration only **reads** values. Writing parameters to the boiler (eBUS command 5023) is documented for reference only and is **not covered**: wrong values can cause malfunction or damage. Changes to boiler parameters should only be made by a qualified heating engineer.

## License

[GPL-3.0](LICENSE)
