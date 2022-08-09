import Protocole;
import mt.bumdum9.Lib;
import Board;

class Ball extends SP {//}
	
	public static var SIZE = 20;
	//public static var FILTERS =  [ new flash.filters.DropShadowFilter(2, 45, 0, 1, 0, 0, 100) ];
	public static var FILTERS =  [  ];

	public var bubble:Bool;
	public var ghost:Bool;
	public var flag:Int;
	public var generic:Bool;
	public var grey:Bool;
	
	public var nei:Array<Ball>;
	public var group:BallGroup;
	public var fall:Int;
	public var hits:Int;
	public var score:Int;
	
	public var px:Int;
	public var py:Int;
	public var type:BallType;
	public var board:Board;
	public var data:DataBall;

	//public var el:mt.pix.Element;
	public var el:GameIcons;
	public var box:SP;
		
	public var temp:Float;

	
	public function new(b) {
		super();
		board = b;
		board.dm.add(this, Board.DP_BALLS);
		
		bubble = false;
		ghost = false;
		generic = false;
		grey = false;
		flag = 0;
		hits = 0;

		
		px = 0;
		py = 0;
		
		filters = FILTERS;
		
		//el = new mt.pix.Element();
		el = new GameIcons();
		el.x = -SIZE >> 1;
		el.y = -SIZE >> 1;
		el.graphics.beginFill(0, 0);
		el.graphics.drawRect(0, 0, SIZE, SIZE);
		
		box = new SP();
		addChild(box);
		box.addChild(el);
		
	}
	
	// FX
	var fxRadiate:mt.fx.Radiate;
	public function setRadiate(fl:Bool) {
		
		if ( fl ) 						fxRadiate = new mt.fx.Radiate(el, 0.12);
		else if (fxRadiate != null )	fxRadiate.kill();
		
		
	}
	public function fxSpawn() {
		var e = new mt.fx.Flash(this);
		e.glow(4, 8);
	}
		
	public function fxIceShards() {
		var max = 8;
		for ( i in 0...max) {
			var mc = new McCrystal();
			var p = Game.me.getPart(mc);
			var cx = Math.random();
			var cy = Math.random();
			var pos = getGlobalPos(cx, cy);
			p.setPos(pos.x, pos.y);
			p.weight = 0.05 + Math.random() * 0.05;
			p.timer = 10 + Std.random(30);
			p.twist(6, 0.98);
			p.setScale(0.1 + Math.random() * 0.3);
			p.fadeType = 2 ;
			var pow = 1;
			p.vx = (cx - 0.5) * pow;
			p.vy = (cy - 0.5) * pow;
		}
	}
	public function fxDrop() {
		for ( i in 0...4 ) {
			var p = Game.me.getPart(new FxFluo());
			var pos = getGlobalPos(Math.random(), Math.random());
			p.setPos(pos.x, pos.y);
			p.weight = 0.05 + Math.random() * 0.1;
			p.timer = 10 + Std.random(20);
			p.fadeType = 2;
			p.setScale(0.25 + Math.random() * 0.25);
			p.vy = -Math.random() * 0.25;
		}
	}
	public function fxActive() {
		var e = new mt.fx.Flash(this, 0.02);
		e.glow(3, 8);
		e.curve(0.5);
	}
	//
	public function setType(t:BallType) {
		type = t;
		data = Data.BALLS[Type.enumIndex(type)];
		switch(type) {
			case TURNIP :		if ( board.hero.have(TURNIP_UP) ) generic = true;
			case MAGIC_DROP :	generic = true;

			default :
		}
		
		
		/// GFX
		draw(el,type,hits);
		
	}
	static public function draw(el:MC,type:BallType,hits:Int) {
	
	

		Col.setPercentColor(el, 0,0);
		el.filters = [];

		switch(type){
			case FROZEN(ft):
				el.gotoAndStop(1 + Type.enumIndex(ft) + hits);
				

				Filt.grey(el, null, -50, { r: -100, g:100, b:120 } );
							
				var fl = new flash.filters.DropShadowFilter(3, 45, 0xFFFFFF, 1, 0, 0, 4, 1, true);
				var a = el.filters;
				a.push(fl);
				el.filters = a;
				
				//Filt.glow(el, 8, 1.5, 0x0088FF,true );
				
				Filt.glow(el, 3, 5, 0x0088FF,true );
				Filt.glow(el, 2, 12, 0xDDDDFF );
				Filt.glow(el, 2, 12, 0x0066FF );
				
				
				
			default :
				el.gotoAndStop(1 + Type.enumIndex(type) + hits);
		}
		

		
		
	}
	public function selfDraw(type) {
		draw(el, type, hits);
	}
	
	
	public function setPos(px,py) {
		this.px = px;
		this.py = py;
		updatePos();
	}
	public function updatePos() {
		gotoPos(px, py);
	}
	public function gotoPos(gx,gy) {
		x = (gx+0.5) * SIZE;
		y = (gy+0.5) * SIZE;
	}
	
