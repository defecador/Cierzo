# OpenRepos listing copy for Cierzo

Paste into the fields at https://openrepos.net/node/add/application
(Platform: SailfishOS. Pick the category from their dropdown —
"Applications" fits; there is no dedicated weather category.)

---

## Title

Cierzo

## Summary / teaser

A weather reader shaped like a station report, not a set of cards.

## Description

Cierzo shows the weather the way an observation reports it.

**The reading now** — temperature on a fixed colour ramp, so the same
number is always the same colour; the condition; what it feels like.

**Wind** — a compass whose barb points the way the air is going, with the
direction it comes from in figures beside it, and the Beaufort force.

**The rest of the observation** — pressure with its three-hour tendency,
the interval a station report uses; humidity with the dew point derived
by the Magnus formula; cloud cover in oktas; visibility; UV index; the
length of the day.

**Next 48 hours** — one temperature curve on a single scale, with the
chance of precipitation hanging below it and midnight marked by the
weekday it begins. Swipes sideways.

**Seven days** — each day's range drawn as a bar on a scale shared by the
whole week, so the rows can be read against one another instead of one at
a time. Today's bar carries a pin at the current temperature. Tap a day
for hour by hour.

**The cover** — place, condition, temperature, today's range, and a
refresh action.

### Choosing whose forecast you trust

Settings names the meteorological service whose model produces the
figures, and the forecast page always prints which one it was:

* Best available — the highest-resolution model covering the place
* ECMWF IFS — European Centre for Medium-Range Weather Forecasts
* ICON — Deutscher Wetterdienst
* ARPEGE / AROME — Météo-France
* MET Nordic — Meteorologisk institutt, Norway
* UM — UK Met Office
* GFS — NOAA, United States

Data is served by Open-Meteo. No account, no API key, no tracking, no
advertising. Note that ECMWF and Météo-France publish no visibility or UV
index, and Cierzo says "not in this model" rather than inventing a number.

### Other things worth knowing

* Colours come from your ambience — Cierzo hardcodes no palette.
* Icons are drawn on canvas, so they stay sharp at any size.
* The last reading is cached on the phone and shown with the time it was
  taken when there is no signal.
* Pure QML, no compiled code: one noarch package for every device.
* Places are saved locally; "Use my position" uses GPS only when tapped.
* Asks for two permissions only — Internet and Location. No camera,
  microphone, Bluetooth, NFC or file access.

Free software under GPL-3.0. Source: https://github.com/defecador/Cierzo

## Changelog — 0.1.4

About page: shorter sources section.

## Changelog — 0.1.3

Runs sandboxed with Internet and Location only. Previous versions declared
no permissions, so Sailfish granted its default set of twelve.

## Changelog — 0.1.2

Hourly chart: the warmest and coldest hour of the run are labelled again
(Qt's Canvas silently refuses a numeric font weight, so those two labels
had never been drawing), labels stay inside the plot, and the "now"
caption no longer sits on its own marker.

## Changelog — 0.1.1

Name a GPS position properly. Open-Meteo publishes no reverse geocoding
endpoint, so positions were being saved as "Here"; Cierzo now asks a
service that has one.

## Changelog — 0.1.0

First release. Current observation in synoptic units, 48-hour temperature
curve with precipitation chance, seven days on one shared scale, per-day
hourly detail, selectable forecast model, saved places, GPS location,
offline cache of the last reading, and a cover with refresh.

---

## Upload checklist

* [ ] RPM: `RPMS/harbour-cierzo-0.1.4-1.noarch.rpm`
      (noarch — one file covers aarch64 and armv7hl)
* [ ] Icon: `icons/172x172/harbour-cierzo.png`
* [x] Screenshots: packaging/openrepos/screenshots/ (taken on device,
      Jolla at 1032x2272 — portrait pair plus the 48-hour chart in landscape)
* [ ] Licence: GPL-3.0
* [ ] Source URL: https://github.com/defecador/Cierzo

### Screenshots

With the phone connected over USB networking and the app open on screen:

```bash
ssh defaultuser@192.168.2.15 \
  'dbus-send --session --print-reply --dest=org.nemomobile.lipstick \
     /org/nemomobile/lipstick/screenshot \
     org.nemomobile.lipstick.saveScreenshot \
     string:/home/defaultuser/Pictures/cierzo-1.png'
scp defaultuser@192.168.2.15:~/Pictures/cierzo-*.png .
```

Worth capturing: the forecast page, the seven-day scale, a day's hourly
detail, and the Settings model picker.

### Optional: uploading from the command line

`openrepos-webclient` drives the website with Selenium and needs Firefox
plus geckodriver. It reads your credentials from the environment, so keep
them in a file you source rather than on the command line:

```bash
pip install --user openrepos-webclient
source ~/openrepos-credentials.sh   # exports OPENREPOS_USERNAME/PASSWORD
openrepos upload-rpm -n Cierzo -p SailfishOS -c Applications \
    RPMS/harbour-cierzo-0.1.4-1.noarch.rpm
```

It was last released in 2023 and automates the live site, so check the
result in the browser afterwards.
