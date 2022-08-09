import Protocol.Const;
import mt.bumdum9.Lib;

class Boat {
	
	public var mc : flash.display.MovieClip;
	public var target : flash.display.Sprite;
	var path : Array<{ x : Int, y : Int }>;
	var pathPos : Float;
	var a : Float;
	var dir : Float;
	var speed : Float;
	var wait : Int;

	public var x : mt.flash.Volatile<Int>;
	public var y : mt.flash.Volatile<Int>;

	public var px : mt.flash.Volatile<Int>;
	public var py : mt.flash.Volatile<Int>;
	public var saving : Bool;
	public var locked : Bool;
	public var targetIsland : Protocol.MapIsland;
	public var movedDist : mt.flash.Volatile<Int>;
	public var lastDist : mt.flash.Volatile<Int>;
	
	var cloudColor:Int;
	
	public function new(b:{ x : Int, y : Int, move : Int }) {
		a = 0;
		dir = 0; speed = 0;
		mc = new McBoat();
		px = Const.BP(b.x);
		py = Const.BP(b.y);
		movedDist = b.move;
		lastDist = b.move;
		mc.x = b.x;
		x = b.x;
		mc.y = b.y;
		y = b.y;
		mc.stop();
		target = new flash.display.Sprite();
		target.visible = false;
		cloudColor = 0xC0ac6a;
	}
	
	public function setPath(p, i) {
		path = p;
		targetIsland = i;
		pathPos = 0;
		while( target.numChildren > 0 ) {
			var c : flash.display.MovieClip = cast target.getChildAt(0);
			if( target.parent == null || !target.visible )
				target.removeChild(c);
			else {
				c.gotoAndPlay("end");
				c.x = target.x;
				c.y = target.y;
				target.parent.addChild(c);
			}
		}
		
		if( p == null || p.length == 0 )
			target.visible = false;
		else {
			target.visible = true;
			if( i == null )
				target.addChild(new ui.Floater());
			else
				target.addChild(new ui.Flag());
			target.x = path[path.length - 1].x;
			target.y = path[path.length - 1].y;
		}
		mc.x = x;
		mc.y = y;
	}
	
	public function isMoving() {
		return path != null;
	}
	

	public function update( dt ) {
				
		
		a += 0.1;
		mc.rotation = Math.sin(a) * 4;
		
		if( path == null ) return;
		
		var move = (speed + 0.5) * 0.6 * Const.DIST_PREC;
		var ipos = Std.int(pathPos) + 1;
		while( ipos < path.length ) {
			var dx = path[ipos].x - path[ipos - 1].x;
			var dy = path[ipos].y - path[ipos - 1].y;
			var dist = Const.calculateDist(dx, dy, Main.inst.curWind);
			if( move < dist ) {
				pathPos += move / dist;
				break;
			}
			move -= dist;
			ipos++;
			pathPos++;
		}
		
		var ipos = Std.int(pathPos), inext = ipos + 1;
		if( ipos >= path.length - 1 ) {
			pathPos = ipos = inext = path.length - 1;
			speed *= 0.5;
			if( speed < 0.1 ) {
				speed = 0;
				mc.x = path[ipos].x;
				mc.y = path[ipos].y;
				setPath(null, null);
				locked = false; // auto unlock if we reach the end of the path
				return;
			}
		} else {
			speed *= 0.9;
			speed += dt * 0.1;
		}
		var p = pathPos - ipos;
		var tx = Std.int(path[ipos].x * (1 - p) + path[inext].x * p);
		var ty = Std.int(path[ipos].y * (1 - p) + path[inext].y * p);
		if( tx != x || ty != y ) {
			movedDist += Const.calculateDist(tx - x, ty - y, Main.inst.curWind);
			dir = Math.atan2(ty - y, tx - x);
			if( dir < 0 ) dir += Math.PI * 2;
			x = tx;
			y = ty;
			mc.x = x;
			mc.y = y;
		}
		var k = (Std.int(dir / (Math.PI / 8)) + 4) % 16 + 1;
		
		// prevent flipping
		wait++;
		if( k != mc.currentFrame ) {
			if( wait > 4 ) {
				mc.gotoAndStop(k);
				wait = -4;
			}
		} else if( wait > 0 )
			wait = 0;
			
			
		// FX
		if( Std.random(4)==0 ){
			var p = new mt.fx.Part(new SP());
			
			var dist = 20;
			var ddx =  Math.cos(dir + 3.14) * dist;
			var ddy =  Math.sin(dir + 3.14) * dist;
			

			//var col = Map.me.getPixelAt(300+Std.int(ddx), 200+Std.int(ddy));
			//cloudColor = Col.mergeCol(col, cloudColor, 0.05);
			
			p.root.graphics.beginFill(cloudColor);
			p.root.graphics.drawCircle(0, 0, 3+Std.random(5));
			
			var base = 0;
			if( Math.abs(Num.hMod(1.57-dir,3.14)) > 1.57 ) base = 2;
			Map.me.fxCloudLayers[base+Std.random(2)].addChild(p.root);
			

			var ec = 8;
			var x = mc.x + ddx + (Math.random()*2-1)*ec;
			var y = mc.y + ddy + (Math.random()*2-1)*ec + 7;
			p.setPos(x, y);
			

			p.vy = -(0.2 + Math.random() * 0.5);
			p.frict = 0.95 + Math.random() * 0.03;
			p.weight = 0.01 + Math.random() * 0.01;
			p.timer = 80+Std.random(40);
			p.fadeLimit = 30;
			p.fadeType = 2;
			p.setGround(p.y,0,0);
		
			new mt.fx.Spawn(p.root,0.04,false,true);
			
		}
			
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
}