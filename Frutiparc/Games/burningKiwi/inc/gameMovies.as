/*-----------------------------------------------
    CLEAN EM ALL !
 ------------------------------------------------*/
function cleanAll() {
  var i ;
  for ( i=0;i<cars.length;i++)
    cars[i].removeMovieClip() ;
  for ( i=0;i<fx.length;i++)
    fx[i].removeMovieClip() ;
  for ( i=0;i<bgFx.length;i++)
    bgFx[i].removeMovieClip() ;
  for ( i=0;i<trackTopItems.length;i++)
    trackTopItems[i].removeMovieClip() ;
  for ( i=0;i<timeLines.length;i++)
    timeLines[i].removeMovieClip() ;
  for ( i=0;i<buttons.length;i++)
    buttons[i].removeMovieClip() ;

  cars = new Array() ;
  fx = new Array() ;
  bgFx = new Array() ;
  trackTopItems = new Array() ;
  timeLines = new Array() ;
  buttons = new Array() ;

  announce.removeMovieClip() ;
  arrow.removeMovieClip() ;
  blackBg.removeMovieClip() ;
  chronoSummary.removeMovieClip() ;
  finalScrolls.removeMovieClip() ;
  gameOver.removeMovieClip() ;
  ghostCar.removeMovieClip() ;
  giveUpBox.removeMovieClip() ;
  goBox.removeMovieClip() ;
  grille.removeMovieClip() ;
  intro.removeMovieClip() ;
  keys.removeMovieClip() ;
  kiwiCounter.removeMovieClip() ;
  kiwiItem.removeMovieClip() ;
  limited.removeMovieClip() ;
  logo.removeMovieClip() ;
  menuMC.removeMovieClip() ;
  panelMC.removeMovieClip() ;
  pauseBox.removeMovieClip() ;
  perfectMC.removeMovieClip() ;
  preloader.removeMovieClip() ;
  startAnim.removeMovieClip() ;
  sBox.removeMovieClip() ;
  summary.removeMovieClip() ;
  teamList.removeMovieClip() ;
  track.skin.unloadMovie() ;
  track.removeMovieClip() ;

}



/*-----------------------------------------------
    MAIN TRACK LOADER
 ------------------------------------------------*/
