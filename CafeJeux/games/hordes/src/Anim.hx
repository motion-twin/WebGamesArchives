import Common;
import mt.Timer;

interface Anim {
//	public var mc : flash.MovieClip;
	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;
	public function play() : Bool;
	public function clean() : Void;
	public var fl_skip : Bool;
}

typedef TurnInter =  {>flash.MovieClip, title:flash.TextField, city:flash.TextField, turn:flash.TextField, turnXL:flash.TextField, cpt:Float}

class TurnInfo implements Anim {

	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;
	public var x(default,null) : Int;
	public var y(default,null) : Int;
	public var mc : TurnInter;
	public var game : Game;
	public var fl_skip : Bool;

	public function new(game,currenTurn : Int ) {
		this.game = game;

		mc = cast game.dm.attach("mcTurn",Const.DP_INVISIBLE);
		mc._x = Math.floor(Const.WIDTH*0.5);
		mc._y = mc._x;
		mc._xscale = 120;
		mc._yscale = 120;
		mc.filters = [ new flash.filters.GlowFilter(0x0, 0.4, 40,40, 2) ];

		if( currenTurn > game.zombieTurn ) {
			var min = currenTurn - game.zombieTurn;
			mc.title.text = if(min>1) Lang.TURN_INFO[1] else Lang.TURN_INFO[0];
			mc.turn.text = if(min>=10) Std.string(min) else "";
			mc.turnXL.text = if(min<10) Std.string(min) else "";
		}
		else {
			mc.title.text = Lang.TURN_INFO[2];
			mc.turn.text = Std.string(60-(game.zombieTurn-currenTurn));
			mc.turnXL.text = "";
		}

		mc.city.text = "";

		mc.cpt = 0;
		mc._visible = false;
	}

	public function play() {
		mc._visible = true;
		var zoom = 20;
		mc.cpt+=0.15*Timer.tmod;
		var s = if(mc.cpt>=Math.PI*0.5 ) 0 else (zoom - zoom*Math.sin(mc.cpt));
		mc._xscale = 100 + s;
		mc._yscale = mc._xscale;
		if ( mc.cpt>=1.5*Math.PI ) {
			var strength = Math.sin(mc.cpt-1.5*Math.PI)*15;
			mc.filters = [ new flash.filters.BlurFilter(strength, strength*1.2, 1.0) ];
			mc._alpha = Math.cos(mc.cpt-1.5*Math.PI)*100;
		}
		return mc.cpt>=2.2*Math.PI;
	}

	public function clean() {
		mc.removeMovieClip();
		mc = null;
	}
}

typedef TurnGInter =  {>flash.MovieClip,cpt:Float}

class TurnGradient implements Anim {

	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;
	public var x(default,null) : Int;
	public var y(default,null) : Int;
	public var mc : TurnGInter;
	public var game : Game;
	public var fl_skip : Bool;

	public function new(game ) {
		this.game = game;

		mc = cast game.dm.attach("mcGradient",Const.DP_INTERF);
		mc._x = Const.WIDTH*0.5;
		mc._y = Const.WIDTH*0.5;
		mc._alpha = 0;
//		mc._rotation = Std.random(4)*90;
		mc.cpt = 0;
		mc.gotoAndPlay(1);
	}

	public function play() {
		mc.cpt+=0.06*Timer.tmod;
		mc._alpha = Math.sin(mc.cpt)*70;

		return mc.cpt>=Math.PI*2;
	}

	public function clean() {
		mc.removeMovieClip();
		mc = null;
	}
}

typedef OppTurnInter =  {>flash.MovieClip, field:flash.TextField }

class OppTurnAnim implements Anim {
	public static var ZOOM = 5;

	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;
	public var x(default,null) : Int;
	public var y(default,null) : Int;
	public var mc : OppTurnInter;
	public var game : Game;
	public var fl_skip : Bool;

	var fl_roll	: Bool;
	var cpt		: Float;

	public function new(game ) {
		this.game = game;

		mc = cast game.dm.attach("oppTurn",Const.DP_INVISIBLE);
		mc._x = Const.WIDTH * 0.5;
		mc._y = Const.WIDTH * 0.5;

//		mc.field.text = Lang.CUSTOM[3];
		mc.field.text = "";
		cpt = 0;

		mc._alpha = 0;
	}

	public function play() {
		if( fl_roll ) {
			roll();
			if( cpt>=Math.PI*0.5 ) {
				mc.stop();
				mc._alpha = 100;
				mc.filters = new Array();
				cpt = 0;
				return true;
			}
		}
		else {
			unroll();
			if( cpt>=Math.PI*0.5 ) {
				mc.stop();
				mc._alpha = 0;
				mc.filters = new Array();
				cpt = 0;
				return true;
			}
		}

		return false;
	}