	// TOOLS
	/*
	public function isFrozen() {
		switch(type) {
			case FROZEN_SWORD, FROZEN_SHIELD, FROZEN_HEAL, FROZEN_HAMMER : 	return true;
			default :	return false;
		}
	}
	*/
	public function isSword() {
		switch(type) {
			case SWORD, SWORD_RED : 	return true;
			default :	return false;
		}
	}
	public static function isAttack(type) {
		switch(type) {
			case SWORD, SWORD_RED, AXE, HAMMER, BOW : return true;
			default :return false;
		}
	}
	public function isMagic() {
		switch(type) {
			case ICE_BLAST, MECHA_CRYSTAL : return true;
			default :return false;
		}
	}
	public function isJar() {
		switch(type) {
			case JAR, JAR_CRACKED, JAR_POISON : return true;
			default : return false;
		}
	}
	public function isFrozen() {
		switch(type) {
			case FROZEN(t) : return true;
			default : return false;
		}
	}
	public function isPlayable() {
		if ( grey ) 		return false;
		return data.play;
	}
	
	public function get8Nei() {
		var a = [];
		for ( b in board.balls ) {
			if ( b == this ) continue;
			if ( Math.abs(b.px - px) <= 1 && Math.abs(b.py - py) <= 1) a.push(b);
		}
		return a;
	}
	public function get4Nei() {
		var a = [];
		for ( b in board.balls ) {
			if ( b == this ) continue;
			if ( (Math.abs(b.px - px) + Math.abs(b.py - py)) == 1) a.push(b);
		}
		return a;
	}
	public function getGlobalPos(dx=0.5,dy=0.5) {
		var pos = board.getGlobalBallPos(px, py);
		pos.x += dx * SIZE;
		pos.y += dy * SIZE;
		return pos;
	}
	
	// SHORTCUT
	public function freeze() {
		switch(type) {
			case FROZEN(ft):
			default :
				setType(FROZEN(type));
				new mt.fx.Flash(this, 0.2);
				//fxIceShards();
		}
		
		
		
	}
	public function isAlive() {
		return data.play && type != STONE;
	}
	