function attachTrack(id) {
  var i ;

  track._visible = true ;
  track.skin.sub._xscale = 100 ;
  track.skin.sub._yscale = 100 ;

  track.id=id ;
  track.skin.sub.outZone._visible = false ;

  // Stats de course
  track.stats = tracks[id] ;
  track.difficulty = track.stats.difficulty ;


  // Objets de premier plan présents sur la course
  i=0 ;
  while (i<tracks[id].topItems.length) {
    item = tracks[id].topItems[i] ;
    d = track.calcDepth(DP_TRACKTOP) ;
    track.attachMovie (item.id, "trackTopItem_"+d, d) ;
    mc = track["trackTopItem_"+d] ;
    mc._x = item.x ;
    mc._y = item.y ;
    mc._rotation = item.ang ;
    trackTopItems.push( mc ) ;
    i++ ;
  }


  // Voitures
  skinPool=new Array() ;
  for (i=0 ; i<4 ; i++) {
    skinPool.push(i+1) ;
  }
  i=0 ;

  // Spécificités des modes de jeu
  maxCars = 4 ;
  if ( vs.gameMode == DUEL ) {
    maxCars = 2 ;
//    track.difficulty *= 1.15 ;
    switch ( vs.selectedAdv ) {
        case 0 : mc.nitroAgg=0.95 ; track.difficulty *= 0.95 ; break ; // UltraOrange
        case 1 : mc.nitroAgg=0.75 ; track.difficulty *= 0.87 ; break ; // UWE wing
        case 2 : mc.nitroAgg=0.95 ; track.difficulty *= 0.85 ; break ; // Fury Hun
        case 3 : mc.nitroAgg=1.10 ; track.difficulty *= 0.90 ; break ; // Sonic Brain
        case 4 : mc.nitroAgg=1.50 ; track.difficulty *= 1.18 ; break ; // KiwiX
    }
  }

  if ( vs.gameMode == ARCADE || vs.gameMode == TRAINING )
    track.difficulty *= 0.79 ;

  if ( vs.gameMode == KIWIRUN || vs.gameMode == TUTORIAL )
    maxCars = 1 ;

  if ( vs.gameMode == TIMETRIAL )
    maxCars = 1 ;

  if ( vs.gameMode == GHOSTRUN ) {
    maxCars = 1 ;
    skipGhost = false ;
    ghost = createGhost() ;
    if ( previousGhost != undefined ) {
      attachGhost( vs.selectedCar ) ;
      previousGhost.current = 0 ;
    }
  }

  if ( specials[2].state ) {
    track.difficulty *= 0.60 ;
  }

  if ( vs.gameMode == FRUTICUP )
    if ( !vs.$wcs )
      track.difficulty *= 0.72 ;
    else
      track.difficulty *= 1.15 ;

  while ( i < tracks[id].startPoints.length && i < maxCars ) {
    startPoint = tracks[id].startPoints[i] ;
    carId = startPoint.id ;
    if (carId == 0)
      attachCar(startPoint.id, carStats[vs.selectedCar], startPoint.x, startPoint.y, startPoint.ang) ;
    else
      attachCar(startPoint.id, tracks[id].carStatsIA, startPoint.x, startPoint.y, startPoint.ang) ;
    i++ ;
  }

  if ( specials[2].state ) { // Cheat DRONE
    var maxDrones = 5 ;
    if ( vs.gameMode == TUTORIAL )
      maxDrones = 10 ;
    for (var i=0;i<maxDrones;i++) {
      var rCP, rCPid ;
      rCPid = random(CP[id].length-4)+3 ;
      rCP = CP[id][ rCPid ] ;
      attachCar(i+4, tracks[id].carStatsIA, rCP.x, rCP.y, rCP.ang) ;
      cars[i+4].currentCP = rCPid ;
      cars[i+4].totalCP = -30 ;
      cars[i+4].nextX = CP[id][rCPid].x ;
      cars[i+4].nextY = CP[id][rCPid].y ;
    }
  }

  // Mode nocturne
  if ( nightMode ) {
    setColor(track, 100,nightOffset, 100,nightOffset, 100,nightOffset*0.3) ;
    setColor(track.skin.sub.lights, 100,-nightOffset, 100,-nightOffset, 100,-nightOffset*0.3) ;
  }
}



/*------------------------------------------------------------------------
    ATTACHE LE GHOST
 ------------------------------------------------------------------------*/
function attachGhost(id) {
  d = track.calcDepth(DP_CARS) ;
  track.attachMovie("car","ghostCar",d) ;
  ghostCar = track.ghostCar ;
  ghostCar._alpha = ghostAlpha ;

  ghostCar.stop() ;
  stopBoostAnim(ghostCar) ;
  ghostCar.skin.gotoAndStop( carStats[id].skin ) ;
}



/*-----------------------------------------------
    ATTACHE UNE VOITURE
 ------------------------------------------------*/
