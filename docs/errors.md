# Errors

## Where errors appear on the bus

| Source | CSV name | Content | When |
|---|---|---|---|
| fe01 broadcast | `ErrorBroadcast` | text `E008`, `E000` = reset | only when the error state changes |
| 5022 0x0001 | `ErrorStatus` | error code as number, 0 = no error | on every read |
| 0503 byte 2 / 3 | `BurnerStatus` | mode 8 and status bit `0x80` | every ~20 s |
| 5022 0x023d / 0x023e | `ErrorHistoryLast…` | newest entry of the error history | on every read |

For automations use `ErrorStatus` (always available) and the fault flag of `BurnerStatus`; `ErrorBroadcast` is lost after an ebusd restart until the next change. The 0800 operating status does **not** show a fault.

## Error codes

From the boiler manual (short description):

| Code | Fault | Typical cause |
|---|---|---|
| 1 | TBV over-temperature | flow above the safety limit, heat exchanger dirty |
| 4 | no flame formation | no flame at burner start |
| 5 | flame failure during operation | flame lost during stabilisation or soft start |
| 6 | TW over-temperature | flow/return above the limiter |
| 7 | TBA over-temperature (flue gas) | flue gas temperature or flue gas outlet; restart after ~15 min |
| 8 | flue gas damper does not switch | damper or its feedback contact |
| 10 | flow sensor 2 defective | sensor or cable |
| 11 | flame simulation | flame detected before burner start |
| 12 | flow sensor 1 defective | sensor or cable |
| 14 | storage sensor defective | sensor or cable |
| 15 | outside sensor defective | sensor or cable |
| 17 | modulation current fault | ≥ 10 s outside the target range |
| 40 | system pressure switch | switch has tripped |
| 41 | flow monitoring | flow 1 > flow 2 + 12 K, temperature rise too fast |
| 45 | flow sensor (hot water) | cable or sensor |
| 46 | hot water outlet temperature sensor | cable or sensor |
| 52 | maximum storage charging time | charging time exceeded |
| 78 | collector sensor defective | out of range |

Only error 8 has been observed so far (provoked, see below).

## Error history (HG80–89)

5022 numbers 0x022b–0x023e: **10 entries of two words**, the newest entry last (0x023d / 0x023e). With every new error the list moves by one entry (the oldest is dropped).

| Word | Content |
|---|---|
| 1 (e.g. 0x023d) | low byte = **error code**, high byte = unknown (e.g. `a7`, `1f`) |
| 2 (e.g. 0x023e) | **operating hour** of the error (compare 5022 0x0228 `OperatingHours`) |

The error time is not stored as date: the error happened about `OperatingHours − ErrorHistoryLastHours` hours ago (accuracy ±1 h; in the test the calculated time was about 1 h too early).

## Provoked error E008 (test)

The test installation has a flue gas damper whose feedback contact is wired to the boiler. Opening this contact during burner start produces error 8:

| Time | Action | eBUS |
|---|---|---|
| 0 s | feedback contact open, no heat demand | no reaction |
| +30 s | heat demand on | 0800 `0x12` – demand, burner stays blocked, **no error** |
| +69 s | contact closed | 0800 `0x02` – burner released |
| +83 s | contact open again | – |
| +84 s | – | 0503 mode 6 (ignition), status `0x79` |
| +95 s | – | **fe01 `E008`** |
| +101 s | – | 5022 0x0001 = 8 |
| +104 s | – | 0503 **mode 8**, status bits **`0xc1`** |
| +118 s | contact closed | – |
| +131 s | – | **fe01 `E000`** – error 8 resets itself 13 s after the contact is closed |

- If the feedback is missing **before** the start, the boiler waits without error. E008 only occurs when the feedback is lost during start or operation.
- The error was added to the error history with the current operating hour.
- A second test during heating gave the same sequence (E008, E000 after 25 s, then a normal restart).

## Reset button and power-up

- Pressing the reset button without a pending error does nothing on the bus.
- After switching the boiler off and on, no fe01 is sent; the parameters, counters and the error history are kept.
