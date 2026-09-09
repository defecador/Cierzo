import QtQuick 2.6
import Sailfish.Silica 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: col.height + Theme.paddingLarge * 2

        Column {
            id: col
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: qsTr("Cierzo")
                description: qsTr("Surface observation and forecast")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin * 2
                text: qsTr("Named after the cold north-westerly that funnels down the Ebro valley.")
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
            }

            SectionHeader { text: qsTr("On sources") }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin * 2
                text: qsTr("eltiempo.es publishes no developer interface, so no app can read it "
                         + "directly. Its Spanish forecasts and every one of its weather warnings "
                         + "come from AEMET, the Spanish state meteorological agency, which does "
                         + "publish its data — but only for Spain.")
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
            }
            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin * 2
                text: qsTr("Cierzo therefore reads Open-Meteo, which serves the national services' "
                         + "own models worldwide and needs no account. Settings lets you name the "
                         + "service you want to trust — ECMWF, Deutscher Wetterdienst, "
                         + "Météo-France, MET Norway, the UK Met Office or NOAA — and the forecast "
                         + "page always prints which one produced the figures on it.")
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
            }

            SectionHeader { text: qsTr("On the figures") }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin * 2
                text: qsTr("Dew point is derived from temperature and humidity by the Magnus "
                         + "formula. Cloud cover is reported in oktas, pressure tendency over the "
                         + "three hours a station report uses, and wind strength on the Beaufort "
                         + "scale. The compass barb points the way the air is going; the figures "
                         + "beside it name the direction it comes from, as a forecast does.")
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin * 2
                text: qsTr("Readings are stored on the phone, so the last one you fetched is still "
                         + "there with no signal — marked with the time it was taken.")
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
                bottomPadding: Theme.paddingLarge
            }
        }
        VerticalScrollDecorator { }
    }
}
