/* A compass with a barb pointing downwind — the direction the air is going,
   while the figures below report the direction it comes from. */
import QtQuick 2.6
import Sailfish.Silica 1.0

Canvas {
    id: rose

    property real direction: 0        // degrees the wind blows FROM
    property real speed: 0            // km/h, sets the barb's length
    property color ring: Theme.rgba(Theme.primaryColor, 0.4)
    property color needle: Theme.highlightColor

    width: Theme.itemSizeMedium
    height: width
    antialiasing: true

    onDirectionChanged: requestPaint()
    onSpeedChanged: requestPaint()
    onNeedleChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        var c = width / 2, r = c * 0.86
        var rad = function (deg) { return (deg - 90) * Math.PI / 180 }

        ctx.strokeStyle = ring
        ctx.lineWidth = Math.max(1, width / 90)
        ctx.beginPath(); ctx.arc(c, c, r, 0, Math.PI * 2); ctx.stroke()

        for (var a = 0; a < 360; a += 30) {
            var cardinal = (a % 90) === 0
            var r1 = cardinal ? r * 0.8 : r * 0.9
            ctx.lineWidth = cardinal ? Math.max(1.2, width / 70) : Math.max(1, width / 110)
            ctx.globalAlpha = cardinal ? 0.85 : 0.45
            ctx.beginPath()
            ctx.moveTo(c + r1 * Math.cos(rad(a)), c + r1 * Math.sin(rad(a)))
            ctx.lineTo(c + r * Math.cos(rad(a)), c + r * Math.sin(rad(a)))
            ctx.stroke()
        }
        ctx.globalAlpha = 1

        var len = r * Math.min(0.92, 0.36 + speed * 0.012)
        ctx.save()
        ctx.translate(c, c)
        ctx.rotate((direction + 180) * Math.PI / 180)
        ctx.strokeStyle = needle
        ctx.fillStyle = needle
        ctx.lineWidth = Math.max(2, width / 34)
        ctx.lineCap = "round"
        ctx.beginPath(); ctx.moveTo(0, len * 0.5); ctx.lineTo(0, -len * 0.72); ctx.stroke()
        ctx.beginPath()
        ctx.moveTo(0, -len)
        ctx.lineTo(len * 0.2, -len * 0.66)
        ctx.lineTo(-len * 0.2, -len * 0.66)
        ctx.closePath(); ctx.fill()
        ctx.restore()

        ctx.fillStyle = ring
        ctx.beginPath(); ctx.arc(c, c, Math.max(1.5, width / 40), 0, Math.PI * 2); ctx.fill()
    }
}
