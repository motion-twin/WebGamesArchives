import flash.display.MovieClip;

@:bind
class Spawner extends MovieClip, implements Anim {
	var forceDelay : Float;
	var delay : Float;
	var index : Int;
	public var list : Array<{ delay:Float, cls:Class<Enemy> }>;
	var previous : Enemy;
	var fade : Float;
	var factory : Enemy -> Void;

	public function new( spawnList:Array<{ delay:Float, cls:Class<Enemy> }>, ?f:Enemy->Void ){
		super();
		list = spawnList;
		delay = 0.0;
		forceDelay = 0.0;
		index = 0;
		fade = -1.0;
		factory = f;
	}

	public function setPos( p:{x:Float, y:Float} ){
		x = p.x;
		y = p.y;
	}

	public function update(){
		delay += mt.Timer.deltaT;
		while (index < list.length && (
			(forceDelay != 0 && delay >= forceDelay) ||
			(list[index].delay < 0 && index == 0) ||
			(list[index].delay >= 0 && delay >= list[index].delay)
		)){
			spawn(list[index].cls);
			delay -= list[index].delay;
			forceDelay = 0;
			index++;
		}
		if (index >= list.length){
			if (fade == -1){
				fade = 0;
				Game.instance.spawners.remove(this);
				Game.instance.addAnimation(this);
			}
			fade += mt.Timer.deltaT;
			alpha = 1 - (fade / 2);
			if (alpha <= 0){
				parent.removeChild(this);
				return false;
			}
		}
		return true;
	}

	public function onChildDeath(){
		if (list[index] != null && list[index].delay < 0){
			delay = 0.0;
			forceDelay = -list[index].delay;
		}
	}

	function spawn( cls:Class<Enemy> ){
		var c = Type.createInstance(cls,[]);
		c.spawner = this;
		c.x = x;
		c.y = y;
		if (factory != null)
			factory(c);
		Game.instance.foes.push(c);
		Game.instance.gameLayer.addChild(c);
		if (previous != null && previous.life > 0 && previous.wave && c.wave){
			var prev : WaveEnemy = cast previous;
			var next : WaveEnemy = cast c;
			prev.child = next;
			next.leader = prev;
		}
		previous = c;
	}
}