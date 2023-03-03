/*-----------------------------------------------
    MAIN DE LA PHASE FINALE
 ------------------------------------------------*/
function mainFinal() {
  // Anim de la grille en fond
  animGrid() ;

  moveConfettis() ;

  // Fin
  switch( vs.finalPhase ) {
    case -1 :
        break ;


    // *** CLASSEMENT DE COURSE
    case 0 : // affichage des MCs de base du final MC du classement
        var d ;
        if ( vs.giveUp )
          vs.finalPhase = 30 ;
        else
          if ( vs.gameMode == KIWIRUN ) // kiwi-run
            vs.finalPhase = 3 ;
          else
            vs.finalPhase++ ;
        break;

    case 1 : // affichage du MC du classement
        var d = this.calcDepth(DP_INTERF) ;
        attachMovie( "finalPosition", "finalPosition", d ) ;

        // Confettis pour la première place
        if ( classement == 1 )
          for (var i=0;i<20;i++)
            spawnConfetti() ;

        vs.finalPhase++ ;
        break;

    case 2 : // attente
        if ( skipTest() ) {
          playSoundBK("buttonOk") ;
          finalPosition.removeMovieClip() ;
          gdebug("fl_localScore = "+client.fl_localScore) ;
          vs.finalPhase++ ;
          if ( gameEnded() )
            if ( vs.gameMode==ARCADE && !vs.giveUp )
              vs.finalPhase=50 ;
        }
        break ;

    // *** STATS DE COURSE
    case 3 : // affichage MC des stats
        if ( !skipTest() ) {
          var d = this.calcDepth(DP_INTERF) ;
          attachMovie( "raceStats", "raceStats", d ) ;
          raceStats._x = (docWidth/2) ;
          raceStats._y = (docHeight/2) ;
          raceStats.trackName_txt = race.trackName ;
          raceStats.carName_txt = race.carName ;
          raceStats.raceTime_txt = timeToString( race.raceTime ) ;
          raceStats.maxSpeed_txt = Math.round( race.topSpeed * kmhFact ) + " km/h" ;
          raceStats.offRoadTotal_txt = timeToString( race.offRoadTotal ) ;

          if ( vs.gameMode == KIWIRUN ) // kiwi-run
            raceStats.bestLap_txt = "N/A" ;
          else
            raceStats.bestLap_txt = timeToString( race.bestLap ) ;

          if ( vs.gameMode == KIWIRUN || vs.gameMode == TIMETRIAL ) // TimeTrial ou kiwi-run
            raceStats.collisions_txt = "N/A" ;
          else
            raceStats.collisions_txt = race.collisions ;

          if ( vs.gameMode == KIWIRUN ) // kiwi-run
            raceStats.perfects_txt = "N/A" ;
          else
            raceStats.perfects_txt = race.perfects+" / "+race.totalLaps ;

          // Perfect ?
          if ( race.offRoadTotal == 0 && race.collisions == 0 )
            raceStats.perfect = true ;

          // Grade
          raceStats.perfectsRank = race.rank.perfectsRank ;
          raceStats.posRank = race.rank.posRank ;

          vs.finalPhase++ ;
        }
        break;

    case 4 : // attente
        if ( skipTest() ) {
          playSoundBK("buttonOk") ;
          raceStats.removeMovieClip() ;

          // Tournoi classique
          if ( vs.gameMode == FRUTICUP ) {
            vs.finalPhase = 10 ;
            break ;
          }
          // Survivor
          if ( vs.gameMode == SURVIVOR ) {
            vs.finalPhase = 20 ;
            break ;
          }
          // Duel
          if ( vs.gameMode == DUEL ) {
            if ( classement == 1 )
              vs.finalPhase = 60 ;
            else
              vs.finalPhase = 30 ;
            break ;
          }
          // Arcade
          if ( (vs.gameMode == TRAINING || vs.gameMode == ARCADE) && classement != 1 ) {
            vs.finalPhase = 30 ;
            break ;
          }

          skipToTrackPresent = false ;
          finalScrolls.removeMovieClip() ;
          gotoMenu() ;
        }
        break ;


    // *** FRUTICOUPE
    case 10 : // TOURNOI - bilan de la course: affichage
        if ( !skipTest() ) {
          var d = this.calcDepth(DP_INTERF) ;
          attachMovie( "tournamentSummary", "summary", d ) ;
          summary._x = (docWidth/2) ;
          summary._y = (docHeight/2) ;
          summary.titre = "BILAN DE LA COURSE" ;

          // Affiche le listing
          for (var i=0;i<tournament.podiumRace.length;i++) {
            summary["car_"+i] = "<P ALIGN=\"CENTER\">"+tournament.cars[tournament.podiumRace[i]].carName+"</P>" ;
            summary["pts_"+i] = "<P ALIGN=\"CENTER\">"+tournament.cars[tournament.podiumRace[i]].racePts+"</P>" ;
            // met le joueur en évidence
            if ( tournament.podiumRace[i] == 0 ) {
              summary["car_"+i] = "<B>"+summary["car_"+i]+"</B>" ;
              summary["pts_"+i] = "<B>"+summary["pts_"+i]+"</B>" ;
            }
          }

          summary.timeTxt = timeToString( tournament.cars[0].raceTime, " min ", " sec ", "" ) ;

          vs.finalPhase++ ;
        }
        break;

    case 11 : // TOURNOI - bilan de la course: attente
        if ( skipTest() ) {
          playSoundBK("buttonOk") ;
          vs.finalPhase++ ;
        }
        break ;

    case 12 : // TOURNOI - bilan global: affichage
        if ( !skipTest() ) {
          vs.finalPhase++ ;
          summary.titre = "BILAN DU TOURNOI" ;

          // Affiche le listing
          for (var i=0;i<tournament.podium.length;i++) {
            summary["car_"+i] = "<P ALIGN=\"CENTER\">"+tournament.cars[tournament.podium[i]].carName+"</P>" ;
            summary["pts_"+i] = "<P ALIGN=\"CENTER\">"+tournament.cars[tournament.podium[i]].totalPts+"</P>" ;
            // met le joueur en évidence
            if ( tournament.podium[i] == 0 ) {
              summary["car_"+i] = "<B>"+summary["car_"+i]+"</B>" ;
              summary["pts_"+i] = "<B>"+summary["pts_"+i]+"</B>" ;
            }
          }

          summary.timeTxt = timeToString( tournament.cars[0].totalTime, " min ", " sec ", "" ) ;
        }
        break ;

    case 13 : // TOURNOI - bilan global: attente
        if ( skipTest() ) {
          playSoundBK("buttonOk") ;
          vs.finalPhase++ ;
        }
        break ;

    case 14 : // TOURNOI - fin du bilan
        if ( !skipTest() ) {
          summary.removeMovieClip() ;
          finalScrolls.removeMovieClip() ;
          if ( vs.giveUp ) {
            skipToTrackPresent = false ;
            gotoMenu() ;
          }
          else {
            vs.selectedTrack ++ ;
          }

          // Gagne une coupe si on est premier sur une des courses finales
          if ( !vs.useSpecials &&
               ( ( vs.selectedTrack == 4 && tournament.podium[0] == 0 ) ||
                 ( vs.selectedTrack == 6 && tournament.podium[0] == 0 ) ) ) {
            var d = this.calcDepth(DP_INTERF) ;
            attachMovie( "announce", "announce", d ) ;
            announce._x = (docWidth/2) ;
            announce._y = (docHeight/2) ;
            if ( vs.selectedTrack == 6 ) { // Coupe d'or
              announce.win.gotoAndStop(4) ;
              giveCup(vs.$wc, "$fruticupxl") ;
              vs.$wc = true ;
              savePublic() ;
            }
            else { // Coupe d'argent
              announce.win.gotoAndStop(3) ;
              giveCup(vs.$wcs, "$fruticup") ;
              unlockMode(DUEL) ;
              unlockMode(SURVIVOR) ;
              vs.$wcs = true ;
              savePublic() ;
            }
            vs.finalPhase++ ;
          }
          else {
            vs.finalPhase+=2 ;
          }
        }
        break ;

    case 15 : // TOURNOI - victoire: attente
        if ( skipTest() ) {
          playSoundBK("buttonOk") ;
          announce.removeMovieClip() ;
          // Envoie le joueur sur les courses extras
          if ( vs.selectedTrack == 4 && vs.$wss ) {
            vs.finalPhase++ ;
          }
          else {
            vs.finalPhase = 30 ;
          }
        }
        break ;


    case 16 : // TOURNOI - passe à la course suivante
        if ( ( vs.selectedTrack == 4 && tournament.podium[0] != 0 ) ||
             ( vs.selectedTrack == 4 && (!vs.$wss || !checkMode(SURVIVOR)) ) ||
             ( vs.selectedTrack == 6 ) ) {
          // Fin du tournoi
          vs.finalPhase = 30 ;
        }
        else {
          // Course suivante
          gotoMenu() ;
          skipToTrackPresent = true ;
        }
        break ;


    // *** SURVIVOR
    case 20 : // SURVIVOR - bilan: affichage
        if ( !skipTest() ) {
          var d = this.calcDepth(DP_INTERF) ;
          attachMovie( "survivorSummary", "summary", d ) ;
          summary._x = (docWidth/2) ;
          summary._y = (docHeight/2) ;
          if ( vs.giveUp || gameEnded() )
            summary.summary.msg._visible = false ;
          else
            if ( classement == 1 )
              summary.summary.msg.gotoAndStop(3) ;
            else
              if ( classement == 2 )
                summary.summary.msg.gotoAndStop(1) ;
              else
                summary.summary.msg.gotoAndStop(2) ;

          // Attachement des MCs des vies restantes
          for ( var i=0 ; i<survivorLives ; i++ ) {
            var mc, w ;
            summary.summary.attachMovie("survivorLife","survivorLife_"+i,i) ;
            mc = summary.summary["survivorLife_"+i] ;
            w = 50 ;
            mc._x = w/2 + i*w  - (survivorLives * w / 2) ;
            mc._y = 5 ;
            if ( i+1 > tournament.vs.lives ) {
              mc.gotoAndStop(2) ;
              // Anim de perte de vie
              if ( classement > 2 && i+1 == tournament.vs.lives+1 ) {
                summary.summary.attachMovie("loseLife","loseLife",100+i) ;
                summary.summary.loseLife._x = mc._x ;
                summary.summary.loseLife._y = mc._y ;
              }
            }
             else
              mc.gotoAndStop(1) ;
          }
          canPlaySound = false ;
          vs.finalPhase++ ;
        }
        break ;

    case 21 : // SURVIVOR - bilan: attente
        // canPlaySound est mis à TRUE dans l'anim de la bille explosant
        if ( canPlaySound ) {
          playSoundBK("loseLifeSound") ;
          canPlaySound = false ;
        }
        if ( skipTest() ) {
          playSoundBK("buttonOk") ;
          vs.finalPhase++ ;
        }
        break ;

    case 22 : // SURVIVOR - bilan : fin
        if ( !skipTest() ) {
          summary.removeMovieClip() ;
          finalScrolls.removeMovieClip() ;
          // Game over ?
          if ( tournament.vs.lives > 0 ) {
            if ( classement == 1 )
              vs.selectedTrack ++ ;

            // Gagne une coupe ?
            if ( classement==1 &&
                 !vs.useSpecials &&
                 ( ( vs.selectedTrack == 4 ) ||
                   ( vs.selectedTrack >= 6 ) ) ) {
              var d = this.calcDepth(DP_INTERF) ;
              attachMovie( "announce", "announce", d ) ;
              announce._x = (docWidth/2) ;
              announce._y = (docHeight/2) ;
              if ( vs.selectedTrack == 6 ) { // Coupe d'or
                announce.win.gotoAndStop(2) ;
                giveCup(vs.$ws, "$elitexl") ;
                vs.$ws = true ;
                savePublic() ;
              }
              else { // Coupe d'argent
                announce.win.gotoAndStop(1) ;
                giveCup(vs.$wss, "$elite") ;
                vs.$wss = true ;
                savePublic() ;
              }
              vs.finalPhase++ ;
            }
            else {
              if ( vs.useSpecials && vs.selectedTrack>=6 )
                vs.finalPhase = 30 ;
              else {
                skipToTrackPresent = true ;
                gotoMenu() ;
              }
            }

          }
          else
            vs.finalPhase = 30 ;

        }
        break ;

    case 23 : // SURVIVOR - victoire: attente
        if ( skipTest() ) {
          playSoundBK("buttonOk") ;
          announce.removeMovieClip() ;
          // Envoie le joueur sur les courses extras
          if ( vs.selectedTrack == 4 && vs.$wss ) {
            skipToTrackPresent = true ;
            gotoMenu() ;
          }
          else {
            vs.finalPhase = 30 ;
          }
        }
        break ;

    case 30 : // GAMEOVER : affichage
        if ( !skipTest() ) {
          var d = this.calcDepth(DP_INTERF) ;
          attachMovie( "gameOver", "gameOver", d ) ;
          gameOver._x = (docWidth/2) ;
          gameOver._y = (docHeight/2) ;

          finalScrolls.removeMovieClip() ;

          playSoundBK("gameOverSound") ;

          vs.finalPhase++ ;
        }
        break ;

    case 31 : // GAMEOVER : attente
        if ( skipTest() ) {
          playSoundBK("buttonOk") ;
          gameOver.removeMovieClip() ;
          skipToTrackPresent = false ;
          gotoMenu() ;
        }
        break ;


    // *** SAVESCORE OU ENDGAME
    case 40 : // SERVEUR: envoi du endGame
        attachNetworkPop() ;
        gdebug("saving score...") ;
        gdebug("giveup="+vs.giveUp) ;
        gdebug("useSpec="+vs.useSpecials) ;
        if ( vs.giveUp || vs.useSpecials ) {
          // Abandon
          gdebug("should endGame...") ;
          client.endGame() ;
          client.fl_localScore = true ;
        }
        else {
          gdebug("should saveScore...") ;
          // SaveScore
          var miscData = [
            race.carName,
            race.rank.perfectsRank,
            race.rank.posRank
          ] ;

          // Patch: score invalide
          if ( race.raceTime==0 || race.raceTime==undefined || isNaN(race.raceTime) ) {
            var msg = "Invalid score, time="+race.raceTime+" object="+traceObject(race) ;
            report(msg) ;
            fatal("Défaillance du chronomètre",msg) ;
            break ;
          }
          client.saveScore( race.raceTime, miscData ) ;
        }
//        timeOutInterval = setInterval( fatal, client.TIMEOUT, "Pas réponse du serveur", "timeout for endGame" ) ;
        vs.finalPhase++ ;
        break ;

    case 41 : // SERVEUR: callback
        if ( client.fl_success ) {
          gdebug("callback...") ;
          detachNetworkPop() ;
//          clearInterval( timeOutInterval ) ;
          vs.finalPhase=0 ;
        }
        break ;


    // *** CLASSEMENT SERVEUR
    case 50 : // CLASSEMENT FRUTIPARC: affichage
        if ( !skipTest() ) {
          // Panneau de récap
          var d = this.calcDepth(DP_INTERF) ;
          var ranking = client.ranking ;
          attachMovie( "announce", "announce", d ) ;
          announce._x = (docWidth/2) ;
          announce._y = (docHeight/2) ;
          announce.pos_txt = ranking.bestScorePos ;
          announce.raceTime_txt = timeToString( race.raceTime ) ;

          var ecart = ranking.oldPos - ranking.bestScorePos ;
          if ( ecart!=0 ) {
            // Progression
            announce.win.gotoAndStop(7) ;
            announce.details = "" ;
            if ( ecart==1 )
              announce.details = "Vous avez progressé de 1 place" ;
            else
              if ( ranking.oldPos != 0 )
                announce.details = "Vous avez progressé de "+ecart+" places !" ;
          }
          else {
            // Pas de progression
            announce.win.gotoAndStop(8) ;
          }
          vs.finalPhase++ ;
        }
        break ;


    case 51 : // CLASSEMENT FRUTIPARC: attente
        if ( skipTest() ) {
          playSoundBK("buttonOk") ;
          announce.removeMovieClip() ;
          vs.finalPhase = 3 ;
        }
        break ;


    // *** DUEL
    case 60 : // DUEL: déblocage d'une écurie
        if ( !skipTest() ) {
          var d = this.calcDepth(DP_INTERF) ;
          attachMovie( "announce", "announce", d ) ;
          announce._x = (docWidth/2) ;
          announce._y = (docHeight/2) ;
          announce.win.gotoAndStop(9) ;
          announce.win.team.gotoAndStop( vs.selectedAdv+1 ) ;
//          if (!availableCars[vs.selectedAdv])
          if ( !vs.useSpecials ) {
            giveItem("$logo0"+(vs.selectedAdv+1)) ;
            availableCars[vs.selectedAdv] = true ;
          }
          savePublic() ;

          finalScrolls.removeMovieClip() ;

          vs.finalPhase++ ;
        }
        break ;

    case 61 : // DUEL: attente
        if ( skipTest() ) {
          playSoundBK("buttonOk") ;
          announce.removeMovieClip() ;
          skipToTrackPresent = false ;
          gotoMenu() ;
        }
        break ;

  }
}


