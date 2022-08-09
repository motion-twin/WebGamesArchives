class entity.fx.Cartridge extends entity.Fx {

/*------------------------------------------------------------------------
    CONSTRUCTEUR
 ------------------------------------------------------------------------*/
  function new() {
    super() ;
  }


/*------------------------------------------------------------------------
    INITIALISATION
 ------------------------------------------------------------------------*/
  function init(g,x,y) {
    super.init(g,x,y) ;
    mover = new mover.Fall(this) ;
    mover.dx = -Std.random(200)/10 ;
    mover.dy = -Std.random(100)/10-4 ;
    mover.dr = Std.random(50)/10+5
    this._rotation = Std.random(360) ;
  }


/*------------------------------------------------------------------------
    ATTACH
 ------------------------------------------------------------------------*/
  static function attach(g,x,y) {
    var e : entity.fx.Cartridge = Std.cast(g.depthMan.attach("cartridge", Data.DP_FX)) ;
    e.init(g,x,y);
    return e ;
  }
}
