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
- [ ] Hardware and bus participants (addresses 03/08, ART f1/30, adapter type)
- [ ] Setup guide: ebusd options (`--configpath`, optional `--enablehex`), where to put the CSV
- [ ] Telegram reference: 0503, 0507, 0800, fe01, 0704 with byte layout and bit fields
- [ ] 5022 reference: request format (`xx LL HH`, first byte ignored), number list (measurements, parameters, counters, error history) with confidence level
- [ ] Parameter table HG01–HG17 with 5022 numbers and encoding (e.g. HG02–HG04 raw 0–255 = 0–100 %)
- [ ] 5023 write format as observed from the ART (for reference only, with warning)
- [ ] Operating modes and status bits (0503 byte 2/3), operating type bit field (0800 byte 6)
- [ ] Error codes and error history format
- [ ] Known behaviour: burner cycle lock (HG09), pump run-on (HG07), HG08 vs. HG22, DHW
- [ ] Open questions / unknown values (so others can help)
- [ ] Confidence legend (✅ confirmed · 🟡 probable · ❓ unknown)

### 4. Examples
- [ ] `ebusctl` read and hex query examples
- [ ] Optional: Home Assistant via MQTT discovery (filter notes for `mqtt-hassio.cfg`), example template for error text
- [ ] Optional: gas consumption estimate from burner power (with calibration note)

### 5. Verification and evidence
- [ ] Read and add `ebusctl info` / scan result (device identification)
- [x] Add anonymised raw data: 5022 scan results, sample telegrams ([raw/](raw/))
- [ ] Compare our 0503 interpretation with the standard eBUS definition

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
