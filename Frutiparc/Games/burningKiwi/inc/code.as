import util.MTCodec ;
import frusion.client.FrusionClient ;
import frusion.service.FrutiScore ;
import frusion.service.FrutiCard ;
import frusion.Context
//import frusion.server.CommandParameter ;


#include "../ext/inc/sounds.as"
//#include "../ext/inc/varSecure2.as"
#include "../ext/inc/depth.as"
#include "../ext/inc/keyNames.as"
#include "../ext/inc/stringLib.as"
#include "../ext/inc/timer-fp.as"
#include "inc/gameData.as"
#include "inc/gameMovies.as"
#include "inc/IA.as"
#include "inc/main.as"
#include "inc/mainGame.as"
#include "inc/mainFinal.as"
#include "inc/menu.as"
#include "inc/preload.as"
#include "inc/sounds.as"

#include "inc/debug/buildInfos.as"
//#include "inc/debug/debug.as"



/*-----------------------------------------------
    SCROLLING MANAGER
 ------------------------------------------------*/
function scrolling(mc) {
  var side ;

  side=docWidth ;
  halfSide = docWidth/2 ;

  // Centrage sur le mc
  track._x=0.4*track._x+0.6*(-mc.x+halfSide) ;
  track._y=0.4*track._y+0.6*(-mc.y+halfSide) ;

  // Plafonds
  if (track._x>0) track._x=0 ;
  if (track._y>0) track._y=0 ;
  if (track._x<-track._width+side) track._x=-track._width+side ;
  if (track._y<-track._height+side) track._y=-track._height+side ;
}


/*-----------------------------------------------
    CORRECTION D'ANGLES
 ------------------------------------------------*/
function getAngle(ang) {
  var retour=ang ;
  if (retour>=180)
    retour-=360 ;
  if (retour<=-180)
    retour+=360 ;
  return (retour) ;
}


/*-----------------------------------------------
    RENVOIE LES COORDONNEES D'UN CHECKPOINT
 ------------------------------------------------*/
function getPosCP(id, skill) {
  x = CP[track.id][id].x ;
  y = CP[track.id][id].y ;
  distance = random(CP[track.id][id].dist)*( random(2)*2-1 ) ;
  distance *= 1-skill ;
  angRad = (Math.PI/180)*getAngle(CP[track.id][id].ang+90) ;
  dx = Math.cos(angRad)*distance ;
  dy = Math.sin(angRad)*distance ;
  pt = {x:x+dx,y:y+dy} ;
  return pt ;
}



/*-----------------------------------------------
    RENVOIE UN ENTIER CORRESPONDANT AUX
    POIDS DES PNEUS DE mcA EN COLLISION
    AVEC mcB
 ------------------------------------------------*/
function testHitCar(mcA, mcB) {
  var poids ;
  var oldAngA, oldSpeed, oldSpeedA ;
  poids = 0 ;

  if ( specials[3].state ) { // Cheat GHOST
    oldSpeed = mcB.speed  ;
    oldSpeedA = mcB.speedA ;
    oldAngA = mcB.angA ;
  }

  // Pour optimiser, on ne hit-test pas si les 2 MCs sont trop éloignés
  tolerance=17 ;
  if ( !EDITORMODE && !mcA.finished && !mcB.finished &&
       !mcA.vs.immuneHit && !mcB.vs.immuneHit &&
       Math.abs(mcA._x-mcB._x) <= tolerance &&
       Math.abs(mcA._y-mcB._y) <= tolerance ) {


    pt = { x:mcA.tire1._x, y:mcA.tire1._y } ;
    mcA.localToGlobal(pt) ;
    if ( mcB.hitTest( pt.x, pt.y, true ) ) poids += 1 ;

    pt = { x:mcA.tire2._x, y:mcA.tire2._y } ;
    mcA.localToGlobal(pt) ;
    if ( mcB.hitTest( pt.x, pt.y, true ) ) poids += 2 ;

    pt = { x:mcA.tire4._x, y:mcA.tire4._y } ;
    mcA.localToGlobal(pt) ;
    if ( mcB.hitTest( pt.x, pt.y, true ) ) poids += 4 ;

    pt = { x:mcA.tire8._x, y:mcA.tire8._y } ;
    mcA.localToGlobal(pt) ;
    if ( mcB.hitTest( pt.x, pt.y, true ) ) poids += 8 ;



    if ( poids > 0 ) {
      /* Correspondance des poids:
          1- arrière gauche
          2- arrière droit
          4- avant gauche
          8- avant droit
      */

      mcA.panic = baseImmuneHit/2 ;
      mcB.panic = baseImmuneHit/2 ;

      // Avant de B touchant A
      if ( poids < 4 ) {
        // Choc
        if ( mcA.spawnImmune == 0 ) {
          mcA.spawnImmune=15 ;
          mcA.vs.collisions ++ ;
          mcB.vs.collisions ++ ;
          if ( gameQuality>=MEDIUM )
            for (i=0;i<mcA.speed*0.7;i++)
              spawnHitCar(mcA._x,mcA._y, -mcA.dx,-mcA.dy) ;
        }

        mcA.speed = mcA.speed * 0.9 ;
        if ( mcB == carPJ ) {
          mcB.speed = -Math.abs(mcB.speed) ;
        }
        else
          mcB.speedA = -Math.abs(mcB.speed*0.9) ;
        mcA.preImmune = 5 ;
      }

      // Avant de A touchant B
      if ( poids >= 4 ) {
        // Choc
        if (mcA.spawnImmune==0 && gameQuality>=MEDIUM) {
          mcA.spawnImmune=15 ;
          mcA.vs.collisions ++ ;
          mcB.vs.collisions ++ ;
          for (i=0;i<mcA.speed*0.7;i++)
            spawnHitCar(mcA._x,mcA._y, mcA.dx,mcA.dy) ;
        }
        if ( mcA == carPJ ) {
          mcA.speed = -Math.abs(mcA.speed) ;
        }
        else {
          mcA.speedA = -Math.abs(mcA.speed*0.9) ;
        }
        mcB.speed = mcB.speed * 0.9 ;
        mcB.preImmune = 5 ;
      }

      // Touché à l'arrière, côté gauche seulement
      if ( poids == 4 ) {
        mcA._rotation += random(40)+10 ;
      }
      // Touché à l'arrière, côté droit seulement
      if ( poids == 8 ) {
        mcA._rotation -= random(40)+10 ;
      }

      // Touché à l'avant, côté gauche seulement
      if ( poids == 1 ) {
        mcA._rotation -= random(30)+10 ;
      }
      // Touché à l'avant, côté droit seulement
      if ( poids == 2 ) {
        mcA._rotation += random(30)+10 ;
      }

      // Touché sur l'aile gauche
      if ( poids == 5 ) {
        mcB.speed = mcA.speed ;
        mcB.speedA = mcA.speedA ;
        mcA.angA = getAngle( mcA._rotation+random(40)+50 ) ;
      }
      // Touché sur l'aile droite
      if ( poids == 10 ) {
        mcB.speed = mcA.speed ;
        mcB.speedA = mcA.speedA ;
        mcA.angA = getAngle( mcA._rotation-(random(40)+50) ) ;
      }
    }

    if ( specials[3].state ) { // Cheat GHOST
      mcB.speed = oldSpeed ;
      mcB.speedA = oldSpeedA ;
      mcB.angA = oldAngA ;
      mcB.vs.collisions -- ;
    }

  }

}


