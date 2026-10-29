# ebusd_Wolf-CGU-2K-18

ebusd configuration CSV file for Wolf CGU-2K-18 with ART Thermostat

> 🚧 **Work in progress** – this repository is being prepared and will be made public once the items below are done.

## Goal

Everything someone needs to read data from a **Wolf CGU-2K-18** gas combi boiler (with **Wolf ART** room controller) over eBUS with [ebusd](https://github.com/john30/ebusd):

- a general, ready-to-use ebusd configuration (CSV)
- a documented decoding of the eBUS traffic: which telegram, byte and number means what, and how certain each finding is
- examples how to query the values (`ebusctl`, MQTT)

All findings come from observing a real installation (telegram log, 5022 scans, controlled tests on the ART and the boiler, gas meter readings) and from the Wolf installation manuals.

## To-Do

### 1. Repository setup
- [ ] Choose a license (e.g. the same as [ebusd-configuration](https://github.com/john30/ebusd-configuration))
- [ ] Define the folder structure (`config/`, `docs/`, `examples/`, `raw/`)
- [ ] Add `.gitignore`
- [ ] Add a disclaimer: no affiliation with Wolf, use at your own risk, writing parameters is not covered

### 2. ebusd configuration
- [ ] Create a general `encon/08.csv` with **English** message and field names (manufacturer 0x40 = ENCON, boiler slave address 08)
- [ ] Use neutral read types (`r`) and document a recommended polling setup separately (no installation-specific priorities)
- [ ] Remove installation-specific values and HA-only naming tricks (`_status` / `_temp` suffixes) or explain them where needed for Home Assistant
- [ ] Include only **confirmed** values by default; mark probable values clearly in the comments; leave unknown numbers out
- [ ] Broadcasts: 0503 (burner status), 0507 / 0800 (ART ↔ boiler), fe01 (error code)
- [ ] 5022 reads: flow temperatures, DHW temperature, error code, parameters HG01–HG17, counters, error history
- [ ] Decide how to handle 5023 (parameter write): document only, no write definitions until tested
- [ ] Test the published CSV on the real installation (all values must arrive as before)

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
- [ ] Add anonymised raw data: 5022 scan results, sample telegrams
- [ ] Compare our 0503 interpretation with the standard eBUS definition

### 6. Before going public
- [ ] Privacy check: no IP addresses, URLs, tokens or personal data in files or history
- [ ] Proofread English texts and links
- [ ] Switch repository to public
- [ ] Optional: announce in an issue at [john30/ebusd-configuration](https://github.com/john30/ebusd-configuration) (Wolf / ENCON support)
