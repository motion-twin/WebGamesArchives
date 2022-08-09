package fx;
import Protocol;
import mt.bumdum9.Lib;

class ElectricWall extends mt.fx.Fx {


	var borders:SP;
	public var infection:Bool;
	
	public var dec:Float;

	public function new() {
		super();
		infection = false;
		
		borders = new SP();
		Game.me.dm.add(borders, Game.DP_BG);
		var ec = 1;
		borders.graphics.beginFill(0xFFFFFF);
		borders.graphics.drawRect(Game.BORDER_X, Game.BORDER_Y, Game.WIDTH - Game.BORDER_X*2, Game.HEIGHT - Game.BORDER_Y*2);
		borders.graphics.drawRect(Game.BORDER_X+ec, Game.BORDER_Y+ec, Game.WIDTH - (Game.BORDER_X+ec)*2, Game.HEIGHT - (Game.BORDER_Y+ec)*2);
		borders.graphics.endFill();
		borders.blendMode = flash.display.BlendMode.ADD;
		
		dec = 0;
		
		Game.me.hero.onCollideWall = heroCollide;
		Game.me.border.gotoAndStop(2);
	}

	override function update() {
		super.update();
		
		dec = (dec +0.1) % 6.28;
		if( Game.me.needRedraw )
		{
			borders.filters = [];
			var c = 1 + Math.sin(dec) * 0.5;
			Filt.glow(borders, 4*c, c * 2, 0xFFFFFF);
			Filt.glow(borders, 6 * c, c*0.5 , 0xFFFF00);
		}
		
		if(infection) {
				if( Game.me.needRedraw )
				{
					var h = Game.me.hero;
					var el = Game.me.setFx("volt_a", h.x + (Math.random() * 2 - 1) * 16, h.y + (Math.random() * 2 - 1) * 16);
					el.shuffleDir();
					el.blendMode = flash.display.BlendMode.ADD;
					Filt.glow(el, 4, 1, 0xFFFF44);
				}
				coef += 0.025;
				if ( coef >= 1 ) {
					Game.me.gameOver();
					kill();
				}
		}
	}
	
	public function heroCollide() {
		if ( infection || Game.me.hero.invincible ) return;
		Game.me.hero.electric = true;
		infection = true;
		coef = 0;
		new mt.fx.Flash(Game.me.bg);
		new mt.fx.Flash(Game.me.border,0.02,0xFFFFFF);
	}
	
	override function kill() {
		super.kill();
	}
}












