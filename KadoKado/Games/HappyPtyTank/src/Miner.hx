private enum State {
	Waiting;
	Rotating;
	InterState;
	Moving;
	Mining;
}

@:bind
class Miner extends Enemy {
	static var WAIT_FRAME = 3;
	static var MOVE_FRAME = 1;
	static var ROTT_FRAME = 2;
	static var INTER_FRAME = 2;
	static var MINE_FRAME = 4;

	static var MARGIN = 40;
	static var SPEED = 1.5;
	static var WAIT_TIME = 1.0;
	static var ROTATE_TIME = 2.0;
	static var MOVE_TIME = 1.0;
	static var INTER_TIME = 0.5;
	static var MINING_TIME = 1.5;
	static var SHOTS = 3;

	var smc : flash.display.MovieClip;
	var state : State;
	var nextState : State;
	var time : Float;
	var shots : Int;
	var interDirection : Int;

	public function new(){
		super();
		life = maxLife = 10;
		value = KKApi.const(200);
		gotoAndStop(WAIT_FRAME);
		state = Waiting;
		nextState = null;
		time = 0;
		shots = 0;
		speed = 1.5 * (60/mt.Timer.wantedFPS);
		interDirection = 1;
	}

	function updateSmc( delta:Float ){
		if (smc == null)
			return;
		smc.gotoAndStop(1+Math.floor(smc.totalFrames * delta));
	}

	function transitionTo( nstate, direction ){
		nextState = nstate;
		state = InterState;
		interDirection = direction;
		time = 0;
	}

	override public function update(){
		time += mt.Timer.deltaT;
		switch (state){
			case Waiting:
				var delta = Math.min(time, WAIT_TIME) / WAIT_TIME;
				updateSmc(delta);
				if (delta >= 1){
					gotoAndStop(ROTT_FRAME);
					state = Rotating;
					time = 0;
				}

			case Rotating:
				state = Moving;
				gotoAndStop(MOVE_FRAME);
				time = 0;

			case InterState:
				var delta = Math.min(time, INTER_TIME) / INTER_TIME;
				if (interDirection == -1)
					updateSmc(1 - delta);
				else
					updateSmc(delta);
				if (delta >= 1){
					time = 0;
					state = nextState;
					switch (nextState){
						case Moving: gotoAndStop(MOVE_FRAME);
						case Waiting: gotoAndStop(WAIT_FRAME);
						case Mining: gotoAndStop(MINE_FRAME);
						default: throw "not gooo";
					}
				}

			case Moving:
				var delta = Math.min(time, MOVE_TIME) / MOVE_TIME;
				updateSmc(delta);
				if (move != null){
					move.update();
				}
				if (delta >= 1){
					if (shots < SHOTS){
						transitionTo(Mining, 1);
					}
					else {
						transitionTo(Waiting, 1);
						shots = 0;
					}
					time = 0;
				}
			case Mining:
				var delta = Math.min(time, MINING_TIME) / MINING_TIME;
				updateSmc(delta);
				if (delta >= 1){
					transitionTo(Moving, -1);
					time = 0;
					shots++;
					var mine = new Mine();
					mine.x = x;
					mine.y = y;
					Game.instance.foesMines.push(mine);
					Game.instance.gameLayer.addChild(mine);
					Game.instance.gameLayer.swapChildren(this, mine);
					gotoAndStop(1);
				}
		}
	}
}