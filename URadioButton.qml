import QtQuick 2.7
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4


Item {
    id: r
    width: labelText.contentWidth+app.fs*3
    height: r.d
    property int d: app.fs
    property int fontSize: app.fs
    property alias checked: urb.checked
    property alias checkable: urb.checkable
    property string text: 'URadioButton'
    property color fontColor: app.c2
    RadioButton {
        id: urb
        contentItem: Text {
            id: labelText
            text: r.text
            font.pixelSize: r.fontSize
            opacity: enabled ? 1.0 : 0.3
            color: r.fontColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            anchors.left: parent.left
            anchors.leftMargin: r.d+app.fs*0.5
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 0-r.d*0.3
        }
        indicator: Rectangle {
            implicitWidth: r.d
            implicitHeight: r.d
            radius: r.d*0.5
            border.color: r.activeFocus ? app.c3 : app.c4
            border.width: unikSettings.borderWidth
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 0-r.d*0.3
            color: app.c2
            Rectangle {
                anchors.fill: parent
                visible: r.checked
                color: app.c1
                radius: r.d*0.5
                anchors.margins: app.fs*0.25
            }
        }
    }
}
