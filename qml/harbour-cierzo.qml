/*
 * Cierzo — a surface observation and forecast reader for Sailfish OS.
 * Named after the cold north-westerly of the Ebro valley.
 */
import QtQuick 2.6
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "pages"
import "js/wx.js" as Wx

ApplicationWindow {
    id: app

    /* ---- settings and state, read by every page and by the cover ---- */
    property bool   us: false               // Fahrenheit, miles, inches
    property string model: "best_match"     // which met service's model
    property var    places: []              // [{ name, sub, lat, lon }]
    property int    placeIndex: 0
    property var    wx: null                // parsed reading, or null
    property bool   loading: false
    property string error: ""
    property string cachedAt: ""            // set when showing a stored reading

    readonly property var place: (placeIndex >= 0 && placeIndex < places.length)
                                ? places[placeIndex] : null

    allowedOrientations: defaultAllowedOrientations
    initialPage: Component { ForecastPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    /* ---------------- store: settings, places, last reading ---------------- */
    function db() {
        var d = LocalStorage.openDatabaseSync("cierzo", "1.0", "Cierzo store", 400000)
        d.transaction(function (tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS kv(k TEXT PRIMARY KEY, v TEXT)")
        })
        return d
    }
    function put(key, value) {
        db().transaction(function (tx) {
            tx.executeSql("INSERT OR REPLACE INTO kv VALUES(?,?)", [key, value])
        })
    }
    function take(key) {
        var out = ""
        db().transaction(function (tx) {
            var r = tx.executeSql("SELECT v FROM kv WHERE k=?", [key])
            if (r.rows.length > 0) out = r.rows.item(0).v
        })
        return out
    }

    function persist() {
        put("units", us ? "us" : "si")
        put("model", model)
        put("places", JSON.stringify(places))
        put("placeIndex", String(placeIndex))
    }
    function restore() {
        us = take("units") === "us"
        var m = take("model"); if (m) model = m
        var p = take("places")
        if (p) { try { places = JSON.parse(p) } catch (e) { places = [] } }
        var i = parseInt(take("placeIndex"), 10)
        placeIndex = (!isNaN(i) && i < places.length) ? i : 0
    }

    /* ---------------- network ---------------- */
    function fetch(url, ok, fail) {
        var x = new XMLHttpRequest()
        x.onreadystatechange = function () {
            if (x.readyState !== XMLHttpRequest.DONE) return
            if (x.status === 200) {
                try { ok(JSON.parse(x.responseText)) }
                catch (e) { fail(qsTr("The service sent something unreadable")) }
            } else if (x.status === 0) {
                fail(qsTr("No network"))
            } else {
                fail(qsTr("Weather service error %1").arg(x.status))
            }
        }
        x.open("GET", url)
        x.send()
    }

    function refresh() {
        if (!place) return
        loading = true
        error = ""
        var key = "cache:" + place.lat.toFixed(3) + "," + place.lon.toFixed(3) + ":" + model
        fetch(Wx.forecastUrl(place.lat, place.lon, model),
              function (raw) {
                  loading = false
                  cachedAt = ""
                  wx = Wx.parse(raw)
                  put(key, JSON.stringify(raw))
                  put(key + ":at", new Date().toISOString())
              },
              function (msg) {
                  loading = false
                  var stored = take(key)
                  if (stored) {
                      try {
                          wx = Wx.parse(JSON.parse(stored))
                          var at = take(key + ":at")
                          cachedAt = at ? Qt.formatDateTime(new Date(at), "d MMM hh:mm") : qsTr("earlier")
                          error = ""
                          return
                      } catch (e) { /* fall through to the error */ }
                  }
                  wx = null
                  error = msg
              })
    }

    /* ---------------- places ---------------- */
    function addPlace(name, sub, lat, lon) {
        var list = places.slice()
        for (var i = 0; i < list.length; i++)
            if (Math.abs(list[i].lat - lat) < 0.01 && Math.abs(list[i].lon - lon) < 0.01) {
                places = list; placeIndex = i; persist(); refresh(); return
            }
        list.push({ name: name, sub: sub, lat: lat, lon: lon })
        places = list
        placeIndex = list.length - 1
        persist()
        refresh()
    }
    function removePlace(i) {
        var list = places.slice()
        list.splice(i, 1)
        places = list
        if (placeIndex >= list.length) placeIndex = Math.max(0, list.length - 1)
        persist()
        if (list.length === 0) wx = null
        else refresh()
    }
    function selectPlace(i) {
        placeIndex = i
        wx = null
        persist()
        refresh()
    }

    Component.onCompleted: {
        restore()
        if (places.length > 0) refresh()
    }
}
