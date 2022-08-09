package ent;
import mt.bumdum9.Lib;
import mt.bumdum9.Tools;
import Protocol;

class Ball extends Ent 
{
	
	public static var DATA =  ods.Data.parse("data.ods", "animals", DataBall);
	
	public var vz:Float;
	public var score:mt.flash.Volatile<Int>;
	public var charge:Bool;
	public var type:BallType;
	public var skin:gfx.Ball;
	
	public var combos:Array<Array<Ball>>;
	
	var animal:MC;
	var reg:Bool;
	
	public function new(?type) 
	{
		super();
		charge = false;
		dropShadow();
		if( type == null )
			type = Game.me.getPoolType();
		setType(type);
		reg = false;
		vz = 0;
		gy = 4;
		sy = 8;
		combos = [];
	}
	
	// SKINING
	public function setType(t) 
	{
		type = t;
		animal = null;
		if( skin != null )
			skin.parent.removeChild(skin);
		skin = getSkin(type);
		if( skin.smc != null )
			animal = skin.smc;
		root.addChild(skin);
	}
	
	public static function getSkin(type:BallType)
	{
		var mc = new gfx.Ball();
		mc.gotoAndStop(Type.enumIndex(type) + 1);
		if( mc.smc != null )
			mc.smc.stop();
		return mc;
	}
	
	public function goto(lab)
	{
		if( animal != null )
			animal.gotoAndStop(lab);
	}
	
	override function isBall()
	{
		return true;
	}
	
	// FX
	public function fxBurst() 
	{
		var lim = 0;
		if( Game.me.ents.length > 120 ) lim++;
		if( Game.me.ents.length > 200 ) lim++;
		if( Game.me.ents.length > 300 ) lim++;
		if( Game.me.ents.length > 400 ) lim++;
		// PERFS CHECK
		if( api.AKApi.isLowQuality() ) lim *= 2;
		else lim = Std.int( lim / api.AKApi.getPerf() );
		// GIBS
		var max = 4 >> lim;
		var cr = 3;
		for ( i in 0...max ) 
		{
			var a = Math.random() * 6.28;
			var speed = 0.5 + Math.random() * 5;
			var p = new Limb(type, i + 1);
			p.vx = Math.cos(a) * speed;
			p.vy = Math.sin(a) * speed;
			p.vz = speed - 7;
			p.setPos(x+p.vx*cr, y+p.vy*cr, z+p.vz*cr);
			p.twist(16, 0.98);
		}
		// GUTS
		var max = 2 >> lim;
		var cr = 2;
		for ( i in 0...max ) 
		{
			var a = Math.random() * 6.28;
			var speed = 1+Math.random() * 3;
			var p = new Guts();
			p.vx = Math.cos(a) * speed;
			p.vy = Math.sin(a) * speed;
			p.setPos(x + p.vx * cr, y + p.vy * cr);
		}
		// BLOODS
		var max = 4 >> lim;
		for ( i in 0...max ) 
		{
			var p = new Blood(1 + Math.random() * 2.2);
			var a = ((i + Math.random()) / max) * 6.28;
			var speed = Math.random() * 4;
			p.setPos(x, y, z);
			p.vx = Math.cos(a) * speed;
			p.vy = Math.sin(a) * speed;
			p.vz = speed - 3;
		}
		
		if( !api.AKApi.isLowQuality() )
		{
			// BIG DROP
			var skin = new gfx.BloodDrop();
			skin.rotation = Math.random() * 360;
			skin.gotoAndStop(3);
			var mc = new SP();
			mc.addChild(skin);
			var m = new MX();
			m.translate(shade.x, shade.y);
			Game.me.blood.draw(mc, m);
			// CORE
			var p = new mt.fx.Part( new gfx.BallCore() );
			Game.me.dm.add(p.root,Game.DP_GROUND);
			p.setPos(x, y);
			p.timer = p.fadeLimit = 10;
			p.fadeType = 2;
			Col.setColor(p.root, 0xFF0000);
		}
		// PARTS
		var a = Tools.slice(skin, 4>>lim);
		for( p in a ) 
		{
			Game.me.dm.add(p.root, Game.DP_FX);
			p.timer = p.fadeLimit = 15;
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
	}
	
	public function register()
	{
		Game.me.balls.push(this);
	}
	
	public function unregister() 
	{
		Game.me.balls.remove(this);
	}
	
	public function getNeiBall(di)
	{
		var nsq = square.dnei[di];
		if( nsq == null ) return null;
		return nsq.getBall();
	}
	
	// KILL
	public function burst() 
	{
		fxBurst();
		unregister();
		kill();
	}
}
