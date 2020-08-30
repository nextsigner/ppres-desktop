import QtQuick 2.0

Rectangle {
    id: r
    anchors.fill: parent
    color: app.c1
    enabled: false
    onVisibleChanged: {
        if(visible){
            tiAdmin.textInput.focus=true
        }
    }
    Column{
        spacing: app.fs*0.5
        anchors.centerIn: parent
        UText{
            text:  '<b>Acceder</b>'
            font.pixelSize: app.fs*2
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Column{
            spacing: app.fs
            Rectangle{
                width: app.fs*12
                height: width
                radius: width*0.5
                clip: true
                anchors.horizontalCenter: parent.horizontalCenter
                Image{
                    width: parent.width*0.7
                    height: width
                    source: './img/admin_icon.png'
                    anchors.centerIn: parent
                }
            }
            Row{
                anchors.right: parent.right
                spacing: app.fs
                UText{
                    text: 'Administrador:'
                    font.pixelSize: app.fs*2
                    anchors.verticalCenter: parent.verticalCenter
                }
                UTextInput{
                    id: tiAdmin
                    label: ''
                    fontSize: app.fs*2
                    width: app.fs*20
                    maximumLength: 12
                    KeyNavigation.tab: tiContrasenia
                    onFocusChanged: {
                        textInput.selectAll()
                    }
                }
            }
            Row{
                anchors.right: parent.right
                spacing: app.fs
                UText{
                    text: 'Contraseña:'
                    font.pixelSize: app.fs*2
                    anchors.verticalCenter: parent.verticalCenter
                }
                UTextInput{
                    id: tiContrasenia
                    textInput.echoMode: TextInput.Password
                    label: ''
                    fontSize: app.fs*2
                    width: app.fs*20
                    maximumLength: 12
                    KeyNavigation.tab: botLogin
                    onFocusChanged: {
                        textInput.selectAll()
                    }
                }
            }
        }
        BotonUX{
            id: botLogin
            text: 'Ingresar'
            height: app.fs*4
            fontSize: app.fs*2
            anchors.right: parent.right
            Keys.onReturnPressed: login()
            onClicked: login()
            UnikFocus{}
        }
        Item {
            width: 1
            height: app.fs
        }
        UText{
            id: status
            font.pixelSize: app.fs*2
        }
    }
    Timer{
        running: true
        repeat: false
        interval: 2000
        onTriggered: {
            r.enabled=true
            tiAdmin.focus=true
            tiAdmin.textInput.focus=true
        }
    }
    Component.onCompleted: {
        tiAdmin.textInput.focus=true
        /*let key=unik.encData('mario|mep', 'axf5d', 'adgd5a')
        if(!unik.folderExist('./admins')){
            unik.mkdir('admins')
        }
        unik.setFile('./admins/pass1.key', key)*/
    }
    function login(){
        let eu=false
        let nf=-1
        for(let i=1;i<100;i++){
            if(!unik.fileExist('./admins/pass'+i+'.key')){
                //continue
            }else{
                let ad=''+unik.decData(unik.getFile('./admins/pass'+i+'.key'), 'axf5d', 'adgd5a')
                let mad=ad.split('|')
                if(mad.length===2){
                    if(tiAdmin.text===''+mad[0]){
                        nf=i
                        eu=true
                        break
                    }
                }
            }
        }
        if(!eu){
            status.text='Administrador o contraseña incorrecta.'
            return
        }
        let claveDec=unik.decData(unik.getFile('./admins/pass'+nf+'.key'), 'axf5d', 'adgd5a')
        let clave=tiAdmin.text+'|'+tiContrasenia.text
        if(clave===claveDec){
            app.cAdmin=tiAdmin.text
            r.visible=false
        }else{
            status.text='Administrador o contraseña incorrecta.'
            tiAdmin.text=''
            tiContrasenia.text=''
            tiAdmin.focus=true
        }
    }
}