/*-----------------------------------------------
    GESTION DES CHECKPOINTS POUR UNE VOITURE
 ------------------------------------------------*/
function testCheckPoints ( idCar ) {
  var car ;
  car = cars[idCar] ;


  // Si le prochain checkpoint est le 0, on vérifie si on passe sur le MC de la grille de depart
  if ( car.didAllCP ) {
    pt = { x:car.x, y:car.y } ;
    track.localToGlobal( pt ) ;
    if ( track.skin.sub.startZone.hitTest( pt.x,pt.y,true ) ) {

      // Grille de départ franchie
      car.didAllCP = false ;
      car.totalCP++ ;
      if (idCar==0 || !specials[2].state) // Cheat DRONE
        if ( !EDITORMODE )
          car.vs.laps++ ;

      // Course terminée
      if ( car.vs.laps >= track.stats.totalLaps ) {
        car.finished = true ;
        stopBoostAnim(car) ;
        if ( idCar == 0 ) {
          timerEnd = delaiFin ;
        }
        orderFinal.push( idCar ) ;
      }

      temps=getTimer()-car.timerLap ;
      car.vs.bestLap = Math.min( car.vs.bestLap, temps ) ;
      // Temps au tour battu
      var best = false ;
      if ( !vs.useSpecials )
        if ( vs.gameMode==TIMETRIAL && idCar==0 && car.vs.bestLap < trackStats[vs.selectedTrack].$fcLap ) {
          trackStats[vs.selectedTrack].$fcLap = car.vs.bestLap ;
          trackStats[vs.selectedTrack].$lapCar = vs.selectedCar ;
          best = true ;
        }


      // Pop up de temps au tour
      if ( idCar == trackedCar && !car.finished )
        attachLap( car.vs.laps ) ;

      // Perfect
      var perfect = false
      if ( idCar == 0 && car.vs.offRoad == 0 && car.vs.collisions == 0 ) {
        perfect = true ;
        car.vs.perfects++ ;
        attachPerfect() ;
      }

      // Indicateur permanent de temps au tour
      if ( idCar == 0 && ( vs.gameMode == TIMETRIAL || vs.gameMode == ARCADE || vs.gameMode == TRAINING ) )
        attachTimeLine( car.vs.laps-1, temps, perfect, best, false, car.previousLapTime ) ;
      car.previousLapTime = temps ;

      // Update des données de jeu pour cette voiture
      car.vs.totalTime += temps ;
      car.vs.collisionsTotal += car.vs.collisions ;
      car.vs.collisions = 0 ;
      car.vs.offRoadTotal += car.vs.offRoad ;
      car.vs.offRoad = 0 ;
      car.timerLap=getTimer() ;

      // Mode ghost
      if ( vs.gameMode == GHOSTRUN ) {
        ghost.raceTime = car.vs.totalTime ;
//        gdebug("ghost: "+ghost.raceTime+" ("+ghost.moves.length+") vs "+previousGhost.raceTime+" ("+previousGhost.moves.length+")") ;
        if ( ghost.raceTime < previousGhost.raceTime || previousGhost == undefined )
          previousGhost = ghost ;
      }

      // Temps à la course battu
      if ( !vs.useSpecials )
        if ( vs.gameMode==TIMETRIAL && idCar==0 && car.finished && trackStats[vs.selectedTrack].$fcTotal > car.vs.totalTime ) {
          attachTimeLine(car.vs.laps+1, 0, false, false, true) ;
          trackStats[vs.selectedTrack].$fcTotal = car.vs.totalTime ;
          trackStats[vs.selectedTrack].$totalCar = vs.selectedCar ;
        }

    }
  }


  // Si on est proche du current checkpoint, on passe au suivant
  if ( idCar==0 )
    distance = distanceCP ;
  else
    distance = distanceCPIA * Math.max(1,gtmod*0.5) ;

  // Multiplicateur pour certains checkpoints (cas des routes multiples)
  if ( CP[track.id][car.currentCP].distanceCheckFactor )
    distance *= CP[track.id][car.currentCP].distanceCheckFactor ;


  // Vérifie si le CP est franchi
  if ( car.currentCP==-1 ||
       ( Math.abs(car.x-car.nextX)<=distance/2 &&
         Math.abs(car.y-car.nextY)<=distance/2 ) )
  {
    //if (idCar==trackedCar) traceTxt("passed CP #"+car.currentCP) ;
    car.lastCP = car.currentCP ;
    car.currentCP++ ;
    car.totalCP++ ;

    if ( car.currentCP>=CP[track.id].length ) {
      car.currentCP = 0 ;
      car.didAllCP = true ;
    }

    if (idCar==0) {
      car.nextX = CP[track.id][car.currentCP].x ;
      car.nextY = CP[track.id][car.currentCP].y ;
    }
    else {
      pt = getPosCP(car.currentCP, car.skill) ;
      car.nextX = pt.x ;
      car.nextY = pt.y ;
      /*** DEBUG ONLY (point exact à atteindre) ***
      if (idCar==trackedCar) {
        track.targetMC._x = car.nextX ;
        track.targetMC._y = car.nextY ;
      }
      /*** DEBUG ONLY ***/
      car.statRotTemp = car.statRot ;
    }

  }

}



