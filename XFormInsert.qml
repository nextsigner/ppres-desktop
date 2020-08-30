import QtQuick 2.12
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "func.js" as JS

Item {
    id: r
    anchors.fill: parent
    property int numMod
    property bool modificando: false
    property string cFolioAModificar: ''
    property int pIdAModificar: -1
    property string tableName: ''
    property string uCodInserted: ''
    property var cols: []
    property bool calsVisible: calendario.parent!==r
    property var currentCalFN
    property var currentCalFC
    property var uDateFNSelected
    property var uDate
    property var uMaxDate
    property var uMinDate
    property var dateForOpenFN
    property var dateForOpenFC

    property int cIdAlumno: -1
    property string cNom: ''

    onVisibleChanged: {
        if(visible){
            if(!modificando){
                updateGui()
                if(!colDatosCertificado.visible){
                    tiNombre.focus=true
                }else{
                    tiFolio.focus=true
                }

                //tiNombre.text=''
            }else{
                tiFolio.focus=true
                tiNombre.enabled=false
            }
        }else{
            tiFolio.focus=false
            tiGrado.focus=false
            tiNombre.focus=false
            tiFechaNac.focus=false
        }
    }
    Column{
        id: col1
        spacing: app.fs*0.5
        anchors.centerIn: parent
        UText{
            text:  !r.modificando?'<b>Registro de Certificados</b>':'<b>Modificando Certificado de Alumno</b>'
            font.pixelSize: app.fs*2
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Item{width: 1;height: app.fs*2}

        UTextInput{
            id: tiNombre
            label: 'Nombre: '
            width: r.width*0.5+app.fs
            maximumLength: 50
            //regularExp: RegExpValidator{regExp: /^\d+(\.\d{1,2})?$/ }
            KeyNavigation.tab: itemCalFN
            anchors.horizontalCenter: parent.horizontalCenter
            textInput.onFocusChanged: {
                if(textInput.focus){
                    calendario.parent=r
                    textInput.selectAll()
                }
            }
            textInput.onTextChanged: {
                r.cIdAlumno=-1
                botCC.visible=false
                labelStatus.text=''
            }
            onSeted: {
                r.cIdAlumno=-1
                botCC.visible=false
                loadList()
            }
        }
        XListViewAl{
            id: xListViewAl
            onVisibleChanged: {
                if(visible)botCancel.visible=true
            }
            onIdDesSelected: r.cIdAlumno=-1
            onIdSelected: {
                //uLogView.showLog('ID:' + id+' Nombre: '+nom)
                r.cIdAlumno=id
                r.cNom=nom
                botCC.visible=true
                botCancel.visible=true
            }
        }
        Row{
            spacing: app.fs
            anchors.horizontalCenter: parent.horizontalCenter
            BotonUX{
                id: botCC
                text: 'Crear Certificado'
                height: app.fs*2
                KeyNavigation.tab: botReg
                visible: xListViewAl.listModel.count>0
                onClicked: {
                    if(r.cIdAlumno>=0){
                        tiNombre.text=r.cNom
                        tiNombre.enabled=false
                        xListViewAl.visible=false
                        colDatosCertificado.visible=true
                        tiFolio.focus=true
                        botCC.visible=false
                        botCancel.visible=true
                    }
                }
                UnikFocus{}
            }
        }
        Column{
            id: colDatosCertificado
            spacing: app.fs*0.5
            visible: false
            anchors.horizontalCenter: parent.horizontalCenter
            z: xBtns.z+1000
            Row{
                spacing: app.fs
                UTextInput{
                    id: tiFolio
                    label: 'Folio: '
                    width: app.fs*12
                    maximumLength: 10
                    KeyNavigation.tab: tiGrado
                    property string uCodExist: ''
                    textInput.onFocusChanged: {
                        if(textInput.focus){
                            calendario.parent=r
                            textInput.selectAll()
                        }
                    }
                    onTextChanged: {
                        if(r.modificando)return
                        //tCheckCodExist.restart()
                    }
                    Timer{
                        id: tCheckCodExist
                        running: false
                        repeat: false
                        interval: 3000
                        onTriggered: {
                            let ce=r.codExist()
                            if(tiFolio.text!==r.uCodInserted&&ce&&tiFolio.text!==tiFolio.uCodExist){
                                let msg='<b>Atención!: </b>El folio actual ya existe.'
                                unik.speak(msg.replace(/<[^>]*>?/gm, ''))
                                labelStatus.text=msg
                            }
                            if(!ce){
                                r.modificando=false
                            }
                            tiFolio.uCodExist=tiFolio.text
                        }
                    }
                }
                UTextInput{
                    id: tiGrado
                    label: 'Grado: '
                    width: r.width*0.5-tiFolio.width//-app.fs*2
                    maximumLength: 50
                    KeyNavigation.tab: tiNombre
                    textInput.onFocusChanged: {
                        if(textInput.focus){
                            calendario.parent=r
                            textInput.selectAll()
                        }
                    }
                }
            }
            Row{
                z:labelCount.z+100
                spacing: app.fs*1.5
                UTextInput{
                    id: tiFechaNac
                    label: 'Fecha de Nacimiento: '
                    width: tiNombre.width*0.5-app.fs*0.5
                    maximumLength: 10
                    textInput.enabled: false
                    textInput.clip: false
                    //regularExp: RegExpValidator{regExp: /^([1-9])([0-9]{10})/ }
                    KeyNavigation.tab: itemCalFC
                    MouseArea{
                        anchors.fill: parent
                        onClicked:{
                            showCal(1)
                        }
                    }
                    Item{
                        id: itemCalFN
                        width: itemCalFC.width
                        height: app.fs*20
                        anchors.right: parent.right
                        anchors.rightMargin: app.fs*6.5
                        anchors.verticalCenter: parent.verticalCenter
                        objectName: 'itemCal1'
                        property string prevDateString:''
                        KeyNavigation.tab: itemCalFC
                        onFocusChanged: {
                            if(focus)showCal(1)
                        }
                        onVisibleChanged: {
                            if(visible&&tiFechaNac.text!==''){
                                prevDateString=tiFechaNac.text
                            }
                        }
                    }
                }
                UTextInput{
                    id: tiFechaCert
                    label: 'Fecha de Certificado: '
                    width: tiNombre.width*0.5-app.fs
                    maximumLength: 10
                    textInput.enabled: false
                    textInput.clip: false
                    MouseArea{
                        anchors.fill: parent
                        onClicked:{
                            showCal(2)
                        }
                    }
                    Item{
                        id: itemCalFC
                        width: r.width-colDatosCertificado.x-tiFechaCert.x-tiFechaCert.width-app.fs
                        height: app.fs*20
                        anchors.left: parent.right
                        anchors.leftMargin: 0
                        anchors.verticalCenter: parent.verticalCenter
                        objectName: 'itemCal2'
                        KeyNavigation.tab: botReg
                        property string prevDateString: ''
                        onFocusChanged: {
                            if(focus)showCal(2)
                            //                        if(!focus&&!itemCalFN.focus){
                            //                            calendario.parent=r
                            //                        }
                        }
                    }
                }
            }
            Item{width: 1;height: app.fs*2}
            UText{
                id: labelCount
                width: r.width*0.5-tiFolio.width-app.fs*2
                height: contentHeight
                wrapMode: Text.WordWrap
            }
        }
        Item{width: 1;height: app.fs*2}
        BotonUX{
            id: botCancel
            text: 'Cancelar'
            height: app.fs*2
            KeyNavigation.tab: botReg
            visible: false
            anchors.right: parent.right
            onClicked: {
                if(r.modificando){
                    r.modificando=false
                    //                    colDatosCertificado.visible=false
                    //                    tiNombre.text=''
                    //                    tiNombre.focus=true
                    //                    clear()
                    //                    return
                }
                visible=false
                tiNombre.text=''
                labelStatus.text=''
                cancel()
            }
            UnikFocus{}
        }
        Row{
            id: xBtns
            spacing: app.fs
            anchors.right: parent.right
            BotonUX{
                id: botClear
                text: 'Limpiar'
                height: app.fs*2
                KeyNavigation.tab: botReg
                visible: tiNombre.text!==''
                onClicked: {
                    clear()
                }
                UnikFocus{}
            }
            //            BotonUX{
            //                id: botCancelarModificar
            //                text: 'Cancelar'
            //                height: app.fs*2
            //                visible: r.modificando
            //                onClicked: {
            //                    r.modificando=false
            //                    colDatosCertificado.visible=false
            //                    tiNombre.text=''
            //                    tiNombre.focus=true
            //                    clear()
            //                }
            //            }
            BotonUX{
                id: botReg
                text: !r.modificando?'Guardar Registro':'Modificar Registro'
                height: app.fs*2
                visible: colDatosCertificado.visible
                onClicked: {
                    if(!r.modificando){
                        if(codExist()){
                            let msg='<b>Atención!: </b>El folio actual ya existe.'
                            unik.speak(msg.replace(/<[^>]*>?/gm, ''))
                            labelStatus.text=msg
                        }else{
                            insert()
                        }
                    }else{
                        modify()
                    }
                }
                KeyNavigation.tab: tiFolio
                Keys.onReturnPressed: {
                    if(!r.modificando){
                        if(codExist()){
                            let msg='<b>Atención!: </b>El folio actual ya existe.'
                            unik.speak(msg.replace(/<[^>]*>?/gm, ''))
                            labelStatus.text=msg
                        }else{
                            insert()
                        }
                    }else{
                        modify()
                        r.modificando=false
                    }
                }
                UnikFocus{}
            }
        }
        Item{
            id: xLS
            width: r.width*0.5-app.fs
            height: 1
            UText{
                id: labelStatus
                text: 'Esperando a que se registren certificados.'
                //width: contentWidth
                //height: contentHeight
                wrapMode: Text.WordWrap
                anchors.centerIn: parent
                //anchors.verticalCenter: parent.verticalCenter
                //anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        UText{
            id: labelCalCmd
            width: parent.width
            height: app.fs*2
            wrapMode: Text.WordWrap
            opacity: calendario.parent!==r?1.0:0.0
            text: 'Presionar arriba o abajo para cambiar día.\nPresionar derecha o izquierda para cambiar mes.\nPresionar Shift+derecha o Shift+izquierda para cambiar de año.'
        }

    }
    Timer{
        repeat: true
        running: r.visible
        interval: 15000
        onTriggered: updateGui()
    }
    Component{
        id: compExist
        Rectangle{
            id: xCodExists
            width: r.width*0.5
            height: colExists.height+app.fs
            radius: app.fs*0.1
            border.width: 2
            border.color: app.c2
            anchors.centerIn: parent
            color: app.c1
            property string vaid: ''
            property string vafolio: ''
            property string vagrado: ''
            property string vanom: ''
            property string vafechanac: ''
            property string vafechacert: ''
            Column{
                id: colExists
                spacing: app.fs
                width: parent.width-app.fs
                anchors.centerIn: parent
                UText{
                    id: txt
                    color:app.c2
                    font.pixelSize: app.fs
                    textFormat: Text.RichText
                    width: parent.width-app.fs
                    wrapMode: Text.WordWrap
                }
                Row{
                    spacing: app.fs
                    BotonUX{
                        id: botCodExistsMod
                        text: 'Modificar'
                        height: app.fs*1.6
                        fontColor: focus?app.c1:app.c2
                        bg.color: focus?app.c2:app.c1
                        glow.radius:focus?2:6
                        Keys.onReturnPressed: loadProd()
                        onClicked: loadProd()
                        function loadProd(){
                            xCodExists.visible=false
                            xCodExists.destroy(3000)
                            tiFolio.text=vafolio
                            tiGrado.text=vagrado
                            tiNombre.text=vanom
                            let d1=new Date(parseInt(vafechanac))
                            let d2=new Date(parseInt(vafechacert))
                            let f1=''+d1.getDate()+'/'+parseInt(d1.getMonth()+1)+'/'+d1.getFullYear()
                            let f2=''+d2.getDate()+'/'+parseInt(d2.getMonth()+1)+'/'+d2.getFullYear()
                            tiFechaNac.text=f1
                            tiFechaCert.text=f2
                            tiFolio.focus=true
                            r.modificando=true
                            r.pIdAModificar=parseInt(vaid)
                        }
                    }
                    BotonUX{
                        text: 'Cerrar'
                        height: app.fs*1.6
                        fontColor: focus?app.c1:app.c2
                        bg.color: focus?app.c2:app.c1
                        glow.radius:focus?2:6
                        onClicked: xCodExists.destroy(10)
                    }
                }
            }
            Component.onCompleted: {
                botCodExistsMod.focus=true
                let d1=new Date(parseInt(vafechanac))
                let d2=new Date(parseInt(vafechacert))
                let f1=''+d1.getDate()+'/'+parseInt(d1.getMonth()+1)+'/'+d1.getFullYear()
                let f2=''+d2.getDate()+'/'+parseInt(d2.getMonth()+1)+'/'+d2.getFullYear()
                let txtFinal='<b style="font-size:'+app.fs+'px;">Folio: </b><span style="font-size:'+app.fs+'px;">'+vafolio+'</span><br /><b  style="font-size:'+app.fs+'px;">Grado: </b><span style="font-size:'+app.fs+'px;">'+vagrado+'</span><br /><b style="font-size:'+app.fs+'px;">Nombre: </b> <span style="font-size:'+app.fs+'px;">'+vanom+'</span><br /><b>Fecha de Nacimiento: </b>'+f1+'<br /><b>Fecha de Certificado: </b>'+f2+'<br />'
                txt.text=txtFinal
            }
        }
    }
    Calendar{
        id: calendario
        anchors.fill: parent
        visible: parent.objectName==='itemCal1'||parent.objectName==='itemCal2'
        property bool setTextInput: false
        property int num:-1
        onParentChanged: {
            setTextInput=false
            if(parent===r){
                //selectedDate=new Date(Date.now())
                calendario.focus=false
                return
            }else{
                tiNombre.focus=false
                tiFolio.focus=false
                tiFechaNac.focus=false
                tiFechaCert.focus=false
                calendario.focus=true
            }
            if(parent===itemCalFN){
                if(tiFechaNac.text.length<2){
                    selectedDate=new Date(Date.now())
                }else{
                    selectedDate=new Date(r.dateForOpenFN.getTime())
                }
                return
            }
            if(parent===itemCalFC){
                if(tiFechaCert.text.length<2){
                    selectedDate=new Date(Date.now())
                }else{
                    selectedDate=new Date(r.dateForOpenFC.getTime())
                }
                return
            }
        }
        onVisibleChanged:{
            if(parent.objectName==='itemCal1'){
                num=1
                return
            }
            if(parent.objectName==='itemCal2'){
                num=2
                return
            }
            num=-1
        }
        style: CalendarStyle {
            dayDelegate: Rectangle{
                color: styleData.selected ? app.c2 : (styleData.visibleMonth && styleData.valid ? "#111" : "#666");
                Label {
                    text: styleData.date.getDate()
                    font.pixelSize: app.fs
                    anchors.centerIn: parent
                    color: styleData.valid ? (styleData.selected ?app.c1:app.c2) : app.c4
                }
                Rectangle {
                    width: parent.width
                    height: 1
                    color: app.c3
                    anchors.bottom: parent.bottom
                }
                Rectangle {
                    width: 1
                    height: parent.height
                    color: app.c3
                    anchors.right: parent.right
                }
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        calendario.setTextInput=true
                        calendario.selectedDate=styleData.date
                        if(calendario.parent===itemCalFN){
                            r.dateForOpenFN=new Date(styleData.date.getTime())
                        }
                        if(calendario.parent===itemCalFC){
                            r.dateForOpenFC=new Date(styleData.date.getTime())
                        }
                        //cal2.parent.visible=false
                    }
                }
            }
        }
        onSelectedDateChanged: {
            if(setTextInput){
                var d = selectedDate
                let dia=''+d.getDate()
                let mes=''+parseInt(d.getMonth()+1)
                if(parseInt(dia)<10){
                    dia='0'+dia
                }
                if(parseInt(mes)<10){
                    mes='0'+mes
                }
                let an=d.getFullYear()
                let s=''+dia+'/'+mes+'/'+an
                //uLogView.showLog('set!'+cal.num)

                if(calendario.num===1){
                    r.dateForOpenFN=new Date(d.getTime())
                    tiFechaNac.text=s
                    calendario.parent=r
                }
                if(calendario.num===2){
                    r.dateForOpenFC=new Date(d.getTime())
                    tiFechaCert.text=s
                    calendario.parent=r
                }
            }
            setTextInput=true
        }
        Rectangle{
            anchors.fill: parent
            color: app.c1
            z: parent.z-1
        }
        MouseArea{
            anchors.fill: parent
            z: calendario.z-1
        }
    }
    Component.onCompleted: {
        tiNombre.focus=true
        r.dateForOpenFN=new Date(Date.now())
        r.dateForOpenFC=new Date(Date.now())
    }
    function loadList(){
        xListViewAl.listModel.clear()
        let sql = 'select * from '+xFormInsertDatosAl.tableName+' where nombre like \'%'+tiNombre.text+'%\''
        let rows=unik.getSqlData(sql)
        //uLogView.showLog('rows: '+sql)
        if(rows.length>0){
            for(var i=0;i<rows.length;i++){
                xListViewAl.listModel.append(xListViewAl.listModel.addDato(rows[i].col[0],rows[i].col[1],rows[i].col[3],rows[i].col[2], rows[i].col[4], rows[i].col[5]))
            }
            xListViewAl.visible=true
            botCancel.visible=true
        }else{
            xListViewAl.visible=false
            botCancel.visible=false
        }
    }
    function codExist(){
        let sql = 'select * from '+r.tableName+' where folio=\''+tiFolio.text+'\''
        let rows = unik.getSqlData(sql)
        let exists= rows.length>0
        if(exists){
            let comp = compExist
            let obj = comp.createObject(r, {vaid:rows[0].col[0], vafolio:rows[0].col[1],  vagrado:rows[0].col[2], vanom: rows[0].col[3], vafechanac: rows[0].col[4], vafechacert: rows[0].col[5]})
        }
        return exists
    }
    function getCount(){
        let sql = 'select '+r.cols[0]+' from '+r.tableName
        let rows = unik.getSqlData(sql)
        return rows.length
    }
    function insert(){
        uLogView.text=''
        if(tiFolio.text===''||tiGrado.text===''||tiNombre.text===''||tiFechaNac.text===''||tiFechaCert.text===''){
            uLogView.showLog('Error!\nNo se han introducido todos los datos requeridos.\nPara registrar este alumno es necesario completar el formulario en su totalidad.')
            if(tiFolio.text===''){
                uLogView.showLog('Faltan los datos de folio.')
            }
            if(tiGrado.text===''){
                uLogView.showLog('Faltan los datos de grado.')
            }
            if(tiNombre.text===''){
                uLogView.showLog('Faltan los datos de nombre.')
            }
            if(tiFechaNac.text===''){
                uLogView.showLog('Faltan los datos de fecha de nacimiento.')
            }
            if(tiFechaCert.text===''){
                uLogView.showLog('Faltan los datos de fecha de certificado.')
            }
            uLogView.showLog('Presionar Escape para cerrar estas panel de advertencias.')
            return
        }
        if(r.tableName===''){
            uLogView.showLog('Table Name is empty!')
            return
        }
        if(r.cols.length===0){
            uLogView.showLog('Cols is empty!')
            return
        }
        let sql=''
        let rows
        //        let sql = 'select '+r.cols[0]+' from '+r.tableName+' where '+r.cols[0]+'=\''+tiFolio.text+'\''
        //        let rows = unik.getSqlData(sql)
        //        if(rows.length>=1){
        //            uLogView.showLog('Error! No se puede registrar el alumno con este número de folio.\nYa existe un alumno con el folio '+tiFolio.text)
        //            return
        //        }
        let m0DFN=tiFechaNac.text.split('/')
        let m0DFC=tiFechaCert.text.split('/')
        let dateFN= new Date(parseInt(m0DFN[2]), parseInt(m0DFN[1] - 1), parseInt(m0DFN[0]))
        let dateFC= new Date(parseInt(m0DFC[2]), parseInt(m0DFC[1] - 1), parseInt(m0DFC[0]))
        sql = 'insert into '+r.tableName+'('+r.cols+')values('+
                '\''+tiFolio.text+'\','+
                '\''+tiGrado.text+'\','+
                '\''+r.cNom+'\','+
                ''+dateFN.getTime()+','+
                ''+dateFC.getTime()+','+
                ''+r.cIdAlumno+''+
                ')'
        let insertado = unik.sqlQuery(sql)
        if(insertado){
            labelStatus.text='Se ha registrado el alumno con el folio '+tiFolio.text
        }else{
            labelStatus.text='El alumno con el folio '+tiFolio.text+' no ha sido registrado correctamente.'
            r.uCodInserted=tiFolio.text
        }
        clear()
        botCancel.visible=false
        tiNombre.text=''
        tiNombre.enabled=true
        tiNombre.focus=true
        colDatosCertificado.visible=false
        sql='select id from certificados order by id desc limit 1'
        rows=unik.getSqlData(sql)
        let d=new Date(Date.now())
        let event=''+app.cAdmin+' ha insertado un certificado'
        JS.setEvent(event, 'certificados', rows[0].col[0], d.getTime())
        //uLogView.showLog('Registro Insertado: '+insertado)
    }
    function modify(){
        let sql
        if(tiFolio.text!==r.cFolioAModificar){
            sql = 'select * from '+xFormInsert.tableName+' where folio=\''+tiFolio.text+'\''
            let rows=unik.getSqlData(sql)
            //uLogView.showLog('rows: '+sql)
            if(rows.length>0){
                unik.speak('Ya existe un certificado  con este folio.')
                return
            }
        }
        uLogView.text=''
        if(tiFolio.text===''||tiGrado.text===''||tiNombre.text===''||tiFechaNac.text===''||tiFechaCert.text===''){
            uLogView.showLog('Error!\nNo se han introducido todos los datos requeridos.\nPara registrar este alumno es necesario completar el formulario en su totalidad.')
            if(tiFolio.text===''){
                uLogView.showLog('Faltan los datos de folio.')
            }
            if(tiGrado.text===''){
                uLogView.showLog('Faltan los datos de grado.')
            }
            if(tiNombre.text===''){
                uLogView.showLog('Faltan los datos de nombre.')
            }
            if(tiFechaNac.text===''){
                uLogView.showLog('Faltan los datos de fecha de nacimiento.')
            }
            if(tiFechaCert.text===''){
                uLogView.showLog('Faltan los datos de fecha de certificado.')
            }
            uLogView.showLog('Presionar Escape para cerrar estas panel de advertencias.')
            return
        }
        if(r.tableName===''){
            uLogView.showLog('Table Name is empty!')
            return
        }
        if(r.cols.length===0){
            uLogView.showLog('Cols is empty!')
            return
        }
        let m0DFN=tiFechaNac.text.split('/')
        let m0DFC=tiFechaCert.text.split('/')
        let dateFN= new Date(parseInt(m0DFN[2]), parseInt(m0DFN[1] - 1), parseInt(m0DFN[0]))
        let dateFC= new Date(parseInt(m0DFC[2]), parseInt(m0DFC[1] - 1), parseInt(m0DFC[0]))
        sql = 'update '+r.tableName+' set '+
                app.colsCertificados[0]+'=\''+tiFolio.text+'\','+
                app.colsCertificados[1]+'=\''+tiGrado.text+'\','+
                app.colsCertificados[2]+'=\''+tiNombre.text+'\','+
                app.colsCertificados[3]+'='+dateFN.getTime()+','+
                app.colsCertificados[4]+'='+dateFC.getTime()+''+
                ' where id='+r.pIdAModificar
        //uLogView.showLog('MOD: '+sql)
        //console.log(sql)
        let insertado = unik.sqlQuery(sql)
        if(insertado){
            let msg='Se ha modificado el registro del alumno con folio '+tiFolio.text
            unik.speak(msg)
            labelStatus.text=msg
            r.modificando=false
        }else{
            let msg='El alumno con el folio '+tiFolio.text+' no ha sido modificado correctamente.'
            unik.speak(msg)
            labelStatus.text=msg
            r.uCodInserted=tiFolio.text
        }
        colDatosCertificado.visible=false
        tiNombre.text=''
        tiNombre.focus=true
        botCancel.visible=false
        labelStatus.text=''
        clear()
        let d=new Date(Date.now())
        let event=''+app.cAdmin+' ha modificado un certificado'
        JS.setEvent(event, 'certificados', r.pIdAModificar, d.getTime())
        //uLogView.showLog('Registro Insertado: '+insertado)
    }
    function updateGui(){
        labelCount.text=!r.modificando?'Creando el registro número '+parseInt(getCount() + 1):'Modificando el registro con folio '+tiFolio.text
    }
    function loadModify(p1, p2, p3, p4, p5, p6, p7){
        r.modificando=true
        app.mod=r.numMod
        r.pIdAModificar=p1
        colDatosCertificado.visible=true
        tiFolio.text=p2
        r.cFolioAModificar=p2
        tiGrado.text=p3
        tiNombre.text=p4
        //tiNombre.textInput.enabled=false
        tiFolio.focus=true
        let d1=new Date(parseInt(p5))
        let f1=''+d1.getDate()+'/'+parseInt(d1.getMonth()+1)+'/'+d1.getFullYear()
        tiFechaNac.text=f1
        let d2=new Date(parseInt(p6))
        let f2=''+d2.getDate()+'/'+parseInt(d2.getMonth()+1)+'/'+d2.getFullYear()
        tiFechaCert.text=f2
        botCancel.visible=true
    }
    function clear(){
        if(!colDatosCertificado.visible){
            tiNombre.text=''
            return
        }
        tiFolio.text=''
        tiGrado.text=''
        tiFechaNac.text=''
        tiFechaCert.text=''
        tiFolio.focus=true
        r.dateForOpenFN=new Date(Date.now())
        r.dateForOpenFC=new Date(Date.now())
        //r.cIdAlumno=-1
        //r.cNom=''
        botCC.visible=false
        tiNombre.enabled=true
        //colDatosCertificado.visible=false
        //xListViewAl.listModel.clear()
        labelStatus.text='Formulario limpiado.'
    }
    function cancel(){
        tiFolio.text=''
        tiGrado.text=''
        //tiNombre.text=''
        tiFechaNac.text=''
        tiFechaCert.text=''
        tiNombre.focus=true
        r.dateForOpenFN=new Date(Date.now())
        r.dateForOpenFC=new Date(Date.now())
        r.cIdAlumno=-1
        r.cNom=''
        botCC.visible=false
        xListViewAl.visible=false
        tiNombre.enabled=true
        colDatosCertificado.visible=false
    }

    function showCal(num){
        //tiFolio.textInput.focus=false
        //tiGrado.textInput.focus=false
        //tiNombre.textInput.focus=false

        if(num===1){
            calendario.parent=itemCalFN
        }
        if(num===2){
            calendario.parent=itemCalFC
        }
    }

    function upForm(){
        if(calendario.parent===r){
            return
        }
        var fecha = calendario.selectedDate;
        fecha.setDate(fecha.getDate() - 1);
        calendario.setTextInput=false
        calendario.selectedDate=fecha
    }
    function downForm(){
        if(calendario.parent===r){
            return
        }
        var fecha = calendario.selectedDate;
        fecha.setDate(fecha.getDate() + 1);
        calendario.setTextInput=false
        calendario.selectedDate=fecha
    }
    function rightForm(){
        //uLogView.showLog('R!')
        if(calendario.parent===r){
            return
        }
        var fecha = calendario.selectedDate;
        fecha.setMonth(fecha.getMonth() + 1);
        calendario.setTextInput=false
        calendario.selectedDate=fecha
    }
    function leftForm(){
        if(botReg.focus){
            botClear.focus=true
            return
        }
        if(calendario.parent===r){
            return
        }
        var fecha = calendario.selectedDate;
        fecha.setMonth(fecha.getMonth() - 1);
        calendario.setTextInput=false
        calendario.selectedDate=fecha
    }
    function shiftRightForm(){
        if(calendario.parent===r){
            return
        }
        var fecha = calendario.selectedDate;
        fecha.setYear(fecha.getFullYear() + 1);
        calendario.setTextInput=false
        calendario.selectedDate=fecha
    }
    function shiftLeftForm(){
        if(calendario.parent===r){
            return
        }
        var fecha = calendario.selectedDate;
        fecha.setYear(fecha.getFullYear() - 1);
        calendario.setTextInput=false
        calendario.selectedDate=fecha
    }
    function enterForm(){
        if(botCC.focus){
            botCC.clicked()
            tiFolio.focus=true
            return
        }
        if(tiNombre.textInput.focus){
            botCC.visible=false
            loadList()
            return
        }
        if(botClear.focus){
            clear()
            return
        }
        if(botReg.focus){
            botReg.clicked()
            return
        }
        if(calendario.parent===r){
            return
        }
        let d = calendario.selectedDate
        let dia=''+d.getDate()
        if(d.getDate()<10){
            dia='0'+dia
        }
        let mes=''+parseInt(d.getMonth()+1)
        if(parseInt(d.getMonth()+1)<10){
            mes='0'+mes
        }
        let an=''+d.getFullYear()
        let s=''+dia+'/'+mes+'/'+an
        if(calendario.parent===itemCalFN){
            tiFechaNac.text=s
            r.dateForOpenFN=new Date(calendario.selectedDate.getTime())
            calendario.parent=itemCalFC
            return
        }
        if(calendario.parent===itemCalFC){
            tiFechaCert.text=s
            r.dateForOpenFC=new Date(calendario.selectedDate.getTime())
            calendario.parent=r
            botReg.focus=true
        }
    }
    function escForm(){
        calendario.parent=r
        tiFolio.textInput.focus=true
    }
}
