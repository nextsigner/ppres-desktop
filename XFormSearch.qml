import QtQuick 2.12
import QtQuick.Controls 2.0
import Qt.labs.settings 1.0
import "func.js" as JS

Item {
    id: r
    anchors.fill: parent
    property bool buscando: false
    property string currentTableName: ''
    property bool selectedAll: false
    property var idsSelected: []
    onSelectedAllChanged: {
        cbSelectedAll.checked=selectedAll
        if(!cbSelectedAll.setearTodos&&!selectedAll){
            cbSelectedAll.setearTodos=true
            setBtnDeleteText()
            return
        }
        for(var i=0;i<lm.count; i++){
            lm.get(i).v7=selectedAll
        }
        setBtnDeleteText()
        lv.focus=true
    }
    onVisibleChanged: {
        lv.focus=visible
        tiSearch.text=''
        if(visible&&tiSearch.text===''){
            //getSearch(tiSearch.text)
            //search()
            lv.currentIndex=usFormSearch.uCurrentIndex
        }
        setBtnDeleteText()
    }
    Settings{
        id: usFormSearch
        fileName: pws+'/'+app.moduleName+'/'+app.moduleName+'_xsearch'
        property string searchBy
        property int orderAscDesc
        property bool showTools
        property bool selectToTop
        property int uCurrentIndex
        Component.onCompleted: {
            if(usFormSearch.searchBy==='')usFormSearch.searchBy='Folio'
            tiSearch.focus=true
        }
    }
    Column{
        id: colFormSearch
        width: parent.width-app.fs
        height: parent.height
        spacing: app.fs*0.25
        anchors.horizontalCenter: parent.horizontalCenter
        Row{
            spacing: app.fs*0.5
            anchors.horizontalCenter: parent.horizontalCenter
            UTextInput{
                id: tiSearch
                label: 'Buscar Producto:'
                width: app.fs*18
                KeyNavigation.down: lv
                KeyNavigation.tab: lv
                itemNextFocus: lv
                onSeted: getSearch(tiSearch.text)
                onTextChanged: {
                    r.buscando=true
                    //lv.currentIndex=0
                    //search()
                    //getSearch(tiSearch.text)
                }
            }
            BotonUX{
                id: botSearchTools
                text: ''//'Opciones de Busqueda'
                height: app.fs*2
                onClicked: usFormSearch.showTools=!usFormSearch.showTools
                UText{
                    text: '\uf013'//'Opciones de Busqueda'
                    font.family: "FontAwesome"
                    anchors.centerIn: parent
                }
            }
            BotonUX{
                id: botDelete
                text: 'Eliminar Registro'
                height: app.fs*2
                visible: false
                onClicked: deleteRows()
            }
            BotonUX{
                id: botModify
                text: 'Modificar Registro'
                height: app.fs*2
                visible: false
                onClicked: modifyRow()
            }
        }
        Row{
            id: rowRBX
            spacing: app.fs*0.5
            anchors.horizontalCenter: parent.horizontalCenter
            visible: usFormSearch.showTools
            Row{
                id: rowRB
                spacing: app.fs*0.5
                anchors.verticalCenter: parent.verticalCenter
                UText{text: '<b>Buscar por:</b>';anchors.verticalCenter: parent.verticalCenter}
                URadioButton{
                    id: rbCod
                    text: 'Folio'
                    checked: true
                    d: app.fs*1.4
                    onCheckedChanged: {
                        search()
                        if(checked){
                            rbDes.checked=false
                        }
                    }
                    anchors.verticalCenter: parent.verticalCenter
                }
                URadioButton{
                    id: rbDes
                    text: 'Nombre'
                    d: app.fs*1.4
                    onCheckedChanged: {
                        search()
                        if(checked){
                            rbCod.checked=false
                        }
                    }
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            UText{text: '<b>Ordenar por:</b>';anchors.verticalCenter: parent.verticalCenter}
            ComboBox{
                id: cbPor
                model: app.colsNamesProds
                currentIndex: app.colsNamesProds.indexOf(usFormSearch.searchBy)
                anchors.verticalCenter: parent.verticalCenter
                onCurrentTextChanged:{
                    usFormSearch.searchBy=currentText
                    search()
                }
            }
            ComboBox{
                id: cbAscDesc
                model: ['Ascendente', 'Descendente']
                currentIndex: usFormSearch.orderAscDesc
                anchors.verticalCenter: parent.verticalCenter
                onCurrentIndexChanged:{
                    usFormSearch.orderAscDesc=currentIndex
                    search()
                }
            }
            Row{
                spacing: app.fs
                UText{
                    text: 'Posicionar seleccionados\nhacia arriba'
                    width: app.fs*16
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
                CheckBox{
                    id: cbSelToTop
                    checked: usFormSearch.selectToTop
                    onCheckedChanged: {
                        usFormSearch.selectToTop=checked
                        search()
                    }
                }
            }
        }

        UText{id: cant}
        Item{
            width: lv.width
            height: app.fs*4-colFormSearch.spacing
            Item{
                id:xRowTitDes
                width: lv.width
                height: app.fs*4
                property var anchos: [0.35, 0.1,0.1,0.1,0.1,0.25]
                property string fontColor: app.c1
                Row{
                    anchors.centerIn: parent
                    Repeater{
                        model: app.colsNamesProds
                        Rectangle{
                            width: xRowTitDes.width*xRowTitDes.anchos[index]
                            height:xRowTitDes.height
                            border.width: 2
                            border.color: app.c4
                            color: app.c2
                            UText{
                                text: '<b>'+(''+app.colsNamesProds[index]).replace(/ /g, '<br />')+'</b>'
                                anchors.centerIn: parent
                                color: app.c1//xRowTitDes.fontColor
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                }
            }
        }
        Rectangle{
            width: parent.width
            height: usFormSearch.showTools?r.height-tiSearch.height-xRowTitDes.height-cant.height-colFormSearch.spacing*4-rowRBX.height:r.height-tiSearch.height-xRowTitDes.height-cant.height-colFormSearch.spacing*3
            color: 'transparent'
            border.color: app.c2
            border.width:   2
            //            UnikFocus{
            //                visible: lv.focus
            //                radius: 0
            //            }
            ListView{
                id: lv
                model: lm
                delegate: delPorCod//rbCod.checked?delPorCod:delPorDes
                spacing: 0//app.fs*0.5
                width: parent.width
                height: parent.height
                clip: true
                KeyNavigation.tab: tiSearch
                Keys.onDownPressed: downRow()
                Keys.onUpPressed: upRow()
                boundsBehavior: ListView.StopAtBounds
                ScrollBar.vertical: ScrollBar {}
                cacheBuffer: 1000
                displayMarginBeginning: lm.count*app.fs*2
                displayMarginEnd: lm.count*app.fs*2
                onCurrentIndexChanged: {
                    //usFormSearch.uCurrentIndex=currentIndex
                }
                ListModel{
                    id: lm
                    function addDato(p1, p2, p3, p4, p5, p6, p7){
                        return{
                            v1: p1,//id
                            descripcion: p2,//descripcion
                            codigo: p3,//codigo
                            precioinstalacion:p4,
                            precioabono: p5,
                            adicionalriesgo: p6,
                            observaciones: p7,
                            v8: false
                        }
                    }
                }
                Component{
                    id: delPorCod
                    Rectangle{
                        id:xRowDes
                        width: parent.width
                        height: rowData.height//+app.fs*2//parseInt(v1)!==-10?app.fs*2:app.fs*3
                        border.width: 2
                        property string rowId: v1
                        //Keys.onDownPressed: downRow()
                        //Keys.onUpPressed: upRow()
                        Keys.onSpacePressed: {
                            /*lv.currentIndex=index
                            cbRow.checked=!cbRow.checked
                            if(cbSelToTop.checked){
                                search()
                            }*/
                            //uLogView.showLog('Spacing'+index)
                        }
                        Row{
                            id: rowData
                            anchors.verticalCenter: parent.verticalCenter
                            XCelda{
                                id: xDes
                                width:xRowTitDes.width*xRowTitDes.anchos[0]
                                text: descripcion
                            }
                            XCelda{
                                id: xCodigo
                                width:xRowTitDes.width*xRowTitDes.anchos[1]
                                height: xDes.height
                                text: codigo
                            }
                            XCelda{
                                id: xPrecioinstalacion
                                width:xRowTitDes.width*xRowTitDes.anchos[2]
                                height: xDes.height
                                text: '$'+precioinstalacion
                            }
                            XCelda{
                                id: xPrecioabono
                                width:xRowTitDes.width*xRowTitDes.anchos[3]
                                height: xDes.height
                                text: '$'+precioabono
                            }
                            XCelda{
                                id: xAdicionalRiesgo
                                width:xRowTitDes.width*xRowTitDes.anchos[4]
                                height: xDes.height
                                text: '$'+adicionalriesgo
                            }
                            XCelda{
                                id: xObservaciones
                                width:xRowTitDes.width*xRowTitDes.anchos[5]
                                height: xDes.height
                                text: observaciones
                            }
                        }
                    }
                }
            }
        }
    }
    Component.onCompleted: {
        if(r.visible){
            search()
            lv.focus=true
            //tiSearch.focus=true
        }
    }
    function enterForm(){
        if(tiSearch.textInput.focus){
            getSearch(tiSearch.text)
            return
        }
    }

    function search(){
        //if(!buscando)return
        lm.clear()

        let colSearch=''
        if(rbCod.checked){
            colSearch='folio'
        }else{
            colSearch='nombre'
        }

        var p1=tiSearch.text!=='*'||tiSearch.text!==''?tiSearch.text.split(' '):('').split(' ')

        let sOrderByAndAsc=' order by '
        let ascDesc=cbAscDesc.currentIndex===0?'asc':'desc'
        if(usFormSearch.orderBy===''){
            sOrderByAndAsc+='id desc'
        }else{
            sOrderByAndAsc+=app.colsCertificados[cbPor.currentIndex]+' '+ascDesc
        }

        //lm.append(lm.addDato('-10', tiSearch.text, '', '','',''))
        var b=colSearch+' like \'%'
        //b+=p1[0]+'%'
        for(var i=0;i<p1.length;i++){
            b+=p1[i]+'%'
        }
        b+='\' or '+colSearch+' like \'%'
        for(i=p1.length-1;i>-1;i--){
            b+=p1[i]+'%'
        }
        b+='\''
        var sql='select distinct * from '+app.tableName1+' where '+b+' '+sOrderByAndAsc
        //console.log('Sql: '+sql)

        //uLogView.showLog('1 SQL SEARCH:'+sql)

        var rows=unik.getSqlData(sql)
        //console.log('Sql count result: '+rows.length)
        cant.text='Resultados: '+rows.length
        if(r.idsSelected.length===0||!cbSelToTop.checked){
            //cbSelectedAll.setearTodos=false
            //cbSelectedAll.checked=false
            for(i=0;i<rows.length;i++){
                lm.append(lm.addDato(rows[i].col[0], rows[i].col[1], rows[i].col[2], rows[i].col[3], rows[i].col[4], rows[i].col[5], rows[i].col[6]))
            }
        }else{
            for(i=0;i<rows.length;i++){
                if(r.idsSelected.indexOf(parseInt(rows[i].col[0]))>=0){
                    //uLogView.showLog('id: '+rows[i].col[0])
                    lm.append(lm.addDato(rows[i].col[0], rows[i].col[1], rows[i].col[2], rows[i].col[3], rows[i].col[4], rows[i].col[5], rows[i].col[6]))
                }
            }
            for(i=0;i<rows.length;i++){
                if(r.idsSelected.indexOf(parseInt(rows[i].col[0]))<0){
                    lm.append(lm.addDato(rows[i].col[0], rows[i].col[1], rows[i].col[2], rows[i].col[3], rows[i].col[4], rows[i].col[5], rows[i].col[6]))
                }
            }
        }
    }
    function deleteRows(){
        //        for(var i=0;i<lv.children[0].children.length; i++){
        //            let id=lv.children[0].children[i].rowId
        //            //uLogView.showLog('s: '+lv.children[0].children[i].selected)
        //            if(id&&lv.children[0].children[i].selected){
        //                let sql='delete from '+app.tableName1+' where id='+id
        //                unik.sqlQuery(sql)
        //            }
        //        }
        botModify.visible=false
        for(var i=0;i<lm.count; i++){
            let id=lm.get(i).v1
            //uLogView.showLog('s: '+lv.children[0].children[i].selected)
            if(lm.get(i).v7){
                let sql='delete from '+app.tableName1+' where id='+id
                unik.sqlQuery(sql)
            }
        }
        botDelete.visible=false
        //search()
    }
    function setCbs(){
        cbSelectedAll.checked=selectedAll
        if(!cbSelectedAll.setearTodos&&!selectedAll){
            cbSelectedAll.setearTodos=true
            return
        }
        for(var i=0;i<lm.count+1; i++){
            if(lv.children[0].children[i]){
                lv.children[0].children[i].selected=selectedAll
            }
        }
    }
    function setBtnDeleteText(){
        //uLogView.showLog('setBtnDeleteText()')
        let cantSel=0
        for(var i=0;i<lm.count; i++){
            if(lm.get(i).v7){
                cantSel++
            }
        }
        if(cantSel===0){
            botDelete.visible=false
        }else  if(cantSel===1){
            botDelete.text='Eliminar Registro'
            botDelete.visible=true
        }else{
            botDelete.text='Eliminar '+cantSel +' Registros'
            botDelete.visible=true
        }
        if(cantSel===1){
            botModify.visible=true
        }else{
            botModify.visible=false
        }
        //uLogView.showLog('Cantidad: '+cantSel)
    }
    function modifyRow(){
        for(var i=0;i<lm.count; i++){
            if(lm.get(i).v7){
                //xFormInsert.modificando=true
                //xFormInsert.loadModify(lm.get(i).v1, lm.get(i).v2, lm.get(i).v3, lm.get(i).v4, lm.get(i).v5,  lm.get(i).v6,  lm.get(i).v8)
                break
            }
        }
        r.idsSelected=[]
    }

    function upRow(){
        if(lv.currentIndex===0){
            lv.contentY=lm.count*app.fs*2-lv.height
        }
        if(lv.currentIndex>0){
            lv.currentIndex--
        }else{
            lv.currentIndex=lm.count-1
        }
    }
    function downRow(){
        if(tiSearch.focus){
            tiSearch.focus=false
            tiSearch.textInput.focus=false
            lv.focus=true
            return
        }
        lv.focus=true
        if(lv.currentIndex===lm.count-1){
            lv.contentY=0
        }
        if(lv.currentIndex<lm.count-1){
            lv.currentIndex++
        }else{
            lv.currentIndex=0
        }
    }
    function atras(){
        if(tiSearch.textInput.focus){
            lv.focus=true
            return true
        }
        return false
    }

    function getSearch(consulta){
        lm.clear()
        let url=app.serverUrl+':'+app.portRequest+'/ppres/searchproducto?consulta='+consulta
        console.log('Get '+app.moduleName+' server from '+url)
        var req = new XMLHttpRequest();
        req.open('GET', url, true);
        req.onreadystatechange = function (aEvt) {
            if (req.readyState === 4) {
                if(req.status === 200){
                    let json=JSON.parse(req.responseText)
                    //console.log(req.responseText)
                    setSearchResult(json)
                }else{
                    console.log("Error el cargar el servidor de Mercurio. Code 1\n");
                }
            }
        };
        req.send(null);
    }
    function setSearchResult(json){
        for(var i=0;i<Object.keys(json.productos).length;i++){
            //Rows 'descripcion', 'codigo', 'precioinstalacion', 'precioabono', 'adicionalriesgo', 'observaciones'
            //                console.log('P1'+i+': '+json.productos[i].descripcion)
            //                console.log('P2'+i+': '+json.productos[i].codigo)
            //                console.log('P3'+i+': '+json.productos[i].precioinstalacion)
            //                console.log('P4'+i+': '+json.productos[i].precioabono)
            //                console.log('P5'+i+': '+json.productos[i].adicionalriesgo)
            //                console.log('P6'+i+': '+json.productos[i].observaciones)
            //return
            let existe=false
            let cant=0
            /*for(var i2=0;i2<xGetPres.list.listModel.count;i2++){
                //console.log('RS --> numId:['+xGetPres.list.listModel.get(i2).numId+'] id:['+json.productos[i]._id+']')
                if(xGetPres.list.listModel.get(i2).numId===json.productos[i]._id){
                    existe=true
                    cant=xGetPres.list.listModel.get(i2).cant
                    break
                }
            }*/
            //console.log('Producto id: '+ json.productos[i]._id)
            lm.append(lm.addDato(
                          json.productos[i]._id,
                          json.productos[i].descripcion,
                          json.productos[i].codigo,
                          json.productos[i].precioinstalacion,
                          json.productos[i].precioabono,
                          json.productos[i].adicionalriesgo,
                          json.productos[i].observaciones
                          ))

        }
        //xListProdSearch.focus=true
    }
}