/*-----------------------------------------------
    Init des voitures au départ
 ------------------------------------------------*/
function resetGame() {
  var i ;
  for ( i=0 ; i<cars.length ; i++ ) {
    mc = cars[i] ;
    mc.finished = false ;
    mc.timerLap = getTimer() ;
    if ( !specials[2].state ) { // Cheat DRONE
      mc.totalCP=0 ;
      mc.currentCP = -1 ;
    }
    mc.vs.laps = 0 ;
    mc.derapage = 0 ;
  }
  orderFinal = new Array() ;
}



/*-----------------------------------------------
    CLASSE LES VOITURES DANS LA TABLE
 ------------------------------------------------*/
function getOrder (trackedId) {
  var pos,temp ;
  var CPprevX, CPprevY, CPX, CPY, distCar, distCP, referenceCP, rapport ;

  pos = new Array() ;

  // Initialisation  : ne même pas chercher à comprendre comment ça marche...
  for ( i=0 ; i<cars.length ; i++ ) {
    pos[i] = i ;

    // Détermine l'indice du dernier checkpoint réellement franchit
    CPprevX = CP[track.id][cars[i].currentCP-1].x ;
    CPprevY = CP[track.id][cars[i].currentCP-1].y ;
    CPX = CP[track.id][cars[i].currentCP].x ;
    CPY = CP[track.id][cars[i].currentCP].y ;
    distCar = Math.sqrt( (cars[i].x-CPX) * (cars[i].x-CPX) + (cars[i].y-CPY) * (cars[i].y-CPY) ) ;
    distCP = Math.sqrt( (CPprevX-CPX) * (CPprevX-CPX) + (CPprevY-CPY) * (CPprevY-CPY) ) ;

    cars[i].posCounter = cars[i].totalCP - 1 ;
    referenceCP = cars[i].currentCP  ;
    if ( distCP < distCar ) {
      cars[i].posCounter -- ;
      referenceCP -- ;
    }

    // Distance entre les checkpoints qui encadrent cette voiture
    if ( CP[track.id][referenceCP-1].x == undefined ) {
      CPprevX = CP[track.id][CP[track.id].length-1].x ;
      CPprevY = CP[track.id][CP[track.id].length-1].y ;
    }
    else {
      CPprevX = CP[track.id][referenceCP-1].x ;
      CPprevY = CP[track.id][referenceCP-1].y ;
    }
    CPX = CP[track.id][referenceCP].x ;
    CPY = CP[track.id][referenceCP].y ;
    distCar = Math.sqrt( (cars[i].x-CPX) * (cars[i].x-CPX) + (cars[i].y-CPY) * (cars[i].y-CPY) ) ;
    distCP = Math.sqrt( (CPprevX-CPX) * (CPprevX-CPX) + (CPprevY-CPY) * (CPprevY-CPY) ) ;

    rapport = 1 - distCar / distCP ;
    cars[i].posCounter += rapport ;
  }


  // Bubble-sort!
  for ( j=0 ; j<cars.length ; j++ )
    for ( i=cars.length-1 ; i>j ; i-- ) {
      if ( cars[pos[i]].posCounter > cars[pos[i-1]].posCounter ) {
        temp = pos[i] ;
        pos[i] = pos[i-1] ;
        pos[i-1] = temp ;
      }
  }

  // Mise à jour des MCs
  for ( i=0 ; i<pos.length ; i++ ) {
    mc = panelMC["jeton_"+(i+1)] ;
    if ( pos[i] == trackedId )
      mc.gotoAndStop( 3 ) ;
    else
      mc.gotoAndStop( 2 ) ;
//    mc.gotoAndStop( pos[i]+2 ) ;
  }

  orderList = pos ;
}


