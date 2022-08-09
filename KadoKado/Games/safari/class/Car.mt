class Car {
  var game : Game ;

  var x : float ;
  var y : float ;

  var width : float ;

  var dx : float ;
  var dy : float ;

  var left : MovieClip ;
  var right : MovieClip ;
  var body : MovieClip ;
  var shadow : MovieClip ;
  var draw : MovieClip ;

  var elastX : float ;
  var elastY : float ;

  var stableBodyY : float ;

  var fl_stable : bool ;
  var fl_inGame : bool ;
  var fl_shoot : bool ;

  // var retro : MovieClip; // fight against the evil bot

/*------------------------------------------------------------------------
    CONSTRUCTEUR
 ------------------------------------------------------------------------*/
  function new(g) {
    game = g ;
    x = -100 //Data.CAR_X ;
    y = Data.GROUND_Y ;

    dx = 0 ;
    dy = 0 ;
    width = Data.CAR_WIDTH ;
    fl_stable = true ;
    fl_inGame = false ;

    elastX = 0 ;
    elastY = 0 ;
    stableBodyY = Data.BODY_Y ;

    // Corps
    body = g.depthMan.attach("carBody",Data.DP_CAR_BODY) ;
    body._x = x+width/2 ;
    body._y = Data.GROUND_Y-stableBodyY ;

    /*
    retro = Std.createEmptyMC(body, body.getNextHighestDepth());
    retro.beginFill(0xFF0000, 100);
    retro.moveTo(-5,-5);
    retro.lineTo( 5,-5);
    retro.lineTo( 5, 5);
    retro.lineTo(-5, 5);
    retro.lineTo(-5,-5);
    retro.endFill();
    retro._alpha = 50;
    retro._x = 17;
    retro._y = -26;
    */

    downcast(body).gat.stop() ;
    downcast(body).gat.canon._rotation = -75 ;

    // Roues
    left = g.depthMan.attach("wheel",Data.DP_CAR_WHEEL) ;
    right = g.depthMan.attach("wheel",Data.DP_CAR_WHEEL) ;
    downcast(left).sub._rotation = Std.random(360) ;
    downcast(right).sub._rotation = Std.random(360) ;
    left._xscale = Data.WHEEL_SCALE ;
    left._yscale = left._xscale ;
    right._xscale = Data.WHEEL_SCALE ;
    right._yscale = right._xscale ;

    // Ombre
    shadow = game.depthMan.attach("shadow", Data.DP_SHADOW) ;

    draw = game.depthMan.empty(Data.DP_CAR_DRAW) ;
    endUpdate() ;
  }


/*------------------------------------------------------------------------
    ARRIVÉE EN JEU !
 ------------------------------------------------------------------------*/
  function enterGame() {
    // Saut
    x = -70 ;
    jump(9,-25) ;

    // Débris
    for (var i=0;i<15;i++) {
      var fx = entity.fx.Gib.attach(game,Data.GIB_DRONE,null, -Std.random(50),Std.random(50)+150) ;
      fx.mover.dx = Math.abs(dx)* (0.5+Std.random(100)/100) ;
    }
    for (var i=0;i<7;i++) {
      var fx = entity.fx.Gib.attach(game,Data.GIB_MISC,null, -Std.random(50),Std.random(50)+150) ;
      fx.mover.dx = Math.abs(dx)*(0.3+Std.random(50)/100) ;
    }

    fl_inGame = true ;
  }


/*------------------------------------------------------------------------
    SAUT
 ------------------------------------------------------------------------*/
  function jump(dx,dy) {
    if ( !fl_stable || game.fl_gameOver )
      return ;

    this.dx = dx ;
    this.dy = dy ;
    fl_stable = false ;
  }


/*------------------------------------------------------------------------
    ATTERRISSAGE
 ------------------------------------------------------------------------*/
  function land() {
    fl_stable = true ;
    dy = 0 ;
    y = Data.GROUND_Y ;
  }


/*------------------------------------------------------------------------
    ANIM DE TIR
 ------------------------------------------------------------------------*/
  function shoot() {
    fl_shoot = true ;
  }
  function stopShoot() {
    fl_shoot = false ;
  }


/*------------------------------------------------------------------------
    ROTATION D'UN PT AUTOUR D'UN AUTRE
 ------------------------------------------------------------------------*/
  function rotatePoint(x:float,y:float, parentX:float,parentY:float, ang:float) {
    var pt = {x:x,y:y} ;

    var ptRad = { dist:Math.sqrt(Math.pow(pt.x,2)+Math.pow(pt.y,2)), ang:Math.atan2(pt.y,pt.x) } ;
    ptRad.ang += (ang) * Math.PI/180 ;
    pt = { x:parentX+Math.cos(ptRad.ang)*ptRad.dist, y:parentY+Math.sin(ptRad.ang)*ptRad.dist } ;

    return pt ;
  }


/*------------------------------------------------------------------------
    TRACÉ DES FIXATIONS
 ------------------------------------------------------------------------*/
  function redraw() {
    var pt:{x:float,y:float} ;
    draw.clear() ;
    draw.lineStyle(2, 0x4E5B7C, 100) ;
    draw.lineStyle(2, 0x0, 100) ;

    // Gauche
    pt = rotatePoint(
        downcast(body).l._x, downcast(body).l._y,
        body._x,body._y,
        body._rotation
    ) ;
    draw.moveTo( pt.x, pt.y ) ;
    draw.lineTo( left._x, left._y-left._height/2 ) ;

    // Droite
    pt = rotatePoint(
        downcast(body).r._x, downcast(body).r._y,
        body._x,body._y,
        body._rotation
    ) ;
    draw.moveTo( pt.x, pt.y ) ;
    draw.lineTo( right._x, right._y-right._height/2 ) ;


    // Centrales
    pt = rotatePoint(
        downcast(body).m._x, downcast(body).m._y,
        body._x,body._y,
        body._rotation
    ) ;
    draw.moveTo( pt.x, pt.y ) ;
    draw.lineTo( left._x, left._y-left._height/2 ) ;
    draw.moveTo( pt.x, pt.y ) ;
    draw.lineTo( right._x, right._y-right._height/2 ) ;
  }


/*------------------------------------------------------------------------
    UPDATE GRAPHIQUE
 ------------------------------------------------------------------------*/
  function endUpdate() {
    var speed = game.scroller.speed ;

    // Placement des parties
    left._x = x ;
    right._x = x+width ;
    if ( fl_stable ) {
      left._y = y-Std.random( Math.round(Math.min(8,speed*0.5)) ) ;
      right._y = y-Std.random( Math.round(Math.min(8,speed*0.5)) ) ;
    }
    else {
      left._y = y ;
      right._y = y ;
    }

    // Elasticité
    elastX = ( left._x-speed*0.3-body._x+width/2+5 ) * 0.2 + 0.8 * elastX ;
    elastY = ( left._y-body._y ) * 0.35 + 0.65 * elastY ;
    body._x += elastX ;
    body._y += elastY - stableBodyY ;
    body._y = Math.min(Data.GROUND_Y-stableBodyY*0.8, body._y) ;
    body._rotation = (left._x-speed-body._x+width/2)*0.5 ;

    // Rotations roues
    var wheelSpeed = game.scroller.speed*2.3*Timer.tmod ;
    if ( wheelSpeed>=30 ) {
      downcast(left).sub.gotoAndStop("2");
      downcast(right).sub.gotoAndStop("2");
    }
    else {
      downcast(left).sub.gotoAndStop("1");
      downcast(right).sub.gotoAndStop("1");
    }

    downcast(left).sub._rotation += wheelSpeed;
    downcast(right).sub._rotation += wheelSpeed;

    // Canon
    if ( game.fl_gameRunning ) {
      var tx = game.cross._x ;
      var ty = game.cross._y ;
      var ang = Math.atan2( Data.CANON_Y+y-ty, Data.CANON_X+x-tx ) ;
      if ( ang>0 ) {
        downcast(body).gat.canon._rotation = ang*180/Math.PI-90 ;
        downcast(body).gat.gotoAndStop(
            Math.round(Math.min(1,ang/Math.PI) * downcast(body).gat._totalframes) + ""
        ) ;
      }
    }

    // Ombre
    shadow._x = body._x ;
    shadow._y = Data.GROUND_Y-5 ;
    shadow._height = 7 ;
    shadow._width = Data.CAR_WIDTH*1.5 ;

    redraw() ;
  }


/*------------------------------------------------------------------------
    MAIN
 ------------------------------------------------------------------------*/
  function update() {

    if ( fl_shoot ) {
      downcast(body).gat.canon.gotoAndStop("2") ;
      downcast(body).gat.s1.gotoAndStop("2") ;
      downcast(body).gat.s2.gotoAndStop("2") ;
      downcast(body).gat.s3.gotoAndStop("2") ;
      downcast(body).gat.s4.gotoAndStop("2") ;
    }
    else {
      downcast(body).gat.canon.gotoAndStop("1") ;
      downcast(body).gat.s1.gotoAndStop("1") ;
      downcast(body).gat.s2.gotoAndStop("1") ;
      downcast(body).gat.s3.gotoAndStop("1") ;
      downcast(body).gat.s4.gotoAndStop("1") ;
    }

    if ( fl_inGame ) {
      if ( !fl_stable ) {
        // Gravité
        dy+=Data.GRAVITY*Timer.tmod ;
      }
      else {
        // Recentrage
        if ( !game.fl_gameOver ) {
          if ( x>Data.CAR_X )
            dx-=1.5*Timer.tmod ;
          if ( x<Data.CAR_X )
            dx+=1.5*Timer.tmod ;
          if ( Math.abs(dx)<=0.7 && Math.abs(x-Data.CAR_X)<=4 ) {
            x = Data.CAR_X ;
            dx = 0 ;
          }
        }
      }

      // Frictions
      if ( fl_stable ) {
        if ( Math.abs(x-Data.CAR_X)<=30  )
          dx *= Math.pow(0.85,Timer.tmod) ;
        else
          dx *= Math.pow(0.6,Timer.tmod) ;
      }


      x+=dx*Timer.tmod ;
      y+=dy*Timer.tmod ;

      if ( !fl_stable && y>=Data.GROUND_Y )
        land() ;
    }

    endUpdate() ;
  }
}
