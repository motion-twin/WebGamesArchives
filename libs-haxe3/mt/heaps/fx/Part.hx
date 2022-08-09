package mt.heaps.fx;
import h2d.Drawable;

class Part<T:h2d.Drawable> extends mt.fx.Fx 
{
	public var fitPix:Bool;			// fit to pixels
	public var x:Float;
	public var y:Float;
	public var vx:Float;
	public var vy:Float;
	public var vr:Float;			// rotation speed
	public var sfr:Null<Float>;		//scale friction
	public var weight:Float;
	public var frict:Float;			//movement friction
	public var rfr:Float;			//rotation friction
	public var scale:Float;
	public var alpha:Float;
	public var timer:Int;			//lifetime,  -1 => infinite
	public var fadeLimit:Int;		//when timer is under this value, starts to fadeOut depending on fadeType
	public var fadeType:Int;		//1:alpha fade,2: scale fade, 3:scale X,4:scale Y
	var fadeInData: { timer:Int, limit:Int };
	var ground: { y:Float, frx:Float, fry:Float };

	public var onBounceGround:Void->Void;
	public var root:T;
		
	public function new(mc:T, ?pManager) {
		super(pManager);
		root = mc;
		fitPix = false;
		x = root.x;
		y = root.y;
		vx = 0;
		vy = 0;
		weight = 0;
		vr = 0;
		sfr = null;
		rfr = 1;
		frict = 1;
		rfr = 1;
		scale = 1;
		alpha = 1;
		timer = -1;
		fadeLimit = 10;
		fadeType = 0;
	}
	
	public function setScale(sc) {
		scale = sc;
		root.scaleX = sc;
		root.scaleY = sc;
	}
	
	public function setAlpha(a) {
		alpha = a;
		root.alpha = a;
	}
	
	override function update() {
		// POS
		vy += weight;
		vx *= frict;
		vy *= frict;
		x += vx;
		y += vy;
		// ROT
		vr *= rfr;
		root.rotation += vr;
		// SC
		if( sfr != null ) {
			scale *= sfr;
			setScale(scale);
		}
		// GROUND
		if( ground != null ) {
			if( y > ground.y ) {
				y = ground.y;
				vx *= ground.frx;
				vy *= -ground.fry;
				if( onBounceGround != null ) onBounceGround();
			}
		}
		// FADE IN;
		if( fadeInData != null  ) {
			fadeInData.timer++;
			var c = fadeInData.timer / fadeInData.limit;
			switch(fadeType) {
				case 0 :
				case 1 :	root.alpha = c * alpha;
				case 2 :	root.scaleX = root.scaleY = c * scale;
				case 3 :	root.scaleX = c * scale;
				case 4 :	root.scaleY = c * scale;
			}
			if( c == 1 ) fadeInData = null;
		}
		// FADE OUT
		timer--;
		if( timer < fadeLimit && timer >= 0) {
			var c = timer / fadeLimit;
			switch(fadeType) {
				case 0 :
				case 1 :	root.alpha = c * alpha;
				case 2 :	root.scaleX = root.scaleY = c * scale;
				case 3 :	root.scaleX = c * scale;
				case 4 :	root.scaleY = c * scale;
			}
		}
		// TIME OUT
		if( timer == 0 ) kill();
		//
		updatePos();
	}
	
	public function setPos(nx, ny) {
		x = nx;
		y = ny;
		updatePos();
	}
	
	public function updatePos() {
		root.x = x;
		root.y = y;
		if( fitPix ) {
			root.x = Std.int(root.x);
			root.y = Std.int(root.y);
		}
	}
	
	public function frameKill() {
		var dyn:Dynamic = cast root;
		dyn.kill = kill;
	}
	
	public function fadeIn(n) {
		fadeInData = { timer:0, limit:n };
		root.scaleX = root.scaleY = 0;
	}
	
	/**
	 *
	 * @param	y		y pos of the ground
	 * @param	frx		x bouncing of the ground
	 * @param	fry		y bouncing of the ground
	 * @param	?timer	The part will be killed after $timer frames, once they touched the ground
	 */
	public function setGround(y,frx,fry,?timer) {
		ground = { y:y, frx:frx, fry:fry };
		if ( timer != null ) {
			var me = this;
			onBounceGround = function() { me.timer = timer; };
		}
	}
	
	// SHORTCUT
	public function twist(n, ?fr:Null<Float>) {
		if( fr != null ) rfr = fr;
		root.rotation = Math.random() * 360;
		vr = (Math.random() * 2 - 1) * n;
	}
	
	public function shortrun(n) {
		x += vx * n;
		y += vy * n;
		updatePos();
	}
	
	public function sleep(count:Int, autoplay = false) {
		var sleep = new Sleep(this, count);
		root.visible = false;
		var me = this;
		var f = function() { me.root.visible = true; };
		if( autoplay ) {
			var mc:flash.display.MovieClip = cast root;
			mc.stop();
			f = function() { me.root.visible = true; mc.play(); };
		}
		sleep.onFinish = f;
	}

	// KILL
	override function kill() {
		if( root.parent != null ) root.parent.removeChild(root);
		super.kill();
	}
}
