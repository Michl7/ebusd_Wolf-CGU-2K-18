# raw

Anonymised raw data used for the decoding. No addresses, names or dates of the installation.

| File | Content |
|---|---|
| [`telegrams-24h.txt`](telegrams-24h.txt) | 394 real telegrams (each distinct telegram once): 24 h with heating and hot water, hourly parameter reads, plus the fe01 error test and seven 5022 scan values. Time as offset, ready for `ebusd --inject` |
| [`scan/`](scan/) | 5022 scans: number (`HHLL`, as `xx`/`xxxx`) and raw answer `NN LL HH`. `020080` = number not available |

The scans were taken with `ebusctl hex 0850220300LLHH` (read only) at a time when HG08 was set to 65 °C (later 70 °C).
