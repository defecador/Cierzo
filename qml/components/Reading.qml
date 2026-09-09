/* One figure from the observation, with the unit named and a note beneath.
   Every reading on the page is this same object, so they line up. */
import QtQuick 2.6
import Sailfish.Silica 1.0

Column {
    property alias label: caption.text
    property alias value: figure.text
    property alias note: sub.text
    property color valueColor: Theme.primaryColor

    spacing: 0

    Label {
        id: caption
        font.pixelSize: Theme.fontSizeTiny
        font.capitalization: Font.AllUppercase
        font.letterSpacing: Theme.pixelRatio * 0.8
        color: Theme.secondaryColor
        truncationMode: TruncationMode.Fade
        width: parent.width
    }
    Label {
        id: figure
        font.pixelSize: Theme.fontSizeLarge
        color: valueColor
        truncationMode: TruncationMode.Fade
        width: parent.width
    }
    Label {
        id: sub
        font.pixelSize: Theme.fontSizeTiny
        color: Theme.secondaryColor
        wrapMode: Text.WordWrap
        width: parent.width
        visible: text.length > 0
    }
}
