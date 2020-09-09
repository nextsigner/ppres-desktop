import QtQuick 2.0

Rectangle {
    id: r
    height:txtData.contentHeight+app.fs*2
    clip: true
    anchors.verticalCenter: parent.verticalCenter
    border.width: 2
    property bool selected: false
    property string text: '?'

    UText{
        id: txtData
        text: r.text
        width: r.width-app.fs
        wrapMode: Text.WordWrap
        anchors.centerIn: parent
        color: r.selected?app.c1:app.c2
        horizontalAlignment: Text.AlignHCenter
    }
}
