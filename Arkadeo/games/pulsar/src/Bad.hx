import Protocol;
import mt.bumdum9.Lib;
import mt.bumdum9.Tools;
import api.AKApi;
import api.AKProtocol;

class Bad {
	
	public static var DATA =  ods.Data.parse("data.ods", "bads", DataBad);
	
	public var reactors:Array<Reactor>;
	
	public var badType:BadType;
	public var root:SP;
	
	//public var skin:EL;
	public var skin:MC;
	public var shade:SP;
	
	public var ray:Int;
	public var vx:Float;
	public var vy:Float;
	public var x:Float;
	public var y:Float;
	public var zh:Float;
	public var bump:Int;
	
	var fid:Null<Int>;
	public var timer:Int;
	public var age:Int;
	public var life:Int;

	var frict:Float;
	
	public var dist:Float;		// EXTERN
	public var data:DataBad;
	public var hero:Hero;
	public var float: { bzh:Int, ec:Float, speed:Int, dec:Int };
	
	public var lifeBar:fx.LifeBar;
	
	// SHORTCUT
	var rnd:Int->Int;
	
	public function new(type) {
		badType = type;
		data = DATA[Type.enumIndex(type)];
		hero = Game.me.hero;
		
		shade = new SP();
		Game.me.shadeLayer.addChild(shade);
		
		root = new SP();
		Game.me.bads.push(this);
		Game.me.dm.add(root, Game.DP_BADS);

		bump = 0;
		timer = 0;
		vx  = 0;
		vy  = 0;
		ray = 8;
		zh = -4;
		
		life = data.life;
		reactors = [];
		frict = 0.97;
		// SHORTCUT
		rnd = Game.me.seed.random;
	}
	//
	public function setSkin(mc, shadeRay) {
		skin = mc;
		root.addChild(skin);
		// SHADE
		shade.graphics.beginFill(0);
		shade.graphics.drawCircle(0, 0, shadeRay);
		shade.graphics.endFill();
		return mc;
	}
	
	// POS
	public function setPos(x, y) {
		this.x = x;
		this.y = y;
		updatePos();
	}
	
	public function setBorderPos(di, n) {

	}
	
	public function setAngle(a) {
		
	}
	
	public function updatePos() {
		root.x = Std.int(x);
		root.y = Std.int(y+zh);
		shade.x = Std.int(x);
		shade.y = Std.int(y);
		shade.rotation = root.rotation;
	}
	
	public function noisePos() {
		x += (rnd(1000)/1000) * 4 - 2;
		y += (rnd(1000)/1000) * 4 - 2;
		updatePos();
	}
	
	// UPDATE
	public function update() {
		age++;
		timer++;
		x += vx;
		y += vy;
		vx *= frict;
		vy *= frict;
		// FLOAT ENGINE
		updateFloat();
		//RECAL
		var ma = Game.BORDER_X + ray;
		if ( x < ma || x > Game.WIDTH - ma ) {
			x = Num.mm(ma, x, Game.WIDTH - ma);
			vx *= -1;
			onRecal(0);
		}
		
		var ma = Game.BORDER_Y + ray;
		if ( y < ma || y > Game.HEIGHT - ma ) {
			y = Num.mm(ma, y, Game.HEIGHT - ma);
			vy *= -1;
			onRecal(1);
		}
		//
		updatePos();
	}
	
	// COMMAND
	public function setFloat(base,ec,speed,?dec) {
		if ( dec == null ) dec = Game.me.seed.random(628);
		float = { bzh:base, speed:speed, ec:ec, dec:dec };
		updateFloat();
	}
	
	public function updateFloat(){
		if( float != null )
		{
			float.dec = (float.dec + float.speed) % 628;
			zh = - (float.bzh + (0.5 + Math.cos(float.dec * 0.01) * 0.5) * float.ec);
		}
	}

	public function addReactor(size,ray,offset=0) {
		var r = new Reactor(this, size, ray, offset);
		root.addChild(r);
		reactors.push(r);
		return r;
	}
	
	public function updateReactor(angle:Float) {
		for ( r in reactors ) r.update(angle);
		var an = Num.hMod(angle, 3.14);
		if ( an < 0 ) root.addChild(skin);
		for ( r in reactors ) root.addChild(r);
		if(  an >= 0 ) root.addChild(skin);
	}
	
	inline public function orient(a:Float, step=4 ) {
		root.rotation = getOrientId(a, step) * 360 / step;
	}
	
	public function getOrientId(a:Float,step) {
		var rot = a / 0.0174;
		var lim = Std.int(360 / step);
		rot = Num.sMod(rot+(lim>>1), 360);
		return Std.int(rot / lim);
	}
	
	public function setFamily() {
		Game.me.addFamilyMember(this);
	}
	
