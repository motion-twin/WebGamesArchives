class entity.target.Warper extends entity.Target {

/*------------------------------------------------------------------------
    CONSTRUCTEUR
 ------------------------------------------------------------------------*/
  function new() {
    super() ;
    baseEnergy = 2 ;
    bonus = 100 ;
    shockFactor = 1.5 ;
    targetId = Data.WARPER ;
  }


/*------------------------------------------------------------------------
    INITIALISATION
 ------------------------------------------------------------------------*/
  function initTarget() {
    super.initTarget() ;
    mover = new mover.Warp(this) ;
    radius = 19 ;
  }


/*------------------------------------------------------------------------
    EVENT: CRASH AU SOL
 ------------------------------------------------------------------------*/
  function onCrash() {
    super.onCrash() ;
    explodeFullGibs(Data.GIB_WARPER) ;
  }


/*------------------------------------------------------------------------
    ATTACH
 ------------------------------------------------------------------------*/
  static function attach(g,x,y) {
    var e : entity.target.Warper = Std.cast(g.depthMan.attach("warper", Data.DP_TARGET)) ;
    e.init(g,x,y);
  }

}
