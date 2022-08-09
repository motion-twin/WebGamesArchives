import Common;
import Anim;

class Option {

	public var mc : flash.MovieClip;
	public var mcLock : flash.MovieClip;
	public var mcSelected : flash.MovieClip;
	public var game : Game;
	public var option : Int;
	public var disabled : Bool;
	public var locked : Bool;

	public function new(game: Game) {
		locked = false;
		disabled = false;
		this.game = game;
		mc = game.dm.attach("mcOption",Const.DP_OPTIONS);
		unLock();
		mc._visible = false;
		mcLock = game.dm.attach("mcOptionLocked",Const.DP_OPTIONS);
		mcLock._visible = false;
		mcSelected = game.dm.attach("mcSelectedOption",Const.DP_OPTIONS);
		mcSelected._visible = false;
	}

	public function move(x,y) {
		mc._x = x;
		mc._y = y;
		mcLock._x = x;
		mcLock._y = y;
		mcSelected._x = x;
		mcSelected._y = y;
	}

	public function hide() {
		lock();
		mcLock._visible = false;
		mcSelected._visible = false;
	}

	public function show() {
		mc._visible = true;
	}

	public function unLock() {
		locked = false;
		mc.gotoAndStop(option);
		mc.onRelease = playOption;
		mc.onRollOver = displaySelector;
		mc.onRollOut = hideSelector;
		mc.onReleaseOutside = hideSelector;
		mc.useHandCursor = true;
		mcLock._visible = false;
	}

	public function lock() {
		locked = true;
		Reflect.deleteField( mc, "onRelease" );
		Reflect.deleteField( mc, "onReleaseOutside" );
		mc.useHandCursor = false;
		mcLock._visible = true;
	}

	public function playOption(){
		locked = true;
		Reflect.deleteField( mc, "onRelease" );
		Reflect.deleteField( mc, "onReleaseOutside" );
		mc.gotoAndStop(21);
//		mcSelected._visible = true;
		game.playOption( option - 1);
	}

	public function display( opt : Int ) {
		this.option = opt;
		mc.gotoAndStop(opt);
		mc._visible = true;
	}

	public function displaySelector() {
		if( disabled ) return;
		game.displayHelp( option - 1 );
		if( locked ) return;
		mcSelected._visible = true;
	}

	public function hideSelector() {
		game.hideOptionSelector(disabled);
		if( !disabled ) game.hideHelp();
		mcSelected._visible= false;
	}

	public function unlockOptions() {
		game.unlockOptions( option - 1);
	}

	// empêche le curseur de sélection d'être désactivé
	public function activate() {
		mc.onRelease = unlockOptions;
		mc.onReleaseOutside = unlockOptions;
	}

	public function disable() {
		disabled = true;
		mc.gotoAndStop(20);
		option = 20;
		Reflect.deleteField( mc, "onRelease" );
		Reflect.deleteField( mc, "onReleaseOutside" );
		Reflect.deleteField( mc, "onRollOut" );
		Reflect.deleteField( mc, "onRollOver");
		mcSelected._visible = false;
	}

	public function clean() {
		mc.removeMovieClip();
		mc = null;
	}
}

