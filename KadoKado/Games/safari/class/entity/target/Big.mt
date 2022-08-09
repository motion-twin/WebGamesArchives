class entity.target.Big extends entity.Target {
  var flame : MovieClip;

/*------------------------------------------------------------------------
    CONSTRUCTEUR
 ------------------------------------------------------------------------*/
  function new() {
    super() ;
    baseEnergy = 15 ;
    bonus = 500 ;
    targetId = Data.BIG ;
  }


/*------------------------------------------------------------------------
    INITIALISATION
 ------------------------------------------------------------------------*/
  function initTarget() {
    super.initTarget() ;
    mover = new mover.Curves(this) ;
    downcast(mover).amp = 10 ;
    mover.dx = Std.random(200)/100+1 ;
    radius = 28 ;
    shockFactor = 1.5 ;
  }


/*------------------------------------------------------------------------
    EXPLOSION
 ------------------------------------------------------------------------*/
  function explode() {
    super.explode();
    flame._visible = false ;
  }


/*------------------------------------------------------------------------
    EVENT: CRASH AU SOL
 ------------------------------------------------------------------------*/
  function onCrash() {
    super.onCrash() ;
    explodeFullGibs(Data.GIB_BIG) ;
    this.gotoAndStop("2") ;
  }


/*------------------------------------------------------------------------
    ATTACH
 ------------------------------------------------------------------------*/
  static function attach(g,x,y) {
    var e : entity.target.Big = Std.cast(g.depthMan.attach("bigUFO", Data.DP_TARGET)) ;
    e.init(g,x,y);
  }

}
