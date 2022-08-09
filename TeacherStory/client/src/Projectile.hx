class Projectile extends flash.display.Sprite {
	static var ALL : Array<Projectile> = new Array();
	
	var rx				: Float;
	var ry				: Float;
	var startX			: Float;
	var startY			: Float;
	public var tx(default,null)		: Float;
	public var ty(default,null)		: Float;
	public var dx		: Float;
	public var dy		: Float;
	public var dr		: Float;
	public var speed	: Float;
	public var delay	: Float;
	
	// homing missile
	var ang				: Float;
	var angSpeed		: Float;
	var angRecalSpeed	: Float;
	
	public var pixel	: Bool;
	var arrived			: Bool;
	var totalDist		: Float;
	
	var moveFunc		: Void->Bool;
	public var onUpdate	: Null< Void->Void >;
	public var onEnd	: Null< Void->Void >;
	var paused			: Bool;
	
	public function new(x,y, ?spd=1.0) {
		super();
		
		this.x = rx = x;
		this.y = ry = y;
		paused = false;
		speed = spd;
		dx = dy = dr = 0;
		pixel = false;
		arrived = false;
		startX = x;
		startY = y;
		delay = 0;
		totalDist = 1;
		angSpeed = 0.05;
		ang = -3.14*0.1;
		ang = Math.random()*6.28;
		angRecalSpeed = 0.005 + Math.random()*0.05;
		
		ALL.push(this);
		setLinear();
	}
	
	public function setPos(x,y) {
		this.x = rx = x;
		this.y = ry = y;
	}
	
	public inline function pause() { paused = true; }
	public inline function resume() { paused = false; }
	
	public function destroy() {
		parent.removeChild(this);
		if( onEnd!=null )
			onEnd();
	}
	
	public inline function progress() : Float {
		return arrived ? 1 : (1 - tdist() / totalDist);
	}
	
	
	public function setTarget(ttx,tty) {
		tx = ttx;
		ty = tty;
		totalDist = Math.sqrt( (startX-tx)*(startX-tx) + (startY-ty)*(startY-ty));
	}
	
	public function drawBox(w:Float,h:Float, col:Int, ?alpha=1.0) {
		graphics.beginFill(col, alpha);
		graphics.drawRect(-Std.int(w*0.5), -Std.int(h*0.5), w,h);
		graphics.endFill();
	}
	
	inline function rad(a:Float) {
		return a*3.1416 / 180;
	}
	inline function deg(a:Float) {
		return a*180 / 3.1416;
	}
	
	inline function tang() {
		return Math.atan2(ty-ry, tx-rx);
	}
	
	public inline function tdist() {
		return Math.sqrt( (tx-rx)*(tx-rx) + (ty-ry)*(ty-ry) );
	}
	
	inline function abs(v:Float) {
		return v<0 ? -v : v;
	}
	
	function normAng(a:Float) {
		while( a>=3.1416 )
			a-=3.1416*2;
		while( a<-3.1416 )
			a+=3.1416*2;
		return a;
	}
	
	function angDist(a:Float,b:Float) {
		var d = b-a;
		if( abs(d)<=3.1416 )
			return d;
		else
			return abs(normAng(b)-normAng(a));
	}
	
	public function setHoming() { moveFunc = _homing; }
	function _homing() {
		var ta = tang();
		var brake = 1.0;
		var delta = angDist(ang, ta);
		ang += angRecalSpeed * delta;
		angRecalSpeed += 0.003 + speed*0.005;
		if( angRecalSpeed>1 )
			angRecalSpeed = 1;
		ang = normAng(ang);
		rx+=Math.cos(ang)*speed*brake;
		ry+=Math.sin(ang)*speed*brake;
		rotation = deg(ang);
		if( speed>=tdist() )
			return true;
		else
			rotation = deg(ang);
		return false;
	}
	
	public function setLinear() { moveFunc = _linear; }
	function _linear() {
		var a = tang();
		rx+=Math.cos(a)*speed;
		ry+=Math.sin(a)*speed;
		if( speed>=tdist() )
			return true;
		else
			return false;
	}
	
	public function setEaseOut() { moveFunc = _easeOut; }
	function _easeOut() {
		var d = tdist();
		var s = Math.max(0.5, Math.min( d/5, speed ));
		var a = tang();
		dx = Math.cos(a)*s;
		dy = Math.sin(a)*s;
		rx+=dx;
		ry+=dy;
		if( d<=0.5 )
			return true;
		else
			return false;
	}
	
	public static function clearAll() {
		for( p in ALL )
			p.destroy();
		ALL = new Array();
	}
	
	public static function update(?tmod=1.0) {
		var i = 0;
		while( i<ALL.length ) {
			var p = ALL[i];
			
			if( p.paused ) {
				i++;
				continue;
			}
			
			p.visible = p.delay<=0;
			if( p.delay>0 ) {
				p.delay-=tmod;
				i++;
				continue;
			}
			
			var destroy = p.arrived;
			if( !p.arrived && p.moveFunc() ) {
				p.rx = p.tx;
				p.ry = p.ty;
				p.arrived = true;
			}
			
			if( destroy ) {
				ALL.splice(i,1);
				p.destroy();
			}
			else {
				p.rotation+=p.dr;
				while( p.rotation<-180 )
					p.rotation+=360;
				while( p.rotation>=180 )
					p.rotation-=360;
				p.x = p.rx;
				p.y = p.ry;
				if( p.onUpdate!=null )
					p.onUpdate();
				if( p.pixel ) {
					p.x = Std.int(p.x);
					p.y = Std.int(p.y);
				}
				i++;
			}
		}
	}
}