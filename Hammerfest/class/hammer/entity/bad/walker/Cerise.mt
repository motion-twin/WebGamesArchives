class entity.bad.walker.Cerise extends entity.bad.Walker {

/*------------------------------------------------------------------------
    CONSTRUCTEUR
 ------------------------------------------------------------------------*/
  function new() {
    super() ;
    animFactor = 0.65 ;
  }


/*------------------------------------------------------------------------
    ATTACHEMENT
 ------------------------------------------------------------------------*/
  static function attach(g:mode.GameMode,x,y) {
    var linkage = Data.LINKAGES[Data.BAD_CERISE];
    var mc : entity.bad.walker.Cerise = downcast( g.depthMan.attach(linkage,Data.DP_BADS) ) ;
    mc.initBad(g,x,y) ;
    return mc ;
  }

}

