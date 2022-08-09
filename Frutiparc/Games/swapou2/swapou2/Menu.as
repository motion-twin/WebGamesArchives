import swapou2.Manager;
import swapou2.Data;
import swapou2.Sounds;

class swapou2.Menu {

  public var depthMan ;

  var btList ;
  var phase ;
  var animPhase ;
  var stack ; // historique pour les retours
  var animList ;
  var onEnd ;
  var wait ;
  var selectedButton ;
  var timer ;
  var clicked ;
  var lock ;
  var wins_flag ;
  var wantedPlayer ; // for face selection

  var mc;
  var bg, logo, menuFruit, shadow, leftChar, rightChar, bar, versus, netBox ;
  var attackIcon, defenseIcon ;
  var gameButton ;


  /*------------------------------------------------------------------------
  CONSTRUCTEUR
  ------------------------------------------------------------------------*/
  function Menu( mc ) {
    this.mc = mc;

	if( !Manager.start_menu )		
		Sounds.playMusic(Sounds.MUSIC_MENU);	

    depthMan = new asml.DepthManager(mc);
    bg = depthMan.attach("bg",Data.DP_BG) ;
    bg.stop() ;

    rightChar = Std.cast( depthMan.attach("fullNatacha",Data.DP_INTERFTOP) ) ;
    rightChar._x = Data.DOCWIDTH-200 ;
    rightChar._xscale = Data.CHAR_SCALE ;
    rightChar._yscale = rightChar._xscale ;
    rightChar.stop() ;

    leftChar = Std.cast( depthMan.attach("fullDimitri",Data.DP_INTERFTOP) ) ;
    leftChar._x = 200 ;
    leftChar._xscale = Data.CHAR_SCALE ;
    leftChar._yscale = leftChar._xscale ;
    leftChar.stop() ;

    bar = Std.cast( depthMan.attach("helpBar",Data.DP_INTERFTOP) ) ;
    bar._x = Data.DOCWIDTH/2 ;
    bar._y = 20 ;
    bar.txtField.text = "" ;

    shadow = Std.cast( depthMan.attach("bigShadow",Data.DP_INTERF) ) ;
    shadow._x = Data.MENU_FRUIT_X
    shadow._y = Data.DOCHEIGHT-40 ;

    menuFruit = Std.cast( depthMan.attach("menuFruit",Data.DP_INTERF) ) ;
    menuFruit.gotoAndStop( string(random(menuFruit._totalframes)+1) ) ;
    menuFruit._x = Data.MENU_FRUIT_X ;
    menuFruit._y = Data.MENU_FRUIT_Y ;
    //    menuFruit._alpha = 0 ;
    menuFruit._xscale = 20 ;
    menuFruit._yscale = menuFruit._xscale ;
    menuFruit.cpt = 0 ;
    menuFruit.scaleCpt = 0 ;
    menuFruit.moveCpt = 0 ;
    menuFruit.x = menuFruit._x ;
    menuFruit.y = menuFruit._y ;
    menuFruit.ds = 0 ;

    var bt : swapou2.SimpleButton = Std.cast( depthMan.attach("swapou2_simpleButton",Data.DP_BG) ) ;
    bt.attach(this, "gameButton",0,0,release) ;
    bt.disable() ;
    gameButton = bt ;

    setVisible(false) ;

    btList = new Array() ;
    stack = new Array() ;
    animList = new Array() ;

    clicked = false ;
    selectedButton = 0 ;
    wait = 10 ;
    animPhase = 0 ;
//    animPhase = 10 ; // xxx
//    setVisible(true) ; // xxx
    phase = 10 ;
  }


