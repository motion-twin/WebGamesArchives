package mt.deepnight;

#if (flash || openfl)
import flash.display.Sprite;
import flash.display.DisplayObjectContainer;
import mt.Cooldown;
import mt.Delayer;
#end

class Mode {
	#if (flash || openfl)
	public static var DEFAULT_ROOT_PARENT : DisplayObjectContainer = flash.Lib.current;
	#end
	
	static var ALL : Array<Mode> = [];
	static var KILL_LIST : Array<Mode> = [];
	
	#if (flash || openfl)
	public var root			: Sprite;
	#end
	var fps					: Float;
	public var tw			: Tweenie;
	public var cd			: Cooldown;
	public var delayer		: Delayer;
	
	public var time(default,null)		: Int;
	public var rendering(default,null)	: Bool;
	public var paused(default,null)		: Bool;
	public var destroyed(default,null)	: Bool;
	
	
	public function new( #if (flash || openfl) ?parent:DisplayObjectContainer, #end ?fps=30 ) {
		ALL.push(this);
		this.fps = fps;
		paused = false;
		destroyed = false;
		time = 0;
		
		#if (flash || openfl)
		root = new Sprite();
		if( parent!=null )
			parent.addChild(root);
		else
			DEFAULT_ROOT_PARENT.addChild(root);
		#end
		
		delayer = new Delayer(fps);
		tw = new Tweenie(fps);
		cd = new Cooldown();
	}
	
	
	public function destroy() {
		if( !destroyed ) {
			destroyed = true;
			
			pause();
			KILL_LIST.push(this);
			
			cd.destroy();
			delayer.destroy();
			
			#if (flash || openfl)
			root.parent.removeChild(root);
			root = null;
			#end
		}
	}
	
	public function pause() {
		paused = true;
	}
	public function resume() {
		paused = false;
	}
	
	
	private function preUpdate() {
		delayer.update();
		cd.update();
		tw.update();
	}
	
	private function update() {
	}
	
	private function postUpdate() {
	}
	
	private function render() {
	}
	
	public static function flushDestructions() {
		for(m in KILL_LIST)
			ALL.remove(m);
		KILL_LIST = [];
	}
	
	public static function updateAll(?render=true) {
		for(m in ALL)
			if( !m.paused && !m.destroyed ) {
				m.rendering = render;
				m.preUpdate();
				m.update();
				m.postUpdate();
				if( render )
					m.render();
				m.time++;
			}
			
		flushDestructions();
	}
	
	
}
