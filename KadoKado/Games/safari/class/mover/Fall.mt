class mover.Fall extends Mover {

/*------------------------------------------------------------------------
    CONSTRUCTEUR
 ------------------------------------------------------------------------*/
  function new(e) {
    super(e) ;
    dx += 5 ;
  }


/*------------------------------------------------------------------------
    EVENT: SOL
 ------------------------------------------------------------------------*/
  function onHitGround() {
    super.onHitGround() ;
    var s = Math.round(e.game.scroller.speed) ;
    dr = - (Std.random(s)+s*1.5)*Timer.tmod ;
    dx -= (dx+e.game.scroller.speed*Data.GROUND_SPEED)*0.5 ;
  }

/*------------------------------------------------------------------------
    MAIN
 ------------------------------------------------------------------------*/
  function update() {
    super.update() ;
    dy+=Data.GRAVITY*e.weight*Timer.tmod ;
  }
}

