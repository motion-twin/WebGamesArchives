import Pion;

enum Msg {
	Init;
	Set( x : Int, y : Int, dx : Int, dy : Int );
}

class Game implements MMGame<Msg> {

	var rootmanager : mt.DepthManager;
	public var dmanager : mt.DepthManager;
	public var first : Bool;
	var level : Level;
	var sx : Float;
	var sy : Float;
	var end : Bool;

	var pos : { x : Int, y : Int, dx : Int, dy : Int };
	var cursor : Pion;
	var lock : Bool;
	var root : flash.MovieClip;
	var plan1 : flash.MovieClip;
	var plan2 : flash.MovieClip;
	var web : flash.MovieClip;
	var target : { x : Int, y : Int };

	var scroll : flash.MovieClip;
	var bg : flash.MovieClip;
	public var anims : Array<{ update : Void -> Bool }>;

	function new( mc : flash.MovieClip ) {
		root = mc;
		rootmanager = new mt.DepthManager(root);
		scroll = rootmanager.empty(1);
		dmanager = new mt.DepthManager(scroll);
		bg = rootmanager.attach("bg",0);
		bg._x = bg._y = 150;
		plan1 = rootmanager.attach("plan1",0);
		plan2 = rootmanager.attach("plan2",0);
		web = rootmanager.attach("web",0);
		sx = Const.D * Const.SIZE;
		sy = Const.D * Const.SIZE;
		level = new Level(this);
		anims = new Array();
		lock = true;
		main();
		MMApi.lockMessages(false);
		var tanim = new haxe.Timer(5000);
		tanim.run = randomAnim;
	}

	public function initialize() {
		return Init;
	}

	public function onVictory( v : Bool ) {
		haxe.Timer.delayed(MMApi.gameOver,3000)();
	}

	public function onReconnectDone() {
		onTurnDone();
	}

	public function selectPos() {
		if( pos == null || lock )
			return;
		lock = true;
		MMApi.endTurn(Set(pos.x,pos.y,pos.dx,pos.dy));
	}

	function randomAnim() {
		level.all[Std.random(level.all.length)].playAnim();
	}

	function pan(mc:flash.MovieClip,m,f:Float) {
		var px = (Std.int(sx * f + m / 2 - 18) % m + m) % m;
		var py = (Std.int(sy * f + m / 2 + 3) % m + m) % m;
		mc._x = -px;
		mc._y = -py;
	}


	public function main() {

		var dx = (level.maxX - level.minX - 4) * Const.SIZE;
		var dy = (level.maxY - level.minY - 4) * Const.SIZE;
		var mx = (level.minX + level.maxX) / 2 * Const.SIZE;
		var my = (level.minY + level.maxY) / 2 * Const.SIZE;
		var tx = (root._xmouse / 300 - 0.5) * dx + mx;
		var ty = (root._ymouse / 300 - 0.5) * dy + my;
		if( target != null ) {
			tx = target.x * Const.SIZE;
			ty = target.y * Const.SIZE;
		}
		var p = Math.pow(0.5,mt.Timer.tmod);
		sx = sx * p + (1 - p) * tx;
		sy = sy * p + (1 - p) * ty;

		scroll._x = -sx + 150;
		scroll._y = -sy + 150;

		pan(plan1,300,0.5);
		pan(plan2,300,0.7);
		pan(web,800,1);

		var i = 0;
		while( i < anims.length ) {
			if( !anims[i].update() )
				anims.splice(i,1);
			else
				i++;
		}

		pos = null;
		if( !lock ) {
			var px = Std.int(scroll._xmouse / Const.SIZE + 0.5);
			var py = Std.int(scroll._ymouse / Const.SIZE + 0.5);
			for( i in 0...5 ) {
				if( (pos = level.lookup(px-i,py)) != null )
					break;
				if( i == 0 )
					continue;
				if( (pos = level.lookup(px+i,py)) != null )
					break;
				if( (pos = level.lookup(px,py-i)) != null )
					break;
				if( i == 0 )
					continue;
				if( (pos = level.lookup(px,py+i)) != null )
					break;
			}
			cursor.visible( pos != null );
			cursor.moveTo(pos.x,pos.y);
			cursor.updateGlow(Math.atan2(-pos.dy,-pos.dx));
		}
	}

	public function onTurnDone() {
		lock = !MMApi.isMyTurn() || !MMApi.hasControl();
		if( end )
			lock = true;
		dmanager.over(cursor.mc);
	}

	function onAnimDone() {
		var v = level.checkVictory();
		if( v.n == 3 )
			MMApi.setInfos("<b>Attention !</b>");
		else {
			MMApi.setInfos("");
			if( v != null && v.n >= 4 ) {
				MMApi.victory(v.k == PMine);
				end = true;
				if( target == null )
					target = { x : v.x, y : v.y };
				for( i in 0...v.n ) {
					var p = level.tbl[v.x][v.y];
					p.loopAnim();
					if( v.h )
						v.x++;
					else
						v.y++;
				}
			}
		}
		if( !end )
			target = null;
		MMApi.lockMessages(false);
	}

	public function onMessage( mine : Bool, msg : Msg ) {
		switch( msg ) {
		case Init:
			first = mine;
			if( mine )
				MMApi.setColors(0x00E89C,0xD6370A);
			else
				MMApi.setColors(0xD6370A,0x00E89C);
			cursor = new Pion(this,Const.D,Const.D,PMine);
			cursor.initGlow();
			cursor.mc.onRelease = selectPos;
			cursor.visible(false);
		case Set(x,y,dx,dy):
			var p = level.set(x,y,mine);
			MMApi.lockMessages(true);
			if( mine && MMApi.hasControl() ) {
				cursor.visible(false);
				onAnimDone();
			} else {
				p.setPos(dx*Const.D+Const.D,dy*Const.D+Const.D);
				p.moveTo(x,y);
				target = { x : x, y : y };
				p.onMoveDone = onAnimDone;
			}
		}
	}

}
