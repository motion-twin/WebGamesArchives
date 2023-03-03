#include "../ext/inc/deep/debug.as"
#include "inc/debug/editor.as"

gamePrefix = "(BK)" ;

GAMEDEBUG = true ;
//EDITORMODE=true ; // édition des checkpoints
SERVERTRACE = true ; // affiche les debugs utilisés par gameClient

//debugAutoAccel = true ;

if ( _parent._parent._name==undefined )
  USEFAKESERVER=true ;


/*-----------------------------------------------
    TRACE SUR UN CHAMP TEXTE (ÉDITEUR)
 ------------------------------------------------*/
function traceTxt(chaine) {
  _root.traceur=_root.traceur+chaine+"<BR>" ;
  trace( chaine ) ;
}



/*-----------------------------------------------
    GESTION DES TOUCHES SPÉCIALES
 ------------------------------------------------*/
function getDebugControls() {
  if ( Key.isDown(Key.CONTROL) ) {
    if (Key.isDown(97)) { // NUMPAD 1: fin de course avec classement forcé
      gdebug("force #1") ;
      forcePosition = 0 ;
      updateRace() ;
      updateTournament() ;
      vs.mainPhase = 2 ;
    }
    if (vs.gameMode!=ARCADE && Key.isDown(98)) { // NUMPAD 2: fin de course avec classement forcé
      gdebug("force #2") ;
      forcePosition = 1 ;
      updateRace() ;
      updateTournament() ;
      vs.mainPhase = 2 ;
    }
    if (vs.gameMode!=ARCADE && Key.isDown(99)) { // NUMPAD 3: fin de course avec classement forcé
      gdebug("force #3") ;
      forcePosition = 2 ;
      updateRace() ;
      updateTournament() ;
      vs.mainPhase = 2 ;
    }
    if (vs.gameMode!=ARCADE && Key.isDown(100)) { // NUMPAD 4: fin de course avec classement forcé
      gdebug("force #4") ;
      forcePosition = 3 ;
      updateRace() ;
      updateTournament() ;
      vs.mainPhase = 2 ;
    }
  }


  if (!Key.isDown(78)) lockNext=false ; // N: tracking caméra
  if (Key.isDown(78) && !lockNext) {
    trackedCar++ ;
    if (trackedCar>=cars.length) trackedCar=0 ;
    lockNext=true ;
  }
//  if (Key.isDown(67)) { // HOME: recentrage
//    lastCP = CP[track.id][carPJ.lastCP] ;
//    carPJ._rotation = lastCP.ang ;
//    carPJ.accelAng = carPJ._rotation ;
//    carPJ.x = lastCP.x ;
//    carPJ.y = lastCP.y ;
//    carPJ.oldX=carPJ.x ;
//    carPJ.oldY=carPJ.y ;
//    carPJ.speed = 0 ;
//    carPJ.speedA = 0 ;
//    carPJ.dx=0 ;
//    carPJ.dy=0 ;
//    chronoTimer=getTimer() ;
//    chrono=true ;
//  }
}



/*-----------------------------------------------
    GESTION DES TOUCHES SPÉCIALES (GÉNÉRALES)
 ------------------------------------------------*/
function getGlobalControls() {
  // Vide le buffer text
  if (Key.isDown(Key.BACKSPACE)) {
    gdebug() ;
  }
  if (Key.isDown(Key.DELETEKEY)) {
    _root.test="" ;
  }
}



/*-----------------------------------------------
    INITIALISATION DU FAUX SERVEUR
 ------------------------------------------------*/
function initFakeServer() {
  warning("USING FAKE SERVER") ;
  // Divers
  _global.swfURL = "./" ;
}


/*-----------------------------------------------
    RENVOIE UN OBJET "FILES"
 ------------------------------------------------*/
function getDebugFileId( fileName ) {
  return { id:fileName, size:random(100000)+50000 } ;
}


/*-----------------------------------------------
    RÉCEPTION DU GAMEDISC (FAKE)
 ------------------------------------------------*/
function getFakeInit() {
  client.BLACK = 0 ;
  client.GRAY = 1 ;
  client.GREY = 1 ;
  client.WHITE = 2 ;

  client.gameDisc = new Object() ;
  client.gameDisc.width = docWidth ;
  client.gameDisc.height = docHeight ;
  // Noms
  client.gameDisc.files = new Object() ;
  for (var i=0;i<5;i++)
    client.gameDisc.files["bk0"+i+"_mp3"] = getDebugFileId("bk0"+i+".mp3") ;
  for (var i=0;i<5;i++)
    client.gameDisc.files["track0"+i+"_swf"] = getDebugFileId("track0"+i+".swf") ;
  client.gameDisc.files["track99_swf"] = getDebugFileId("track99.swf") ;
  client.gameDisc.files["bkMenu_swf"] = getDebugFileId("bkMenu.swf") ;
  client.gameDisc.files["bkMenu_mp3"] = getDebugFileId("bkMenu.mp3") ;

  client.connected = true ;
}


/*-----------------------------------------------
    ENVOI DE DONNÉES AU SERVEUR (FAKE)
 ------------------------------------------------*/
function sendFakeServerCommand(cmd) {
  client.fl_success = true ;
}


/*-----------------------------------------------
    ENVOI DE DONNÉES AU SERVEUR (FAKE)
 ------------------------------------------------*/
function fakeFrusionError( msg ) {
  error("FRUSION-ERROR: "+msg) ;
  _parent.gotoAndStop(1) ;
}


initDebug( 0x000000, gamePrefix ) ;
_parent.attachMovie("consoleDebug", "console", 1866) ;



