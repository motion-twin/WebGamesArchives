import Common;
import Anim;
import mt.bumdum.Lib;

class Token {
	static var ANIM_BLOW = {start: 1,end: 10};

	public var cell : Cell;
	public var team : Bool;
	public var game : Game;

	public var chained : Bool;

	public var mc(default,null) : flash.MovieClip;
	var mcFly : flash.MovieClip;

	var animGlow : Anim;
	var mcGlow : flash.MovieClip;

	public function new(g,c,t){
		game = g;
		cell = c;
		team = t;
		chained = false;
		display();
	}

	public function display(){
		if( mc == null ) mc = game.dmanagerToken.attach("token",Const.PLAN_TOKEN);
		if( !MMApi.isReconnecting() ){
			mc._x = cell.mc._x;
			mc._y = cell.mc._y;
			mc._visible = true;
			mc._alpha = 100;
			mc.gotoAndStop( if( team ) 2 else 1 );
		}
	}

	public function initActions(){
		mc.onRelease = initMove;

		startGlow();

	}

	public function stopActions(){
		Reflect.deleteField(mc,"onRelease");
		if( mcFly != null ){
			mcFly.removeMovieClip();
			mcFly = null;
		}
		stopGlow();
		display();
	}

	function possibleMoves(){
		var ret = new Array();
		var c = cell.countLineToken( South );

		var t = cell.getNeighbour(South,c,team);
		if( t != null ) ret.push( t );

		var t = cell.getNeighbour(North,c,team);
		if( t != null ) ret.push( t );

		c = cell.countLineToken( SouthEast );
		var t = cell.getNeighbour(SouthEast,c,team);
		if( t != null ) ret.push( t );

		var t = cell.getNeighbour(NorthWest,c,team);
		if( t != null ) ret.push( t );

		c = cell.countLineToken( SouthWest );
		var t = cell.getNeighbour(SouthWest,c,team);
		if( t != null ) ret.push( t );

		var t = cell.getNeighbour(NorthEast,c,team);
		if( t != null ) ret.push( t );
		return ret;
	}

	function initMove(){
		game.flyingToken = this;
		mc._alpha = 20;

		mcFly = game.dmanagerToken.attach("token",2);
		mcFly.onRelease = moveOrCancel;
		mcFly.gotoAndStop( if( team ) 2 else 1 );
		mcFly._xscale = mcFly._yscale = 110;
		updateFly();
		
		for( c in possibleMoves() ){
			c.mc.gotoAndStop( 2 );
		}
	}

	function moveOrCancel(){
		var pm = possibleMoves();
		var flyOn = null;
		for( c in pm ){
			if( c.mc.hitTest(flash.Lib._root._xmouse,flash.Lib._root._ymouse,true) ){
				flyOn = c;
				break;
			}
		}
		
		if( flyOn != null ){
			game.move( cell, flyOn );
			stopActions();
		}else{
			initActions();
			game.flyingToken = null;
			mcFly.removeMovieClip();
			mcFly = null;
			mc._alpha = 100;
			display();
		}
		
		for( c in pm ){
			c.mc.gotoAndStop( 1 );
		}
		
	}

	public function updateFly(){
		mcFly._x = mc._parent._xmouse;
		mcFly._y = mc._parent._ymouse;
	}

	public function moveTo( to : Cell ){
		if( MMApi.isReconnecting() ){
			arriveOn( to );
		}else{
			mcFly = game.dmanagerToken.attach("token",Const.PLAN_FLYING);
			mcFly.gotoAndStop( if( team ) 2 else 1 );
			mc._visible = false;
			var af = new AnimFly(mcFly,mc,to.mc);
			var me = this;
			af.onEnd = function(){
				me.arriveOn( to );
			}
			game.anim.add( af );
		}
		
	}

	public function arriveOn( to : Cell ){
		if( mcFly != null ){
			mcFly.removeMovieClip();
			mcFly = null;
		}
		if( to.token != null ){
			to.token.blow();
			to.token = null;
		}
		cell.token = null;
		to.token = this;
		cell = to;
		display();
	}

	public function blow(){
		mc.removeMovieClip();
		if( !MMApi.isReconnecting() ){
			mc = game.dmanagerToken.attach("blow",Const.PLAN_BLOW);
			mc._x = cell.mc._x;
			mc._y = cell.mc._y;
			game.anim.add( new AnimPlay(mc,ANIM_BLOW,0,kill) );
		}
	}

	function kill(){
		mc.removeMovieClip();
		mc = null;

		stopGlow();
	}

	public function stopGlow(){
		if( animGlow != null ){
			game.freeAnim.remove( animGlow );
			animGlow = null;
			mcGlow.removeMovieClip();
			mcGlow = null;
		}
	}

	public function startGlow(){
		if( animGlow == null ){
			mcGlow = game.dmanagerToken.attach("token",Const.PLAN_GLOW );
			mcGlow._x = cell.mc._x;
			mcGlow._y = cell.mc._y;
			mcGlow.stop();
			mcGlow.blendMode = "add";
			mcGlow._alpha = 0;
			Col.setColor( mcGlow, 0xFFFFFF, 0 );

			animGlow = new AnimGlow( mcGlow );
			game.freeAnim.add( animGlow );
		}
	}

	public function startVictoryGlow(){
		stopGlow();
		mcGlow = game.dmanagerToken.attach("token",Const.PLAN_GLOW );
		mcGlow._x = cell.mc._x;
		mcGlow._y = cell.mc._y;
		mcGlow.stop();
		mcGlow.blendMode = "add";
		mcGlow._alpha = 0;
		Col.setColor( mcGlow, 0xFFFFFF, 0 );

		animGlow = new AnimGlow( mcGlow, 2 );
		game.freeAnim.add( animGlow );
	}

	public function chain() : Int{
		var r = 1;
		var n : Cell;
		chained = true;

		n = cell.getNeighbour(North);
		if( n.token != null && n.token.team == team && !n.token.chained ) r += n.token.chain();

		n = cell.getNeighbour(NorthWest);
		if( n.token != null && n.token.team == team && !n.token.chained ) r += n.token.chain();

		n = cell.getNeighbour(NorthEast);
		if( n.token != null && n.token.team == team && !n.token.chained ) r += n.token.chain();

		n = cell.getNeighbour(South);
		if( n.token != null && n.token.team == team && !n.token.chained ) r += n.token.chain();

		n = cell.getNeighbour(SouthWest);
		if( n.token != null && n.token.team == team && !n.token.chained ) r += n.token.chain();

		n = cell.getNeighbour(SouthEast);
		if( n.token != null && n.token.team == team && !n.token.chained ) r += n.token.chain();

		return r;
	}
}
