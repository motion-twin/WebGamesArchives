import mt.bumdum9.Lib;

typedef Alien = { cell:Cell, dist:Float };

class Cell {//}
	
	public static var IMPULSE = 0.3;
	
	public var dead:Bool;
	var consume:Bool;
	
	var type:Int;
	
	public var x:Float;
	public var y:Float;
	public var vx:Float;
	public var vy:Float;
	var val:Float;
	
	public var baseRay:Float;
	public var ray:Float;
	public var color:Int;
	public var last:Bool;
	public var blob:Float;
	public var dec:Float;
	public var accel:Float;
	
	var sprite:McCell;
	//var sprite:flash.display.Sprite;

	
	public function new(r) {
		Game.me.cells.push(this);
		

		sprite = new McCell();
		sprite.env.stop();
		sprite.noyau.stop();
		//sprite.blendMode = flash.display.BlendMode.ADD;
		Game.me.lvl.dm.add(sprite, Level.DP_CELLS);		

	
		dead = false;
		ray = r;
		baseRay = r;
		color = Std.random(3);

		consume = false;
		type = 0;
		near = [];
		nearTimer = 0;
		accel = 0.1+Game.me.dif*0.05;

		x = 0;
		y = 0;
		vx = 0;
		vy = 0;
		
		dec = 0;
		blob = 0;
		flh = 0;
				
		setRandomPos();
		randomImpulse();
		draw();
	}


	public function draw() {
		
		sprite.scaleX = ray * 2 *0.01;
		sprite.scaleY = ray * 2 * 0.01;
		
		/*
		var fr = 1 ;
		if( ray > 12 ) fr++;
		if( ray > 24 ) fr++;
		if( ray > 64 ) fr++;
		sprite.gotoAndStop(fr);
		*/
		
		var sc = Math.max(2 - ray / 200, 1);
		
		sprite.noyau.scaleX = sc;
		sprite.noyau.scaleY = sc;
		//sprite.noyau.gotoAndPlay(Std.random(24) + 1);
		
	}
	public function drawCircle(color_inside, color_line) {
		var gfx = sprite.graphics;	
		gfx.clear();
		gfx.lineStyle(0, color_line);
		gfx.beginFill(color_inside,50);
		gfx.drawCircle(0, 0, ray);		

	}
	
	public function setRandomPos() {
		for( i in 0...400 ) {
			var ma = ray;
			x = ma + Math.random() * (Level.WIDTH - 2 * ma);			
			y = ma + Math.random() * (Level.HEIGHT - 2 * ma);					
			var ok = true;
			for ( c in Game.me.cells ) {
				if ( c!=this && collide(c) ) {
					ok = false;
					break;
				}
			}
			if ( ok ) return;
		}		
	}
	
	public function randomImpulse() {
		var a = Math.random() * 6.28;
		var pow = IMPULSE;
		vx = Math.cos(a) * pow;
		vy = Math.sin(a) * pow;
	}
	
	public function collide(c:Cell) {
		var dx = ddx(c.x - x);
		var dy = ddy(c.y - y);
		var lim = ray + c.ray;
		if( Math.abs(dx) > lim || Math.abs(dy) > lim ) return false;
		return Math.sqrt(dx * dx + dy * dy) < lim;
	}
	
	// UPDATE
	
