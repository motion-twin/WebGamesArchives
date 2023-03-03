nbPreloadIcons = 3 ;

// ajouter un "/" à la fin
basePreloadURL = "../burningKiwi/" ;
basePreloadURL = "" ;


/*-----------------------------------------------
    BOUCLE MAIN PRELOAD
 ------------------------------------------------*/
function mainPreload() {

//  // Timeout: attention, l'objet doit peser AU MOINS 7ko ! (sinon bug)
//  if ( objectPreloaded.getBytesTotal() < 7000 ) {
//    if ( timeoutPreload > 0 ) {
//      timeoutPreload -- ;
//      if ( timeoutPreload <= 0 ) {
//        timeoutPreload = 0 ;
//        preloader.txt = fileName ;
//        preloader.gotoAndStop(2) ; // file not found
//      }
//    }
//    return( false ) ;
//  }
//  else
//    if ( preloader.txt != "..."+message.toUpperCase() )
//      preloader.txt = "..."+message.toUpperCase() ;


  if ( preloadData.obj.getBytesTotal() > 7000 ) {
    showProgress( preloadData.obj.getBytesLoaded(), preloadData.obj.getBytesTotal() ) ;
    preloader.txt = preloadData.msg ;
  }

  // Renvoie true ou false selon que le preload est terminé
  if ( preloadData.loadComplete ) {
    preloader.removeMovieClip() ;
    return true ;
  }
}



/*-----------------------------------------------
    BOUCLE MAIN DU LOADER DE COURSE
 ------------------------------------------------*/
function mainTrackLoader() {
  if ( mainPreload() ) {
    track.initDepth() ;
    if (musicON)
      vs.mainPhase = 4 ;
    else
      vs.mainPhase = 1 ;
    grille.removeMovieClip() ;
  }
}



/*-----------------------------------------------
    INITIALISATION DU LOADER DE COURSE
 ------------------------------------------------*/
function initTrackLoader(trackId) {

  track.removeMovieClip() ;
  this.createEmptyMovieClip( "track", this.calcDepth(DP_TRACK) ) ;
  track.createEmptyMovieClip( "skin", 1 ) ;
  track.initDepth() ;
  track._visible = false ;

  var fileName ;
  if ( trackId < 10 )
    fileName = "track0"+trackId+".swf" ;
  else
    fileName = "track"+trackId+".swf" ;

  startPreload( track.skin, fileName, "Chargement de course") ;

}



/*-----------------------------------------------
    BOUCLE MAIN DU LOADER DE MUSIC
 ------------------------------------------------*/
function mainMusicLoader(soundObject) {
  if ( mainPreload() )
    return true ;
}



/*-----------------------------------------------
    INITIALISATION DU LOADER DE MUSIC
 ------------------------------------------------*/
function initMusicLoader(soundMC, fileId) {

  // Nom du fichier
  var fileName ;
  if ( typeof(fileId) == "string" )
    fileName = fileId ;
  else {
    if ( fileId < 10 )
      fileName = "bk0"+fileId+".mp3" ;
    else
      fileName = "bk"+fileId+".mp3" ;
  }

  // Charge la musique
  var soundObject = new Sound(soundMC) ;
  soundObject.onLoad = eventSoundComplete ;
  soundObject.isPlaying = false ;


  startPreload( soundObject, fileName, "Chargement musique" ) ;
  return soundObject ;
}



/*-----------------------------------------------
    INDIQUE L'ÉVOLUTION D'UN PRELOAD
 ------------------------------------------------*/
function showProgress( loadedBytes, totalBytes ) {

  pct = Math.round( loadedBytes*100/totalBytes ) ;
  for (var i=0;i<nbPreloadIcons;i++) {
    var step1, step2 ;
    step1 = i*(100/nbPreloadIcons) ;
    step2 = (i+1)*(100/nbPreloadIcons) ;
    if ( pct>=step2 )
      preloader["k_"+i].gotoAndStop(3) ;
    if ( pct>step1 && pct<step2 ) {
      var k = preloader["k_"+i]
      k.gotoAndStop(2) ;
      k.nitro.liquid._y = -12 + ((pct-step1)*19) / (100/nbPreloadIcons) ;
    }
  }

}


/*-----------------------------------------------
    ÉVÈNEMENT: LOADING DE SON TERMINÉ
 ------------------------------------------------*/
