# 5022 reference (manufacturer read command)

## Request and answer

```
QQ 08 50 22 03 | xx LL HH        answer: 02 | VL VH
```

- `HHLL` is a **16-bit number** (little-endian in the telegram). The first data byte `xx` is ignored – the ART sends varying values there, any value from `00` to `ff` gives the same answer (tested). This configuration uses `00`.
- The answer is always 2 bytes, little-endian. `0x8000` (`02 00 80`) = number not available.
- **One value per request** – there is no block read. Several values in one telegram only come with the broadcasts (0503, 0800).
- The ART uses the same command with source address 30 when its parameter menu is opened.

Example (flow temperature 1):

```
ebusctl hex 08502203000d00      ->  02 5e 01   = 0x015e = 350 -> 35.0 °C
```

Scanned ranges (read only): `0x0000–0x04ff` and `0x0a00–0x0aff`, raw data in [`raw/scan/`](../raw/scan/). Encoding: most temperatures and setpoints are value / 10 (signed), parameters in `0x01xx` are integers.

## Measurements and setpoints

| Number | CSV name | Encoding | Meaning | Status |
|---|---|---|---|---|
| 0x0001 | `ErrorStatus` | integer | current error code, 0 = no error (8 during the E008 test) | ✅ |
| 0x0002 | `BoilerTempSetpoint` | / 10 °C | HG08 − HG01, same as 0800 byte 1–2 | ✅ |
| 0x0003 | `HwcTempSetpoint` | / 10 °C | hot water setpoint P03 | ✅ |
| 0x000c | `OutsideTemp` | / 10 °C | −40.0 = no outside sensor | 🟡 |
| 0x000d | `FlowTemp` | / 10 °C | flow temperature 1 (A02 on the ART, same as 0503 byte 5) | ✅ |
| 0x000e | – | / 10 °C | 255.0 constant – storage sensor B4 not connected | 🟡 |
| 0x0358 | `FlowTemp2` | / 10 °C | flow temperature 2 near the heat exchanger (copy in 0x038e) | 🟡 |
| 0x0359 | `HwcTemp` | / 10 °C | hot water temperature (copy in 0x038f); reaches P03 while drawing | ✅ |
| 0x0393 | `ModulationStatus` | integer | probably modulation level: 179 = burner off, 0 at start, then rising; runs 10–20 s ahead of 0503 `Power` | 🟡 hypothesis |
| 0x03f4 | – | / 10 °C | copy of the hot water setpoint P03 | ✅ |
| 0x0284 | – | / 10 °C | copy of HG08 | ✅ |

**Flow 1 vs. flow 2:** while the burner runs, both are equal within ±1 K. After the pump stops, 0x0358 stays 1–2 K warmer (18 cases), after a hot water draw it even rose from 68 to 70 °C while flow 1 cooled down – so 0x0358 sits at the heat exchanger mass (manual: flow sensor 2 is closer to the heat exchanger). Error 41 compares both sensors (flow 1 > flow 2 + 12 K).

## Parameters

| Number | Parameter | Encoding | Status |
|---|---|---|---|
| 0x0022 | HG01 burner switching differential | / 10 K | ✅ |
| 0x015a | HG02 lower burner power heating | raw 0–255 (= 0–100 %) | ✅ |
| 0x0159 | HG03 upper burner power hot water | raw 0–255 | ✅ |
| 0x013f | HG04 upper burner power heating | raw 0–255 | ✅ |
| 0x0a00 | HG05 / A09 frost protection limit | / 10 °C | ✅ |
| 0x0141 | HG06 pump operating mode | integer | ✅ |
| 0x0142 | HG07 pump run-on time | min | ✅ |
| 0x0027 | HG08 maximum boiler temperature heating | / 10 °C | ✅ |
| 0x0143 | HG09 burner cycle lock | min | ✅ |
| 0x0a5b | HG13 input E1 | integer | ✅ |
| 0x0abf | HG14 output A1 | integer | ✅ |
| 0x0140 | HG15 storage hysteresis | / 10 K | ✅ |
| 0x0155 | HG16 pump power minimum | % | ✅ |
| 0x0156 | HG17 pump power maximum | % | ✅ |
| 0x0178 | HG10 eBUS address (display only) | integer | 🟡 |
| 0x016a | HG11 hot water quick start temperature | / 10 °C | 🟡 |
| 0x016b | HG12 gas type | integer | 🟡 |
| 0x001f | HG21 minimum boiler temperature TK-min | / 10 °C | 🟡 |

