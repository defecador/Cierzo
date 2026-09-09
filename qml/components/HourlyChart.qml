/* Temperature curve over the hours ahead, with the chance of precipitation
   hanging from the plot floor. One scale places the marks and the labels. */
import QtQuick 2.6
import Sailfish.Silica 1.0
import "../js/wx.js" as Wx

Canvas {
    id: chart

    property var  hours: []
    property bool us: false

    property real padLeft: Theme.paddingLarge * 2.4
    property real padRight: Theme.paddingMedium
    property real padTop: Theme.paddingLarge * 1.6
    property real bandHeight: Theme.itemSizeExtraSmall * 0.8   // precipitation band
    property real labelRow: Theme.fontSizeSmall * 2.2

    antialiasing: true
    onHoursChanged: requestPaint()
    onUsChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    function ticks(lo, hi) {
        var span = Math.max(hi - lo, 2)
        var steps = [1, 2, 2.5, 5, 10, 20], step = 25
        for (var i = 0; i < steps.length; i++) if (span / steps[i] <= 4) { step = steps[i]; break }
        var a = Math.floor(lo / step) * step, out = []
        for (var v = a; v <= hi + step * 0.001; v += step) out.push(v)
        return out
    }

    onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        if (!hours || hours.length < 2) return

        var temps = [], i
        for (i = 0; i < hours.length; i++) temps.push(hours[i].t)
        var tk = ticks(Math.min.apply(null, temps), Math.max.apply(null, temps))
        var lo = tk[0], hi = tk[tk.length - 1]

        var left = padLeft, right = width - padRight
        var top = padTop, floorY = height - labelRow - bandHeight
        var X = function (n) { return left + (right - left) * n / (hours.length - 1) }
        var Y = function (t) { return floorY - (floorY - top) * (t - lo) / (hi - lo) }

        var tiny = Theme.fontSizeTiny
        ctx.font = tiny + "px sans-serif"
        ctx.textBaseline = "middle"

        /* scale: a line per tick, labelled with a value the curve reaches */
        for (i = 0; i < tk.length; i++) {
            ctx.strokeStyle = Theme.rgba(Theme.primaryColor, 0.13)
            ctx.lineWidth = 1
            ctx.beginPath(); ctx.moveTo(left, Y(tk[i])); ctx.lineTo(right, Y(tk[i])); ctx.stroke()
            ctx.fillStyle = Theme.secondaryColor
            ctx.textAlign = "right"
            ctx.fillText(Wx.temp(tk[i], us) + "°", left - Theme.paddingSmall, Y(tk[i]))
        }

        /* chance of precipitation */
        var maxPop = 0, peak = -1
        for (i = 0; i < hours.length; i++) if (hours[i].pop > maxPop) { maxPop = hours[i].pop; peak = i }
        var bw = Math.max(2, (right - left) / hours.length * 0.5)
        for (i = 0; i < hours.length; i++) {
            var p = hours[i].pop
            if (!p) continue
            var h = bandHeight * p / 100
            ctx.fillStyle = Theme.rgba(Theme.highlightColor, 0.45)
            ctx.fillRect(X(i) - bw / 2, floorY + bandHeight - h, bw, h)
        }
        ctx.strokeStyle = Theme.rgba(Theme.primaryColor, 0.25)
        ctx.beginPath()
        ctx.moveTo(left, floorY + bandHeight); ctx.lineTo(right, floorY + bandHeight); ctx.stroke()
        if (maxPop > 0) {
            ctx.fillStyle = Theme.highlightColor
            ctx.textAlign = "center"
            ctx.fillText(maxPop + "%", X(peak), floorY + bandHeight - bandHeight * maxPop / 100 - tiny * 0.8)
        }

        /* midnight divider and the weekday it begins */
        for (i = 1; i < hours.length; i++) {
            if (hours[i].hour !== 0) continue
            ctx.strokeStyle = Theme.rgba(Theme.primaryColor, 0.3)
            ctx.lineWidth = 1
            ctx.beginPath(); ctx.moveTo(X(i), top - tiny); ctx.lineTo(X(i), floorY + bandHeight); ctx.stroke()
            ctx.fillStyle = Theme.secondaryColor
            ctx.textAlign = "left"
            var d = new Date(hours[i].date + "T12:00:00")
            ctx.fillText(d.toLocaleDateString(Qt.locale(), "ddd"), X(i) + Theme.paddingSmall / 2, top - tiny)
        }

        /* hour labels, every third hour */
        ctx.fillStyle = Theme.secondaryColor
        ctx.textAlign = "center"
        for (i = 0; i < hours.length; i++) {
            if (hours[i].hour % 3 !== 0) continue
            ctx.fillText(("0" + hours[i].hour).slice(-2), X(i), height - labelRow / 2)
        }

        /* the curve, over a fade to the plot floor */
        var grad = ctx.createLinearGradient(0, top, 0, floorY)
        grad.addColorStop(0, Theme.rgba(Theme.highlightColor, 0.28))
        grad.addColorStop(1, Theme.rgba(Theme.highlightColor, 0.0))
        ctx.fillStyle = grad
        ctx.beginPath()
        ctx.moveTo(X(0), floorY)
        for (i = 0; i < hours.length; i++) ctx.lineTo(X(i), Y(temps[i]))
        ctx.lineTo(X(hours.length - 1), floorY)
        ctx.closePath(); ctx.fill()

        ctx.strokeStyle = Theme.highlightColor
        ctx.lineWidth = Math.max(2, Theme.pixelRatio * 2.2)
        ctx.lineJoin = "round"
        ctx.beginPath()
        for (i = 0; i < hours.length; i++) {
            if (i === 0) ctx.moveTo(X(0), Y(temps[0])); else ctx.lineTo(X(i), Y(temps[i]))
        }
        ctx.stroke()

        for (i = 3; i < hours.length; i += 3) {
            ctx.fillStyle = Wx.tempColor(temps[i])
            ctx.beginPath(); ctx.arc(X(i), Y(temps[i]), Theme.pixelRatio * 2.6, 0, Math.PI * 2); ctx.fill()
        }

        /* the warmest and the coldest hour ahead, named where they fall */
        var hot = 0, cold = 0
        for (i = 1; i < hours.length; i++) {
            if (temps[i] > temps[hot]) hot = i
            if (temps[i] < temps[cold]) cold = i
        }
        ctx.font = "500 " + Theme.fontSizeExtraSmall + "px sans-serif"
        ctx.textAlign = "center"
        if (hot > 0) {
            ctx.fillStyle = Wx.tempColor(temps[hot])
            ctx.fillText(Wx.tempS(temps[hot], us), X(hot), Y(temps[hot]) - Theme.fontSizeSmall)
        }
        if (cold > 0 && cold !== hot) {
            ctx.fillStyle = Wx.tempColor(temps[cold])
            ctx.fillText(Wx.tempS(temps[cold], us), X(cold), Y(temps[cold]) + Theme.fontSizeSmall)
        }

        /* now */
        ctx.fillStyle = Theme.highlightDimmerColor
        ctx.strokeStyle = Wx.tempColor(temps[0])
        ctx.lineWidth = Math.max(2, Theme.pixelRatio * 2.4)
        ctx.beginPath(); ctx.arc(X(0), Y(temps[0]), Theme.pixelRatio * 4.4, 0, Math.PI * 2)
        ctx.fill(); ctx.stroke()
        ctx.fillStyle = Theme.highlightColor
        ctx.textAlign = "left"
        ctx.font = tiny + "px sans-serif"
        ctx.fillText(qsTr("now"), X(0) - Theme.paddingSmall / 2, top - tiny)
    }
}
