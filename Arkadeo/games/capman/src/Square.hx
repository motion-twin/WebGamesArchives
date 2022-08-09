import mt.bumdum9.Lib;
using mt.bumdum9.MBut;
import Protocol;
import api.AKApi;
import api.AKProtocol;


class Square {
	
	public var skinId:Int;
	
	public var out:Bool;
	public var color:Int;

	public var door:Door;
	public var doorDir:Int;
	
	public var tag:Int;
	public var hdist:Int;
	public var htrack:Int;
	public var heat:Int;
	
	public var coin:EL;
	
	public var x:Int;
	public var y:Int;
	public var nei:Array<Square>;
	public var dnei:Array<Square>;
	
	var walls:Array<Int>;
	
	public function new(px,py) {
		x = px;
		y = py;
		nei = [];
		dnei = [];
		walls = [1, 1];
		tag = 0;
		heat = 0;
		out = false;
		skinId = 1;
	}

	public function getCenter() {
		return Square.getPos(x + 0.5, y + 0.5);
	}
	
	public function getId() {
		return x * Cs.YMAX + y;
	}
	
	public function getWall(di:Int) {
		if( di < 2 ) return walls[di];
		var nsq = dnei[di];
		if( nsq == null ) return 1;
		else return nsq.walls[di - 2];
	}
	
	public function isWallLimit(di:Int) {
		return dnei[di] == null;
	}
	
	public function setWall(di,n) {
		if( di < 2 ) 	walls[di] = n;
		else 			dnei[di].walls[di - 2] = n;
	}
	
	public function open(di:Int) {
		setWall(di, 0);
	}
	public function openOne() {
		var a = [];
		for( di in 0...4 ) {
			var nsq = dnei[di];
			if( nsq != null && getWall(di)>0 && !nsq.isBlock() ) a.push(di);
		}
		if( a.length == 0) return false;
		open( a[Game.me.rnd(a.length)] );
		return true;
	}
	
	public function getDoorScore() {
		// TEST ZONE
		var cur = this;
		for( di in 0...4 ) {
			cur = cur.dnei[di];
			if( cur == null || cur.isBlock() || cur.door != null ) return -10;
		}
		// SCORE
		var sum = 0;
		var cur = this;
		var di = 3;
		//
		for( k in 0...4 ) {
			var best = 0;
			var num = -1;
			
			for( i in 0...3 ) {
				if( cur.isBlock() ) return 0;
				
				// CHECK WALL
				if( cur.getWall(di)==1 ) {
					var score = [4,8,4][i];
					if( score > best ) best = score;
					num++;
				}
				
				// NEXT
				cur = cur.dnei[di];
				if( cur == null ) 	return 0;
				
				// TURN
				di = di + [1, 1, -1][i];
				if( di < 0 ) 	di += 4;
				if( di >= 4 ) 	di -= 4;
			}
			if( num > 0 ) best = best>>num;
			if( num == -1) best = -4;
			
			sum += best;
		}
		
		return sum;
	}
	
	public function getWallId() {
		var wid = 0;
		for( di in 0...4 )
			if( getWall(di) != 1 )
				wid += Std.int(Math.pow(2, di));
		return wid;
	}
	
	public function getDir(sq) {
		for( di in 0...4 )
			if( sq == dnei[di] )
				return di;
		return -1;
	}
	
	public function addCoin() {
		if( coin != null ) return;
		Game.me.coins++;
		
		coin = new EL();
		coin.goto("coin");
		Level.me.dm.add(coin, Level.DP_GROUND);
		
		var p = getCenter();
		coin.x = p.x;
		coin.y = p.y;
	}
	
	public function removeCoin(check) {
		if( coin == null ) return;
		coin.parent.removeChild(coin);
		coin  = null;
		Game.me.coins--;
		if(!check) return;
		AKApi.setProgression(1 - Game.me.coins / Game.me.coinMax);
		if( Game.me.coins == 0 ) Game.me.onLastCoin();
	}
	
	//
	var el:EL;
	public function initGfx() {
		el = new EL();
		var pos = Square.getPos(x, y);
		el.x = pos.x;
		el.y = pos.y;
		Level.me.walls.addChild(el);
		
		majGfx();
	}
	
	public function majGfx() {
		el.goto(getWallId()+skinId*16,0,0);
	}
	
	// FX
	public function fxTwinkle() {
		var mc = new gfx.LightTriangle();
		Level.me.dm.add(mc, Level.DP_FX);
		var p = new mt.fx.Part(mc);
		var pos = getCenter();
		p.setPos(pos.x + Math.random() * 24 - 12, pos.y + Math.random() * 24 - 12);
		p.setScale(0.5 + Math.random());
		p.weight = -(0.02 + Math.random() * 0.04);
		p.frict = 0.99;
		p.timer = 10 + Std.random(30);
		p.fadeLimit = p.timer >> 1;
		p.fadeType = 2;
		p.twist(10, 0.98);
		if(Std.random(2)==0)Filt.blur(p.root,2,2);
		
		var color = [0x00FF00, 0x00FFFF, 0x0088FF][Std.random(3)];
		Col.setColor(p.root, color);
		p.root.blendMode = flash.display.BlendMode.ADD;
		return p;
	}
	
	// TOOLS
	public function burstWall(di) {
		var nsq = dnei[di];
		open(di);
		majGfx();
		nsq.majGfx();
		
		var fr = Std.random(4);
		var d = Cs.DIR[di];
		var bp = getPos(x + 0.5 + d[0] * 0.5, y + 0.5 + d[1] * 0.5);
		var dd = Cs.DIR[(di + 1) % 4];
		var max = 5;
		
		for( i in 0...max ) {
			var el = new EL();
			el.goto(fr+skinId*6, "wall_parts");
			Level.me.dm.add(el, Level.DP_GROUND);
			
			var p = new mt.fx.Part(el);
			var sens = (i / (max - 1)) * 2 - 1;
			var rep = sens * (Cs.SQ-6)  * 0.5;
			
			p.setPos(bp.x+dd[0]*rep, bp.y+dd[1]*rep  );
			
			var speed = 0.5 + Math.random() * 2.5;
			var spread = 1.5 * Math.random();
			
			p.vx = d[0] * speed + dd[0] * spread;
			p.vy = d[1] * speed + dd[1] * spread;
			p.frict = 0.9;
			p.fitPix = true;
			p.timer = 100 + Std.random(50);
			p.fadeType = 2;
			
			fr = (fr + 1) % 4;
		}
	}
	
	// STATIC
	public static function getPos(px:Float,py:Float) {
		return {
			x:Cs.CX + px * Cs.SQ,
			y:Cs.CY + py * Cs.SQ,
		}
	}
		
	// TEST
	public function isBlock() {
		for( di in 0...4 )
			if( getWall(di) == 0 )
				return false;
		return true;
	}
	
	// DEV
	public function mark(color=0xFF0000) {
		var mc = new SP();
		mc.graphics.beginFill(color, 0.5);
		mc.graphics.drawRect(0, 0, Cs.SQ, Cs.SQ);
		var pos = getPos(x, y);
		Game.me.dm.add(mc, Game.DP_LEVEL);
		mc.x = pos.x;
		mc.y = pos.y;
	}
	
	public function showDist() {
		var f = Cs.getField();
		var pos = getPos(x, y);
		Level.me.dm.add(f, Level.DP_FX);
		f.x  = pos.x;
		f.y  = pos.y;
		f.text = "" + hdist;
	}
}