function attachCar(id, stats, x,y,rot) {
  var mc, mcSh ;

  d = track.calcDepth(DP_SHADOWS) ;
  track.attachMovie("carShadow","carShadow_"+id,d) ;
  mcSh = track["carShadow_"+id] ;
  d = track.calcDepth(DP_CARS) ;
  track.attachMovie("car","car_"+id,d) ;
  mc = track["car_"+id] ;

  if ( nightMode )
    setColor(mc, 100,-nightOffset, 100,-nightOffset, 100,-nightOffset) ;
  else
    mc.lights._visible = false ;

  mc.x = x ;
  mc.y = y ;
  mc._x = x ;
  mc._y = y ;
  mc._rotation = rot ;

  // Ombre
  mcSh._x = mc._x + shadowShift ;
  mcSh._y = mc._y + shadowShift ;
  mcSh._rotation = mc._rotation ;

  // Objet secure de la voiture
  mc.vs = new Object() ;
  mc.vs.vsInit("vsCar"+id) ;
  mc.vs.laps = 0 ;
  mc.vs.kiwis = stats.kiwis ;
  mc.vs.offRoad = 0 ;
  mc.vs.offRoadTotal = 0 ;
  mc.vs.collisions = 0 ;
  mc.vs.perfects = 0 ;
  mc.vs.collisionsTotal = 0 ;
  mc.vs.totalTime = 0 ;
  mc.vs.bestLap = Infinity ;
  mc.vs.topSpeed = 0 ;
  mc.vs.immuneHit = 0 ;
  mc.vs.vsSecureAll() ;

  mc.nitroAgg = 0.90 ;

  mc.preImmune = 0 ;


  if ( mc.vs.kiwis > maxKiwis )
    fatal("Surchauffe du moteur", "invalid "+mc.vs.kiwis+" nitros (car id="+id+")") ;

  // Caracteristiques du véhicule
  mc.statRot = stats.rot ;
  mc.statAccel = stats.accel ;
  mc.statBrake = stats.brake ;
  mc.statTurning = stats.turning ;
  mc.statMaxSpeed = stats.maxSpeed ;
  mc.statGrip = stats.grip ;
  mc.currentMaxSpeed = stats.maxSpeed ;
//  mc.statMaxSpeedBoost = stats.maxSpeedBoost ;
  mc.statKiwis = stats.kiwis ;

  // L'IA a des stats déclinée d'une base commune, mais pondérées par quelques facteurs
  if (stats.skin == -1) {
    fact = (0.85 + random(30)/100) * track.difficulty ;
    mc.statAccel *= fact ;

    fact = (0.80 + random(40)/100) * track.difficulty ;
    if ( specials[2].state ) // Cheat DRONE
      fact *= random(80)/100 + 0.5 ;
    mc.statMaxSpeed *= fact ;

    fact = (0.85 + random(30)/100) * track.difficulty ;
    mc.statGrip *= fact ;

//    mc.maxSpeedBoost = 1 ;
    mc.nitroBoost = 0 ;
//    if ( vs.gameMode == DUEL )
      mc.vs.kiwis = Infinity ;
//    else
//      mc.vs.kiwis = random(5)+8 ;
    mc.rotationBoost = 1 ;
    mc.CPdistanceTolerance = 1 ;
    if ( vs.gameMode == DUEL || random(4)==0 ) { // duel ou voiture "aggressive"
      mc.CPdistanceTolerance = 1 ;
      mc.nitroAgg *= 0.5 ;
    }

    if ( EDITORMODE )
      mc.skill = 0 ;
    else
      if ( vs.gameMode == DUEL ) // Duel
        mc.skill = 0.90 + random(10)/100 ;
      else
        mc.skill = random(20)/100 ;

//    trace("id:"+id+" acc="+mc.statAccel+" maxspd="+mc.statMaxSpeed+" grip="+mc.statGrip+" skill="+mc.skill) ;
  }


  // on enlève la voiture du pool restant
  if ( stats.skin != -1 ) {
    mc.skinId = stats.skin ;
    if ( id==0 && mc.skinId==1 && specials[5].state )
      mc.skinId=41 ;
    else
      if ( id==0 && specials[4].state ) {
        mc.skinId+=20 ;
      }
    mc.carName = carSkinNames[mc.skinId-1] ;
    gdebug("Driving : "+mc.carName) ;
    for (n=0 ; n<skinPool.length ; n++)
      if (skinPool[n]==mc.skinId) {
        skinPool.splice(n,1) ;
        break ;
      }
  }
  else {
    if ( vs.gameMode == DUEL ) { // TimeTrial
      mc.skinId = vs.selectedAdv+1 ;
      mc.carName = carSkinNames[mc.skinId-1] ;
    }
    else
      if ( specials[2].state ) {// Cheat DRONE
        mc.carName = "Drone" ;
        mc.skinId = 6 ;
      }
      else {
        // ou on lui attribue un skin du pool restant
        mc.skinId = skinPool[ 0 ] + 7 ;
        skinPool.splice( 0, 1 ) ;
        mc.carName = carSkinNames[mc.skinId-8] ;
      }
  }


  mc.skin.gotoAndStop( mc.skinId ) ;

  // Initialisations des forces
  mc.speed = 0 ;
  mc.speedA = 0 ;
  mc.accelAng = mc._rotation ;

  // Divers
  mc.speedCounter = 0 ;

  mc.currentCP = -1 ;

  // Variables de gameplay
  mc.nitroTimer = 0 ;
  mc.panic = 0 ;
  mc.spawnImmune = 0 ;
  mc.didAllCP = false ;
  mc.derapage = 0 ; // en fin de course, pour la frime

  mc.stop() ;
  stopBoostAnim(mc) ;

  cars[id] = mc ;
  carShadows[id] = mcSh ;
}



