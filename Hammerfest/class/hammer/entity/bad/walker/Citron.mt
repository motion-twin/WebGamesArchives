class entity.bad.walker.Citron extends entity.bad.Shooter {

/*------------------------------------------------------------------------
    CONSTRUCTEUR
 ------------------------------------------------------------------------*/
  function new() {
    super() ;
    setJumpH(50) ;
    setShoot(3) ;
    initShooter(50, 20) ;
  }


/*------------------------------------------------------------------------
    ATTACHEMENT
 ------------------------------------------------------------------------*/
  static function attach(g:mode.GameMode,x,y) {
    var linkage = Data.LINKAGES[Data.BAD_CITRON];
    var mc : entity.bad.walker.Citron = downcast( g.depthMan.attach(linkage,Data.DP_BADS) ) ;
    mc.initBad(g,x,y) ;
    return mc ;
  }


/*------------------------------------------------------------------------
    EVENT: TIR
 ------------------------------------------------------------------------*/
  function onShoot() {
    var s = entity.shoot.Zeste.attach(game, x,y) ;
    var target = game.getOne(Data.PLAYER) ;
    if ( target.y<y )
      s.moveUp(s.shootSpeed) ;
    else
      s.moveDown(s.shootSpeed) ;
  }

}

