# Hardware and setup

## Devices

| Device | Role |
|---|---|
| Wolf **CGU-2K-18** | gas combi boiler (instantaneous hot water, no storage tank), room-air dependent |
| Wolf **ART** | analog room temperature controller with day program (ART 2A); sends setpoints, reads/writes boiler parameters |
| eBUS adapter | network adapter with enhanced protocol (ebusd device `ens:<ip>:9999`) -> Elecrow eBUS Adapter Shield C6 Stick Edition | 
| ebusd | 26.1 (tested); any version ≥ 24.1 should work |

The heat demand of this installation does **not** come over the eBUS: a room thermostat contact is wired to input **E1** of the boiler (parameter HG13 = 1 "room thermostat"). Open contact = no heating (and no heating pump). The ART still sends its setpoints on the bus.

## Bus participants

| Address | Device | Traffic |
|---|---|---|
| 03 | boiler (master) | broadcasts 0503, fe01; 0800 to the ART |
| 08 | boiler (slave) | answers 5022 reads and 0704 identification |
| f1 | ART (master) | 0507 and 0800 to the boiler (every ~10 s), 0704 identification of the boiler (every minute) |
| 30 | ART (second master address) | parameter access: reads with 5022 and writes with 5023 while the parameter menu is open |
| f6 | – | queried by the ART at start-up, no device answers |
| 31 | ebusd | 5022 reads |

## Identification (0704)

| Device | Answer | Meaning |
|---|---|---|
| boiler (08) | `40 01 1c 00 20 01 ff ff ff ff` | manufacturer 0x40 = **ENCON**, device ID `01 1c 00 20 01` (not ASCII), no SW/HW version |
| ART (30 / f1) | `50 01 0b 00 00 80 01 62 04 82` (30) / `… 40 …` (f1) | manufacturer 0x50 = Kromschröder |

Because the device ID is not printable, **ebusd reports an empty ID** and picks the file `encon/08.csv` from its configuration path (tested with ebusd 26.1: `read scan config file encon/08.csv for ID ""`).

## ebusd setup

1. Copy the folder [`config/`](../config/) to the ebusd host.
2. Start ebusd with this folder as configuration path, for example:

   ```
   ebusd --device=ens:<adapter-ip>:9999 --configpath=/path/to/config --scanconfig
   ```

3. Check the ebusd log for `read scan config file encon/08.csv`.
4. Read a value: `ebusctl read -f FlowTemp`.

Optional options:

| Option | Use |
|---|---|
| `--enablehex` | allows raw requests `ebusctl hex …` (needed for own 5022 scans) |
| `--pollinterval=SEC` | time between two polled messages (default 5 s) |
| `--mqttvar=filter-seen=1` | with the default Home Assistant integration (`mqtt-hassio.cfg`): stops the integration from polling every known message with priority up to 5 |

Recommended polling setup and Home Assistant notes: see [`config/README.md`](../config/README.md).

### Home Assistant app

With the ebusd app for Home Assistant (repository LukasGrebe/ha-addons), put the CSV for example to `/share/ebusconf/encon/08.csv` and add `--configpath=/share/ebusconf` to the app's command line options.

### Telegram log

The Home Assistant app can store every telegram in an SQLite database (`sqlite_db` option). This log was the basis of the decoding: it allows to compare telegrams before and after an event (e.g. a parameter change on the ART).
