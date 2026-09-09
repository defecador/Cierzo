/* Drawn rather than shipped as bitmaps, so it takes the ambience colour
   and stays sharp at every size the pages ask for. */
import QtQuick 2.6
import Sailfish.Silica 1.0

Canvas {
    id: glyph

    property string kind: "cloud"     // sun suncloud cloud fog drizzle rain showers snow storm
    property bool   isDay: true
    property color  color: Theme.primaryColor

    width: Theme.itemSizeSmall
    height: width
    antialiasing: true

    onKindChanged: requestPaint()
    onIsDayChanged: requestPaint()
    onColorChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        var u = width / 24                      // the shapes are authored on a 24-unit grid
        ctx.fillStyle = color
        ctx.strokeStyle = color
        ctx.lineCap = "round"

        function disc(x, y, r) {
            ctx.beginPath(); ctx.arc(x * u, y * u, r * u, 0, Math.PI * 2); ctx.fill()
        }
        function bar(x, y, w, h, r) {
            ctx.beginPath()
            ctx.moveTo((x + r) * u, y * u)
            ctx.arcTo((x + w) * u, y * u, (x + w) * u, (y + h) * u, r * u)
            ctx.arcTo((x + w) * u, (y + h) * u, x * u, (y + h) * u, r * u)
            ctx.arcTo(x * u, (y + h) * u, x * u, y * u, r * u)
            ctx.arcTo(x * u, y * u, (x + w) * u, y * u, r * u)
            ctx.fill()
        }
        function cloud(dy) {
            disc(9, 12.4 + dy, 3.9); disc(14.2, 11.2 + dy, 4.8); disc(17.6, 14.2 + dy, 3.0)
            bar(5.1, 13.2 + dy, 14.5, 4.4, 2.2)
        }
        function stroke(x1, y1, x2, y2, w) {
            ctx.lineWidth = w * u
            ctx.beginPath(); ctx.moveTo(x1 * u, y1 * u); ctx.lineTo(x2 * u, y2 * u); ctx.stroke()
        }
        function crescent(cx, cy, r) {
            /* the lit limb: a disc with a second disc taken out of it */
            ctx.save()
            ctx.beginPath(); ctx.arc(cx * u, cy * u, r * u, 0, Math.PI * 2)
            ctx.arc((cx + r * 0.62) * u, (cy - r * 0.46) * u, r * 0.88 * u, 0, Math.PI * 2, true)
            ctx.fill("evenodd")
            ctx.restore()
        }
        function rays(cx, cy, r0, r1, w) {
            for (var a = 0; a < 360; a += 45) {
                var t = a * Math.PI / 180
                stroke(cx + r0 * Math.cos(t), cy + r0 * Math.sin(t),
                       cx + r1 * Math.cos(t), cy + r1 * Math.sin(t), w)
            }
        }
        function drops(heavy) {
            var w = heavy ? 1.8 : 1.3
            stroke(8.5, 18, 7.4, 22, w); stroke(12.4, 18, 11.3, 22.4, w); stroke(16.3, 18, 15.2, 22, w)
        }
        function flake(cx, cy) {
            stroke(cx - 2, cy, cx + 2, cy, 1.3)
            stroke(cx - 1, cy - 1.7, cx + 1, cy + 1.7, 1.3)
            stroke(cx + 1, cy - 1.7, cx - 1, cy + 1.7, 1.3)
        }

        if (kind === "sun") {
            if (isDay) { ctx.globalAlpha = 0.85; rays(12, 12, 7.6, 10.6, 1.5); ctx.globalAlpha = 1; disc(12, 12, 5) }
            else crescent(12, 12, 7.4)
        } else if (kind === "suncloud") {
            if (isDay) {
                ctx.globalAlpha = 0.8; rays(8.5, 9.6, 4.6, 6.8, 1.25); ctx.globalAlpha = 1
                disc(8.5, 9.6, 3.2)
            } else crescent(8.8, 8.8, 4.8)
            ctx.globalAlpha = 0.92; cloud(2.2); ctx.globalAlpha = 1
        } else if (kind === "cloud") {
            ctx.globalAlpha = 0.95; cloud(0); ctx.globalAlpha = 1
        } else if (kind === "fog") {
            ctx.globalAlpha = 0.8; cloud(-2.4); ctx.globalAlpha = 0.75
            stroke(5, 19.4, 17, 19.4, 1.6); stroke(8, 22.4, 19, 22.4, 1.6)
            ctx.globalAlpha = 1
        } else if (kind === "drizzle") {
            cloud(-2.4); drops(false)
        } else if (kind === "rain" || kind === "showers") {
            cloud(-2.4); drops(true)
        } else if (kind === "snow") {
            cloud(-2.4); flake(8.6, 20.6); flake(15.4, 20.6)
        } else if (kind === "storm") {
            cloud(-2.8)
            ctx.beginPath()
            ctx.moveTo(13.4 * u, 17.0 * u); ctx.lineTo(9.2 * u, 17.0 * u)
            ctx.lineTo(12.2 * u, 23.6 * u); ctx.lineTo(11.0 * u, 19.5 * u)
            ctx.lineTo(14.8 * u, 19.5 * u); ctx.closePath(); ctx.fill()
        }
    }
}
