import flash.display.Sprite;

@:bind
class XBall extends Enemy {
	public function new(){
		super();
		life = maxLife = 20;
	}
}

@:bind
class XLink extends Sprite {
}

enum XBallState {
	MOVE;
	WAIT;
	FIRE;
	WAITFIRE;
}

class XBalls extends Enemy {
	var state : XBallState;
	var stateEnd : Float;
	var link : XLink;
	var balls : Array<XBall>;

	public function new(){
		super();
		value = KKApi.const(600);
		balls = [];
		link = new XLink();
		addChild(link);
		for (c in [ {x:-20, y:0, r:0}, {x:0, y:-20, r:90}, {x:20, y:0, r:180}, {x:0, y:20, r:270} ]){
			var b = new XBall();
			b.x = c.x;
			b.y = c.y;
			b.rotation = c.r;
			addChild(b);
			balls.push(b);
		}
		setState(MOVE, 1000);
		life = maxLife = 1000;
	}

	function setState( st, dur ){
		stateEnd = Game.instance.now + dur;
		state = st;
	}

	override public function collideWithShot( shot:Shot ){
		for (b in balls.copy()){
			if (Collision.isColliding(shot, b, Game.instance.gameLayer, false, 0)){
				b.damaged(shot.power);
				if (b.life <= 0){
					removeChild(b);
					balls.remove(b);
					var angle = Geom.deg2rad(rotation);
					var origin = { x:b.x, y:b.y};
					Geom.rotate(origin, angle);
					Game.instance.fxLayer.addChild(b);
					b.x = x + origin.x;
					b.y = y + origin.y;
					var f = new EnemyDeathAnim(b);
					//					f.x = x + origin.x;
					//					f.y = y + origin.y;
					if (balls.length == 0)
						life = 0;
				}
				return true;
			}
		}
		return false;
	}

	override public function update(){
		switch (state){
			case MOVE:
				rotation += mt.Timer.tmod * 5;
				if (Game.instance.now >= stateEnd)
					setState(WAIT, 250);

			case WAIT:
				if (Game.instance.now >= stateEnd)
					setState(FIRE, 0);

			case FIRE:
				var angle = Geom.deg2rad(rotation);
				for (b in balls){
					var origin = { x:b.x, y:b.y};
					Geom.rotate(origin, angle);
					origin.x += x;
					origin.y += y;
					Game.instance.createEnemyLazer(origin, rotation + Geom.angleDeg({x:0.0, y:0.0}, b));
				}
				setState(WAITFIRE, 400);

			case WAITFIRE:
				if (Game.instance.now >= stateEnd)
					setState(MOVE, 1000);
		}
	}
}