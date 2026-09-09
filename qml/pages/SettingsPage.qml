import QtQuick 2.6
import Sailfish.Silica 1.0
import "../js/wx.js" as Wx

Page {
    id: page
    allowedOrientations: Orientation.All

    function modelIndex() {
        for (var i = 0; i < Wx.MODELS.length; i++)
            if (Wx.MODELS[i].id === app.model) return i
        return 0
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: col.height + Theme.paddingLarge * 2

        Column {
            id: col
            width: parent.width

            PageHeader { title: qsTr("Settings") }

            TextSwitch {
                checked: app.us
                text: qsTr("Fahrenheit, miles, inches")
                description: qsTr("Off: Celsius, km/h, hPa, millimetres")
                onClicked: { app.us = checked; app.persist() }
            }

            SectionHeader { text: qsTr("Where the forecast comes from") }

            ComboBox {
                id: picker
                width: parent.width
                label: qsTr("Model")
                currentIndex: page.modelIndex()
                description: Wx.modelBy(app.model)

                menu: ContextMenu {
                    Repeater {
                        model: Wx.MODELS
                        MenuItem { text: modelData.name }
                    }
                }

                onCurrentIndexChanged: {
                    var id = Wx.MODELS[currentIndex].id
                    if (id === app.model) return
                    app.model = id
                    app.persist()
                    app.refresh()
                }
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin * 2
                text: qsTr("Each option is one national weather service's own model, delivered through "
                         + "Open-Meteo. “Best available” lets Open-Meteo pick the highest-resolution "
                         + "model covering the place, which changes as you travel.")
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
                topPadding: Theme.paddingSmall
                bottomPadding: Theme.paddingLarge
            }

            ValueButton {
                label: qsTr("About")
                value: qsTr("Cierzo and its sources")
                onClicked: pageStack.animatorPush(Qt.resolvedUrl("AboutPage.qml"))
            }
        }
        VerticalScrollDecorator { }
    }
}
