package seq;
import mt.bumdum9.Lib;
import api.AKApi;

class GameOver extends mt.fx.Sequence {
	
	
	var circle:SP;
	var blast:SP;

	public function new() {
		super();
		// SHOTS
		for( sh in Game.me.shots.copy() ) sh.kill();
		
		// HERO
		var h = Game.me.hero;
		var fl = h.skin.burster.flame;
		fl.scaleX = fl.scaleY = 0;
		// CIRCLE
		var ray = 600;
		circle = new SP();
		circle.graphics.lineStyle(6,0xFFFFFF,0.2);
		circle.graphics.drawCircle(0,0,ray );
		circle.graphics.lineStyle(1,0xFFFFFF);
		circle.graphics.drawCircle(0,0,ray );
		
		Game.me.dm.add(circle, Game.DP_FX);
		circle.blendMode  = flash.display.BlendMode.ADD;
		circle.x = h.x;
		circle.y = h.y+h.zh;
		//
		spc = 0.05;
		//
		Game.me.hero.removeMoveArrow( );
		flash.ui.Mouse.show();
	}

	override function update() {
		super.update();
		
		switch(step) {
			case  0 :
				var c = Math.pow(1 - coef, 2);
				circle.scaleX = circle.scaleY = c;
				if( coef == 1 ) {
					nextStep();
					new mt.fx.Flash(Game.me.hero);
				}
			case 1 :
				if( timer == 10 ) explode();
				
			case 2 : // EXPLODING
				
				var h = Game.me.hero;
				var ec = 12 + coef*34;
				for( i in 0...1 ){
					var mc = new gfx.Explo();
					var sc = (1-coef)+Math.random()*0.2;
					var dx = (Math.random() * 2 - 1) * ec;
					var dy = (Math.random() * 2 - 1) * ec;
					
					var m = new MX();
					m.rotate(Math.random() * 360);
					m.scale(sc, sc);
					m.translate(h.x+dx, h.y+dy);
					Game.me.plasma.draw(mc, m, null, flash.display.BlendMode.ADD);
				}
				//
				if( Math.pow(Math.random(),2) > coef ) #if sound Sfx.play(16) #end
				// PARTS
				fire(6 - 4 * coef);
				//
				blast.scaleX = blast.scaleY = 1-Math.pow(coef, 2);
				if( coef == 1 ) nextStep();
				
			case 3 :
				if( timer == 20 ) {
					AKApi.gameOver(false);
					nextStep();
				}
		}
	}
	
	function fire(ec:Float) {
		var h = Game.me.hero;
		var p = new part.Fire();
		p.vz = -(2 + Math.random() * 3);
		p.vx = (Math.random() * 2 - 1) * ec;
		p.vy = (Math.random() * 2 - 1) * ec;
		p.setPos(h.x + p.vx, h.y + p.vy );
		p.timer += Std.random(16);
		p.root.visible = false;
	}
	
	function explode() {
		nextStep(0.03);
		Game.me.step = 2;
		
		var h = Game.me.hero;
		h.visible = false;
		//
		for( i in 0...16 ) fire(6 + Math.random() * 4);
		// BLOW
		for( b in Game.me.bads ) {
			var dx = b.x - h.x;
			var dy = b.y - h.y;
			
			var ray = 240;
			var pow = 12*Math.max(0,ray - Math.sqrt(dx * dx + dy * dy))/ray;
			
			var an = Math.atan2(dy, dx);
			b.vx += Math.cos(an) * pow;
			b.vy += Math.sin(an) * pow;
		}
		
		// BLAST
		blast = new SP();
		
		var max = 5;
		for( i in 0...max ) {
			var c = i / max;
			blast.graphics.beginFill(0xFFFFFF, 0.1+c*0.5);
			blast.graphics.drawCircle(0, 0, 40-c*14);
			blast.graphics.endFill();
		}
		
		blast.x = h.x;
		blast.y = h.y;
		blast.blendMode = flash.display.BlendMode.ADD;
		Game.me.dm.add(blast, Game.DP_FX);
		
	}
}
