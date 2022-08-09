class Main { //}

	static function main() {
		haxe.Log.setColor(0xFFFF00);
		flash.Lib.current.addEventListener( flash.events.Event.ENTER_FRAME, update );

		new Game();
	}

	static function update(_) {
		mt.deepnight.Process.updateAll();
	}

}
