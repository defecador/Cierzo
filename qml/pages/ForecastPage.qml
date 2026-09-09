import QtQuick 2.6
import Sailfish.Silica 1.0
import "../components"
import "../js/wx.js" as Wx

Page {
    id: page
    allowedOrientations: Orientation.All

    SilicaFlickable {
        id: view
        anchors.fill: parent
        contentHeight: body.height + Theme.paddingLarge * 2

        PullDownMenu {
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.animatorPush(Qt.resolvedUrl("SettingsPage.qml"))
            }
            MenuItem {
                text: qsTr("Places")
                onClicked: pageStack.animatorPush(Qt.resolvedUrl("PlacesPage.qml"))
            }
            MenuItem {
                text: app.loading ? qsTr("Reading…") : qsTr("Refresh")
                enabled: !app.loading && app.place !== null
                onClicked: app.refresh()
            }
        }

        ViewPlaceholder {
            enabled: !app.place
            text: qsTr("No place yet")
            hintText: qsTr("Pull down to add one")
        }

        ViewPlaceholder {
            enabled: app.place && !app.wx && app.error !== ""
            text: app.error
            hintText: qsTr("Pull down to try again")
        }

        BusyIndicator {
            anchors.centerIn: parent
            size: BusyIndicatorSize.Large
            running: app.loading && !app.wx
        }

        Column {
            id: body
            width: parent.width
            visible: app.wx !== null

            PageHeader {
                title: app.place ? app.place.name : ""
                description: app.place ? app.place.sub : ""
            }

            /* ---------------- the reading now ---------------- */
            Item {
                width: parent.width
                height: Math.max(figure.height, aside.height) + Theme.paddingLarge

                Label {
                    id: figure
                    anchors { left: parent.left; leftMargin: Theme.horizontalPageMargin; top: parent.top }
                    text: app.wx ? Wx.temp(app.wx.t, app.us) + "°" : ""
                    font.pixelSize: Theme.fontSizeHuge * 1.9
                    font.weight: Font.Light
                    color: app.wx ? Wx.tempColor(app.wx.t) : Theme.primaryColor
                }

                Column {
                    id: aside
                    anchors {
                        left: figure.right; leftMargin: Theme.paddingMedium
                        right: parent.right; rightMargin: Theme.horizontalPageMargin
                        top: parent.top; topMargin: Theme.paddingMedium
                    }
                    spacing: Theme.paddingSmall / 2

                    WeatherIcon {
                        width: Theme.iconSizeMedium
                        kind: app.wx ? app.wx.kind : "cloud"
                        isDay: app.wx ? app.wx.isDay : true
                        color: Theme.highlightColor
                    }
                    Label {
                        width: parent.width
                        text: app.wx ? app.wx.label : ""
                        font.pixelSize: Theme.fontSizeMedium
                        wrapMode: Text.WordWrap
                    }
                    Label {
                        width: parent.width
                        text: app.wx ? qsTr("Feels like %1").arg(Wx.tempS(app.wx.feels, app.us)) : ""
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: Theme.secondaryColor
                    }
                    Label {
                        width: parent.width
                        visible: app.wx && app.wx.rain1h > 0
                        text: app.wx ? qsTr("%1 in the last hour").arg(Wx.depth(app.wx.rain1h, app.us)) : ""
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: Theme.highlightColor
                    }
                }
            }

            /* ---------------- wind ---------------- */
            Item {
                width: parent.width
                height: rose.height + Theme.paddingLarge

                WindRose {
                    id: rose
                    anchors { left: parent.left; leftMargin: Theme.horizontalPageMargin }
                    width: Theme.itemSizeMedium
                    direction: app.wx ? app.wx.windDir : 0
                    speed: app.wx ? app.wx.windSpeed : 0
                }
                Column {
                    anchors {
                        left: rose.right; leftMargin: Theme.paddingLarge
                        right: parent.right; rightMargin: Theme.horizontalPageMargin
                        verticalCenter: rose.verticalCenter
                    }
                    Label {
                        text: app.wx ? Wx.speed(app.wx.windSpeed, app.us)
                                     + "  " + qsTr("gusting") + " " + Wx.speed(app.wx.gust, app.us) : ""
                        font.pixelSize: Theme.fontSizeSmall
                    }
                    Label {
                        text: app.wx ? qsTr("from %1  %2°").arg(Wx.compass(app.wx.windDir))
                                                           .arg(Math.round(app.wx.windDir)) : ""
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: Theme.secondaryColor
                    }
                    Label {
                        text: app.wx ? qsTr("Beaufort %1 · %2").arg(app.wx.force).arg(app.wx.forceName) : ""
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: Theme.secondaryColor
                    }
                }
            }

            /* ---------------- the rest of the observation ---------------- */
            Grid {
                id: readings
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin * 2
                columns: width > Theme.itemSizeHuge * 3 ? 3 : 2
                rowSpacing: Theme.paddingLarge
                columnSpacing: Theme.paddingMedium
                readonly property real cell:
                    (width - columnSpacing * (columns - 1)) / columns

                Reading {
                    width: readings.cell
                    label: qsTr("Pressure")
                    value: app.wx ? Wx.pressure(app.wx.pressure, app.us) : ""
                    note: app.wx ? app.wx.tendency.text : ""
                }
                Reading {
                    width: readings.cell
                    label: qsTr("Humidity")
                    value: app.wx ? Math.round(app.wx.rh) + "%" : ""
                    note: app.wx ? qsTr("dew point %1").arg(Wx.tempS(app.wx.dew, app.us)) : ""
                }
                Reading {
                    width: readings.cell
                    label: qsTr("Cloud")
                    value: app.wx ? Math.round(app.wx.cloud) + "%" : ""
                    note: app.wx ? Wx.oktas(app.wx.cloud) + "/8 " + qsTr("oktas") + " · "
                                 + Wx.oktasName(Wx.oktas(app.wx.cloud)) : ""
                }
                Reading {
                    width: readings.cell
                    label: qsTr("Visibility")
                    value: app.wx ? Wx.distance(app.wx.visibility, app.us) : ""
                    note: app.wx && app.wx.visibility === null ? qsTr("not in this model")
                        : app.wx ? (app.wx.visibility < 1000 ? qsTr("fog limits")
                                 : app.wx.visibility < 5000 ? qsTr("haze")
                                 : app.wx.visibility >= 20000 ? qsTr("exceptional") : qsTr("clear")) : ""
                }
                Reading {
                    width: readings.cell
                    label: qsTr("UV index")
                    value: app.wx ? (app.wx.uv === null ? "—" : app.wx.uv.toFixed(1)) : ""
                    note: app.wx ? (app.wx.uv === null
                            ? (app.wx.uvMax === null ? qsTr("not in this model")
                               : qsTr("peak %1 today").arg(app.wx.uvMax.toFixed(1)))
                            : Wx.uvName(app.wx.uv)
                              + (app.wx.uvMax !== null
                                 ? " · " + qsTr("peak %1").arg(app.wx.uvMax.toFixed(1)) : "")) : ""
                }
                Reading {
                    width: readings.cell
                    label: qsTr("Daylight")
                    value: app.wx ? app.wx.daylight : ""
                    note: app.wx ? app.wx.sunrise + " ↑  " + app.wx.sunset + " ↓" : ""
                }
            }

            /* ---------------- the hours ahead ---------------- */
            SectionHeader { text: qsTr("Next 48 hours") }

            SilicaFlickable {
                width: parent.width
                height: Theme.itemSizeHuge * 1.55
                contentWidth: graph.width
                contentHeight: height
                flickableDirection: Flickable.HorizontalFlick
                clip: true

                HourlyChart {
                    id: graph
                    height: parent.height
                    width: Math.max(page.width, (app.wx ? app.wx.hours.length : 1)
                                    * Theme.itemSizeExtraSmall * 0.52)
                    hours: app.wx ? app.wx.hours : []
                    us: app.us
                }
            }
            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin * 2
                text: qsTr("Hour, local time · bars show the chance of precipitation · swipe the chart")
                font.pixelSize: Theme.fontSizeTiny
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
            }

            /* ---------------- the week ---------------- */
            SectionHeader { text: qsTr("Seven days") }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin * 2
                text: app.wx ? qsTr("One shared scale, %1 to %2")
                               .arg(Wx.tempS(week.lo, app.us)).arg(Wx.tempS(week.hi, app.us)) : ""
                font.pixelSize: Theme.fontSizeTiny
                color: Theme.secondaryColor
                bottomPadding: Theme.paddingSmall
            }

            Column {
                id: week
                width: parent.width

                /* the week's own extremes, so every bar is read against the same span */
                property real lo: {
                    if (!app.wx || app.wx.days.length === 0) return 0
                    var a = app.wx.days[0].min
                    for (var i = 1; i < app.wx.days.length; i++) a = Math.min(a, app.wx.days[i].min)
                    return a
                }
                property real hi: {
                    if (!app.wx || app.wx.days.length === 0) return 1
                    var b = app.wx.days[0].max
                    for (var i = 1; i < app.wx.days.length; i++) b = Math.max(b, app.wx.days[i].max)
                    return b
                }

                Repeater {
                    model: app.wx ? app.wx.days : 0
                    delegate: DayRow {
                        day: modelData
                        lo: week.lo
                        hi: week.hi
                        us: app.us
                        nowTemp: app.wx ? app.wx.t : 0
                        onClicked: pageStack.animatorPush(Qt.resolvedUrl("DayPage.qml"),
                                                          { dayIndex: index })
                    }
                }
            }

            /* ---------------- provenance ---------------- */
            Item { width: 1; height: Theme.paddingLarge }

            Column {
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin * 2
                spacing: 2

                Label {
                    width: parent.width
                    text: app.wx ? qsTr("%1 — %2").arg(Wx.modelName(app.model)).arg(Wx.modelBy(app.model)) : ""
                    font.pixelSize: Theme.fontSizeTiny
                    color: Theme.secondaryColor
                    wrapMode: Text.WordWrap
                }
                Label {
                    width: parent.width
                    text: app.wx ? qsTr("Observed %1 %2 · %3 m a.s.l. · served by Open-Meteo")
                                   .arg(app.wx.observed).arg(app.wx.tzAbbr)
                                   .arg(Math.round(app.wx.elevation)) : ""
                    font.pixelSize: Theme.fontSizeTiny
                    color: Theme.secondaryColor
                    wrapMode: Text.WordWrap
                }
                Label {
                    width: parent.width
                    visible: app.cachedAt !== ""
                    text: qsTr("Stored reading from %1 — no network").arg(app.cachedAt)
                    font.pixelSize: Theme.fontSizeTiny
                    color: Theme.highlightColor
                    wrapMode: Text.WordWrap
                }
            }
        }

        VerticalScrollDecorator { }
    }
}
