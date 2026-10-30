# Open questions

Unconfirmed (🟡) and unknown (❓) values. Observations from other installations (other CGU/CGB models, other firmware) are welcome – please open an issue with the telegrams or 5022 values.

## Probable, not proven (🟡)

| Item | Current interpretation | What would confirm it |
|---|---|---|
| 5022 0x0358 `FlowTemp2` | flow sensor 2 near the heat exchanger | disconnecting one sensor (error 10 / 12) – not tested |
| 5022 0x0393 `ModulationStatus` | modulation level (179 = burner off) | relation to `Power` differs between heating and hot water |
| 5022 0x022a `BurnerHours` | burner hours | more increments compared with the burner run time |
| 5022 0x000c / 0800 bytes 3–4 `OutsideTemp` | outside temperature, −40 = no sensor | installation with outside sensor |
| 5022 0x000e | storage sensor B4 (255 = not connected) | installation with storage tank |
| 0503 modes 3 / 5 / 6 | start phase steps (preparation / gas valves / ignition) | faster sampling of 0503 is not possible (broadcast every 20 s) |
| 0503 status bits `0x08` / `0x30` | flame / gas valves | |
| 0503 bytes 6–8 `80 ff d8` | constant, probably "no sensor" | |
| 0800 bits `0x02`, `0x10`, `0x20`/`0x40` | heating active, burner off, chimney sweep | `0x20` and `0x40` only seen together |
| ART 0800 value 1 | flow setpoint (followed A01) | |

## Unknown (❓)

| Item | Values |
|---|---|
| ART 0800 values 2 and 3 | 90 / 18 |
| ART 0507 bytes 2, 5–7, 9 | `04`, `00 80 ff`, `ff` |
| Error history, high byte of word 1 | `a7`, `1f` |
| 5022 0x023f, 0x0240 | 54 → 179 → 158, 148 |
| 5022 0x001f, 0x0157, 0x0168 / 0x0181, 0x002d / 0x0158 | candidates for HG21, HG22, HG23, HG25 (not visible on the ART) |
| 5022 0x0034, 0x01df, 0x0394, 0x03e8–0x03f2, 0x0460, 0x04ce/0x04cf, 0x0a28/0x0a29, 0x0161–0x019a | see [5022-reference.md](5022-reference.md#further-numbers-without-meaning) |
| 5023 first data byte and `5d 01 00 00` | |
| 5022 numbers outside 0x0000–0x04ff and 0x0a00–0x0aff | not scanned |

## Open contradictions

- **Soft start:** the manual describes ~180 s with minimum power after ignition, but 0503 `Power` shows 100 % right after ignition.
- **Hot water limit:** the flow is held at ~65 °C during hot water draws; HG08 does not apply to hot water and HG23 only to storage tanks.
