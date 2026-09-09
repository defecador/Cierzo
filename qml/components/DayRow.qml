/* One forecast day. The bar sits on a scale shared by the whole week, so the
   rows can be read against each other rather than one at a time. */
import QtQuick 2.6
import Sailfish.Silica 1.0
import "../js/wx.js" as Wx

BackgroundItem {
    id: row

    property var  day
    property real lo: 0          // coldest value in the week
    property real hi: 1          // warmest value in the week
    property bool us: false
    property real nowTemp: 0     // marked on today's bar only

    height: Theme.itemSizeSmall
    width: parent ? parent.width : 0

    Row {
        anchors {
            left: parent.left; right: parent.right
            leftMargin: Theme.horizontalPageMargin; rightMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
        spacing: Theme.paddingMedium

        Label {
            width: Theme.itemSizeExtraSmall * 1.15
            anchors.verticalCenter: parent.verticalCenter
            text: day.today ? qsTr("Today")
                            : new Date(day.date + "T12:00:00").toLocaleDateString(Qt.locale(), "ddd")
            font.pixelSize: Theme.fontSizeExtraSmall
            color: day.today ? Theme.highlightColor : Theme.primaryColor
            truncationMode: TruncationMode.Fade
        }

        WeatherIcon {
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.iconSizeSmall
            kind: Wx.condition(row.day.code).kind
            isDay: true
            color: Theme.secondaryColor
        }

        Label {
            width: Theme.itemSizeExtraSmall * 0.82
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignRight
            text: Wx.tempS(day.min, us)
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.secondaryColor
        }

        Item {
            id: track
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - Theme.itemSizeExtraSmall * 3.95 - Theme.iconSizeSmall
                   - Theme.paddingMedium * 5
            height: Theme.paddingSmall

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: Theme.rgba(Theme.primaryColor, 0.12)
            }
            Rectangle {
                x: track.width * (day.min - row.lo) / Math.max(row.hi - row.lo, 1)
                width: Math.max(track.width * (day.max - day.min) / Math.max(row.hi - row.lo, 1),
                                Theme.paddingSmall)
                height: parent.height
                radius: height / 2
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Wx.tempColor(day.min) }
                    GradientStop { position: 1.0; color: Wx.tempColor(day.max) }
                }
            }
            Rectangle {
                visible: day.today
                width: Math.max(2, Theme.pixelRatio * 2)
                height: parent.height * 2.1
                anchors.verticalCenter: parent.verticalCenter
                x: Math.max(0, Math.min(track.width - width,
                     track.width * (row.nowTemp - row.lo) / Math.max(row.hi - row.lo, 1)))
                color: Theme.primaryColor
                opacity: 0.8
            }
        }

        Label {
            width: Theme.itemSizeExtraSmall * 0.82
            anchors.verticalCenter: parent.verticalCenter
            text: Wx.tempS(day.max, us)
            font.pixelSize: Theme.fontSizeExtraSmall
        }

        Label {
            width: Theme.itemSizeExtraSmall * 1.15
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignRight
            text: day.mm > 0 ? Wx.depth(day.mm, us) : "—"
            font.pixelSize: Theme.fontSizeTiny
            color: day.mm > 0 ? Theme.highlightColor : Theme.secondaryColor
        }
    }
}
