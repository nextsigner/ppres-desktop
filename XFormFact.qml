import QtQuick 2.0
import QtWebEngine 1.5

Item {
    id: r
    anchors.fill: parent
    property int mod: 0
    property var prods: []
    onVisibleChanged: {
//        if(visible&&colPdfPages.children.length===0){
//            //addNewFactPage()
//        }
    }
    XFormFactPrep{
        id: xFormFactPrep
        height: r.height
        visible: false//r.mod===0
        currentTableName: 'productos'
    }
    Row{
        spacing: app.fs
        BotonUX{
            text: 'Crear Nueva Factura'
            onClicked: {
                addNewFactPage()
            }
        }
        BotonUX{
            text: 'Abrir una Factura'
            onClicked: {
                openFactPage()
            }
        }
        BotonUX{
            text: 'Continuar editando Factura'
            onClicked: {
                for(var i=0;i<xEditorPdf.children.length;i++){
                    xEditorPdf.children[i].visible=true
                }
            }
        }
    }
    Item{
        id: xEditorPdf
        width: r.width
        height: r.height
    }
    WebEngineView{//Necesita args app --disable-web-security
        id: wv
        width: 2480*0.5
        height:3508*0.5
        settings.localContentCanAccessRemoteUrls: true
        settings.localStorageEnabled: true
        property string fn: ''
        visible: r.mod===1
        onLoadProgressChanged:{
            if(loadProgress===100){
                wv.printToPdf('facts/'+wv.fn+'.pdf', WebEngineView.A4, WebEngineView.Portrait)
            }
        }
        onPdfPrintingFinished:{
            console.log(filePath+' '+success)
        }
    }
        Timer{
        id: tPrint
        running: false
        repeat: false
        interval: 1500
        onTriggered: {
            itemToImage(itemPDF)
        }
    }
    Component.onCompleted:{
        /*let cPdfPage=compPdfPage

        let pds=[]
        for(let i=0;i<45;i++){
            let prod={}
            prod.cod='cod-'+parseInt(i + 1)
            prod.des='des-'+i
            prod.cant=10
            prod.prec=33
            prod.descu=10
            pds.push(prod)
        }
        let oPdfPage=cPdfPage.createObject(colPdfPages, {prods:pds})
        tPrint.start()*/
    }
    function itemToImage(item){
        let d = new Date(Date.now())
        let fn='fact_'+d.getTime()
        wv.fn=fn
        item.grabToImage(function(result) {
            result.saveToFile('facts/'+fn+".jpg");
            let html='<!DOCTYPE html>'+
                '<html>'+
                '<body style="width:100%; margin:0 auto;text-align:center;">'+
                '<img style="width:790px;" src="file:///facts/'+fn+'.jpg" />'+
                '</body>'+
                '</html>'
            wv.loadHtml(html)
        });
    }
    function setFactData(){
        let cPdfPage=compPdfPage

        let pds=[]
        for(let i=0;i<r.prods.length;i++){
            let prod={}
            prod.cod=r.prods[i].cod
            prod.des=r.prods[i].des
            prod.cant=r.prods[i].cant
            prod.prec=r.prods[i].ven
            prod.dto=r.prods[i].dto
            pds.push(prod)
        }
        let oPdfPage=cPdfPage.createObject(colPdfPages, {prods:pds})
        tPrint.start()
    }
    function addNewFactPage(){
        //uLogView.showLog('xEditorPdf.children.length: '+xEditorPdf.children.length)
        for(var i=0;i<xEditorPdf.children.length;i++){
            xEditorPdf.children[i].destroy(10)
        }
        let cPdfPage=Qt.createComponent("XFactPage.qml")
        let oPdfPage=cPdfPage.createObject(xEditorPdf, {})
        let d=new Date(Date.now())
        let ms=d.getTime()//15561516516
        let sql='insert into facts(ms, codcli, com)values('+ms+', \'\',\'\')'
        unik.sqlQuery(sql)
        sql='select id from facts order by id desc limit 1'
        let row=unik.getSqlData(sql)
        let nuevoNumeroDeFactura=parseInt(row[0].col[0])
        oPdfPage.numFact=nuevoNumeroDeFactura
    }
    function openFactPage(){
        for(var i=0;i<xEditorPdf.children.length;i++){
            xEditorPdf.children[i].destroy(10)
        }
        let cPdfPage=Qt.createComponent("XFactPage.qml")
        let oPdfPage=cPdfPage.createObject(xEditorPdf, {})
    }
}
