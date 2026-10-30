# ebusctl and MQTT examples

`ebusctl` talks to a running ebusd (TCP port 8888). With the Home Assistant app, run it in the app's terminal.

## Read values of the configuration

```sh
ebusctl read FlowTemp                  # cached value if younger than 5 min, otherwise read from the bus
ebusctl read -f FlowTemp               # force reading from the bus
ebusctl read -f -v HwcTemp             # with name, unit and comment
ebusctl read -f HG09_BurnerCycleLockTimer
ebusctl read -f ErrorHistoryLastStatus # -> 8;31  (error code; extra byte)
ebusctl read BurnerStatus              # broadcast: last received value, e.g. 7;121;100;70.0
ebusctl read -c art ControllerStatus   # message of the circuit "art"
```

Example output:

```
$ ebusctl read -f FlowTemp
45.0
$ ebusctl read BurnerStatus
7;121;100;70.0          # Mode 7 = burner on; StatusBits 0x79; Power 100 %; FlowTemp 70.0 °C
```

## List messages and values

```sh
ebusctl find                 # all known messages with their last value
ebusctl find -c boiler -v    # verbose, boiler circuit only
ebusctl find FlowTemp        # name filter is a substring: FlowTemp, FlowTemp2, HG08_FlowTempMaxHeating
ebusctl find -d              # only messages with data
ebusctl info                 # ebusd version, loaded configuration, seen participants
ebusctl scan result          # identification of the devices (boiler: ENCON, empty ID)
ebusctl listen               # print every update until "stop" / Ctrl+C
```

## Raw 5022 reads (any number)

Without a definition, a 5022 number can be read as hex message (`ZZ PB SB NN DD…`):

```sh
ebusctl read -h 08502203000d00     # number 0x000d -> answer 02 5e 01 = 0x015e = 35.0 °C
ebusctl hex 08502203002602         # number 0x0226 (burner starts), needs ebusd --enablehex
```

The request bytes are `00 LL HH` for the number `0xHHLL` (low byte first). The answer `02 VL VH` is the value little-endian; `02 00 80` = number not available. Details: [docs/5022-reference.md](../docs/5022-reference.md).

> Only read commands (5022). Never send 5023 (write) by hand unless you know exactly what you are doing – see the warning in the docs.

## Decode recorded data offline

```sh
ebusctl decode "UIN,10" 5e01       # -> 35.0
```

Or replay whole telegrams without a bus, see [tests/](../tests/).

## MQTT

With `--mqtthost=…` (or the Home Assistant app) ebusd publishes every value with the default topic `ebusd/<circuit>/<name>`:

| Topic | Payload with `--mqttjson` (one entry per field) |
|---|---|
| `ebusd/boiler/FlowTemp` | `{"value": {"value": 45.0}}` |
| `ebusd/boiler/BurnerStatus` | `{"Mode": {"value": 7}, "StatusBits": {"value": 121}, "Power": {"value": 100}, "FlowTemp": {"value": 70.0}}` |
| `ebusd/art/ControllerStatus` | `{"Status": {"value": 187}, "FlowTempSetpoint": {"value": 90.0}, "HwcTempSetpoint": {"value": 55.0}}` |

Read on demand by publishing an **empty** message to the `get` topic:

```sh
mosquitto_pub -h <broker> -t ebusd/boiler/HG09_BurnerCycleLockTimer/get -n
```

ebusd then reads the value from the bus (log: `sent read boiler HG09_BurnerCycleLockTimer`) and publishes it on `ebusd/boiler/HG09_BurnerCycleLockTimer`.