/*-----------------------------------------------
    EFFACE LE CONTENU DU CHRONO DU PANEL
 ------------------------------------------------*/
function hideChrono() {
  if ( panelMC.chrono_txt != "" ) {
    panelMC.chrono_txt = "" ;
    panelMC.chronoMilli_txt = "" ;
  }
}


/*-----------------------------------------------
    MET À JOUR L'AFFICHAGE DU CHRONO
    DANS LE PANEL
 ------------------------------------------------*/
function updateChrono(timerLap) {

  temps = getTimer() - timerLap ;

  mins = Math.floor( temps / 60000 ) ;
  temps -= mins * 60000 ;

  secs = Math.floor(temps/1000) ;
  temps -= secs*1000 ;

  milli = temps ;

  if (secs<10) secs = "0"+secs ;
  if (milli<10)
    milli = "00"+milli ;
  else
    if (milli<100) milli = "0"+milli ;

  panelMC.chrono_txt = mins+"\""+secs ;
  panelMC.chronoMilli_txt = milli ;
}


/*-----------------------------------------------
    RENVOIE UN TEMPS SOUS FORME DE
    CHAINE FORMATÉE
 ------------------------------------------------*/
function timeToString(temps, minChar, secChar, milliChar) {
  if ( minChar==null ) minChar = "'" ;
  if ( secChar==null ) secChar = '"' ;
  if ( milliChar==null ) milliChar = "" ;
  var mins, secs, milli ;
  // Découpage
  mins = Math.floor( temps / 60000 ) ;
  temps -= mins * 60000 ;

  secs = Math.floor(temps/1000) ;
  temps -= secs*1000 ;

  milli = temps ;

  // leading zeros
  if (secs<10) secs = "0"+secs ;
  if (milli<10)
    milli = "00"+milli ;
  else
    if (milli<100) milli = "0"+milli ;

  return ( "" + mins + minChar + secs + secChar + milli + milliChar ) ;
}



/*-----------------------------------------------
    MET A JOUR L'OBJET STAT DE COURSE
 ------------------------------------------------*/
function updateRace() {
  // init
  race = new Object() ;

  // update
  race.vsInit("race") ;
  race.trackName = tracks[vs.selectedTrack].title ;
  race.totalLaps = tracks[vs.selectedTrack].totalLaps ;
  race.carName = cars[0].carName ;
  race.raceTime = cars[0].vs.totalTime ;
  race.bestLap = cars[0].vs.bestLap ;
  race.topSpeed = cars[0].vs.topSpeed ;
  race.offRoadTotal = cars[0].vs.offRoadTotal ;
  race.collisions = cars[0].vs.collisionsTotal ;
  race.perfects = cars[0].vs.perfects ;
  race.vsSecureAll() ;

}



/*-----------------------------------------------
    DÉTERMINE LE GRADE SELON LES RÉSULTATS
 ------------------------------------------------*/
function getRank() {
  var rank = new Object() ;
  // Grade
  rank.perfectsRank = 6 ;
  if ( vs.gameMode!=KIWIRUN && !vs.giveUp ) {
    if ( race.perfects == race.totalLaps )
      rank.perfectsRank = 5 ;
    else
      rank.perfectsRank = race.perfects+1 ;
  }

  // Classement
  if ( vs.gameMode!=KIWIRUN && !vs.giveUp )
    rank.posRank = classement ;
  else
    rank.posRank = 5 ;

  return rank ;
}


/*-----------------------------------------------
    INITIALISE UN NOUVEAU TOURNOI
 ------------------------------------------------*/
function initTournament() {
  var i ;
  tournament = new Object() ;
  tournament.cars = new Array(4) ;
  for (i=0;i<4;i++) {
    tournament.cars[i] = new Object() ;
    tournament.cars[i].vsInit("tournamentCar"+i) ;
    tournament.cars[i].carName = cars[i].carName ;
    tournament.cars[i].totalTime = 0 ;
    tournament.cars[i].totalPts = 0 ;
    tournament.cars[i].pos = 99 ;
    tournament.cars[i].vsSecureAll() ;
  }
  tournament.vs = new Object() ;
  tournament.vs.vsInit("vsTourn") ;
  tournament.vs.lives = survivorLives ;
  tournament.vs.vsSecureAll() ;
}


/*-----------------------------------------------
    MET A JOUR LES INFOS DU TOURNOI
 ------------------------------------------------*/
