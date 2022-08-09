class mover.Death extends Mover {

  var fl_fly : bool ;

/*------------------------------------------------------------------------
    CONSTRUCTEUR
 ------------------------------------------------------------------------*/
  function new(e) {
    super(e) ;
    dx += 5 ;
    fl_fly = true ;
    var fx = entity.fx.Instant.attach(e.game, e.x+15,e.y, Data.EXPLOSION) ;
    fx.randomizeRotation() ;
    fx._xscale = 70 ;
    fx._yscale = fx._xscale ;
  }


/*------------------------------------------------------------------------
    EVENT: SOL
 ------------------------------------------------------------------------*/
  function onHitGround() {
    dy=-Math.abs(dy*0.9) ;
    e.y = Data.GROUND_Y-e._height/2 ;

    // Destruction immédiate pour le gameover
    if ( e.game.fl_gameOver ) {
      var fx = entity.fx.Instant.attach(e.game, e.x,e.y, Data.EXPLOSION) ;
      fx.randomizeRotation() ;
      fx._xscale = 60 ;
      fx._yscale = fx._xscale ;
      e.destroy() ;
    }

    if ( fl_fly ) {
      // Crash
      fl_fly = false ;
      dx -= e.game.scroller.speed*Data.GROUND_SPEED;
      dy = -Std.random(10)-2 ;
      var s = Math.round(e.game.scroller.speed) ;
      dr = -(Std.random(s)+s*1.5)*Timer.tmod ;
      e.onCrash() ;
    }
    else {
      dx -= (dx+e.game.scroller.speed*Data.GROUND_SPEED)*0.8 ;
    }
  }

/*------------------------------------------------------------------------
    MAIN
 ------------------------------------------------------------------------*/
  function update() {

    if ( fl_fly ) {
      if ( Std.random(2)==0 ) {
        // Fumée
        var fx = entity.fx.Instant.attach (
              e.game,
              e.x+Std.random(30)/10,e.y+Std.random(30)/10,
              Data.SMOKE
        ) ;
        fx.randomize() ;
      }
      dy+=0.4*e.weight*Timer.tmod ;
      dr=(Std.random(3)+2)*Timer.tmod ;
    }
    else {
      // Roule sous la voiture
      if ( e.x>=e.game.car.x+Data.CAR_WIDTH && e.x<=e.game.car.x+Data.CAR_WIDTH*1.5 ) {
        var h = e.radius*(0.6+Std.random(30)/100)
        e.game.car.jump( (Std.random(2)*2-1) * Std.random(30)/10, -Math.min(15,h) ) ;
        e.y = Data.GROUND_Y-e._height/2 ;
        dy=0 ;
      }
      dr *= Math.pow(0.9,Timer.tmod) ;
      dy+=Data.GRAVITY*e.weight*Timer.tmod ;
    }
    super.update() ;
  }
}

