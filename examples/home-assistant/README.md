# Home Assistant

Example setup with the ebusd app (add-on) and MQTT discovery. The templates were tested on the test installation (template preview with the real values; results identical to the sensors running there). The automations are English versions of the automations running there.

## 1. ebusd app

- Install the **eBUSd** app (repository LukasGrebe/ha-addons) and the MQTT broker (Mosquitto).
- Copy [`config/encon/08.csv`](../../config/encon/08.csv) to `/share/ebusconf/encon/08.csv`.
- App option `commandline_options`:

  ```
  --configpath=/share/ebusconf
  --mqttvar=filter-seen=1
  ```

  `filter-seen=1` stops the integration file `mqtt-hassio.cfg` from polling every message with priority up to 5 – otherwise all 5022 values are polled in a long round.
- Leave `seed_mqtt_cfg` on: the default `mqtt-hassio.cfg` works with this configuration, because the message names contain `Temp`, `Status`, `Power`, `Mode`, `Timer`, `Hours` or `Starts`.

## 2. Entities

MQTT discovery creates two devices, **ebusd boiler** and **ebusd art**. Entity IDs follow the pattern

```
sensor.ebusd_<circuit>_<name>             single-field messages, e.g. sensor.ebusd_boiler_flowtemp
sensor.ebusd_<circuit>_<name>_<field>     multi-field messages, e.g. sensor.ebusd_boiler_burnerstatus_mode
```

If the device is assigned to an area, Home Assistant may prefix the area (e.g. `sensor.heating_ebusd_boiler_flowtemp`). Check your IDs under *Settings → Devices & services → Entities* (search "ebusd") and adjust the templates.

Notes:
- `ErrorBroadcast` (text) is not created – the default `mqtt-hassio.cfg` skips text fields. Use `ErrorStatus`.
- HG02–HG04 are raw values (0–255); percent = raw / 2.55.
- Values that are only read on demand appear after the first read (see step 3).

## 3. Read the slow values

[`automations/read_slow_values.yaml`](automations/read_slow_values.yaml) publishes `ebusd/boiler/<name>/get` for every parameter, counter and the error history once per hour and one minute after a (re)start. Import it in the automation editor (*Edit in YAML*) and adjust `binary_sensor.ebusd_global_running` to your entity ID.

For the fast values (`FlowTemp`, `FlowTemp2`, `HwcTemp`, `ErrorStatus`, `ModulationStatus`) change `r` to `r1` in your copy of the CSV – ebusd then polls them itself (every ~30 s with 5 polled messages).

## 4. Template sensors

Create them as template helpers (*Settings → Devices & services → Helpers → Create helper → Template → Template sensor*) and paste the file content as state template.

| File | Sensor | Unit / class |
|---|---|---|
| [`templates/operating_mode.jinja`](templates/operating_mode.jinja) | operating mode as text (Off, Start phase, Ignition, Burner on, Fault, Shutdown phase) | – |
| [`templates/operating_status.jinja`](templates/operating_status.jinja) | 0800 operating status as text (Standby, Heating, Heating burner pause, Hot water draw, …) | – |
| [`templates/error.jinja`](templates/error.jinja) | current error with text, e.g. `Error 8: Flue gas damper does not switch` | – |
| [`templates/last_error.jinja`](templates/last_error.jinja) | newest error history entry with approximate time | – |
| [`templates/gas_heating.jinja`](templates/gas_heating.jinja) | estimated gas flow heating | m³/h, volume flow rate, measurement |
| [`templates/gas_hot_water.jinja`](templates/gas_hot_water.jinja) | estimated gas flow hot water | m³/h, volume flow rate, measurement |

`error.jinja` and `last_error.jinja` use the macro `error_text()`: copy [`custom_templates/wolf_ebus.jinja`](custom_templates/wolf_ebus.jinja) to `/config/custom_templates/` and run the action `homeassistant.reload_custom_templates`.

### Gas consumption

- The gas flow templates are an **estimate** (model in [docs/behaviour.md](../../docs/behaviour.md#gas-consumption-estimate)). Calibrate `factor` with your gas meter: read the meter before and after one burner run and compare with the integrated value.
- For a consumption counter in m³ add an *Integral (Riemann sum)* helper per sensor (method *left*, time unit hours). The sum of both can be used in the energy dashboard as gas source (kWh = m³ × calorific value × state number of your gas supplier).

## 5. Notification on errors

[`automations/error_notification.yaml`](automations/error_notification.yaml) creates a persistent notification and a push message when the error sensor (`error.jinja`, here `sensor.boiler_error`) shows an error and when it is cleared. Replace `notify.notify` with your service.

The same logic runs on the test installation; a test with a real (not provoked) error is still pending.
