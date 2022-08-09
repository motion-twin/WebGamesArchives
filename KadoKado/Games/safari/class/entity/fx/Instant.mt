class entity.fx.Instant extends entity.Fx {
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
    this.stop() ;
    mover = new Mover(this) ;
    mover.dx = -game.scroller.speed*0.5 ;
  }


/*------------------------------------------------------------------------
    ATTACH
 ------------------------------------------------------------------------*/
  static function attach(g,x,y, frame:int) {
    var e : entity.fx.Instant = Std.cast(g.depthMan.attach("instantFx", Data.DP_FX)) ;
    e.init(g,x,y);
    e.gotoAndStop(frame+"") ;

    return e ;
  }



/*------------------------------------------------------------------------
    ALTÉRATIONS ALÉATOIRES
 ------------------------------------------------------------------------*/
  function randomize() {
    randomizeScale() ;
    randomizeRotation() ;
  }

  function randomizeScale() {
    this._xscale = Std.random(50)+50 ;
    this._yscale = this._xscale ;
  }

  function randomizeRotation() {
    this._rotation = Std.random(360) ;
  }


/*------------------------------------------------------------------------
    MAIN
 ------------------------------------------------------------------------*/
  function update() {
    super.update() ;
    if ( sub._currentframe==sub._totalframes )
      destroy() ;
    sub.nextFrame() ;
    if ( game.fl_fast )
      sub.nextFrame() ;
  }

}