How they were found: when scrolling through its parameter menu, the ART reads exactly these numbers with 5022 in **menu order** (HG01 0x0022, HG02 0x015a, HG03 0x0159, HG04 0x013f, HG05 0x0a00, HG06 0x0141, HG07 0x0142, HG08 0x0027, HG09 0x0143, HG13 0x0a5b, HG14 0x0abf, HG15 0x0140, HG16 0x0155, HG17 0x0156). Changing HG08, HG09, HG02 and HG15 on the ART confirmed the numbers. Details in [parameters.md](parameters.md).

Candidates for the parameters that the ART does not show (not confirmed):

| Number | Value | Candidate |
|---|---|---|
| 0x0157 | 80 | HG22 maximum boiler temperature TK-max (factory 80 °C) |
| 0x0168 / 0x0181 | 65 / 65.0 | HG23 maximum hot water temperature (factory 65 °C) – both stayed 65 when HG08 was changed |
| 0x002d / 0x0158 | 20.0 / 20 | HG25 boiler over-temperature for storage charging (factory 20 K) |

## Counters and error history

| Number | CSV name | Meaning | Status |
|---|---|---|---|
| 0x0226 | `BurnerStarts` | burner starts (counts heating and hot water starts) | ✅ |
| 0x0228 | `OperatingHours` | operating hours with mains on (+1 per hour) | ✅ |
| 0x022a | `BurnerHours` | burner hours (+1 after ~1.7 h of burner time) | 🟡 |
| 0x022b–0x023e | – | error history HG80–89: 10 entries × 2 words, newest last | ✅ |
| 0x023d / 0x023e | `ErrorHistoryLastStatus` / `…Hours` | newest entry | ✅ |
| 0x023f, 0x0240 | – | unknown (54 → 179 → 158 / 148) | ❓ |

Format of the error history: see [errors.md](errors.md#error-history-hg8089).

## Further numbers without meaning

| Range | Values |
|---|---|
| 0x0034 | 4 (constant) |
| 0x0161–0x019a | 0x0161 = 12, 0x0162 = 3, 0x0167 = 27, 0x0169 = 3, 0x016a = 100, 0x016b = 1, 0x0172 = 4, 0x0173 = 96, 0x0178 = 1, 0x0179 = 96, 0x0184 = 50, 0x0199 = 0xf202, 0x019a = 10, 0x016c–0x0176 and 0x0180 = 0 |
| 0x01df | 24 (= operating status `0x18`?) |
| 0x0394 | 42 (constant) |
| 0x03e8–0x03f2 | 0x03e8 = 10, 0x03e9/0x03eb/0x03ef = 64, 0x03ea/0x03ec/0x03f0 = 50, 0x03ed/0x03ee = 70 (not HG08), 0x03f1 = 18, 0x03f2 = 90 (A01?) |
| 0x0460 | 50 |
| 0x04ce / 0x04cf | 0 / 30 |
| 0x0a28 / 0x0a29 | 132 |

0x0167 = 27 might be the lower modulation limit (manual: minimum power 8 kW between 0 and 27 %).

## 5023 – parameter write (reference only)

> ⚠️ **Not included in the configuration and never sent by us.** Observed only when the ART saved a parameter. Wrong values can make the boiler malfunction. Parameter changes belong to a qualified heating engineer.

```
30 03 50 23 09 | xx LL HH VL VH 5d 01 00 00
```

| Data | Meaning |
|---|---|
| `xx` | varying (`80`, `18`, `4c`, `d0`, `88` observed) – meaning unknown |
| `LL HH` | parameter number (as in 5022) |
| `VL VH` | new value, little-endian, same encoding as 5022 |
| `5d 01 00 00` | constant (meaning unknown; also described for other Wolf devices) |

Observed writes:

| Data | Number | Value | Effect |
|---|---|---|---|
| `80 27 00 bc 02 5d 01 00 00` | 0x0027 HG08 | 700 | 70.0 °C |
| `18 43 01 ff 7f 5d 01 00 00` | 0x0143 HG09 | 0x7fff (invalid) | boiler set HG09 to its maximum 20 min |
| `4c 43 01 07 00 5d 01 00 00` | 0x0143 HG09 | 7 | 7 min |
| `d0 5a 01 66 00 5d 01 00 00` | 0x015a HG02 | 102 | 40 % |
| `88 40 01 3c 00 5d 01 00 00` | 0x0140 HG15 | 60 | 6.0 K |

The 0x7fff write was not intended by the user – presumably the ART sent it while the menu was being scrolled. After using the parameter menu of the ART, check the values (e.g. with the 5022 reads of this configuration).