function updateTournament() {
  var i,j ;

  /* DEBUG ONLY: force le classement du joueur (xxx) */
  if ( forcePosition != undefined ) {
    orderFinal=[0,1,2,3] ;
    var swapA, swapB ;

    for (i=0;i<orderFinal.length;i++) {
      if ( orderFinal[i] == 0 )
        swapA = i ;
      if ( i == forcePosition )
        swapB = i ;
    }

    var tmp = orderFinal[swapA] ;
    orderFinal[swapA] = orderFinal[swapB]
    orderFinal[swapB] = tmp ;

    for (i=0;i<cars.length;i++) {
      cars[i].vs.totalTime = random(500) ;
    }
  }
  delete forcePosition ;
  /* */

  // Certaines voitures n'ont pas franchies l'arrivée avant la fin de partie
  if ( orderFinal.length < maxCars ) {
    var missing = new Array() ;
    // Recherche des absents du classement
    for ( var i=0;i<maxCars;i++ ) {
      var found = false ;
      for ( j=0;j<orderFinal.length;j++ )
        if ( orderFinal[j] == i )
          found = true ;
      if ( !found )
        missing.push(i) ;
    }
    // On ajoute les absents dans le classement
    while ( missing.length>0 ) {
      var id = random( missing.length ) ;
      orderFinal.push( missing[id] )
      missing.splice(id,1) ;
    }
  }


  for (i=0;i<cars.length;i++) {
    var pos,pts ;
    // recherche de la voiture dans le classement
    for (j=0;j<orderFinal.length;j++)
      if (orderFinal[j]==i)
        pos = j+1 ;
    switch (pos) {
      case 1: pts = 4 ; break;
      case 2: pts = 2 ; break;
      case 3: pts = 1 ; break;
      case 4: pts = 0 ; break;
    }
    // attribution des points et temps
    tournament.cars[i].totalTime += cars[i].vs.totalTime ;
    tournament.cars[i].raceTime = cars[i].vs.totalTime ;
    tournament.cars[i].totalPts += pts ;
    tournament.cars[i].racePts = pts ;
    tournament.cars[i].pos = pos ;
  }

  // Survivor: perte de vie
  if ( vs.gameMode == SURVIVOR && tournament.cars[0].pos > 2 ) {
    tournament.vs.lives -- ;
  }

  // Table contenant les ids de voiture dans l'ordre
  tournament.podiumRace = new Array() ;
  for (i=0;i<tournament.cars.length;i++)
    tournament.podiumRace[i] = i ;

  // Bubble sort pour déterminer le classement de la course
  for ( j=0 ; j<tournament.podiumRace.length ; j++ )
    for ( i=tournament.podiumRace.length-1 ; i>j ; i-- )
      if ( tournament.cars[tournament.podiumRace[i]].racePts > tournament.cars[tournament.podiumRace[i-1]].racePts ) {
        var tmp ;
        tmp = tournament.podiumRace[i-1] ;
        tournament.podiumRace[i-1] = tournament.podiumRace[i] ;
        tournament.podiumRace[i] = tmp ;
      }


  // Table contenant les ids de voiture dans l'ordre
  tournament.podium = new Array() ;
  for (i=0;i<tournament.cars.length;i++)
    tournament.podium[i] = i ;

  // Bubble sort pour déterminer le classement du tournoi
  for ( j=0 ; j<tournament.podium.length ; j++ )
    for ( i=tournament.podium.length-1 ; i>j ; i-- )
      if ( tournament.cars[tournament.podium[i]].totalPts > tournament.cars[tournament.podium[i-1]].totalPts ) {
        var tmp ;
        tmp = tournament.podium[i-1] ;
        tournament.podium[i-1] = tournament.podium[i] ;
        tournament.podium[i] = tmp ;
      }

}



/*-----------------------------------------------
    EVENT: CLIC SUR LE MAIN
 ------------------------------------------------*/
function eventMainRelease() {
  mainClicked = true ;
}



/*-----------------------------------------------
    TESTE LES CONTROLES POUR PASSER À
    L'ECRAN SUIVANT
 ------------------------------------------------*/
function skipTest() {
  var result ;

  // Attachement de l'event
  if ( this.onRelease == undefined )
    this.onRelease = eventMainRelease ;

  // Test
  result = mainClicked || Key.isDown(controls[4]) || Key.isDown(Key.SPACE) || Key.isDown(Key.ENTER) || Key.isDown(Key.ESCAPE) ;

  // Détachement de l'event
  if ( result ) {
    delete this.onRelease ;
    delete mainClicked ;
  }

  return result ;
}


/*-----------------------------------------------
    MET À JOUR L'ÉTAT DE PAUSE
 ------------------------------------------------*/
function togglePause() {

  gamePaused = !gamePaused ;

  pauseBox.removeMovieClip() ;
  if ( gamePaused ) {
    // Pause
    var d = this.calcDepth(DP_MENU) ;
    attachMovie( "pauseBox", "pauseBox", d ) ;
    pauseBox._x = (docWidth/2) ;
    pauseBox._y = 130 ;
    vs.pauseDuration = getTimer() ;
  }
  else {
    // Fin de pause
    vs.pauseDuration = getTimer() - vs.pauseDuration ;
    if ( carPJ.offRoadTimer != undefined )
      carPJ.offRoadTimer += vs.pauseDuration ;
    for ( i=0 ; i<cars.length ; i++ ) {
      mc = cars[i] ;
      mc.timerLap += vs.pauseDuration ;
    }
  }
}


/*-----------------------------------------------
    DÉFINI LA QUALITÉ GRAPHIQUE DU JEU
 ------------------------------------------------*/
function setDetailLevel( q ) {
  gameQuality = Math.max(0, Math.min(HIGH, q) ) ;
  updateDetailLevel( q ) ;
}


/*-----------------------------------------------
    MISE À JOUR DE LA QUALITÉ GRAPHIQUE DU JEU
 ------------------------------------------------*/
function updateDetailLevel( q ) {
  switch ( q ) {
    case AUTO :
    case HIGH :
        _quality = "high" ;
        break ;
    case MEDIUM :
        _quality = "medium" ;
        break ;
    case LOW :
        _quality = "low" ;
        break ;
  }

}



// *** FRUTICARD

/*-----------------------------------------------
    PRÉPARATION DE LA FRUTICARD
 ------------------------------------------------*/
