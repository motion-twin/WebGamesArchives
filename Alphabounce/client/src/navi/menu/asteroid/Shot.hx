package navi.menu.asteroid;
import mt.bumdum.Lib;
import mt.bumdum.Phys;


class Shot extends Rel{//}

	public var damage:Float;

	public function new(mc){
		super(mc);
		game.shots.push(this);
		setDamage(1);
	}


	public function setDamage(n){
		damage = n;
		ray = n*2.5;
	}


	override public function update(){
		super.update();

	}




	override public function kill(){
		game.shots.remove(this);
		super.kill();
	}


//{
}








