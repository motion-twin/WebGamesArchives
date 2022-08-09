import mt.bumdum9.Lib;

class Shot extends EL {
	
	static var JACKY = false;

	public var type:Int;
	public var vx:Float;
	public var vy:Float;
	public var skin:MC;
	var halo:SP;
	public var life:Int;
	var slimeProof:Bool;
	public var power:Int;
	
	public function new(type) {
		super();
		setType(type);
		Game.me.shots.push(this);
		Game.me.dm.add(this, Game.DP_SHOTS);
		life = -1;
		power = 1;
		if( JACKY ){
			halo = new gfx.GradientSphere();
			Col.setColor(halo, 0xFF6633);
			halo.scaleX = halo.scaleY = 1;
			
			addChild(halo);
			halo.blendMode = flash.display.BlendMode.ADD;
			halo.alpha = 0.1;
		}
		slimeProof = type == 1 || !Game.me.have(BULLET_SLIME);
	}

	public function setType(t) {
		type = t;
		if( skin != null )
			removeChild(skin);
		skin = null;
		switch(t) {
			case 0 :
				skin = new gfx.HeroShot();//HeroShot
				addChild(skin);
				
			default :
				skin = new gfx.BadShot();
				addChild(skin);
		}
	}
	
	public function update() {
		// SLIME TEST
		var coefSpeed = 1.0;
		if ( !slimeProof && Game.me.slime.isSticky(x, y) ) coefSpeed = 0.2;
		
		x += vx * coefSpeed;
		y += vy * coefSpeed;
		
		x = Std.int(x);
		y = Std.int(y);
		
		switch(type) {
			case 0 :
				for ( b in Game.me.bads ) {
					var dx = b.x - x;
					var dy = b.y - y;
					var ray = b.ray + 3*power;
					if ( Math.abs(dx) < ray && Math.abs(dy) < ray ) {
						var hit = b.damage(power, this);
						if(hit){
							var circ = Game.me.setFx("circ", x, y);
							circ.rotation = 90 * Std.random(4);
							fxImpactDif();
							kill();
							#if sound
							Sfx.play( b.data.sfx_hit);
							#end
						}
						break;
					}
				}
			case 1 :
				// implémenté dans Hero
		}
		
		// BORDER
		checkBorders();
		
		// LIFE
		if( type == 0 && life == 10 ) {
			vx = 0;
			vy = 0;
			skin.gotoAndPlay(6);
		}
		
		if( life-- == 0 ) {
			kill();
		}
	}

	public function orient(a:Float) {
		rotation = a / 0.0174;
	}
	
	function checkBorders() {
		var ma = Game.BORDER_X;
		if ( x < ma || x > Game.WIDTH - ma ) {
			x = Num.mm(ma, x, Game.WIDTH - ma);
			impactWall(0);
		}
		var ma = Game.BORDER_Y;
		if ( y < ma || y > Game.HEIGHT - ma ) {
			y = Num.mm(ma, y, Game.HEIGHT - ma);
			impactWall(1);
		}
	}
	
	function impactWall(k) {
		#if sound
		Sfx.play(10,0.25);
		#end
		if ( !Game.me.have(SOFT_WALL) && type == 0 ) {
			if ( k == 0 ) vx *= -1;
			if ( k == 1 ) vy *= -1;
			orient(Math.atan2(vy, vx));
			life >>= 1;
		} else {
			fxImpact();
			kill();
		}
	}

	// FX
	function fxImpact() {
		var el = new EL();
		Game.me.dm.add(el, 4);
		el.x = x;
		el.y = y;
		var anim = "border_impact";
		if ( Game.me.have(ELECTRIC_WALLS) ) {
			el.blendMode = flash.display.BlendMode.ADD;
			anim = "volt_b";
			el.shuffleDir();
		}
		el.play(anim,false);
		el.anim.onFinish = el.kill;
	}
	
	function fxImpactDif() {
		
		var sp = new SP();
		sp.graphics.beginFill(0xFFFFFF);
		sp.graphics.drawCircle(0, 0, 20);
		sp.blendMode = flash.display.BlendMode.HARDLIGHT;
		sp.alpha = 0.4;
		Game.me.dm.add(sp, Game.DP_TOP);
		sp.x =  x;
		sp.y =  y;
		var e = new mt.fx.Vanish(sp, 6,6);
		e.setFadeScale(1, 1);
	}
	
	override function kill() {
		super.kill();
		Game.me.shots.remove(this);
		
		if( JACKY ){
			Game.me.dm.add(halo, Game.DP_UFX);
			halo.x = x;
			halo.y = y;
			halo.blendMode = flash.display.BlendMode.ADD;
			halo.alpha = 0.4;
			halo.scaleX = halo.scaleY = 2;
			var e =new mt.fx.Vanish(halo, 60,60);
			e.setFadeScale(1, 1);
		}
	}
}