/*-----------------------------------------------
    ANIM DES CONFETTIS
 ------------------------------------------------*/
function moveConfettis() {
  for ( var i=0 ; i<fx.length ; i++ ) {
    var mc = fx[i] ;
    if ( mc.isConfetti ) {
      mc.cpt += 0.05 * gtmod ;
      mc._x = mc.baseX + Math.cos(mc.cpt) * mc.margeX ;
      mc._y += mc.dy * gtmod ;
      if ( mc._y > 370 ) {
        mc.removeMovieClip() ;
        fx.splice(i,1) ;
        if (!killConfettis) spawnConfetti() ;
      }
    }
  }
}



/*-----------------------------------------------
    INIT DES CONFETTIS ^^
 ------------------------------------------------*/
function spawnConfetti() {
  var d,mc ;

  d = this.calcDepth(DP_FXTOP) ;
  attachMovie( "confetti", "confetti_"+d, d ) ;
  mc = this["confetti_"+d] ;

  mc._x = random(300)+20 ;
  mc._y = -random(150) ;
  mc._rotation = random(360) ;

  mc.dy = random(40)/10 + 2 ;
  mc.cpt = random( Math.PI*100 )/100 ;
  mc.baseX = mc._x ;
  mc.margeX = random(50) ;
  mc.anim.gotoAndPlay( random(20)+1 ) ;
  mc.isConfetti = true ;

  fx.push( mc ) ;
}


