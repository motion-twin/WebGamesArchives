class mover.Warp extends Mover {
  var tx : float ;
  var ty : float ;
  var ang : float ;
  var speed : float ;

  var timer : float ;
  var warps : int ;


/*------------------------------------------------------------------------
    CONSTRUCTEUR
 ------------------------------------------------------------------------*/
  function new(e) {
    super(e) ;
    speed = 25 ;
    timer = 0.1 ;
    warps = 0 ;
  }


/*------------------------------------------------------------------------
    VISER
 ------------------------------------------------------------------------*/
  function aim(x,y) {
    tx = x ;
    ty = y ;
    ang = Math.atan2( y-e.y, x-e.x ) ;
    dx = Math.cos(ang)*speed ;
    dy = Math.sin(ang)*speed ;
    e.alpha = 50 ;
    warps++ ;
  }


/*------------------------------------------------------------------------
    ARRÊT ET ATTENTE
 ------------------------------------------------------------------------*/
  function halt() {
    timer = 70 * Math.max(0.6, 1.5*1/e.game.level ) ;
    e.alpha = 100 ;
  }



/*------------------------------------------------------------------------
    MAIN
 ------------------------------------------------------------------------*/
  function update() {
    if ( timer>0 ) {
      dx *= Math.pow( 0.5, Timer.tmod ) ;
      dy *= Math.pow( 0.5, Timer.tmod ) ;
      timer-=Timer.tmod ;
      if ( timer<=0 ) {
        if ( warps>=Data.MAX_WARP )
          aim( 350, e.y ) ;
        else
          aim( Std.random(240)+30, Std.random(170)+40 ) ;
        timer = 0 ;
      }
    }

    e._rotation = 3*dx;
    super.update() ;

    // Point dépassé
    if ( timer==0 ) {
      if ( Math.abs(Math.atan2( ty-e.y, tx-e.x )-ang) >= 1.57 )
        halt();
    }
  }
}

