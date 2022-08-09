class Entity extends MovieClip {
  var game : Game ;

  var x : float ;
  var y : float ;
  var radius : float ;
  var shockFactor : float ;
  var alpha : float ;
  var weight : float ;

  var fl_kill : bool ;
  var fl_destroy : bool ;
  var fl_count : bool ;
  var fl_useless : bool ;

  var mover : Mover ;

  var color : Color ;
  var light : float ;
  var lightTimer : float ;

  var lifeTimer : float ;



/*------------------------------------------------------------------------
    CONSTRUCTEUR
 ------------------------------------------------------------------------*/
  function new() {
    fl_destroy = false ;
    fl_kill = false ;
    fl_count = false ;
    fl_useless = false ;
    alpha = 100 ;
    weight = 1.0 ;
    shockFactor = 1.0 ;
    lifeTimer = null ;
    setLuminosity(0) ;
  }

/*------------------------------------------------------------------------
    INITIALISATION
 ------------------------------------------------------------------------*/
  function init(g,x,y) {
    game = g ;
    this.x = x ;
    this.y = y ;
    radius = this._width/2 ;
    register() ;
    endUpdate() ;
  }


/*------------------------------------------------------------------------
    MISE EN LISTE
 ------------------------------------------------------------------------*/
  function register() {
    game.entityList.push(this) ;
    if ( fl_count ){
      game.targets++ ;
      game.ttargets++ ;
    }
  }


/*------------------------------------------------------------------------
    DÉFINI UN FILTRE DE COULEUR SUR LE MC
 ------------------------------------------------------------------------*/
  function setColor( rPct,rAlpha, gPct,gAlpha, bPct,bAlpha ) {
    var obj = {
      ra:rPct,rb:rAlpha,
      ga:gPct,gb:gAlpha,
      ba:bPct,bb:bAlpha,
      aa:100,ab:0
    };
    color = new Color(this) ;
    color.setTransform(obj) ;
  }


/*------------------------------------------------------------------------
    DÉFINI LA LUMINOSITÉ DE L'ENTITÉ
 ------------------------------------------------------------------------*/
  function setLuminosity(offset) {
    setColor( 100,offset, 100,offset, 100,offset ) ;
    light = offset ;
    if ( light>0 )
      lightTimer = 2 ;
  }


/*------------------------------------------------------------------------
    DESTRUCTION
 ------------------------------------------------------------------------*/
  function destroy() {
    if ( fl_count ) {
      game.targets-- ;
      game.ttargets-- ;
      fl_count = false;
    }
    removeMovieClip() ;
  }


/*------------------------------------------------------------------------
    EVENT: CRASH AU SOL
 ------------------------------------------------------------------------*/
  function onCrash() {
    _rotation = Std.random(360) ;
    lifeTimer = 50 ;
  }


/*------------------------------------------------------------------------
    UPDATE GRAPHIQUE
 ------------------------------------------------------------------------*/
  function endUpdate() {
    _x = x ;
    _y = y ;
    _alpha = alpha ;
  }



/*------------------------------------------------------------------------
    MAIN
 ------------------------------------------------------------------------*/
  function update() {
    if ( mover!=null )
      mover.update() ;

    if ( lightTimer>0 ) {
      lightTimer-=Timer.tmod ;
      if ( lightTimer<=0 )
        setLuminosity(0) ;
    }

    if ( lifeTimer!=null ) {
      lifeTimer-=Timer.tmod ;
      if ( lifeTimer<=0 ) {
        alpha -= Timer.tmod ;
        if ( alpha<=0 )
          destroy() ;
      }
    }
  }

}

