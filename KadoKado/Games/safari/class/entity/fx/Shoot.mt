class entity.fx.Shoot extends entity.Fx {

  function new() {
    super() ;
  }


/*------------------------------------------------------------------------
    INITIALISATION
 ------------------------------------------------------------------------*/
  function init(g,x,y) {
    super.init(g,x,y) ;
    mover = new mover.Linear(this) ;
  }


/*------------------------------------------------------------------------
    ATTACH
 ------------------------------------------------------------------------*/
  static function attach(g,x,y) {
    var e : entity.fx.Shoot = Std.cast(g.depthMan.attach("shoot", Data.DP_FX)) ;
    e.init(g,x,y);
    return e ;
  }
}