function initFrutiCard() {
  frutiSlots = new Array() ;
  frutiSlots[SLOT_PUBLIC] = new Object() ;
  frutiSlots[SLOT_PREFS] = new Object() ;
  frutiSlots[SLOT_MODES] = new Array() ;
//  frutiSlots[SLOT_STATS] = new Object() ;
}



/*-----------------------------------------------
    CRÉATION DU PROFIL PAR DÉFAUT
 ------------------------------------------------*/
function initFrutiCardContent() {
  // Préférences
  musicON = true ;
  soundsON = true ;
  if (USEFAKESERVER) { musicON = false ; soundsON = false ; } // xxx
  qualitySetting = AUTO ;
  setDetailLevel( qualitySetting ) ;
  panelON = true ;

  // Données de jeu
  vs.$ws = false ;
  vs.$wss = false ;
  vs.$wc = false ;
  vs.$wcs = false ;

  // Voitures activées
  availableCars = new Array() ;
  availableCars[0] = false ;
  availableCars[1] = false ;
  availableCars[2] = true ;
  availableCars[3] = true ;
  availableCars[4] = false ;

  // Performances par course
  trackStats = new Array() ;
  for (var i=0;i<nbTracks;i++) {
    trackStats[i] = new Object() ;
    trackStats[i].$fcLap = Infinity ;
    trackStats[i].$fcTotal = Infinity ;
  }

  // Contrôles par défaut
  for (var i=0;i<controls.length;i++)
    if ( controls[i] == undefined )
      controls[i] = defaultControls[i] ;
}


/*------------------------------------------------------------------------
    INITIALISE LE SLOT DES MODES
 ------------------------------------------------------------------------*/
function initSlotModes() {
    frutiSlots[SLOT_MODES] = new Array() ;
    for (var i=0;i<9;i++)
      frutiSlots[SLOT_MODES][i] = false ;
    client.saveSlot( SLOT_MODES, frutiSlots[SLOT_MODES] ) ;
}


/*------------------------------------------------------------------------
    CONVERSION DE CARD
 ------------------------------------------------------------------------*/
function updateCard() {
  var ver = frutiSlots[SLOT_PREFS].$ver ;

  gdebug("(update) starting with ver="+ver);

  if (frutiSlots[SLOT_PUBLIC].$ver=="1.2" && ver==undefined) { // auto detect old 1.2
    warning("(update) old 1.2 detected") ;
    ver = "1.2" ;
  }

  gdebug("(update) starting switch with ver="+ver);

  switch (ver) {
    case undefined:
        break;
    case "1.2":
        // Ces cards ont leur numéro de version dans public,
        // et public est créé meme sur les FDs noirs
        warning("(update) "+ver+" -> 1.3") ;
        frutiSlots[SLOT_PREFS].$ver = "1.3" ;
    case "1.3":
        warning("(update) "+ver+" -> 1.4") ;
        frutiSlots[SLOT_PREFS].$ver = "1.4" ;
    case "1.4":
        warning("(update) "+ver+" -> 1.5") ;
        frutiSlots[SLOT_PREFS].$ver = "1.5" ;
        initSlotModes() ;
        gdebug("(update) "+frutiSlots[SLOT_MODES].join(":")+" id="+SLOT_MODES);
        gdebug("(update) func="+client.saveSlot);
    case "1.5":
        warning("(update) "+ver+" -> 1.6") ;
        frutiSlots[SLOT_PREFS].$ver = "1.6" ;
        if ( client.isWhite() ) {
          if ( frutiSlots[SLOT_PUBLIC].$wcs ) giveItem("$fruticup") ;
          if ( frutiSlots[SLOT_PUBLIC].$wc ) giveItem("$fruticupxl") ;
          if ( frutiSlots[SLOT_PUBLIC].$wss ) giveItem("$elite") ;
          if ( frutiSlots[SLOT_PUBLIC].$ws ) giveItem("$elitexl") ;
          if ( frutiSlots[SLOT_PUBLIC].$ac[0] ) giveItem("$logo01") ;
          if ( frutiSlots[SLOT_PUBLIC].$ac[1] ) giveItem("$logo02") ;
          if ( frutiSlots[SLOT_PUBLIC].$ac[4] ) giveItem("$logo05") ;
        }
    case "1.6":
    case "1.7":
        warning("(update) "+ver+" -> 1.8") ;
        if ( frutiSlots[SLOT_MODES][i]==null || frutiSlots[SLOT_MODES][i]==undefined )
            initSlotModes();
  }

  gdebug("Done update: ver="+frutiSlots[SLOT_PREFS].$ver);

}


/*-----------------------------------------------
    LIT LES INFOS DE LA FRUTICARD
 ------------------------------------------------*/
