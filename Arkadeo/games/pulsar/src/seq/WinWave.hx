package seq;
import mt.bumdum9.Lib;


@:build(mt.kiroukou.macros.IntInliner.create([
	CLEAN,
	MOVE,
	DISPLAY_SCREEN,
	WAIT,
	END
]))
class WinWave extends mt.fx.Sequence {

	public function new() {
		super();
		flash.ui.Mouse.show();
		Game.me.hero.removeMoveArrow( );
		
		var hero = Game.me.hero;
		hero.shooting = false;
		hero.invincible = true;
		hero.noFollow = true;
		
		sx = hero.x;
		sy = hero.y;
		spc = 0.018;
	}
	
	var sx:Float;
	var sy:Float;
	
	override function update() {
		super.update();
		var hero = Game.me.hero;
		switch(step) {
			case MOVE :
				//move hero to screen center
				var cx = Game.WIDTH / 2;
				var cy = Game.HEIGHT / 2;
				var dx = cx - sx;
				var dy = cy - sy;
				//
				hero.x = sx + dx * coef;
				hero.y = sy + dy * coef;
				hero.orient(coef * 6.28);
				//
				if( cx == hero.x && cy == hero.y )
					nextStep();
			case CLEAN:
				if( timer % 2 == 0 )
				{
					var s = fx.Spawn.ALL.pop();
					if( s != null ) s.kill();
					var b = Game.me.bads.pop();
					if( b != null ) b.dust();
					if( fx.Spawn.ALL.length == 0 && Game.me.bads.length == 0 )
						nextStep();
				}
			case DISPLAY_SCREEN:
				hero.shooting = false;
				var label = switch( api.AKApi.getGameMode() ) {
					case GM_PROGRESSION: Texts.levelCleared;
					case GM_LEAGUE: Texts.gameOver;
				}
				var labelSubtitle = switch( api.AKApi.getGameMode() ) {
					case GM_PROGRESSION: Texts.levelClearedSubtitle;
					case GM_LEAGUE: api.AKApi.getScore() + " pts";
				}
				new fx.FinalScreen( 100, label, labelSubtitle ).onFinish = function() {
					nextStep();
				}
				nextStep();
				
			case WAIT:
				
			case END :
				if( timer == 50 ) {
					kill();
					nextStep();
				}
		}
	}
}
