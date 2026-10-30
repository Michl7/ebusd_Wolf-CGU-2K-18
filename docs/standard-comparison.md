# Comparison with the official ebusd configuration

Checked in October 2026 against [john30/ebusd-configuration](https://github.com/john30/ebusd-configuration) (TypeSpec sources in `src/`).

## Device identification

Real scan of the test installation (see [`raw/ebusctl-info.txt`](../raw/ebusctl-info.txt)):

```
address 08: slave #11, scanned "MF=ENCON;ID=  ;SW=-;HW=-"
```

The official repository has a folder `encon/`, but it only contains broadcast definitions and files for ventilation units (addresses 0a, 3c, 7c). The Wolf boiler definitions are in `wolf/` (`08..hc.tsp`), which is used for manufacturer **0x50 (Kromschröder)** – `kromschroeder/` is a link to `wolf/`. A CGU-2K-18 identifies itself as **0x40 (ENCON)**, so ebusd does not load the Wolf boiler file for it: with the official configuration it only decodes the standard broadcasts.

## Standard telegrams 0507 and 0800

The official file `opdata_inc.tsp` defines the eBUS standard telegrams. They explain most of the ART ↔ boiler traffic:

### 0507 "burner operational data" (ART → boiler)

Standard layout vs. observed `bb 04 a0 05 00 80 ff 6e ff`:

| Byte | Standard field | Observed | Meaning |
|---|---|---|---|
| 1 | status heat request | `bb` = hwc_heat, `aa` = heat | normal: heating + hot water; chimney sweep mode: heating only |
| 2 | variable consumers (action) | `04` = consumeon | |
| 3–4 | boiler target temperature (D2C) | 90 °C | = A01 (`FlowTempSetpoint`) |
| 5–6 | boiler target pressure (D2B) | `00 80` = not available | |
| 7 | setting degree (D1C) | `ff` = not available | |
| 8 | hot water target temperature (D1C) | 55 °C | = P03 (`HwcTempSetpoint`) |
| 9 | fuel choice | `ff` | |

So the previously unknown bytes 2 and 5–7, 9 are standard fields that the ART does not use.

### 0800 "target values of the room controller" (ART → boiler) and the boiler's answer

| Bytes | Standard field | ART → boiler | Boiler → ART |
|---|---|---|---|
| 1–2 | boiler target temperature (D2B) | 90 °C (follows A01) | `BoilerTempSetpoint` = HG08 − HG01 |
| 3–4 | outside temperature (D2B) | 90 | −40 (no sensor) |
| 5 | forced performance (D1B) | 0 | 0 |
| 6 | bit 0 hot water active, bit 1 heating active | `0x12` (heating active + bit 4) | `OperatingStatus` |
| 7–8 | hot water target temperature (D2B) | P03 | P03 |

- Confirms our reading of the boiler's 0800: bit `0x01` = hot water, bit `0x02` = heating active. The other bits (`0x04` hot water draw, `0x08` no heat demand, `0x10` burner off, `0x20`/`0x40` chimney sweep) are not in the standard – they are boiler specific.
- ART value 1 is the standard "boiler target temperature" → it follows A01, as observed when the ART knob was turned.
- ART value 2 is the standard "outside temperature" field – the ART sends 90 there (it has no outside sensor).

## 0503 and fe01

The official repository has **no definition** for 0503 block 1 (burner operational data to the controller) or for fe01. Our layout of 0503 is purely empirical (see [telegrams.md](telegrams.md)); the eBUS specification document itself was not available to us for comparison.

## Wolf register file `wolf/08..hc.tsp`

The Wolf file reads parameters with the same command (5022, first data byte fixed `00`). Comparison with our findings:

| Name in Wolf file | Number | Our finding | Remark |
|---|---|---|---|
| HG01 | 0x0022 | HG01 ✅ | same |
| HG02 / HG03 / HG04 | 0x015a / 0x0159 / 0x013f | same numbers ✅ | Wolf file: percent – here **raw 0–255** (128 = 50 %, verified on the ART) |
| HG06 / HG07 / HG09 | 0x0141 / 0x0142 / 0x0143 | same ✅ | |
| HG08 | **0x0284** | 0x0284 = copy of HG08 ✅ | the ART reads and writes **0x0027** for HG08; both changed together |
| HG22 | **0x0027** | 0x0027 = HG08 (ART menu) | contradiction: on this boiler 0x0027 follows the ART's HG08 |
| HG10 / HG11 / HG12 | 0x0178 / 0x016a / 0x016b | 1 / 10.0 °C / 1 | match the factory values (eBUS address 1, quick start off, natural gas) 🟡 |
| HG15 | 0x0140 | HG15 ✅ | |
| HG16 / HG17 | 0x0155 / 0x0156 | same ✅ | Wolf file unit: minutes – here **%** |
| HG21 | 0x001f | 40.0 °C (factory 40) | confirms our candidate 🟡 |
| HG73 Io actual value | 0x0170 | 0 | burner off at scan time |
| HG74 fan speed | 0x01f6 | not available | the CGU-2K-18 has no fan (atmospheric burner) |
| HG75 hot water flow | 0x016c | 0 | no draw at scan time |
| PWM pump | 0x016d | 0 | pump off at scan time |
| HG9x mains hours / HG90 burner hours / HG91 burner starts | 0x0228 / 0x022a / 0x0226 | same ✅ | confirms 0x022a = burner hours |
| flow / return / hot water | 0x000d / 0x0016 / 0x000e | 0x000d ✅ / not available / 255 | no return sensor; 0x000e is the storage sensor (not connected) – the instantaneous hot water temperature is 0x0359 |
| flow / hot water setpoint | 0x0002 / 0x0003 | same ✅ | |

### First byte of 5022 / 5023

The Wolf file notes that the first data byte "should rather be crc8 of the following bytes". For the five 5023 writes of the ART this was tested with the eBUS CRC8 (polynomial 0x9B, two common variants) over every part of the telegram: **no match**. For reads the byte is ignored by the boiler anyway.
