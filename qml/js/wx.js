/*
 * wx.js — Cierzo's meteorology and data layer.
 * Plain JS so it can be unit-tested outside QML; .pragma library means one
 * shared copy across every page that imports it (no per-page state).
 */
.pragma library

/* ------------------------------------------------------------------ *
 * Sources. Open-Meteo needs no API key and serves national met-service
 * models directly, so the reader can choose whose model they trust.
 * ------------------------------------------------------------------ */
var API = "https://api.open-meteo.com/v1/forecast"
var GEO = "https://geocoding-api.open-meteo.com/v1"
var REVGEO = "https://api.bigdatacloud.net/data/reverse-geocode-client"

var MODELS = [
    { id: "best_match",             name: "Best available",     by: "Open-Meteo picks the highest-resolution model covering the place" },
    { id: "ecmwf_ifs025",           name: "ECMWF IFS",          by: "European Centre for Medium-Range Weather Forecasts" },
    { id: "icon_seamless",          name: "ICON",               by: "Deutscher Wetterdienst" },
    { id: "meteofrance_seamless",   name: "ARPEGE / AROME",     by: "Météo-France" },
    { id: "metno_seamless",         name: "MET Nordic",         by: "Meteorologisk institutt, Norway" },
    { id: "ukmo_seamless",          name: "UM",                 by: "UK Met Office" },
    { id: "gfs_seamless",           name: "GFS",                by: "NOAA, United States" }
]

function modelName(id) {
    for (var i = 0; i < MODELS.length; i++)
        if (MODELS[i].id === id) return MODELS[i].name
    return id
}
function modelBy(id) {
    for (var i = 0; i < MODELS.length; i++)
        if (MODELS[i].id === id) return MODELS[i].by
    return ""
}

var CURRENT = "temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,"
            + "weather_code,cloud_cover,pressure_msl,wind_speed_10m,wind_direction_10m,wind_gusts_10m"
var HOURLY  = "temperature_2m,precipitation_probability,precipitation,weather_code,visibility,"
            + "uv_index,pressure_msl,relative_humidity_2m,wind_speed_10m,wind_direction_10m,is_day"
var DAILY   = "weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,"
            + "precipitation_sum,precipitation_probability_max,uv_index_max,wind_speed_10m_max"

function forecastUrl(lat, lon, model) {
    var u = API + "?latitude=" + lat.toFixed(4) + "&longitude=" + lon.toFixed(4)
          + "&current=" + CURRENT + "&hourly=" + HOURLY + "&daily=" + DAILY
          + "&timezone=auto&past_days=1&forecast_days=7"
    if (model && model !== "best_match") u += "&models=" + model
    return u
}
function searchUrl(q) {
    return GEO + "/search?count=8&language=en&format=json&name=" + encodeURIComponent(q)
}
/* Open-Meteo's geocoder only searches forwards — it has no reverse endpoint —
   so naming a GPS fix takes a second, equally keyless service. */
function reverseUrl(lat, lon) {
    return REVGEO + "?latitude=" + lat + "&longitude=" + lon + "&localityLanguage=en"
}
function reverseName(d) {
    return d.city || d.locality || d.principalSubdivision || ""
}
function reverseSub(d) {
    var parts = []
    if (d.principalSubdivision && d.principalSubdivision !== reverseName(d))
        parts.push(d.principalSubdivision)
    if (d.countryName) parts.push(d.countryName)
    return parts.join(", ")
}

/* ------------------------------------------------------------------ *
 * WMO 4677 present weather, grouped to the shapes Cierzo can draw.
 * ------------------------------------------------------------------ */
var WMO = {
    0:  ["Clear sky", "sun"],        1:  ["Mainly clear", "suncloud"],
    2:  ["Partly cloudy", "suncloud"], 3: ["Overcast", "cloud"],
    45: ["Fog", "fog"],              48: ["Freezing fog", "fog"],
    51: ["Light drizzle", "drizzle"], 53: ["Drizzle", "drizzle"],
    55: ["Heavy drizzle", "drizzle"], 56: ["Freezing drizzle", "drizzle"],
    57: ["Freezing drizzle", "drizzle"],
    61: ["Light rain", "rain"],       63: ["Rain", "rain"],
    65: ["Heavy rain", "rain"],       66: ["Freezing rain", "rain"],
    67: ["Heavy freezing rain", "rain"],
    71: ["Light snow", "snow"],       73: ["Snow", "snow"],
    75: ["Heavy snow", "snow"],       77: ["Snow grains", "snow"],
    80: ["Rain showers", "showers"],  81: ["Rain showers", "showers"],
    82: ["Violent rain showers", "showers"],
    85: ["Snow showers", "snow"],     86: ["Heavy snow showers", "snow"],
    95: ["Thunderstorm", "storm"],    96: ["Thunderstorm with hail", "storm"],
    99: ["Thunderstorm, heavy hail", "storm"]
}
function condition(code) {
    var c = WMO[code]
    return c ? { label: c[0], kind: c[1] } : { label: "—", kind: "cloud" }
}

