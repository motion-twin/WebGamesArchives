

/* CallBacks ******************************************************************/


/*-----------------------------------------------
    CALLBACK: GÉNÉRIQUE
 ------------------------------------------------*/
function genericCallback() {
  dataReceived = true ;
  if ( USEFAKESERVER )
    clearInterval( callBackInterval ) ;
}


/*-----------------------------------------------
    CALLBACK: ERREUR
 ------------------------------------------------*/
function genericErrorCallback() {
  errorReceived = true ;
  if ( USEFAKESERVER )
    clearInterval( callBackInterval ) ;
}


/*-----------------------------------------------
    CALLBACK: LANCEMENT DE LA PARTIE
 ------------------------------------------------*/
function onStartGame( nodeTxt ) {
  var node = new XML(nodeTxt) ;
  if ( node.firstChild.attributes.k != undefined ) {
    error("onStartGame: REFUSED !") ;
    genericErrorCallback() ;
  }
  else {
    gdebug("onStartGame: allowed") ;
    genericCallback() ;
  }
}


/*-----------------------------------------------
    CALLBACK: ENDGAME
 ------------------------------------------------*/
function onEndGame( nodeTxt ) {
  var node = new XML(nodeTxt) ;
  scoreKey = node.firstChild.attributes.pi ;
  gdebug("onEndGame: key = "+scoreKey) ;

  // Callbacks standards
  if ( node.firstChild.attributes.k != undefined ) {
    error("onEndGame: error") ;
    genericErrorCallback() ;
  }
  else {
    genericCallback() ;
  }

  // Suite à la fermeture forcée de la frusion
  if ( forceClose )
    endCallback() ;
}



/*-----------------------------------------------
    CALLBACK: CONNECTÉ AU SERVICE ET PRÊT
 ------------------------------------------------*/
function onServerReady() {
  // Données du jeu
  gdebug() ;
  gameDisc = frusionClient.gameDisc ;
  frutiSlots = frusionClient.frutiCard.slots ;

  vs.discType = gameDisc.discType ;

  gdebug("onServerReady: gameDisc="+gameDisc+" frutiSlots="+typeof(frutiSlots)+"("+frutiSlots.length+") discType="+vs.discType) ;

  genericCallback() ;
}



/*-----------------------------------------------
    CALLBACK: LISTMODES
 ------------------------------------------------*/
function onListModes(nodeTxt) {
  var node = new XML(nodeTxt) ;
  var modeStr = node.firstChild.attributes.md ;
  var modeList ;

  if ( modeStr==undefined || modeStr=="" )
    modeList = new Array() ;
  else
    modeList = modeStr.split(":") ;

  gdebug("onListModes:"+modeList+"(length="+modeList.length+")" ) ;

  for (var i=0;i<modeList.length;i++)
    gameModes[ Number(modeList[i]) ] = true ;

  if ( node.firstChild.attributes.k != undefined )
    genericErrorCallback() ;
  else
    genericCallback() ;
}



/*-----------------------------------------------
    CALLBACK: PAUSE
 ------------------------------------------------*/
function onPause() {
  // Jeu actif alors que le serveur réclame une pause
  forcePause = frusionClient.pauseStatus ;
  gdebug("onPause: status="+frusionClient.pauseStatus) ;
}



/*-----------------------------------------------
    CALLBACK: INTERRUPTION DU JEU (CONSOLE)
 ------------------------------------------------*/
function onGameClose() {
  gdebug("onGameClose") ;
  forceClose = true ;
  forcePause = true ;
  endCallback = stopGame ;
  if ( gameRunning )
    sendEndGame() ;
  else
    endCallback() ;
}


/*-----------------------------------------------
    CALLBACK: RESET DE LA CONSOLE
 ------------------------------------------------*/
function onGameReset() {
  gdebug("onGameReset") ;
  forceClose = true ;
  forcePause = true ;
  endCallback = stopGame ;
  if ( gameRunning )
    sendEndGame() ;
  else
    endCallback() ;
}


