package en;

import mt.deepnight.retro.SpriteLibBitmap;
import flash.display.Sprite;
import flash.display.Bitmap;

class Bomb extends Entity {
	static inline var DELAY = 40;
	
	var warning		: Bitmap;
	var bomb		: BSprite;
	
	public function new(from:Entity, x,y) {
		super();
		
		collides = false;
		weight = 0;
		
		xx = x;
		yy = y;
		updateFromScreenCoords();
		
		var b = game.char.get("bomb", 0);
		game.sdm.add(b, Const.DP_BOMB);
		b.x = from.xx;
		b.y = from.yy-30;
		b.setCenter(0.5,0.5);
		game.tw.create(b, "y", b.y-200, TLinear, 300);
		game.tw.create(b, "alpha", 0, TLinear, 300).onEnd = function() {
			b.parent.removeChild(b);
		}
		
		
		bomb = game.char.get("bomb", 1);
		bomb.setCenter(0.5, 1);
		bomb.visible = false;
		bomb.x = xx;
		bomb.y = yy-150;
		game.sdm.add(bomb, Const.DP_BOMB);
		
		var c = 0xFFFF00;
		var s = new Sprite();
		s.graphics.lineStyle(5, c, 0.5, flash.display.LineScaleMode.NONE);
		s.graphics.drawCircle(0,0,20);
		s.graphics.moveTo(-25,0);
		s.graphics.lineTo(-15,0);
		s.graphics.moveTo(25,0);
		s.graphics.lineTo(15,0);
		s.graphics.moveTo(0, -25);
		s.graphics.lineTo(0, -15);
		s.graphics.moveTo(0, 25);
		s.graphics.lineTo(0, 15);
		s.filters = [ new flash.filters.GlowFilter(0xFF5300,0.9, 8,8, 3) ];
		warning = mt.deepnight.Lib.flatten(s, 8);
		warning.blendMode = flash.display.BlendMode.ADD;
		warning.x = xx-warning.width*0.5;
		warning.y = yy-warning.height*0.5;
		game.sdm.add(warning, Const.DP_BG_FX);
		
		cd.set("arrive", DELAY);
		cd.onComplete("arrive", function() {
			play3dSound( S.BANK.fall01(), mt.deepnight.Lib.rnd(0.1, 0.2) );
		});
	}
	
	override public function destroy() {
		super.destroy();
		bomb.parent.removeChild(bomb);
		warning.bitmapData.dispose();
		warning.parent.removeChild(warning);
		play3dSound( S.BANK.explode05(), 0.3 );
	}
	
	override public function update() {
		super.update();
		
		//warning.scaleX -= 0.03;
		//if( warning.scaleX<0.8 )
			//warning.scaleX = 1;
		//warning.scaleY = warning.scaleX;
		warning.scaleX = 0.5 + 0.5*cd.get("arrive")/DELAY;
		warning.scaleY = warning.scaleX * 0.7;
		warning.x = xx-warning.width*0.5;
		warning.y = yy-warning.height*0.5;
		
		if( !cd.has("arrive") ) {
			warning.alpha = game.time%3==0 ? 1 : 0.5;
			bomb.visible = true;
			bomb.y+=8;
			fx.bombSmoke(bomb.x, bomb.y-5, 0xA3AAC2);
			if( bomb.y>=yy ) {
				fx.explode(xx,yy);
				game.explosion(true, xx,yy, 30, 3, 2);
				fx.burn(xx,yy);
				destroy();
			}
		}
	}
}

