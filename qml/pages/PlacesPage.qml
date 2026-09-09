import QtQuick 2.6
import Sailfish.Silica 1.0
import QtPositioning 5.3
import "../js/wx.js" as Wx

Page {
    id: page
    allowedOrientations: Orientation.All

    property var results: []
    property bool searching: false
    property string message: ""

    function search(q) {
        if (q.trim().length < 2) { results = []; message = ""; return }
        searching = true
        message = ""
        app.fetch(Wx.searchUrl(q.trim()),
                  function (d) {
                      searching = false
                      results = d.results ? d.results : []
                      if (results.length === 0)
                          message = qsTr("Nothing matches “%1”. Try adding the country.").arg(q.trim())
                  },
                  function (msg) { searching = false; results = []; message = msg })
    }

    PositionSource {
        id: gps
        updateInterval: 2000
        active: false
        onPositionChanged: {
            if (!position.latitudeValid || !position.longitudeValid) return
            active = false
            var la = position.coordinate.latitude, lo = position.coordinate.longitude
            page.message = qsTr("Naming the position…")
            app.fetch(Wx.reverseUrl(la, lo),
                      function (d) {
                          page.message = ""
                          var r = (d.results && d.results.length > 0) ? d.results[0] : null
                          app.addPlace(r ? r.name : qsTr("Here"),
                                       r ? [r.admin1, r.country].filter(function (x) { return !!x }).join(", ")
                                         : la.toFixed(3) + ", " + lo.toFixed(3),
                                       la, lo)
                          pageStack.pop()
                      },
                      function () {
                          page.message = ""
                          app.addPlace(qsTr("Here"), la.toFixed(3) + ", " + lo.toFixed(3), la, lo)
                          pageStack.pop()
                      })
        }
    }

    SilicaListView {
        anchors.fill: parent
        model: app.places
        currentIndex: app.placeIndex

        header: Column {
            width: page.width

            PageHeader { title: qsTr("Places") }

            SearchField {
                id: field
                width: parent.width
                placeholderText: qsTr("Search a town or city")
                inputMethodHints: Qt.ImhNoPredictiveText
                EnterKey.enabled: text.length > 1
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: { page.search(text); focus = false }
            }

            BackgroundItem {
                width: parent.width
                height: Theme.itemSizeSmall
                onClicked: { page.message = qsTr("Waiting for a position…"); gps.active = true }

                Row {
                    anchors {
                        left: parent.left; leftMargin: Theme.horizontalPageMargin
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: Theme.paddingMedium
                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        source: "image://theme/icon-m-location"
                    }
                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("Use my position")
                        color: Theme.highlightColor
                    }
                }
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin * 2
                visible: page.message !== ""
                text: page.message
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
                bottomPadding: Theme.paddingMedium
            }

            BusyIndicator {
                anchors.horizontalCenter: parent.horizontalCenter
                running: page.searching
                visible: running
                size: BusyIndicatorSize.Medium
            }

            Column {
                width: parent.width
                visible: page.results.length > 0

                SectionHeader { text: qsTr("Search results") }

                Repeater {
                    model: page.results
                    delegate: BackgroundItem {
                        width: page.width
                        height: Theme.itemSizeSmall
                        onClicked: {
                            app.addPlace(modelData.name,
                                         [modelData.admin1, modelData.country]
                                            .filter(function (x) { return !!x }).join(", "),
                                         modelData.latitude, modelData.longitude)
                            page.results = []
                            pageStack.pop()
                        }
                        Column {
                            anchors {
                                left: parent.left; leftMargin: Theme.horizontalPageMargin
                                right: parent.right; rightMargin: Theme.horizontalPageMargin
                                verticalCenter: parent.verticalCenter
                            }
                            Label {
                                width: parent.width
                                text: modelData.name
                                truncationMode: TruncationMode.Fade
                            }
                            Label {
                                width: parent.width
                                text: [modelData.admin1, modelData.country]
                                      .filter(function (x) { return !!x }).join(", ")
                                      + "  ·  " + modelData.latitude.toFixed(2) + ", "
                                      + modelData.longitude.toFixed(2)
                                font.pixelSize: Theme.fontSizeExtraSmall
                                color: Theme.secondaryColor
                                truncationMode: TruncationMode.Fade
                            }
                        }
                    }
                }

                SectionHeader { text: qsTr("Saved") }
            }
        }

        delegate: ListItem {
            id: item
            width: page.width
            highlighted: down || index === app.placeIndex

            onClicked: { app.selectPlace(index); pageStack.pop() }

            menu: ContextMenu {
                MenuItem {
                    text: qsTr("Remove")
                    onClicked: item.remorseAction(qsTr("Removing"), function () { app.removePlace(index) })
                }
            }

            Column {
                anchors {
                    left: parent.left; leftMargin: Theme.horizontalPageMargin
                    right: parent.right; rightMargin: Theme.horizontalPageMargin
                    verticalCenter: parent.verticalCenter
                }
                Label {
                    width: parent.width
                    text: modelData.name
                    color: index === app.placeIndex ? Theme.highlightColor : Theme.primaryColor
                    truncationMode: TruncationMode.Fade
                }
                Label {
                    width: parent.width
                    text: modelData.sub
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                    truncationMode: TruncationMode.Fade
                }
            }
        }

        ViewPlaceholder {
            enabled: app.places.length === 0 && page.results.length === 0
            text: qsTr("No places saved")
            hintText: qsTr("Search above, or use your position")
        }

        VerticalScrollDecorator { }
    }
}
