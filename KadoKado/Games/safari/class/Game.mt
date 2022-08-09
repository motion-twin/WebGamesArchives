class Game {//}
  var manager : Manager ;

  var depthMan: DepthManager ;
  var scroller : Scroller ;
  var entityList : PArray<Entity> ;
  var spawnList : PArray<int> ;

  var bulletPool : MovieClip ;
  var cross : MovieClip ;
  var popUp : MovieClip ;

  var car : Car ;

  volatile var ammo : float ;
  var coolDown : float ;

  var misses : int ;
  var targets : int ;
  volatile var ttargets : int ; // CHECK CHEAT
  volatile var tmisses : int ;	// CHECK CHEAT
  volatile var maxTargets : int ;
  volatile var multi : int ;
  volatile var multiTimer : float ;
  volatile var combo : int ;
  volatile var comboPool : int ;
  volatile var kills : int ;
  volatile var shots : int ;
  volatile var goodShots : int ;
  volatile var badShots : int ;
  volatile var retroShots : int ;
  volatile var lastBonus : float ;
  volatile var level : float ;
  var lastSpawnTimer : float ;
  var startTimer : float ;

  var optionList : PArray<float> ;



  var fl_shoot : bool ;
  var fl_gameRunning : bool ;
  var fl_gameOver : bool ;
  var fl_fast : bool ;
  var endTimer : float ;

  volatile var gameTimer : float ;

  var debriefing : String ;


/*------------------------------------------------------------------------
    CONSTRUCTEUR
 ------------------------------------------------------------------------*/
  function new(m) {
    manager = m ;
    depthMan = new DepthManager(manager.root) ;

    gameTimer = 0 ;

    scroller = new Scroller(this) ;
    entityList = new PArray() ;
    fl_shoot = false ;
    fl_gameRunning = false ;
    fl_gameOver = false ;
    fl_fast = false ;

    cross = depthMan.attach("cross", Data.DP_INTERF) ;
    cross._visible = false ;

    bulletPool = depthMan.attach("bulletPool", Data.DP_INTERF) ;
    bulletPool._x = Data.AMMO_X ;
    bulletPool._y = Data.AMMO_Y ;


    attachPopUp(" Attaque imminente ", "Préparez-vous pour l'assaut !") ;
    startTimer = 65 ;
    var me = this ;
    manager.root.useHandCursor = true ;
    manager.root.onRelease = fun() {
      me.startGame() ;
    }

    car = new Car(this) ;

    ammo = Data.AMMO ;
    coolDown = 0 ;

    targets = 0 ;
    ttargets = 0 ;
    maxTargets = 0 ;
    KKApi.setScore(KKApi.const(0)) ;
    misses = 0 ;
    tmisses = 0 ;
    multi = 1 ;
    multiTimer = 0 ;
    combo = 0 ;
    comboPool = 0 ;
    kills = 0 ;
    shots = 0 ;
    goodShots = 0 ;
    retroShots = 0;
    badShots = 0;
    level = 0.0 ;
    lastSpawnTimer = 0 ;

    manager.root.onMouseDown = fun() {
      me.mouseDown() ;
    }
    manager.root.onMouseUp = fun() {
      me.mouseUp() ;
    }

    interfaceUpdate() ;
    initSpawner() ;
  }



// *** DIVERS


/*------------------------------------------------------------------------
    DÉMARRAGE DU JEU
 ------------------------------------------------------------------------*/
  function startGame() {
    startTimer = 0 ;
    clearRelease() ;
    Mouse.hide() ;
    downcast(manager.root)._quality = "medium" ;
    car.enterGame() ;
    popUp.removeMovieClip() ;
    fl_gameRunning = true ;
  }


/*------------------------------------------------------------------------
    FIN DU JEU
 ------------------------------------------------------------------------*/
  function endGame() {
    if ( fl_gameOver )
      return ;

    var p = {
	$r: retroShots,
	$g: goodShots,
	$b: badShots
    };
    KKApi.gameOver(p) ;

//    debriefing =
//        "Cibles détruites: "+kills+"\n"+
//        "Balles tirées: "+shots+" "+
//        "(précision: "+Math.round(100*goodShots/Math.max(1,shots))+"%)\n"
//
//    attachPopUp(
//        "Fin de mission",
//        debriefing
//    ) ;
//
//    var me = this ;
//    manager.root.useHandCursor = true ;
//    manager.root.onRelease = fun() {
//      me.saveScore() ;
//    }

    Mouse.show() ;
    cross._visible = false ;
    car.stopShoot() ;
    car.stableBodyY *= 0.7 ;
    fl_gameRunning = false ;
    fl_gameOver = true ;

    for (var i=0;i<entityList.length;i++)  {
      var e = entityList[i] ;
      if ( e.fl_useless )
        e.destroy() ;
      else
        downcast(e).mover.dx += scroller.speed*0.5 ;
    }
  }


/*------------------------------------------------------------------------
    SERVEUR: ENVOI DE SCORE
 ------------------------------------------------------------------------*/
  function saveScore() {
    clearRelease() ;
    attachPopUp(" Veuillez patienter... ", debriefing) ;
    downcast(popUp).sub.click._visible = false ;
    manager.root.onRelease = fun() {} ;
    var p = {
	$r: retroShots,
	$g: goodShots,
	$b: badShots
    };
    KKApi.saveScore(p) ;
  }


/*------------------------------------------------------------------------
    ATTACH: POP-UP DE TEXTE
 ------------------------------------------------------------------------*/
  function attachPopUp(title, txt) {
    popUp.removeMovieClip() ;
    popUp = depthMan.attach("popUp",Data.DP_INTERF) ;
    popUp._x = 150 ;
    popUp._y = 90 ;
    var me = this ;
    downcast(popUp).sub.title.text = title ;
    downcast(popUp).sub.txt.text = txt ;
  }


/*------------------------------------------------------------------------
    DÉFINI UN FILTRE DE COULEUR SUR LE MC
 ------------------------------------------------------------------------*/
  function setColor( mc:MovieClip, rPct,rAlpha, gPct,gAlpha, bPct,bAlpha ) {
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
    RANDOM TMODDÉ
 ------------------------------------------------------------------------*/
  function randomT(n) {
    return Std.random( Math.round(n*1/Timer.tmod) ) ;
  }


/*------------------------------------------------------------------------
    GESTION DES CIBLES
 ------------------------------------------------------------------------*/
  function spawner() {
    // Spawn de rabbit-options
    while ( optionList.length>0 && level>=optionList[0] ) {
      entity.target.Option.attach(this, -20,Std.random(170)+50) ;
      optionList.splice(0,1) ;
    }

    if ( lastSpawnTimer>0 ) {
      lastSpawnTimer-=Timer.tmod ;
      if ( lastSpawnTimer<0 )
        lastSpawnTimer=0;
      return ;
    }

    // Evolution du maxTargets
    maxTargets = Data.MIN_TARGETS + Math.floor(level) ;

    // Calcul de la chance d'apparition
    var chance = Data.PROBA_SPAWN*Timer.tmod * level*0.5 ;
    chance += Math.pow(maxTargets-targets, 2)*5 ;
    if ( targets==0 )
      chance *= 1000 ;

    if ( targets<maxTargets && Std.random(1000)<=chance ) {
      lastSpawnTimer = Math.max(0,8-level*2) + Std.random( int(Math.max(0,20-level*2)) ) ;
      if ( Std.random(1000)<=Data.PROBA_BIG*Timer.tmod ) {
        // Gros
        entity.target.Big.attach(this, -40, Std.random(120)+30) ;
      }
      else {
        // Spawn d'un monstre de base au hasard
        var n = Math.min( spawnList.length-1, Std.random(spawnList.length)+level*10 )
        var id = spawnList[Math.round(n)] ;
        switch (id) {
            case Data.DRONE :
                entity.target.Drone.attach(this, -20, Std.random(170)+50) ;
                break ;
            case Data.WARPER :
                if ( level<=1.5 )
                  break ;
                entity.target.Warper.attach(this, -20, Std.random(170)+50) ;
                break ;
            default:
                Log.trace("spawn error !!! "+id+" at "+n) ;
        }
      }

    }
  }


/*------------------------------------------------------------------------
    TUE TOUS LES BADS EN JEU
 ------------------------------------------------------------------------*/
  function destroyAll() {
    for (var i=0;i<entityList.length;i++) {
      var e = entityList[i] ;
      if ( downcast(e).bonus!=null ) {
        var fx = entity.fx.Instant.attach(this, e.x+15,e.y, Data.EXPLOSION) ;
        e.destroy() ;
      }
    }
  }


/*------------------------------------------------------------------------
    INITIALISATION DES RÉPARTITIONS ALÉATOIRES
 ------------------------------------------------------------------------*/
  function initSpawner() {
    spawnList = new PArray() ;

    for (var i=0;i<Data.PROBA_DRONE;i++)
      spawnList.push(Data.DRONE) ;
    for (var i=0;i<Data.PROBA_WARPER;i++)
      spawnList.push(Data.WARPER) ;

    optionList = new PArray() ;
    var l = 0 ;
    var total = 5 + Std.random(3) ;
    for (var i=0;i<total;i++) {
      l += Std.random(25)/10 ;
      optionList.push( l ) ;
    }
  }



// *** EVENTS

/*------------------------------------------------------------------------
    EFFACE L'EVENT ONRELEASE
 ------------------------------------------------------------------------*/
  function clearRelease() {
    manager.root.onRelease = null ;
    manager.root.useHandCursor = false ;
  }


/*------------------------------------------------------------------------
    EVENT: CLIC DE SOURIS
 ------------------------------------------------------------------------*/
  function mouseDown() {
    if ( !fl_gameRunning || fl_gameOver )
      return ;
    fl_shoot = true ;
    shoot() ;
  }
  function mouseUp() {
    fl_shoot = false ;
  }


/*------------------------------------------------------------------------
    event: clic sur la bannière
 ------------------------------------------------------------------------*/
  function release() {
    Log.trace("popRelease ") ;
    if ( fl_gameOver && endTimer<=0 )
      saveScore() ;
    if ( !fl_gameRunning && !fl_gameOver )
      startGame() ;
  }



// *** ARMEMENT

/*------------------------------------------------------------------------
    TIR
 ------------------------------------------------------------------------*/
  function shoot() {
    var x = cross._x ;
    var y = cross._y ;

    if ( ammo<1 ) {
      car.stopShoot() ;
      return ;
    }

    car.shoot() ;

    if ( coolDown>0 )
      return;

    ammo-- ;
    shots++ ;
    coolDown = Data.HEAT ;

    // Cartouche
    var fx = entity.fx.Cartridge.attach( this, car.x+Data.CANON_X, car.y+Data.CANON_Y ) ;

    // Cibleur
//    cross._x += (Std.random(2)*2-1) * Std.random(50)/10 ;
//    cross._y += (Std.random(2)*2-1) * Std.random(50)/10 ;
    downcast(cross).center._rotation -= 30 ;
    downcast(cross).center._xscale = 130+Std.random(100) ;
    downcast(cross).center._yscale = downcast(cross).center._xscale ;
    var light = Std.random(100)+100 ;
    setColor( downcast(cross).sub, 100,light, 100,light, 100,light ) ;

    // Parcours des cibles
    var found = false ;
    for (var i=entityList.length-1;i>=0;i--) {
      var e=entityList[i] ;
      if ( e.fl_count && !e.fl_kill &&
           x>=e.x-e.radius && x<=e.x+e.radius &&
           y>=e.y-e.radius && y<=e.y+e.radius ) {
        var dist = Math.sqrt( Math.pow(x-e.x,2) + Math.pow(y-e.y,2) ) ;
        if ( dist <= e.radius ) {
          downcast(e).hit(1) ;
          found = true ;
          break;
        }
      }
    }

    if ( found ){
      goodShots++ ;
      return;
    }

    var carRetro = { x:car.body._x+17, y:car.body._y-26 };
    var distRetro = Math.sqrt( Math.pow(x-carRetro.x,2) + Math.pow(y-carRetro.x,2) );
    if (distRetro < 10){
      // car.retro._alpha = 0;
      // Log.trace("bing!");
      retroShots++;
    }
    else {
      badShots++;
    }

  }



/*------------------------------------------------------------------------
    RECHARGEMENT
 ------------------------------------------------------------------------*/
  function reload() {
    if ( ammo<Data.AMMO ) {
      ammo += Data.RELOAD*Timer.tmod ;
      if ( ammo>Data.AMMO )
        ammo = Data.AMMO ;
    }
  }


/*------------------------------------------------------------------------
    MAIN: REFROIDISSEMENT CANON ET MULTI
 ------------------------------------------------------------------------*/
  function interfaceUpdate() {
    var width = bulletPool._width/20 ;
    downcast(bulletPool).mask._width = width * Math.floor(ammo) ;
    downcast(bulletPool).multiField.text = " x"+multi ;
  }


/*------------------------------------------------------------------------
    MAIN: CIBLEUR
 ------------------------------------------------------------------------*/
  function manageCross() {
    var x = manager.root._xmouse ;
    var y = manager.root._ymouse ;
    if ( x!=0 && y!=0 )
      cross._visible = true ;
    setColor( downcast(cross).sub, 100,0, 100,0, 100,0 ) ;
    cross._x = x ;
    cross._y = y ;
    downcast(cross).center._rotation += 15 ;

    var s = downcast(cross).center._xscale ;
    s += (100-s)*0.1 ;
    downcast(cross).center._xscale = s ;
    downcast(cross).center._yscale = s ;
  }


// *** SCORES

/*------------------------------------------------------------------------
    GAIN DE POINTS
 ------------------------------------------------------------------------*/
  function getBonus(n:KKConst,label:String, x,y) {
    n = KKApi.cmult(n,KKApi.const(multi));

    if (label==null)
      label = ""+KKApi.val(n) ;

    var mc = depthMan.attach("bonus",Data.DP_INTERF) ;
    mc._x = x ;
    mc._y = y ;
    downcast(mc).sub.field.text = label ;

    lastBonus = gameTimer ;
    combo++ ;
    comboPool+=KKApi.val(n);
    KKApi.addScore(n) ;
  }


/*------------------------------------------------------------------------
    GESTION DES COMBOS
 ------------------------------------------------------------------------*/
  function manageCombos() {
    if ( gameTimer-lastBonus>Data.COMBO_TIMER ) {
      if (combo>1) {
        getBonus( KKApi.cmult(KKApi.const(combo),Data.C25), combo+" hits", car.x+Data.CAR_WIDTH/2, car.y-70 ) ;
      }
      combo = 0 ;
      comboPool = 0 ;
    }
  }


/*------------------------------------------------------------------------
    AJOUTE UN MISS
 ------------------------------------------------------------------------*/
  function miss(id:int) {
    if ( fl_gameOver )
      return ;
    var mc = depthMan.attach("miss",Data.DP_INTERF) ;
    mc._x = 285-misses*30 ;
    mc._y = 15 ;
    mc.gotoAndStop( (id+1)+"" ) ;
    misses++ ;
    tmisses++ ;
    destroyAll() ;
    if ( misses >= Data.MAX_MISSES )
      endGame() ;
  }



// *** MAIN


/*------------------------------------------------------------------------
    MAIN DE GAME OVER
 ------------------------------------------------------------------------*/
  function updateEnd() {
    scroller.speed = Math.max(4, scroller.speed*0.95) ;
    endTimer-=Timer.tmod;

    if ( car.x >= 100 )
      car.dx -= 0.5*Timer.tmod ;
  }

/*------------------------------------------------------------------------
    MAIN
 ------------------------------------------------------------------------*/
  function update() {



    gameTimer+=Timer.tmod ;

    // Debug
    if ( KKApi.isLocal() ) {
      Log.print("FPS: "+Math.round(32*1/Timer.tmod)) ;
      Log.print("level: "+Math.round(level*100)/100) ;
      Log.print(optionList.join(" | ")) ;

      if ( Key.isDown(Key.CONTROL) ) return;
      if ( Key.isDown(Key.SPACE) )
        entity.target.Option.attach(this, -10, Std.random(50)+100) ;
      if ( Key.isDown(109) ) scroller.hideGround();
      if ( Key.isDown(107) ) scroller.showGround();
    }

    // if ( Key.isDown(Key.ESCAPE) )
    //  endGame() ;

    // CHECK CHEAT
    if(ttargets!=targets || tmisses!=misses || entityList.getCheat() || spawnList.getCheat() ||  optionList.getCheat() ) KKApi.flagCheater();



    // HACK

    // Scolling
    scroller.update() ;
    if ( startTimer>0 ) {
      startTimer-=Timer.tmod ;
      if ( startTimer<=0 )
        startGame() ;
    }

    if ( fl_gameOver )
      updateEnd() ;

    if ( fl_gameRunning ) {
      if ( multiTimer>0 ) {
        multiTimer-=Timer.tmod;
        if ( multiTimer<=0 ) {
          multiTimer=0 ;
          multi=1 ;
        }
      }
      level += Data.LEVELING_SPEED * Timer.tmod;

      scroller.updateSpeed() ;

      // Cible
      manageCross() ;

      // Divers
      manageCombos() ;

      // Tir
      if ( fl_shoot )
        shoot() ;
      else {
        car.stopShoot() ;
        reload() ;
      }
      if ( coolDown>0 )
        coolDown-=Timer.tmod;
      interfaceUpdate() ;

      spawner() ;
    }

    // Updates d'entités
    for (var i=0;i<entityList.length;i++) {
      entityList[i].update() ;
      entityList[i].endUpdate() ;
      if ( entityList[i].x == null ) {
        entityList.splice(i,1) ;
        i-- ;
      }
    }

    car.update() ;
  }

 //{
 }

