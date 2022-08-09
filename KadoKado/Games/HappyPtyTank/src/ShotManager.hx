enum ShotState {
	Shot;
	ShotAngle(f:Void->Float);
	ShotMultiAngles(f:Void->Array<Float>);
	Pause(time:Float);
}

class ShotManager {
	var shooter : Enemy;
	var states : Array<ShotState>;
	var index : Int;
	var time : Float;
	var frame : Int;
	
	public function new( shooter:Enemy, states:Array<ShotState>, ?frame:Int=1 ){
		this.shooter = shooter;
		this.states = states;
		this.index = 0;
		this.time = 0;
		this.frame = frame;
	}

	inline function next(){
		time = Game.instance.now;
		index = (index+1) % states.length;
	}
	
	public function update(){
		switch (states[index]){
			case Shot:
				Game.instance.createEnemyShot(shooter).gotoAndStop(frame);
				next();

			case ShotAngle(f):
				Game.instance.createEnemyShot(shooter, Geom.radToVector(f())).gotoAndStop(frame);
				next();

			case ShotMultiAngles(f):
				for (a in f())
					Game.instance.createEnemyShot(shooter, Geom.radToVector(a)).gotoAndStop(frame);
				next();
				
			case Pause(delay):
				var now = Game.instance.now;
				var elp = now - time;
				if (elp >= delay){
					next();
					time -= elp - delay;
				}
		}
	}	
}