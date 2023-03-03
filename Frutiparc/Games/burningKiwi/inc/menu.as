/***
  SCRIPT DU MENU:

    PRINCIPAL:
      1-modes de jeu
        11-arcade -> 3
        12-tutorial -> 4
        13-evolution -> 6
        14-events -> 7
        99-retour -> 99

      2-options
        21-qualitySetting
        22-interface
        23-sons
        24-musique
        25-touches -> 30
        99-retour

      3-courses
        3n-course n
        4-ok -> 4
        1-retour -> 1 / 6 / 7

      4-voitures
        4n-voiture n
        5-ok -> 5
        3-retour -> 3

      5-intro course

      6-evolution
        61-duel -> 3
        62-essais -> 3
        63-tournoi classique (voitures) -> 4
        64-tournoi survivor (courses) -> 4
        99-retour -> 1

      7-events
        71-kiwirun -> 5
        99-retour -> 1

      8-courses extras

      20-palmarès
        99-retour -> 99

      99-menu principal

      100-intro

***/


/*-----------------------------------------------
    BOUCLE MAIN MENU
 ------------------------------------------------*/
function mainMenu () {
  var i,mc ;

  animGrid() ;

  manageButtons() ;
  manageSpecials() ; // gestion des cheats
  moveConfettis() ;
  moveBgFx() ;


  switch (vs.menuPhase) {

    case -1: break ;


    // ***** MODES DE JEU *****
    case 1 :
      stack(vs.menuPhase) ;
      menuMC.bande._visible = true ;
      menuMC.infoPanel.txt = "" ;
      if ( !menuMC.infoPanel._visible ) {
        menuMC.infoPanel.gotoAndPlay(1) ;
        menuMC.infoPanel._visible = true ;
      }

      // Callback normal
      var skinBt, onPushAllow, onPushDisallow ;
      onPushAllow = function() {
        playSoundBK("buttonOk") ;
        removeAllButtons() ;
        menuMC.infoPanel.gotoAndPlay("hide") ;
      } ;
      // Callback de bouton grisé
      onPushDisallow = function() {
        playSoundBK("buttonRefuse") ;
        if ( !limited._visible ) {
          limited.label = demoLabel ;
          limited._visible = true ;
          limited.gotoAndPlay(1) ;
        }
      } ;


      menuMC.menuTitleANIM.menuTitle.title = "modes de jeu" ;

      // Entrainement
      if ( checkMode(TRAINING) ) {
        skinBt = skinAllow ;
        onPush = onPushAllow ;
        onEnd = function() { vs.menuPhase = 140 ; vs.gameMode = TRAINING ; } ;
        onOver = function() { menuMC.infoPanel.txt = "La piste est à vous ! Entrainement illimité sur la course du jour !" ; }
        onOut = function() { menuMC.infoPanel.txt = "" ; }
        attachButton(11, "essais", skinBt, 10,80, onPush, undefined, onEnd, onOver, onOut) ;
      }
      else {
        // Arcade
        if ( checkMode(ARCADE) ) {
          skinBt = 2 ;
          onPush = onPushAllow ;
          onEnd = function() { vs.menuPhase = 140 ; vs.gameMode = ARCADE ; } ;
        }
        else {
          skinBt = skinDisallow ;
          onPush = onPushDisallow ;
          onEnd = undefined ;
        }
        onOver = function() { menuMC.infoPanel.txt = "Faites le meilleur temps sur la course du jour" ; }
        onOut = function() { menuMC.infoPanel.txt = "" ; }
        attachButton(11, "challenge", skinBt, 10,80, onPush, undefined, onEnd, onOver, onOut) ;
      }

      // Tutorial
      if ( checkMode(TUTORIAL) ) {
        skinBt = skinAllow ;
        onPush = onPushAllow ;
        onEnd = function() { vs.menuPhase = 4 ; vs.gameMode = TUTORIAL ; vs.selectedTrack = 99 ; } ;
      }
      else {
        skinBt = skinDisallow ;
        onPush = onPushDisallow ;
        onEnd = undefined ;
      }
      onOver = function() { menuMC.infoPanel.txt = "Découvrez les principes du jeu et entraînez-vous librement" ; }
      onOut = function() { menuMC.infoPanel.txt = "" ; }
      attachButton(12, "tutorial", skinBt, -5,120, onPush, undefined, onEnd, onOver, onOut) ;

      // Évolution
      onPush = function() { playSoundBK("buttonOk") ; removeAllButtons() ; } ;
      onEnd = function() { vs.menuPhase = 6 ; } ;
      onOver = function() { menuMC.infoPanel.txt = "Débloquez de nouvelles fonctionnalités" ; }
      onOut = function() { menuMC.infoPanel.txt = "" ; }
      attachButton(13, "evolution", 1, -20,160, onPush, undefined, onEnd, onOver, onOut) ;

      // Épreuves
      onPush = function() { playSoundBK("buttonOk") ; removeAllButtons() ; } ;
      onEnd = function() { vs.menuPhase = 7 ; } ;
      onOver = function() { menuMC.infoPanel.txt = "Participez aux épreuves organisées sur Frutiparc !" ; }
      onOut = function() { menuMC.infoPanel.txt = "" ; }
      attachButton(14, "epreuves", 1, -25,200, onPush, undefined, onEnd, onOver, onOut) ;

      onPush = function() { back(); playSoundBK("buttonCancel") ; removeAllButtons() ; menuMC.infoPanel.gotoAndPlay("hide") ; } ;
      onEnd = function() {  } ;
      attachButton(getPrevious(), "retour", 2, -70,320, onPush, undefined, onEnd) ;

      vs.menuPhase = -1 ;
      break;



    // ***** OPTIONS *****
    case 2 :
      menuMC.menuTitleANIM.menuTitle.title = "options" ;


      // Bouton détails
      onPush = function() {
        playSoundBK("buttonSwitch") ;
        this.pushed=false ;
        qualitySetting-- ;
        if (qualitySetting<LOW) qualitySetting=AUTO ;
        this.onUpdate() ;
      } ;
      onUpdate = function() {
        this.pushed=false ;
        if (qualitySetting==AUTO) {
          menuButton_21.skin.label="details: auto" ;
        }
        if (qualitySetting==HIGH) {
          menuButton_21.skin.label="details: hauts" ;
        }
        if (qualitySetting==MEDIUM) {
          menuButton_21.skin.label="details: moyen" ;
        }
        if (qualitySetting==LOW) {
          menuButton_21.skin.label="details: bas" ;
        }
        setDetailLevel( qualitySetting ) ;
      } ;
      onEnd = function() {  } ;
      attachButton(21, "details: hauts", 1, 45,80, onPush, onUpdate, onEnd) ;


      // Bouton interface
      onPush = function() {
        playSoundBK("buttonSwitch") ;
        this.pushed=false ;
        panelON = !panelON ;
        this.onUpdate() ;
      } ;
      onUpdate = function() {
        if (panelON)
          menuButton_22.skin.label="interface: oui" ;
        else {
          menuButton_22.skin.label="interface: non" ;
        }
      }
      onEnd = function() {  } ;
      attachButton(22, "interface: oui", 1, 30,120, onPush, onUpdate, onEnd) ;


      // Bouton Sons
      onPush = function() {
        if ( soundsON) playSoundBK("buttonSwitch") ;
        this.pushed=false ;
        soundsON = !soundsON ;
        if ( soundsON) playSoundBK("buttonSwitch") ;
        this.onUpdate() ;
      } ;
      onUpdate = function() {
        if (soundsON)
          menuButton_23.skin.label="sons: oui" ;
        else
          menuButton_23.skin.label="sons: non" ;
      }
      onEnd = function() {  } ;
      attachButton(23, "sons: oui", 1, 20,160, onPush, onUpdate, onEnd) ;


      // Bouton Musique
      onPush = function() {
        playSoundBK("buttonSwitch") ;
        this.pushed=false ;
        musicON = !musicON ;
        if ( musicON ) {
          startMusic( musicMenu ) ;
        }
        else {
          stopMusic( musicMenu ) ;
        }
        this.onUpdate() ;
      } ;
      onUpdate = function() {
        if (musicON)
          menuButton_24.skin.label="musique: oui" ;
        else
          menuButton_24.skin.label="musique: non" ;
      }
      onEnd = function() {  } ;
      attachButton(24, "musique: oui", 1, 13,200, onPush, onUpdate, onEnd) ;


      onPush = function() { playSoundBK("buttonOk") ; removeAllButtons() ; } ;
      onEnd = function() { vs.menuPhase = 30 ; } ;
      attachButton(25, "touches", 1, 9,240, onPush, undefined, onEnd) ;


      // Bouton debug: attribution d'items  xxx
      /***
      onPush = function() {
        playSoundBK("buttonSwitch") ;
        this.pushed=false ;
        var itemClass=random(3) ;
        switch (itemClass) {
          case 0:
              var itemId = random(5) ;
              giveItem("$car0"+itemId) ;
              break ;
          case 1:
              var itemId = random(5) ;
              giveItem("$logo0"+itemId) ;
              break ;
          case 2:
              var itemId = random(4) ;
              if (itemId==0) giveItem("$fruticup") ;
              if (itemId==1) giveItem("$fruticupxl") ;
              if (itemId==2) giveItem("$elite") ;
              if (itemId==3) giveItem("$elitexl") ;
              break ;
        }
        this.onUpdate() ;
      } ;
      onEnd = function() {  } ;
      attachButton(26, "titems", 1, 13,280, onPush, undefined, onEnd) ; /***/


      onPush = function() { playSoundBK("buttonOk") ; removeAllButtons() ; } ;
      onEnd = function() {  } ;

      attachButton(130, "valider", 2, -70,320, onPush, undefined, onEnd) ;

      vs.menuPhase = -1 ;
      break;



    // ***** COURSES *****
    case 3 :
      stack(vs.menuPhase) ;
      menuMC.bande._visible = false ;
      menuMC.infoPanel._visible = false ;
      menuMC.menuTitleANIM.menuTitle.title = "courses" ;
      menuMC.trackSel._visible=true ;
      if ( vs.selectedTrack > 3 && !vs.$wss )
        vs.selectedTrack = 0 ;
      if ( vs.selectedTrack == 99 )
        vs.selectedTrack = 0 ;
      for (i=0 ; i<tracks.length ; i++) {
        mc = menuMC.trackSel["track"+i] ;
        if (i==vs.selectedTrack)
          mc._visible=true ;
        else
          mc._visible=false ;
      }

      onPush = function() {
        playSoundBK("buttonSwitch") ;
        this.pushed=false ;
        mc = menuMC.trackSel["track"+vs.selectedTrack] ;
        mc._visible = false ;
        vs.selectedTrack = 0 ;
        mc = menuMC.trackSel["track"+vs.selectedTrack] ;
        mc._visible = true ;
      } ;
      attachButton(31, tracks[0].title, 3, -8,80, onPush, undefined, undefined) ;

      onPush = function() {
        playSoundBK("buttonSwitch") ;
        this.pushed=false ;
        mc = menuMC.trackSel["track"+vs.selectedTrack] ;
        mc._visible = false ;
        vs.selectedTrack = 1 ;
        mc = menuMC.trackSel["track"+vs.selectedTrack] ;
        mc._visible = true ;
      } ;
      attachButton(32, tracks[1].title, 3, -8,120, onPush, undefined, undefined) ;

      onPush = function() {
        playSoundBK("buttonSwitch") ;
        this.pushed=false ;
        mc = menuMC.trackSel["track"+vs.selectedTrack] ;
        mc._visible = false ;
        vs.selectedTrack = 2 ;
        mc = menuMC.trackSel["track"+vs.selectedTrack] ;
        mc._visible = true ;
      } ;
      attachButton(33, tracks[2].title, 3, -8,160, onPush, undefined, undefined) ;

      onPush = function() {
        playSoundBK("buttonSwitch") ;
        this.pushed=false ;
        mc = menuMC.trackSel["track"+vs.selectedTrack] ;
        mc._visible = false ;
        vs.selectedTrack = 3 ;
        mc = menuMC.trackSel["track"+vs.selectedTrack] ;
        mc._visible = true ;
      } ;
      attachButton(34, tracks[3].title, 3, -8,200, onPush, undefined, undefined) ;

      if ( checkMode(SURVIVOR) && vs.$wss ) {
        onPush = function() {
          playSoundBK("buttonOk") ;
          menuMC.trackSel._visible=false ;
          removeAllButtons() ;
        } ;
        onEnd = function() { } ;
        attachButton(8, "extras", 2, -8,240, onPush, undefined, onEnd) ;
      }
      else {
        onPush = function() { playSoundBK("buttonRefuse") ; } ;
        onEnd = undefined ;
        attachButton(35, "extras", 4, -8,240, onPush, undefined, onEnd) ;
      }


      onPush = function() {
        playSoundBK("buttonOk") ;
        menuMC.trackSel._visible=false ;
        removeAllButtons() ;
      } ;
      onEnd = function() { } ;
      attachButton(4, "ok", 2, -70,280, onPush, undefined, onEnd) ;

      onPush = function() {
        back();
        playSoundBK("buttonCancel") ;
        menuMC.trackSel._visible=false ;
        removeAllButtons() ;
      } ;
      onEnd = function() { } ;
      attachButton(getPrevious(), "retour", 2, -70,320, onPush, undefined, onEnd) ;

      vs.menuPhase = -1 ;
      break;



    // ***** VOITURES *****
    case 4 :
      stack(vs.menuPhase) ;
      menuMC.bande._visible = false ;
      menuMC.infoPanel._visible = false ;
      menuMC.menuTitleANIM.menuTitle.title = "voitures" ;
      menuMC.carSel._visible=true ;

      var skinBt ;
      var currentName ;

      updateStats( vs.selectedCar ) ;

      // Ultra
      if ( availableCars[0] )
        skinBt = 3 ;
      else
        skinBt = 4 ;
      onPush = function() {
        playSoundBK("buttonSwitch") ;
        this.pushed = false ;
        vs.selectedCar = 0 ;
        updateStats( vs.selectedCar ) ;
      } ;
      currentName = carSkinNames[0] ;
      if ( specials[5].state ) currentName = "UltraCop" ;
      if ( specials[4].state ) currentName = carSkinNames[20] ;
      attachButton(41, currentName.toLowerCase(), skinBt, -15,80, onPush, undefined, undefined) ;

      // UWE
      if ( availableCars[1] )
        skinBt = 3 ;
      else
        skinBt = 4 ;
      onPush = function() {
        playSoundBK("buttonSwitch") ;
        this.pushed = false ;
        vs.selectedCar = 1 ;
        updateStats( vs.selectedCar ) ;
      } ;
      currentName = carSkinNames[1] ;
      if ( specials[4].state ) currentName = carSkinNames[21] ;
      attachButton(42, currentName.toLowerCase(), skinBt, -15,120, onPush, undefined, undefined) ;

      // Fury
      if ( availableCars[2] )
        skinBt = 3 ;
      else
        skinBt = 4 ;
      onPush = function() {
        playSoundBK("buttonSwitch") ;
        this.pushed = false ;
        vs.selectedCar = 2 ;
        updateStats( vs.selectedCar ) ;
      } ;
      currentName = carSkinNames[2] ;
      if ( specials[4].state ) currentName = carSkinNames[22] ;
      attachButton(43, currentName.toLowerCase(), skinBt, -15,160, onPush, undefined, undefined) ;

      // Sonic
      if ( availableCars[3] )
        skinBt = 3 ;
      else
        skinBt = 4 ;
      onPush = function() {
        playSoundBK("buttonSwitch") ;
        this.pushed = false ;
        vs.selectedCar = 3 ;
        updateStats( vs.selectedCar ) ;
      } ;
      currentName = carSkinNames[3] ;
      if ( specials[4].state ) currentName = carSkinNames[23] ;
      attachButton(44, currentName.toLowerCase(), skinBt, -15,200, onPush, undefined, undefined) ;

      // KiwiX
//      if ( specials[0].state ) { // cheat Kiwix
      if ( availableCars[4] ) {
        skinBt = 3 ;
        onPush = function() {
          playSoundBK("buttonSwitch") ;
          this.pushed = false ;
          vs.selectedCar = 4 ;
          updateStats( vs.selectedCar ) ;
        } ;
        currentName = carSkinNames[4] ;
        if ( specials[4].state ) currentName = carSkinNames[24] ;
        attachButton(45, currentName.toLowerCase(), skinBt, -15,240, onPush, undefined, undefined) ;
      }


      onPush = function() {
        if ( !availableCars[vs.selectedCar] )
        {
          // Véhicule non autorisé
          playSoundBK("buttonRefuse") ;
          if ( !limited._visible ) {
            if ( !isWhite() )
              limited.label = demoLabel ;
            else
              limited.label = carsLabel ;
            limited._visible = true ;
            limited.gotoAndPlay(1) ;
          }
          this.pushed = false ;
        }
        else {
          // Validation
          playSoundBK("buttonOk") ;
          menuMC.carSel._visible=false ;
          removeAllButtons() ;
          if ( vs.gameMode != DUEL ) {
            menuMC.fondMenu.play() ;
            menuMC.menuTitleANIM.play() ;
          }
        }
      } ;
      onEnd = function() {  }
      var nextPhase = 5 ;
      if ( vs.gameMode==DUEL )
        nextPhase = 150 ;
      attachButton(nextPhase, "ok", 2, -70,280, onPush, undefined, onEnd) ;

      onPush = function() {
        back();
        playSoundBK("buttonCancel") ;
        menuMC.carSel._visible=false ;
        removeAllButtons() ;
      } ;
      onEnd = function() {  } ;
      attachButton(getPrevious(), "retour", 2, -70,320, onPush, undefined, onEnd) ;

      vs.menuPhase = -1 ;
      break;


    // ***** AVERTISSEMENT CHEAT *****
    case 5 :
      stack(vs.menuPhase) ;
      menuMC.bande._visible = false ;
      // Cheats trouvés dans un mode les interdisant
      if ( vs.useSpecials && ( vs.gameMode==ARCADE || vs.gameMode==FRUTICUP || vs.gameMode==SURVIVOR || vs.gameMode==TIMETRIAL ) ) {
        menuMC.warningSpecials._visible = true ;

        onPush = function() {
          playSoundBK("buttonOk") ;
          menuMC.warningSpecials._visible = false ;
          removeAllButtons() ;
        } ;
        onEnd = function() {  } ;
        attachButton(90, "ok", 2, -70,320, onPush, undefined, onEnd) ;

        vs.menuPhase = -1 ;
      }
      else {
        vs.menuPhase = 90 ;
      }
      break ;


    // ***** ÉVOLUTION *****
    case 6 :
      stack(vs.menuPhase) ;
      menuMC.bande._visible = true ;
      menuMC.infoPanel.txt = "" ;
      if ( !menuMC.infoPanel._visible ) {
        menuMC.infoPanel.gotoAndPlay(1) ;
        menuMC.infoPanel._visible = true ;
      }

      // Callback normal
      var skinBt, onPushAllow, onPushDisallow ;
      onPushAllow = function() {
        playSoundBK("buttonOk") ;
        removeAllButtons() ;
        menuMC.infoPanel.gotoAndPlay("hide") ;
      } ;
      // Callback de bouton grisé
      onPushDisallow = function() {
        playSoundBK("buttonRefuse") ;
        if ( !limited._visible ) {
          limited.label = demoLabel ;
          limited._visible = true ;
          limited.gotoAndPlay(1) ;
        }
      } ;
      // Callback de bouton grisé (mode non débloqué)
      onPushDisallowMode = function() {
        playSoundBK("buttonRefuse") ;
        if ( !limited._visible ) {
          limited.label = modeLabel ;
          limited._visible = true ;
          limited.gotoAndPlay(1) ;
        }
      } ;

      menuMC.menuTitleANIM.menuTitle.title = "evolution" ;

      // Duel
      if ( checkMode(DUEL) && vs.$wcs ) {
        skinBt = skinAllow ;
        onPush = onPushAllow ;
        onEnd = function() { vs.menuPhase = 4 ; vs.gameMode = DUEL ; vs.selectedTrack=duelTrack } ;
      }
      else {
        skinBt = skinDisallow ;
        if ( !checkMode(DUEL) )
          onPush = onPushDisallow ;
        else
          onPush = onPushDisallowMode ;
        onEnd = undefined ;
      }
      onOver = function() { menuMC.infoPanel.txt = "Affrontez une écurie pour accéder à leur véhicule" ; }
      onOut = function() { menuMC.infoPanel.txt = "" ; }
      attachButton(61, "duel", skinBt, 10,80, onPush, undefined, onEnd, onOver, onOut) ;

      // TimeTrial
      onPush = onPushStd ;
      if ( checkMode(TIMETRIAL) ) {
        skinBt = skinAllow ;
        onPush = onPushAllow ;
        onEnd = function() { vs.menuPhase = 3 ; vs.gameMode = TIMETRIAL ; } ;
      }
      else {
        skinBt = skinDisallow ;
        onPush = onPushDisallow ;
        onEnd = undefined ;
      }
      onOver = function() { menuMC.infoPanel.txt = "Un accès exclusif aux pistes pour des courses contre la montre!" ; }
      onOut = function() { menuMC.infoPanel.txt = "" ; }
      attachButton(62, "TimeTrial", skinBt, 13,120, onPush, undefined, onEnd, onOver, onOut) ;

      // Fruticoupe
      var skinBtSmall ;
      onPush = onPushStd ;
      if ( checkMode(FRUTICUP) ) {
        skinBt = skinAllow ;
        skinBtSmall = 3 ;
        onPush = onPushAllow ;
        onEnd = function() { vs.menuPhase = 4 ; vs.selectedTrack = 0 ; vs.gameMode = FRUTICUP ; newTournament = true ; } ;
      }
      else {
        skinBt = skinDisallow ;
        skinBtSmall = skinDisallow ;
        onPush = onPushDisallow ;
        onEnd = undefined ;
      }
      onOver = function() { menuMC.infoPanel.txt = "Gagnez la FrutiCoupe pour activer de nouveaux modes de jeu" ; }
      onOut = function() { menuMC.infoPanel.txt = "" ; }
      if ( vs.$wss )
        attachButton(63, "fruticoupe XL", skinBtSmall, 7,160, onPush, undefined, onEnd, onOver, onOut) ;
      else
        attachButton(63, "fruticoupe", skinBt, 16,160, onPush, undefined, onEnd, onOver, onOut) ;

      // Survivor
      onPush = onPushStd ;
      if ( checkMode(SURVIVOR) && vs.$wcs ) {
        skinBt = skinAllow ;
        onPush = onPushAllow ;
        onEnd = function() { vs.menuPhase = 4 ; vs.selectedTrack = 0 ; vs.gameMode = SURVIVOR ; newTournament = true ; } ;
      }
      else {
        skinBt = skinDisallow ;
        if ( !checkMode(SURVIVOR) )
          onPush = onPushDisallow ;
        else
          onPush = onPushDisallowMode ;
        onEnd = undefined ;
      }
      onOver = function() { menuMC.infoPanel.txt = "Débloquez les circuits et les coupes XL dans ce tournoi d'endurance !" ; }
      onOut = function() { menuMC.infoPanel.txt = "" ; }
      if ( vs.$wss )
        attachButton(64, "elite XL", skinBt, -4,200, onPush, undefined, onEnd, onOver, onOut) ;
      else
        attachButton(64, "elite", skinBt, -4,200, onPush, undefined, onEnd, onOver, onOut) ;



//      // Ghost-Run
//      if ( client.checkMode(GHOSTRUN) ) {
//        skinBt = skinAllow ;
//        onPush = onPushAllow ;
//        onEnd = function() { vs.menuPhase = 3 ; vs.gameMode = GHOSTRUN } ;
//      }
//      else {
//        skinBt = skinDisallow ;
//        if ( !client.checkMode(GHOSTRUN) )
//          onPush = onPushDisallow ;
//        else
//          onPush = onPushDisallowMode ;
//        onEnd = undefined ;
//      }
//      onOver = function() { menuMC.infoPanel.txt = "Rivalisez avec votre pire adversaire: vous !" ; }
//      onOut = function() { menuMC.infoPanel.txt = "" ; }
//      attachButton(65, "ghost run", skinBt, -23,240, onPush, undefined, onEnd, onOver, onOut) ;


      // Cancel
      onPush = function() {
        back();
        playSoundBK("buttonCancel") ;
        removeAllButtons() ;
        limited.gotoAndPlay("hide") ;

      } ;
      onEnd = function() {  } ;
      attachButton(getPrevious(), "retour", 2, -70,320, onPush, undefined, onEnd) ;

      vs.menuPhase = -1 ;
      break;


    // ***** EVENTS *****
    case 7 :
      stack(vs.menuPhase) ;
      menuMC.bande._visible = true ;
      menuMC.infoPanel.txt = "" ;
      if ( !menuMC.infoPanel._visible ) {
        menuMC.infoPanel.gotoAndPlay(1) ;
        menuMC.infoPanel._visible = true ;
      }

      // Callback normal
      var skinBt, onPushAllow, onPushDisallow ;
      onPushAllow = function() {
        playSoundBK("buttonOk") ;
        removeAllButtons() ;
        menuMC.infoPanel.gotoAndPlay("hide") ;
      } ;
      // Callback de bouton grisé
      onPushDisallow = function() {
        playSoundBK("buttonRefuse") ;
        if ( !limited._visible ) {
          limited.label = demoLabel ;
          limited._visible = true ;
          limited.gotoAndPlay(1) ;
        }
      } ;

      menuMC.menuTitleANIM.menuTitle.title = "epreuves" ;

      // KiwiRun
      if ( checkMode(KIWIRUN) ) {
        skinBt = skinAllow ;
        onPush = onPushAllow ;
        onEnd = function() { vs.menuPhase = 4 ; vs.selectedTrack = 0 ; vs.gameMode = KIWIRUN ; } ;
      }
      else {
        skinBt = skinDisallow ;
        onPush = onPushDisallow ;
        onEnd = undefined
      }
      onOver = function() { menuMC.infoPanel.txt = "Ramassez au plus vite les bonus placés sur la course !" ; }
      onOut = function() { menuMC.infoPanel.txt = "" ; }
      attachButton(71, "kiwi run", skinBt, 10,80, onPush, undefined, onEnd, onOver, onOut) ;

      // Cancel
      onPush = function() { back(); playSoundBK("buttonCancel") ; removeAllButtons() ; } ;
      onEnd = function() {  } ;
      attachButton(getPrevious(), "retour", 2, -70,320, onPush, undefined, onEnd) ;

      vs.menuPhase = -1 ;
      break;



    // ***** COURSES EXTRAS *****
    case 8 :
      menuMC.bande._visible = false ;
      menuMC.infoPanel._visible = false ;
      menuMC.menuTitleANIM.menuTitle.title = "extras" ;
      menuMC.trackSel._visible=true ;
      for (i=0 ; i<tracks.length ; i++) {
        mc = menuMC.trackSel["track"+i] ;
        if (i==vs.selectedTrack)
          mc._visible=true ;
        else
          mc._visible=false ;
      }

      onPush = function() {
        playSoundBK("buttonSwitch") ;
        this.pushed=false ;
        mc = menuMC.trackSel["track"+vs.selectedTrack] ;
        mc._visible = false ;
        vs.selectedTrack = 4 ;
        mc = menuMC.trackSel["track"+vs.selectedTrack] ;
        mc._visible = true ;
      } ;
      attachButton(31, tracks[4].title, 3, -8,80, onPush, undefined, undefined) ;

      onPush = function() {
        playSoundBK("buttonSwitch") ;
        this.pushed=false ;
        mc = menuMC.trackSel["track"+vs.selectedTrack] ;
        mc._visible = false ;
        vs.selectedTrack = 5 ;
        mc = menuMC.trackSel["track"+vs.selectedTrack] ;
        mc._visible = true ;
      } ;
      attachButton(32, tracks[5].title, 3, -8,120, onPush, undefined, undefined) ;

      if (vs.$wss) {
        onPush = function() {
          playSoundBK("buttonOk") ;
          menuMC.trackSel._visible=false ;
          removeAllButtons() ;
        } ;
        onEnd = function() { } ;
        attachButton(3, "normales", 2, -8,240, onPush, undefined, onEnd) ;
      }

      onPush = function() {
        playSoundBK("buttonOk") ;
        menuMC.trackSel._visible=false ;
        removeAllButtons() ;
      } ;
      onEnd = function() { } ;
      attachButton(4, "ok", 2, -70,280, onPush, undefined, onEnd) ;

      onPush = function() {
        back();
        playSoundBK("buttonCancel") ;
        menuMC.trackSel._visible=false ;
        removeAllButtons() ;
      } ;
      onEnd = function() { } ;
      attachButton(getPrevious(), "retour", 2, -70,320, onPush, undefined, onEnd) ;

      vs.menuPhase = -1 ;
      break;


    // ***** PALMARÈS *****
    case 20 :
        stack(vs.menuPhase) ;
        menuMC.menuTitleANIM.menuTitle.title = "palmares" ;

        // Bouton Temps
        onPush = function() { playSoundBK("buttonOk") ; removeAllButtons() ; } ;
        onEnd = function() {  } ;
        attachButton(21, "Temps", 1, 10,80, onPush, undefined, onEnd) ;

        // Bouton Coupes
        onPush = function() {
          removeAllButtons() ;
          playSoundBK("buttonOk") ;
        } ;
        onEnd = function() {  } ;
        attachButton(25, "Coupes", 1, -5,120, onPush, undefined, onEnd) ;

        // Bouton retour
        onPush = function() { back(); playSoundBK("buttonCancel") ; removeAllButtons() ; } ;
        onEnd = function() {  } ;
        attachButton(getPrevious(), "retour", 2, -70,320, onPush, undefined, onEnd) ;

        vs.menuPhase = -1 ;
        break ;


    // ***** TEMPS *****
    case 21 :
        stack(vs.menuPhase) ;
        var d = this.calcDepth(DP_INTERF) ;
        attachMovie("announce","announce",d) ;
        announce._x = (docWidth/2) ;
        announce._y = (docHeight/2) ;
        announce.win.gotoAndStop(6) ;
        for (var i=0;i<nbTracks;i++) {
          // Temps au tour
          if ( trackStats[i].$fcLap == Infinity ) {
            announce["b"+i] = "     -" ;
            announce.win["lapCar_"+i]._visible = false ;
          }
          else {
            announce["b"+i] = timeToString( trackStats[i].$fcLap ) ;
            announce.win["lapCar_"+i].skin.gotoAndStop( carStats[trackStats[i].$lapCar].skin ) ;
            announce.win["lapCar_"+i].boost._visible = false ;
          }
          // Temps total
          if ( trackStats[i].$fcTotal == Infinity ) {
            announce["t"+i] = "     -" ;
            announce.win["totalCar_"+i]._visible = false ;
          }
          else {
            announce["t"+i] = timeToString( trackStats[i].$fcTotal ) ;
            announce.win["totalCar_"+i].skin.gotoAndStop( carStats[trackStats[i].$totalCar].skin ) ;
            announce.win["totalCar_"+i].boost._visible = false ;
          }
        }

        menuMC.fondMenu.play() ;
        menuMC.menuTitleANIM.play() ;
        menuMC.bande._visible = false ;

        onPush = function() {
          back();
          playSoundBK("buttonCancel") ;
          removeAllButtons() ;
          announce.removeMovieClip() ;
          menuMC.fondMenu.gotoAndPlay(1) ;
          menuMC.menuTitleANIM.gotoAndPlay(1) ;
          menuMC.bande._visible = true ;
          killConfettis = true ;
          clearShines() ;
        } ;
        onEnd = function() {  } ;
        attachButton(getPrevious(), "retour", 2, -70,320, onPush, undefined, onEnd) ;

        vs.menuPhase = -1 ;
        break ;


    // ***** COUPES *****
    case 25 :
        stack(vs.menuPhase) ;
        var d = this.calcDepth(DP_INTERF) ;
        attachMovie("announce","announce",d) ;
        announce._x = (docWidth/2) ;
        announce._y = (docHeight/2) ;
        announce.win.gotoAndStop(5) ;

        var maxConfettis = 0 ;
        clearConfettis() ;
        killConfettis = false ;

        // CLASSIC silver
        if ( !vs.$wcs )
          announce.win.classicSilv._visible = false ;
        else
          maxConfettis += 3 ;

        // CLASSIC
        if ( !vs.$wc )
          announce.win.classic._visible = false ;
        else
          maxConfettis += 15 ;

        // SURVIVOR silver
        if ( !vs.$wss )
          announce.win.survSilv._visible = false ;
        else
          maxConfettis += 3 ;

        // SURVIVOR
        if ( !vs.$ws )
          announce.win.surv._visible = false ;
        else
          maxConfettis += 7 ;

        // Etoile de l33t
        if ( vs.$ws && vs.$wc )
          announce.win.stars._visible = true ;
        else
          announce.win.stars._visible = false ;

        menuMC.fondMenu.play() ;
        menuMC.menuTitleANIM.play() ;
        menuMC.bande._visible = false ;

        for (var i=0;i<maxConfettis;i++)
          spawnConfetti() ;


        onPush = function() {
          playSoundBK("buttonCancel") ;
          back();
          removeAllButtons() ;
          announce.removeMovieClip() ;
          menuMC.fondMenu.gotoAndPlay(1) ;
          menuMC.menuTitleANIM.gotoAndPlay(1) ;
          menuMC.bande._visible = true ;
          killConfettis = true ;
          clearShines() ;
        } ;
        onEnd = function() {  } ;
        attachButton(getPrevious(), "retour", 2, -70,320, onPush, undefined, onEnd) ;

        canMoveShines = false ; // mis à TRUE dans le MC announce
        vs.menuPhase++ ;
        break ;


    // ***** PALMARÈS : attente *****
    case 26 :
      if ( canMoveShines )
        moveShines() ;
      break ;


    // ***** TOUCHES : affichage *****
    case 30 :
      menuMC.menuTitleANIM.menuTitle.title = "touches" ;
      attachMovie("keysManager","keys", this.calcDepth(DP_INTERF) ) ;
      keys._x = (docWidth/2) ;
      keys._y = (docHeight/2) ;
      keys.manager.stop() ;
      keys.manager.conflict._visible = false ;
      keyAsked = undefined ;

      for (var i=0;i<controlNames.length;i++) {
        keys.manager["controlName_"+i] = controlNames[i] ;
        keys.manager["control_"+i] = keyNames[ controls[i] ] ;
      }

      onPush = function() { keys.removeMovieClip() ; playSoundBK("buttonOk") ; removeAllButtons() ; } ;
      onEnd = function() {  } ;
      attachButton(2, "valider", 2, -70,320, onPush, undefined, onEnd) ;

      vs.menuPhase = 31 ;
      break ;


    // ***** TOUCHES : attente du choix d'un contrôle à modifier *****
    case 31 :
      if ( keyAsked != undefined ) {
        playSoundBK("buttonKeys") ;
        keys.manager.gotoAndStop(2) ;
        keys.manager.current = controlNames[keyAsked] ;
        vs.menuPhase = 32 ;
      }
      break ;

    // ***** TOUCHES : attente d'une touche *****
    case 32 :
      var touche = getAnyKey() ;
      if ( touche != undefined ) {
        if ( touche != Key.ESCAPE ) {
          controls[keyAsked] = touche ;
          keys.manager["control_"+keyAsked] = keyNames[touche]
          playSoundBK("buttonKeysOk") ;
        }
        else
          playSoundBK("buttonCancel") ;
        keyAsked = undefined ;
        keys.manager.gotoAndStop(1) ;

        // Gestion des conflits de touches
        var conflict = checkConflicts() ;
        keys.manager.conflict._visible = conflict ;
        menuButton_2._visible = !conflict ;

        vs.menuPhase = 31 ;
      }
      break ;


    // ***** INTRO COURSE *****
    case 90 :
        stack(vs.menuPhase) ;
        menuMC.bande._visible = false ;
        menuMC.introCourseANIM._visible = true ;
        menuMC.introCourseANIM.gotoAndPlay(1) ;
        if ( tracks[vs.selectedTrack].totalLaps <= 1 )
          menuMC.introCourseANIM.toursTxt = tracks[vs.selectedTrack].totalLaps+" tour" ;
        else
          menuMC.introCourseANIM.toursTxt = tracks[vs.selectedTrack].totalLaps+" tours" ;
        for (i=0 ; i<tracks.length ; i++) {
          mc = menuMC.introCourseANIM.introCourse.trackSel["track"+i] ;
          if (i==vs.selectedTrack)
            mc._visible=true ;
          else
            mc._visible=false ;
        }
        menuMC.introCourseANIM.introCourse.title = tracks[vs.selectedTrack].title.toLowerCase() ;
        menuMC.introCourseANIM.introCourse.summary = tracks[vs.selectedTrack].summary ;
        vs.menuPhase ++ ;
        break ;


    // ***** INTRO COURSE : attente *****
    case 91 :
        if ( skipTest() ) {
          playSoundBK("buttonOk") ;
          if ( skipToTrackPresent )
            vs.mainPhase = 3 ;
          else
            vs.menuPhase ++ ;
        }
        break ;

    // ***** INTRO COURSE : envoi au serveur *****
    case 92 :
        if ( vs.gameMode == TUTORIAL ) { // Mode tutorial
          vs.mainPhase = 3 ;
          break ;
        }
        attachNetworkPop() ;
        savePublic() ;
        gdebug("startgame") ;
        client.startGame() ;
        vs.menuPhase ++ ;
        break ;

    // ***** INTRO COURSE : données reçues *****
    case 93 :
        if ( client.error ) {
          detachNetworkPop() ;
          menuMC.introCourseANIM._visible = false ;
          menuMC.fondMenu.gotoAndPlay(1) ;
          menuMC.menuTitleANIM.gotoAndPlay(1) ;
          menuMC.bande._visible = true ;
          vs.menuPhase = 99 ;
        }
        if ( client.fl_success ) {
          detachNetworkPop() ;
          vs.mainPhase = 3 ;
        }
        break ;


    // ***** MENU PRINCIPAL *****
    case 99 :
        stack(99) ;
        menuMC.bande._visible = true ;
        menuMC.infoPanel._visible = false ;
        menuMC.menuTitleANIM.menuTitle.title = "menu principal" ;
        // Bouton jouer
        onPush = function() { playSoundBK("buttonOk") ; removeAllButtons() ; } ;
        onEnd = function() {  } ;
        attachButton(1, "jouer", 1, 10,80, onPush, undefined, onEnd) ;

        var skin ;
        if ( client.isWhite() ) {
          onPush = function() {
            playSoundBK("buttonOk") ;
            removeAllButtons() ;
          } ;
          onEnd = function() {  } ;
          skin = skinAllow ;
        }
        else {
          onPush = function() {
            playSoundBK("buttonRefuse") ;
            if ( !limited._visible ) {
              limited.label = demoLabel ;
              limited._visible = true ;
              limited.gotoAndPlay(1) ;
            }
          } ;
          onEnd = undefined ;
          skin = skinDisallow ;
        }
        attachButton(20, "palmares", skin, -5,120, onPush, undefined, onEnd) ;

        // Bouton options
        onPush = function() { playSoundBK("buttonOk") ; removeAllButtons() ; } ;
        onEnd = function() {  } ;
        attachButton(2, "options", 1, -20,160, onPush, undefined, onEnd) ;

        vs.menuPhase = -1 ;
        break;



    // ***** INTRO : affichage *****
    case 100 :
        this.createEmptyMovieClip("intro", this.calcDepth(DP_PRELOAD)) ;
        intro._visible = false ;
        startPreload( intro, "intro.swf", "Chargement de l'intro") ;
        vs.menuPhase++ ;
        break ;
    case 101 :
        if ( mainPreload() ) {
          grille._visible = false ;
          intro._visible = true ;
          vs.menuPhase++ ;

          if ( musicON )
            if ( !musicMenu.isPlaying ) {
              stopMusic( musicGame ) ;
              startMusic( musicMenu ) ;
            }
        }
        break ;
    case 102 :
        if ( skipTest() ) {
          intro.removeMovieClip() ;
          grille._visible = true ;
          vs.menuPhase++ ;
        }
        break ;

    case 103 :
        var d ;
        stack(vs.menuPhase) ;

        d = this.calcDepth(DP_PRELOAD) ;
        attachMovie("logo","logo",d) ;
        logo._x = (docWidth/2) ;
        logo._y = (docHeight/2) ;


        if ( musicON )
          if ( !musicMenu.isPlaying ) {
            stopMusic( musicGame ) ;
            startMusic( musicMenu ) ;
          }
        vs.menuPhase++ ;
        break ;

    // ***** INTRO : anti-skip *****
    case 104 :
        if ( !skipTest() )
          vs.menuPhase++ ;
        break ;

    // ***** INTRO : attente *****
    case 105 :
        if ( skipTest() ) {
          playSoundBK("buttonOk") ;
          logo.gotoAndPlay("hide") ;
          menuMC.fondMenu.gotoAndPlay(1) ;
          menuMC.menuTitleANIM.gotoAndPlay(1) ;
          menuMC.bande._visible = true ;
          vs.menuPhase = 99 ;
        }
        break ;


    // ***** LOADER MUSIC DE MENU : init *****
    case 110 :
      // Skip
      if ( menuMusicLoaded ) {
        vs.menuPhase = 103 ;
        break ;
      }

      musicMenu = initMusicLoader(musicMenuMC, "bkMenu.mp3") ;
      vs.menuPhase++ ;
      break ;

    // ***** LOADER MUSIC DE MENU : boucle *****
    case 111 :
      if ( mainPreload() ) {
        menuMusicLoaded = true ;
        vs.menuPhase = 100 ;
      }
      break ;


    // ***** CONNEXION: ouverture de la connexion *****
    case 120 :
        attachNetworkPop() ;
        client.serviceConnect() ;
        gdebug("Connecting to service...") ;
        vs.menuPhase ++ ;
        break ;

    // ***** CONNEXION: connecté et prêt (onServerReady) *****
    case 121 :
        if ( client.error ) {
          detachNetworkPop() ;
          vs.menuPhase = -1 ;
        }
        if ( client.connected ) {
          fl_allowReset = true ;
          gdebug("daily="+client.dailyData) ;
          gdebug("client.manager="+client.manager) ;
          gdebug("client.manager.frusionClient="+client.manager.frusionClient) ;
          gdebug("daily in frusionClient="+client.manager.frusionClient.dailyData) ;
          initFrutiCardContent() ;
          readFrutiCard() ;
          gdebug("DiscType: (B:"+client.isBlack()+" G:"+client.isGrey()+" W:"+client.isWhite()+")") ;
          gdebug("array = "+frutiSlots[SLOT_MODES]);
          warning("Now testing modes...");
          gdebug("training = "+checkMode(TRAINING));
          gdebug("arcade = "+checkMode(ARCADE));
          gdebug("fruticup = "+checkMode(FRUTICUP));
          gdebug("duel = "+checkMode(DUEL));
          gdebug("timetrial = "+checkMode(TIMETRIAL));
          gdebug("kiwirun = "+checkMode(KIWIRUN));
          gdebug("survivor = "+checkMode(SURVIVOR));
          gdebug("ghostrun = "+checkMode(GHOSTRUN));
          detachNetworkPop() ;
          vs.menuPhase++ ;
        }
        break ;

    // ***** CONNEXION: test du Stage *****
    case 122 :
        if ( Stage.width==350 && Stage.height==350 )
          vs.menuPhase = 110 ;
        else {
          fatal("Votre frusion ne peut afficher correctement ce jeu", "bad size: "+Stage.width+"x"+Stage.height);
          vs.menuPhase = -1;
        }
        break ;


    // ***** CONNEXION: sauvegarde des préférences *****
    case 130 :
        attachNetworkPop() ;
        savePreferences() ;
        vs.menuPhase++ ;
        break ;
    case 131 :
        if ( client.fl_success ) {
          detachNetworkPop() ;
          vs.menuPhase = 99 ;
        }
        break ;



    // ***** COURSE CHALLENGE *****
    case 140 :
      stack(vs.menuPhase) ;
      menuMC.bande._visible = false ;
      menuMC.infoPanel._visible = false ;
      menuMC.menuTitleANIM.menuTitle.title = "" ;
      menuMC.menuTitleANIM.play() ;
      menuMC.fondMenu.play() ;
      menuMC.dailyTrack._visible = true ;

      var dailyXML = new XML( client.dailyData ) ;
      vs.selectedTrack = parseInt( dailyXML.firstChild.attributes.trk, 10 ) ;
      menuMC.dailyTrack.trackName = tracks[vs.selectedTrack].title.toLowerCase() ;

      if ( client.dailyData==undefined ) {
//        vs.selectedTrack=0 ;/**            // xxx
        fatal("La course du jour n'a pas été choisie par le grand jury","dailyData undefined") ;/***/
      }

      for (var i=0 ; i<tracks.length ; i++) {
        var mc = menuMC.dailyTrack.track["track"+i] ;
        if (i == vs.selectedTrack)
          mc._visible=true ;
        else
          mc._visible=false ;
      }

      // Nombre de tours
      if ( tracks[vs.selectedTrack].totalLaps <= 1 )
        menuMC.toursTxt = tracks[vs.selectedTrack].totalLaps+" tour" ;
      else
        menuMC.toursTxt = tracks[vs.selectedTrack].totalLaps+" tours" ;


      onPush = function() {
        menuMC.menuTitleANIM.gotoAndPlay(1) ;
        menuMC.fondMenu.gotoAndPlay(1) ;
        playSoundBK("buttonOk") ;
        removeAllButtons() ;
        menuMC.dailyTrack._visible = false ;
      } ;
      onEnd = function() { } ;
      attachButton(4, "jouer", 2, -70,280, onPush, undefined, onEnd) ;


      onPush = function() {
        menuMC.menuTitleANIM.gotoAndPlay(1) ;
        menuMC.fondMenu.gotoAndPlay(1) ;
        playSoundBK("buttonCancel") ;
        back();
        removeAllButtons() ;
        menuMC.dailyTrack._visible = false ;
      } ;
      onEnd = function() { } ;
      attachButton(getPrevious(), "retour", 2, -70,320, onPush, undefined, onEnd) ;


      vs.menuPhase = -1 ;
      break;


    // ***** DUEL: choix adversaire *****
    case 150 :
        stack(vs.menuPhase) ;
        menuMC.bande._visible = false ;
        menuMC.infoPanel.gotoAndPlay(1) ;
        menuMC.infoPanel._visible = true ;
        menuMC.infoPanel.txt = "Choisissez l'écurie que vous affronterez." ;

        menuMC.menuTitleANIM.menuTitle.title = "adversaire" ;

        this.attachMovie("teamList", "teamList", this.calcDepth(DP_INTERF) ) ;
        teamList._x = docWidth-75 ;
        teamList._y = 120 ;
        teamList._xscale = 57 ;
        teamList._yscale = teamList._xscale ;
        teamList.gotoAndStop( vs.selectedAdv+1 ) ;

        // ULTRA ORANGE
        var onPush = function() {
          playSoundBK("buttonSwitch") ;
          this.pushed = false ;
          vs.selectedAdv = 0 ;
          teamList.gotoAndStop( vs.selectedAdv+1 ) ;
        } ;
        attachButton(41, carSkinNames[0].toLowerCase(), 3, -15,80, onPush, undefined, undefined) ;

        // UWE WING
        var onPush = function() {
          playSoundBK("buttonSwitch") ;
          this.pushed = false ;
          vs.selectedAdv = 1 ;
          teamList.gotoAndStop( vs.selectedAdv+1 ) ;
        } ;
        attachButton(42, carSkinNames[1].toLowerCase(), 3, -15,120, onPush, undefined, undefined) ;

        // FURY HUN
        var onPush = function() {
          playSoundBK("buttonSwitch") ;
          this.pushed = false ;
          vs.selectedAdv = 2 ;
          teamList.gotoAndStop( vs.selectedAdv+1 ) ;
        } ;
        attachButton(43, carSkinNames[2].toLowerCase(), 3, -15,160, onPush, undefined, undefined) ;

        // SONIC BRAIN
        var onPush = function() {
          playSoundBK("buttonSwitch") ;
          this.pushed = false ;
          vs.selectedAdv = 3 ;
          teamList.gotoAndStop( vs.selectedAdv+1 ) ;
        } ;
        attachButton(44, carSkinNames[3].toLowerCase(), 3, -15,200, onPush, undefined, undefined) ;

        // KIWIX
        var onPush = function() {
          playSoundBK("buttonSwitch") ;
          this.pushed = false ;
          vs.selectedAdv = 4 ;
          teamList.gotoAndStop( vs.selectedAdv+1 ) ;
        } ;
        attachButton(45, carSkinNames[4].toLowerCase(), 3, -15,240, onPush, undefined, undefined) ;


        onPush = function() {
          teamList.removeMovieClip() ;
          playSoundBK("buttonOk") ;
          menuMC.infoPanel.gotoAndPlay("hide") ;
          menuMC.fondMenu.play() ;
          menuMC.menuTitleANIM.play() ;
          removeAllButtons() ;
        } ;
        onEnd = function() { } ;
        attachButton(90, "ok", 2, -70,280, onPush, undefined, onEnd) ;

        onPush = function() {
          back() ;
          teamList.removeMovieClip() ;
          playSoundBK("buttonCancel") ;
          removeAllButtons() ;
        } ;
        onEnd = function() { } ;
        attachButton(getPrevious(), "retour", 2, -70,320, onPush, undefined, onEnd) ;

        vs.menuPhase = -1 ;
        break ;


  }

}