/*-----------------------------------------------
    FX: fumée
 ------------------------------------------------*/
function spawnSmoke(id, x,y, dx,dy, scale, ecartRandom, onTop) {
  var d,mc ;

  if (onTop)
    d = track.calcDepth(DP_FXTOP,false) ;
  else
    d = track.calcDepth(DP_FX,false) ;
  track.attachMovie(id,"smoke_"+d,d) ;
  mc=track["smoke_"+d] ;

  x+=random(ecartRandom)*( random(2)*2-1 ) ;
  y+=random(ecartRandom)*( random(2)*2-1 ) ;
/*  x+=random(ecartRandom)*( random(2)*2-1 ) ;
  y+=random(ecartRandom)*( random(2)*2-1 ) ;*/
  mc._x=x ;
  mc._y=y ;
  mc.dx=dx ;
  mc.dy=dy ;
  mc.friction=Math.pow(0.8,gtmod) ;

  mc._xscale=scale ;
  mc._yscale=scale ;

  if (dx!=0 || dy!=0) {
    fx.push(mc) ;
  }
}


/*-----------------------------------------------
    FX: chocs car-car
 ------------------------------------------------*/
function spawnHitCar(x,y, dx,dy) {
  var d,mc ;

  d = track.calcDepth(DP_FX) ;
  track.attachMovie("hitCar","hitCar_"+d,d) ;
  mc=track["hitCar_"+d] ;

  x+=random(4)*( random(2)*2-1 ) ;
  y+=random(4)*( random(2)*2-1 ) ;
  mc._x=x ;
  mc._y=y ;
  mc.dx = 0.5*dx + 0.2*(random(5)*( random(2)*2-1 )) ;
  mc.dy = 0.5*dy + 0.2*(random(5)*( random(2)*2-1 )) ;
  mc.friction=Math.pow(0.9,gtmod) ;

  mc._xscale=random(50)+80 ;
  mc._yscale=mc._xscale ;
  mc.gotoAndPlay( random(20)+1 ) ;

  fx.push(mc) ;
}


/*-----------------------------------------------
    Panel d'affichage dans le jeu
 ------------------------------------------------*/
function attachPanel() {
  var d = this.calcDepth(DP_INTERF) ;
  attachMovie ("panel", "panelMC", d) ;
  panelMC._x = 0 ;
  panelMC._y = 346 ;
  panelMC.initDepth() ;
  panelMC.bar.stop() ;
  panelMC.pos_txt.text = "" ;

  // Jetons de classement
  panelMC.jeton1.stop() ;
  panelMC.jeton2.stop() ;
  panelMC.jeton3.stop() ;
  panelMC.jeton4.stop() ;

  // Kiwis
  for (var i=0;i<cars[0].vs.kiwis;i++) {
    var mc ;
    d = panelMC.calcDepth(DP_INTERF) ;
    panelMC.attachMovie("nitroMC", "nitro_"+i, d ) ;
    mc = panelMC["nitro_"+i] ;
    mc._x = 189 + i*24 ;
    mc._y = -14 ;
    mc.stop() ;
  }
}



/*-----------------------------------------------
    AFFICHE LE TEMPS D'UN TOUR
 ------------------------------------------------*/
function attachTimeLine(lap, time, perfect, bestLap, bestRace, prevTime) {
  var d,mc, frame ;

  d = this.calcDepth(DP_INTERF) ;
  this.attachMovie("timeLine","timeLine_"+d, d) ;
  mc = this["timeLine_"+d] ;
  mc._y = lap * timeLinesHeight + timeLinesY ;
  mc.txt = "Tour "+ (lap+1) +" - "+ timeToString( time ) ;

  if ( lap == 0 )
    mc.progress._visible = false ;
  else {
    if ( time==prevTime )
      mc.progress_txt = "Même temps !"
    if ( time>prevTime )
      mc.progress_txt = "+ "+timeToString( time-prevTime ) ;
    if ( time<prevTime )
      mc.progress_txt = "- "+timeToString( prevTime-time ) ;
  }

  if ( perfect )
    mc.txt += " (P)" ;

  frame = 1 ;

  if ( bestLap ) {
    mc.txt += " *" ;
    frame = 2 ;
  }

  if ( bestRace ) {
    mc.txt += " *" ;
    mc.progress._visible = false ;
    frame = 3 ;
  }

  mc.gotoAndStop(frame) ;

  timeLines.push(mc) ;
}



