import QtQuick 2.0

Rectangle {
    id: r
    visible: r.parent.focus
    width: parent.width
    height: parent.height
    anchors.centerIn: parent
    property var objFocus: parent
    property int w: unikSettings.borderWidth
    property color c1: app.c1
    property color c2: app.c2
    property string idSound
    color: 'transparent'
    border.width: unikSettings.borderWidth
    border.color: c2
    radius: unikSettings.radius
    onVisibleChanged: {
        if(visible&&app.objFocus){
            app.objFocus=r.objFocus            
        }
    }
    Timer{
        running: parent.visible
        repeat: true
        interval: 500
        property int v: 0
        onTriggered: {
            if(v===0){
                r.border.color=r.c1
                //parent.c=app.c2
                v++
            }else{
                r.border.color=r.c2
//                if(r.parent.border.color){
//                    parent.c=r.parent.border.color
//                }else{
//                    parent.c=app.c4
//                }
                v=0
            }
        }
    }
}