/*-----------------------------------------------
    BOUCLES DE GESTION DES BOUTONS
 ------------------------------------------------*/
function manageButtons() {
  var i ;
  for ( i=0 ; i<buttons.length ; i++ ) {
    mc = buttons[i] ;
    if (!mc.kill && killAll) mc.play() ;

    if (mc.kill) {
      buttons.splice (i,1) ;
      mc.removeMovieClip() ;
      i-- ;
    }
  }

  if (killAll) killAll=false ;
}



/*-----------------------------------------------
    BOUCLES DE GESTION DES CHEAT CODES
 ------------------------------------------------*/
function manageSpecials() {
  var i ;

  if ( skipToTrackPresent )
    return ;

  // Parcoure la liste des codes et vérifie lequel est saisi
  for (var i=0;i<specials.length;i++) {
    // vérifie si la touche où on en est pour un code donné est pressée
    if ( Key.isDown( specials[i].chaine.charCodeAt(specials[i].pos) ) ) {
      specials[i].pos ++ ;

      // code entièrement saisi
      if ( specials[i].pos >= specials[i].chaine.length ) {
        specials[i].pos = 0 ;
        if ( client.isWhite() ) {
          // Jeu complet
          specialsUsed = true ;
          specials[i].state = !specials[i].state ;
          sBox.removeMovieClip() ;
          attachMovie( "specialsBox","sBox",this.calcDepth(DP_SPECIALSBOX) ) ;
          sBox._x = (docWidth/2) ;
          sBox._y = 100 ;
          sBox.txt = specials[i].chaine ;
          if ( specials[i].state )
            sBox.underTxt = "activé" ;
          else
            sBox.underTxt = "désactivé" ;

          // Teste si il y a au moins 1 cheat de gameplay actif
          vs.useSpecials = false ;
          for (var j=0;j<specials.length;j++) {
            if ( specials[j].state && j!=4 && j!=5 && j!=6 )
              vs.useSpecials = true ;
          }

          // Si la KiwiX est choisie alors que le code est désactivé...
          if ( vs.selectedCar == 4 && !specials[i].state && i==0 )
            vs.selectedCar = 0 ;
        }
        else {
          if ( !limited._visible ) {
            limited.label = demoLabel ;
            limited._visible = true ;
            limited.gotoAndPlay(1) ;
          }
        }
      }
      specTimeOut = 40 ;
    }
  }

  // on réinitialise la saisie au bout d'un délai court
  if ( specTimeOut ) {
    specTimeOut -= gtmod ;
    if ( specTimeOut <= 0 ) {
      specTimeOut = 0 ;
      for (var i=0;i<specials.length;i++)
        specials[i].pos = 0 ;
    }
  }
}



