package fx;

import mt.bumdum.Lib;

typedef AnimedMovie = { > flash.MovieClip,
	var clip : Null<flash.MovieClip>;
}

class AttachAnim extends State {

	var caster : Fighter;
	var link : String;
	var frame : Null<String>;
	var mc : AnimedMovie;
	
	public function new( f, link, ?frame ) {
		super();
		this.link = link;
		this.caster = f;
		this.frame = frame;
		addActor(f);
	}

	override function init() {
		mc = cast caster.bdm.attach(link, 10);
		if( mc.clip != null && frame != null ) {
			mc.clip.gotoAndStop(frame);
		}
		mc._x = -caster.skin._width / 2;
		mc._y = -caster.skin._height / 2;
		mc.stop();
		mc.gotoAndPlay(1);
	}
	
	override function update() {
		super.update();
		if( castingWait ) return;
		if( mc._currentframe == mc._totalframes ) {
			end();
			mc.removeMovieClip();
		}
	}
}
