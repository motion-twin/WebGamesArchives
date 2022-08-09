class Card {

	static var cards = new Array();

	var id : int;
	var mc : MovieClip;
	var mcface : MovieClip;
	var flip : MovieClip;
	var game : Game;
	var visible : bool;
	var hideTimer : float ;

	function new(g,id,x,y) {
		this.id = id;
		visible = false;
		game = g;
		initCard(x,y);
	}

	function initCard(x,y) {

		var l = game.getLevel();
		var px = (300 - l.width * 50 + 8) / 2;
		var py = (290 - l.height * 70 + 6) / 2 + 10;

		mc = game.dmanager.attach("card",Const.PLAN_CARD);
		mc._x = px + x * 50;
		mc._y = py + y * 70;
		mc.stop();

		mcface = game.dmanager.attach("card",Const.PLAN_CARD);
		mcface._x = mc._x;
		mcface._y = mc._y;
		mcface._visible = false;
		mcface.gotoAndStop(string(id+2));

		var me = this;
		mc.onPress = fun() { me.game.cardSelect(me) };
		KKApi.registerButton(mc);
	}

	function show(b) {
		visible = b;
	    flip = game.dmanager.attach("flip",Const.PLAN_CARD) ;
	    flip._x = mc._x ;
	    flip._y = mc._y ;
	    flip.stop() ;
	    downcast(flip).top.gotoAndStop(string(id+2)) ;
	    downcast(flip).back.stop() ;
		mcface._visible = false;
		mc._visible = false ;

		if( !visible ) {
		  flip.gotoAndStop( string(flip._totalframes) ) ;
		  hideTimer = 10 ;
		}
		cards.push(this);
	}

	function destroy() {
		mc.removeMovieClip();
		mcface.removeMovieClip();
	}

	static function main(g) {
		var i;
		for(i=0;i<cards.length;i++) {
			var c = cards[i];
			if( c.visible ) {
			    if ( c.flip._currentframe==c.flip._totalframes ) {
			        c.flip.removeMovieClip() ;
					c.mcface._visible = true;
					cards.splice(i--,1);
					g.onShowDone(c);
				}
			    c.flip.nextFrame() ;
			} else {
			    c.hideTimer-=Timer.tmod ;
			    if ( c.hideTimer<=0 ) {
    			    if ( c.flip._currentframe==1 ) {
    			        c.flip.removeMovieClip() ;
    					c.mc._visible = true ;
    					cards.splice(i--,1);
    					g.onShowDone(c);
    				}
    			    c.flip.prevFrame() ;
    			}
			}
		}
	}

}