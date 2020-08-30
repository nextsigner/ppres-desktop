import QtQuick 2.0

Item {
    id: r
    anchors.fill: parent
    property bool modificando: false
    property int pIdAModificar: -1
    property string tableName: ''
    property string uCodInserted: ''
    property var cols: []
    onVisibleChanged: {
        if(visible){
            updateGui()
            tiCodigo.focus=visible
            search()
        }else{
            tiCodigo.focus=false
            tiCodigo.focus=false
            tiNombre.focus=false
            tiDir.focus=false
            tiTel.focus=false
            tiCorreo.focus=false
            tiSaldo.focus=false
        }
    }
    Row{
        spacing: app.fs
        anchors.fill: r
        Column{
            id: colInsCli
            width: r.width*0.5-app.fs
            //anchors.horizontalCenter: parent.horizontalCenter
            spacing: app.fs*0.5
            UText{
                text:  !r.modificando?'<b>Insertando Cliente</b>':'<b>Modificando Cliente</b>'
                font.pixelSize: app.fs*2
            }
            Row{
                spacing: app.fs
                UTextInput{
                    id: tiCodigo
                    label: 'Código: '
                    width: app.fs*10
                    maximumLength: 10
                    KeyNavigation.tab: tiNombre
                    property string uCodExist: ''
                    onFocusChanged: {
                        textInput.selectAll()
                    }
                    onTextChanged: {
                        tCheckCodExist.restart()
                    }
                    Timer{
                        id: tCheckCodExist
                        running: false
                        repeat: false
                        interval: 3000
                        onTriggered: {
                            let ce=r.codExist()
                            if(tiCodigo.text!==r.uCodInserted&&ce&&tiCodigo.text!==tiCodigo.uCodExist){
                                let msg='<b>Atención!: </b>El código actual ya existe.'
                                unik.speak(msg.replace(/<[^>]*>?/gm, ''))
                                labelStatus.text=msg
                            }
                            if(!ce){
                                r.modificando=false
                            }
                            tiCodigo.uCodExist=tiCodigo.text
                        }
                    }
                }
                UText{
                    id: labelCount
                    width: colInsCli.width-tiCodigo.width-app.fs*2
                    height: contentHeight
                    wrapMode: Text.WordWrap
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            UTextInput{
                id: tiNombre
                label: 'Nombre: '
                width: colInsCli.width-app.fs
                maximumLength: 250
                KeyNavigation.tab: tiDir
                onFocusChanged: {
                    textInput.selectAll()
                }
            }
            UTextInput{
                id: tiDir
                label: 'Dirección: '
                width: colInsCli.width-app.fs
                maximumLength: 250
                KeyNavigation.tab: tiTel
                onFocusChanged: {
                    textInput.selectAll()
                }
            }
            UTextInput{
                id: tiTel
                label: 'Teléfono: '
                width: colInsCli.width-app.fs
                maximumLength: 250
                KeyNavigation.tab: tiCorreo
                onFocusChanged: {
                    textInput.selectAll()
                }
            }
            UTextInput{
                id: tiCorreo
                label: 'E-Mail: '
                width: colInsCli.width-app.fs
                maximumLength: 250
                KeyNavigation.tab: tiSaldo
                onFocusChanged: {
                    textInput.selectAll()
                }
            }
            UTextInput{
                id: tiSaldo
                label: 'Saldo: '
                width: app.fs*8
                maximumLength: 19
                regularExp: RegExpValidator{regExp: /^\d+(\.\d{1,2})?$/ }
                KeyNavigation.tab: botReg
                onFocusChanged: {
                    textInput.selectAll()
                }
            }
            Item{width: 1; height: app.fs}
            Item{
                width: r.width-app.fs
                height: 1
                UText{
                    id: labelStatus
                    text: 'Esperando a que se registren clientes.'
                    width: r.width
                    height: contentHeight
                    wrapMode: Text.WordWrap
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Row{
                spacing: app.fs
                anchors.right: parent.right
                BotonUX{
                    text: 'Limpiar'
                    height: app.fs*2
                    onClicked: {
                        tiCodigo.text=''
                        tiNombre.text=''
                        tiDir.text=''
                        tiTel.text=''
                        tiCorreo.text=''
                        tiSaldo.text=''
                        tiCodigo.focus=true
                        labelStatus.text='Formulario limpiado.'
                    }
                }
                BotonUX{
                    id: botReg
                    text: !r.modificando?'Guardar Cliente':'Modificar Cliente'
                    height: app.fs*2
                    onClicked: {
                        if(!r.modificando){
                            insert()
                        }else{
                            modify()
                        }
                        search()
                    }
                    KeyNavigation.tab: lv
                    Keys.onReturnPressed: {
                        if(!r.modificando){
                            insert()
                        }else{
                            modify()
                        }
                        search()
                    }
                    UnikFocus{
                        visible: parent.focus
                    }
                }
            }
        }
        Rectangle{
            width: parent.width*0.5
            height: parent.height
            color: 'transparent'
            border.color: app.c2
            border.width:   2
            UnikFocus{
                visible: lv.focus
                radius: 0
            }
            ListView{
                id: lv
                model: lm
                delegate: delPorCod//rbCod.checked?delPorCod:delPorDes
                spacing: app.fs*0.5
                width: parent.width
                height: parent.height
                clip: true
                onFocusChanged: currentIndex=1
                KeyNavigation.tab: tiCodigo
                Keys.onDownPressed: {
                    if(currentIndex<lm.count-1){
                        currentIndex++
                    }else{
                        currentIndex=1
                    }
                }
                Keys.onUpPressed: {
                    if(currentIndex>1){
                        currentIndex--
                    }else{
                        currentIndex=lm.count-1
                    }
                }
                ListModel{
                    id: lm
                    function addProd(pid, pcod, pnom, pdir, ptel, pemail, psaldo){
                        return{
                            vpid: pid,
                            vpcod: pcod,
                            vpnom: pnom,
                            vpdir:pdir,
                            vptel: ptel,
                            vpemail: pemail,
                            vpsaldo: psaldo
                        }
                    }
                }
                Component{
                    id: delPorCod
                    Rectangle{
                        id:xRowDes
                        width: parent.width
                        height: parseInt(vpid)!==-10?txtNom.height+app.fs:app.fs*3
                        radius: app.fs*0.1
                        border.width: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: parseInt(vpid)!==-10&&index!==lv.currentIndex?app.c1:app.c2
                        property string fontColor: index!==lv.currentIndex?app.c2:app.c1
                        MouseArea{
                            anchors.fill: parent
                            onClicked: lv.currentIndex=index
                        }
                        Row{
                            visible: parseInt(vpid)!==-10
                            anchors.centerIn: parent
                            Rectangle{
                                id: xRD1
                                width: app.fs*10
                                height:xRD2.height
                                border.width: 2
                                border.color: app.c2
                                color: parseInt(vpid)!==-10&&index!==lv.currentIndex?app.c1:app.c2
                                UText{
                                    text: vpcod
                                    anchors.centerIn: parent
                                    color: xRowDes.fontColor
                                }
                            }
                            Rectangle{
                                id: xRD2
                                width: xRowDes.width-xRD1.width-xRD3.width
                                height:txtNom.contentHeight+app.fs*2
                                border.width: 2
                                border.color: app.c2
                                color: parseInt(vpid)!==-10&&index!==lv.currentIndex?app.c1:app.c2
                                UText{
                                    id: txtNom
                                    text: vpnom
                                    color: xRowDes.fontColor
                                    width: parent.width-app.fs
                                    wrapMode: Text.WordWrap
                                    anchors.centerIn: parent
                                }
                            }
                            Rectangle{
                                id: xRD3
                                width: app.fs*10
                                height:xRD2.height
                                border.width: 2
                                border.color: app.c2
                                color: parseInt(vpid)!==-10&&index!==lv.currentIndex?app.c1:app.c2
                                UText{
                                    text: vpsaldo
                                    color: xRowDes.fontColor
                                    anchors.centerIn: parent
                                }
                            }
                        }
                        BotonUX{
                            text: 'Eliminar'
                            height: app.fs*2
                            fontColor: app.c2
                            bg.color: app.c1
                            glow.radius: 2
                            visible: index===lv.currentIndex&&parseInt(vpid)!==-10
                            anchors.right: parent.right
                            anchors.rightMargin: app.fs*0.5
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked: {
                                let sql='delete from '+r.currentTableName+' where id='+vpid
                                unik.sqlQuery(sql)
                                search()
                            }
                        }
                    }
                }
            }
        }
    }
    Timer{
        repeat: true
        running: r.visible
        interval: 5000//15000
        onTriggered: {
            updateGui()
            //search()
        }
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
            color: parseInt(vpid)!==-10?app.c1:app.c2
            property string vpid: ''
            property string vpcod: ''
            property string vpnom: ''
            property string vpdir: ''
            property string vptel: ''
            property string vpemail: ''
            property string vpsaldo: ''
            Column{
                id: colExists
                spacing: app.fs
                width: parent.width-app.fs
                anchors.centerIn: parent
                UText{
                    id: txt
                    color:parseInt(vpid)!==-10?app.c2:app.c1
                    font.pixelSize: app.fs
                    text: parseInt(vpid)!==-10? '<b style="font-size:'+app.fs+'px;">Código: </b><span style="font-size:'+app.fs+'px;">'+vpcod+'</span><br /><br />

<b  style="font-size:'+app.fs*1.4+'px;">Nombre: </b><span style="font-size:'+app.fs+'px;">'+vpnom+'</span><br /><br />

<b  style="font-size:'+app.fs*1.4+'px;">Dirección: </b><span style="font-size:'+app.fs+'px;">'+vpdir+'</span><br /><br />

<b  style="font-size:'+app.fs*1.4+'px;">Teléfono: </b><span style="font-size:'+app.fs+'px;">'+vptel+'</span><br /><br />

<b  style="font-size:'+app.fs*1.4+'px;">E-Mail: </b><span style="font-size:'+app.fs+'px;">'+vpemail+'</span><br /><br />

<b  style="font-size:'+app.fs*1.4+'px;">Saldo: </b><span style="font-size:'+app.fs+'px;">'+vpsaldo+'</span><br /><br />':'<b>Resultados por descripción:</b> '+tiSearch.text
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
                            tiCodigo.text=vpcod
                            tiNombre.text=vpnom
                            tiDir.text=vpdir
                            tiTel.text=vptel
                            tiCorreo.text=vpemail
                            tiSaldo.text=vpsaldo
                            r.modificando=true
                            r.pIdAModificar=parseInt(vpid)
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
            Component.onCompleted: botCodExistsMod.focus=true
        }
    }
    Component.onCompleted: {
        search()
    }
    function codExist(){
        let sql = 'select * from '+r.tableName+' where cod=\''+tiCodigo.text+'\''
        let rows = unik.getSqlData(sql)
        let exists= rows.length>0
        if(exists){
            let comp = compExist
            let obj = comp.createObject(r, {vpid:rows[0].col[0], vpcod:rows[0].col[1],  vpnom:rows[0].col[2], vpdir: rows[0].col[3], vptel: rows[0].col[4], vpemail:rows[0].col[5], vpsalso:rows[0].col[6]})
        }
        return exists
    }
    function getCount(){
        let sql = 'select '+r.cols[0]+' from '+r.tableName
        let rows = unik.getSqlData(sql)
        return rows.length
    }
    function insert(){
        if(tiCodigo.text===''||tiNombre.text===''){
            uLogView.showLog('Error!\nNo se han introducido todos los datos requeridos.\nPara guardar este producto es necesario completar el formulario en su totalidad.')
            if(tiCodigo.text===''){
                uLogView.showLog('Faltan los datos de código.')
            }
            if(tiNombre.text===''){
                uLogView.showLog('Faltan los datos de descripción.')
            }
            if(tiPrecioCosto.text===''){
                uLogView.showLog('Faltan los datos de precio de costo.')
            }
            if(tiPrecioVenta.text===''){
                uLogView.showLog('Faltan los datos de precio de venta.')
            }
            return
        }
        if(r.tableName===''){
            uLogView.showLog('Table Name is empty!')
            return
        }
        //        if(r.cols.length===0){
        //            uLogView.showLog('Cols is empty!')
        //            return
        //        }
        let sql = 'select '+r.cols[0]+' from '+r.tableName+' where '+r.cols[0]+'=\''+tiCodigo.text+'\''
        let rows = unik.getSqlData(sql)
        if(rows.length>=1){
            uLogView.showLog('Error! No se puede insertar un cliente con este código.\nYa existe un cliente con el código '+tiCodigo.text)
            return
        }
        let saldo=tiSaldo.text
        if(saldo===''){
            saldo='00.00'
        }
        if(saldo.indexOf('.')<0){
            saldo+='.00'
        }
        sql = 'insert into '+r.tableName+'('+r.cols+')values('+
                '\''+tiCodigo.text+'\','+
                '\''+tiNombre.text+'\','+
                '\''+tiDir.text+'\','+
                '\''+tiTel.text+'\','+
                '\''+tiCorreo.text+'\','+
                ''+tiSaldo.text+''+
                ')'
        let insertado = unik.sqlQuery(sql)
        if(insertado){
            let msg='Se ha insertado el cliente con el código '+tiCodigo.text
            unik.speak(msg)
            labelStatus.text=msg
        }else{
            let msg='El cliente con el código '+tiCodigo.text+' no ha sido registrado correctamente.'
            unik.speak(msg)
            labelStatus.text=msg
            r.uCodInserted=tiCodigo.text
        }
        //uLogView.showLog('Registro Insertado: '+insertado)
    }
    function modify(){
        if(tiCodigo.text===''||tiNombre.text===''){
            uLogView.showLog('Error!\nNo se han introducido todos los datos requeridos.\nPara guardar este producto es necesario completar el formulario en su totalidad.')
            if(tiCodigo.text===''){
                uLogView.showLog('Faltan los datos de código.')
            }
            if(tiNombre.text===''){
                uLogView.showLog('Faltan los datos de descripción.')
            }
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
        let saldo=tiSaldo.text
        if(saldo.indexOf('.')<0){
            saldo+='.00'
        }
        let sql = 'update '+r.tableName+' set '+
            'cod=\''+tiCodigo.text+'\','+
            'nom=\''+tiNombre.text+'\','+
            'dir=\''+tiDir.text+'\','+
            'tel=\''+tiTel.text+'\','+
            'email=\''+tiCorreo.text+'\','+
            'saldo='+saldo+''+
            ' where id='+r.pIdAModificar
        let insertado = unik.sqlQuery(sql)
        if(insertado){
            let msg='Se ha modificado el producto con el código '+tiCodigo.text
            unik.speak(msg)
            labelStatus.text=msg
        }else{
            let msg='El producto con el código '+tiCodigo.text+' no ha sido modificado correctamente.'
            unik.speak(msg)
            labelStatus.text=msg
            r.uCodInserted=tiCodigo.text
        }
        //uLogView.showLog('Registro Insertado: '+insertado)
    }
    function search(){
        //if(!buscando)return
        lm.clear()
        lm.append(lm.addProd('-10', 'Lista de Clientes', '', '','','',''))
        var sql='select * from clientes order by id desc'
        var rows=unik.getSqlData(sql)
        //console.log('Sql count result: '+rows.length)
        //cant.text='Resultados: '+rows.length
        //uLogView.showLog('Cli: '+rows.length)
        for(var i=0;i<rows.length;i++){
            lm.append(lm.addProd(rows[i].col[0], rows[i].col[1], rows[i].col[2], rows[i].col[3], rows[i].col[4], rows[i].col[5], rows[i].col[6]))
        }

    }
    function updateGui(){
        labelCount.text=!r.modificando?'Creando el registro número '+parseInt(getCount() + 1):'Modificando el registro con código '+tiCodigo.text
    }
}
