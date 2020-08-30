import QtQuick 2.0
import Qt.labs.platform 1.1
import Qt.labs.settings 1.0

Item {
    id: r
    anchors.fill: parent
    onVisibleChanged: {
        if(visible){
            xApp.focus=visible
        }
    }
    Settings{
        id: inicioSettings
        fileName: pws+'/'+app.moduleName+'/'+app.moduleName+'_xconfig'
        property string uFolder
        property string uFolderSelect
    }
    Column{
        anchors.centerIn: parent
        spacing: app.fs
        UText{
            text: '<b>Configurar </b>'
            font.pixelSize: app.fs*2
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Row{
            spacing: app.fs
            UText{
                text: 'Configurar Administradores'
                anchors.verticalCenter: parent.verticalCenter
            }
            BotonUX{
                text: 'Administrar Contraseñas'
                onClicked: {
                    xSetAdmins.visible=true
                }
            }
            BotonUX{
                text: 'Eventos de Administradores'
                onClicked: {
                    xListViewEvents.visible=true
                }
            }
        }
        Item{width: 1;height: app.fs*2}
        UText{
            text: '<b>Base de Datos: </b>'+apps.bdFileName
            font.pixelSize: app.fs
        }
        Row{
            spacing: app.fs
            BotonUX{
                text: 'Abrir Base de Datos'
                onClicked: {
                    fileDialog.mod=0
                    fileDialog.visible=true
                }
            }
        }
        Row{
            spacing: app.fs
            BotonUX{
                text: 'Hacer Copia de Seguridad / Exportar'
                onClicked: {
                    folderDialog.visible=true
                }
            }
            BotonUX{
                text: 'Seleccionar Base de Datos / Importar'
                onClicked: {
                    fileDialog.mod=1
                    fileDialog.visible=true
                }
            }
        }
        BotonUX{
            id: botActualiza
            text:'Actualizar Aplicación'
            height: app.fs*2
            onClicked: {
                    let cmd='-git=https://github.com/nextsigner/ppres-desktop.git'
                    unik.setUnikStartSettings(cmd)
                    if(Qt.platform.os==='linux'){
                        unik.restartApp(cmd)
                    }else{
                        unik.restartApp()
                    }

            }
        }
        UText{
            id: backUpStatus
            font.pixelSize: app.fs
        }
        }
    XSetAdmins{id: xSetAdmins}
    XListViewEvents{
        id: xListViewEvents;visible:false
        anchors.fill: parent
    }

    FileDialog{
        id: fileDialog
        title: 'Elegir un archivo SQLITE'
        nameFilters: ["*.sqlite"]
        fileMode: FileDialog.OpenFile
        folder: inicioSettings.uFolderSelect!==''?inicioSettings.uFolder:unik.getPath(3)
        acceptLabel: 'Seleccionar Base de Datos'
        property int mod:0
        onAccepted: {
            var bdSelected=""
            if(mod===0){
                unik.sqliteClose()
                let fn0=(''+file).replace('file:///', '').split('/')
                let fn1=fn0[fn0.length-1]
                //uLogView.showLog('Sqlite: '+fn1)
                let fs=(''+files).replace('file:///', '')
                bdSelected=(""+fs).replace(/\//g, "\\\\")
                unik.sqliteInit(bdSelected)
                let sql='SELECT count(*) FROM sqlite_master WHERE type = \'table\' AND name != \'sqlite_sequence\';'
                let rows=unik.sqlQuery(sql)
                if(rows.length<=0){
                    unik.speak('Error. No se ha podido conectar a la base de datos que se intenta abrir.')
                }else{
                    unik.speak('Archivo abierto. Base de datos conextada con éxito.')
                    apps.bdFileName=bdSelected
                }

            }
            if(mod===1){
                //uLogView.showLog('Sqlite: '+file)
                let fn0=(''+file).replace('file:///', '').split('/')
                let fn1=fn0[fn0.length-1]
                if(fn1===apps.bdFileName){
                    unik.speak('Error. En este momento ya se está utilizando un archivo con este mismo nombre.')
                }else{
                    //uLogView.showLog('Sqlite: '+fn1)
                    let fs=(''+files).replace('file:///', '')
                    let folderCurrentBds=""+pws+"/taekwondo/bds"
                    let folderBds=""+folder+""
                    let nBd=(""+folderCurrentBds+"/"+fn1).replace(/\//g, "\\\\")

                    bdSelected=(""+fs).replace(/\//g, "\\\\")
                    let cmd='cmd /c copy "'+bdSelected+'" "'+nBd+'"'
                    unik.sqliteClose()
                    xMsgCopiando.mod=2
                    xMsgCopiando.file=fn1
                    xMsgCopiando.visible=true
                    unik.ejecutarLineaDeComandoAparte(cmd)
                    //uLogView.showLog('CMD: '+cmd)
                }
            }
        }
    }
    FolderDialog {
        id: folderDialog
        title: 'Elegir donde hacer la copia'
        currentFolder: inicioSettings.uFolder!==''?inicioSettings.uFolder:unik.getPath(3)
        folder: StandardPaths.standardLocations(StandardPaths.Documents)[0]
        acceptLabel: 'Hacer la copia en esta carpeta'

        onAccepted: {
            inicioSettings.uFolder=folder
            let d=new Date(Date.now())
            let dia=d.getDate()
            let mes=d.getMonth()+1
            let anio=(''+d.getYear()).split('')

            let hora=d.getHours()
            let minuto=d.getMinutes()
            let segundos=d.getSeconds()

            let bdFN='productos_'+dia+'_'+mes+'_'+anio[anio.length-2]+anio[anio.length-1]+'_'+hora+'_'+minuto+'_'+segundos+'.sqlite'

            let fs=(''+folder).replace('file:///', '')
            let folderCurrentBds=""+pws+"/taekwondo/bds"
            let folderBds=""+fs+""
            let currentBd=apps.bdFileName.indexOf('\\')<0?(""+folderCurrentBds+"/"+apps.bdFileName).replace(/\//g, "\\\\"):""+apps.bdFileName

            let bd=(""+folderBds+"/"+bdFN).replace(/\//g, "\\\\")
            let cmd='cmd /c copy "'+currentBd+'" "'+bd+'"'
            //unik.run(cmd)
            xMsgCopiando.mod=1
            xMsgCopiando.file=bdFN
            xMsgCopiando.visible=true
            unik.ejecutarLineaDeComandoAparte(cmd)
            //backUpStatus.text='Archivo '+bdFN+' copiado en la carpeta '+folderBds
            //backUpStatus.text='Copiando archivo '+bdFN+' en la carpeta '+folderBds
            //tCheckBK.file='"'+bd+'"'
            //tCheckBK.v=0
            //tCheckBK.repeat=true
            //tCheckBK.start()
        }
    }
    Rectangle{
        id: xMsgCopiando
        visible: false
        width: r.width*0.6
        height: r.height*0.2+msg.contentHeight
        border.width: 2
        border.color: app.c2
        color: app.c1
        radius: unikSettings.radius
        anchors.centerIn: r
        property string m: 'Copiando'
        property string file
        property int mod: 1
        onVisibleChanged: {
            m='Copiando '+file
            botCerrarXMsgCopiando.visible=false
        }
        Timer{
            running: parent.visible&&!botCerrarXMsgCopiando.visible
            repeat: true
            interval: 800
            onTriggered: parent.m+='.'
        }
        Timer{
            id: tCopiando
            repeat: false
            running: parent.visible
            interval: 7000
            property string file
            onTriggered: {
                if(xMsgCopiando.mod===1){
                    xMsgCopiando.m='La copia de seguridad se ha realizado con éxito.'
                    botCerrarXMsgCopiando.visible=true
                }else{
                    let folderBds=""+pws+"/taekwondo/bds"
                    let bd=""+folderBds+"/"+xMsgCopiando.file
                    if(!unik.fileExist(bd)){
                        unik.speak('Error. El archivo seleccionado no se ha copiado correctamente.')
                    }else{
                        //uLogView.showLog('NBD: '+xMsgCopiando.file)
                        unik.sqliteInit(bd)
                        let sql='SELECT count(*) FROM sqlite_master WHERE type = \'table\' AND name != \'sqlite_sequence\';'
                        let rows=unik.sqlQuery(sql)
                        if(rows.length<=0){
                            unik.speak('Error. No se ha podido conectar a la base de datos importada.')
                        }else{
                            unik.speak('Base de datos importada con éxito.')
                            xMsgCopiando.visible=false
                            apps.bdFileName=xMsgCopiando.file
                        }

                    }
                }
            }
        }
        Column{
            spacing: app.fs
            width: parent.width-app.fs*2
            anchors.centerIn: parent
            UText{
                text: xMsgCopiando.mod===1?'<b>Creando copia de seguridad</b>':'<b>Conectando Base de Datos seleccionada</b>'
                width: xMsgCopiando.width-app.fs*2
                height: contentHeight
                wrapMode: Text.WordWrap
                anchors.horizontalCenter: parent.horizontalCenter
            }
            UText{
                id: msg
                text: xMsgCopiando.m
                width: xMsgCopiando.width-app.fs*2
                height: contentHeight
                wrapMode: Text.WordWrap
            }
            BotonUX{
                id: botCerrarXMsgCopiando
                text: 'Cerrar'
                visible: false
                anchors.right: parent.right
                onClicked: xMsgCopiando.visible=false
            }
        }
    }
    Timer{
        id: tCheckBK
        repeat: true
        running: false
        interval: 3000
        property string file
        property int v: 0
        onTriggered: {
            let fn=file//.replace(/\\\\\\\\/g, '/')
            uLogView.showLog('fn: '+fn)
            if(unik.fileExist(fn)){
                backUpStatus.text='Base de datos copiada correctamente.'
                tCheckBK.repeat=false
                tCheckBK.running=false
                tCheckBK.stop()
            }else{
                backUpStatus.text+='.'
            }
            if(v>30){
                backUpStatus.text='La copia está demorando demasiado.\nEsto significa que algo está funcionando mal.'
            }
            v++
        }
    }


    function actualizar(){
        let sql = 'select * from '+app.tableName1
        let rows = unik.getSqlData(sql)
        //labelCountProds.text='<b>Cantidad de Productos Registrados: </b>'+rows.length
    }
}