function readFrutiCard() {
  gdebug("readFrutiCard: version "+(frutiSlots[SLOT_PREFS].$ver)+" found") ;

  gdebug("running update: "+updateCard) ;
  updateCard() ;

  // Préférences
  if ( frutiSlots[SLOT_PREFS].$mus != undefined ) {
    gdebug(". READING: preferences") ;
    musicON = frutiSlots[SLOT_PREFS].$mus ;
    soundsON = frutiSlots[SLOT_PREFS].$snd ;
    qualitySetting = frutiSlots[SLOT_PREFS].$det ;
    setLevelDetail( qualitySetting ) ;
    panelON = frutiSlots[SLOT_PREFS].$bar ;
    controls = frutiSlots[SLOT_PREFS].$ctr ;
  }
  else
    frutiSlots[SLOT_PREFS] = new Object() ;

  // Données publiques
  if ( frutiSlots[SLOT_PUBLIC].$ws != undefined ) {
    gdebug(". READING: public") ;
    delete frutiSlots[SLOT_PUBLIC].$tmpCard ;
    vs.$ws = frutiSlots[SLOT_PUBLIC].$ws ;
    vs.$wss = frutiSlots[SLOT_PUBLIC].$wss ;
    vs.$wc = frutiSlots[SLOT_PUBLIC].$wc ;
    vs.$wcs = frutiSlots[SLOT_PUBLIC].$wcs ;
    availableCars = frutiSlots[SLOT_PUBLIC].$ac ; // attention à ca ... (anciennement c)
    trackStats = frutiSlots[SLOT_PUBLIC].$ts ;
  }
  else {
    frutiSlots[SLOT_PUBLIC] = new Object() ;
    if ( !client.isWhite() )
      frutiSlots[SLOT_PUBLIC].$tmpCard = true ;
  }

  // Modes
  if ( frutiSlots[SLOT_MODES].length!=undefined ) {
        // do nothing...
  }
  else {
        initSlotModes();
  }


  /***
  if ( USEFAKESERVER ) { // xxx
    availableCars[0]=true ;
    availableCars[1]=true ;
    availableCars[4]=true ;
    vs.$ws = true ;
    vs.$wss = true ;
    vs.$wc = true ;
    vs.$wcs = true ;
  }
  /***/


  // Patch 1.5+: débloquage des modes fcard
  if ( client.isWhite() && vs.$wcs ) {
    if ( !checkMode(DUEL) )
      unlockMode(DUEL) ;
    if ( !checkMode(SURVIVOR) )
      unlockMode(SURVIVOR) ;
  }


  savePreferences() ;
  savePublic() ;
}


/*-----------------------------------------------
    ENVOIE LES PRÉFÉRENCES AU SERVEUR
 ------------------------------------------------*/
function savePreferences() {
  frutiSlots[SLOT_PREFS].$ver = SLOTVERSION ;
  frutiSlots[SLOT_PREFS].$mus = musicON ;
  frutiSlots[SLOT_PREFS].$snd = soundsON ;
  frutiSlots[SLOT_PREFS].$det = qualitySetting ;
  frutiSlots[SLOT_PREFS].$bar = panelON ;
  frutiSlots[SLOT_PREFS].$ctr = controls ;

  client.saveSlot( SLOT_PREFS, frutiSlots[SLOT_PREFS] ) ;
}


/*-----------------------------------------------
    ENVOIE LES DONNÉES DE JEU AU SERVEUR
 ------------------------------------------------*/
function savePublic() {
  if ( frutiSlots[SLOT_PUBLIC].$tmpCard ) {
    warning("(savePublic) skipped (tmp card)") ;
    return ;
  }
  delete frutiSlots[SLOT_PUBLIC].$ver ;
  frutiSlots[SLOT_PUBLIC].$ws = vs.$ws ;
  frutiSlots[SLOT_PUBLIC].$wss = vs.$wss ;
  frutiSlots[SLOT_PUBLIC].$wc = vs.$wc ;
  frutiSlots[SLOT_PUBLIC].$wcs = vs.$wcs ;
  frutiSlots[SLOT_PUBLIC].$ac = availableCars ;
  frutiSlots[SLOT_PUBLIC].$ts = trackStats ;

  client.saveSlot( SLOT_PUBLIC, frutiSlots[SLOT_PUBLIC] ) ;
}



// *** MODES

/*------------------------------------------------------------------------
    TESTE LA DISPONIBILITÉ D'UN MODE
 ------------------------------------------------------------------------*/
  function checkMode(mode) {
    // Gris/noir
    if ( client.isBlack() || client.isGray() ) {
      if ( mode == ARCADE || mode == TUTORIAL )
        return true ;
      else
        return false ;
    }

    // Rouge
    if ( client.isRed() )
      return frutiSlots[SLOT_MODES][mode] ;

    // Blanc
    if ( client.isWhite() )
      if ( mode == TRAINING || mode==TUTORIAL || mode==FRUTICUP || mode==TIMETRIAL )
        return true ;
      else
        return frutiSlots[SLOT_MODES][mode] ;

  }


/*------------------------------------------------------------------------
    DÉBLOQUE UN MODE
 ------------------------------------------------------------------------*/
  function unlockMode(mode) {
    frutiSlots[SLOT_MODES][mode] = true ;
    client.saveSlot( SLOT_MODES, frutiSlots[SLOT_MODES] ) ;
    gdebug("unlocking "+mode);
  }



// *** GHOST MODE

/*------------------------------------------------------------------------
    GHOST: SAUVE UNE POSITION
 ------------------------------------------------------------------------*/
function ghostStore( g, usedNitro ) {
  g.moves.push( { x:carPJ.x, y:carPJ.y, r:carPJ._rotation, n:usedNitro } )
}


/*------------------------------------------------------------------------
    GHOST: RENVOIE LA PROCHAINE POSITION ENREGISTRÉE
 ------------------------------------------------------------------------*/
function ghostRead( g ) {
  if ( g.current >= g.moves.length )
    g.current = g.moves.length-1 ;
  return g.moves[g.current++] ;
}



/*------------------------------------------------------------------------
    GHOST: INITIALISATION
 ------------------------------------------------------------------------*/
function createGhost() {
  var g = new Object() ;
  g.current = 0 ;
  g.moves = new Array() ;
  g.raceTime = Infinity ;
  return g ;
}


