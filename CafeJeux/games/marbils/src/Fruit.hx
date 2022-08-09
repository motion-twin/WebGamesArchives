import Common;
import Anim;
	
typedef FruitMc = {> flash.MovieClip, beretFrame : Int, fruit: {> flash.MovieClip, beret: flash.MovieClip}}

typedef Plouf = {> flash.MovieClip,
	size : Float
}

typedef Voosh = {> flash.MovieClip,
	sub: flash.MovieClip
}

typedef Spark = {> flash.MovieClip,
	sub: flash.MovieClip
}

class Fruit {
	public var dmanager : mt.DepthManager;
	static var ANIM_JUMP_DOWN = {start: 11, end: 31};
	static var ANIM_JUMP_HORI = {start: 41, end: 61};
	static var ANIM_JUMP_UP = {start: 71, end: 91};

	static var ANIM_PUSH_DOWN = {start: 126, end: 146};
	static var ANIM_PUSH_HORI = {start: 101, end: 121};
	static var ANIM_PUSH_UP = {start: 151, end: 171};
	
	static var ANIM_KILL = {start: 181, end: 220};
	static var ANIM_STONE = {start: 224, end: 241};
	static var ANIM_SLEEP = {start: 263, end: 274};
	static var ANIM_MYTURN = {start: 275, end: 295};
	static var ANIM_VICTORY = [{start: 243, end: 250},{start: 256, end: 280},{start: 286, end: 310},{start: 317, end: 341}];
	
	static var PLOUF_START = {start: 1, end: 48};
	static var ANIM_VOOSH = {start: 1, end: 28}
	static var ANIM_SPARK = {start: 1,end: 9};

	public var team : Team;
	public var originalTeam : Team;
	public var pos : Pos;
	var mc : FruitMc;
	var game : Game;
	public var stoned : Bool;
	public var sleeping : Anim;
	public var myturn : Anim;
	public var starsMc : flash.MovieClip;
	public var destroyed : Bool;

	public function new( g, t, p ){
		game = g;
		team = t;
		originalTeam = t;
		pos = p;
		stoned = false;
		destroyed = false;
	}

	public function display(){
		var px = pos.x * Const.CSIZE + Const.BASEX;
		var py = pos.y * Const.CSIZE + Const.BASEY;
		if( mc == null ) mc = cast game.fruit("fruit",null,null);
		mc._x = px;
		mc._y = py;
		if( starsMc != null ){
			starsMc._x = px;
			starsMc._y = py;
		}
		game.dmanager.compact(Const.PLAN_FRUIT);
		game.dmanager.ysort(Const.PLAN_FRUIT);
		//mc.gotoAndStop(if(originalTeam == Orange) 1 else 2);
		mc.beretFrame = if(team == Orange) 1 else 2;
		mc.gotoAndStop(mc.beretFrame);
		mc.fruit.gotoAndStop(1);
		if( stoned )
			mc.fruit.gotoAndStop(ANIM_STONE.end);
		if( MMApi.isMyTurn() && game.myTeam == team && MMApi.hasControl() && !MMApi.isReconnecting() )
			myTurn();
	}

	public function move( d : Direction, pushed : Bool, ?endFun: Void -> Void ){
		game.moveCount++;
		wakeUp();
		if( endFun == null ) endFun = display;
		var a =
		switch( d ){
			case Up:
				new AnimPlay(mc.fruit,if( pushed ) ANIM_PUSH_UP else ANIM_JUMP_UP,(game.max_y - pos.y)*2,endFun);
			case Down:
				new AnimPlay(mc.fruit,if( pushed ) ANIM_PUSH_DOWN else ANIM_JUMP_DOWN,(pos.y - game.min_y)*2,endFun);
			case Left:
				new AnimPlay(mc.fruit,if( pushed ) ANIM_PUSH_HORI else ANIM_JUMP_HORI,(game.max_x - pos.x)*2,endFun,true);
			case Right:
				new AnimPlay(mc.fruit,if( pushed ) ANIM_PUSH_HORI else ANIM_JUMP_HORI,(pos.x - game.min_x)*2,endFun);
		}
		game.anim.add(a);
	}

	public function moveAndDestroy( d : Direction ){
		game.moveCount++;
		pos = { x: pos.x, y: pos.y };
		switch( d ){
			case Up: pos.y--;
			case Down: pos.y++;
			case Left: pos.x--;
			case Right: pos.x++;
		}
		move(d,false,destroy);
	}

