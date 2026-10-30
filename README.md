# ebusd_Wolf-CGU-2K-18

ebusd configuration CSV file for Wolf CGU-2K-18 with ART Thermostat

> 🚧 **Work in progress** – this repository is being prepared and will be made public once the items below are done.

## Repository structure

| Path | Content |
|---|---|
| [`config/`](config/) | ebusd configuration (use as `--configpath`) |
| [`docs/`](docs/) | eBUS decoding: telegrams, 5022 numbers, parameters, error codes |
| [`examples/`](examples/) | query examples (`ebusctl`, MQTT, Home Assistant) |
| [`raw/`](raw/) | anonymised raw data (scan results, sample telegrams) |
| [`tests/`](tests/) | offline test of the configuration with injected telegrams |

## Goal

Everything someone needs to read data from a **Wolf CGU-2K-18** gas combi boiler (with **Wolf ART** room controller) over eBUS with [ebusd](https://github.com/john30/ebusd):

- a general, ready-to-use ebusd configuration (CSV)
- a documented decoding of the eBUS traffic: which telegram, byte and number means what, and how certain each finding is
- examples how to query the values (`ebusctl`, MQTT)

All findings come from observing a real installation (telegram log, 5022 scans, controlled tests on the ART and the boiler, gas meter readings) and from the Wolf installation manuals.

## To-Do

### 1. Repository setup
- [x] Choose a license – GPL-3.0, same as [ebusd-configuration](https://github.com/john30/ebusd-configuration)
- [x] Define the folder structure (`config/`, `docs/`, `examples/`, `raw/`)
- [x] Add `.gitignore`
- [x] Add a disclaimer: no affiliation with Wolf, use at your own risk, writing parameters is not covered

### 2. ebusd configuration
- [x] Create a general [`encon/08.csv`](config/encon/08.csv) with **English** message and field names (manufacturer 0x40 = ENCON, boiler slave address 08)
- [x] Use neutral read types (`r`) and document a recommended polling setup separately ([config/README.md](config/README.md))
- [x] Remove installation-specific values and HA-only naming tricks – names chosen so that the default `mqtt-hassio.cfg` filter passes them
- [x] Include only **confirmed** values by default; mark probable values clearly in the comments; leave unknown numbers out
- [x] Broadcasts: 0503 (burner status), 0507 / 0800 (ART ↔ boiler), fe01 (error code)
- [x] 5022 reads: flow temperatures, DHW temperature, setpoints, error code, parameters HG01–HG17, counters, newest error history entry
- [x] Decide how to handle 5023 (parameter write): document only, no write definitions until tested
- [x] Offline test with ebusd 26.1: `--checkconfig` and injected telegrams ([tests/](tests/))
- [x] Test with real data of the installation: 390 real telegrams (24 h) replayed – identical values to the configuration running there ([tests/](tests/))

### 3. Documentation (English)
- [x] Hardware and bus participants (addresses 03/08, ART f1/30, adapter type) – [docs/hardware-and-setup.md](docs/hardware-and-setup.md)
- [x] Setup guide: ebusd options (`--configpath`, optional `--enablehex`), where to put the CSV – [docs/hardware-and-setup.md](docs/hardware-and-setup.md#ebusd-setup)
- [x] Telegram reference: 0503, 0507, 0800, fe01, 0704 with byte layout and bit fields – [docs/telegrams.md](docs/telegrams.md)
- [x] 5022 reference: request format (`xx LL HH`, first byte ignored), number list with confidence level – [docs/5022-reference.md](docs/5022-reference.md)
- [x] Parameter table HG01–HG25 with 5022 numbers and encoding – [docs/parameters.md](docs/parameters.md)
- [x] 5023 write format as observed from the ART (for reference only, with warning) – [docs/5022-reference.md](docs/5022-reference.md#5023--parameter-write-reference-only)
- [x] Operating modes and status bits (0503 byte 2/3), operating status bit field (0800 byte 6) – [docs/telegrams.md](docs/telegrams.md)
- [x] Error codes and error history format – [docs/errors.md](docs/errors.md)
- [x] Known behaviour: burner cycle lock (HG09), pump run-on (HG07), HG08 vs. HG22, hot water, power-up, gas estimate – [docs/behaviour.md](docs/behaviour.md)
- [x] Open questions / unknown values (so others can help) – [docs/open-questions.md](docs/open-questions.md)
- [x] Confidence legend (✅ confirmed · 🟡 probable · ❓ unknown) – [docs/README.md](docs/README.md#confidence-legend)

### 4. Examples
- [x] `ebusctl` read and hex query examples, MQTT topics – [examples/ebusctl.md](examples/ebusctl.md)
- [x] Home Assistant via MQTT discovery: setup, entity IDs, slow-value automation, template sensors (error text, last error, operating mode/status, gas), error notification – [examples/home-assistant/](examples/home-assistant/)
- [x] Optional: gas consumption estimate from burner power (with calibration note) – [docs/behaviour.md](docs/behaviour.md#gas-consumption-estimate)

### 5. Verification and evidence
- [x] Read and add `ebusctl info` / scan result (device identification) – [raw/ebusctl-info.txt](raw/ebusctl-info.txt)
- [x] Add anonymised raw data: 5022 scan results, sample telegrams ([raw/](raw/))
- [x] Compare with the standard eBUS definitions and the official Wolf file (0503 has no standard definition there; 0507 / 0800 follow the standard) – [docs/standard-comparison.md](docs/standard-comparison.md)

### 6. Before going public
- [ ] Privacy check: no IP addresses, URLs, tokens or personal data in files or history
- [ ] Proofread English texts and links
- [ ] Switch repository to public
- [ ] Optional: announce in an issue at [john30/ebusd-configuration](https://github.com/john30/ebusd-configuration) (Wolf / ENCON support)

## Disclaimer

This is an independent community project. It is **not affiliated with, endorsed by or supported by** Wolf GmbH or any other manufacturer. All product names and trademarks belong to their respective owners.

The information was obtained by observing the eBUS of one installation. It may be incomplete or wrong for other devices, firmware versions or configurations. **Use it at your own risk.**

The configuration only **reads** values. Writing parameters to the boiler (eBUS command 5023) is documented for reference only and is **not covered**: wrong values can cause malfunction or damage. Changes to boiler parameters should only be made by a qualified heating engineer.

## License

[GPL-3.0](LICENSE)
