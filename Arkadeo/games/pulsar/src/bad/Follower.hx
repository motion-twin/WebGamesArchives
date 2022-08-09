package bad;
import mt.bumdum9.Lib;


class Follower extends Bad  {
	
	var mini:Bool;
	var acc:Float;
	
	public function new() {
		super(FOLLOWER);
		setFamily();
		ray = 10;
		
		setSkin(new gfx.Blob(), 8);
		
		zh = -4;
		acc = 0.0002;
		mini = false;
		if ( have(FOLLOWER_LIFE) ) 	life++;
		if ( have(FOLLOWER_SPEED) ) acc *= 2;
		
		skin.scaleX = skin.scaleY = 1.2;
	}

	public function setMini() {
		mini = true;
		life = 1;
		ray = 5;
		zh = -3;
		skin.scaleX = skin.scaleY = 0.75;
		shade.scaleX = shade.scaleY = 0.75;
	}
	
	override function update() {
		super.update();
		var dx = Game.me.hero.x - x;
		var dy = Game.me.hero.y - y;
		vx += dx * acc;
		vy += dy * acc;
	}
	
	override function explode(?angle) {
		super.explode(angle);
		
		// DIVIDE
		if( !mini && (have(FOLLOWER_DIVIDE) ) ){
			for ( i in 0...2 ) {
				var b:Follower = cast spawn(FOLLOWER);
				b.setMini();
				b.noisePos();
				b.updatePos();
			}
		}
		
		// BLAST
		var a = Game.me.getBadList(FOLLOWER);
		for ( b in a ) {
			var dx = b.x - x;
			var dy = b.y - y;
			var a = Math.atan2(dy, dx);
			var lim = 64;
			var co = (lim - Math.sqrt(dx * dx + dy * dy)) / lim;
			if( co > 0 ){
				var speed = 6 * co;
				b.vx += Math.cos(a) * speed;
				b.vy += Math.sin(a) * speed;
			}
		}
	}
	
	override function fxExplode(?angle) {
		#if sound
		Sfx.play(6,0.5);
		#end
		if ( !Game.me.lowQuality )
		{
			var mc = new gfx.SlimeSpot();
			mc.rotation = Game.me.seed.rand() * 360;
			mc.gotoAndStop(rnd(mc.totalFrames) + 1);
			
			var size = 150 + rnd(50);
			if ( mini ) size >>= 1;
			var p = Game.me.slime.splash2( mc, x, y, angle, size*0.01);
			var max = mini?0:3;
			var cr = 3;
			for ( i in 0...max ) {
				var el = new EL();
				el.goto(rnd(4), "follower_ribs");
				el.shuffleDir();
				Filt.glow(el, 2, 4, 0x113800);
				Game.me.dm.add(el, Game.DP_UFX);
				
				var a = angle += (Math.random() * 2 - 1) * 0.4;
				var speed = 2.5 + Math.random() * 4;
				var p = new part.Basic(el);
				
				p.vx = Math.cos(a)*speed;
				p.vy = Math.sin(a) * speed;
				p.setPos(x+p.vx*cr, y+p.vy*cr);
				p.frict = 0.9;
				p.fitPix = true;
				
				p.fadeType = 2;
				p.timer = 80 + Std.random(20);
			}
		}
		var cr = 3;
		var max = mini?3:6;
		for ( i in 0...max ) {
			var el = new EL();
			el.play("follower_part",false);
			el.anim.goto(Std.random(4));
			Game.me.dm.add(el, Game.DP_FX);
			
			var a = angle += (Math.random() * 2 - 1) * 0.4;
			var speed = 1.5 + Math.random() * 3;
			
			var p = new mt.fx.Part(el);
			p.vx = Math.cos(a) * speed;
			p.vy = Math.sin(a) * speed;
			p.setPos(x+p.vx*cr, y+p.vy*cr);
			p.frict = 0.94;
			p.fitPix = true;
			// HERE
			el.anim.onFinish = p.kill;
		}
	}
}
