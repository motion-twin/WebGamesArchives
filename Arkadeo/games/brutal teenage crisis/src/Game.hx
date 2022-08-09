import api.AKProtocol;

class Game extends flash.display.Sprite implements game.IGame{
	var mode				: Mode;
	var time				: Int;

	public function new(){
		super();
		#if dev
		haxe.Log.setColor(0xFFFF00);
		#end
		time = 0;

		switch( api.AKApi.getGameMode() ) {
			case GameMode.GM_LEAGUE : new mode.League(this);
			case GameMode.GM_PROGRESSION : new mode.Progression(this);
		}
	}

	public function update(render:Bool){
		mt.deepnight.Process.updateAll(render);
		mt.deepnight.mui.Component.updateAll();
		time++;
	}

}