/*-----------------------------------------------
    EFFACE LES REFLETS SUR LES COUPES
 ------------------------------------------------*/
function clearShines() {
  // Boucle de gestion de la durée de vie
  for (var i=0;i<fx.length;i++) {
    if ( fx[i].isShine ) {
      fx[i].removeMovieClip() ;
      fx.splice(i,1) ;
      i-- ;
    }
  }
}


/*-----------------------------------------------
    BOUCLE DES REFLETS SUR LES COUPES
 ------------------------------------------------*/
function moveShines() {

  // Spawn
  if ( random(10) == 0 ) {
    var win, x,y, tries, maxTries, valid ;
    maxTries = 15 ;
    tries = 0 ;
    win = announce.win ;

    // Cherche un point sur une coupe
    valid = false ;
    do {
      x = random(docWidth) ;
      y = random(docHeight) ;
      if ( ( win.classic.hitTest(x,y,true) && win.classic._visible ) ||
           ( win.classicSilv.hitTest(x,y,true) && win.classicSilv._visible ) ||
           ( win.surv.hitTest(x,y,true) && win.surv._visible ) ||
           ( win.survSilv.hitTest(x,y,true) && win.survSilv._visible ) )
        valid = true;
      tries ++ ;
    } while ( tries<maxTries && !valid ) ;

    // Attache le reflet si un point a été trouvé
    if ( tries < maxTries ) {
      var d,mc ;
      d = this.calcDepth(DP_FXTOP,true) ;
      attachMovie("shine","shine_"+d,d) ;
      mc = this["shine_"+d] ;
      mc._x = x ;
      mc._y = y ;
      mc._xscale = random(40)+20 ;
      mc._yscale = mc._xscale ;
      mc._rotation = random(360) ;
      mc.kill = false ;
      mc.isShine = true ;
      fx.push(mc) ;
    }
  }


  // Boucle de gestion de la durée de vie
  for (var i=0;i<fx.length;i++) {
    if ( fx[i].kill ) {
      fx[i].removeMovieClip() ;
      fx.splice(i,1) ;
      i-- ;
    }
  }
}



