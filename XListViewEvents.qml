import QtQuick 2.12
import QtQuick.Controls 2.0
import Qt.labs.settings 1.0
import "func.js" as JS

Rectangle{
    id: r0
    width: parent.parent.width-app.fs
    height: parent.height
    color: app.c1
    onVisibleChanged: {
        //lv.focus=visible
        lm.clear()
        let sql='select * from eventos order by id desc'
        let rows=unik.getSqlData(sql)
        for(var i=0;i<rows.length;i++){
            lm.append(lm.addDato(rows[i].col[1], rows[i].col[2], rows[i].col[3], rows[i].col[4]))
        }
    }

    Column{
        id: r
        width: parent.width
        height: parent.height
        visible: lm.count>0
        property alias listModel: lm
        property var colsNameEventos: ['Evento', 'Tabla', 'Id', 'Fecha']
        signal idSelected(int id, string nom)
        Item{
            width: lv.width
            height: app.fs*4-app.fs*0.25
            Item{
                id:xRowTitDes
                width: lv.width
                height: app.fs*4
                property var anchos: [0.35, 0.25,0.15,0.25]
                property string fontColor: app.c1
                Row{
                    anchors.centerIn: parent
                    Repeater{
                        model: r.colsNameEventos
                        Rectangle{
                            width: xRowTitDes.width*xRowTitDes.anchos[index]
                            height:xRowTitDes.height
                            border.width: 2
                            border.color: app.c4
                            color: app.c2
                            UText{
                                text: '<b>'+(''+r.colsNameEventos[index]).replace(/ /g, '<br />')+'</b>'
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
            height: r.height-xRowTitDes.height-app.fs*0.25
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
                width: r0.width
                height: parent.height
                clip: true
                //KeyNavigation.tab: botCC
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
                    function addDato(p1, p2, p3, p4){
                        return{
                            v1: p1,
                            v2: p2,
                            v3: p3,
                            v4:p4
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
                        color: app.c1
                        property string fontColor: app.c2
                        property var arrayModeloDatos: [v1, v2, v3, v4]//[v2, v3, v4, v5, v6]



                        Row{
                            anchors.centerIn: parent
                            Repeater{
                                model: r.colsNameEventos
                                Rectangle{
                                    width: xRowDes.width*xRowTitDes.anchos[index]
                                    height:xRowDes.height
                                    border.width: 2
                                    border.color:app.c2
                                    color: app.c1
                                    clip: true
                                    UText{
                                        id: txtCelda
                                        text: xRowDes.arrayModeloDatos[index]
                                        anchors.centerIn: parent
                                        color: xRowDes.fontColor
                                        horizontalAlignment: Text.AlignHCenter
                                        //color: index===3||index===4?'red':'blue'
                                    }
                                    Component.onCompleted: {
                                                                if(index===3){
                                                                    let d=new Date(parseInt(v4))
                                                                   txtCelda.text=''+d.getDate()+'/'+parseInt(d.getMonth()+1)+'/'+d.getFullYear()+' '+d.getHours()+':'+d.getMinutes()+':'+d.getSeconds()
                                                                }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    BotonUX{
        text: 'Atras'
        onClicked: {
            r0.visible=false
        }
    }

}
