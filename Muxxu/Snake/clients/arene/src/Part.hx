import Protocole;
import mt.bumdum9.Lib;

class Part
{//}

	public static var POOL:Array<Part> = [];
	public static var INIT_ID = 0;

	public var initId:Int;
	public var stageOut:Bool;
	public var weightSleep:Bool;

	public var x:Float;
	public var y:Float;
	public var z:Float;
	
	public var vx:Float;
	public var vy:Float;
	public var vz:Float;
	
	public var frict:Float;
	public var frictBounceXY:Float;
	public var frictBounceZ:Float;
	
	public var ray:Float;
	public var weight:Float;
	
	public var timer:Null<Int>;
	public var sleep:Null<Int>;
	public var fadeType:Int;
	public var fadeLimit:Int;
	
	public var shade:flash.display.Sprite;
	public var sprite:pix.Sprite;
	
	public var onGroundBounce:Void->Void;

	public var backPool:Array<Dynamic>;
	public var link:Part;
	
	public function new() {
		link = this;
		//NEW_NUM++;
		sprite = new pix.Sprite();
		pix.Sprite.all.remove(sprite);
		backPool = POOL;
		init();
	}
	public function init() {
		
		initId = INIT_ID++;
		
		//
		x = 0;
		y = 0;
		z = 0;
		vx = 0;
		vy = 0;
		vz = 0;
		weight = 0;
		frict = 1;
		ray = 0;
		stageOut = false;
		frictBounceXY = 0.5;
		frictBounceZ = 0.75;
		fadeType = 0;
		fadeLimit = 10;
		weightSleep = false;
		
		//
		shade = null;
		onGroundBounce = null;
		timer = null;
		sleep = null;
		
		// SPRITE
		//sprite = new pix.Sprite();
		sprite.clear();
		pix.Sprite.all.push(sprite);
		
		
		Game.me.parts.push(this);
	}
	static public function get() {
		if( POOL.length == 0 ) return new Part();
		var p = POOL.pop();
		p.init();
		return p;
	}
	
	
	public function update() {
		if ( sleep != null ) {
			if ( sleep-- <= 0 ){
				sleep = null;
				sprite.visible = true;
				if( shade != null ) shade.visible = true;
				if( sprite.anim != null && sprite.anim.playSpeed == 0 ) sprite.anim.play();
			}
			return;
		}
		
		x += vx;
		y += vy;
		
		vx *= frict;
		vy *= frict;
		
		if ( !weightSleep ) {
			z += vz;
			
			vz *= frict;
			if ( z > -ray ) {
				groundBounce();
				z = -ray;
				vz *= -frictBounceZ;
				vx *= frictBounceXY;
				vy *= frictBounceXY;
				if ( Math.abs(vz) < weight * 3 ) {
					vz = 0;
					weightSleep = true;
				}
			}else {
				vz += weight;
			}
		}
		
		checkBorderBounce();
		
		
		
		updatePos();
		if ( timer != null ) {
			timer --;
			if ( timer <= fadeLimit ) {
				var c = timer / fadeLimit;
				switch(fadeType) {
					case 0 :
					case 1 :
						sprite.alpha = c;
					case 2 :
						sprite.scaleX = sprite.scaleY = c;
					
				}
			}
			if( timer < 0 ) timeUp();
		}

	}
	
	public function updatePos() {
		sprite.x = x;
		sprite.y = y + z;
		sprite.pxx();
		if ( shade != null) {
			var cz = 0.25;
			shade.x = x+2 - z*cz;
			shade.y = y+2 - z*cz;
			if ( stageOut ) {
				shade.x -= Stage.me.root.x;
				shade.y -= Stage.me.root.y;
			}
		}
	}
	public function timeUp() {
		kill();
	}
	
	function checkBorderBounce() {
		if ( x < ray || x > Stage.me.width - ray ) {
			vx *= -frictBounceZ;
			x = Num.mm( ray, x, Stage.me.width - ray);
		}
		if ( y < ray || y > Stage.me.height - ray ) {
			vy *= -frictBounceZ;
			y = Num.mm( ray, y, Stage.me.height - ray);
		}
	}
	public function launch( a:Float, speed:Float, nvz:Float ) {
		vx = Snk.cos(a) * speed;
		vy = Snk.sin(a) * speed;
		vz = nvz;
		weightSleep = false;
	}
	
	// ON
	public function groundBounce() {
		if( onGroundBounce!=null ) onGroundBounce();
	}
	
	// COMMAND
	public function dropShade(bmpShape = true) {
		
		if ( bmpShape ) {
			var sh = new pix.Element();
			sh.drawFrame( sprite.currentFrame );
			Col.setPercentColor(sh, 1, 0);
			shade = sh;
		}else {
			shade = new flash.display.Sprite();
			shade.graphics.beginFill(0);
			shade.graphics.drawCircle(0, 0, ray);
		}
		Stage.me.shadeLayer.addChild(shade);
		
	}
	public function setPos(nx, ny, ?nz) {
		x = nx;
		y = ny;
		if ( nz != null ) z = nz;
		updatePos();
	}
	public function setSleep(n) {
		sleep = n;
		sprite.visible = false;
		if( shade != null ) shade.visible = false;
	}
	
	public function removeShade() {
		shade.parent.removeChild(shade);
		shade = null;
		
	}
	// TOOLS
	public function randMirror() {
		var sc = 1;
		sprite.scaleX = (Std.random(2) * 2 - 1) * sc;
		sprite.scaleY = (Std.random(2) * 2 - 1) * sc;
	}
	
	// FX
	public function blink(n) {
		//return; BUG
		var c = 0.0;
		if ( Game.me.gtimer % (n * 2) < n ) c = 1;
		Col.setPercentColor(sprite, c, 0xFFFFFF);
	}
	
	//KILL
	public function kill() {
		Game.me.parts.remove(this);
		if( shade!= null && shade.parent != null ) shade.parent.removeChild(shade);
		//if( sprite.parent != null ) sprite.parent.removeChild(sprite);
		sprite.kill();
		backPool.push(this);
	}
	
	
	
	// DEBUG
	public function mark(color = 0xFF0000) {
		var mark = new flash.display.Sprite();
		sprite.addChild(mark);
		mark.graphics.beginFill(color);
		mark.graphics.drawCircle(0, 0, ray);
	}
	
//{
}