/*-----------------------------------------------
    BOUCLE DES ANIMS DE FOND DE MENU
 ------------------------------------------------*/
function moveBgFx() {
  if ( bgFx.length < 2 && gameQuality >= MEDIUM  )
    attachBgFx() ;

  for (var i=0;i<bgFx.length;i++) {
    var f = bgFx[i] ;

    f.timer -= gtmod ;
    f._xscale += gtmod ;
    f._yscale = f._xscale ;

    if ( gameQuality < MEDIUM )
      f.timer = 0 ;

    // Temps de vie
    if ( f.timer <= 0 ) {
      // Attache un autre effet
      if ( !f.doOnce ) {
        f.doOnce = true ;
        if ( gameQuality >= MEDIUM )
          attachBgFx() ;
      }
      // Disparition en alpha
      f._alpha -= gtmod ;
      if ( f._alpha <= 0 ) {
        f.removeMovieClip() ;
        bgFx.splice(i,1) ;
      }
    }
    else {
      // Apparition en alpha
      f._alpha += gtmod ;
      f._alpha = Math.min( f._alpha, f.maxAlpha ) ;
    }

  }
}



/*-----------------------------------------------
    ATTACHE UN EFFET FOND DE MENU
 ------------------------------------------------*/
function attachBgFx() {
  var d,mc ;
  d = this.calcDepth(DP_FXBG) ;
  attachMovie("backgroundFx","bgFx_"+d,d) ;

  mc = this["bgFx_"+d] ;
  mc._x = random(290)+30 ;
  mc._y = random(290)+30 ;
  mc.gotoAndStop( random(nbBgFx)+1 ) ;
  mc.timer = random(80)+40 ;
  mc._alpha = 0 ;
  mc._xscale = random(50)+20 ;
  mc._yscale = mc._xscale ;
  mc.maxAlpha = random(20) + 30 ;

  bgFx.push(mc) ;
}



