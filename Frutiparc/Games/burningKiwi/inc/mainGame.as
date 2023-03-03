/*-----------------------------------------------
    BOUCLE MAIN GAME
 ------------------------------------------------*/
function mainGame() {

  // Mode AUTO de gestion de la qualité
  if ( !gamePaused && qualitySetting == AUTO && gameQuality > LOW ) {
    checkFPS -= gtmod ;
    if ( checkFPS <= 0 ) {
      if ( FPS <= qualitySteps[gameQuality] )
        setDetailLevel( gameQuality-1 ) ;
      checkFPS = baseCheckFPS ;
    }
  }


  // Départ
  if ( gamePaused && starting )
    mainStart() ;

  // Forcage de la pause par le serveur
  if ( !gamePaused && client.forcePause == true ) {
    togglePause() ;
  }


  // Fin de partie
  if ( timerEnd > 0 ) {
    timerEnd -= gtmod ;
    if ( timerEnd <= 0 ) {
      if ( vs.gameMode == FRUTICUP || vs.gameMode == SURVIVOR )
        updateTournament() ;
      updateRace() ;
      vs.mainPhase = 2 ;
    }
  }


  // Saisie des touches de jeu (pas les touches de controle du joueur)
  getControls() ;


  if (!gamePaused) {
    // Effets spéciaux
    moveFx() ;

    // Jeu
    manageGame() ;

    // Panneau d'affichage du jeu
    if (panelON && !starting) {
      // Gestion du classement
      if ( !cars[trackedCar].finished && vs.gameMode!=TUTORIAL && vs.gameMode!=TIMETRIAL && vs.gameMode!=DUEL ) {
        orderSkip += gtmod ;
        if (orderSkip >= 3 ) {
          orderSkip = 0 ;
          getOrder(trackedCar) ;
          for (var i=0;i<orderList.length;i++)
            if ( orderList[i]==0 ) {
              panelMC.pos_txt.text = i+1 ;
              break ;
            }
        }
      }

      cars[trackedCar].vs.topSpeed = Math.max( cars[trackedCar].vs.topSpeed, cars[trackedCar].speed ) ;
      cars[trackedCar].speedCounter = 0.8*cars[trackedCar].speedCounter + 0.2*cars[trackedCar].realSpeed ;
      panelMC.maskSpeedBar._width = ( cars[trackedCar].speedCounter * 95 ) / cars[trackedCar].statMaxSpeed ;
      if ( cars[trackedCar].speedCounter >= cars[trackedCar].statMaxSpeed )
        panelMC.bar.play() ;
      else
        panelMC.bar.gotoAndStop(1) ;
    }
    // Affichage du chrono
    if ( cars[trackedCar].finished )
      hideChrono() ;
    else
      updateChrono( cars[trackedCar].timerLap ) ;
  }

  // Recalage du scrolling sur une voiture
  scrolling(cars[trackedCar]) ;


  // Kiwi-run
  if ( vs.gameMode == KIWIRUN )
    if ( !gamePaused )
      manageKiwis() ;


}



/*-----------------------------------------------
    CODE DU JEU
 ------------------------------------------------*/
