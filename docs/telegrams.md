# Telegram reference

Passive telegrams that ebusd receives without polling. CSV names in brackets.

## 0503 – burner status broadcast (`BurnerStatus`)

`03 → fe`, block 1, about every 20 s. Example: `03 fe 05 03 08 | 01 07 79 64 8c 80 ff d8`

| Byte | Field | Meaning | Status |
|---|---|---|---|
| 1 | block | always `01` | ✅ |
| 2 | `Mode` | operating mode, see below | ✅ |
| 3 | `StatusBits` | bit field, see below | ✅ / 🟡 |
| 4 | `Power` | burner power in % **relative to the allowed maximum** (HG04 heating, HG03 hot water) | ✅ |
| 5 | `FlowTemp` | flow temperature 1, UCH / 2 °C (same as 5022 0x000d) | ✅ |
| 6–8 | – | always `80 ff d8` | 🟡 (probably "no sensor") |

`Power` was confirmed with the gas meter: with HG04 = 50 %, heating at 100 % takes about 1.26 m³/h natural gas (≈ 12 kW load), clearly below the full-load value of the data sheet (2.1 m³/h). In chimney sweep mode it shows 100 for the whole run. During normal heating it modulates between about 86 and 100, during hot water between 73 and 91.

Open contradiction: according to the manual the burner starts with minimum power for ~180 s (soft start), but byte 4 shows 100 right after ignition.

### Operating mode (byte 2)

| Value | Meaning | Status | Observation |
|---|---|---|---|
| 0 | off / standby | ✅ | |
| 3 | start phase (preparation?) | 🟡 | ~25 s, pump only (status bits `0x41` / `0x45`) |
| 5 | start phase (gas valves open, no flame yet?) | 🟡 | ~20 s, status bits `0x71` / `0x75` |
| 6 | ignition | 🟡 | ~20 s, status bits `0x79` |
| 7 | burner on | ✅ | every run |
| 8 | fault | ✅ | provoked error E008, status bits `0xc1` |
| 10 | shutdown phase | ✅ | ~40 s after every run |

1, 2, 4 and 9 were never seen. Because the broadcast comes only every 20 s, usually only one start step is captured per burner start; the order 3 → 5 → 6 → 7 is assumed.

### Status bits (byte 3)

| Bit | Meaning | Status |
|---|---|---|
| `0x01` | always set | ✅ |
| `0x04` | hot water operation | ✅ |
| `0x08` | flame (ionisation; set from mode 6/7) | 🟡 |
| `0x30` | gas valves (GKV 1 / 2; already set in start mode 5) | 🟡 |
| `0x40` | pump running | ✅ |
| `0x80` | fault | ✅ |

Typical values:

| Value | Meaning | Ring LED on the boiler |
|---|---|---|
| `0x01` | standby | green flashing |
| `0x41` | pump running, burner off (before ignition or run-on) | green steady |
| `0x45` | pump + hot water, burner not yet on | – |
| `0x71` / `0x75` | start: gas valves open, no flame yet (heating / hot water) | – |
| `0x79` | burner on, heating (also chimney sweep mode) | yellow steady |
| `0x7d` | burner on, hot water | yellow steady |
| `0xc1` | fault, pump running | red flashing |

## 0800 boiler → ART (`BoilerStatus`)

`03 → f1`, four 2-byte values. Example: `00 3e 00 d8 00 18 00 37`

| Bytes | Field | Normal | Chimney sweep | Meaning | Status |
|---|---|---|---|---|---|
| 1–2 | `BoilerTempSetpoint` (D2B) | 62 °C | 40 °C | **HG08 − HG01** (restart point); also 5022 0x0002 | ✅ |
| 3–4 | `OutsideTemp` (D2B) | −40 °C | −40 °C | no outside sensor connected; also 5022 0x000c | 🟡 |
| 5 | – | `00` | `00` | forced performance (standard field) | ✅ |
| 6 | `OperatingStatus` | 24 | 104 | bit field, see below | ✅ |
| 7–8 | `HwcTempSetpoint` (D2B) | 55 °C | 40 °C | hot water setpoint = echo of ART P03; also 5022 0x0003 | ✅ |

### Operating status bit field (byte 6)

