
@:bind
class TheEnd extends flash.display.MovieClip, implements Anim {
	var time : Float;
	var duration : Float;
	public function new(){
		super();
		gotoAndStop(1);
		time = 0;
		duration = 6;
		Game.root.addChild(this);
	}

	public function update() : Bool {
		time += mt.Timer.deltaT;
		var delta = Math.min(1, time / duration);
		gotoAndStop(1+Math.floor(delta*totalFrames));
		if (delta >= 1)
			return false;
		return true;
	}
}

@:bind
class YouDie extends TheEnd {
	public function new(){
		super();
		duration = 0.8;
	}
}