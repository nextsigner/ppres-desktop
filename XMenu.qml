import QtQuick 2.0
import Qt.labs.settings 1.0

Item{
    id: r
    width: parent.width
    height: minimalista?app.fs*0.5:app.fs*1.4
    property bool minimalista: menuSettings.minimalista
    property var arrayMenuNames: ['Inicio', 'Buscar', 'Configurar', 'Acerca de']
    Settings{
        id: menuSettings
        fileName: pws+'/'+app.moduleName+'/'+app.moduleName+'_xmenu'
        property bool minimalista: false
    }
    MouseArea{
        anchors.fill: r
        onDoubleClicked: menuSettings.minimalista=!menuSettings.minimalista
    }
    Row{
        visible: r.minimalista
        anchors.centerIn: parent
        spacing: app.fs
        Repeater{
            model: r.arrayMenuNames.length
            Rectangle{
                width: app.fs*0.5
                height: width
                radius: width*0.5
                opacity: app.mod===index?1.0:0.5
                MouseArea{
                    width: parent.width*2
                    height: width
                    anchors.centerIn: parent
                    onClicked: {
                        app.mod=index
                        apps.setValue("umod", index)
                        //apps.cMod=index
                    }
                }
            }
        }
    }
    Row{
        visible: !r.minimalista
        spacing: app.fs*0.5
        anchors.left: parent.left
        anchors.leftMargin: app.fs*0.5
        Repeater{
            model: r.arrayMenuNames
            BotonUX{
                text: modelData
                height: app.fs*2
                fontColor: app.mod===index?app.c1:app.c2
                bg.color: app.mod===index?app.c2:app.c1
                glow.radius:app.mod===index?2:6
                onClicked: {
                    app.mod=index
                }
            }
        }
    }
}