	public function update() {
		
		/*
		if( type == 2 ) ia();
		if( type == 1 ) control();
		if( type == 0 ) {
			if( Std.random(200) == 0 && Math.sqrt(vx*vx+vy*vy) < IMPULSE ) {
				randomImpulse();
			}
		}
		*/

		
		
		x += vx;
		y += vy;
		
		sprite.noyau.x = vx*0.5;
		sprite.noyau.y = vy*0.5;
		
		if( blob > 0 ) {
			var ec = blob * 0.001;
			dec = (dec + 32 + blob) % 628;	
			sprite.env.scaleX = 1 + Math.cos(dec * 0.01) * ec;
			sprite.env.scaleY = 1 + Math.sin(dec * 0.01) * ec;
			blob *= 0.8;
		}
		
		
		updateFlash();
		//
		//
		checkBorderCol();		
		
	}
	public function updatePos() {
		
		
		var fc = Game.me.lvl.focus;
		var dx = ddx(x - fc.x);
		var dy = ddy(y - fc.y);	

		sprite.x = fc.x + dx;
		sprite.y = fc.y + dy;
		sprite.visible = true;
		
		var ww = (Game.mcw * 0.5) / Game.me.lvl.scale;
		var hh = (Game.mch * 0.5) / Game.me.lvl.scale;
		sprite.visible = Math.abs(dx) - ray < ww && Math.abs(dy) - ray < hh;

	}
	
	
	function checkBorderCol() {		
		x = Num.sMod(x, Level.WIDTH);
		y = Num.sMod(y, Level.HEIGHT);
	}
	public static inline function ddx(n) {
		return Num.hMod(n, Level.WIDTH*0.5);
	}
	public static inline function ddy(n) {
		return Num.hMod(n, Level.HEIGHT*0.5);
	}	
	
	public function checkCols(c:Cell) {
		
			
		var dx = ddx( c.x - x );
		var dy = ddy( c.y - y );
		var lim = ray + c.ray;
		if( Math.abs(dx) < lim && Math.abs(dy) < lim ) {
			var dif = lim - Math.sqrt(dx * dx + dy * dy);
			if( dif > ray ) dif = ray;
			if( dif > c.ray ) dif = c.ray;
			if( dif > 0 ) {

				var cns = consume || c.consume;
				
				// BOUNCE
				if( !cns || Math.abs(1 - ray / c.ray) < 0.1 ){
				
					bounce(c, dif, dx, dy);
					
				}else {	
					
					if( ray >= c.ray ) 	eat(c,dif);
					else 				c.eat(this, dif);					
					
					// DEBUG
					if( c.type == 2 ) c.checkNear(this);
					if( type == 2 ) checkNear(c);
					
					
				}
			}				
		}
	
	}
	function eat(c:Cell,dif:Float) {
		var area = getDiscArea(c.ray) - getDiscArea(c.ray - dif);
		grow(area);								
		c.grow( -area);
		//incScore(dif);	
		
		
	}
	function bounce(c:Cell, dif:Float, dx,dy) {
	
		var an = Math.atan2(dy, dx);
		var ca = Math.cos(an);
		var sa = Math.sin(an);
		
		var ec = dif * 0.5;
		c.x += ca * ec;
		c.y += sa * ec;
		x -= ca * ec;
		y -= sa * ec;
		
		// BOUNCE
		var speed = Math.sqrt(vx * vx + vy * vy);
		var cspeed = Math.sqrt(c.vx * c.vx + c.vy * c.vy);						
		var sp = (ray / (ray + c.ray)) * speed;
		c.vx += ca * sp;
		c.vy += sa * sp;							
		var sp = (c.ray / (ray + c.ray)) * speed;
		vx -= ca * sp;
		vy -= sa * sp;
		
	}
	
	
	/*
	function incScore(dif:Float) {
		if( type != 1 || dif < 0) return;
		KKApi.addScore(KKApi.const(Std.int(dif*10)));		
	}
	*/
	
	function grow(inc:Float) {
		var area = getDiscArea(ray);
		var c = inc / area;
		area += inc;
		ray = getDiscRay(area);
		draw();

		if( inc < 0 )
			blob *= 0.5;
		else
			blob += c * 200;
		
		if( ray < 1 ) {
			/*
			var mc = new FxStar();
			mc.x = x;
			mc.y = y;
			Game.me.lvl.dm.add(mc, 3);
			var me = this;
			mc.addFrameScript(10, function() { me.destroy(mc); } );		
			*/
			
			kill();
		}
	}
	function destroy(mc:flash.display.MovieClip) {
		//trace("!!");
		mc.stop();
		if(mc.parent != null) mc.parent.removeChild(mc);
		
	}
	
	
	function getDiscArea(ray:Float):Float {
		if( ray < 0 ) return 0;
		return Math.pow(2*Math.PI*ray,2);
	}
	function getDiscRay(area:Float):Float {
		if( area < 0 ) return 0;
		return Math.sqrt(area) / (Math.PI * 2);		
	}
	

