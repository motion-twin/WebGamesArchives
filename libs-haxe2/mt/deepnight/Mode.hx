package mt.deepnight;

import flash.display.Sprite;

class Mode {
	static var ALL : Array<Mode> = [];
	static var KILL_LIST : Array<Mode> = [];
	
	var fps					: Float;
	public var root			: Sprite;
	public var tw			: Tweenie;
	public var cd			: Cooldown;
	public var delayer		: Delayer;
	public var time			: Int;
	
	public var rendering(default,null)	: Bool;
	var paused				: Bool;
	var destroyed			: Bool;
	
	
	public function new(?fps=30) {
		ALL.push(this);
		this.fps = fps;
		paused = false;
		destroyed = false;
		time = 0;
		
		root = new Sprite();
		delayer = new Delayer(fps);
		tw = new Tweenie(fps);
		cd = new Cooldown();
	}
	
	
	public function destroy() {
		if( !destroyed ) {
			destroyed = true;
			pause();
			root.parent.removeChild(root);
			KILL_LIST.push(this);
		}
	}
	
	
	public function pause() {
		paused = true;
	}
	public function resume() {
		paused = false;
	}
	
	
	public static function updateAll(?render=true) {
		for(m in ALL)
			if( !m.paused && !m.destroyed ) {
				m.rendering = render;
				m.update();
			}
			
		for(m in KILL_LIST)
			ALL.remove(m);
		KILL_LIST = [];
	}
	
	
	private function update() {
		delayer.update();
		tw.update();
		cd.update();
		time++;
	}
}