  /*------------------------------------------------------------------------
  BOUCLE MAIN
  ------------------------------------------------------------------------*/
  function main() {

    // Mouvement de la poire
    if ( Data.lod>=Data.MEDIUM ) {
      menuFruit._x = menuFruit.x + Math.cos(menuFruit.cpt)*Data.MENU_FRUIT_MOVE/2 ;
      menuFruit._y = menuFruit.y + Math.sin(menuFruit.cpt)*Data.MENU_FRUIT_MOVE ;
    }
    else {
      menuFruit._x = menuFruit.x ;
      menuFruit._y = menuFruit.y ;
    }
    menuFruit.cpt += 0.05 * Std.tmod ;


    // Masquage du menu
    switch ( animPhase ) {
    // ** LOGO
    case 0 :
      netBox._visible = false ;
      logo = Std.cast( depthMan.attach("mainLogo",Data.DP_INTERFTOP) ) ;
      logo._x = Data.DOCWIDTH/2 ;
      logo._y = Data.DOCHEIGHT/2 ;
//      wait = 60 ;
      waitClick() ;
      animPhase++ ;
      break ;
    case 1 :
  	  logo._xscale = 100 - Math.cos(wait/5) * 5;
  	  logo._yscale = 100 - Math.sin(wait/5) * 5;
      wait-=Std.tmod ;
      if ( clicked ) {
        logo.gotoAndPlay("hide") ;
        setVisible(true) ;
        menuFruit._visible = true ;
        shadow._visible = true ;
        shadow._y = menuFruit.y + 200 * menuFruit._yscale/100 ;
        animPhase = 15 ;
      }
      break ;

      // ** ARRIVÉE MENU
    case 10 :
      leftChar._xscale += (100 - leftChar._xscale) * 0.3 ;
      leftChar._yscale = leftChar._xscale ;
      rightChar._xscale += (100 - rightChar._xscale) * 0.3 ;
      rightChar._yscale = rightChar._xscale ;
      if ( leftChar._xscale >= Data.CHAR_SCALE-3 ) {
        leftChar._xscale = Data.CHAR_SCALE ;
        leftChar._yscale = leftChar._xscale ;
        rightChar._xscale = Data.CHAR_SCALE ;
        rightChar._yscale = rightChar._xscale ;
        animPhase = 15 ;
      }
      //
      break ;
    case 15 :
      leftChar._x -= (leftChar._x)*0.3 ;
      rightChar._x += (Data.DOCWIDTH-rightChar._x)*0.3 ;
      if ( leftChar._x <= 5 ) {
        leftChar._x = 0 ;
        rightChar._x = Data.DOCWIDTH ;
        menuFruit.ds = 0 ;
        animPhase++ ;
      }
      break ;
    case 16 :
      shadow._y = menuFruit.y + 200 * menuFruit._yscale/100 ;
      shadow._alpha = menuFruit._alpha ;
      menuFruit._xscale += Std.tmod*(100-menuFruit._xscale)*0.2 ;
      menuFruit._yscale = menuFruit._xscale ;
      if ( menuFruit._xscale>= Data.MENU_FRUIT_SCALE-3) {
        menuFruit._xscale = Data.MENU_FRUIT_SCALE ;
        menuFruit._yscale = menuFruit._xscale ;
        netBox._visible = true ;
        animPhase++ ;
      }
      break ;
    case 17:
      if (!lock) {
        jump(phase) ;
        animPhase=20 ;
      }
      break ;

      // ** MAIN
    case 20 :
      if ( Data.lod>=Data.HIGH ) {
        menuFruit._xscale = Math.sin(menuFruit.scaleCpt+Math.PI)*5+Data.MENU_FRUIT_SCALE ;
        menuFruit._yscale = Math.sin(menuFruit.scaleCpt)*5+Data.MENU_FRUIT_SCALE ;
      }
      else {
        menuFruit._xscale = 100 ;
        menuFruit._yscale = 100 ;
      }
      menuFruit.scaleCpt += 0.13 * Std.tmod ;
      break ;

      // ** FIN MENU
    case 30 :
      menuFruit.ds += Data.MENU_MOVE * Std.tmod ;
      menuFruit._xscale -= menuFruit.ds * Std.tmod ;
      menuFruit._yscale = menuFruit._xscale ;
      menuFruit._alpha = menuFruit._xscale ;
      shadow._y -= Std.tmod*8 ;
      shadow._alpha = menuFruit._alpha ;
      if ( menuFruit._xscale<0 )
        animPhase++ ;
      break ;
    case 31 : // MOVE PERSONNAGES
      leftChar._x -= 13*Std.tmod ;
      rightChar._x += 13*Std.tmod ;
      if ( leftChar._x <= -leftChar._width ) {
        if ( (Data.gameMode == Data.CHALLENGE && !lock) || Data.gameMode == Data.HISTORY || Data.gameMode == Data.CLASSIC )
          onEnd() ;
        if ( Data.gameMode == Data.DUEL )
          animPhase = 40 ;
      }
      break ;

      // ** VERSUS
    case 40 :
      attachVersus() ;
      waitClick() ;
      animPhase++ ;
      break ;
    case 41 :
      if ( clicked ) {
        versus.gotoAndPlay("hide") ;
        animPhase++ ;
      }
      break ;
    case 42 :
      if ( versus._currentframe==versus._totalframes ) {
        versus.removeMovieClip() ;
        animPhase++ ;
      }
      break ;
    case 43 :
      if ( !lock )
        onEnd() ;
      break ;
    }


    shadow._x = menuFruit._x ;
//    if ( Data.lod>=Data.MEDIUM ) {
      shadow._xscale = menuFruit._xscale ;
      shadow._yscale = menuFruit._yscale ;
//    }
//    else {
//      shadow._xscale = 100 ;
//      shadow._yscale = 100 ;
//    }

    // Animations diverses
    for (var i=0;i<animList.length;i++) {
      var mc = animList[i] ;
      if ( !mc.kill )
        mc.nextFrame() ;
      else {
        mc.prevFrame() ;
        if ( mc._currentframe==1 ) {
          mc.removeMovieClip() ;
          animList.splice(i,1) ;
          i-- ;
        }
      }
    }


    // Animation des boutons
    for (var i=0;i<btList.length;i++) {
      var bt = btList[i] ;
      bt.move() ;
      // Destruction
      if ( bt.kill ) {
        bt.removeMovieClip() ;
        btList.splice(i,1) ;
        i-- ;
        if ( btList.length == 0 )
          onHidden() ;
      }
      else
        bt.update() ;
    }

  }