	// IA 
	public var near:Array<{cell:Cell,dist:Float}>;
	public var nearTimer:Float;
	function ia() {
		

		if( nearTimer-- <= 0 ) majNear();
		
		majNearDist();
		near.sort(sortNear);
		
		
		var acc = accel;
		var ref = 0.0;
		var a = [];
		var speed =  Math.sqrt(vx * vx + vy * vy);
	
		for ( o in near ) {
			if( o.cell.dead ) {
				near.remove(o);
				continue;
			}
			if( ref == 0 ) ref = o.dist;
			var coef = ref / o.dist;
			if( coef < 0.5 && Math.abs(o.dist) > speed*5 ) break;
			var dx = ddx( o.cell.x - x);
			var dy = ddy( o.cell.y - y);
			var an = Math.atan2(dy, dx);			
			if( o.cell.ray >= ray ) an += 3.14;
			a.push( { an:an, w:coef } );
			
		}
		var sum = 0.0;
		for( o in a ) sum += o.w;
		var dx = 0.0;
		var dy = 0.0;
		for( o in a ) {
			var c = o.w / sum;
			dx += Math.cos(o.an);
			dy += Math.sin(o.an);
		}
		var an = Math.atan2(dy, dx);
		
		if( a.length == 0 ) acc = 0;
		vx += Math.cos(an) * acc;
		vy += Math.sin(an) * acc;
		

		var frict = 0.96;
		vx *= frict;
		vy *= frict;	
	
		
	}
	function majNear() {
		near  = [];
		nearTimer = 30 + Std.random(10);
		
		for( c in Game.me.cells ) {
			if( c != this ) {
				var dx = ddx(x - c.x);
				var dy = ddy(y - c.y);
				var dist = Math.sqrt(dx * dx + dy * dy) - (c.ray + ray);
				near.push({cell:c,dist:dist});
			}
		}
		near.sort(sortNear);
		near = near.slice(0, 20);
	}
	
	function majNearDist() {
		for( o in  near) {			
			var dx = ddx(x - o.cell.x);
			var dy = ddy(y - o.cell.y);
			var dist = Math.sqrt(dx * dx + dy * dy) - (o.cell.ray + ray);
			o.dist = dist;
		}
		
	}
	
	public function sortNear(a:Alien, b:Alien) {
		if( a.dist < b.dist ) return -1;
		else return 1;
	}
	
	function checkNear(c) {
		//return;
		for( o in near ) if( o.cell == c ) return;
		trace("alien unknown" + Std.random(10));
		fxFlash();
		
	}

	// FX
	public var flh:Float;
	public function fxFlash() {
		flh = 1;
		sprite.alpha = 0.5;
		updateFlash();
		
	}
	public function updateFlash() {
		if( flh == 0 ) return;
		if( flh < 0.1 )	flh = 0;	
	
		//Col.setColor(sprite, 0, Std.int(flh * 100));
		Col.setPercentColor(sprite, flh, 0xFFFFFF);
		flh *= 0.75;
	}
	
	
	public function kill() {
		dead = true;
		sprite.parent.removeChild(sprite);
		Game.me.cells.remove(this);
	}
	
	// DEBUG
	public function lineTo(c:Cell) {
		var gfx = Game.me.lvl.tracer.graphics;
		gfx.lineStyle(1, 0xFFFFFF);
		gfx.moveTo(x, y);
		var dx = ddx(c.x - x);
		var dy = ddy(c.y - y);
		gfx.lineTo(x+dx, y+dy);
				
	}
	
//{
}





















