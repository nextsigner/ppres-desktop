import QtQuick 2.0

Item {
    id: r
    anchors.fill: parent
    onVisibleChanged: {
        if(visible){
            xApp.focus=visible
        }
    }
    Column{
        anchors.centerIn: parent
        spacing: app.fs
        Image {
            id: logo
            source: "file:./img/escudo.png"
            width: app.fs*20
            height: width
        }
        Column{
            anchors.horizontalCenter: parent.horizontalCenter
            UText{
                text: '<b>Taekwondo</b>'
                font.pixelSize: app.fs*2
                anchors.horizontalCenter: parent.horizontalCenter
            }
            UText{
                text: 'Aplicación para la gestión y control\nde folios de alumnos de Taekwondo.'
                font.pixelSize: app.fs
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        UText{
            id: labelCountProds
            text: '<b>Cantidad de Alumnos Registrados: </b> Contando...'
            font.pixelSize: app.fs
        }       
    }
    Timer{
        running: r.visible
        repeat: true
        interval: 1500
        onTriggered: actualizar()
    }
    function actualizar(){
        let sql = 'select * from '+app.tableName2
        let rows = unik.getSqlData(sql)
        labelCountProds.text='<b>Cantidad de Alumnos Registrados: </b>'+rows.length
        sql = 'select * from '+app.tableName1
        rows = unik.getSqlData(sql)
        labelCountProds.text+='<br /><b>Cantidad de Certificados Registrados: </b>'+rows.length
    }
}
