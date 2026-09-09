import QtQuick 2.6
import Sailfish.Silica 1.0
import "../components"
import "../js/wx.js" as Wx

CoverBackground {
    id: cover

    Column {
        anchors {
            left: parent.left; right: parent.right
            verticalCenter: parent.verticalCenter
            margins: Theme.paddingLarge
        }
        spacing: Theme.paddingSmall / 2

        Label {
            width: parent.width
            text: app.place ? app.place.name : qsTr("Cierzo")
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.secondaryColor
            truncationMode: TruncationMode.Fade
            horizontalAlignment: Text.AlignHCenter
        }

        WeatherIcon {
            anchors.horizontalCenter: parent.horizontalCenter
            width: Theme.iconSizeMedium
            visible: app.wx !== null
            kind: app.wx ? app.wx.kind : "cloud"
            isDay: app.wx ? app.wx.isDay : true
            color: Theme.highlightColor
        }

        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: app.wx ? Wx.temp(app.wx.t, app.us) + "°" : "··"
            font.pixelSize: Theme.fontSizeExtraLarge
            font.weight: Font.Light
            color: app.wx ? Wx.tempColor(app.wx.t) : Theme.primaryColor
        }

        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            visible: app.wx !== null
            text: app.wx && app.wx.days.length > 0
                  ? Wx.tempS(app.wx.days[0].min, app.us) + " / " + Wx.tempS(app.wx.days[0].max, app.us) : ""
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.secondaryColor
        }

        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: app.wx ? app.wx.observed : (app.loading ? qsTr("reading…") : qsTr("no reading"))
            font.pixelSize: Theme.fontSizeTiny
            color: Theme.secondaryColor
        }
    }

    CoverActionList {
        enabled: app.place !== null
        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: app.refresh()
        }
    }
}