  /*------------------------------------------------------------------------
  ATTACHE UN BOUTON DE MENU
  ------------------------------------------------------------------------*/
  function attachButton(y, label, gotoPhase, help) {
    var bt : swapou2.RotatorButton = Std.cast( depthMan.attach("swapou2_menuButton",Data.DP_BUTTONS) ) ;
    bt.initRotatorButton( this, y,label, gotoPhase, help ) ;
    if ( lock ) bt.lock() ;
    btList.push(bt) ;
    return bt ;
  }


  /*------------------------------------------------------------------------
  ATTACHE UN BOUTON SPÉCIAL
  ------------------------------------------------------------------------*/
  function attachSwitch(y, label, func, help) {
    var bt : swapou2.RotatorButton = Std.cast( depthMan.attach("swapou2_menuButton",Data.DP_BUTTONS) ) ;
    bt.initRotatorButton(this, y,label, phase, help) ;
    bt.releaseCallback = func ;
    btList.push(bt) ;
  }


  /*------------------------------------------------------------------------
  ATTACHE UN BOUTON DE MENU
  ------------------------------------------------------------------------*/
  function attachFace(gridPos, faceId, gotoPhase, help ) {
    var bt : swapou2.RotatorFace = Std.cast( depthMan.attach("swapou2_faceButton",Data.DP_BUTTONS) ) ;
    bt.initRotatorFace( this, gridPos, faceId, gotoPhase, help ) ;
    if ( !Data.chars[faceId] ) bt.disable() ;
    if ( lock ) bt.lock() ;
    btList.push(bt) ;
  }


  /*------------------------------------------------------------------------
  AFFICHE TOUS LES VISAGES
  ------------------------------------------------------------------------*/
  function attachFaces(wantedPlayer, gotoPhase, title) {
    var bt ;
    this.wantedPlayer = wantedPlayer ;
    attachTitle(title);
  	if( gotoPhase == 51 ) { // HISTORY
  		attachFace(0,0,gotoPhase, Data.CHAR_NAMES[0]) ;
  		attachFace(2,1,gotoPhase, Data.CHAR_NAMES[1]) ;
  	} else {
  		attachFace(0,0,gotoPhase, Data.CHAR_NAMES[0]) ;
  		attachFace(1,1,gotoPhase, Data.CHAR_NAMES[1]) ;
  		attachFace(2,2,gotoPhase, Data.CHAR_NAMES[2]) ;
  		attachFace(3,3,gotoPhase, Data.CHAR_NAMES[3]) ;
  		attachFace(4,4,gotoPhase, Data.CHAR_NAMES[4]) ;
  		attachFace(5,5,gotoPhase, Data.CHAR_NAMES[5]) ;
  		attachFace(7,6,gotoPhase, Data.CHAR_NAMES[6]) ;
  	}
  }


