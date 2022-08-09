package cell;

import mt.bumdum9.Lib;

class Hero extends Cell{//}
	
	var arrow:McArrow;
	
	public function new(r) {
		super(r);
		consume = true;
		sprite.env.gotoAndStop(3);
		sprite.noyau.gotoAndStop(3);	
		
		arrow = new McArrow();
		arrow.blendMode = flash.display.BlendMode.ADD;
		Game.me.lvl.dm.add(arrow, 3);
		
	}
	
	/*
	override function draw() {
		drawCircle( 0xAA9988,0xCCBBAA);
	}
	*/
	
	override function update() {
		
		// CONTROL
		var an = Math.atan2(sprite.mouseY, sprite.mouseX);
		arrow.alpha = 0.2;
		arrow.filters = [];
		if( Game.me.click ) {
			arrow.alpha = 1;
			Filt.glow(arrow, 4, 0.5, 0xFFFFFF);
			var acc = 0.125 + (0.2 / Game.me.lvl.scale)*0.25;
			vx += Math.cos(an)*acc;
			vy += Math.sin(an)*acc;
		}
		
		
		// FRICT
		var frict = 0.98;
		vx *= frict;
		vy *= frict;
		
		// TIMER
		var lim = 2500 - Game.me.dif * 200;
		var c = Game.me.timer / lim;
		//sprite.noyau.scaleX = sprite.noyau.scaleY = (1-c) * 2;
		if( Game.me.timer > lim ) {
			var area = getDiscArea(ray);
			grow( -area * 0.01);
		}
		
	
		//
		super.update();
		
		// ARROW
		var ma = 3 / Game.me.lvl.scale;
		arrow.x = x + Math.cos(an) * (ray + ma);
		arrow.y = y + Math.sin(an) * (ray + ma);
		arrow.rotation = an / 0.0174;
		arrow.scaleX = arrow.scaleY = 0.5 / Game.me.lvl.scale;
		//arrow.scaleX = arrow.scaleY = 1;
		
		//arrow.scale = 8;
		
	}
	
	override function grow(inc) {
		super.grow(inc);
		if( inc < 0 ) {
			Game.me.pink.alpha += 0.1;
		}
	}
	
	
	override function kill() {
		super.kill();
		arrow.parent.removeChild(arrow);
		vx = 0;
		vy = 0;
		Game.me.pink.alpha = 1;
	}
	
	
	override function eat(c,dif) {
		super.eat(c,dif);
		if( c.dead ) scoreCell(c);
	}
	
	function scoreCell(c:Cell) {
		//fxFlash();
		
		var score =  KKApi.const(25);
		if( c.baseRay > 16 ) score = KKApi.const(50);
		if( c.baseRay > 50 ) score = KKApi.const(100);
		if( c.baseRay > 80 ) score = KKApi.const(200);
		KKApi.addScore( score );
		
		
		var mc = new McScore();
		mc.gfx.field.text = Std.string(KKApi.val(score));
		Game.me.lvl.dm.add(mc,4);
		var sp = new Element(mc,c.sprite.x,c.sprite.y);		
		
		var sc = 0.75;
		if( c.baseRay > 16 ) sc = 2;
		if( c.baseRay > 50 ) sc = 3.5;
		if( c.baseRay > 80 ) sc = 5;
		
		var lim = 0.5;
		if( sc * Game.me.lvl.scale < lim ) {
			sc = lim / Game.me.lvl.scale;
		}
			
		mc.scaleX = mc.scaleY = sc;
		
		var base = 50;
		var inc = 255 - base;
		var color = Col.objToCol( { r:base + Std.random(inc), g:0, b:base + Std.random(inc) } );
	
		var fl = new flash.filters.GlowFilter(color, 1, 2, 2, 10);
		mc.gfx.field.filters = [fl];

		
		//mc.scaleX = mc.scaleY = 1 / Game.me.lvl.scale;
		
	}
	
//{
}





