/*-----------------------------------------------
    ATTACH D'UN BOUTON DU MENU
 ------------------------------------------------*/
function attachButton (id, label, skin, x,y, pushFunction, updateFunction, endFunction, overFunction, outFunction) {
  var d, mc ;
  d = this.calcDepth(DP_INTERF) ;
  attachMovie ("menuButton", "menuButton_"+id, d) ;
  mc = this["menuButton_"+id] ;
  mc._x = x ;
  mc._y = y ;
  mc.id = id ;
  mc.skin.label = label.toLowerCase() ;
  mc.skin.gotoAndStop(skin) ;
  mc.onPush = pushFunction ;
  mc.onUpdate = updateFunction ;
  mc.onEnd = endFunction ;
  mc.onOver = overFunction ;
  mc.onOut = outFunction ;

  buttons.push(mc) ;
  return mc ;
}





/*-----------------------------------------------
    DISPARITION DE TOUS LES BOUTONS
 ------------------------------------------------*/
function removeAllButtons() {
  killAll=true ;
}



/*-----------------------------------------------
    MET A JOUR LES JAUGES DE STATS DU
    PANNEAU DES ECURIES
 ------------------------------------------------*/
function updateStats(idCar) {
  // Masque tous les logos de voitures et affiche celui sélectionné
  menuMC.carSel.car_5._visible = false ;
  for (var i=0 ; i<carStats.length ; i++) {
    if (i==idCar) {
      if ( idCar==0 && specials[5].state && !specials[4].state  )
        menuMC.carSel.car_5._visible = true ;
      else
        menuMC.carSel["car_"+i]._visible = true ;
    }
    else
      menuMC.carSel["car_"+i]._visible = false ;
  }

  // Met à jour les stats
  mc = menuMC.carSel.stats ;
//  mc.gotoAndStop(idCar+1) ;
  mc.speed.mask._xscale = staticStats[idCar].maxSpeed * 100 ;
  mc.accel.mask._xscale = staticStats[idCar].accel * 100 ;
  mc.grip.mask._xscale = staticStats[idCar].grip * 100 ;
  mc.rot.mask._xscale = staticStats[idCar].rot * 100 ;
  i = 0 ;
  while ( mc["kiwi_"+i] != undefined ) {
    if ( i < carStats[idCar].kiwis )
      mc["kiwi_"+i]._visible = true ;
    else
      mc["kiwi_"+i]._visible = false ;
    i++ ;
  }
}



