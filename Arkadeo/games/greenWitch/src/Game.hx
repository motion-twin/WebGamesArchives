import api.AKApi;

import mt.deepnight.Buffer;

class Game extends flash.display.Sprite implements game.IGame {
	public static var ME : Game;
	public var buffer			: Buffer;

	public function new(){
		try { // HACK ------------------------------
		super();
		} catch(e:Dynamic) { throw "ERR00 "+e; } // HACK ------------------------------

		try { // HACK ------------------------------
		ME = this;
		#if dev
		haxe.Log.setColor(0xFFFF00);
		#end
		} catch(e:Dynamic) { throw "ERR01 "+e; } // HACK ------------------------------

		try { // HACK ------------------------------
		buffer = new Buffer(Math.ceil(Const.WID/Const.UPSCALE), Math.ceil(Const.HEI/Const.UPSCALE), Const.UPSCALE, false, 0x0);
		addChild(buffer.render);
		} catch(e:Dynamic) { throw "ERR02 "+e; } // HACK ------------------------------

		try { // HACK ------------------------------
		if( AKApi.getGameMode()==api.AKProtocol.GameMode.GM_LEAGUE )
			new mode.League();
		else
			new mode.Progression();
		} catch(e:Dynamic) { throw "ERR03 "+e; } // HACK ------------------------------
	}

	public function update(render:Bool){
		Mode.updateAll(render);
		if( render )
			buffer.update();
	}
}
