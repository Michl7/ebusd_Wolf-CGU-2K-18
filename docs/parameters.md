# Boiler parameters (HG)

Parameter list of the CGU-2K-18 (installation manual for the heating engineer). On the boiler side the parameters are called HGxx; the ART shows them as HGxx too, the boiler manual lists some as GBxx for ART/AWT controllers.

"Test value" = setting of the test installation, read with 5022 and checked on the ART.

| Parameter | Meaning | Range | Factory | Test value | 5022 | Encoding | Status |
|---|---|---|---|---|---|---|---|
| HG01 (GB01) | burner switching differential | 5–25 K | 8 K | 8 K | 0x0022 | / 10 K | ✅ |
| HG02 | lower burner power heating | 1–100 % | 1 % | 39 % | 0x015a | raw 0–255 | ✅ |
| HG03 | upper burner power hot water | 1–100 % | 100 % | 100 % | 0x0159 | raw 0–255 | ✅ |
| HG04 (GB04) | upper burner power heating | 1–100 % | 100 % | 50 % | 0x013f | raw 0–255 | ✅ |
| HG05 (GB05 / A09) | frost protection limit | −20…+10 °C | +2 °C | 2 °C | 0x0a00 | / 10 °C | ✅ |
| HG06 (GB06) | pump operating mode | 0–2 | 0 | 0 | 0x0141 | integer | ✅ |
| HG07 (GB07) | boiler pump run-on time | 0–30 min | 1 min | 30 min | 0x0142 | min | ✅ |
| HG08 (GB08) | maximum boiler temperature heating (TV-max) | 40–90 °C | 80 °C | 70 °C | 0x0027 | / 10 °C | ✅ |
| HG09 (GB09) | burner cycle lock | 1–20 min | 7 min | 7 min | 0x0143 | min | ✅ |
| HG10 | eBUS address (display only) | 1–4 | 1 | – | – | – | |
| HG11 | hot water quick start temperature | 10–60 °C | 10 °C (= off) | – | – | – | |
| HG12 | gas type (1 natural gas, 0 LPG) | 0–1 | 1 | – | – | – | |
| HG13 (GB13) | configurable input E1 | 0–11 | 1 | 1 (room thermostat) | 0x0a5b | integer | ✅ |
| HG14 (GB14) | configurable output A1 | 0–15 | 6 | 8 | 0x0abf | integer | ✅ |
| HG15 (GB15) | storage hysteresis | 1–30 K | 5 K | 5 K | 0x0140 | / 10 K | ✅ |
| HG16 | heating circuit pump power minimum | 20–100 % | 45 % | 45 % | 0x0155 | % | ✅ |
| HG17 | heating circuit pump power maximum | 20–100 % | 80 % | 80 % | 0x0156 | % | ✅ |
| HG20 | no function | – | 0 | – | – | – | |
| HG21 | minimum boiler temperature TK-min | 40–60 °C (detail page: 20–60 °C) | 40 °C | – | 0x001f? | / 10 °C | ❓ |
| HG22 | maximum boiler temperature TK-max | 50–90 °C | 80 °C (detail page shows 90) | – | 0x0157? | integer | ❓ |
| HG23 (A14) | maximum hot water temperature (storage) | 60–80 °C | 65 °C | – | 0x0168 / 0x0181? | | ❓ |
| HG25 | boiler over-temperature for storage charging | 0–40 K | 20 K | – | 0x002d / 0x0158? | | ❓ |
| HG70 | collector sensor (display only) | – | – | – | – | – | |
| HG80–89 | error history | – | – | – | 0x022b–0x023e | see [errors.md](errors.md) | ✅ |
| P03 (ART) | hot water setpoint | | | 55 °C | 0x0003, 0x03f4 | / 10 °C | ✅ |

The ART of the test installation shows and changes HG01–HG09 and HG13–HG17 (including HG02, HG03, HG15–HG17, although the boiler manual lists only the GB parameters for the ART). HG10–HG12 and HG20–HG25 are not shown.

## Encoding of HG02–HG04

The burner power parameters are stored as **raw value 0–255** for 0–100 %:

| Setting | Raw value |
|---|---|
| 39 % | 100 |
| 40 % | 102 |
| 50 % | 128 |
| 100 % | 255 |

percent = raw / 2.55. Found by changing HG02 on the ART from 39 to 40 % (0x015a 100 → 102).

## Notes on single parameters

- **HG01 / HG08:** in heating mode the burner switches off at HG08 and restarts below HG08 − HG01. The boiler sends HG08 − HG01 as `BoilerTempSetpoint` (0800, 5022 0x0002).
- **HG07:** run-on time of the boiler pump after the **last burner shutdown** (not after the heat demand ends) – see [behaviour.md](behaviour.md#pump-run-on-hg07).
- **HG09:** applies after every burner shutdown in heating mode – see [behaviour.md](behaviour.md#burner-cycle-lock-hg09).
- **HG13 = 1:** input E1 = room thermostat. Closed contact releases heating; open contact blocks heating and the heating pump.
- **HG14 = 8:** output A1 = external ventilation – A1 switches inverted to the burner (e.g. to lock an extractor fan while the burner runs).
- **HG15, HG23, HG25:** only relevant for a hot water storage tank. The CGU-2K-18 heats hot water instantaneously, so they have no function there; HG15 can still be read and changed.

## HG08 vs. HG22 – two maximum temperatures

| | HG08 "maximum limit boiler circuit TV-max" | HG22 "maximum boiler temperature TK-max" |
|---|---|---|
| applies to | **heating mode only** | every mode (boiler temperature controller) |
| storage charging | not active – the boiler may get hotter | the absolute upper limit |
| factory setting | 80 °C | 80 °C (enough e.g. for a storage setpoint of 60 °C + HG25 = 20 K) |

So HG08 ≤ HG22. Without a storage tank, HG08 is the limit seen in practice (switch-off at 69–70 °C with HG08 = 70 °C). During hot water draws the flow reached 67–70 °C, below HG22.

**HG21 (TK-min):** minimum switch-on temperature – if the boiler temperature falls below it **during a heat demand**, the burner starts (after the cycle lock). Without heat demand the boiler may cool down below it. Frost protection: if the boiler water falls below +5 °C, the burner heats at least up to TK-min.
