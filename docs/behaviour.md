# Observed behaviour

Observations of the test installation (HG08 = 70 °C, later 80 °C; HG01 = 8 K; HG02 = 39 %, later 25 %; HG07 = 30 min, HG09 = 7 min, P03 = 55 °C, heat demand via input E1).

## Burner start

- About 14 s after the heat demand (E1 closed) the pump starts (status bit `0x40`); the flow temperature drops briefly when the pump starts.
- Start steps seen in 0503: mode 3 (~25 s, pump only), mode 5 (~20 s, gas valves without flame), mode 6 (ignition, ~20 s), then mode 7. Because 0503 comes only every 20 s, usually only one of these steps is captured per start.
- Once a hot water start was aborted in mode 5 (status `0x75`) and went directly to the shutdown phase 10 without flame (short draw).
- Heating: flow rises about 4 K/min at full power.
- **Soft start:** after ignition the burner runs about 180 s at minimum power (HG02, `Power` 86 with HG02 = 39 %, 70 with HG02 = 25 %) and then modulates up. It does not switch off before these 3 min, even when the switch-off temperature is already reached (two runs of exactly 3:00 min).

## Burner shutdown and maximum temperature

- In heating mode the burner **restarts below `BoilerTempSetpoint`** (after the cycle lock) and **switches off at `BoilerTempSetpoint` + HG01**, with `BoilerTempSetpoint` = min(A01, HG08 − HG01). So the switch-off temperature is **min(A01 + HG01, HG08)**:

| HG08 | A01 | `BoilerTempSetpoint` | switch-off expected | observed |
|---|---|---|---|---|
| 80 °C | 75–77 °C | 72 °C | 80 °C | 79 °C |
| 80 °C | 61 °C | 61 °C | 69 °C | 71 °C |
| 80 °C | 55 °C | 55 °C | 63 °C | 68 °C (held by the 3-min soft start) |
| 70 °C | 90 °C | 62 °C | 70 °C | 69–70 °C (many runs) |

  With A01 = 90 °C (ART setpoint far above the room temperature) HG08 is the limit; with A01 lower the ART limits the flow temperature. The chimney sweep mode ended at HG08.
