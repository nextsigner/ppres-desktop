import QtQuick 2.0

Rectangle{
    anchors.centerIn: parent
    width: parent.width*0.5
    height: 300
    color: "pink"
    border.width: 10
    border.color: "yellow"
    radius: 10
    MouseArea{
        anchors.fill: parent
        onClicked: iniciarApp()
    }
    XTablaAlumnos{}
}
