class Mover {
  var e : Entity ;

  var dx : float;
  var dy : float ;
  var dr : float ;

/*------------------------------------------------------------------------
    CONSTRUCTEUR
 ------------------------------------------------------------------------*/
  function new(e) {
    this.e = e ;
    dx = 0 ;
    dy = 0 ;
  }


/*------------------------------------------------------------------------
    EVENT: SOL
 ------------------------------------------------------------------------*/
  function onHitGround() {
    dy=-dy*0.6 ;
    e.y = Data.GROUND_Y-e._height/2 ;
  }


/*------------------------------------------------------------------------
    MAIN
 ------------------------------------------------------------------------*/
  function update() {
    e.x+=dx*Timer.tmod ;
    e.y+=dy*Timer.tmod ;
    e._rotation+=dr*Timer.tmod ;


    if ( e.y+e.radius/2>=Data.GROUND_Y && dy>0 )
      onHitGround() ;
  }
}

