class entity.target.Option extends entity.Target {
  var flame:MovieClip ;

/*------------------------------------------------------------------------
    CONSTRUCTEUR
 ------------------------------------------------------------------------*/
  function new() {
    super() ;
    baseEnergy = 1 ;
    bonus = null ;
  }


/*------------------------------------------------------------------------
    INITIALISATION
 ------------------------------------------------------------------------*/
  function initTarget() {
    super.initTarget() ;
    mover = new mover.Linear(this) ;
    radius = 18 ;
  }


/*------------------------------------------------------------------------
    EXPLOSION
 ------------------------------------------------------------------------*/
  function explode() {
    if ( fl_kill )
      return ;
    game.multi ++ ;
    game.multiTimer += Data.MULTI_TIMER
    var fx = game.depthMan.attach("displayBonus",Data.DP_FX) ;
    downcast(fx).txt = " x"+game.multi+" " ;
    fx._x = x ;
    fx._y = y ;

    super.explode();

    flame._visible = false ;
  }


/*------------------------------------------------------------------------
    EVENT: CRASH AU SOL
 ------------------------------------------------------------------------*/
  function onCrash() {
    super.onCrash() ;
    explodeFullGibs(Data.GIB_OPTION) ;
  }


/*------------------------------------------------------------------------
    ATTACH
 ------------------------------------------------------------------------*/
  static function attach(g,x,y) {
    var e : entity.target.Option = Std.cast(g.depthMan.attach("option", Data.DP_TARGET)) ;
    e.init(g,x,y);
  }

}