	function roll() {
		cpt+=0.05;
		var s = Math.cos(cpt)*20;
		mc.filters = [ new flash.filters.BlurFilter(s,s,1) ];
		mc._alpha = 100*Math.sin(cpt);
	}

	function unroll() {
		cpt+=0.1;
		var s = Math.sin(cpt)*10;
		mc.filters = [ new flash.filters.BlurFilter(s,s,1) ];
		mc._alpha = 100*Math.cos(cpt);
	}

	public function startRoll() {
		mc.gotoAndPlay(1);
		fl_roll = true;
		cpt = 0;
		mc._alpha = 0;
	}

	public function startUnroll() {
		mc.gotoAndPlay(1);
		fl_roll = false;
		cpt = 0;
		mc._alpha = 100;
	}

	public function clean() {
//		mc.removeMovieClip();
//		mc = null;
	}

}

typedef OptionInter = {
	>flash.MovieClip,
	icon : flash.MovieClip,
	name : {
		>flash.MovieClip,
		field	: flash.TextField,
	},
}

class OptionAnim implements Anim {

	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;
	public var x(default,null) : Int;
	public var y(default,null) : Int;
	public var mc : OptionInter;
	public var game : Game;
	public var fl_skip : Bool;

	var frame	: Float;
	var cpt		: Float;

	public function new(game,o) {
		this.game = game;
		frame = 0;

		mc = cast game.dm.attach("optionAnim",Const.DP_INVISIBLE);
		mc._x = Const.WIDTH*0.5;
		mc._y = Const.WIDTH*0.5;
		mc._visible = false;
		mc.icon.gotoAndStop( o+1 );
		mc.name.field.text = Lang.ACTION_NAME[o];
		cpt = 0;
	}

	public function play() {
		if( !mc._visible ) mc._visible = true;
		cpt+=0.05*Timer.tmod;
		frame+=Timer.tmod;
		while( frame>=1 ) {
			mc.nextFrame();
			frame--;
		}
		if ( cpt>=Math.PI*0.5 ) {
			mc._alpha = Math.cos(cpt-Math.PI*0.5)*100;
		}

		return cpt>=Math.PI;
	}

	public function clean() {
		mc.removeMovieClip();
		mc = null;
	}

}

typedef DoorInter = {>flash.MovieClip, small:flash.TextField, title:flash.TextField }

class MidnightAnim implements Anim {

	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;
	public var x(default,null) : Int;
	public var y(default,null) : Int;
	public var mc : DoorInter;
	public var game : Game;
	public var end : Bool;
	public var fl_skip : Bool;

	var plasma		: PlasmaBg;
	var cpt			: Float;
	var fl_shake	: Bool;

	public function new(game) {
		end = false;
		this.game = game;

		mc = cast game.dm.attach("anim_midnight",Const.DP_TOP);
		mc._x = Const.WIDTH*0.5;
		mc._y = Const.WIDTH*0.5;
		mc.small.text = Lang.CUSTOM[0];
		mc.title.text = Lang.CUSTOM[4];
		mc._alpha =0;
		fl_shake = false;
		cpt = 0;
	}

	public function play() {
		if ( cpt<=Math.PI*0.5 ) {
			mc._alpha = Math.sin(cpt)*100;
		}
		if ( cpt>=Math.PI*0.3 && !fl_shake ) {
			fl_shake = true;
			game.shake(2, 0.05);
		}
		if ( cpt>=Math.PI*1.5 ) {
			mc._alpha = Math.sin(cpt-Math.PI)*100;
		}
		cpt+=0.085*Timer.tmod;
		return cpt>=Math.PI*2;
	}

	public function clean() {
		mc.removeMovieClip();
		mc = null;
	}

}

typedef InvasionInter = {>flash.MovieClip, step : Int, maxStep : Int, ibg:flash.MovieClip, name: flash.TextField }

class Invasion implements Anim {

	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;
	public var x(default,null) : Int;
	public var y(default,null) : Int;
	public var mc : InvasionInter;
	public var game : Game;
	public var end : Bool;
	public var fl_skip : Bool;

	public function new(game) {
		end = false;
		this.game = game;

		mc = cast game.dm.attach("invasion",Const.DP_INVISIBLE);
		mc._y = 150;
		mc._x = 150;
		mc.ibg._alpha = 0.0;
		mc.useHandCursor = false;
		mc.maxStep = 40;
		mc.step = 0;
		mc.name.selectable = false;
	}

	public function play() {
		if( !end ) {
			mc._xscale = 100 + mc.step * 4;
			mc._yscale = 100 + mc.step * 4;
			mc.ibg._xscale = 100;
			mc.ibg._yscale = 100;
			mc.ibg._alpha += 2;
		} else {
			if( mc.step >= Std.int( mc.maxStep / 2 ) ) {
				mc._alpha -= 5;
			}
		}

		if( mc.step++ >= mc.maxStep ) {
			if( end )
				return true;
			else {
				mc.step = 0;
				end = true;
			}
		}
		return false;
	}

