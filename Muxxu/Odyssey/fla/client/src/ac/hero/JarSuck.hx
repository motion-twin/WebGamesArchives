package ac.hero;
import Protocole;
import mt.bumdum9.Lib;



class JarSuck extends Action {//}
	
	public static var JX = 342;
	
	var agg:Hero;
	var vic:Monster;
	
	var life:Int;
	var trg:Folk;
	//var jar:McJar;
	var bmp:BMD;
	
	var screen:BMP;
	var morph:BMD;
	var dis:flash.filters.DisplacementMapFilter;
	
	public function new(agg,vic) {
		super();
		this.agg = agg;
		this.vic = vic;
		
		trg = vic.folk;

		
		
	}
	override function init() {
		if ( agg.readStock(JAR) <= vic.life ) {
			kill();
			return;
		}
		
		super.init();
		add( new ac.MoveMid(agg.folk,-80), spawnJar );
		


	}
	
	
	override function update() {
		super.update();
		
		
		switch(step) {
			case 0:
				
			case 1:
				if ( timer == 10 ) launch();
			case 2:
				suckIn();
				if ( timer == 60 ) end();
			case 3:
			case 4:
				if (tasks.length == 0 ) kill();
		}


	}
	
	
	
	
	function end() {
		
		nextStep();
		agg.folk.play("take", null, false);
		agg.folk.anim.autoLoop = false;
		agg.folk.anim.addEndEvent( goBack );
		
		if ( agg.have(MEAT_SAFE) ) add( new Regeneration(agg, vic.life) );

		vic.life = 0;
		agg.stock = 0;
		
		vic.majInter();
		agg.majInter();
		
		
		
		morph.dispose();
		bmp.dispose();
		
	}
	
	function goBack() {
		nextStep();
		add( new ac.hero.MoveBack(agg.folk) );
	}
	
	
//

	
	
	

	function spawnJar() {
		//nextStep();
		
		agg.folk.play("drop", null, false);
		agg.folk.anim.autoLoop = false;
		agg.folk.anim.addEndEvent( callback(nextStep,null) );
		/*
		jar = new McJar();
		Scene.me.dm.add(jar, Scene.DP_FOLKS);
		jar.x = Cs.mcw*0.5;
		jar.y = Scene.HEIGHT - 12;
		*/
		
		
	}
	

	
	function launch() {
		nextStep();
		
		//var box = trg.getBox();
		var center = trg.getCenter();
		var b = trg.root.getBounds(trg.root);
		//trace(b.x);
		
		var ww = Std.int( (center.x - JX) + trg.width * 0.5+30);
		bmp = new BMD( ww, Scene.HEIGHT, true, 0);
		
		screen = new flash.display.Bitmap(bmp);
		Scene.me.dm.add( screen, Scene.DP_UNDER_FX );
		screen.x =  JX-3;
		screen.y =  0;
		
		// SNAPSHOT
		var m = new flash.geom.Matrix();
		m.translate( trg.x - screen.x, trg.y -screen.y);
		bmp.draw(trg, m);
		//for( i in 0...100 ) bmp.fillRect( new flash.geom.Rectangle( Std.random(bmp.width), Std.random(bmp.height),3,3), 0xFFFFFFFF );
		bmp.fillRect( new flash.geom.Rectangle(0, bmp.height - 1, bmp.width, 1), 0 );
		
		trg.visible = false;
		//trg.show(false);
		
	

		
		// moprh
		morph = new BMD( ww, Scene.HEIGHT, false, 0);
	
		for( x in 0...morph.width ) {
		
		
			var tx:Float = x * 0.9;
			tx = x*0.9-6;
			if( tx < 0 ) tx = 0;
			var co = Math.pow( Math.max(tx / morph.width, 0),0.5);
			var ty:Float = (0.2+(1 - Math.sin(co * 3.14))*0.8) * morph.height;
			
			for( y in 0...morph.height ) {
				
					
				var dx = tx - x;
				var dy = ty - y;
				
				var an = Math.atan2(dy, dx);
				var speed = 128;
		
				dx = Math.cos(an) * speed;
				dy = Math.sin(an) * speed;

				
				var r = 128 + Std.int(dx);
				var g = 128 + Std.int(dy);
				var b = 128;
				var color = Col.objToCol( { r:r, g:g, b:b } );
				morph.setPixel(x, y, color);
				
			}
		}
		
		dis = new flash.filters.DisplacementMapFilter( morph, new flash.geom.Point(0, 0), 1, 2, 1, 1, flash.filters.DisplacementMapFilterMode.CLAMP );
		
		//screen.bitmapData = morph;
		
	}
	
	public function suckIn() {
		
		var base = bmp.clone();
		bmp.applyFilter(base, base.rect, new flash.geom.Point(0, 0), dis );
		dis.scaleX = dis.scaleY = -16;
		bmp.applyFilter(bmp, bmp.rect, new flash.geom.Point(0, 0), new flash.filters.GlowFilter(0, 1, 2, 2, coef*1.5));
		
		bmp.fillRect( new flash.geom.Rectangle(0, 0, bmp.width, 1), 0 );
		bmp.fillRect( new flash.geom.Rectangle(0, 0, 1, bmp.height), 0 );
		bmp.fillRect( new flash.geom.Rectangle(0, bmp.height - 1, bmp.width, 1), 0 );
		bmp.fillRect( new flash.geom.Rectangle(bmp.width - 1, 0, 1, bmp.height), 0 );
		
	}
	
	
	




	
	
//{
}