/*-----------------------------------------------
    ANIMATION DU SCROLLING EN FOND
 ------------------------------------------------*/
function animGrid () {
  if ( gameQuality<HIGH )
    return ;

  if ( grille.nbCycles >= grille.nbCyclesMax ) {
  	grille.nbCycles = 0 ;
  	grille.nbCyclesMax = random(50)+50 ;
  	grille.tang = random(180) * ( random(2)*2-1 ) ;
  }

  if (grille.ang < grille.tang) {
  	grille.ang += 5 ;
  	if (grille.ang > grille.tang)
  		grille.ang = grille.tang ;
  }
  if (grille.ang > grille.tang) {
  	grille.ang -= 5 ;
  	if (grille.ang < grille.tang)
  		grille.ang = grille.tang ;
  }

  grille.angRad =  (Math.PI/180) * grille.ang ;
  grille.dx = Math.cos(grille.angRad) * grille.speed ;
  grille.dy = Math.sin(grille.angRad) * grille.speed ;

  grille._x += grille.dx ;
  grille._y += grille.dy ;

  if (grille._x>100) grille._x -=68 ;
  if (grille._x<0) grille._x +=68 ;
  if (grille._y>100) grille._y -=68 ;
  if (grille._y<0) grille._y +=68 ;

  grille.nbCycles ++ ;
}