function eventSoundComplete(success) {
  if ( success ) {
    preloadData.loadComplete = true ;
  }
  else {
    loadingError( "Musique introuvable", preloadData.shortFileName ) ;
  }
}


/*-----------------------------------------------
    ÉVÈNEMENT: DÉBUT DE LOADING
 ------------------------------------------------*/
function eventOnLoadStart( mc ) {
}


/*-----------------------------------------------
    ÉVÈNEMENT: LOADING EN COURS
 ------------------------------------------------*/
function eventOnLoadProgress( mc, loadedBytes, totalBytes ) {
}


/*-----------------------------------------------
    ÉVÈNEMENT: LOADING TERMINÉ
 ------------------------------------------------*/
function eventOnLoadComplete( mc ) {
  preloadData.loadComplete = true ;
  if ( !USEFAKESERVER && preloadData.obj.getBytesTotal() != preloadData.fileInfos.size ) // xxx
    fatal("Fichier illisible sur le FD","sizeMatch: "+preloadData.shortFileName+"("+preloadData.getBytesTotal()+")") ;
}


/*-----------------------------------------------
    ÉVÈNEMENT: PREMIÈRE ACTION DU MOVIE EXÉCUTÉE
 ------------------------------------------------*/
function eventOnLoadInit( mc ) {
}


/*-----------------------------------------------
    ÉVÈNEMENT: ERREUR
 ------------------------------------------------*/
function eventOnLoadError( mc, errorCode ) {
  var msg ;

  if ( errorCode == "URLNotFound" )
    msg = "Fichier introuvable" ;
  else
    msg = "Téléchargement interrompu" ;

  loadingError( msg+" ("+mc+")", preloadData.shortFileName ) ;
}



/*------------------------------------------------------------------------
    ERREUR DE PRELOADING
 ------------------------------------------------------------------------*/
function loadingError( errorMsg, fileName ) {
  preloader.error = errorMsg ;

  if ( client.gameRunning )
    client.endGame() ;

  preloader.gotoAndStop(2) ;
  preloader.file = fileName ;

  fatal("Fichier "+fileName+" non trouvé sur le FD", "loadingError: "+errorMsg+" filename="+fileName+" md5="+preloadData.fileInfos.name) ;
}



/*-----------------------------------------------
    LANCEMENT D'UN PRELOAD
 ------------------------------------------------*/
function startPreload( obj, fileName, message ) {
  attachPreloader() ;

  preloadData = new Object() ;

  preloadData.obj = obj ;
  preloadData.shortFileName = fileName ;
  preloadData.fileInfos = client.getFileInfos( fileName ) ;
  if ( USEFAKESERVER ) preloadData.fileInfos = {name:fileName,size:68498} ; // xxx
  preloadData.msg = message ;

  if ( typeof(preloadData.obj) == "movieclip" ) {
    // MovieClip
    mcl.loadClip( preloadData.fileInfos.name, preloadData.obj ) ;
  }
  else {
    // Objet son
    preloadData.obj.loadSound(preloadData.fileInfos.name, false) ;
  }
}



/*-----------------------------------------------
    ATTACHE LE PRELOADER
 ------------------------------------------------*/
function attachPreloader() {
  // attachement
  preloader.removeMovieClip() ;
  var d = this.calcDepth(DP_PRELOAD) ;
  attachMovie( "preloader", "preloader", d ) ;
  preloader._x = preloaderX ;
  preloader._y = preloaderY ;
  preloader.gotoAndStop(1) ;
  preloader.txt = "...RECHERCHE" ;
  timeoutPreload = baseTimeOut ;

  // init des billes de nitro
  for (var i=0;i<nbPreloadIcons;i++)
    preloader["k_"+i].gotoAndStop(1) ;

}



/*-----------------------------------------------
    INITIALISATION GÉNÉRALE DU PRELOADER
 ------------------------------------------------*/
function initPreloader() {
  mcl = new MovieClipLoader() ;
  mclListener = new Object() ;
  mclListener.onLoadStart = eventOnLoadStart ;
  mclListener.onLoadProgress = eventOnLoadProgress ;
  mclListener.onLoadComplete = eventOnLoadComplete ;
  mclListener.onLoadInit = eventOnLoadInit ;
  mclListener.onLoadError = eventOnLoadError ;
  mcl.addListener( mclListener ) ;

}