/*------------------------------------------------------------------------
    BOUCLE D'ANIM DE LA PHASE DE DÉPART
 ------------------------------------------------------------------------*/
function mainStart() {
  if ( gameQuality>=HIGH )
    animGrid() ;
  if ( startAnim._x == undefined ) {
    // Attachement
    var d = this.calcDepth(DP_BG) ;
    // Fond
    if ( gameQuality>=HIGH )
      initGrid() ;
    else {
      this.attachMovie("blackBg", "blackBg", d ) ;
      blackBg._width = docWidth ;
      blackBg._height = docHeight ;
      blackBg.stop() ;
    }
    // Anim de décompte
    this.attachMovie("startAnim", "startAnim", this.calcDepth(DP_INTERF) ) ;
    startAnim._x = docWidth/2 ;
    startAnim._y = docHeight/2 ;
    startAnim.sub.frame = 0 ;
    startAnim.stop() ;
    startAnim.sub.stop() ;
    startAnim.sub.sub.gotoAndStop(1) ;
    track.setMask(startAnim) ;
    fakeSpeed = 0 ;
    fakeSpeedCounter = 0 ;
  }
  else {
    // Affichage de la fausse accélération
    fakeSpeedCounter = 0.8*fakeSpeedCounter + 0.2*fakeSpeed ;
    panelMC.maskSpeedBar._width = ( fakeSpeedCounter * 95 ) / carPJ.statMaxSpeed ;

    // Avancement de l'anim
    startAnim.sub.frame += gtmod ;
    while ( startAnim.sub.frame >=1 ) {
      startAnim.sub.nextFrame() ;
      startAnim.sub.frame -- ;
    }
    // Chiffre en cours terminé
    if ( startAnim.sub._currentframe >= startAnim.sub._totalframes ) {
      // Décompte terminé, départ !
      if ( startAnim._currentframe==2 ) {
        track.setMask(null) ;
        startAnim.removeMovieClip() ;
        blackBg.removeMovieClip() ;
        grille.removeMovieClip() ;
        gamePaused = false ;
        starting = false ;
        resetGame() ;
        vs.startBoost = 1 - Math.abs(optimalStartSpeed - fakeSpeed) / superStartMaxGap ;
//        vs.startBoost = 1 - ( Math.abs( fakeSpeed - optimalStartSpeed ) ) / superStartMaxGap ;
//        vs.startBoost = Math.abs( vs.startBoost ) ;
        if ( vs.startBoost>1 || vs.startBoost<0 )
          vs.startBoost = 0 ;
      }
      // Bascule sur le GO
      if ( startAnim.sub.sub._currentframe == startAnim.sub.sub._totalframes ) {
        startAnim._xscale == 120 ;
        startAnim.gotoAndStop(2) ;
        startAnim.sub.frame = 0 ;
        if ( vs.selectedTrack != 3 ) // pour la neige, on ne switch pas au blanc
          blackBg.gotoAndStop(2) ;
      }
      else
        startAnim._xscale += 60 ;
      startAnim._yscale = startAnim._xscale ;
      startAnim.sub.sub.nextFrame() ;
      startAnim.sub.gotoAndStop(1) ;
    }
  }




  // Super départ
  if ( starting ) {
    if ( Key.isDown(controls[0]) ) {
      fakeSpeed += gtmod * ( ((carPJ.statMaxSpeed-fakeSpeed)/(carPJ.statMaxSpeed+15))*carPJ.statAccel ) ;
      fakeSpeed *= Math.pow( roadFriction,gtmod ) ;
    }
    else {
      fakeSpeed *= Math.pow( carPJ.statBrake, gtmod ) ;
    }

  }
}


/*------------------------------------------------------------------------
    DONNE UNE COUPE SUR FRUTIPARC
 ------------------------------------------------------------------------*/
function giveCup(flag, name) {
  if ( vs.useSpecials ) return ;
  if ( !flag )
    giveItem(name) ;
  giveItem("$car0"+(vs.selectedCar+1)) ;
}


/*------------------------------------------------------------------------
    GIVEITEM LOCAL (FONCTION DEBUG)
 ------------------------------------------------------------------------*/
function giveItem(name) {
  if ( vs.useSpecials ) return ;
  gdebug("(giveItem) "+name) ;
  client.giveItem(name) ;
}



/*------------------------------------------------------------------------
    ERREUR CRITIQUE
 ------------------------------------------------------------------------*/
function fatal( msgUser, msg ) {
  error("(FATAL ) "+msgUser) ;
  error("(FATAL ) "+msg) ;
//  client.fatalError(msg+" ("+buildVersion+"/"+buildDate+") "+msgUser) ;
  client.logError(msgUser+"\n----------\nInformations complémentaires:\n"+msg+" ("+buildVersion+"/"+buildDate+") ") ;
  stop();
}



/*------------------------------------------------------------------------
    REPORT D'ERREUR NON CRITIQUE
 ------------------------------------------------------------------------*/
function report( msg ) {
  warning("(REPORT) "+msg) ;
  client.logError(msg+" ("+buildVersion+"/"+buildDate+")") ;
}


/*-----------------------------------------------
    TRACE LE CONTENU D'UN OBJET
 ------------------------------------------------*/
function traceObject(obj) {
  var msg = "" ;
  for (item in obj) {
    msg+="  . "+item+" = "+obj[item]+"\n" ;
  }
  return msg ;
}
