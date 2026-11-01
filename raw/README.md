# raw

Anonymised raw data used for the decoding. No addresses, names or dates of the installation.

| File | Content |
|---|---|
| [`telegrams-24h.txt`](telegrams-24h.txt) | 396 real telegrams (each distinct telegram once): 24 h with heating and hot water, hourly parameter reads, plus the fe01 error test, seven 5022 scan values and two 5022 reads at the ART. Time as offset, ready for `ebusd --inject` |
| [`scan/`](scan/) | 5022 scans: number (`HHLL`, as `xx`/`xxxx`) and raw answer `NN LL HH`. `020080` = number not available |

The boiler scans were taken with `ebusctl hex 0850220300LLHH` (read only) at a time when HG08 was set to 65 °C (later 70 °C); the ART scan (`5022_art35_…`) with `ebusctl hex 3550220300LLHH`.