| Bit | Meaning | Status |
|---|---|---|
| `0x01` | hot water operation incl. ~60 s run-on after the draw (standard: hot water active) | ✅ |
| `0x02` | heating active (cleared while hot water has priority; standard: heating active) | ✅ |
| `0x04` | hot water draw detected (flow sensor, reacts within a second) | ✅ |
| `0x08` | no heat demand (input E1 open) | ✅ |
| `0x10` | burner off / not requested | 🟡 |
| `0x20`, `0x40` | chimney sweep mode (only seen together) | 🟡 |

Observed values:

| Dec | Hex | Meaning |
|---|---|---|
| 24 | `0x18` | standby |
| 2 | `0x02` | heating, burner on |
| 18 | `0x12` | heat demand, burner pause (e.g. cycle lock) |
| 29 | `0x1d` | hot water draw, burner not yet on |
| 13 | `0x0d` | hot water draw, burner on |
| 25 | `0x19` | hot water run-on |
| 5 | `0x05` | hot water draw during heat demand (hot water priority) |
| 19 | `0x13` | hot water run-on during heat demand |
| 104 | `0x68` | chimney sweep mode (without heat demand) |

The fault state is **not** shown in this bit field.

## 0507 ART → boiler (`ControllerStatus`)

`f1 → 03`, every ~10 s. Example: `bb 04 a0 05 00 80 ff 6e ff`. Standard eBUS telegram "burner operational data" – see [standard-comparison.md](standard-comparison.md#0507-burner-operational-data-art--boiler).

| Byte | Field | Meaning | Status |
|---|---|---|---|
| 1 | `Status` | status heat request: `bb` = hot water + heating (normal), `aa` = heating only (chimney sweep mode) | ✅ |
| 2 | – | action: `04` = consumers on | ✅ (standard) |
| 3–4 | `FlowTempSetpoint` (SIN / 16 = D2C) | A01 boiler target temperature, 90 °C on the test installation – **not** the effective setpoint (the boiler limits with HG08). Changes when the temperature knob of the ART is turned (e.g. 83 °C) – relation still being investigated | ✅ / 🟡 |
| 5–6 | – | target pressure, `00 80` = not available | ✅ (standard) |
| 7 | – | setting degree, `ff` = not available | ✅ (standard) |
| 8 | `HwcTempSetpoint` (UCH / 2) | P03 hot water setpoint | ✅ |
| 9 | – | fuel choice, `ff` | ✅ (standard) |

## 0800 ART → boiler (`ControllerData`)

`f1 → 03`, every ~10 s. Example: `00 5a 00 5a 00 12 00 37`. Standard eBUS telegram "target values of the room controller" – same layout as the boiler's 0800.

| Bytes | Field | Meaning | Status |
|---|---|---|---|
| 1–2 | `FlowTempSetpoint` (D2B) | boiler target temperature: 90 normally, 5 in chimney sweep mode; follows A01 when the ART knob is turned (e.g. 68.7 / 83 °C) | ✅ |
| 3–4 | – | outside temperature field – the ART sends 90 (it has no outside sensor) | 🟡 |
| 5 | – | forced performance, 0 | ✅ (standard) |
| 6 | – | `0x12`: bit 1 heating active, bit 4 unknown | 🟡 |
| 7–8 | `HwcTempSetpoint` (D2B) | P03 (changes immediately when P03 is turned on the ART) | ✅ |

Changing P03 on the ART does **not** send a write command (5023): the new value is only sent in 0507 and 0800, and the boiler takes it over after 10–15 s (its 0800 `HwcTempSetpoint` and 5022 0x0003 follow).

## fe01 – error broadcast (`ErrorBroadcast`)

`03 → fe`, 10 bytes ASCII: `E` + 3 digits + 6 spaces, e.g. `45 30 30 38 20 20 20 20 20 20` = `E008`, and `E000` when the error is reset.

- Sent **only when the error state changes** – not at power-up and not when pressing the reset button without a pending error. After an ebusd restart the value is unknown until the next change.
- For a value that is always available use 5022 0x0001 (`ErrorStatus`). See [errors.md](errors.md).

## 0704 – identification

The ART asks the boiler every minute (`f1 → 08 07 04`). After power-up the boiler, then the ART (as 30 and f1) send their identification as broadcast. See [hardware-and-setup.md](hardware-and-setup.md#identification-0704).

## ff00 – power-up

After switching the boiler on, it sends the standard broadcast `ff00` (`03 → fe`, data `00`).

## Not on the bus

- the heat demand (input E1, see [hardware-and-setup.md](hardware-and-setup.md))
- the return temperature – the CGU-2K-18 has no return sensor
