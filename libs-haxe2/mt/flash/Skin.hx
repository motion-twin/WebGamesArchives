package mt.flash;

class Skin {

	var frames : Hash<Dynamic>;
	var actions : Hash<flash.display.MovieClip -> Void>;

	public function new() {
		frames = new Hash();
		actions = new Hash();
	}

	public function add( name, frame : Int ) {
		frames.set(name,frame);
	}

	public function addString( name, frame : String ) {
		frames.set(name,frame);
	}

	public function addAction( name, frame ) {
		actions.set(name,frame);
	}

	public function apply( mc : flash.display.MovieClip, ?keep ) {
		mc.addEventListener(flash.events.Event.ADDED,onAdded);
		processRec(mc);
		if( !keep ) {
			var inf = {
				mc : mc,
				flag : false,
				clean : null,
			};
			inf.clean = callback(clean,inf);
			mc.addEventListener(flash.events.Event.ENTER_FRAME,inf.clean);
		}
	}

	public function remove( mc : flash.display.MovieClip ) {
		mc.removeEventListener(flash.events.Event.ADDED,onAdded);
	}

	public function stop( mc : flash.display.MovieClip ) {
		mc.stop();
		for( i in 0...mc.numChildren ) {
			var mc = flash.Lib.as(mc.getChildAt(i),flash.display.MovieClip);
			if( mc != null ) stop(mc);
		}
	}

	function clean( inf : { mc : flash.display.MovieClip, clean : Dynamic -> Void, flag : Bool }, _ : Dynamic ) {
		/*
			in some cases, such as when attaching things in event handlers,
			its possible that we will get an enter frame event before the skin
			is actually applied.
		*/
		if( !inf.flag ) {
			inf.flag = true;
			return;
		}
		inf.mc.removeEventListener(flash.events.Event.ADDED,onAdded);
		inf.mc.removeEventListener(flash.events.Event.ENTER_FRAME,inf.clean);
	}

	function skin( mc : flash.display.MovieClip ) {
		var f = frames.get(mc.name);
		if( f != null )
			mc.gotoAndStop(f);
		else {
			var act = actions.get(mc.name);
			if( act != null ) act(mc);
		}
	}

	function onAdded( e : flash.events.Event ) {
		var mc : flash.display.MovieClip = untyped __as__(e.target,flash.display.MovieClip);
		if( mc == null ) return;
		skin(mc);
	}

	function processRec( mc : flash.display.MovieClip ) {
		skin(mc);
		for( i in 0...mc.numChildren ) {
			var sub : flash.display.MovieClip = untyped __as__(mc.getChildAt(i),flash.display.MovieClip);
			if( sub != null ) processRec(sub);
		}
	}

}
