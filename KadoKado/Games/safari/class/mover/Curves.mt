class mover.Curves extends Mover {

  var baseY : float ;
  var amp : float ;


/*------------------------------------------------------------------------
    CONSTRUCTEUR
 ------------------------------------------------------------------------*/
  function new(e) {
    super(e);
    dx = Std.random(15)/10+1 + Math.min( 2.5,e.game.level*0.5 ) ;
    baseY = e.y ;
    amp = Math.min( 2.5, 0.5*e.game.level) * (Std.random(30)+10 ) ;
  }


/*------------------------------------------------------------------------
    MAIN
 ------------------------------------------------------------------------*/
  function update() {
    super.update() ;
    e.y = Math.cos(e.x*0.03)*amp+baseY;
  }
}

