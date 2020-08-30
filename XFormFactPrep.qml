import QtQuick 2.0

Item {
    id: r
    width: parent.width-app.fs
    property bool buscando: false
    property string currentTableName: ''
    property var prods: []
    onVisibleChanged: {
        tiSearch.focus=visible
    }
    Timer{
        running: r.visible
        repeat: true
        interval: 500
        onTriggered: {
            prodCount.text=r.prods.length!==0?'Ya hay '+r.prods.length+' productos.':'Factura sin productos.'
        }
    }
//    Rectangle{
//        anchors.fill: r
//        color: 'transparent'
//        border.width: 1
//        border.color: app.c2
//    }
    Column{
        width: parent.width-app.fs
        height: parent.height
        spacing: app.fs*0.5
        anchors.horizontalCenter: parent.horizontalCenter
        Row{
            spacing: app.fs*3
            UText{
                id: prodCount;
                text: r.prods.length!==0?'Ya hay '+r.prods.length+' productos.':'Factura sin productos.'; font.pixelSize: app.fs
                anchors.verticalCenter: parent.verticalCenter
            }
            BotonUX{
                text: 'Vista Previa'
                onClicked: {
                    r.parent.prods=r.prods
                    r.parent.setFactData()
                    r.parent.mod=1
                }
            }
            //UText{text: 'Buscando en la planilla '+r.currentTableName; font.pixelSize: app.fs}
        }
        Row{
            spacing: app.fs*0.5
            anchors.horizontalCenter: parent.horizontalCenter
            UTextInput{
                id: tiSearch
                label: 'Buscar:'
                width: app.fs*18
                KeyNavigation.tab: lv
                onTextChanged: {
                    r.buscando=true
                    lv.currentIndex=0
                    if(text===''){
                        lm.clear()
                        return
                    }
                    search()
                }
            }
            Rectangle{
                width: rowRB.width+app.fs
                height: app.fs*2
                anchors.verticalCenter: parent.verticalCenter
                border.width: unikSettings.borderWidth
                border.color: app.c1
                radius: app.fs*0.25
                color: 'transparent'
                Row{
                    id: rowRB
                    spacing: app.fs*0.5
                    anchors.verticalCenter: parent.verticalCenter
                    UText{text: '<b>Buscar por:</b>';anchors.verticalCenter: parent.verticalCenter}
                    URadioButton{
                        id: rbCod
                        text: 'Código'
                        checked: true
                        d: app.fs*1.4
                        onCheckedChanged: search()
                    }
                    URadioButton{
                        id: rbDes
                        text: 'Descripción'
                        d: app.fs*1.4
                        onCheckedChanged: search()
                    }
                }

            }
            BotonUX{
                id: botSearch
                text: 'Buscar'
                height: app.fs*2
            }
        }
        UText{id: cant}
        ListView{
            id: lv
            model: lm
            delegate: del
            spacing: app.fs*0.5
            width: parent.width
            height: r.height-tiSearch.height-app.fs*2-cant.height
            clip: true
            onFocusChanged: currentIndex=1
            KeyNavigation.tab: tiSearch
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
                function addProd(pid, pcod, pdes, pcos, pven, pstock, pgan){
                    return{
                        vpid: pid,
                        vpcod: pcod,
                        vpdes: pdes,
                        vpcos:pcos,
                        vpven: pven,
                        vpstock: pstock,
                        vpgan: pgan
                    }
                }
            }
            Component{
                id: del
                Rectangle{
                    id: xProd
                    width: parent.width
                    height: txt.contentHeight+app.fs
                    radius: app.fs*0.1
                    border.width: 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: parseInt(vpid)!==-10&&index!==lv.currentIndex?app.c1:app.c2
                    property bool agregado: false
                    UText{
                        id: txt
                        color:parseInt(vpid)!==-10&&index!==lv.currentIndex?app.c2:app.c1
                        font.pixelSize: app.fs
                        text: parseInt(vpid)!==-10? '<b style="font-size:'+app.fs+'px;">Código: </b><span style="font-size:'+app.fs+'px;">'+vpcod+'</span><br /><br /><b  style="font-size:'+app.fs*1.4+'px;">Descripción: </b><span style="font-size:'+app.fs+'px;">'+vpdes+'</span><br /><br /><b style="font-size:'+app.fs+'px;">Precio de Costo: </b> <span style="font-size:'+app.fs+'px;">$'+vpcos+'</span><br><b style="font-size:'+app.fs+'px;">Precio de Venta: </b> <span style="font-size:'+app.fs+'px;">$'+vpven+'</span><br /><b>Cantidad en Stock: </b>'+vpstock+'<br /><b>Ganancia: </b>'+vpgan:(tiSearch.text==='*'?'Mostrando todos los productos':'<b>Resultados por código:</b> '+tiSearch.text)
                        textFormat: Text.RichText
                        width: parent.width-app.fs
                        wrapMode: Text.WordWrap
                        anchors.centerIn: parent
                    }
                    Row{
                        spacing: app.fs
                        visible: index===lv.currentIndex&&parseInt(vpid)!==-10&&!xProd.agregado
                        anchors.right: parent.right
                        anchors.rightMargin: app.fs*0.5
                        anchors.top: parent.top
                        anchors.topMargin: app.fs*0.5
                        onVisibleChanged: {
                            tiCant.focus=visible
                            if(visible){
                                tiCant.textInput.selectAll()
                            }
                        }
                        UTextInput{
                            id:tiCant
                            label: 'Cantidad: '
                            text: '0'
                            maximumLength:10
                            width: app.fs*10
                            fontColor:app.c1
                            regularExp: RegExpValidator{regExp: /^([0-9])*$/}
                            KeyNavigation.tab: tiDto
                        }
                        UTextInput{
                            id:tiDto
                            label: 'Descuento: %'
                            text: '0'
                            maximumLength:3
                            width: app.fs*10
                            fontColor:app.c1
                            regularExp: RegExpValidator{regExp: /^([0-9])*$/}
                            KeyNavigation.tab: botAgregarProd
                        }
                        BotonUX{
                            id: botAgregarProd
                            text: 'Agregar'
                            height: app.fs*2
                            fontColor: app.c2
                            bg.color: app.c1
                            glow.radius: 2
                            KeyNavigation.tab: tiCant
                            Keys.onReturnPressed: clicked()
                            onClicked: {
                                let msg=''
                                if(parseInt(tiCant.text)<=0){
                                    msg='Error en la cantidad. Definir una cantidad válida.'
                                    unik.speak(msg)
                                    return
                                }
                                let obj={}
                                obj.cod=vpcod
                                obj.des=vpdes
                                obj.cos=vpcos
                                obj.ven=vpven
                                obj.gan=vpgan
                                obj.cant=parseInt(tiCant.text)
                                obj.dto=parseInt(tiDto.text)
                                r.prods.push(obj)
                                xProd.agregado=true
                                msg=(parseInt(tiCant.text)===1?'Se ha':'Se han')+' agregado '+tiCant.text+' '+(parseInt(tiCant.text)===1?'producto':'productos')+' del código '+vpcod+' a la factura.'
                                unik.speak(msg)
                                //uLogView.showLog('Msg: '+msg)
                                //uLogView.showLog('Cant Prods: '+r.prods.length)
                            }
                        }
                    }
                    Row{
                        spacing: app.fs
                        visible: index===lv.currentIndex&&parseInt(vpid)!==-10&&xProd.agregado
                        anchors.right: parent.right
                        anchors.rightMargin: app.fs*0.5
                        anchors.top: parent.top
                        anchors.topMargin: app.fs*0.5
                        onVisibleChanged: {
                            botQuitar.focus=visible
                        }
                        BotonUX{
                            id: botQuitar
                            text: 'Quitar de la Factura'
                            height: app.fs*2
                            fontColor: app.c2
                            bg.color: app.c1
                            glow.radius: 2
                            Keys.onReturnPressed: clicked()
                            onClicked: {
                                let noProds=[]
                                for(let i=0;i<r.prods.length;i++){
                                    if(r.prods[i].cod!==vpcod){
                                        noProds.push(r.prods[i])
                                    }
                                }
                                r.prods=noProds
                                xProd.agregado=false
                                /*let msg=''
                                if(parseInt(tiCant.text)<=0){
                                    msg='Error en la cantidad. Definir una cantidad válida.'
                                    unik.speak(msg)
                                    return
                                }
                                let obj={}
                                obj.cod=vpcod
                                obj.des=vpdes
                                obj.cos=vpcos
                                obj.ven=vpven
                                obj.gan=vpgan
                                obj.cant=parseInt(tiCant.text)
                                r.prods.push(obj)
                                xProd.agregado=true
                                msg=(parseInt(tiCant.text)===1?'Se ha':'Se han')+' agregado '+tiCant.text+' '+(parseInt(tiCant.text)===1?'producto':'productos')+' del código '+vpcod+' a la factura.'
                                unik.speak(msg)*/
                                //uLogView.showLog('Msg: '+msg)
                                //uLogView.showLog('Cant Prods: '+r.prods.length)
                            }
                        }
                    }
                    Component.onCompleted: {
                        for(let i=0;i<r.prods.length;i++){
                            if(r.prods[i].cod===vpcod){
                                xProd.agregado=true
                            }
                        }
                    }
                }
            }
        }
    }
    function search(){
        if(!buscando)return
        lm.clear()

        let colSearch=''
        if(rbCod.checked){
            colSearch='cod'
        }else{
            colSearch='des'
        }

        var p1=tiSearch.text!=='*'?tiSearch.text.split(' '):('').split(' ')
        lm.append(lm.addProd('-10', tiSearch.text, '', '','','',''))
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
        var sql='select distinct * from productos where '+b+''
        console.log('Sql: '+sql)

        var rows=unik.getSqlData(sql)
        //console.log('Sql count result: '+rows.length)
        cant.text='Resultados: '+rows.length
        for(i=0;i<rows.length;i++){
            lm.append(lm.addProd(rows[i].col[0], rows[i].col[1], rows[i].col[2], rows[i].col[3], rows[i].col[4], rows[i].col[5], rows[i].col[6]))
        }

        b=''
        for(var i=0;i<p1.length-1;i++){
            /*if(i===0){
                b+='nombre like \'%'+p1[i]+'%\' '
            }else{
                b+='or nombre like \'%'+p1[i]+'%\' '
            }*/
            lm.append(lm.addProd('-10', p1[i], '', '','','',''))
            sql='select distinct * from productos where '+colSearch+' like \'%'+p1[i]+'%\''
            console.log('Sql 2: '+sql)
            var rows2=unik.getSqlData(sql)
            //console.log('Sql count result: '+rows.length)
            //cant.text='Resultados: '+parseInt(rows.length+rows2.length)
            for(var i2=0;i2<rows2.length;i2++){
                lm.append(lm.addProd(rows2[i2].col[0], rows2[i2].col[1], rows2[i2].col[2], rows2[i2].col[3], rows2[i2].col[4], rows2[i].col[5], rows2[i].col[6]))
            }
        }
    }
}