	// TOOLS
	inline public function getDist(b:Bad) {
		var dx = b.x - x;
		var dy = b.y - y;
		return Math.sqrt(dx * dx + dy * dy);
	}
	
	inline public function getHeroAngle() {
		var dx = Game.me.hero.x - x;
		var dy = Game.me.hero.y - y;
		return Math.atan2(dy, dx);
	}
	
	public function spawn(type) {
		var b = get(type);
		b.setPos(x, y);
		return b;
	}
	
	// SHORTCUTS
	public function have(upg) {
		return Game.me.have(upg);
	}
	
	// FIRE
	function fire(an,ray,speed=6) {
		var dx = Math.cos(an);
		var dy = Math.sin(an);
		var shot = new Shot(1);
		shot.x = x + dx * ray;
		shot.y = y + dy * ray;
		
		shot.vx = dx * speed;
		shot.vy = dy * speed;
		shot.rotation = an/0.0174;
	}
	
	// DESTRUCTION
	public function damage(n,shot:Shot) {
		life -= n;
		if( life <= 0 ) {
			explode(Math.atan2(shot.vy, shot.vx));
		} else {
			if( data.life >= 9 ) {
				if( lifeBar == null ) lifeBar = new fx.LifeBar(this);
				lifeBar.timer = 60;
			}
			new mt.fx.Flash(root, 0.5);
		}
		return true;
	}
	
	public function explode(?angle) {
		fxExplode(angle);
		spawnScore();
		//
		Game.me.stykades.death += data.dif;
		// SPECIAL
		if (have(SPAWN_FOLLOWER_ON_DEATH)) {
			switch(data.id) {
				case FOLLOWER, DIAGON_EGG:
				default : spawn(FOLLOWER);
			}
		}
		// KILL
		kill();
	}
	
	public function dust() {
		// PARTS
		var a = Tools.slice(skin, ray);
		for( p in a ) {
			Game.me.dm.add(p.root,Game.DP_FX);
			p.timer = p.fadeLimit = 20+Std.random(10);
			p.fadeType = 2;
			
			var a = Math.atan2(p.y, p.x);
			var dist = Math.sqrt(p.x * p.x + p.y * p.y);
			p.vx = Math.cos(a) * dist * 0.1;
			p.vy = Math.sin(a) * dist * 0.1;
			
			// POS
			p.x += x;
			p.y += y;
			p.updatePos();
		}
		
		if ( !Game.me.lowQuality )
		{
			var mc = new gfx.LightBall();
			mc.blendMode = flash.display.BlendMode.ADD;
			mc.scaleX = mc.scaleY = ray / 30;
			
			var mmc = new SP();
			Game.me.dm.add(mmc, Game.DP_FX - 1);
			mmc.addChild(mc);
			mmc.x = x;
			mmc.y = y;
			
			var e = new mt.fx.Vanish(mmc, 10, 10);
			e.setFadeScale(1, 1);
			e.curveInOut();
		}
		//
		kill();
	}
	
	public function kill() {
		Game.me.bads.remove(this);
		root.parent.removeChild(root);
		Game.me.removeFamilyMember(this);
		shade.parent.removeChild(shade);
	}
		
	// FX
	public function fxExplode(?angle:Float) {
		
		if ( Game.me.lowQuality ) return;
		
		#if sound
		Sfx.play(data.sfx_explo);
		#end
		// ONDE
		var e = new mt.fx.ShockWave(ray << 2, ray << 4, (8/ray)*0.1);
		e.curveIn(0.5);
		Game.me.dm.add(e.root, Game.DP_FX);
		e.root.blendMode = flash.display.BlendMode.ADD;
		e.setPos(x, y);
		
		// EXPLO
		for( i in 0...3 ){
			var mc = new gfx.Explo();
			var sc = 0.5 - i * 0.15;
			sc *= ray / 10;
			var dx = (Math.random() * 2 - 1) * i * 12;
			var dy = (Math.random() * 2 - 1) * i * 12;
			
			var m = new MX();
			m.rotate(Math.random() * 360);
			m.scale(sc, sc);
			m.translate(x+dx, y+dy);
			Game.me.plasma.draw(mc, m, null, flash.display.BlendMode.ADD);
		}
		
		// PARTS
		var ec = ray >> 1;
		var max = (ray >> 2) + Std.random(2);
		for( i in 0...max ) {
			var p = new part.Fire();
			p.vz = -(2 + Math.random() * 3);
			p.vx = (Math.random() * 2 - 1) * ec;
			p.vy = (Math.random() * 2 - 1) * ec;
			if( angle != null ) {
				var an = angle + (Math.random() * 2 - 1) * 0.7;
				var pow = ec * (0.25 + Math.random()*0.75);
				p.vx = Math.cos(an)*pow;
				p.vy = Math.sin(an)*pow;
				
			}
			p.setPos(x + p.vx, y + p.vy );
			p.timer += ray-Std.random(8);
		}
		
		return; // TODO AGAIN
	}
	
