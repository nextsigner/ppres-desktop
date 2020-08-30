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
            search()
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
                label: rbCod.checked?'Buscar Folio:':'Buscar Nombre:'
                width: app.fs*18            
                KeyNavigation.down: lv
                KeyNavigation.tab: lv
                itemNextFocus: lv
                onTextChanged: {
                    r.buscando=true
                    //lv.currentIndex=0
                    search()
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
                model: app.colsNameCertificados
                currentIndex: app.colsNameCertificados.indexOf(usFormSearch.searchBy)
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
                property var anchos: [0.05,0.1, 0.25,0.4,0.1,0.1]
                property string fontColor: app.c1
                Row{
                    anchors.centerIn: parent
                    Rectangle{
                        width: xRowTitDes.width*xRowTitDes.anchos[0]
                        height:xRowTitDes.height
                        border.width: 2
                        border.color: app.c2
                        color: app.c1
                        CheckBox{
                            id: cbSelectedAll
                            anchors.centerIn: parent
                            property bool setearTodos: true
                            onClicked: cbSelectedAll.setearTodos=true
                            onCheckedChanged: {
                                //r.selectedAll=checked
                                if(!setearTodos){
                                    cbSelectedAll.setearTodos=true
                                    setBtnDeleteText()
                                    return
                                }
                                for(var i=0;i<lm.count; i++){
                                    lm.get(i).v7=checked
                                }
                                setBtnDeleteText()
                            }
                        }
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                cbSelectedAll.checked=!cbSelectedAll.checked
                                r.idsSelected=[]
                                search()
                                /*if(!cbSelectedAll.checked){

                                }else{
                                    r.idsSelected=[]
                                    cbSelToTop.checked=false
                                }*/
                                for(var i=0;i<lm.count; i++){
                                    lm.get(i).v7=cbSelectedAll.checked
                                }
                                setBtnDeleteText()
                            }
                        }
                    }
                    Repeater{
                        model: app.colsNameCertificados
                        Rectangle{
                            width: xRowTitDes.width*xRowTitDes.anchos[index+1]
                            height:xRowTitDes.height
                            border.width: 2
                            border.color: app.c4
                            color: app.c2
                            UText{
                                text: '<b>'+(''+app.colsNameCertificados[index]).replace(/ /g, '<br />')+'</b>'
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
                    usFormSearch.uCurrentIndex=currentIndex
                }
                ListModel{
                    id: lm
                    function addDato(p1, p2, p3, p4, p5, p6, p7){
                        return{
                            v1: p1,
                            v2: p2,
                            v3: p3,
                            v4:p4,
                            v5: p5,
                            v6: p6,
                            v7: false,
                            v8: p7
                        }
                    }
                }
                Component{
                    id: delPorCod
                    Rectangle{
                        id:xRowDes
                        width: parent.width
                        height: app.fs*2//parseInt(v1)!==-10?app.fs*2:app.fs*3
                        radius: app.fs*0.1
                        border.width: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: cbRow.checked?app.c1:app.c2
                        property string fontColor: cbRow.checked?app.c1:app.c2
                        property var arrayModeloDatos: [v2, v3, v4, v5, v6]//[v2, v3, v4, v5, v6]
                        property bool selected:v7//r.idsSelected.length>0?parseInt(idsSelected.indexOf(v1)+1):v7
                        property int rowId: v1
                        Keys.onDownPressed: downRow()
                        Keys.onUpPressed: upRow()
                        Keys.onSpacePressed: {
                            lv.currentIndex=index
                            cbRow.checked=!cbRow.checked
                            if(cbSelToTop.checked){
                                search()
                            }
                            //uLogView.showLog('Spacing'+index)
                        }
                        onSelectedChanged: {
                            cbRow.checked=selected
                        }
                        MouseArea{
                            anchors.fill: parent
                            onDoubleClicked: xFormInsert.loadModify(v1, v2, v3, v4, v5, v6, v8)
                        }
                        Row{
                            anchors.centerIn: parent
                            Rectangle{
                                width: xRowDes.width*xRowTitDes.anchos[0]
                                height:xRowDes.height
                                border.width: 2
                                border.color: app.c2
                                color:app.c1
                                CheckBox{
                                    id: cbRow
                                    checked: xRowDes.selected
                                    anchors.centerIn: parent
                                    onCheckedChanged: {
                                        if(!checked){
                                            cbSelectedAll.setearTodos=false
                                            cbSelectedAll.checked=false
                                            //r.selectedAll=false
                                        }
                                        v7=checked
                                        setBtnDeleteText()
                                        if(!tiSearch.textInput.focus){
                                            lv.focus=true
                                        }
                                        let allSelected=true
                                        for(var i=0;i<lm.count; i++){
                                            if(!lm.get(i).v7){
                                                allSelected=false
                                                break
                                            }
                                        }
                                        if(allSelected){
                                            cbSelectedAll.setearTodos=false
                                            cbSelectedAll.checked=allSelected
                                        }
                                        if(checked){
                                            if(r.idsSelected.indexOf(parseInt(v1))<0){
                                                r.idsSelected.push(parseInt(v1))
                                            }
                                        }else{
                                            r.idsSelected = JS.removeItemFromArr(r.idsSelected, parseInt(v1))
                                        }
                                        //cant.text=r.idsSelected.toString()

                                    }
                                    Timer{
                                        id: tSearchSelToTop
                                        running: false
                                        repeat: false
                                        interval: 500
                                        onTriggered: search()
                                    }
                                    MouseArea{
                                        anchors.fill: parent
                                        onDoubleClicked: {
                                            lv.currentIndex=index
                                            setBtnDeleteText()
                                        }
                                        onClicked: {
                                            cbRow.checked=!cbRow.checked
                                            if(cbSelToTop.checked){
                                                search()
                                            }
                                            setBtnDeleteText()
                                        }
                                    }
                                    Rectangle{
                                        anchors.centerIn: parent
                                        width: parent.contentItem.width
                                        height: parent.contentItem.height
                                        border.width: 3
                                        border.color: 'red'
                                        color: 'transparent'
                                        visible: index===lv.currentIndex
                                        z:parent.z+100000
                                        onVisibleChanged: {
                                            if(visible)lv.currentIndex=index
                                        }
                                    }
                                }
                            }
                            Repeater{
                                model: app.colsNameCertificados
                                Rectangle{
                                    width: xRowDes.width*xRowTitDes.anchos[index+1]
                                    height:xRowDes.height
                                    border.width: 2
                                    border.color:cbRow.checked?app.c1:app.c2
                                    color: cbRow.checked?app.c2:app.c1
                                    clip: true
                                    UText{
                                        id: txtCelda
                                        text: xRowDes.arrayModeloDatos[index]
                                        anchors.centerIn: parent
                                        color: xRowDes.fontColor
                                        horizontalAlignment: Text.AlignHCenter
                                        //color: index===3||index===4?'red':'blue'
                                        visible: false
                                        Component.onCompleted: {
                                            if(index===3||index===4){
                                                let d=new Date(parseInt(xRowDes.arrayModeloDatos[index]))
                                                let dia=''+d.getDate()
                                                if(d.getDate()<10){
                                                    dia='0'+dia
                                                }
                                                let mes=''+parseInt(d.getMonth()+1)
                                                if(d.getMonth()+1<10){
                                                    mes='0'+mes
                                                }
                                                let an=''+d.getFullYear()
                                                let s=''+dia+'/'+mes+'/'+an
                                                text=s
                                            }
                                            visible=true
                                        }
                                    }
                                }
                            }
                        }
                        //                        UText{
                        //                            text: '<b>'+parseInt(index +1)+'</b>'
                        //                            font.pixelSize: app.fs*0.6
                        //                            color: 'red'
                        //                            anchors.verticalCenter: parent.verticalCenter
                        //                            anchors.left: parent.left
                        //                            anchors.leftMargin: app.fs*0.5
                        //                        }
                        Component.onCompleted: {
                            if(idsSelected.indexOf(parseInt(v1))>=0){
                                xRowDes.selected=true
                            }else{
                                cbSelectedAll.setearTodos=false
                                cbSelectedAll.checked=false
                            }
                        }
                    }
                }
            }
        }
    }
    //        UText{
    //            text: 'INDEX: '+lv.focus+' '+lv.currentIndex+' Cant: '+lm.count
    //            font.pixelSize: app.fs*2
    //            color: 'red'
    //        }
    Component.onCompleted: {
        if(r.visible){
            search()
            lv.focus=true
            //tiSearch.focus=true
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
        search()
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
                xFormInsert.modificando=true
                xFormInsert.loadModify(lm.get(i).v1, lm.get(i).v2, lm.get(i).v3, lm.get(i).v4, lm.get(i).v5,  lm.get(i).v6,  lm.get(i).v8)
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
}
