import QtQuick 2.0

Rectangle{
    id: r
    width: parent.width
    height: parent.height
    color: app.c1
    property int numFact: -1
    Flickable{
        id: flickablePages
        width: itemPDF.width
        height: itemPDF.height
        contentWidth: itemPDF.width
        contentHeight: itemPDF.height*1.98
        //visible: r.mod===1
        Rectangle{
            id: itemPDF
            width: 2480*0.5
            height:colPdfPages.height//3508*0.5
            Column{
                id: colPdfPages
                spacing: 5
            }
        }

        //        BotonUX{
        //            text: 'Print'
        //            onClicked: {
        //                //itemToImage(itemPDF)
        //                setFactData()
        //            }
        //        }
    }
    BotonUX{
        text: 'Atras'
        onClicked: {
            r.visible=false
        }
    }
    property int printMarginTop: 60
    property int fontSize: 16
    property int hRows: 30
    property var colsWidth: [0.07, 0.52, 0.10, 0.10, 0.06,0.15]
    Component{
        id: compPdfPage
        Rectangle{
            id: pdfPage
            width: 2480*0.5
            height:3508*0.5+1
            //color: '#ff8833'
            border.width: 1
            property int cabHeight: 0
            property var prods: []
            Component.onCompleted: {
                let totalFact=0.00
                let comp=compCabFact
                let obj=comp.createObject(pdfPage, {})

                let compRCT=compRowCabTabla
                let objRCT=compRCT.createObject(pdfPage, {})
                objRCT.y=objRCT.parent.cabHeight+r.printMarginTop+r.hRows

                let yr=objRCT.height+objRCT.y
                for(let i=0;i<prods.length;i++){
                    //uLogView.showLog('cod: '+prods[0].cod)
                    let compRT=compRowTabla
                    let objProdRT={}
                    objProdRT.y=yr
                    objProdRT.cod=prods[i].cod
                    objProdRT.des=prods[i].des
                    objProdRT.cant=prods[i].cant
                    objProdRT.prec=prods[i].prec
                    objProdRT.dto=prods[i].dto

                    let totalSinDto=parseFloat(prods[i].prec*prods[i].cant).toFixed(2)
                    let vdto=totalSinDto / 100 * parseInt(prods[i].dto)
                    let totalConDto=parseFloat(totalSinDto-vdto).toFixed(2)
                    //                    totalFact=parseFloat(totalFact + totalConDto).toFixed(2)
                    //                    uLogView.showLog('TF: '+totalSinDto)
                    //                    uLogView.showLog('TF2: '+vdto)
                    //                    uLogView.showLog('TF3: '+totalConDto)
                    //                    uLogView.showLog('TF4: '+totalFact)

                    let objRT=compRT.createObject(pdfPage, objProdRT)
                    yr+=r.hRows
                }

                let compRPT=compRowPieTablaTotal
                let objRPT=compRPT.createObject(pdfPage, {total: totalFact})
            }
            function abort(){
                for(var i=0;i<compPdfPage.children.length;i++){
                    compPdfPage.children[i].destroy(10)
                }
                compPdfPage.destroy(10)
            }
        }
    }
    Component{
        id: compCabFact
        Rectangle{
            id: xCabFact
            width: parent.width*0.8
            height: colCabFact.height
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: r.printMarginTop
            property int hRows: 30
            property int horSpacing: 30
            property string fecha: '00/00/000'
            property string srs: 'Salta'
            property string domicilio: 'Rodney 5561 Gregorio de Laferrere'
            property string cuit: '30-18546365-3'
            Column{
                id: colCabFact
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                Row{
                    spacing: xCabFact.horSpacing
                    anchors.horizontalCenter: parent.horizontalCenter
                    Rectangle{
                        width:xCabFact.width*0.33-xCabFact.horSpacing*0.5
                        height: xCabFact.hRows*1.5
                        color: '#888'
                        border.width: 1
                        radius: 6
                        UText{
                            text: '<b>Presupuesto</b> '
                            font.pixelSize: r.fontSize*1.5
                            anchors.centerIn: parent
                            color: 'white'
                        }
                    }
                    Rectangle{
                        id: xTiNumFact
                        width: xCabFact.width*0.33-xCabFact.horSpacing*0.5
                        height: xCabFact.hRows*1.5
                        color: '#888'
                        border.width: 1
                        radius: 6
                        property bool editing: false
                        MouseArea{
                            anchors.fill: parent
                            onClicked: parent.editing=true
                        }
                        UText{
                            text: '<b>Boleta N°: </b>'+tiNumBol.text
                            font.pixelSize: r.fontSize*1.5
                            color: 'white'
                            anchors.centerIn: parent
                            visible: !parent.editing
                        }
                        UTextInput{
                            id: tiNumBol
                            text: r.numFact
                            label: '<b>Boleta N°: </b>'
                            fontColor: 'white'
                            width: parent.width-app.fs*3
                            maximumLength: 10
                            fontSize: app.fs*1.3
                            textInputContainer.border.color: 'transparent'
                            anchors.centerIn: parent
                            visible: parent.editing
                            onVisibleChanged: {
                                focus=visible
                                if(visible)textInput.selectAll()
                            }
                            onSeted:  {
                                parent.editing=false
                                let sql = 'select * from facts where id='+text
                                let rows=unik.getSqlData(sql)
                                //uLogView.showLog('Rows: '+rows.length+' text: '+text)
                                if(rows.length>0){
                                    let d = new Date(parseInt(rows[0].col[1]))
                                    let dia=''+d.getDate()
                                    let mes=''+parseInt(d.getMonth()+1)
                                    let anio=(''+d.getYear()).split('')

                                    if(dia.length===1){
                                        dia='0'+dia
                                    }
                                    if(mes.length===1){
                                        mes='0'+mes
                                    }
                                    let anioCorr=anio[anio.length-2]+anio[anio.length-1]
                                    xCabFact.fecha=''+dia+'/'+mes+'/'+anioCorr
                                }

                            }
                        }

                    }
                    Rectangle{
                        width:xCabFact.width*0.33-xCabFact.horSpacing*0.5
                        height: xCabFact.hRows*1.5
                        color: '#888'
                        border.width: 1
                        radius: 6
                        UText{
                            id: txtFecha
                            text: '<b>Fecha:</b> '+xCabFact.fecha;
                            font.pixelSize: r.fontSize*1.5
                            color: 'white'
                            anchors.centerIn: parent
                        }
                    }
                }
                Row{
                    spacing: xCabFact.horSpacing
                    anchors.horizontalCenter: parent.horizontalCenter
                    Item{
                        width: xCabFact.width*0.5-xCabFact.horSpacing*0.5
                        height: 30
                        Row{
                            spacing: app.fs
                            UTextInput{
                                id: tiCodCliente
                                label: '<b>Código de Cliente: </b>'
                                fontColor: 'black'
                                fontSize: r.fontSize
                                textInputContainer.border.color: 'transparent'
                                width: app.fs*16
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            UText{
                                id: txtCliNombre
                                text: '<b>Señor/s: </b>'+xCabFact.srs
                                color: 'black'
                                font.pixelSize: r.fontSize
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        Rectangle{
                            width: parent.width
                            height: 2
                            color: 'black'
                            anchors.bottom: parent.bottom
                        }
                    }
                    Item{
                        width: xCabFact.width*0.5-xCabFact.horSpacing*0.5
                        height: 30
                        UText{
                            id: txtCliEMail
                            text: '<b>E-Mail: </b>'
                            color: 'black'
                            font.pixelSize: r.fontSize
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Rectangle{
                            width: parent.width
                            height: 2
                            color: 'black'
                            anchors.bottom: parent.bottom
                        }
                    }
                }
                Row{
                    spacing: xCabFact.horSpacing
                    anchors.horizontalCenter: parent.horizontalCenter
                    Item{
                        width: xCabFact.width*0.5-xCabFact.horSpacing*0.5
                        height: 30
                        UText{
                            id: txtCliDomicilio
                            text: '<b>Domicilio: </b>'+xCabFact.domicilio
                            color: 'black'
                            font.pixelSize: r.fontSize
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Rectangle{
                            width: parent.width
                            height: 2
                            color: 'black'
                            anchors.bottom: parent.bottom
                        }
                    }
                    Item{
                        width: xCabFact.width*0.5-xCabFact.horSpacing*0.5
                        height: 30
                        UText{
                            id: txtCliCuit
                            text: '<b>CUIT: </b>'+xCabFact.cuit
                            color: 'black'
                            font.pixelSize: r.fontSize
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Rectangle{
                            width: parent.width
                            height: 2
                            color: 'black'
                            anchors.bottom: parent.bottom
                        }
                    }
                }
                Item{
                    width: xCabFact.width
                    height: 30
                    UText{
                        text: '<b>Condiciones: </b>'
                        color: 'black'
                        font.pixelSize: r.fontSize
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Rectangle{
                        width: parent.width
                        height: 2
                        color: 'black'
                        anchors.bottom: parent.bottom
                    }
                }
            }
            Component.onCompleted: {
                parent.cabHeight=height
                if(r.numFact===-1)xTiNumFact.editing=true
            }
        }
    }
    Component{
        id: compRowCabTabla
        Item{
            id: xRowCabTabla
            width: parent.width*0.8
            height: r.hRows*1.5
            anchors.horizontalCenter: parent.horizontalCenter
            Rectangle{
                width: parent.width
                height: parent.height
                clip: true
                Row{
                    Rectangle{
                        width: xRowCabTabla.width*r.colsWidth[0]
                        height: r.hRows*1.5+10
                        border.width: 2
                        radius: 10
                        UText{
                            text: 'Código'
                            font.pixelSize: r.fontSize
                            color: 'black'
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -5
                        }
                    }
                    Item{
                        width: xRowCabTabla.width*r.colsWidth[1]
                        height: r.hRows*1.5+10
                        Rectangle{
                            width: parent.width+6
                            height: parent.height
                            border.width: 2
                            radius: 10
                            x:-2
                            UText{
                                text: 'Descripción'
                                font.pixelSize: r.fontSize
                                color: 'black'
                                anchors.centerIn: parent
                                anchors.verticalCenterOffset: -5
                            }
                        }
                    }
                    Rectangle{
                        width: xRowCabTabla.width*r.colsWidth[2]
                        height: r.hRows*1.5+10
                        border.width: 2
                        radius: 10
                        UText{
                            text: 'Cantidad'
                            font.pixelSize: r.fontSize
                            color: 'black'
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -5
                        }
                    }
                    Item{
                        width: xRowCabTabla.width*r.colsWidth[3]
                        height: r.hRows*1.5+10
                        Rectangle{
                            width: parent.width+6
                            height: parent.height
                            border.width: 2
                            radius: 10
                            x:-2
                            UText{
                                text: 'Precio\nUnitario'
                                font.pixelSize: r.fontSize
                                color: 'black'
                                anchors.centerIn: parent
                                horizontalAlignment: Text.AlignHCenter
                                anchors.verticalCenterOffset: -5
                            }
                        }
                    }
                    Item{
                        width: xRowCabTabla.width*r.colsWidth[4]
                        height: r.hRows*1.5+10
                        Rectangle{
                            width: parent.width+6
                            height: parent.height
                            border.width: 2
                            radius: 10
                            x:-2
                            UText{
                                text: '% Dto.'
                                font.pixelSize: r.fontSize
                                color: 'black'
                                anchors.centerIn: parent
                                horizontalAlignment: Text.AlignHCenter
                                anchors.verticalCenterOffset: -5
                            }
                        }
                    }
                    Rectangle{
                        width: xRowCabTabla.width*r.colsWidth[5]
                        height: r.hRows*1.5+10
                        border.width: 2
                        radius: 10
                        UText{
                            text: 'Total'
                            font.pixelSize: r.fontSize
                            color: 'black'
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -5
                        }
                    }
                }
                Rectangle{
                    width: xRowCabTabla.width
                    height: 2
                    color: 'black'
                    anchors.bottom: parent.bottom
                }
            }
            Rectangle{
                width: 2
                height: xRowCabTabla.parent.height-xRowCabTabla.parent.cabHeight*2-parent.height
                color: 'black'
                anchors.top: parent.bottom
            }
            Row{
                anchors.top: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                Repeater{
                    model: 6
                    Item{
                        width: xRowCabTabla.width*r.colsWidth[index]
                        height: xRowCabTabla.parent.height-xRowCabTabla.parent.cabHeight*2-parent.parent.height
                        Rectangle{
                            width: 2
                            height: parent.height
                            color: 'black'
                            anchors.right: parent.right
                            Component.onCompleted: {
                                if(index===1){
                                    anchors.rightMargin=-2
                                }
                                if(index===4){
                                    anchors.rightMargin=-2
                                }
                            }
                        }

                    }
                }
                Component.onCompleted: {

                }
            }
        }
    }
    Component{
        id: compRowTabla
        Item{
            id: xRowTabla
            width: parent.width*0.8
            height: r.hRows
            anchors.horizontalCenter: parent.horizontalCenter
            property string cod: '000000'
            property string des: 'abc'
            property int cant: 0
            property int dto: 0
            property real prec: 0
            Item{
                width: parent.width
                height: parent.height
                clip: true
                Row{
                    Item{
                        width: xRowTabla.width*r.colsWidth[0]
                        height: r.hRows
                        UText{
                            text: xRowTabla.cod
                            font.pixelSize: r.fontSize
                            color: 'black'
                            anchors.centerIn: parent
                        }
                    }
                    Item{
                        width: xRowTabla.width*r.colsWidth[1]
                        height: r.hRows
                        Item{
                            width: parent.width+6
                            height: parent.height
                            x:-2
                            UText{
                                text: xRowTabla.des
                                font.pixelSize: r.fontSize
                                color: 'black'
                                anchors.centerIn: parent
                            }
                        }
                    }
                    Item{
                        width: xRowTabla.width*r.colsWidth[2]
                        height: r.hRows
                        UText{
                            text: xRowTabla.cant
                            font.pixelSize: r.fontSize
                            color: 'black'
                            anchors.centerIn: parent
                        }
                    }
                    Item{
                        width: xRowTabla.width*r.colsWidth[3]
                        height: r.hRows
                        Item{
                            width: parent.width+6
                            height: parent.height
                            x:-2
                            UText{
                                text: xRowTabla.prec
                                font.pixelSize: r.fontSize
                                color: 'black'
                                anchors.centerIn: parent
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                    Item{
                        width: xRowTabla.width*r.colsWidth[4]
                        height: r.hRows
                        UText{
                            text: '%'+xRowTabla.dto
                            font.pixelSize: r.fontSize
                            color: 'black'
                            anchors.centerIn: parent
                        }
                    }
                    Item{
                        width: xRowTabla.width*r.colsWidth[5]
                        height: r.hRows
                        UText{
                            //text: '$'+parseFloat(xRowTabla.prec*xRowTabla.cant)
                            font.pixelSize: r.fontSize
                            color: 'black'
                            anchors.centerIn: parent
                            Component.onCompleted: {
                                let totalSinDto=parseFloat(xRowTabla.prec*xRowTabla.cant)
                                let vdto=totalSinDto / 100 * parseInt(xRowTabla.dto)
                                let totalConDto=parseFloat(totalSinDto-vdto).toFixed(2)
                                text='$'+totalConDto
                            }
                        }
                    }
                }
                Rectangle{
                    width: xRowTabla.width
                    height: 2
                    color: 'black'
                    anchors.bottom: parent.bottom
                }
            }
        }
    }
    Component{
        id: compRowPieTablaTotal
        Rectangle{
            id: xRowPieTablaTotal
            width: parent.width*0.8
            height: r.hRows
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: r.printMarginTop
            clip: true
            property real total
            property real saldoAnterior: 0.00
            Row{
                Item{
                    width: xRowPieTablaTotal.width*(r.colsWidth[0]+r.colsWidth[1]+r.colsWidth[2]+r.colsWidth[3]+r.colsWidth[4])
                    height: r.hRows+10
                    Rectangle{
                        width: parent.width+2
                        height: parent.height
                        y:-10
                        border.width: 2
                        radius: 10
                        UText{
                            text: '<b>Saldo anterior: </b>$'+saldoAnterior+' <b>Total: </b>'
                            font.pixelSize: r.fontSize
                            color: 'black'
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: 5
                            anchors.right: parent.right
                            anchors.rightMargin: r.fontSize
                        }
                    }
                }
                Rectangle{
                    width: xRowPieTablaTotal.width*r.colsWidth[5]
                    height: r.hRows+10
                    y:-10
                    border.width: 2
                    radius: 10
                    UText{
                        text: '$'+xRowPieTablaTotal.total
                        font.pixelSize: r.fontSize
                        color: 'black'
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: 5
                    }
                }
            }
            Rectangle{
                width: xRowPieTablaTotal.width
                height: 2
                color: 'black'
                anchors.top: parent.top
            }
        }
    }
    Component.onCompleted:{
        let cPdfPage=compPdfPage
        let oPdfPage=cPdfPage.createObject(colPdfPages, {})
    }
    function loadClientData(){
        let sql = 'select * from clientes where cod=\''+tiCodCliente.text+'\''
        let rows=unik.getSqlData(sql)
    }
}
