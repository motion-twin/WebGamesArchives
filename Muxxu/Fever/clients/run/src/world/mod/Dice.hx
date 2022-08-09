package world.mod;
import Protocole;
import mt.bumdum9.Lib;

class Dice extends world.Mod{//}
	
	public static var GY = 68;
	public static var DY = 8;
	
	var num:Int;
	var step:Int;

	var oldPos: { x:Float, y:Float };
	var rainbow:flash.display.Bitmap;
	var brush:pix.Element;
	var part:pix.Part;
	var bounce:Int;
	var timer:Int;
	
	public function new() {
		ww = 128;
		hh = 96;
		super();
		//drawBg(0);
		center();

		// TIRAGE
		num = Std.random(6);
		World.me.send(_Dice(num==0));
		world.Inter.me.majStatus();
		
		//
		rainbow = new flash.display.Bitmap();
		rainbow.bitmapData = new flash.display.BitmapData(ww, GY+DY, true, 0);
		dm.add(rainbow, 1);
		
		brush = new pix.Element();
		brush.drawFrame(Gfx.fx.get("rainbow"));
		
		part = new pix.Part();
		part.drawFrame(Gfx.fx.get(0));
		part.setPos( -30, 40);
		part.vx  = 5;
		part.vy  = -6;
		part.weight = 1;
		part.frict = 0.99;
		dm.add(part, 2);
		
		var table = new pix.Element();
		table.drawFrame(Gfx.mod.get("table"),0,0);
		dm.add(table, 0);
		table.x = 16;
		table.y = 64;
		
		
		//
		step = 0;
		bounce = 0;
		
		
		
		//tw = new Tween( 0, 50, 50, 50);
		//oldPos = getPos(0);
		
	}
	
	override function update(e) {
		
		switch(step) {
			
			case 0:

				if( part.y > GY ) {
					bounce++;
					part.y = GY;
					part.vy *= -0.9;
					part.vx *= 0.8;
	
				}
				
				if( oldPos != null ){
					var dx = part.x - oldPos.x;
					var dy = part.y+DY - oldPos.y;
					/*
					var p = new pix.Part();
					p.drawFrame(Gfx.fx.get("rainbow"));
					p.setPos(oldPos.x,oldPos.y);
					p.scaleX  = (Math.sqrt(dx * dx + dy * dy) + 2) / 16;
					p.rotation = Math.atan2(dy, dx) / 0.0174;
					dm.add(p, 0);
					*/
					
					var m = new flash.geom.Matrix();
					m.scale((Math.sqrt(dx * dx + dy * dy)+4) / 16, 1);
					m.rotate( Math.atan2(dy,dx));
					m.translate(oldPos.x,oldPos.y);
					rainbow.bitmapData.draw(brush, m);
					
				}
				oldPos = { x:part.xx, y:part.yy+DY };
				
				var fr = num;
				if( bounce == 0 ) fr = Std.random(6);
				part.drawFrame(Gfx.mod.get(fr, "dice") );
				part.rotation += 12;
				if( bounce == 2 ) go();
				
			case 1 :
				if( timer++ > 24 ) {
					part.kill();
					kill();
				}
			
		}
		
		
		var bmp = rainbow.bitmapData;
		bmp.colorTransform( bmp.rect, new flash.geom.ColorTransform(1,1,1,1,3,0,-5,-5) );
		//bmp.applyFilter( bmp, bmp.rect, new flash.geom.Point(0,0), new flash.filters.BlurFilter(2,2) );
		
	}
	
	/*
	function getPos(c:Float) {
		
		c = Math.abs(0.5-Math.cos(c*6.28)*0.5);
		
		var p = tw.getPos(c);
		
		var h = 40;
		if( c > 0.5 ) h = 20;
		
		p.y -= Math.abs(Math.sin( c * 6.28))*h;
		return p;
	}
	
	*/
	
	
	function go() {
		
		part.drawFrame(Gfx.mod.get(num, "dice") );
		part.weight = 0;
		part.vx = 0;
		part.vy = 0;
		part.rotation = 0;
		step++;
		timer = 0;
		
		if( num == 0 ) {
			world.Loader.me.data._plays++;
			world.Inter.me.majStatus();
			
			var pink = world.Inter.me.getLastPinkIceCube();
			new mt.fx.Flash(pink);
			
			var fx = new mt.fx.Flash(part);
			fx.glow(2, 8);
			
			for( i in 0...4) {
				var p = getDust();
				World.me.dm.add(p, World.DP_INTER);
				p.xx = pink.x+Std.random(9)-4;
				p.yy = pink.y + Std.random(9) - 4;
				p.vy -= Math.random() * 1;
				p.updatePos();
			}
			
			var max = 18;
			var cr = 3;
			for( i in 0...max ) {
				var a = i / max * 6.28;
				var speed = Math.random() * 5;
				var p = getDust();
				p.vx = Math.cos(a) * speed;
				p.vy = Math.sin(a) * speed;
				p.xx = part.x + p.vx * cr;
				p.yy = part.y + p.vx * cr;
				dm.add(p, 3);
				p.updatePos();
			}
			
			
		}
		
	}
	

	
	
//{
}








