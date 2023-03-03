/*-----------------------------------------------
    BOUCLE MAIN
 ------------------------------------------------*/
function main() {
  // Timer de secours
  mainTimer() ;


  if ( GAMEDEBUG )
    getGlobalControls() ;



  // Gestion des var secures
//  if ( !_global.vsSecure ) {
//    fatal( "pixel invalide", "VS2["+vsVersion+"] - "+vsHackedList.toString() ) ;
//  }

  // Gestion du FPS
  updateFPS+=gtmod ;
  if (updateFPS>6) {
    FPS = Math.floor( normalFPS / gtmod ) ;
    if ( GAMEDEBUG )
      _root.fpsTxt = FPS ;
    updateFPS = 0 ;
  }

  if ( !fl_allowReset )
    client.reseting = false ;

  // Exécute le bon init dès le changement de phase de jeu
  if ( client.reseting || previousPhase != vs.mainPhase ) {
    vsCheckAll() ;
    // Reset
    if ( client.reseting ) {
      cleanAll() ;
      client.reseting = false ;
      vs.mainPhase = 0 ;
      playSoundBK("gameOverSound") ;
      if ( musicON ) {
        stopMusic( musicGame ) ;
        stopMusic( musicMenu ) ;
        startMusic( musicMenu ) ;
      }
    }
    if ( previousPhase!=3 && previousPhase!=4 )
      cleanAll() ;

    switch (vs.mainPhase) {
      case 0 : initMenu() ; break ;
      case 1 : initGame() ; break ;
      case 2 : initFinal() ; break ;
      case 3 :
          initGrid() ;
          initTrackLoader( vs.selectedTrack ) ;
          break ;
      case 4 :
          initGrid() ;
          if ( musicON )
            if ( vs.gameMode == TUTORIAL ) // Tutorial
              musicGame = initMusicLoader( musicGameMC, 1 ) ;
            else
              musicGame = initMusicLoader( musicGameMC, vs.selectedTrack ) ;
          break ;
    }
    previousPhase = vs.mainPhase ;
  }


  // Exécute le bon main()
  switch (vs.mainPhase) {
    case 0 : mainMenu() ; break ;
    case 1 : mainGame() ; break ;
    case 2 : mainFinal() ; break ;
    case 3 :
        animGrid() ;
        mainTrackLoader() ;
        break ;
    case 4 :
        animGrid() ;
        if ( mainMusicLoader() ) {
          vs.mainPhase = 1 ;
        }
        break ;
  }

}



/*-----------------------------------------------
    INITIALISATION
 ------------------------------------------------*/
function init() {

  // Serveur
  client = new bkiwi.KiwiClient(this) ;
  if ( SERVERTRACE )
    client.setDebugFunction( gdebug ) ;

  gdebug("Testing gdebug...");
  warning("Testing warning...");
  gdebug("isgray="+client.isGray+" = "+client.isGray()) ;
  gdebug("isWhite="+client.isWhite+" = "+client.isWhite()) ;
  gdebug("isBlack="+client.isBlack+" = "+client.isBlack()) ;

  gdebug("Build: "+buildVersion) ;
  gdebug("ClientBuild: "+client.getVersion()) ;
  _parent.build = buildDate+" ("+buildVersion+") ("+client.getVersion()+")" ;

  // Fausses données du serveur
  if ( USEFAKESERVER )
    initFakeServer() ;

  // Var secure
  vs = new Object ;
  vs.vsInit("vs") ;
  vs.$ws = false ;
  vs.$wss = false ;
  vs.$wc = false ;
  vs.$wcs = false ;
  vs.selectedTrack = 0 ;
  vs.selectedCar = 2 ;
  vs.selectedAdv = 0 ;
  vs.useSpecials = false ;
  vs.pauseDuration = 0 ;
  vs.menuPhase = 0 ;
  vs.mainPhase = 0 ;
  vs.finalPhase = 0 ;
  vs.gameMode = 0 ;
  vs.giveUp = false ;
  vs.startBoost = 0 ; // startBoost est un ratio de 0 à 1
  vs.vsSecureAll() ;

  // Traductions des touches
  initKeyNames("fr") ;

  // Variables diverses
  previousPhase = -1 ;
  fl_allowReset = false ;

  // Depths
  this.initDepth(40,150) ;

  // Timer "de secours"
  initTimer(normalFPS) ;
  updateFPS = 0 ;

  // Preloader
  initPreloader() ;

  // Musiques
  initSounds() ;

  // Qualité
  qualitySetting = HIGH

  // Sons
  this.createEmptyMovieClip("soundMC",this.calcDepth(DP_SOUNDS)) ;
  forceSoundMC(soundMC) ; // force la lecture de tous les sons dans un MC

  // Fruticard
  initFrutiCard() ;
}