/*-----------------------------------------------
    EFFACE TOUS LES CONFETTIS
 ------------------------------------------------*/
function clearConfettis() {
  for ( var i=fx.length-1 ; i>=0 ; i-- )
    if ( fx[i].isConfetti ) {
      fx[i].removeMovieClip() ;
      fx.splice(i,1) ;
    }
}



/*-----------------------------------------------
    DÉTERMINE SI LA PARTIE EST TERMINÉE
 ------------------------------------------------*/
function gameEnded() {
  var ended = false ;

  switch ( vs.gameMode ) {
    case FRUTICUP: // Fruticoupe
        // vs.selectedTrack == 4 && vs.$wcs
        if ( ( vs.giveUp ) ||
             ( vs.selectedTrack == 3 && !vs.$wss ) ||
             ( vs.selectedTrack == 3 && tournament.podium[0] != 0 ) ||
             ( vs.selectedTrack == 5 ) ) {
          ended = true ;
        }
        break ;

    case ARCADE: // Arcade
    case TRAINING: // Entrainement
    case DUEL: // Duel
    case TIMETRIAL: // TimeTrial
    case KIWIRUN: // KiwiRun
    case TUTORIAL: // Tutorial
        ended = true ;
        break ;

    case SURVIVOR: // Survivor
        if ( ( vs.giveUp ) ||
             ( tournament.vs.lives <= 0 ) ||
             ( vs.selectedTrack == 5 && classement==1 ) ) {
          ended = true ;
        }
        break ;

    default :
        ended = true ;
        break ;
  }

  return ended ;
}



