class entity.fx.Gib extends entity.Fx {

  var sub : MovieClip ;

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
    mover.dx = -Std.random(150)/10 ;
    mover.dy = -Std.random(100)/10-5 ;
    mover.dr = -Std.random(50)/10-5
    _xscale = Std.random(50)+50 ;
    _yscale = _xscale ;
    this._rotation = Std.random(360) ;
  }


/*------------------------------------------------------------------------
    modifie le skin
 ------------------------------------------------------------------------*/
  function setSkin(frame:int, subFrame:int) {
    this.gotoAndStop(frame+"");
    if ( subFrame==null )
      this.sub.gotoAndStop( (Std.random(sub._totalframes)+1)+"" ) ;
    else
      this.sub.gotoAndStop( subFrame+"" ) ;
  }


/*------------------------------------------------------------------------
    ATTACH
 ------------------------------------------------------------------------*/
  static function attach(g,frame,subFrame x,y) {
    var e : entity.fx.Gib = Std.cast(g.depthMan.attach("gib", Data.DP_FX)) ;
    e.init(g,x,y);
    e.setSkin(frame,subFrame) ;
    return e ;
  }
}