  /*------------------------------------------------------------------------
  ATTACHE UN TITRE
  ------------------------------------------------------------------------*/
  function attachTitle(title) {
    var mc = Std.cast( depthMan.attach("titleBar", Data.DP_INTERFTOP) ) ;
    mc._x = Data.BUTTON_X ;
    mc._y = Data.TITLE_Y ;
    mc.sub.txtField.text = title ;
    mc.stop() ;
    mc.kill = false ;
    animList.push(mc) ;
  }


  /*------------------------------------------------------------------------
  ATTACHE L'ÉCRAN DE VERSUS
  ------------------------------------------------------------------------*/
  function attachVersus() {
    versus = Std.cast( depthMan.attach("versus", Data.DP_INTERF) ) ;
    versus._x = Data.DOCWIDTH/2 ;
    versus._y = Data.DOCHEIGHT/2 ;

    var pid1 = Data.players[0];
    var pid2 = Data.players[1];

	var p1bg,p2bg;
	var p1Frame,p2Frame;
	var p1Taunts,p2Taunts;
	if( wins_flag == undefined ) {
		versus.vs.gotoAndStop(1);
		p1Taunts = Data.TAUNT_QUESTION[pid1];
		p2Taunts = Data.TAUNT_ANSWER[pid2];
		p1Frame = Data.EMOTE_COLERE;
		p2Frame = Data.EMOTE_COLERE;
		p1bg = 0;
		p2bg = 1;
	} else if( wins_flag ) {
		p1Frame = Data.EMOTE_HAPPY;
		p2Frame = Data.EMOTE_DEAD;
		p1Taunts = Data.TAUNT_WINS[pid1];
		p2Taunts = Data.TAUNT_LOOSE[pid2];
		versus.vs.gotoAndStop(3);
		p1bg = 3;
		p2bg = 1;
	} else {
		p1Frame = Data.EMOTE_DEAD;
		p2Frame = Data.EMOTE_HAPPY;
		p1Taunts = Data.TAUNT_LOOSE[pid1];
		p2Taunts = Data.TAUNT_WINS[pid2];
		versus.vs.gotoAndStop(2);
		p1bg = 1;
		p2bg = 3;
	}

    versus.face1.fake._visible = false ;
    versus.face1.sub.gotoAndStop( string(pid1+1) ) ;
    versus.face1.sub.char.gotoAndStop(string(p1Frame)) ;
    versus.face1.sub.bg.gotoAndStop(string(p1bg+1)) ;
    versus.chat1.field.text = p1Taunts[random(p1Taunts.length)];
	versus.chat1.field._y = -8 - versus.chat1.field.textHeight / 2;

    versus.face2.fake._visible = false ;
    versus.face2.sub.gotoAndStop( string(pid2+1) ) ;
    versus.face2.sub.char.gotoAndStop(string(p2Frame)) ;
    versus.face2.sub.bg.gotoAndStop(string(p2bg+1)) ;
    versus.face2.sub.char._xscale = -versus.face2.sub.char._xscale ;
    versus.chat2.field.text = p2Taunts[random(p2Taunts.length)];
	versus.chat2.field._y = -8 - versus.chat2.field.textHeight / 2;
  }

  function showVersus(wins,f_onEnd) {
    wins_flag = wins;
	leftChar._visible = false;
	rightChar._visible = false;
	animPhase = 40;
	onEnd = f_onEnd;
  }

  /*------------------------------------------------------------------------
  MASQUE LES ÉLÉMENTS DE MENU
  ------------------------------------------------------------------------*/
  private function setVisible(flag) {
    bar._visible = flag ;
    shadow._visible = flag ;
    menuFruit._visible = flag ;
  }


  /*------------------------------------------------------------------------
  RETIRE TOUTES LES ANIMS
  ------------------------------------------------------------------------*/
  function removeAnims() {
    for (var i=0;i<animList.length;i++)
      animList[i].kill = true ;
  }