	public function moveAndMine( d : Direction, to : Cell ){
		game.moveCount++;
		pos = to;
		var me = this;

		move(d,false,function(){
			me.display();
			if( to.displayMine ){
				to.destroy(function(){ me.destroy(); });
			}else{
				to.card.displayPower(function(){ to.destroy(function(){ me.destroy(); }); });
			}
		});
	}

	public function destroy(){
		destroyed = true;
		display();
		game.dmanager.swap(mc,Const.PLAN_BG);
		game.anim.add( new AnimPlay(mc.fruit,ANIM_KILL,0,kill) );
		
		var plouf:Plouf = cast game.dmanager.attach("plouf",Const.PLAN_FRUIT);
		game.anim.add( new AnimPlay(plouf,PLOUF_START,Std.random(5),function(){ plouf.removeMovieClip(); }) );
		plouf._x = mc._x;
		plouf._y = mc._y;
		plouf._yscale = Std.random(20)+90;
		plouf._xscale = Std.random(20)+90;
	}

	public function vachette(wait){
		display();
		var r = if( Std.random(2) == 0 ) 20 else -20;
		var p = {start: {x: mc._x,y: mc._y},end: {x: mc._x + r,y: mc._y - 80}}
		var onUpdate = function(mc:flash.MovieClip,i,r:Float){
			mc._xscale += r * 2;
			mc._yscale += r * 2;
			mc._alpha -= r * 50;
		}
		game.anim.add( new AnimMove(mc,p,8,wait,kill,onUpdate) );
	}

	public function stone(){
		endMyTurn();
		stoned = true;
		game.anim.add( new AnimPlay(mc.fruit,ANIM_STONE) );
	}

	public function sleep(){
		if( stoned ) return;
		sleeping = new AnimPlay(mc.fruit,ANIM_SLEEP,false,true);
		game.freeAnim.add( sleeping );
	}

	public function wakeUp(){
		if( sleeping != null && !destroyed ){
			game.freeAnim.remove( sleeping );
			if( !stoned ) mc.fruit.gotoAndStop(1);
		}
	}

	public function myTurn(){
		if( myturn != null || destroyed  ) return;
		wakeUp();
		if( stoned || !MMApi.hasControl() ) return;
		myturn = new AnimPlay(mc.fruit,ANIM_MYTURN,false,true);
		game.freeAnim.add( myturn );
	}

	public function endMyTurn(){
		if( myturn != null ){
			game.freeAnim.remove( myturn );
			myturn = null;
			if( !stoned ) mc.fruit.gotoAndStop(1);
		}
	}

	public function convert(){
		team = Game.opposite(team);
		var voosh : Voosh = cast game.dmanager.attach("voosh",Const.PLAN_EFFECT);
		voosh._x = mc._x;
		voosh._y = mc._y;
		var me = this;
		var oe = function(){
			voosh.removeMovieClip();
			me.game.checkVictory();
			if( me.game.effect.oppDesordre && me.team != me.game.myTeam )
				me.stars();
		}
		var t = {d: false};
		var ou = function( mc, i, r ){
			if( i >= 12 && !t.d ){
				t.d = true;
				me.display();
			}
		}
		var a = new AnimPlay(voosh.sub,ANIM_VOOSH,0,oe,false,ou);
		game.anim.add( a );
	}

	public function spark(){
		var s : Spark = cast game.dmanager.attach("sparke",Const.PLAN_EFFECT);
		s._x = mc._x;
		s._y = mc._y;

		var oe = function(){ s.removeMovieClip(); }
		var a = new AnimPlay(s.sub,ANIM_SPARK,0,oe);
		game.anim.add( a );
	}

	public function stars(){
		if( starsMc != null ) return;

		starsMc = cast game.dmanager.attach("stars",Const.PLAN_EFFECT);
		starsMc._x = mc._x;
		starsMc._y = mc._y;
	}

	public function cleanStars(){	
		if( starsMc == null ) return;

		starsMc.removeMovieClip();
		starsMc = null;
	}

	public function kill(){
		cleanStars();
		mc.removeMovieClip();
	}

	/*
	public function victory( t : Team ){
		if( team == t )
			game.anim.add( new AnimPlay(mc.fruit,ANIM_VICTORY[Std.random(ANIM_VICTORY.length)],0,null,null,null,true) );
	}
	*/

}

