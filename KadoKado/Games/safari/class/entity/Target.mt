class entity.Target extends Entity {

  var energy : float ;
  var baseEnergy : float ;
  var bonus : int ;
  var delayedHit : Array< {timer:float,power:float} > ;

  var shadow : MovieClip ;
  var shadowY : float ;

  var targetId : int ;


/*------------------------------------------------------------------------
    CONSTRUCTEUR
 ------------------------------------------------------------------------*/
  function new() {
    super() ;
    baseEnergy = 1 ;
    bonus = 0 ;
    fl_count = true ;
    delayedHit = new Array() ;
    shadowY = Std.random(500)/100 ;
  }


/*------------------------------------------------------------------------
    INITIALISATION
 ------------------------------------------------------------------------*/
  function init(g,x,y) {
    shadow = g.depthMan.attach("shadow", Data.DP_SHADOW) ;
    super.init(g,x,y) ;
    initTarget() ;
    this.stop();
  }


/*------------------------------------------------------------------------
    INITIALISATION SPÉCIFIQUE
 ------------------------------------------------------------------------*/
  function initTarget() {
    energy = baseEnergy ;
  }


/*------------------------------------------------------------------------
    DÉTRUIT
 ------------------------------------------------------------------------*/
  function explode() {
    if ( fl_kill )
      return ;
    if ( fl_count ) {
      game.targets-- ;
      game.ttargets-- ;
      fl_count = false;
    }

    setLuminosity(-70) ;
    game.kills ++ ;
    if ( bonus!=null )
      game.getBonus(KKApi.const(bonus),null,x,y-10) ;
    fl_kill = true ;
    mover = new mover.Death(this) ;
    shockwave() ;
  }



/*------------------------------------------------------------------------
    TOUCHÉ
 ------------------------------------------------------------------------*/
  function hit(damage) {
    energy-=Math.max(1,damage) ;

    var n=2 ;
    if ( game.fl_fast )
      n=3 ;

    if ( Std.random(n)==0 )
      entity.fx.Gib.attach(game,Data.GIB_MISC,null, x,y) ;
    if ( energy<=0 )
      explode() ;
    else
      setLuminosity(255) ;
  }


/*------------------------------------------------------------------------
    ONDE DE CHOC D'EXPLOSION
 ------------------------------------------------------------------------*/
  function shockwave() {
    var shockRadius = radius*Data.SHOCKWAVE_FACTOR*shockFactor ;
    var fx = entity.fx.Instant.attach( game,x,y, 3 ) ;
    fx.mover = null ;
    fx._width = shockRadius*2 ;
    fx._height = fx._width ;

    for (var i=0;i<game.entityList.length;i++) {
      var e = game.entityList[i] ;
      if ( !e.fl_kill ) {
        var dist = Math.sqrt( Math.pow(x-e.x,2) + Math.pow(y-e.y,2) ) ;
        if ( dist<=shockRadius )
          downcast(e).delayedHit.push(
            {
              timer:Std.random(40)/10+2,
              power:baseEnergy
            }
          ) ;
      }
    }
  }


/*------------------------------------------------------------------------
    EXPLOSION DE TOUTES LES PARTIES
 ------------------------------------------------------------------------*/
  function explodeFullGibs(id) {
    this.gotoAndStop("2") ;
    var fx = entity.fx.Gib.attach(game,id,1, x,y) ;
    var n = fx.sub._totalframes ;
    if ( game.fl_fast )
      n=Math.floor(n*0.5) ;
    for (var i=2;i<n;i++)
      entity.fx.Gib.attach(game,id,i, x,y) ;
  }


/*------------------------------------------------------------------------
    FUITE
 ------------------------------------------------------------------------*/
  function flee() {
    if ( targetId!=null )
      game.miss(targetId) ;
    destroy() ;
  }


/*------------------------------------------------------------------------
    DESTRUCTION
 ------------------------------------------------------------------------*/
  function destroy() {
    shadow.removeMovieClip() ;
    super.destroy() ;
  }


/*------------------------------------------------------------------------
    MISE À JOUR GRAPHIQUE
 ------------------------------------------------------------------------*/
  function endUpdate() {
    super.endUpdate() ;
    shadow._x = x ;
    shadow._y = shadowY + Data.GROUND_Y-5 ;
    var s = Math.max(0.5, 1-((shadow._y-y)/300)) ;
    shadow._height = 7 ;
    shadow._width = radius*2*s ;
  }


/*------------------------------------------------------------------------
    MAIN
 ------------------------------------------------------------------------*/
  function update() {
    super.update() ;


    // Sortie
    if ( x>=310+_width && !fl_kill )
      flee() ;
    if ( x<=-_width && fl_kill )
      destroy() ;


    // Hits en décalé
    for (var i=0;i<delayedHit.length;i++) {
      var h = delayedHit[i] ;
      h.timer-=Timer.tmod ;
      if ( h.timer<=0 ) {
        hit(h.power) ;
        delayedHit.splice(i,1) ;
        i-- ;
      }
    }
  }


}
