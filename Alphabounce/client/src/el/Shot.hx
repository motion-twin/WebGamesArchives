package el;
import mt.bumdum.Lib;

class Shot extends Element{//}

	var damage:Float;

	public function new(mc){
		super(mc);
		damage=1;
	}

	override public function update(){
		super.update();
	}

	override function onEnterSquare(sx,sy){
		var mon =  Game.me.monsterGrid[px][py][0];
		if( mon !=null ){
			var mp = mon.getPos();
			var bp = getPos();
			var dx = bp.x - mp.x;
			var dy = bp.y - mp.y;
			var dist = Math.sqrt(dx*dx+dy*dy);
			if( dist < mon.ray+3 ){
				mon.damage(null);
				hit();
			}
		}
	}

	override function onBounce(px,py){
		Game.me.hit(px,py,cast this);
		hit();
		super.onBounce(px,py);

	}
	public function hit(){
		kill();
	}

//{
}