/* ------------------------------------------------------------------ *
 * Derived quantities a station would report.
 * ------------------------------------------------------------------ */

/* Magnus-Tetens: dew point from dry-bulb temperature and relative humidity */
function dewPoint(t, rh) {
    var a = 17.625, b = 243.04
    var g = Math.log(Math.max(rh, 1) / 100) + (a * t) / (b + t)
    return (b * g) / (a - g)
}

var BEAUFORT = [[1, "Calm"], [6, "Light air"], [12, "Light breeze"], [20, "Gentle breeze"],
                [29, "Moderate breeze"], [39, "Fresh breeze"], [50, "Strong breeze"],
                [62, "Near gale"], [75, "Gale"], [89, "Strong gale"], [103, "Storm"],
                [118, "Violent storm"]]
function beaufort(kmh) {
    for (var i = 0; i < BEAUFORT.length; i++)
        if (kmh < BEAUFORT[i][0]) return { force: i, name: BEAUFORT[i][1] }
    return { force: 12, name: "Hurricane" }
}

var POINTS = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
              "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
function compass(deg) {
    return POINTS[Math.round((((deg % 360) + 360) % 360) / 22.5) % 16]
}

/* cloud cover in oktas, as a synoptic report gives it */
function oktas(pct) { return Math.round(pct / 12.5) }
function oktasName(ok) {
    return ok === 0 ? "sky clear" : ok <= 2 ? "few" : ok <= 4 ? "scattered"
         : ok <= 7 ? "broken" : "overcast"
}

function uvName(uv) {
    return uv >= 11 ? "extreme" : uv >= 8 ? "very high" : uv >= 6 ? "high"
         : uv >= 3 ? "moderate" : "low"
}

/* barometric tendency over three hours, the interval a METAR uses */
function tendency(now, then) {
    if (then === null || then === undefined) return { dir: 0, text: "not available" }
    var d = now - then
    var dir = d > 0.6 ? 1 : d < -0.6 ? -1 : 0
    var word = dir > 0 ? "rising" : dir < 0 ? "falling" : "steady"
    return { dir: dir, delta: d,
             text: word + " " + (d >= 0 ? "+" : "−") + Math.abs(d).toFixed(1) + " hPa/3h" }
}

/* ------------------------------------------------------------------ *
 * Units. Everything is requested in metric and converted on the way out.
 * ------------------------------------------------------------------ */
function temp(c, us)     { return Math.round(us ? c * 9 / 5 + 32 : c) }
function tempS(c, us)    { return temp(c, us) + "°" }
function speed(kmh, us)  { return us ? Math.round(kmh / 1.60934) + " mph" : Math.round(kmh) + " km/h" }
function pressure(h, us) { return us ? (h * 0.0295300).toFixed(2) + " inHg" : Math.round(h) + " hPa" }
function depth(mm, us) {
    if (us) return (mm / 25.4).toFixed(2) + " in"
    return (mm >= 10 ? Math.round(mm) : mm.toFixed(1)) + " mm"
}
function distance(m, us) {
    if (m === null || m === undefined) return "—"
    if (us) return (m / 1609.34).toFixed(1) + " mi"
    return m >= 1000 ? (m / 1000).toFixed(m >= 10000 ? 0 : 1) + " km" : Math.round(m) + " m"
}

/* temperature ramp, in °C — used only to encode value, never as decoration */
var RAMP = [[-20, [47, 79, 158]], [-5, [63, 127, 192]], [5, [73, 165, 189]],
            [13, [90, 165, 132]], [20, [194, 161, 43]], [28, [212, 118, 42]],
            [36, [185, 51, 35]]]
