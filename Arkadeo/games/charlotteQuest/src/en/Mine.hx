package en;

import mt.deepnight.Color;

class Mine extends Enemy {
	public static var MIN_DIFF = 15;
	
	var dr			: Float;
	
	public function new(r:Room, type:Int) {
		super();
		
		var size = rnd(0.55, 0.75);
		
		radius = 35*size;
		color = 0x9CA0BC;
		hasToBeKilled = false;
		pullable = true;
		pullPower = 0.2;
		alertOutside = false;
		
		//var s = new flash.display.Sprite();
		//s.graphics.beginFill(color, 1);
		//s.graphics.drawCircle(0,0, radius);
		//s.filters = [
			//new flash.filters.DropShadowFilter(5,-135, 0x0,0.9, 16,16, 1, 1,true),
			//new flash.filters.DropShadowFilter(1,-135, color,0.3, 4,4, 1, 1,true),
			//new flash.filters.DropShadowFilter(16,90, 0x0,0.3, 8,8, 1),
		//];
		//spr.addChild( mt.deepnight.Lib.flatten(s,20) );
		
		dr = rseed.range(0.5, 2, true);
		
		var mc = new lib.MineBalls();
		mc.filters = [
			new flash.filters.BlurFilter(8,8),
			new flash.filters.GlowFilter(0x96B002, 1, 6,6, 20, 3),
			new flash.filters.GlowFilter(0x728602, 1, 16,16, 50, 3),
			new flash.filters.GlowFilter(0x465201, 0.7, 32,32, 2, 1,true),
			new flash.filters.GlowFilter(0x96AF03, 1, 2,2, 2),
		];
		
		switch( type ) {
			case 0 :
				initLife(4);
			case 1 :
				initLife(2);
				mc.filters = mc.filters.concat([ Color.getColorizeMatrixFilter(0x487E99, 0.7,0.3) ]);
			default :
				throw "err"+type;
		}
		
		animMC = cast mc;
		cacheAnims("mine"+type, 0.7);
		
		setAnim("wait");
		setAnimFrame( Std.random(mc._smc.totalFrames) );
		
		spr.scaleX = spr.scaleY = size;
		spr.rotation = rnd(0,360);
		if( game.perf>=0.8 ) {
			spr.filters = [
				new flash.filters.DropShadowFilter(12,-120, 0x0,0.2, 2,2,1, 1,true),
				new flash.filters.DropShadowFilter(16,90, 0x0,0.4, 16,16,1),
			];
			cachedAnimMC.blendMode = flash.display.BlendMode.ADD;
		}
		
		var spots = r.getEmptySpotsCopy();
		var ok = false;
		while( spots.length>0 && !ok ) {
			var pt = spots.splice( rseed.random(spots.length), 1 )[0];
			var x = pt.x;
			var y = pt.y;
			if( !r.hasMark(x,y) ) {
				setPos(r.cx*Room.CWID + x, r.cy*Room.CHEI + y);
				r.mark(x,y);
				ok = true;
				break;
			}
		}
		if( !ok )
			destroy();
	}
	
	public override function toString() { return super.toString()+"[Mine]"; }
	
	public override function hit(pow:Float, ?from) {
		pow = 1;
		super.hit(pow,from);
		setCD("shield", 5);
	}
	
	public override function onDie() {
		super.onDie();
		var n = 10;
		var base = 0; //rseed.rand()*6.28;
		for( i in 0...n ) {
			var b = new bullet.Bad(this);
			var a = base + 6.28 * i/n;
			b.speed*=1.5;
			b.dx = Math.cos(a)*b.speed;
			b.dy = Math.sin(a)*b.speed;
			b.range = 160;
		}
	}

	public override function update() {
		if( life>1 ) {
			dx = Math.sin( timeOffset(0.05) ) * 0.01;
			dy = Math.sin( timeOffset(0.03) ) * 0.02;
		}
		else {
			dx = Math.sin( timeOffset(0.50) ) * 0.04;
			dy = Math.sin( timeOffset(0.42) ) * 0.03;
		}
		spr.rotation+= dr;
		spr.rotation += pullDx*50;
		
		super.update();

		if( life<=1 && !hasCD("danger") )
			setCD("danger", 15);
		var b = getCD("danger");
		if( b>0 ) {
			var r = b/20;
			spr.transform.colorTransform = Color.getColorizeCT( Color.interpolateInt(0xFF0000,0xFFFF00,r), 0.6 );
		}
		else
			if ( blinkCpt<=0 )
				spr.transform.colorTransform = new flash.geom.ColorTransform();
	}
}