	// MODIFY
	public function morph(bt) {
		setType(bt);
		new mt.fx.Flash( this, 0.1, 0xFF00FF);
	}
	
	
	// KILL
	public function petrify() {
		setType(STONE);
	}
	public function damage(dam:Damage) {
		
		switch(type) {
			case BOMB :
				if ( dam!=null && dam.source == Game.me.monster )
					Game.me.monster.incLife( -5);
				
			case JAR :
				if ( board.hero.have(ARMOURED_CERAMIC) && hits == 0 ) {
					hits++;
					selfDraw(type);
					return ;
				}
			case MECHA_BOMB :
				board.breathSpawn(5, MECHA_CRYSTAL);
				
			case MECHA_CRYSTAL, MECHA_SHARD :
				if ( board.hero.have(MECHA_SURGE) ){
					Game.me.monster.incLife( -1);
				}
				
			case ORI_SHIELD :
				fxActive();
				return ;
				
			default :
		}
		
		
		if ( board.hero.haveStatus(STA_GHOST_FORM) && !ghost )
			ghostify();
		else
			explode();
		
	}
	public function ghostify() {
		ghost = true;
		board.ghosts.push(this);
	}
	public function blast() {
		switch(type) {
			case STONE :
				hits++;
				selfDraw(type);
				var max = 4;
				if( hits == 2 ){
					max = 12;
					kill();
				}
				for ( i in 0...max ) {
					var mc = new gfx.SmallStone();
					mc.gotoAndStop(Std.random(3) + 1);
					var p = Game.me.getPart(mc);
					var pos = getGlobalPos(Math.random(), Math.random());
					p.setPos(pos.x, pos.y);
					p.weight = 0.05 + Math.random() * 0.05;
					p.fadeType = 2;
					p.timer = 15 + Std.random(20);
					p.setScale(0.5 + Math.random() * 1);
					p.vx = (Math.random() * 2 - 1) * 0.8;
					p.vy = -Math.random() * 2;
					p.frict = 0.98;
				}
				
			case FROZEN(t) :
				board.unfreeze++;
				
				unfreeze(t);
			default : return false;
		}
		return true;
	}
	public function unfreeze(t) {
		setType(t);
		fxIceShards();
		new mt.fx.Flash(this);
	}
	
	public function slice(max) {
		var a = mt.bumdum9.Tools.slice(this, max);
		kill();
		for ( p in a ) {
			board.dm.add(p.root, Board.DP_FX);
		}
		return a;
	}
	public function explode() {
		kill();
		var p = new mt.fx.ShockWave(16, 36, 0.1);
		p.setPos(x, y);
		p.curveIn(0.5);
		p.root.blendMode = flash.display.BlendMode.ADD;
		board.dm.add(p.root, 3);
		
	}
	public function combine() {
		
		// STATS
		var bs = Game.me.ballStats;
		var id = Type.enumIndex(type);
		switch(type) {
			case FROZEN(bt): id = Type.enumIndex(_FROZEN);
			default:
		}
		if ( bs[id] == null ) {
			bs[id] = { n:0 };
			bs[id].n = 0;
		}
		bs[id].n++;
		
		
		// COMBINE
		switch(type) {
			case FROZEN(t) :
				blast();
				return false;
				
			case BUD :
				var pos = getGlobalPos();
				var max = 32;
				var cr = 6;
				for ( i in 0...max ) {
					var a = (i / max) * 6.28;
					var speed = Math.random() * 3;
					var mc = new fx.Flower();
					mc.gotoAndStop(Std.random(mc.totalFrames) + 1);
					var p = Game.me.getPart(cast mc);
					
					p.weight = Math.random() * 0.2;
					p.vx = Math.cos(a) * speed;
					p.vy = Math.sin(a) * speed;
					
					p.setPos(pos.x + p.vx * cr, pos.y + p.vy * cr);
					p.frict = 0.98;
					p.fadeType = 2;
					p.timer = 10 + Std.random(30);
				}
				
				var onde = new mt.fx.ShockWave(80, 100);
				onde.setPos(pos.x, pos.y);
				Game.me.dm.add(onde.root, Scene.DP_FX);
				onde.curveIn(0.5);
				onde.root.blendMode =  flash.display.BlendMode.ADD;
			
			case ORI_HELMET :
				fxActive();
				return false;
				
			default :
		}
		
	
		if ( data.eternal && board.balls.length > 1 ) return false;
		kill();
		return true;
		
	}
	public function kill() {

		// board.hero.incBreath(1);
		
		var mon = board.hero.game.monster;
		if ( mon != null ) mon.investment++;
		if ( ghost ) board.ghosts.remove(this);
		if( parent!=null )parent.removeChild(this);
		board.balls.remove(this);
	}
	
	
	
//{
}




