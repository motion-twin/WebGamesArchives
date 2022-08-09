import Common;
import Anim;

class Cell {
	static var ANIM_DESTROY = {start: 9, end: 62};
	static var ANIM_DISAPPEAR = {start: 63, end: 63};
	static var ANIM_ANVIL = {start: 1,end: 12};
	static var ANIM_SMOKE_ANVIL = {start: 1, end: 12};
	static var ANIM_VACHETTE = {start: 1,end: 9};
	static var ANIM_SMOKE = {start: 1,end: 21};
	public var status : Status;
	public var fruit : Fruit;

	public var x : Int;
	public var y : Int;

	public var card : Card;

	public var mc(default,null) : flash.MovieClip;
	var mcTarget : flash.MovieClip;
	var mcFX : flash.MovieClip;
	var game : Game;
	public var displayMine : Bool;

	public function new( g, t, x, y ){
		game = g;
		status = Used;
		this.x = x;
		this.y = y;
		fruit = new Fruit( g, t, this );
		displayMine = false;
	}

	public function display(){
		if( mc == null ){
			mc = game.dmanagerBoard.attach("cell",0);
			mc.stop();
		}
		mc._x = x * Const.CSIZE + Const.BASEX;
		mc._y = y * Const.CSIZE + Const.BASEY;
		if( status == Mined && displayMine ){
			var c = new flash.filters.ColorMatrixFilter();
			c.matrix = [
				1/4, 1/4, 1/4, 0,   0,
				1/4, 1/4, 1/4, 0,   0,
				1/4, 1/4, 1/4, 0,   0,
				0,   0,   0,   1,   0
			];
			mc.filters = [cast c];
		}
	}

	public function destroy( ?oe : Void -> Void ){
		var me = this;
		if( status == Destroy ) return;
		if( card != null )
			card.remove();
		if( status == Used ){
			oe = function(){ me.fruit.destroy(); }
		}
		status = Destroy;
		var onEnd = function(){
			me.kill();
			if( oe != null ) oe();
		}
		game.anim.add( new AnimPlay(mc,ANIM_DESTROY,Std.random(8),onEnd) );
	}

	public function disappear(){
		if( status == Destroy ) return;
		if( card != null ) card.remove();
		status = Destroy;
		game.anim.add( new AnimPlay(mc,ANIM_DISAPPEAR,0,kill) );
	}

	function kill(){
		mc.removeMovieClip();
	}

	function getNeighbour( d : Direction ){
		return switch( d ){
				case Up: game.grid[y-1][x];
				case Down: game.grid[y+1][x];
				case Left: game.grid[y][x-1];
				case Right: game.grid[y][x+1];
		};
	}

	public function move( d : Direction, ?t : Team ) : Bool{
		if( status == Used ){
			if( fruit.stoned ) return false;
			if( t == null || fruit.team == t){
				var to = getNeighbour(d);
				if( to == null || to.status == Destroy ){
					fruit.moveAndDestroy(d);
				}else if( to.status == Mined ){
					fruit.moveAndMine(d,to);
				}else{
					if( to.status == Used ){
						if( !to.move( d ) ) return false;
					}
					to.fruit = fruit;
					to.status = Used;
					fruit.pos = to;
					fruit.move(d,t == null);
				}
				fruit = null;
				status = Free;
			}
		}
		return true;
	}

	public function addFruit( t : Team ){
		if( status != Free ) throw "Ne peut pas ajouter un élément sur cette case !";
		status = Used;
		fruit = new Fruit(game,t,this);
		fruit.display();
	}

	public function chooseTarget( onRelease : Void -> Void ){
		mc.onRollOver= displayTarget;
		mc.onRollOut = hideTarget;
		mc.onRelease = onRelease;
	}

	function displayTarget(){
		mcTarget = game.fruit("target",mc._x,mc._y);
	}

	function hideTarget(){
		mcTarget.removeMovieClip();
		mcTarget = null;
	}

	public function chooseVachette( onRelease : Void -> Void ){
		mc.onRollOver = displayVachette;
		mc.onRollOut = hideTarget;
		mc.onRelease = onRelease;
	}

	function displayVachette(){
		mcTarget = game.fruit("vachette",mc._x,16);
		mcTarget.stop();
	}

	public function cleanRoll(){
		hideTarget();
		Reflect.deleteField(mc,"onRollOver");
		Reflect.deleteField(mc,"onRollOut");
		Reflect.deleteField(mc,"onRelease");
	}

	public function mine( dm : Bool, c : Card ){
		status = Mined;
		card = c;
		displayMine = dm;
		display();
	}


	public function enclume(){
		mcFX = game.fruit("anvil",mc._x,mc._y);
		game.anim.add( new AnimPlay(mcFX,ANIM_ANVIL,0,onEnclume) );
	}

	function onEnclume(){
		mcFX.removeMovieClip();
		mcFX = game.fruit("smokeAnvil",mc._x,mc._y);
		game.anim.add( new AnimPlay(mcFX,ANIM_SMOKE_ANVIL,0,rmFX) );
		if( status == Used )
			fruit.kill();
		disappear();
	}

	function rmFX(){
		mcFX.removeMovieClip();
	}

	public function vachette( wait : Int ){
		if( status == Used ){
			fruit.vachette(wait);
			status = Free;
			mcFX = game.fruit("smoke",mc._x,mc._y);
			mcFX.stop();
			game.anim.add( new AnimPlay(mcFX,ANIM_SMOKE,wait,rmFX) );
		}
	}

	/*
	public function victory( t : Team ){
		if( status == Used ) fruit.victory( t );
	}
	*/


}
