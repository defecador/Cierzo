import QtQuick 2.6
import Sailfish.Silica 1.0
import "../components"
import "../js/wx.js" as Wx

Page {
    id: page
    allowedOrientations: Orientation.All

    property int dayIndex: 0
    readonly property var day: (app.wx && dayIndex < app.wx.days.length) ? app.wx.days[dayIndex] : null

    /* the hourly series only reaches two days out; beyond that a day has
       its summary and nothing finer, and the page says so rather than
       showing an empty chart */
    readonly property var hours: {
        if (!app.wx || !day) return []
        var out = []
        for (var i = 0; i < app.wx.hours.length; i++)
            if (app.wx.hours[i].date === day.date) out.push(app.wx.hours[i])
        return out
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: col.height + Theme.paddingLarge * 2

        Column {
            id: col
            width: parent.width

            PageHeader {
                title: day ? new Date(day.date + "T12:00:00")
                             .toLocaleDateString(Qt.locale(), "dddd") : ""
                description: day ? new Date(day.date + "T12:00:00")
                                   .toLocaleDateString(Qt.locale(), Locale.LongFormat) : ""
            }

            Item {
                width: parent.width
                height: icon.height + Theme.paddingLarge

                WeatherIcon {
                    id: icon
                    anchors { left: parent.left; leftMargin: Theme.horizontalPageMargin }
                    width: Theme.iconSizeLarge
                    kind: page.day ? Wx.condition(page.day.code).kind : "cloud"
                    color: Theme.highlightColor
                }
                Column {
                    anchors {
                        left: icon.right; leftMargin: Theme.paddingLarge
                        right: parent.right; rightMargin: Theme.horizontalPageMargin
                        verticalCenter: icon.verticalCenter
                    }
                    Label {
                        width: parent.width
                        text: day ? Wx.condition(day.code).label : ""
                        font.pixelSize: Theme.fontSizeMedium
                        wrapMode: Text.WordWrap
                    }
                    Label {
                        text: day ? Wx.tempS(day.min, app.us) + " to " + Wx.tempS(day.max, app.us) : ""
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.secondaryColor
                    }
                }
            }

            DetailItem {
                label: qsTr("Precipitation")
                value: day ? (day.mm > 0 ? Wx.depth(day.mm, app.us) : qsTr("none expected"))
                           + (day.pop > 0 ? " · " + day.pop + "% " + qsTr("chance") : "") : ""
            }
            DetailItem {
                label: qsTr("Strongest wind")
                value: day && day.gust !== null ? Wx.speed(day.gust, app.us)
                       + " · " + qsTr("Beaufort %1").arg(Wx.beaufort(day.gust).force) : "—"
            }
            DetailItem {
                label: qsTr("UV index")
                value: day && day.uv !== null ? day.uv.toFixed(1) + " · " + Wx.uvName(day.uv) : "—"
            }
            DetailItem {
                label: qsTr("Sun")
                value: day ? Wx.clockOf(day.sunrise) + " ↑   " + Wx.clockOf(day.sunset) + " ↓" : ""
            }

            SectionHeader { text: qsTr("Hour by hour") }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin * 2
                visible: page.hours.length === 0
                text: qsTr("The hourly series reaches two days ahead. This day has a daily summary only.")
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
            }

            Repeater {
                model: page.hours
                delegate: Item {
                    width: col.width
                    height: Theme.itemSizeExtraSmall

                    Row {
                        anchors {
                            left: parent.left; leftMargin: Theme.horizontalPageMargin
                            right: parent.right; rightMargin: Theme.horizontalPageMargin
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: Theme.paddingMedium

                        Label {
                            width: Theme.itemSizeExtraSmall * 0.9
                            anchors.verticalCenter: parent.verticalCenter
                            text: ("0" + modelData.hour).slice(-2) + ":00"
                            font.pixelSize: Theme.fontSizeExtraSmall
                            color: Theme.secondaryColor
                        }
                        WeatherIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            width: Theme.iconSizeSmall
                            kind: Wx.condition(modelData.code).kind
                            isDay: modelData.day === 1
                            color: Theme.secondaryColor
                        }
                        Label {
                            width: Theme.itemSizeExtraSmall * 0.8
                            anchors.verticalCenter: parent.verticalCenter
                            text: Wx.tempS(modelData.t, app.us)
                            font.pixelSize: Theme.fontSizeSmall
                            color: Wx.tempColor(modelData.t)
                        }
                        Label {
                            width: Theme.itemSizeExtraSmall * 0.9
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.pop > 0 ? modelData.pop + "%" : "—"
                            font.pixelSize: Theme.fontSizeExtraSmall
                            color: modelData.pop >= 40 ? Theme.highlightColor : Theme.secondaryColor
                        }
                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.wind !== null
                                  ? Wx.compass(modelData.dir) + " " + Wx.speed(modelData.wind, app.us) : ""
                            font.pixelSize: Theme.fontSizeExtraSmall
                            color: Theme.secondaryColor
                        }
                    }
                }
            }
        }
        VerticalScrollDecorator { }
    }
}