function manageGame() {

  if (vs.nitroFlag)
    carPJ.pct=0.01 ;
  else
    carPJ.pct=0.02 ;
//  carPJ.pct=Math.min(carPJ.speed/maxSpeed,0.993) ;


  if ( carPJ.preImmune>0 ) {
    carPJ.preImmune -= gtmod ;
    if ( carPJ.preImmune <= 0 )
      carPJ.vs.immuneHit = baseImmuneHit ;
  }

  if ( carPJ.vs.immuneHit>0 ) {
    carPJ.vs.immuneHit -= gtmod ;
    if ( carPJ.vs.immuneHit <= 0 )
      carPJ.vs.immuneHit = 0 ;
  }


  // Correction du bug de hittest foireux d'une frame sur l'autre
  if (!EDITORMODE) {
    pt={x:carPJ.x, y:carPJ.y} ;
    track.localToGlobal(pt) ;
    if (track.skin.sub.outZone.hitTest(pt.x,pt.y, true)==true) {
      carPJ.x=carPJ.oldX ;
      carPJ.y=carPJ.oldY ;
    }
  }

  var previousSpeed = carPJ.realSpeed ;

  // Son moteur
//  if ( soundsON ) {
//    var spd = cars[trackedCar].speed ;
//    var seuil = 4 ;
//    if ( spd >=0 && spd < seuil*2 ) {
//      var c = Math.cos( ( Math.PI*(spd-0) ) / (seuil*2) - Math.PI/2 ) ;
//      motor01.setVolume( Math.round(c*100) ) ;
//    }
//    else
//      motor01.setVolume(0) ;
//
//    if ( spd >=seuil && spd < seuil*3 ) {
//      var c = Math.cos( ( Math.PI*(spd-seuil) ) / (seuil*2) - Math.PI/2 ) ;
//      motor02.setVolume( Math.round(c*100) ) ;
//    }
//    else
//      motor02.setVolume(0) ;
//
//    if ( spd >=seuil*2 && spd < seuil*4 ) {
//      var c = Math.cos( ( Math.PI*(spd-seuil*2) ) / (seuil*2) - Math.PI/2 ) ;
//      motor03.setVolume( Math.round(c*100) ) ;
//    }
//    else
//      motor03.setVolume(0) ;
//  }


  // ** BOOST DE NITRO
  if ( !carPJ.finished ) {
    if ( vs.nitroFlag && ( carPJ.nitroTimer>0 || nitroStopped ) ) {
      carPJ.nitroTimer -= gtmod ;
      if ( vs.startBoost == 0 )
        panelMC["nitro_"+carPJ.vs.kiwis].nitro.liquid._y = 12 - (carPJ.nitroTimer*19) / baseNitroTimer ;
      if ( carPJ.nitroTimer <= 0 || nitroStopped ) {
        stopBoostAnim(carPJ) ;
        carPJ.nitroTimer = 0 ;
        vs.nitroFlag = false ;
        nitroStopped = false ;
        accelBoost = 1 ;
        if ( !specials[3].state ) // Cheat GHOST
           carPJ.vs.immuneHit = 0 ;
        carPJ.currentMaxSpeed = carPJ.statMaxSpeed ;
        if ( vs.startBoost == 0 )
          panelMC["nitro_"+carPJ.vs.kiwis].gotoAndStop(3) ;
        vs.startBoost = 0 ;
      }
    }

    if ( (Key.isDown(controls[4]) && !vs.nitroFlag && !hitBorder && carPJ.vs.kiwis ) ||
         (!vs.nitroFlag && vs.startBoost>0) ) {
      // Coût du boost
      if ( vs.startBoost == 0 ) {
        carPJ.vs.kiwis -- ;
        carPJ.usedKiwis ++ ;
      }
      else {
        attachSuperStart() ;
        carPJ.vs.immuneHit = baseImmuneHit ;
      }
      // Anim dans le panel
      if ( vs.startBoost == 0 )
        panelMC["nitro_"+carPJ.vs.kiwis].gotoAndStop(2) ;
      // Facteur modifiant le boost, pour le cas du super départ
      var factor = vs.startBoost/2 ;
      if ( factor == 0 ) factor = 1 ;
      // Application du boost
      vs.nitroFlag=true ;
      startBoostAnim(carPJ) ;
      accelBoost = Math.pow( 9*factor, 1/gtmod ) ;
//      maxSpeedBoost = carPJ.statMaxSpeedBoost ;
      carPJ.currentMaxSpeed = nitroMaxSpeed ;
      if ( specials[1].state ) // cheat BOOST
        carPJ.currentMaxSpeed *= 1.5 ;
      nitroStopped = false ;
      carPJ.nitroTimer = baseNitroTimer*factor ;

    }



    // Calcul des pertes sur les rotations selon la vitesse
    rotationVitesseLente=Math.max(0, carPJ.statRot-(carPJ.speed*5)*0.7) ;
    if ( vs.nitroFlag )
      if ( specials[1].state ) // Cheat BOOST
        rotationVitesseRapide=Math.max(0,carPJ.speed*0.15) ;
      else
        rotationVitesseRapide=Math.max(0,carPJ.speed*0.3) ;
    else
      rotationVitesseRapide=Math.max(0,carPJ.speed*0.52) ;



    // ** ROTATIONS
    if (Key.isDown(controls[2])) {
      carPJ._rotation -= gtmod * ( Math.max(0,carPJ.statRot-rotationVitesseRapide-rotationVitesseLente) ) ;
      carPJ.speed*=Math.pow(carPJ.statTurning, gtmod) ;
      carPJ.signLastRotation = -1 ;
    }
    if (Key.isDown(controls[3])) {
      carPJ._rotation += gtmod * ( Math.max(0,carPJ.statRot-rotationVitesseRapide-rotationVitesseLente) ) ;
      carPJ.speed*=Math.pow(carPJ.statTurning, gtmod) ;
      carPJ.signLastRotation = 1 ;
    }


    // ** ACCÉLÉRATION
    if ( Key.isDown(controls[0]) || debugAutoAccel || carPJ.nitroTimer>0 ) {
      // calcul de l'angle vers le calcul on accélère
      ecart=getAngle(carPJ._rotation-carPJ.accelAng) ;
      carPJ.accelAng = getAngle (carPJ.accelAng +gtmod * (carPJ.pct*ecart*2)) ;
      carPJ.speed += gtmod * ( ((carPJ.currentMaxSpeed-carPJ.speed)/(carPJ.currentMaxSpeed+15))*carPJ.statAccel*accelBoost ) ;
      if (hitBorder==0 && carPJ.speed <= carPJ.statMaxSpeed*0.7)
        if ( gameQuality >= MEDIUM )
          spawnSmoke ("smokeAccel", carPJ.x,carPJ.y, 0,0, Math.max(10,100-carPJ.speed*2), 6, true) ;
    }
    else {
      if (carPJ.speed<=0.05) carPJ.speed=0 ;
      if ( carPJ.speed > carPJ.currentMaxSpeed ) {
        carPJ.speed *= Math.pow(0.99, gtmod) ;
      }
    }
  }


  // ** FREINAGE
  if (carPJ.finished || Key.isDown(controls[1]) ) {
    if (carPJ.finished && carPJ.skinId==5) // KiwiX
      carPJ.speed *= 0.98 ;
    else
      carPJ.speed *= Math.pow(carPJ.statBrake, gtmod) ;
    if (carPJ.speed<=0.4) carPJ.speed = 0 ;
//    nitroStopped = true ;
  }

  // Dérapage en fin de course
  if ( carPJ.finished ) {
    // Init du dérapage
    if ( carPJ.derapage == 0 ) {
      carPJ.targetRotation = carPJ._rotation + (90+random(50)) * ( random(2)*2-1 ) ;
      carPJ.derapage = 1 ;
      carPJ.oldRotation = carPJ._rotation ;
    }
    // On "dérape" jusqu'à la rotation désirée
    if ( carPJ.derapage == 1 ) {
      carPJ._rotation += gtmod * ( (carPJ.targetRotation - carPJ._rotation)/20 ) ;
      if ( Math.abs(carPJ.targetRotation-carPJ._rotation) <= 10*gtmod || Math.abs(carPJ.targetRotation-carPJ._rotation) > 160 )
        carPJ.derapage = 2 ;
      // Fumée
      if ( gameQuality >= MEDIUM )
        spawnSmoke ("smokeSkid", carPJ.x,carPJ.y, random(80)+20, preSinA*carPJ.speedA*1.5*((random(4)+6)/10), carPJ.speedA*100/10, 5, false) ;
    }
  }

  // Gestion des IAs
  moveIA() ;
//  for (i=1;i<cars.length;i++)
//    testHitCar( carPJ, cars[i] ) ;


  // Frictions et plafonds
  carPJ.speed*=Math.pow( roadFriction,gtmod) ;
  ratio=Math.pow(0.9,gtmod) ;
  carPJ.speedA=carPJ.speedA*ratio+carPJ.speed*(1-ratio) ;
  speedLeft = gtmod * carPJ.speed ;
  speedALeft = gtmod * carPJ.speedA ;




  // On précalcule les constantes
  pi180= Math.PI/180;
  rotRadA=pi180 * carPJ.accelAng;
  preCosA=Math.cos(rotRadA) ;
  preSinA=Math.sin(rotRadA) ;

  if ( carPJ.derapage ) {
    rotRad = pi180 * carPJ.oldRotation ;
  }
  else {
    rotRad = pi180 * carPJ._rotation ;
  }
//  rotRad=pi180 * carPJ._rotation;
  preCos=Math.cos(rotRad) ;
  preSin=Math.sin(rotRad) ;

  carPJ.oldX=carPJ.x ;
  carPJ.oldY=carPJ.y ;
  carPJ.dx=0 ;
  carPJ.dy=0 ;
  carPJ.realSpeed=0 ;

  // ** STEPPING
  do {
    step = stepMax ;
    if (step>=speedLeft) step=speedLeft ;
    speedLeft-=step ;

    stepA = stepMax ;
    if (stepA>speedALeft) stepA=speedALeft ;
    speedALeft-=stepA ;

    recalc=false ;
    do {
      // Application des mouvements
      dxA=preCosA*(stepA) ;
      dyA=preSinA*(stepA) ;

      dx=preCos*step ;
      dy=preSin*step ;

      // Calcul des DX,DY finaux
      dxTotal=(carPJ.statGrip*dx+(1-carPJ.statGrip)*dxA) ;
      dyTotal=(carPJ.statGrip*dy+(1-carPJ.statGrip)*dyA) ;


      // Si on est dans la terre, on modifie le step par la friction et on recalcule
      if (recalc)
        recalc=false ;
      else {
        if (!EDITORMODE) {
          pt={x:carPJ.x+dxTotal, y:carPJ.y+dyTotal} ;
          track.localToGlobal(pt) ;
          if ( track.skin.sub.borderZone.hitTest(pt.x, pt.y, true) ) {
            hitBorder=3 ;
            if ( carPJ.offRoadTimer == undefined && !carPJ.finished )
              carPJ.offRoadTimer = getTimer() ;
          }
          if (hitBorder) {
//            nitroStopped = true ;
//            accelBoost = 1 ;
//            carPJ.currentMaxSpeed = carPJ.statMaxSpeed ;
            step=Math.min(borderMaxSpeed,step) ;
            stepA=Math.min(borderMaxAccelSpeed,stepA) ;
            recalc=true ;
          }
          else {
            if ( carPJ.offRoadTimer ) {
              carPJ.vs.offRoad += getTimer() - carPJ.offRoadTimer ;
              delete carPJ.offRoadTimer ;
            }
          }
        }
      }
    } while (recalc) ;

    if (hitBorder && !EDITORMODE) {
      track.skin.sub.outZone._visible = true ;
      pt={x:carPJ.x+dxTotal, y:carPJ.y+dyTotal} ;
      track.localToGlobal(pt) ;
      if (track.skin.sub.outZone.hitTest(pt.x, pt.y, true)==true) {
        carPJ.speed=1 ;
        carPJ._rotation = getAngle( carPJ._rotation + gtmod * ( carPJ.signLastRotation * 3) ) ;
        carPJ.accelAng = carPJ._rotation ;
        break ;
      }
    }

    carPJ.realSpeed+=step ;

    carPJ.x+=dxTotal ;
    carPJ.y+=dyTotal ;

    carPJ.dx+=dxTotal ;
    carPJ.dy+=dyTotal ;

    // Test si le joueur ramasse le kiwi en cours (kiwi-run)
    if ( vs.gameMode == KIWIRUN )
      if ( carPJ.hitTest(kiwiItem) ) {
        kiwiItem.removeMovieClip() ;
        playSoundBK("kiwiPickUp") ;
        currentKiwi ++ ;
        kiwiCounter.txt = currentKiwi+"/"+kiwiMap[track.id].length ;
        if ( currentKiwi >= kiwiMap[track.id].length ) {
          carPJ.vs.totalTime = getTimer()-carPJ.timerLap ;
          carPJ.finished = true ;
          timerEnd = delaiFin ;
          arrow._visible = false ;
        }
      }

    // Labo Kiwix
    if ( vs.selectedTrack==4 ) {
      pt={x:carPJ.x+dxTotal, y:carPJ.y+dyTotal} ;
      track.localToGlobal(pt) ;
      if ( track.skin.sub.labZone.hitTest(pt.x, pt.y, true) ) {
        if ( carPJ.skin._currentframe <= 5 ) {
          attachMovie( "specialsBox","sBox",this.calcDepth(DP_SPECIALSBOX) ) ;
          sBox._x = (docWidth/2) ;
          sBox._y = 100 ;
          sBox.txt = specials[4].chaine ;
          sBox.underTxt = "activé" ;
          carPJ.skin.gotoAndStop( carPJ.skinId+20 ) ;
        }
      }
    }

  } while (Math.abs(speedLeft)!=0 && Math.abs(speedALeft)!=0) ;


  carPJ.realSpeed = (1/gtmod) * (carPJ.realSpeed) ;

  if (hitBorder>0) {
    nitroStopped = true ;
    carPJ.vibre=20 ;
    if ( gameQuality >= MEDIUM )
      spawnSmoke ("smokeMud", carPJ.x,carPJ.y, 0,0, random(60)+50, 5, false) ;
    hitBorder-- ;
    if (hitBorder<=0) {
      track.skin.sub.outZone._visible = false ;
      carPJ.vibre=0 ;
      hitBorder=0 ;
      pt={x:carPJ.x, y:carPJ.y} ;
      track.localToGlobal(pt) ;
      carPJ.speed = borderMaxSpeed; // 1.5
      carPJ.speedA = borderMaxAccelSpeed; // 2
    }
  }



//  _root.compteurVitesse = Math.max( 0, Math.round( realSpeed*kmhFact ) ) + " km/h" ;


  // Test des checkpoints
  if ( vs.gameMode != KIWIRUN ) // Kiwi-Run
    testCheckPoints( 0 ) ;



  // Update des coordonnées du MC avec les coordonnées en Flottant (plus de précision)
  //vx=random(carPJ.vibre)/10//*( random(2)*2-1 ) ;
  vx = 0 ;
  vy = random(carPJ.vibre) / 10//*( random(2)*2-1 ) ;
  carPJ._x = carPJ.x + vx ;
  carPJ._y = carPJ.y + vy ;
  carShadows[0]._x = carPJ._x + shadowShift ;
  carShadows[0]._y = carPJ._y + shadowShift ;
  if ( carPJ.speed > 7 ) {
    var randomShift = -random(2) ;
    carShadows[0]._x += randomShift ;
    carShadows[0]._y += randomShift ;
  }
  carShadows[0]._rotation = carPJ._rotation ;


  // Affichage mode Ghost (cheat GHOST ou super départ)
  if ( ( vs.startBoost && carPJ.vs.immuneHit ) || specials[3].state ) {
    if ( carPJ._alpha > ghostAlpha ) {
      carPJ._alpha -= gtmod*9 ;
      carPJ._alpha = Math.max( ghostAlpha, carPJ._alpha ) ;
    }
  }
  else {
    if ( carPJ._alpha < 100 ) {
      carPJ._alpha += gtmod*9 ;
      carPJ._alpha = Math.min( 100, carPJ._alpha ) ;
    }
  }


  // Atténuation de l'inertie latérale pour les dérapages
  ecart=getAngle(carPJ._rotation-carPJ.accelAng) ;
  // Fumée en dérapage
  if (hitBorder==0 && Math.abs(ecart)>30) {
    if ( gameQuality >= MEDIUM )
      spawnSmoke ("smokeSkid", carPJ.x,carPJ.y, preCosA*carPJ.speedA*((random(4)+6)/10), preSinA*carPJ.speedA*1.5*((random(4)+6)/10), carPJ.speedA*100/10, 5, false) ;
    carPJ.vibre=13 ;
  }
  else
    carPJ.vibre=false ;
  if (carPJ.speed<4 || (vs.nitroFlag && specials[1].state) ) carPJ.pct=0.06 ;


  if ( carPJ.derapage ) {
    carPJ.accelAng = getAngle (carPJ.accelAng + gtmod * (0.3*carPJ.pct*ecart)) ;
  }
  else {
    carPJ.accelAng = getAngle (carPJ.accelAng + gtmod * (carPJ.pct*ecart)) ;
  }

  if (carPJ.spawnImmune>0) carPJ.spawnImmune-- ;

  // Ghost
  if ( vs.gameMode == GHOSTRUN ) {
    if ( !skipGhost ) {
      ghostStore(ghost,false) ;

      if ( previousGhost != undefined ) {
        var infos = ghostRead( previousGhost ) ;
        ghostCar._x = infos.x ;
        ghostCar._y = infos.y ;
        ghostCar._rotation = infos.r ;
      }
    }
    else {
      if ( previousGhost != undefined ) {
        var infos = ghostRead( previousGhost ) ;
        previousGhost.current-- ;
        ghostCar._x = ( ghostCar._x + infos.x ) / 2 ;
        ghostCar._y = ( ghostCar._y + infos.y ) / 2 ;
        ghostCar._rotation = ( ghostCar._rotation + infos.r ) / 2 ;
      }
    }
    skipGhost = !skipGhost ;
  }


}



