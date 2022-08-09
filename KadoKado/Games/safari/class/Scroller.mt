class Scroller {
  var game : Game ;

  var sky : MovieClip;
  var back : MovieClip;
  var front : MovieClip;
  var under : MovieClip;

  var speed : float;

  var grounds: Array<MovieClip>;


/*------------------------------------------------------------------------
    CONSTRUCTEUR
 ------------------------------------------------------------------------*/
  function new(g) {
    game = g ;
    sky = game.depthMan.attach("sky",Data.DP_BG) ;
    back = game.depthMan.attach("back",Data.DP_BG) ;
    under = game.depthMan.attach("under",Data.DP_BG) ;
    front = game.depthMan.attach("front",Data.DP_BG) ;

    grounds = new Array() ;
    attachGrounds() ;
    speed = Data.MIN_SPEED ;
  }


/*------------------------------------------------------------------------
    ATTACH: SLICES DU SOL
 ------------------------------------------------------------------------*/
  function attachGrounds() {
    for(var i=0;i<Data.SLICES;i++) {
      var mc = game.depthMan.attach("ground",Data.DP_BG) ;
      mc.gotoAndStop((i+1)+"") ;
      mc._y = 248+i*Data.SLICE_HEIGHT;
      mc._xscale = 100+ 100*i/Data.SLICES ;
      mc._x = 150-mc._width/2;
      grounds.push(mc) ;
    }
  }


/*------------------------------------------------------------------------
    AFFICHE/MASQUE LE SOL EN MODE 7
 ------------------------------------------------------------------------*/
  function hideGround() {
    for(var i=0;i<grounds.length;i++) {
      var mc = grounds[i] ;
      mc._visible = false ;
    }
  }

  function showGround() {
    for(var i=0;i<grounds.length;i++) {
      var mc = grounds[i] ;
      mc._visible = true ;
    }
  }


/*------------------------------------------------------------------------
    MISE À JOUR DE LA VITESSE SELON LA DIFFICULTÉ
 ------------------------------------------------------------------------*/
  function updateSpeed() {
    speed = Data.SCROLLER_SPEED + game.level*3 ;
  }


/*------------------------------------------------------------------------
    MAIN
 ------------------------------------------------------------------------*/
  function update() {
    // Controle du speed
    if ( Key.isDown(Key.LEFT) )
      speed = Math.max(Data.MIN_SPEED, speed-0.5*Timer.tmod) ; ;

    if ( Key.isDown(Key.RIGHT) )
      speed+=0.5*Timer.tmod ;

    //if ( Key.isDown(Key.SHIFT) )
      //speed = Data.MIN_SPEED ;


    // Plans de décor
    back._x -= Timer.tmod * speed*0.2;
    under._x -= Timer.tmod * speed*0.35;
    front._x -= Timer.tmod * speed*0.5;
    if ( back._x<=-300 ) back._x+=300 ;
    if ( under._x<=-300 ) under._x+=300 ;
    if ( front._x<=-300 ) front._x+=300 ;


    // Sol mode 7
    var guide = grounds[0] ;
    guide._x -= Timer.tmod * speed*0.5 ;
    if ( guide._x<=300-guide._width )
      guide._x+=guide._width/2 ;
    var center = guide._x + guide._width/2 ;

    for(var i=1;i<grounds.length;i++) {
      var mc = grounds[i] ;
      var offset = (center-150)/300*300*i/Data.SLICES ;
      mc._x = guide._x - 300*i/Data.SLICES + offset;
    }
  }

}
