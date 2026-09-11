# Cierzo

A weather reader for Sailfish OS, shaped like a station report rather than a
set of cards. Named after the cold north-westerly that funnels down the Ebro
valley.

Pure QML + Silica, run by `sailfish-qml`. No compiled code, so the package is
`noarch` and installs on any Sailfish device.

## Where the data comes from

You asked for eltiempo.es as the source. Worth knowing what that is:

* **eltiempo.es publishes no developer interface.** It is a Pelmorex property
  (the Canadian group behind The Weather Network). Nothing can read it directly
  without scraping its pages, which breaks the first time they change markup
  and is against their terms.
* **Its Spanish data is AEMET's.** The Spanish state meteorological agency is
  the upstream for its Spain forecasts and for every weather warning it shows.
  AEMET *does* publish an official API — but only for Spain, so it cannot serve
  an app used mainly outside the country.

So Cierzo reads **Open-Meteo**, which needs no account and serves the national
meteorological services' own models worldwide. Settings names the service you
want to trust, and the forecast page always prints which model produced the
figures on it:

| Option            | Produced by                                    |
|-------------------|------------------------------------------------|
| Best available    | highest-resolution model covering the place    |
| ECMWF IFS         | European Centre for Medium-Range Weather Forecasts |
| ICON              | Deutscher Wetterdienst                         |
| ARPEGE / AROME    | Météo-France                                   |
| MET Nordic        | Meteorologisk institutt, Norway                |
| UM                | UK Met Office                                  |
| GFS               | NOAA, United States                            |

All seven were checked against the live API. Note that **ECMWF and
Météo-France return no visibility or UV index** — those readings show “not in
this model” rather than a fabricated number.

If you later want Spain on AEMET itself, that is a second provider in
`qml/js/wx.js` plus an API key field in Settings; the key is free, by email.

## Permissions

Cierzo runs in the Sailfish sandbox and asks for two permissions:

* **Internet** — forecasts and place search from Open-Meteo, and naming a
  GPS position through BigDataCloud.
* **Location** — only when you tap *Use my position*.

Nothing else: no camera, microphone, Bluetooth, NFC, or access to your
files. Saved places and the cached forecast live in the app's own folder,
`~/.local/share/harbour-cierzo/harbour-cierzo/`, which every sandboxed app
gets without asking.

The profile is the `[X-Sailjail]` section of `harbour-cierzo.desktop`.
Without it, Sailfish applies a default profile of twelve permissions.

## Build

Every command below is relative to the project root, so start there —
`sfdk` looks for `rpm/*.spec` in the current directory and fails with
"No RPM SPEC or YAML file found" if it is run from anywhere else.

The SDK has no 5.2 target yet; a 5.1 build runs on 5.2.

```bash
cd ~/Cierzo
sfdk -c target=SailfishOS-5.1.0.11-aarch64 build
```

The package lands in `RPMS/harbour-cierzo-0.1.0-1.noarch.rpm`.

## Install on the phone

Enable Developer mode on the device (Settings → Developer tools), then:

Replace `PHONE-IP` with the address the phone shows under
Settings → Developer tools.

```bash
scp ~/Cierzo/RPMS/harbour-cierzo-0.1.0-1.noarch.rpm defaultuser@PHONE-IP:~/
```

and on the phone, or over `ssh defaultuser@PHONE-IP`:

```bash
devel-su pkcon install-local ~/harbour-cierzo-0.1.0-1.noarch.rpm -y
```

First run shows no place. Pull down → **Places** → search, or **Use my
position**.

## What is on screen

* **Now** — temperature coloured on a fixed ramp (blue through to red, so the
  same number is always the same colour), condition, apparent temperature.
* **Wind** — a compass whose barb points the way the air is *going*, with the
  direction it comes *from* in figures beside it, plus Beaufort force.
* **Observation** — pressure with its three-hour tendency (the interval a
  station report uses), humidity with dew point by the Magnus formula, cloud
  cover in oktas, visibility, UV index, daylight length.
* **Next 48 hours** — temperature curve on one scale, the chance of
  precipitation hanging below it, midnight marked with the weekday it starts.
  Swipes horizontally.
* **Seven days** — each day's range as a bar on a scale shared by the whole
  week, so rows read against each other. Today's bar carries a pin at the
  current temperature. Tap a day for hour-by-hour.
* **Cover** — place, condition, temperature, today's range, and a refresh
  action.

Readings are cached in local storage, so the last one is still there with no
signal, labelled with when it was taken.

## Jolla Store

`sfdk check` passes except for two findings:

* `QtPositioning` is not an allowed Harbour import, and neither is its
  `Requires`. Both exist only for **Use my position**.
* `explicit-lib-dependency libsailfishapp-launcher` and
  `desktopfile-without-binary sailfish-qml` are inherent to every QML-only
  package — Harbour accepts them.

To submit to the store, delete the `PositionSource` block and the
“Use my position” row in `qml/pages/PlacesPage.qml`, the `QtPositioning`
import, and the positioning `Requires` in `rpm/harbour-cierzo.spec`.
Sideloading as above needs none of that.

## Layout

```
qml/harbour-cierzo.qml      window, settings, places, fetch, cache
qml/js/wx.js                met calculations, units, WMO codes, parsing
qml/components/             WeatherIcon WindRose HourlyChart Reading DayRow
qml/pages/                  Forecast Day Places Settings About
qml/cover/CoverPage.qml     the cover
```

`wx.js` is plain JavaScript with no Qt dependency, so it can be exercised
outside QML — which is how the seven models and every parsed field were
checked against the live API.