/*-----------------------------------------------
    INITIALISATION DU MENU
 ------------------------------------------------*/
function initGrid() {
  if ( grille._x == undefined ) {
    // Anim de la grille qui scroll en fond
    grille.removeMovieClip() ;
    d = this.calcDepth(DP_GRID) ;
    attachMovie( "grille", "grille", d ) ;
    grille.dx = 0 ;
    grille.dy = 0 ;
    grille.speed = 7 ;
    grille.ang = 0 ;
    grille.nbCycles = 0 ;
    grille.nbCyclesMax = 0 ;
    grille._x = 0 ;
    grille._y = 0 ;
  }
}



/*-----------------------------------------------
    FONCTION APPELÉE EN FIN DE MENU
 ------------------------------------------------*/
function endMenu() {
  vs.mainPhase = 3 ;
}



/*-----------------------------------------------
    RENVOIE true S'IL Y A UN CONFLIT DE CONTRÔLES
 ------------------------------------------------*/
function checkConflicts() {
  var conflict = false ;

  for (var i=0;i<controls.length;i++)
    for (var j=i+1;j<controls.length;j++)
      if ( controls[i] == controls[j] )
        conflict = true ;

  return conflict ;
}



/*------------------------------------------------------------------------
    AJOUTE UNE PHASE DANS L'HISTORIQUE DES PHASES
 ------------------------------------------------------------------------*/
