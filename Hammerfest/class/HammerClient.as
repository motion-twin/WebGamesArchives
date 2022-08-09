
class HammerClient extends frusion.gameclient.GameClient {

/** PROPRIÉTÉS PRIVÉES */

  private var fakeServer : Boolean ;
  private var root : MovieClip ;



/** MÉTHODES PUBLIQUES */

/*------------------------------------------------------------------------
    CONSTRUCTEUR
 ------------------------------------------------------------------------*/
  public function HammerClient( context : MovieClip ) {
    super() ;

    this.root = context ;

    this.fakeServer = root.USEFAKESERVER ;
  }



/*------------------------------------------------------------------------
    MODIFIE LE CONTEXTE DE L'OBJET
 ------------------------------------------------------------------------*/
  public function changeRoot( newRoot : MovieClip ) : Void {
    this.root = newRoot ;
  }



/*------------------------------------------------------------------------
    INITIALISATION ET CONNEXION AU SERVICE
 ------------------------------------------------------------------------*/
  public function serviceConnect(port) : Void {
    super.serviceConnect(port) ;

    if ( this.fakeServer )
      root.sendFakeServerCommand("init") ;
  }


/*------------------------------------------------------------------------
    MODES DE JEU
 ------------------------------------------------------------------------*/
  public function listModes() : Void {
    super.listModes() ;

    if ( this.fakeServer )
      root.sendFakeServerCommand("listModes") ;
  }



/*------------------------------------------------------------------------
    DÉMARRE UNE PARTIE
 ------------------------------------------------------------------------*/
  public function startGame( gameMode : Number ) : Void {
    super.startGame( gameMode ) ;

    if ( this.fakeServer )
      root.sendFakeServerCommand("startGame") ;
  }



/*------------------------------------------------------------------------
    TERMINE UNE PARTIE
 ------------------------------------------------------------------------*/
  public function endGame() : Void {
    super.endGame() ;
    if ( this.fakeServer )
      root.sendFakeServerCommand("endGame") ;
  }


/*------------------------------------------------------------------------
    CALLBACK: FERMETURE DU JEU
 ------------------------------------------------------------------------*/
  public function onGameClose() : Void {
    super.onGameClose() ;
    this.closeService() ;
  }


/*------------------------------------------------------------------------
    CALLBACK : ENDGAME
 ------------------------------------------------------------------------*/
  public function onEndGame( nodeTxt : String ) : Void {
    super.onEndGame( nodeTxt ) ;
    if ( root.vs.gameMode == root.ADVENTURE ) { // xxx
      this.debug("onEndGame: sending score") ;
      this.saveScore(
        new Array(
          new frusion.service.ScoreParameter( this.buildScoreSubId(this.root.vs.gameMode), this.root.vs.score )
        ),
        String( this.root.vs.level )
      ) ;
    }
  }

}