/*------------------------------------------------------------------------
    RETOUR AU MENU
 ------------------------------------------------------------------------*/
function gotoMenu() {
  vs.finalPhase = -1 ;
  if ( vs.gameMode == TUTORIAL || client.isWhite() ) {
    vs.mainPhase = 0 ;
  }
  else {
    client.closeService() ;
  }
}



/*-----------------------------------------------
    INIT DE LA PHASE FINALE
 ------------------------------------------------*/
function initFinal() {
  // Sons
  if ( musicON ) {
    stopMusic( musicGame ) ;
    startMusic( musicMenu ) ;
  }

  // Classement
  if ( vs.giveUp ) {
    classement = 4 ;
  }
  else {
    for ( i=0 ; i<orderFinal.length ; i++ )
      if ( orderFinal[i] == 0 )
        classement=i+1 ;
  }
  race.rank = getRank() ;

  // Anim des scolls
  d = this.calcDepth(DP_INTERF) ;
  attachMovie( "finalScrolls", "finalScrolls", d ) ;
  finalScrolls._x = (docWidth/2) ;
  finalScrolls._y = (docHeight/2) ;

  // Divers
  killConfettis = false ;
  initGrid() ;

  // Qualité
  setDetailLevel( qualitySetting ) ;

  // Envoi des données au serveur si la partie est finie
  savePublic() ;
  gdebug("gameEnded="+gameEnded()) ;
  if ( gameEnded() && vs.gameMode!=TUTORIAL )
    vs.finalPhase = 40 ;
  else
    vs.finalPhase = 0 ;
}