	public function spawnScore() {
		
		if( data.dif > 0 && AKApi.getGameMode() == GM_LEAGUE ){
			
			var dif = data.dif << Game.me.hero.numHave(MULTI);
			var sco = dif * 50;
			var mc = new SP();
			var a = Std.string(sco).split("");
			var px = 0;
			for( char in a ) {
				var el = new EL();
				el.goto(char.charCodeAt(0) - 48, "num",0,0);
				el.x = px;
				mc.addChild(el);
				px += char == "1"?2:4;
			}
			
			Game.me.dm.add(mc, Game.DP_SCORE);
			var p = new mt.fx.Part(mc);
			p.vy = -4;
			p.weight = 0.4;
			p.timer = 40;
			p.setPos(x, y);
			p.fitPix = true;
			p.setGround(p.y, 1.0, 0.5);
			Filt.glow(p.root, 2, 4, 0);
			
			AKApi.addScore(api.AKApi.const(sco));
		}
		
		// FX
		var sp = new SP();
		sp.graphics.beginFill(0xFFFFFF);
		sp.graphics.drawCircle(0, 0, ray);
		sp.x = x;
		sp.y = y+zh;
		
		var e = new mt.fx.Vanish(sp, 8, 8, false);
		e.setFadeScale(1, 1);
		Game.me.dm.add(sp, Game.DP_UFX);
	}
	
	// ON
	public function onRecal(n:Int) {
		
	}
	
	// INTERN
	public function rnc(neg = false) {
		var n = rnd(1000) * 0.001;
		if ( neg ) n = n * 2 - 1;
		return n;
	}
	
	// STATIC
	public static function get(type:BadType):Bad {
		return switch(type) {
			case DIAGON_EGG : 	var bad:Bad = new bad.DiagonEgg(); bad;
			case DIAGON : 		new bad.Diagon();
			case FOLLOWER : 	new bad.Follower();
			case GYRO : 		new bad.Gyro();
			case CHASER :		new bad.Chaser();
			case LORD :			new bad.Lord();
			case RAPTOR :		new bad.Raptor();
			case TANK :			new bad.Tank();
			case SHIELD :		new bad.Shield();
			case WHALE :		new bad.Whale();
			case COWARD :		new bad.Coward();
		}
	}
	
	public static function getRandom() {
		return get(DIAGON);
		var a = [FOLLOWER, DIAGON, CHASER, LORD];
		return get( a[Game.me.seed.random(a.length)] );
	}
}

class Reactor extends SP {
	
	public static var SPEED_CYCLE = 2;
	
	var bad:Bad;
	var dist:Float;
	var offset:Float;
	var ray:Float;
	public var cy:Float;
	public var size:Float;
	public var targetSize:Float;
	
	public var spit:Float;
	
	public function new(b,ray,dist,offset) {
		bad = b;
		this.dist = dist;
		this.ray = ray;
		this.offset = offset;
		super();
		
		cy = 1.0;
		spit = 0.0;
		size = targetSize = 1.0;
		
		graphics.beginFill(0xFFFFFF, 0.25);
		graphics.drawCircle(0, 0, ray + 2);
		graphics.endFill();
		graphics.beginFill(0xFFFFFF);
		graphics.drawCircle(0, 0, ray);
		graphics.endFill();
	}
	
	public function update(angle:Float) {
		var ds = targetSize-size;
		size += ds * 0.1;
		
		var sc = size;
		sc *= (bad.age % 4 < 2)?1.5:1;
		scaleX = scaleY = sc;
		
		angle -= 3.14;
		x = Math.cos(angle) * (dist+ray*sc);
		y = Math.sin(angle) * (dist+ray*sc) * cy;
			
		spit += sc;
		while( spit > SPEED_CYCLE ) {
			spit-=SPEED_CYCLE;
			getSpark();
		}
	}
	
	public function fxBurst(max) {
		for ( i in 0...max ) {
			var p = getSpark();
		}
	}
	
	public function getSpark() {
		var sc = 1 + Math.random();
		var sp = new SP();
		sp.graphics.beginFill(0x440000);
		sp.graphics.drawRect(0, 0, sc, sc);
		Game.me.dm.add(sp, Game.DP_SPLINTERS);
		var p = new part.Basic(sp);
		p.fitPix = true;
		p.weightZ = 0.2 + Math.random() * 0.2;
		p.vz = -Math.random() * 4;
		p.vx = (Math.random() * 2 - 1) * 1;
		p.vy = (Math.random() * 2 - 1) * 1;
		p.timer = 20 + Std.random(20);
		p.setPos(x+bad.root.x,y+bad.root.y);
		
		var e = new mt.fx.Flash(sp, 0.05, 0xFFFFFF);
		e.glow(2, 6);
		e.curveIn(2);
	}
}