  /*------------------------------------------------------------------------
  EVENT: ACTIVATION D'UN BOUTON
  ------------------------------------------------------------------------*/
  function jump(gotoPhase) {
    for (var i=0;i<btList.length;i++)
      btList[i].hide() ;

    if ( gotoPhase >= 0 ) {
      if ( phase != gotoPhase && stack[stack.length-1] != phase )
        stack.push(phase) ;
      phase = gotoPhase ;
    }
    else {

		if( gotoPhase == -2 )
			Manager.client.savePrefs();

      phase = stack[stack.length-1] ;
      stack.splice( stack.length-1, 1 ) ;
    }

    removeAnims() ;
    hideHelp() ;


    switch (phase) { // code pour l'arrivée dans une phase
    case 0:
    case -1:
      break ;

      // ** MENU PRINCIPAL
    case 10 :
      attachButton(0, " jouer ", 20, "Choisir un mode de jeu") ;
      attachButton(1, " options ", 11, "Paramètres de jeu") ;
      break ;

      // ** OPTIONS
    case 11 :
      attachTitle("Paramètres de jeu") ;
      var label ;
      if ( Sounds.soundEnabled() ) label = " oui " ;
      else              label = " non " ;
      attachSwitch(0, "son : "+label, onSound, "Activer ou désactiver les effets sonore" ) ;

      if ( Sounds.musicEnabled() ) label = " oui " ;
      else              label = " non " ;
      attachSwitch(1, "musique : "+label, onMusic, "Activer ou désactiver la musique" ) ;

      if ( Data.lod == Data.HIGH )   label = " hauts " ;
      if ( Data.lod == Data.MEDIUM ) label = " moyens " ;
      if ( Data.lod == Data.LOW )    label = " bas " ;
      attachSwitch(2, "details : "+label, onDetails, "Régler le niveau de qualité graphique du jeu") ;

      attachButton(3, " retour ",-2,"") ;
      break ;

      // ** MODES DE JEU
    case 20 :
      var bt ;
      attachTitle(" Modes ");

  	  if( Manager.client.isWhite() )
  		bt = attachButton(0, " entrainement ",30, "Entrainez vous et battez votre record perso") ;
  	  else
  		bt = attachButton(0, " challenge ",30, "Affrontez les autres Frutiz sur le classement") ;

      bt = attachButton(1, " duel ", 40, "Match amical en Un contre Un") ;
      if ( !Manager.client.isWhite() ) bt.disable() ;

      bt = attachButton(2, "pot au feu", 50, "Progressez et accédez à de nouveaux personnages") ;
      if ( !Manager.client.isWhite() ) bt.disable() ;

      bt = attachButton(3, " classique ", 60, "La version classique de swapou") ;
      if ( !Manager.client.isWhite() || !Std.cast(Manager.client.slots[0]).$items[6] ) bt.disable() ;

      attachButton(4, " retour ", -1,"") ;
      break ;

      // ** CHALLENGE
    case 30 :
      attachFaces(0, phase+1, " Personnage ") ;
      attachButton(4, " retour ",-1,"") ;
      break ;


      // ** DUEL
    case 40 :
      attachFaces(0, phase+1, " Personnage ") ;
      attachButton(4, " retour ",-1,"") ;
      break ;
    case 41 :
      attachFaces(1, phase+1, " Adversaire ") ;
      attachButton(4, " retour ",-1,"") ;
      break ;
    case 42 :
      var line=0;
      attachTitle("Difficulté");
      attachButton(line++, " enfantin ", phase+1, "") ;
      attachButton(line++, " facile ", phase+1, "") ;
      attachButton(line++, " moyen ", phase+1, "") ;
      attachButton(line++, " difficile ", phase+1, "") ;
      attachButton(line++, " sauvage ", phase+1, "") ;
      attachButton(line++, " retour ",-1,"") ;
      break ;

	  // ** HISTORY
	case 50 :
	    attachFaces(0, phase+1," Personnage ");
      attachButton(4, " retour ",-1,"") ;
      break ;

    }
  }


  /*------------------------------------------------------------------------
  EVENT: CLIC SUR UNE FACE
  ------------------------------------------------------------------------*/
  function onFaceSelect( gotoPhase, faceId ) {
    Data.players[wantedPlayer] = faceId ;
    jump(gotoPhase) ;
  }


  /*------------------------------------------------------------------------
  EVENT: CLIC SUR UNE FACE
  ------------------------------------------------------------------------*/
  function onButtonSelect( gotoPhase, id ) {
    selectedButton = id ;
    jump(gotoPhase) ;
  }


