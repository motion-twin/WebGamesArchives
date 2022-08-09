
import Protocole;
enum PlayerPhase {
	PHASE_ZOOM;
	PHASE_PLAY;
}

class Player extends flash.display.Sprite {//}
	
	
	public static var WIDTH = 400;
	public static var HEIGHT = 436;
	
	public static var DP_INTER = 2;
	public static var DP_GAME = 1;
	
	public var game:Game;
	public var dif:Float;
	
	public var end:Bool->Void;

	var phase:PlayerPhase;
	public var dm:mt.DepthManager;
	public static var me:Player;
	
	public var fxm:mt.fx.Manager;
	
	public function new() {
		
		super();
		me = this;
		dm = new mt.DepthManager(this);
		
		
		// UPDATE
		#if dev
		addEventListener(flash.events.Event.ENTER_FRAME, update);
		#else
		addEventListener(flash.events.Event.ENTER_FRAME, secureUpdate);
		#end
		//Main.root.addChild(this);
		
		if( mt.fx.Fx.DEFAULT_MANAGER == null ) 	fxm = new mt.fx.Manager();
		dif = 0;
	}
	
	// UPDATE
	public function secureUpdate(e) {
		try {
			update();
		}catch(e:flash.errors.Error) {
			Main.traceError(Std.string(e));
		}catch(e:Dynamic) {
			Main.traceError(Std.string(e));
		}
	}
	public function update(?e:Dynamic) {

	
		var a = pix.Sprite.all.copy();
		for( sp in a ) sp.update();
		if( fxm!= null ) fxm.update();
		
		
	}
	
	// NEW GAME
	function newGame(id) {
		
		#if dev
		if( Cs.TEST_GAMES.length > 0 ) {
			id = Cs.TEST_GAMES[Std.random(Cs.TEST_GAMES.length)];
			if( game!= null && Cs.TEST_GAME_SWAP != null && game.id != Cs.TEST_GAME_SWAP ) id = Cs.TEST_GAME_SWAP;
		}
		#end
		
		game = Game.getInstance(id);
		game.init(dif);
		game.onSetWin = onSetWin;
		game.end = endGame;
	}
	
	// CALLBACK
	public function onSetWin(win:Bool) {
		
	}
	public function endGame() {
		
	}
	
	//
	public function kill() {
		#if dev
		removeEventListener(flash.events.Event.ENTER_FRAME, update);
		#else
		removeEventListener(flash.events.Event.ENTER_FRAME, secureUpdate);
		#end
		Main.root.removeChild(this);
	}
	
	
//{
}