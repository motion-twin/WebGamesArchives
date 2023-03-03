
/*-----------------------------------------------
    JOUE UNE MUSIQUE
 ------------------------------------------------*/
function startMusic( soundObj ) {
  if ( !soundObj.isPlaying ) {
    soundObj.start(0,9999) ;
    soundObj.isPlaying = true ;
  }
}


/*-----------------------------------------------
    STOPPE UNE MUSIQUE
 ------------------------------------------------*/
function stopMusic( soundObj ) {
  if ( soundObj.isPlaying ) {
    soundObj.stop() ;
    soundObj.isPlaying = false ;
  }
}



/*-----------------------------------------------
    JOUE UN SON, AVEC GESTION DU FLAG soundsON
 ------------------------------------------------*/
function playSoundBK( soundId ) {
  if ( soundsON )
    playSound( soundId ) ;
}



/*-----------------------------------------------
    INITIALISATION DES SONS
 ------------------------------------------------*/
function initSounds() {
  this.createEmptyMovieClip( "musicGameMC", this.calcDepth(DP_SOUNDS) ) ;
  this.createEmptyMovieClip( "musicMenuMC", this.calcDepth(DP_SOUNDS) ) ;
  this.createEmptyMovieClip( "engineUpMC", this.calcDepth(DP_SOUNDS) ) ;
  this.createEmptyMovieClip( "engineDownMC", this.calcDepth(DP_SOUNDS) ) ;
  this.createEmptyMovieClip( "engineMiscMC", this.calcDepth(DP_SOUNDS) ) ;
  musicGame.isPlaying = false ;
  musicMenu.isPlaying = false ;
}



/*-----------------------------------------------
    INITIALISATION DES SONS
 ------------------------------------------------*/
function initEngine() {
  engineUp = playSoundInMC("engineUp", engineUpMC, 0,0, 99999 ) ;
  engineDown = playSoundInMC("engineDown", engineDownMC, 0,0, 99999 ) ;
  engineMisc = playSoundInMC("engineOff", engineMiscMC, 0,0, 999999 ) ;
  engineUp.vol = 0 ;
  engineDown.vol = 0 ;
  engineUp.stop() ;
  engineDown.stop() ;
  engineMisc.stop() ;
//  engineUp.setVolume(0) ;
//  engineDown.setVolume(0) ;
//  engineMisc.setVolume(0) ;
}



/*-----------------------------------------------
    GESTION DU SON DU MOTEUR
 ------------------------------------------------*/
function playEngine(currentSpeed, previousSpeed, maximumSpeed) {
  var offset = currentSpeed / maximumSpeed * 7 ;

  var speedMod = Math.abs(currentSpeed - previousSpeed) ;
  if ( lastSpeedMod > speedMod ) {
    engineUp.isPlaying = false ;
    engineDown.isPlaying = false ;
  }
  lastSpeedMod = speedMod ;
  var volSpeed = 40 ;

  // Stationnaire
  if ( currentSpeed <= 2 ) {
    if ( !engineMisc.isPlaying ) {
      engineMisc.start(0,99999) ;
      engineMisc.isPlaying = true ;
    }
  }
  else {
    if ( engineMisc.isPlaying ) {
      engineMisc.stop() ;
      engineMisc.isPlaying = false ;
    }
  }

  if ( previousSpeed < currentSpeed ) {
    // Accélération
    if ( !engineUp.isPlaying ) {
      engineDown.stop() ;
      engineUp.stop() ;
      engineUp.start( offset, 9999 ) ;
    }

//    if ( engineDown.isPlaying ) engineDown.stop() ;
    engineUp.vol = Math.min( 100, engineUp.vol + gtmod*volSpeed*2 ) ;
    engineDown.vol = Math.max( 0, engineDown.vol - gtmod*volSpeed ) ;
    engineUp.isPlaying = true ;
    engineDown.isPlaying = false ;
  }
  else {
    // Ralentissement
//    if ( engineUp.isPlaying ) engineUp.stop();
    if ( !engineDown.isPlaying ) {
      engineDown.stop() ;
      engineUp.stop() ;
      engineDown.start( 7-offset, 9999 ) ;
    }
    engineUp.vol = Math.max( 0, engineUp.vol - gtmod*volSpeed ) ;
    engineDown.vol = Math.min( 100, engineDown.vol + gtmod*volSpeed ) ;
    engineUp.isPlaying = false ;
    engineDown.isPlaying = true ;
    if ( engineDown.prevPos != undefined && engineDown.prevPos > engineDown.position ) {
//      engineDown.stop() ;
//      engineMisc.start(0.5,9999) ;
//      delete engineDown.prevPos ;
    }
    else
      engineDown.prevPos = engineDown.position ;
  }
//  engineUp.setVolume( engineUp.vol ) ;
//  engineDown.setVolume( engineDown.vol ) ;
}