/*-----------------------------------------------
    GESTION DES CONTROLES DU JEU
    (pas les touches de controle du joueur)
 ------------------------------------------------*/
function getControls() {


  // Abandon
  if ( !starting ) {
    if ( lockQuit && !Key.isDown(Key.ESCAPE) )
      lockQuit = false ;
    if ( !lockQuit && Key.isDown(Key.ESCAPE) ) {
      if ( !client.forcePause )
        togglePause() ;
      if ( gamePaused ) {
        // attachement de la boite de confirmation
        waitingGiveUp = true ;
        var d = this.calcDepth(DP_MENU) ;
        giveUpBox.removeMovieClip() ;
        attachMovie( "giveUpBox", "giveUpBox", d ) ;
        giveUpBox._x = (docWidth/2) ;
        giveUpBox._y = 200 ;
        giveUpBox.yes._visible = false ;
        delete giveUpBt ;
      }
      else {
        // suppression de la boite de confirmation
        waitingGiveUp = false ;
        giveUpBox.removeMovieClip() ;
        pauseBox.removeMovieClip() ;
      }
      lockQuit = true ;
    }
  }


  // Gestion de la boîte de confirmation d'abandon
  if ( waitingGiveUp ) {
    // Flêche gauche (oui)
    if ( Key.isDown(Key.LEFT) || Key.isDown(controls[2]) ) {
      giveUpBox.yes._visible = true ;
      giveUpBox.no._visible = false ;
    }
    // Flêche droite (non)
    if ( Key.isDown(Key.RIGHT) || Key.isDown(controls[3]) ) {
      giveUpBox.yes._visible = false ;
      giveUpBox.no._visible = true ;
    }
    // Validation
    if ( giveUpBt != undefined || Key.isDown(controls[4]) || Key.isDown(Key.SPACE) || Key.isDown(Key.ENTER) || Key.isDown(Key.CONTROL) ) {
      if ( giveUpBt==1 || giveUpBox.yes._visible ) {
        vs.giveUp = true ;
        delete giveUpBt ;
        vs.mainPhase = 2 ;
        skipToTrackPresent = false ;
      }
      if ( giveUpBt==2 || giveUpBox.no._visible ) {
        vs.giveUp = false ;
        delete giveUpBt ;
        togglePause() ;
        waitingGiveUp = false ;
        giveUpBox.removeMovieClip() ;
      }
    }
  }


  // Pause
  if ( lockPause && !Key.isDown(80) )
    lockPause = false ;
  if ( !lockPause && Key.isDown(80) && !starting && !waitingGiveUp && !client.forcePause ) {
    togglePause() ;
    lockPause = true ;
  }


  if ( !gamePaused ) {

    // Touches du mode édition
    if (EDITORMODE)
      getEditorControls() ;

    // Touches spéciales de debug
    if ( GAMEDEBUG )
      getDebugControls()
  }

}


