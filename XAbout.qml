import QtQuick 2.0

Item {
    id: r
    anchors.fill: parent
    Column{
        anchors.centerIn: parent
        spacing: app.fs
        UText{
            text: '<b>Acerca de '+app.moduleName+' </b>'
            font.pixelSize: app.fs*2
            anchors.horizontalCenter: parent.horizontalCenter
        }
        UText{
            textFormat: Text.RichText
            width: r.width*0.6
            text: 'Esta aplicación fue desarrollada por <b>pizarromario@gmail.com</b> en Septiembre de 2020 utilizando la herramienta de código libre <b>Unik Qml Engine versión 4.19.4</b> bajo las licencias GPL, LGPL y LGPL2<br /><br />Unik es una aplicación Open Source creada con Qt Open Source versión 5.12.3 bajo las licencias GPL, LGPL y LGPL2.<br /><br />Para más información sobre Unik ir a <a href="https://github.com/nextsigner/unik">https://github.com/nextsigner/unik</a><br /><br />Para más información sobre el Qt Project ir a <a href="https://qt.io/">https://qt.io/</a>'
            font.pixelSize: app.fs
            wrapMode: Text.WordWrap
            anchors.horizontalCenter: parent.horizontalCenter
            onLinkActivated: {
                Qt.openUrlExternally(link)
            }
        }
    }
}