function tempColor(c) {
    if (c <= RAMP[0][0]) return rgbHex(RAMP[0][1])
    for (var i = 1; i < RAMP.length; i++) {
        if (c <= RAMP[i][0]) {
            var a = RAMP[i - 1], b = RAMP[i], f = (c - a[0]) / (b[0] - a[0]), out = []
            for (var k = 0; k < 3; k++) out.push(Math.round(a[1][k] + (b[1][k] - a[1][k]) * f))
            return rgbHex(out)
        }
    }
    return rgbHex(RAMP[RAMP.length - 1][1])
}
function rgbHex(c) {
    var s = "#"
    for (var i = 0; i < 3; i++) s += ("0" + c[i].toString(16)).slice(-2)
    return s
}

/* ------------------------------------------------------------------ *
 * Parsing. Open-Meteo returns local wall-clock strings ("2026-09-09T14:00")
 * for the place's own time zone, so hours are read off the string and never
 * pushed through the phone's time zone.
 * ------------------------------------------------------------------ */
function hourOf(t)  { return parseInt(t.slice(11, 13), 10) }
function dateOf(t)  { return t.slice(0, 10) }
function clockOf(t) { return t.slice(11, 16) }

function parse(raw) {
    var cur = raw.current, H = raw.hourly, D = raw.daily
    var stamp = cur.time.slice(0, 13) + ":00"
    var i = H.time.indexOf(stamp)
    if (i < 0) {
        i = 0
        while (i < H.time.length - 1 && H.time[i] < cur.time) i++
    }
    var today = D.time.indexOf(dateOf(cur.time))
    if (today < 0) today = 0

    var cond = condition(cur.weather_code)
    var wind = beaufort(cur.wind_speed_10m)

    var hours = []
    for (var k = i; k < Math.min(i + 48, H.time.length); k++) {
        hours.push({
            time: H.time[k],
            hour: hourOf(H.time[k]),
            date: dateOf(H.time[k]),
            t: H.temperature_2m[k],
            pop: H.precipitation_probability ? (H.precipitation_probability[k] || 0) : 0,
            mm: H.precipitation ? (H.precipitation[k] || 0) : 0,
            rh: H.relative_humidity_2m ? H.relative_humidity_2m[k] : null,
            wind: H.wind_speed_10m ? H.wind_speed_10m[k] : null,
            dir: H.wind_direction_10m ? H.wind_direction_10m[k] : null,
            code: H.weather_code[k],
            day: H.is_day ? H.is_day[k] : 1
        })
    }

    var days = []
    for (var d = today; d < Math.min(today + 7, D.time.length); d++) {
        days.push({
            date: D.time[d],
            code: D.weather_code[d],
            min: D.temperature_2m_min[d],
            max: D.temperature_2m_max[d],
            mm: D.precipitation_sum[d] || 0,
            pop: D.precipitation_probability_max ? (D.precipitation_probability_max[d] || 0) : 0,
            uv: D.uv_index_max ? D.uv_index_max[d] : null,
            gust: D.wind_speed_10m_max ? D.wind_speed_10m_max[d] : null,
            sunrise: D.sunrise[d],
            sunset: D.sunset[d],
            today: d === today
        })
    }

    var rise = D.sunrise[today], set = D.sunset[today]
    var mins = function (s) { return parseInt(s.slice(11, 13), 10) * 60 + parseInt(s.slice(14, 16), 10) }
    var daylight = mins(set) - mins(rise)

    return {
        t: cur.temperature_2m,
        feels: cur.apparent_temperature,
        label: cond.label,
        kind: cond.kind,
        isDay: cur.is_day === 1,
        rh: cur.relative_humidity_2m,
        dew: dewPoint(cur.temperature_2m, cur.relative_humidity_2m),
        cloud: cur.cloud_cover,
        pressure: cur.pressure_msl,
        tendency: tendency(cur.pressure_msl, H.pressure_msl ? H.pressure_msl[i - 3] : null),
        windSpeed: cur.wind_speed_10m,
        windDir: cur.wind_direction_10m,
        gust: cur.wind_gusts_10m,
        force: wind.force,
        forceName: wind.name,
        rain1h: cur.precipitation,
        visibility: H.visibility ? H.visibility[i] : null,
        uv: H.uv_index ? H.uv_index[i] : null,
        uvMax: D.uv_index_max ? D.uv_index_max[today] : null,
        sunrise: clockOf(rise),
        sunset: clockOf(set),
        daylight: Math.floor(daylight / 60) + " h " + ("0" + (daylight % 60)).slice(-2),
        observed: clockOf(cur.time),
        timezone: raw.timezone,
        tzAbbr: raw.timezone_abbreviation,
        elevation: raw.elevation,
        hours: hours,
        days: days
    }
}
