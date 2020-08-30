import QtQuick 2.0
import QtQuick.Controls 2.0
import Qt.labs.folderlistmodel 2.0

Rectangle {
    id: r
    visible: false
    anchors.fill: parent
    color: app.c1
    onVisibleChanged: {
        if(visible )tiNU.focus=true
    }
    Column{
        spacing: app.fs
        anchors.centerIn: r
        Row{
            spacing: app.fs
            BotonUX{
                text: 'Atras'
                onClicked: {
                    r.visible=false
                }
            }
            UText{
                text: 'Configurar Administradores'
                font.pixelSize: app.fs*2
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        Row{
            spacing: app.fs
            UTextInput{
                id: tiNU
                width: app.fs*20
                label: '<b>Nuevo Usuario</b> :'
                KeyNavigation.tab: tiNK
                anchors.verticalCenter: parent.verticalCenter
            }
            UTextInput{
                id: tiNK
                width: app.fs*20
                label: '<b>Nueva Clave</b> :'
                KeyNavigation.tab: botAddNU
                anchors.verticalCenter: parent.verticalCenter
            }
            BotonUX{
                id: botAddNU
                text: 'Agregar Usuario'
                KeyNavigation.tab: tiNU
                onClicked: {
                    let eu=false
                    for(let i=0;i<folderModel.count;i++){
                        if(!unik.fileExist('./admins/'+folderModel.get(i, 'fileName'))){
                            ////uLogView.showLog('NE: ['+i+']')
                            //continue
                        }else{
                            //uLogView.showLog('SE: ['+i+']')
                            let ad=''+unik.decData(unik.getFile('./admins/'+folderModel.get(i, 'fileName')), 'axf5d', 'adgd5a')
                            //uLogView.showLog('ad: ['+ad+']')
                            let mad=ad.split('|')
                            if(mad.length===2){
                                if(tiNU.text===''+mad[0]){
                                    uLogView.text=''
                                    //uLogView.showLog('Ya existe un administrador con ese nombre.')
                                    //uLogView.showLog('Presione la tecla Escape para cerrar este panel de mensajes.')
                                    eu=true
                                    break
                                }
                            }
                        }
                    }
                    if(eu){
                        return
                    }
                    let nnfu=2
                    for(let i2=2;i2<100;i2++){
                        if(!unik.fileExist('./admins/pass'+i2+'.key')){
                            nnfu=i2
                            break
                        }
                    }
                    unik.setFile('./admins/pass'+nnfu+'.key', unik.encData(tiNU.text+'|'+tiNK.text, 'axf5d', 'adgd5a'))
                    tiNU.text=''
                    tiNK.text=''
                }
            }
        }

        ListView {
            id: lvAdmins
            width: r.width*0.6
            height: r.height*0.3
            anchors.horizontalCenter: parent.horizontalCenter
            FolderListModel {
                id: folderModel
                folder: './admins'
                nameFilters: ["*.key"]
            }
            Component {
                id: fileDelegate
                Rectangle{
                    id: rowFile
                    width: r.width
                    height: app.fs*2
                    color: app.c2
                    Row{
                        spacing: app.fs
                        anchors.centerIn: parent
                        UText {
                            id: user
                            text: fileName
                            color: app.c1
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Rectangle{
                            width: 2
                            height: rowFile.height
                            color: app.c1
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Row{
                            anchors.verticalCenter: parent.verticalCenter
                            UText {
                                id: keyLabel
                                text: '<b>Clave</b>: '
                                color: app.c1
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            UText {
                                id: key
                                visible: cbEM.checked
                                color: app.c1
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        UText {
                            id: keyO
                            visible: !cbEM.checked
                            color: app.c1
                            anchors.verticalCenter: parent.verticalCenter
                            Component.onCompleted: {
                                let t=''
                                for(let i=0;i<key.text.length;i++){
                                    t+='*'
                                }
                                keyO.text=t
                            }
                        }
                        Row{
                            anchors.verticalCenter: parent.verticalCenter
                            UText {
                                id: labelShowKey
                                text: '<b>Mostrar Clave</b>: '
                                color: app.c1
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            CheckBox{
                                id: cbEM
                                Rectangle{
                                    width: parent.width*0.8
                                    height: parent.height*0.8
                                    border.width: 2
                                    border.color: app.c1
                                    color: 'transparent'
                                    anchors.centerIn: parent
                                    z: parent.z+1
                                }
                            }
                            BotonUX{
                                text: 'Eliminar'
                                height: parent.height-app.fs*0.2
                                visible: fileName!=='pass1.key'
                                bg.color: app.c1
                                fontColor: app.c2
                                onClicked: {
                                    unik.deleteFile('./admins/'+fileName)
                                }
                            }
                        }
                    }
                    Component.onCompleted: {
                        let ad=unik.decData(unik.getFile('./admins/'+fileName), 'axf5d', 'adgd5a')
                        let mad=ad.split('|')
                        if(mad.length===2){
                            user.text='<b>Usuario: </b>'+mad[0]
                            key.text=''+mad[1]
                        }
                    }
                }
            }
            model: folderModel
            delegate: fileDelegate
        }
    }
}