	public function clean() {
		mc.removeMovieClip();
		mc = null;
	}

}

class CellAnim implements Anim {

	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;
	public var x(default,null) : Int;
	public var y(default,null) : Int;
	public var mc : flash.MovieClip;
	public var game : Game;
	public var fl_skip : Bool;
	var fl_fadeUp : Bool;

	public function new(game,baseMc, ?fl_fadeUp=true) {
		this.game = game;
		this.fl_fadeUp = fl_fadeUp;
		mc = cast game.dm.attach("cellAnim",Const.DP_INVISIBLE);
		mc._x = baseMc._x;
		mc._y = baseMc._y;
		mc._xscale = baseMc._xscale;
		mc._yscale = baseMc._yscale;
		mc._alpha = if(fl_fadeUp) 0 else 100;
		mc._visible = false;
	}

	public function play() {
		if( !mc._visible ) mc._visible = true;

		if ( fl_fadeUp ) {
			mc._alpha += 5*Timer.tmod;
		}
		else {
			mc._alpha -= 5*Timer.tmod;
		}
		return if(fl_fadeUp) (mc._alpha>=100) else (mc._alpha<=0);
	}

	public function clean() {
		mc.removeMovieClip();
		mc = null;
	}
}


class CellSwitch implements Anim {

	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;
	public var game : Game;
	public var fl_skip : Bool;
	var anim		: { >flash.MovieClip, from:flash.MovieClip, to:flash.MovieClip };
	var cell		: Cell;
	var frame		: Float;

	public function new(game, cell:Cell, from:Int, to:Int) {
		this.cell = cell;
		this.game = game;
		frame = 0;
		anim = cast cell.mc.switchAnim;

		cell.mc.hex._visible = true;
		anim._visible = false;

		anim.gotoAndStop(1);
		anim.from.gotoAndStop(from);
		anim.to.gotoAndStop(to);
	}

	public function play() {
		frame+=Timer.tmod;
		cell.mc.hex._visible = false;
		anim._visible = true;
		while( frame>=1 ) {
			anim.nextFrame();
			frame--;
		}
		return anim._currentframe>=anim._totalframes;
	}

	public function clean() {
		anim.stop();
		cell.mc.hex._visible = true;
		anim._visible = false;
	}
}

class PlasmaBg implements Anim {
	public var onEnd	: Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;
	public var game		: Game;
	public var fl_skip : Bool;
	var root			: flash.MovieClip;
	var plasma			: mt.bumdum.Plasma;
	var cpt				: Float;
	var col				: Int;

	public function new(game,mc,c:Int) {
		return;
		this.game = game;
		root = mc;
		col = c;
		cpt = 0;
//		var bg = root.attachMovie("oppTurn","bg",Const.UNIQ++);
//		bg._x = Const.WIDTH*0.5;
//		bg._y = Const.WIDTH*0.5;
		plasma = new mt.bumdum.Plasma(root.createEmptyMovieClip("cont",Const.UNIQ++), Const.WIDTH, Const.WIDTH, 1.0);
		plasma.filters.push( new flash.filters.BlurFilter(10,5,1) );
		plasma.filters.push( new flash.filters.BlurFilter(10,5,1) );
		for (i in 0...10) {
			addSeed();
		}
		root._alpha = 0;
//		root.blendMode = "screen";
	}

	public function play() {
		if ( cpt<Math.PI*0.5 && Std.random(5)==0 ) {
			addSeed();
		}
		cpt+=0.03*Timer.tmod;
		root._alpha = Math.sin(cpt)*100;
		plasma.update();
		return cpt>=Math.PI;
	}

	function addSeed(?minScale=20) {
		var mc = root.attachMovie("fx_plasma_ball", "fx_"+Const.UNIQ, Const.UNIQ);
		Const.UNIQ++;
//		mc._x = Const.WIDTH*0.5;
//		mc._y = Const.WIDTH*0.5;
//		mc._xscale = 100 * (Std.random(2)*2-1);
//		mc._yscale = 100 * (Std.random(2)*2-1);
		mc._x = Std.random(Const.WIDTH);
		mc._y = Std.random(Const.WIDTH);
		mc._xscale = 120 * (Std.random(2)*2-1);
		mc._yscale = (Std.random(90)+minScale) * (Std.random(2)*2-1);
		mc._alpha = Std.random(30)+20;
		if ( Std.random(2)==0 ) {
			mc.smc.gotoAndStop(1);
		}
		else {
			mc.smc.gotoAndStop(col+1);
		}
		plasma.drawMc(mc);
		mc.removeMovieClip();
	}

	public function clean() {
		plasma.kill();
		root.removeMovieClip();
	}
}