/*-----------------------------------------------
    Déplacement des FX
 ------------------------------------------------*/
function moveFx() {
  var mc,i;
  for (i=0;i<fx.length;i++) {
    mc=fx[i] ;
    mc._x+=gtmod*mc.dx ;
    mc._y+=gtmod*mc.dy ;
    mc.dx*=mc.friction ;
    mc.dy*=mc.friction ;

    if (mc.kill || gameQuality < MEDIUM ) {
      mc.removeMovieClip() ;
      fx.splice(i,1) ;
      i--;
    }
  }
}



/*-----------------------------------------------
    GESTION DU KIWI RUN
 ------------------------------------------------*/
function manageKiwis() {

  // S'il n'y a pas de kiwi en jeu, on en attache un
  if ( kiwiItem._x == undefined && currentKiwi < kiwiMap[track.id].length ) {
    var d = track.calcDepth(DP_KIWIS) ;
    track.attachMovie( "kiwi", "kiwiItem", d ) ;
    kiwiItem = track.kiwiItem ;
    kiwiItem._x = kiwiMap[track.id][currentKiwi].x ;
    kiwiItem._y = kiwiMap[track.id][currentKiwi].y ;
    arrow._visible = true ;
  }


  // Gestion de la flêche indiquant la position du prochain kiwi
  var pt = { x:kiwiItem._x, y:kiwiItem._y } ;
  track.localToGlobal(pt) ;
  arrow._x = Math.max(arrowBorderMargin, Math.min(350-arrowBorderMargin,pt.x) ) ;
  arrow._y = Math.max(arrowBorderMargin, Math.min(350-arrowBorderMargin,pt.y) ) ;

  if ( pt.x >= arrowBorderMargin && pt.x <= 350-arrowBorderMargin &&
       pt.y >= arrowBorderMargin && pt.y <= 350-arrowBorderMargin ) {
    arrow._rotation = 0 ;
    arrow.gotoAndStop(2) ;
  }
  else {
    var angRad = Math.atan2( carPJ.y-kiwiItem._y , carPJ.x-kiwiItem._x ) ;
    var ang = angRad/(Math.PI/180)-180 ;
    arrow._rotation = ang ;
    arrow.gotoAndStop(1) ;
  }
}



