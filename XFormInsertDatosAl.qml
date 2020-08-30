import QtQuick 2.12
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "func.js" as JS

Item {
    id: r
    anchors.fill: parent
    property int numMod
    property bool modificando: false
    property string cNombreAModificar: ''
    property int pIdAModificar: -1
    property string tableName: ''
    property string uCodInserted: ''
    property var cols: []
    property var currentCalFN
    property int currentIdAlumno: -1

    onVisibleChanged: {
        if(visible){
            updateGui()
            tiNombre.focus=visible
        }else{
            tiNombre.focus=false
            tiEdad.focus=false
            tiDomicilio.focus=false
            tiTel.focus=false
            tiEMail.focus=false
        }
    }
    Column{
        id: col1
        spacing: app.fs*0.5
        anchors.centerIn: parent
        UText{
            text:  !r.modificando?'<b>Registro de Datos de Alumno</b>':'<b>Modificando Registro de Alumno</b>'
            font.pixelSize: app.fs*2
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Item{width: 1;height: app.fs*2}
        Column{
            id:colFormInsertDatoAl
            //visible: false
            spacing: app.fs*0.5
            UText{
                text:  !r.modificando?'<b>Información</b>':'<b>Modificando Registro de Alumno</b>'
                font.pixelSize: app.fs
                anchors.horizontalCenter: parent.horizontalCenter
            }
            UTextInput{
                id: tiNombre
                label: 'Nombre: '
                width: r.width*0.5+app.fs
                maximumLength: 50
                //regularExp: RegExpValidator{regExp: /^\d+(\.\d{1,2})?$/ }
                KeyNavigation.tab: tiDomicilio
                onTextChanged: {

                }
                textInput.onFocusChanged: {
                    if(textInput.focus){
                        textInput.selectAll()
                    }
                }
            }
            UTextInput{
                id: tiDomicilio
                label: 'Domicilio: '
                width: tiNombre.width
                maximumLength: 50
                textInput.clip: false
                KeyNavigation.tab: tiEdad
            }
            Row{
                z:labelCount.z+100
                spacing: app.fs*0.5
                UTextInput{
                    id: tiEdad
                    label: 'Edad: '
                    width: tiNombre.width*0.5-app.fs*0.25
                    maximumLength: 3
                    textInput.clip: false
                    KeyNavigation.tab: tiTel
                }
                UTextInput{
                    id: tiTel
                    label: 'Teléfono: '
                    width: tiNombre.width*0.5-app.fs*0.25
                    maximumLength: 20
                    textInput.clip: false
                    KeyNavigation.tab: tiEMail
                }
            }
            Row{
                z:labelCount.z+100
                spacing: app.fs*1.5
                UTextInput{
                    id: tiEMail
                    label: 'E-Mail: '
                    width: tiNombre.width
                    maximumLength: 50
                    textInput.clip: false
                    KeyNavigation.tab: botReg
                }
            }
            Item{width: 1;height: app.fs*2}
        }
        UText{
            id: labelCount
            width: r.width*0.5-tiNombre.width-app.fs*2
            height: contentHeight
            wrapMode: Text.WordWrap
        }
        Item{
            width: r.width*0.5-app.fs
            height: 1
            UText{
                id: labelStatus
                text: 'Esperando a que se registren datos de alumnos.'
                width: r.width
                height: contentHeight
                wrapMode: Text.WordWrap
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        Item{width: 1;height: app.fs*2}
        Row{
            spacing: app.fs
            anchors.right: parent.right
            BotonUX{
                id: botClear
                text: 'Limpiar'
                height: app.fs*2
                KeyNavigation.tab: botReg
                onClicked: {
                    clear()
                }
                UnikFocus{}
            }
            BotonUX{
                id: botCancelarModificar
                text: 'Cancelar'
                height: app.fs*2
                visible: r.modificando
                onClicked: {
                    r.modificando=false
                    clear()
                }
            }
            BotonUX{
                id: botReg
                text: !r.modificando?'Guardar Datos':'Modificar Datos'
                height: app.fs*2
                onClicked: {
                    if(!r.modificando){
                        insert()
                    }else{
                        modify()
                    }
                }
                KeyNavigation.tab: tiNombre
                Keys.onReturnPressed: {
                    if(!r.modificando){
                        insert()
                    }else{
                        modify()
                        r.modificando=false
                    }
                }
                UnikFocus{}
            }
        }
    }
    Timer{
        repeat: true
        running: r.visible
        interval: 15000
        onTriggered: updateGui()
    }
    Component.onCompleted: {
        tiNombre.focus=true
    }
    function codExist(){
        let sql = 'select * from '+r.tableName+' where id=\''+tiNombre.text+'\''
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
        let sql = 'select * from '+xFormInsert.tableName+' where nombre=\''+tiNombre.text+'\''
        let rows=unik.getSqlData(sql)
        //uLogView.showLog('rows: '+sql)
        if(rows.length>0){
            unik.speak('Ya existe un alumno con este nombre.')
            /*r.currentIdAlumno=rows[0].col[0]
            tiDomicilio.text=rows[0].col[1]
            tiEdad.text=rows[0].col[2]
            tiTel.text=rows[0].col[3]
            tiEMail.text=rows[0].col[4]
            r.modificando=true*/
            return
        }
        uLogView.text=''
        if(tiNombre.text===''||tiDomicilio.text===''||tiEdad.text===''||tiTel.text===''||tiEMail.text===''){
            uLogView.showLog('Error!\nNo se han introducido todos los datos requeridos.\nPara registrar los datos de este alumno es necesario completar el formulario en su totalidad.')
            if(tiNombre.text===''){
                uLogView.showLog('Faltan los datos de nombre.')
            }
            if(tiDomicilio.text===''){
                uLogView.showLog('Faltan los datos de Domicilio.')
            }
            if(tiEdad.text===''){
                uLogView.showLog('Faltan los datos de edad.')
            }
            if(tiTel.text===''){
                uLogView.showLog('Faltan los datos de teléfono.')
            }
            if(tiEMail.text===''){
                uLogView.showLog('Faltan los datos de email.')
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
        sql = 'select '+r.cols[0]+' from '+r.tableName+' where '+r.cols[0]+'=\''+tiNombre.text+'\''
        rows = unik.getSqlData(sql)
        if(rows.length>=1){
            uLogView.showLog('Error! No se han podido registrar los datos alumno con este nombre.\nYa existe un alumno con el nombre '+tiNombre.text)
            return
        }
        sql = 'insert into '+r.tableName+'('+r.cols+')values('+
                '\''+tiNombre.text+'\','+
                '\''+tiEdad.text+'\','+
                '\''+tiDomicilio.text+'\','+
                '\''+tiTel.text+'\','+
                '\''+tiEMail.text+'\''+
                ')'
        let insertado = unik.sqlQuery(sql)
        if(insertado){
            labelStatus.text='Se han registrado los datos del alumno '+tiNombre.text
        }else{
            labelStatus.text='Los datos del alumno '+tiNombre.text+' no han sido registrados correctamente.'
            r.uCodInserted=tiNombre.text
        }
        clear()
        sql='select id from alumnos order by id desc limit 1'
        rows=unik.getSqlData(sql)
        let d=new Date(Date.now())
        let event=''+app.cAdmin+' ha insertado un registro de alumno'
        JS.setEvent(event, 'alumnos', rows[0].col[0], d.getTime())
        //uLogView.showLog('Registro Insertado: '+insertado)
    }
    function modify(){
        let sql
        if(tiNombre.text!==r.cNombreAModificar){
            sql = 'select * from '+xFormInsert.tableName+' where nombre=\''+tiNombre.text+'\''
            let rows=unik.getSqlData(sql)
            //uLogView.showLog('rows: '+sql)
            if(rows.length>0){
                unik.speak('Ya existe un alumno con este nombre.')
                return
            }
        }
        uLogView.text=''
        uLogView.text=''
        if(tiNombre.text===''||tiDomicilio.text===''||tiEdad.text===''||tiTel.text===''||tiEMail.text===''){
            uLogView.showLog('Error!\nNo se han introducido todos los datos requeridos.\nPara registrar los datos de este alumno es necesario completar el formulario en su totalidad.')
            if(tiNombre.text===''){
                uLogView.showLog('Faltan los datos de nombre.')
            }
            if(tiDomicilio.text===''){
                uLogView.showLog('Faltan los datos de Domicilio.')
            }
            if(tiEdad.text===''){
                uLogView.showLog('Faltan los datos de edad.')
            }
            if(tiTel.text===''){
                uLogView.showLog('Faltan los datos de teléfono.')
            }
            if(tiEMail.text===''){
                uLogView.showLog('Faltan los datos de email.')
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
        sql = 'update '+r.tableName+' set '+
                app.colsDatosAlumnos[0]+'=\''+tiNombre.text+'\','+
                app.colsDatosAlumnos[1]+'=\''+tiEdad.text+'\','+
                app.colsDatosAlumnos[2]+'=\''+tiDomicilio.text+'\','+
                app.colsDatosAlumnos[3]+'=\''+tiTel.text+'\','+
                app.colsDatosAlumnos[4]+'=\''+tiEMail.text+'\''+
                ' where id='+r.pIdAModificar
        //uLogView.showLog('MOD: '+sql)
        let insertado = unik.sqlQuery(sql)
        if(insertado){
            let msg='Se ha modificado el registro del alumno con nombre '+tiNombre.text
            unik.speak(msg)
            labelStatus.text=msg
            r.modificando=false
        }else{
            let msg='El alumno con el nombre '+tiNombre.text+' no ha sido modificado correctamente.'
            unik.speak(msg)
            labelStatus.text=msg
            r.uCodInserted=tiNombre.text
        }
        clear()
        let d=new Date(Date.now())
        let event=''+app.cAdmin+' ha modificado un registro de alumno'
        JS.setEvent(event, 'alumnos', r.pIdAModificar, d.getTime())
        //uLogView.showLog('Registro Insertado: '+insertado)
    }
    function updateGui(){
        labelCount.text=!r.modificando?'Creando el registro número '+parseInt(getCount() + 1):'Modificando el registro con Nombre '+tiNombre.text
    }
    function loadModify(p1, p2, p3, p4, p5, p6){
        r.modificando=true
        app.mod=r.numMod
        r.pIdAModificar=p1
        tiNombre.text=p2
        r.cNombreAModificar=p2
        tiDomicilio.text=p4
        tiEdad.text=p3
        tiTel.text=p5
        tiEMail.text=p6
    }
    function clear(){
        tiNombre.text=''
        tiDomicilio.text=''
        tiEdad.text=''
        tiTel.text=''
        tiEMail.text=''
        tiNombre.focus=true
        botReg.text='Guardar Datos'
        labelStatus.text='Formulario limpiado.'
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
        if(botClear.focus){
            clear()
            return
        }
        if(botReg.focus){
            botReg.clicked()
            return
        }
    }
    function escForm(){
        calendario.parent=r
        tiNombre.textInput.focus=true
    }
}
