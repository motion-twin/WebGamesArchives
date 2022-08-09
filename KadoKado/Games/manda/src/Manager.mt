class Manager {

	static var root_mc : MovieClip;
	static var updates : Array<void -> void>;

	static var mode : {
		main : void -> void,
		destroy : void -> void
	}

	static function init(mc) {
		if( !KKApi.available() )
			return;
		updates = new Array();
		root_mc = mc;
		mode = new Game(mc);
	}

	static function main() {
		Timer.update();
		mode.main();
		var i;
		for(i=0;i<updates.length;i++)
			updates[i]();
	}

}