function stack( phaseId ) {
  if ( history[history.length-1] != phaseId )
    history.push(phaseId) ;
}



/*------------------------------------------------------------------------
    AJOUTE UNE PHASE DANS L'HISTORIQUE DES PHASES
 ------------------------------------------------------------------------*/
function back() {
  history.splice( history.length-1 ) ;
}



/*------------------------------------------------------------------------
    RENVOIE LA PHASE PRÉCÉDENTE
 ------------------------------------------------------------------------*/
function getPrevious() {
  return history[ history.length-2 ] ;
}



/*-----------------------------------------------
    INITIALISATION DU MENU
 ------------------------------------------------*/
function initMenu() {

  if ( vs.selectedTrack == 99 )
    vs.selectedTrack = 0 ;


  // Attache le menu
  var d = this.calcDepth(DP_MENU) ;
  this.attachMovie( "mainMenu", "menuMC", d ) ;
  menuMC._x = (docWidth/2) ;
  menuMC._y = (docHeight/2) ;

  // Prépare la grille de fond
  initGrid() ;

  // Effets de fond
  attachBgFx() ;
  attachBgFx() ;

  // Divers
  killConfettis = false ;
  newTournament = false ;
  if ( skipToTrackPresent ) {
    menuMC.fondMenu._visible = false ;
    menuMC.menuTitleANIM._visible = false ;
    vs.menuPhase=90 ; // pour les tournois, on zap direct à la présentation de la course
  }
  else {
    if ( client.connected )
      vs.menuPhase=110 ; // Loader musique de menu
    else
      vs.menuPhase=120 ; // Loading des données du serveur
  }
  history = new Array() ;

  // Qualité
  setDetailLevel( qualitySetting ) ;

  // Masquages
  menuMC.dailyTrack._visible = false ;
  menuMC.trackSel._visible = false ;
  menuMC.carSel._visible = false ;
  menuMC.introCourseANIM._visible = false ;
  menuMC.introCourseANIM.gotoAndStop(1) ;
  menuMC.infoPanel.stop() ;
  menuMC.infoPanel._visible = false ;
  limited.stop() ;
  limited._visible = false ;
  menuMC.warningSpecials._visible = false ;
  menuMC.bande._visible = false ;
  menuMC.fondMenu.gotoAndStop(1) ;
  menuMC.menuTitleANIM.gotoAndStop(1) ;

  // Indicateur de refus
  this.attachMovie("limited","limited",this.calcDepth(DP_FXTOP)) ;
  limited._x = 80 ;
  limited._y = 240 ;
  limited.stop() ;
  limited._visible = false ;
}


