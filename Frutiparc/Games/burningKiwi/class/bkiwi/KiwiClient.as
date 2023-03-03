/*
	Class: KiwiClient

  Topic:
	Interface entre les jeux et la frusion (extension de GameClient)

	Version:
	$Id: KiwiClient.as,v 1.15 2005/01/25 16:49:31 sbenard Exp $
*/

class bkiwi.KiwiClient extends frusion.gameclient.GameClient {

  private var root : MovieClip ;

  public var fl_fake : Boolean ;
  public var fl_success : Boolean ;
  public var fl_localScore : Boolean ;


/*------------------------------------------------------------------------
    CONSTRUCTEUR
 ------------------------------------------------------------------------*/
  function KiwiClient(mc) {
    super() ;
    setRoot(mc) ;
    fl_success = false ;
    fl_localScore = false ;
    this.fl_fake = this.root.USEFAKESERVER ;
  }

/*------------------------------------------------------------------------
    DÉFINI LE ROOT
 ------------------------------------------------------------------------*/
  function setRoot(mc) {
    root = mc ;
  }


/*------------------------------------------------------------------------
    TEST LE FD BLANC
 ------------------------------------------------------------------------*/
  function isWhite() {
    if ( fl_fake )
      return true ;
    else
      return super.isWhite() ;
  }


/*------------------------------------------------------------------------
    TEST LE FD BLANC
 ------------------------------------------------------------------------*/
  function isBlack() {
    if ( fl_fake )
      return false ;
    else
      return super.isBlack() ;
  }


/*------------------------------------------------------------------------
    TEST LE FD BLANC
 ------------------------------------------------------------------------*/
  function isRed() {
    if ( fl_fake )
      return false ;
    else
      return super.isRed() ;
  }



/*------------------------------------------------------------------------
    MODIFIE LE CONTEXTE DE L'OBJET
 ------------------------------------------------------------------------*/
  function changeRoot( newRoot : MovieClip ) : Void {
    this.root = newRoot ;
  }


// *** COMMANDES


/*------------------------------------------------------------------------
    INITIALISATION ET CONNEXION AU SERVICE
 ------------------------------------------------------------------------*/
  function serviceConnect() : Void {
    fl_success = false ;
    super.serviceConnect() ;

    if ( this.fl_fake ) {
      root.getFakeInit() ;
    }
  }


/*------------------------------------------------------------------------
    DÉMARRE UNE PARTIE
 ------------------------------------------------------------------------*/
  function startGame() : Void {
    fl_success = false ;
    super.startGame() ;

    if ( this.fl_fake ) {
      root.sendFakeServerCommand("startGame") ;
    }
  }



/*------------------------------------------------------------------------
    TERMINE UNE PARTIE
 ------------------------------------------------------------------------*/
  function endGame() {
    root.gdebug("endGame: fl_localScore="+fl_localScore) ;
    fl_success = false ;
    super.endGame() ;
    if ( this.fl_fake )
      root.sendFakeServerCommand("endGame") ;
  }


/*------------------------------------------------------------------------
    SAUVE LE SCORE
 ------------------------------------------------------------------------*/
  function saveScore(score,misc) {
    root.gdebug("saveScore: score="+score+" misc="+misc) ;
    fl_success = false ;
    fl_localScore = false;
    super.saveScore(score,misc) ;
  }



// *** EVENTS

/*------------------------------------------------------------------------
    EVENT: SERVICE CONNECT
 ------------------------------------------------------------------------*/
  function onServiceConnect() : Void {
    fl_success = true ;
    root.frutiSlots = this.slots ;
  }


/*------------------------------------------------------------------------
    EVENT: ABANDON DE PARTIE
 ------------------------------------------------------------------------*/
  function onEndGame() {
    fl_success = true ;
    root.gdebug("onEndGame") ;
  }



/*------------------------------------------------------------------------
    EVENT: GAME CLOSE
 ------------------------------------------------------------------------*/
  function onGameClose() : Void {
    if ( this.gameRunning )
      this.endGame() ;
    else
      this.closeService() ;
  }


/*------------------------------------------------------------------------
    EVENT: STARTGAME
 ------------------------------------------------------------------------*/
  function onStartGame() {
    fl_success = true ;
  }


/*------------------------------------------------------------------------
    EVENT: SCORE SAUVÉ
 ------------------------------------------------------------------------*/
  function onSaveScore() {
    root.gdebug("onSaveScore") ;
    fl_success = true ;
    if ( this.forceClose )
      this.closeService() ;
  }


/*------------------------------------------------------------------------
    EVENT: SCORE FRUTICARD SAUVÉ
 ------------------------------------------------------------------------*/
  function onSaveScoreFruticard() {
    fl_success = true ;
    fl_localScore = true ;
    root.gdebug("onSaveScoreFruticard") ;
  }


/*------------------------------------------------------------------------
    EVENT: ERREUR
 ------------------------------------------------------------------------*/
  function onError() {
    root.error("onError") ;
    super.onError() ;
  }

}