/*-----------------------------------------------
    INITIALISATIONS DE MAIN GAME
 ------------------------------------------------*/
function initGame() {

  // Sons
  if ( musicON ) {
    stopMusic( musicMenu ) ;
    startMusic( musicGame ) ;
  }

  var today = new Date() ;
  if ( specials[6].state || today.getHours()<=7 || today.getHours()>=20 ) {
    nightMode = true ;
    nightOffset = NIGHT_LUM ;
    if ( id==3 || id==4 || id==5 )
      nightOffset*=2 ;
  }
  else
    nightMode = false ;

  // Circuit et voitures
  attachTrack( vs.selectedTrack ) ;
  carPJ = cars[0] ;
  if ( specials[3].state )
    carPJ.vs.immuneHit = baseImmuneHit ;

  // Tournoi
  if ( newTournament ) {
    initTournament() ;
    newTournament = false ;
  }

  // Kiwi-run
  if ( vs.gameMode == KIWIRUN ) {
    attachMovie("arrowIndicator","arrow", this.calcDepth(DP_ARROW) ) ;
    arrow._x = (docWidth/2) ;
    arrow._y = (docHeight/2) ;
    arrow.stop() ;
    arrow._visible = false ;
    currentKiwi = 0 ;
    attachMovie("kiwiCounter","kiwiCounter", this.calcDepth(DP_ARROW) ) ;
    kiwiCounter._x = (docWidth/2) ;
    kiwiCounter._y = 50 ;
    kiwiCounter.txt = currentKiwi+"/"+kiwiMap[track.id].length ;
  }

  // Panel du jeu
  if (panelON) attachPanel() ;

  // Divers
  hitBorder=0 ;
  trackedCar=0 ; // ID de la voiture suivie par le scrolling
  orderSkip = 0 ;
  activeIAKiwis = 0 ;

  // Boost de nitro
  vs.nitroFlag = false ;
  accelBoost = 1 ;
//  maxSpeedBoost = 1 ;
  nitroStopped = false ;

  // Check du mode de jeu
  if ( !checkMode(vs.gameMode)  )
    fatal( "Fichier introuvable sur ce FD", "Illegal mode") ;

  // Qualité graphique
  checkFPS = baseCheckFPS ;

  // Initialisations diverses
  vs.giveUp = false ;
  waitingGiveUp = false ;
  gamePaused = true ;
  starting = true ;
  timerEnd = 0 ;
  panelMC.maskSpeedBar._width = 0 ;
  panelMC.chrono_txt = "0\"00" ;
  panelMC.chronoMilli_txt = "000" ;
  getOrder() ;
  delete forcePosition ;

  if (EDITORMODE) {
    clearAllCP() ;
    viewAllCP() ;
  }
//  else
//    attachGoPop() ;

}
