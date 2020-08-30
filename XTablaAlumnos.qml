import QtQuick 2.0
import QtQuick.Controls 2.0

Rectangle{
    id: r
    anchors.centerIn: parent
    width: parent.width*0.5
    height: 300
    color: "pink"
    border.width: 10
    border.color: "yellow"
    radius: 10
    ListView{
        id: lv
        anchors.fill: r
        model: lm
        delegate: delegado
        spacing: 10
        ListModel{
            id:lm
            ListElement{folio:"asssd"; nombre: "asaaaaa"}
            ListElement{folio:"2asssd"; nombre: "asaaaaa"}
            ListElement{folio:"3asssd"; nombre: "asaaaaa"}
            ListElement{folio:"4asssd"; nombre: "asaaaaa"}
            ListElement{folio:"5asssd"; nombre: "asaaaaa"}
        }
        Component{
            id: delegado
            Rectangle{
                width: lv.width-10
                height: cb.height+6
                border.color: 'red'
                border.width: 2
                Row{
                    anchors.centerIn: parent
                    CheckBox{
                        id: cb
                        Rectangle{
                            width: parent.width-10
                            height: parent.height-10
                            color: 'transparent'
                            border.width: 2
                            border.color: 'blue'
                            anchors.centerIn: parent
                        }
                    }
                    Text {
                        text: 'Folio: '+folio+' Nombre: '+nombre
                        font.pixelSize: 20
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}