/*-----------------------------------------------
    AFFICHE LE PERFECT LAP
 ------------------------------------------------*/
function attachPerfect() {
  perfectMC.removeMovieClip
  attachMovie( "perfect","perfectMC",  this.calcDepth(DP_FXTOP) ) ;
  perfectMC._x = (docWidth/2) ;
  perfectMC._y = 37 ;
}



/*------------------------------------------------------------------------
    AFFICHE L'INDICATEUR DE SUPER DÉPART
 ------------------------------------------------------------------------*/
function attachSuperStart() {
  this.attachMovie("superPop","superPop",this.calcDepth(DP_FXTOP) ) ;
  superPop._x = docWidth/2 ;
  superPop._y = docHeight-50 ;
  if ( vs.startBoost > 0.6 )
    superPop.sub.sub.gotoAndStop(1) ;
  else
    superPop.sub.sub.gotoAndStop(2) ;
}



/*-----------------------------------------------
    AFFICHE LE NOUVEAU TOUR
 ------------------------------------------------*/
function attachLap(lap) {
  var d ;
  d = this.calcDepth(DP_FXTOP) ;
  chronoSummary.removeMovieClip() ;
  attachMovie( "chronoSummary","chronoSummary", d ) ;
  chronoSummary._x = (docWidth/2) ;
  chronoSummary._y = 5 ;
  chronoSummary.tour = lap+1 ;
}



/*-----------------------------------------------
    AFFICHE L'ANNONCE DU DEPART
 ------------------------------------------------*/
function attachGoPop() {
  var d ;
  d = this.calcDepth(DP_FXTOP) ;
  goBox.removeMovieClip() ;
  attachMovie( "goBox","goBox", d ) ;
  goBox._x = (docWidth/2) ;
  goBox._y = 50 ;
}



/*-----------------------------------------------
    AFFICHE L'INDICATEUR DE TRANSFERT
 ------------------------------------------------*/
function attachNetworkPop() {
  detachNetworkPop() ;
  attachMovie( "networkPop","networkPop", this.calcDepth(DP_FXTOP) ) ;
  networkPop._x = (docWidth/2) ;
  networkPop._y = (docHeight/2) ;
}


/*-----------------------------------------------
    DÉTACHE L'INDICATEUR DE TRANSFERT
 ------------------------------------------------*/
function detachNetworkPop() {
  networkPop.removeMovieClip() ;
}


/*------------------------------------------------------------------------
    DÉMARRE L'ANIM DE BOOST NITRO
 ------------------------------------------------------------------------*/
function startBoostAnim(car) {
  car.boost._visible = true ;
  car.boost.gotoAndPlay(1) ;
  car.instantBoost._visible = true ;
  car.instantBoost.gotoAndPlay(1) ;
}



/*------------------------------------------------------------------------
    STOPPE L'ANIM DE BOOST NITRO
 ------------------------------------------------------------------------*/
function stopBoostAnim(car) {
  car.boost._visible = false ;
  car.boost.stop() ;
  car.instantBoost._visible = false ;
  car.instantBoost.stop() ;
}




/*------------------------------------------------------------------------
    DÉFINI UN FILTRE DE COULEUR SUR LE MC
 ------------------------------------------------------------------------*/
  function setColor( mc, rPct,rAlpha, gPct,gAlpha, bPct,bAlpha ) {
    var obj = {
      ra:rPct,rb:rAlpha,
      ga:gPct,gb:gAlpha,
      ba:bPct,bb:bAlpha,
      aa:100,ab:0
    };
    var color = new Color(mc) ;
    color.setTransform(obj) ;
  }


/*------------------------------------------------------------------------
    DÉFINI LA LUMINOSITÉ DE L'ENTITÉ
 ------------------------------------------------------------------------*/
  function setLuminosity(mc,offset) {
    setColor( mc,100,offset, 100,offset, 100,-offset ) ;
  }