- Mode 10 (shutdown phase) lasts about 40 s.
- HG08 does **not** apply to hot water: during draws the flow reached 67–70 °C. See [parameters.md](parameters.md#hg08-vs-hg22--two-maximum-temperatures).

## Burner cycle lock (HG09)

- After **every burner shutdown in heating mode** the burner is locked for HG09 (observed: 7 min 07 s with HG09 = 7; exactly 20 min with HG09 = 20), even if the shutdown was caused by a short interruption of the heat demand.
- After a shutdown during a hot water draw there is no lock (re-ignition after 79 s).
- **A hot water draw lifts the cycle lock:** a draw during the lock started the burner, and heating continued afterwards without waiting.
- According to the manual, the lock is also reset by switching the boiler off/on or by pressing the reset button briefly.

## Pump run-on (HG07)

- With pump mode HG06 = 0 the pump runs during heat demand and runs on for **HG07 = 30 min after the last burner shutdown** – not after the heat demand ends (6 cases, 29:30–29:56 min between mode 10 and status bits `0x01`).
- After hot water operation the pump runs on only about **60 s**.
- When the ART blocks heating (0507 `55`, see below), the pump does not start even with E1 closed – but a running HG07 run-on is **not** interrupted (pump off 29:49 min after the burner, although the ART had switched to `55` after 6.5 min).

## Hot water

- A draw is detected within a second (0800 bit `0x04`); the burner starts about 18 s after the draw begins.
- Burner power during a long draw: 73–91 %, never 100 % although HG03 = 100 % – the boiler modulates and keeps the flow at about 65 °C. The reason is open (HG23 = 65 °C only applies to a storage tank).
- The hot water temperature (5022 0x0359) reaches the setpoint P03 (54–56 °C at P03 = 55 °C).
- When the flow rate is reduced at the end, the burner stops (mode 10) and the hot water run-on bit stays ~60 s.
- Hot water starts are counted in `BurnerStarts`.

## Chimney sweep mode

- 0800 operating status 104 (`0x68`), ART 0507 status `aa`, ART sends A01 ≈ 5 °C and P03 = 10 °C, boiler 0800 reports 40 °C / 40 °C.
- Power constantly 100 % (heats with the maximum set heating power), ended when HG08 was reached (after 8 min 49 s, not after 15 min).

## Power-up (boiler switched off and on)

| After | Telegram |
|---|---|
| ~30 s | no telegrams from the boiler |
| | `ff00` broadcast (reset / start-up) |
| | 0704 identification broadcasts of the boiler, then the ART (30, then f1) |
| | the ART queries address f6 (no answer), the boiler addresses the ART before it is ready (timeouts) |
| ~40 s | 0800 reports `BoilerTempSetpoint` = 5 °C and `HwcTempSetpoint` = 53 °C, then the normal values |

Parameters, counters and the error history are kept. No fe01 is sent. → Ignore the first ~40 s of 0800 values after a power-up in automations.

## ART room temperature control

The ART measures the room temperature itself and acts as a room controller **in addition** to input E1. Observed with E1 permanently closed, ART room setpoint 23.5–24 °C:

- **Flow setpoint A01** ≈ 65 °C + 20 K × (room setpoint − room temperature), limited to 5…90 °C. It changes in steps of 2 K per 0.1 K and follows the room temperature without delay in both directions (proportional only, no integral part). Data points: +1.5 K → 90, +0.5 K → 75, 0 K → 65, −0.5 K → 55, −1 K → 45.
- **Switching:** heating is released (0507 `bb`) when the room temperature falls to the setpoint, and blocked (0507 `55` = hot water only, the ART manual calls it "summer mode") when it rises above setpoint + 0.5 K. While blocked, the boiler does **not** heat even though E1 is closed (0800 operating status 16).
- **Economy period** (day program of the ART, economy temperature): 0507 `00 03 …`, A01 = 5 °C, no heating; `BoilerTempSetpoint` 40 °C. Instantaneous hot water still works.
- The boiler uses A01: it switches off at min(A01 + HG01, HG08) – see [Burner shutdown](#burner-shutdown-and-maximum-temperature). With the room close to the setpoint, the burner runs at lower flow temperatures and shorter.
- Typical sequence after the economy period: one long run up to HG08, then short runs (3 min soft start, 7 min cycle lock) at decreasing switch-off temperatures, until the room is 0.5 K above the setpoint.

If the heat demand is controlled externally via E1 (as on the test installation), set the ART room setpoint high enough (e.g. 30 °C): then A01 stays at 90 °C and the ART never blocks heating.

## Gas consumption (estimate)

`Power` (0503 byte 4) is relative to the maximum power set with HG04 (heating) or HG03 (hot water). Calibrated with the gas meter of the test installation (natural gas):

| Mode | Maximum flow at `Power` = 100 % | Measurement |
|---|---|---|
| heating, HG04 = 50 % | 1.26 m³/h | one heating run, 670 s, 0.2166 m³ (model −0.2 %) |
| hot water, HG03 = 100 % | 2.11 m³/h | one shower, 6.5 min, 0.182 m³ |

A simple model: maximum flow = factor × share(HG), with the power curve of the manual (8 kW from 0 to 27 %, linear to 18 kW at 100 %): share = (8 + 10 × max(HG − 27, 0) / 73) / 18; factor 2.034 m³/h (heating) / 2.11 m³/h (hot water). Gas flow = maximum flow × `Power` / 100 while mode is 6 or 7; status bit `0x04` separates hot water from heating. Over 4 m³ this matched the gas meter within 0.2 %. Values for other installations will differ (gas quality, settings).