  /*------------------------------------------------------------------------
  EVENT: TOUS LES BOUTONS ONT ÉTÉ MASQUÉS
  ------------------------------------------------------------------------*/
  function onHidden() {
    switch (phase) { // code pour l'arrivée dans une phase
    case 31 : // Mode challenge
      end( Data.CHALLENGE ) ;
      break ;
    case 41 : // DUEL: player 0 choisi
      break ;
    case 42 : // DUEL: player 1 choisi
      break ;
    case 43 : // DUEL: difficulté choisie
      Data.difficulty = selectedButton ;
      end( Data.DUEL ) ;
      break ;
  	case 51 : // Mode history
  	  end( Data.HISTORY );
  	  break;
  	case 60 : // Mode classic
  	  end( Data.CLASSIC );
  	  break;
    }
  }



  /*------------------------------------------------------------------------
  EVENT: SON
  ------------------------------------------------------------------------*/
  function onSound() {
    Sounds.toggleSound();
  }

  /*------------------------------------------------------------------------
  EVENT: MUSIQUE
  ------------------------------------------------------------------------*/
  function onMusic() {
    Sounds.toggleMusic();
  }

  /*------------------------------------------------------------------------
  EVENT: DÉTAILS
  ------------------------------------------------------------------------*/
  function onDetails() {
    switch( Data.lod ) {
    case Data.HIGH   : Data.lod = Data.MEDIUM ; break ;
    case Data.MEDIUM : Data.lod = Data.LOW ; break ;
    case Data.LOW    : Data.lod = Data.HIGH ; break ;
    }
  }

  /*------------------------------------------------------------------------
  FIN DU MENU
  ------------------------------------------------------------------------*/
  function end( mode ) {
    Data.gameMode = mode ;
    animPhase = 30 ;
    menuFruit.fromX = menuFruit.x ;
    menuFruit.ds = 0 ;
    onEnd = undefined ;

    switch(mode) {
    case Data.CHALLENGE :
      onEnd = Manager.startChallenge ;
      break ;
    case Data.DUEL :
      onEnd = Manager.startDuel ;
      break ;
	case Data.HISTORY :
	  onEnd = Manager.startHistoryMap;
	  break;
	case Data.CLASSIC :
	  onEnd = Manager.startClassic;
	  break;
    }
  }



  /*------------------------------------------------------------------------
  AFFICHE UNE AIDE CONTEXTUELLE
  ------------------------------------------------------------------------*/
  function help(msg) {
    bar.txtField.text = msg ;
    bar._visible = true ;
  }

  /*------------------------------------------------------------------------
  MASQUE L'AIDE
  ------------------------------------------------------------------------*/
  function hideHelp() {
    bar.txtField.text = "" ;
    bar._visible = false ;
  }

  /*------------------------------------------------------------------------
  EVENT: CLIC SUR LE FOND
  ------------------------------------------------------------------------*/
  function release() {
    this.clicked = true ;
    gameButton.disable() ;
  }

  /*------------------------------------------------------------------------
  ACTIVE L'ATTENTE D'UN EVENT CLIC
  ------------------------------------------------------------------------*/
  function waitClick() {
    clicked = false ;
    gameButton.enable() ;
  }

/*------------------------------------------------------------------------
    ACTIVE LE VERROU D'ATTENTE SERVEUR
 ------------------------------------------------------------------------*/
  function netLock() {
    for (var i=0;i<btList.length;i++)
      btList[i].lock() ;
    lock = true ;
    netBox = depthMan.attach("box", Data.DP_INTERFTOP) ;
    netBox._x = Data.DOCWIDTH/2 ;
    netBox._y = Data.DOCHEIGHT/2 ;
    netBox.gotoAndStop("2") ;
    if ( animPhase==0 )
      netBox._visible = false ;
  }

/*------------------------------------------------------------------------
    DÉSACTIVE LE VERROU D'ATTENTE SERVEUR
 ------------------------------------------------------------------------*/
  function netUnlock() {
    for (var i=0;i<btList.length;i++)
      btList[i].unlock() ;
    lock = false ;
    netBox.removeMovieClip() ;
	Sounds.playMusic(Sounds.MUSIC_MENU);
  }

  /*------------------------------------------------------------------------
  DESTRUCTION
  ------------------------------------------------------------------------*/
  function destroy() {
    depthMan.destroy() ;
    //    for (var i=0;i<btList.length;i++)
    //      btList[i].removeMovieClip() ;
    //
    //    btList = new Array() ;
    //
    //    bg.removeMovieClip() ;
    //    menuFruit.removeMovieClip() ;
    //    leftChar.removeMovieClip() ;
    //    rightChar.removeMovieClip() ;
    //    bar.removeMovieClip() ;
  }

}
