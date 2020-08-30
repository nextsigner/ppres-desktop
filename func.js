function setBd() {
    let folderBds=""+pws+"/"+app.moduleName+"/bds"
    let bd=''
    if(Qt.platform.os==='windows'){
        bd=apps.bdFileName.indexOf('\\')<0?""+folderBds+"/"+apps.bdFileName:""+apps.bdFileName.replace(/\\\\/g, '/')
    }else{
        bd=apps.bdFileName.indexOf('\\')<0?""+folderBds+"/"+apps.bdFileName:""+apps.bdFileName
    }

    if(!unik.fileExist(bd)){
        apps.bdFileName=getNewBdName()
        bd=""+folderBds+"/"+apps.bdFileName
    }
    //bd="C:\\Users\\qt\\Documents\\unik\\taekwondo\\bds\\productos_24_2_20_17_4_1.sqlite"
    //uLogView.showLog('Iniciando Bd: '+bd)
    let iniciado=unik.sqliteInit(bd)
    //uLogView.showLog('Iniciado: '+iniciado)

    let sql='CREATE TABLE IF NOT EXISTS '+app.tableName1
        +'('
        +'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        +app.colsCertificados[0]+' TEXT NOT NULL,'
        +app.colsCertificados[1]+' TEXT NOT NULL,'
        +app.colsCertificados[2]+' TEXT NOT NULL,'
        +app.colsCertificados[3]+' NUMERIC NOT NULL,'
    +app.colsCertificados[4]+' NUMERIC NOT NULL,'
        +app.colsCertificados[5]+' NUMERIC NOT NULL'
        +')'
    unik.sqlQuery(sql)
    sql='CREATE TABLE IF NOT EXISTS '+app.tableName2
        +'('
        +'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        +app.colsDatosAlumnos[0]+' TEXT NOT NULL,'
        +app.colsDatosAlumnos[1]+' TEXT NOT NULL,'
        +app.colsDatosAlumnos[2]+' TEXT NOT NULL,'
        +app.colsDatosAlumnos[3]+' TEXT  NOT NULL,'
        +app.colsDatosAlumnos[4]+' TEXT  NOT NULL'
        +')'
    unik.sqlQuery(sql)
    sql='CREATE TABLE IF NOT EXISTS eventos'
        +'('
        +'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        +'evento TEXT NOT NULL,'
        +' tablaefectada TEXT NOT NULL,'
        +'idafectado NUMERIC NOT NULL,'
        +'ms NUMERIC  NOT NULL'
        +')'
    unik.sqlQuery(sql)
    //console.log('Ejecutado: '+ejecutado)
}

function setEvent(e, t, i, m){
    let sql='insert into eventos(evento, tablaefectada, idafectado, ms)values(\''+e+'\',\''+t+'\','+i+','+m+')'
    unik.sqlQuery(sql)
}

function setFolders(){   
    unik.debugLog=true

    if(!unik.folderExist(pws+'/taekwondo')){
        unik.mkdir(pws+'/taekwondo')
    }
    if(!unik.folderExist(pws+'/"+app.moduleName+"/bds')){
        unik.mkdir(pws+'/"+app.moduleName+"/bds')
    }
    //apps.bdFileName=''
    //apps.bdFileName=unik.currentFolderPath()+'/bds/p.sqlite'
}

function removeItemFromArr(arr, item){
    var i = arr.indexOf( item );
    arr.splice( i, 1 );
    return arr;
}

function key(){
    let k='6dd62cc2d17539nd473d1zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzc6d1q3c3v8d7d4zzzzzzzzzzzzz||||||Id9d6qdf7c74c051745175d9d3dbc03ccen0a4974d5d67b0a43dfd6qdfded5de74cedfde43dfd6qd2dv4d5d43a7b0aqd17cd5de74ced5ded1dcd2d5d436747c75d53b0a7pa7paOd17539nd473d1zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzc6d1q3c3v8d7d4zzzzzzzzzzzzz'
    return k
}