/*-----------------------------------------------
    CALLBACK: SAVE SCORE
 ------------------------------------------------*/
function onSaveScore(nodeTxt) {
  var node = new XML(nodeTxt) ;
  var sub = node.firstChild.firstChild ;

  serverResult = new Object() ;
  serverResult.oldPos = parseInt( sub.attributes.op, 10 ) ;
  serverResult.newPos = parseInt( sub.attributes.p, 10 ) ;
  gdebug("onSaveScore: old="+serverResult.oldPos+" new="+serverResult.newPos) ;

  if ( node.firstChild.attributes.k != undefined )
    genericErrorCallback() ;
  else
    genericCallback() ;
}



/* Commandes ******************************************************************/


/*-----------------------------------------------
    COMMAND: GÉNÉRIQUE
 ------------------------------------------------*/
function sendServerCommand( cmd, paramList ) {
  dataReceived = false ;
  errorReceived = false ;
  if ( USEFAKESERVER )
    sendServerCommandFake(cmd,paramList) ;
  else {
    gdebug("sendServerCommand: sending ["+cmd+"]") ;
    frusionClient.sendCommand( cmd, paramList ) ;
  }
}


/*-----------------------------------------------
    COMMAND: STARTGAME
 ------------------------------------------------*/
function sendStartGame() {
  gameRunning = true ;
  frutiScore.startGame( gameDisc.id, vs.gameMode ) ;
}


/*-----------------------------------------------
    COMMAND: ENDGAME
 ------------------------------------------------*/
function sendEndGame() {
  gdebug("sendEndGame") ;
  gameRunning = false ;
  frutiScore.endGame() ;
}



/*-----------------------------------------------
    COMMAND: SAVESCORE
 ------------------------------------------------*/
function sendSaveScore( modeId, trackId, value, miscData) {
  var scoreId = String(trackId+1)+String(modeId) ;
  dataReceived = false ;
  gdebug("saveScore: id="+scoreId+" value="+value+" misc="+miscData) ;
  gdebug("saveScore: sid="+_root.sid) ;

  frutiScore.saveScore(
      new Array(
        new ScoreParameter(scoreId,value)
      ),
      miscData,
      scoreKey
  ) ;
}



/*-----------------------------------------------
    COMMAND: STOPGAME (CALLBACK VERS LE SERVEUR
    POUR L'ARRÊT DU JEU)
 ------------------------------------------------*/
function stopGame() {
  gdebug("stopGame") ;
  frusionClient.closeService() ;
}



/* Divers *********************************************************************/


/*-----------------------------------------------
    RENVOIE L'URL ET LA TAILLE D'UN FICHIER
 ------------------------------------------------*/
function getFileInfos( fileName ) {
  fileName = strReplace( fileName, ".", "_" ) ;
  fileName = strReplace( fileName, "-", "_" ) ;
  fullName = _global.swfURL + gameDisc.files[fileName].id ;
  gdebug("getFileInfos: "+fileName+" -> "+fullName) ;

  return { name:fullName, size:parseInt(gameDisc.files[fileName].size), 10 } ;
}



/*-----------------------------------------------
    INITIALISATION DE LA CONNEXION
 ------------------------------------------------*/
function initConnection() {
  if ( USEFAKESERVER ) {
    getFakeInit() ;
    return ;
  }

  // FrusionClient
  frusionClient = new FrusionClient();
  frusionClient.registerReadyCallback( new frusion.util.Callback(this,"onServerReady") ) ;
  frusionClient.registerPauseCallback( new frusion.util.Callback(this,"onPause")) ;
  frusionClient.registerCloseCallback( new frusion.util.Callback(this,"onGameClose")) ;
  frusionClient.registerResetCallback( new frusion.util.Callback(this,"onGameReset")) ;
  gdebug("initConnection: connecting to service (port "+frutiScorePort+")") ;
  frusionClient.getService( frutiScorePort ) ;

  // Manager de score
  frutiScore = new FrutiScore( frusionClient ) ;
  frutiScore.addListener(this);
}
