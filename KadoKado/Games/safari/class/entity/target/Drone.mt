class entity.target.Drone extends entity.Target {
  var flame:MovieClip ;

/*------------------------------------------------------------------------
    CONSTRUCTEUR
 ------------------------------------------------------------------------*/
  function new() {
    super() ;
    baseEnergy = 1 ;
    bonus = 50 ;
    targetId = Data.DRONE ;
  }


/*------------------------------------------------------------------------
    INITIALISATION
 ------------------------------------------------------------------------*/
  function initTarget() {
    super.initTarget() ;
    mover = new mover.Curves(this) ;
    radius = 18 ;
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
    explodeFullGibs(Data.GIB_DRONE) ;
  }


/*------------------------------------------------------------------------
    UPDATE GRAPHIQUE
 ------------------------------------------------------------------------*/
  function endUpdate() {
    super.endUpdate() ;
    if ( !fl_kill ) {
      var ratio = (y-downcast(mover).baseY) / downcast(mover).amp
      flame._xscale = 20+30*Math.abs(ratio) ;
    }
  }


/*------------------------------------------------------------------------
    ATTACH
 ------------------------------------------------------------------------*/
  static function attach(g,x,y) {
    var e : entity.target.Drone = Std.cast(g.depthMan.attach("drone", Data.DP_TARGET)) ;
    e.init(g,x,y);
  }

}
