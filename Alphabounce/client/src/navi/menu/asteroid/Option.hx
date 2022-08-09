package navi.menu.asteroid;
import mt.bumdum.Lib;
import mt.bumdum.Phys;


class Option extends Rel{//}

	public var type:Int;

	public function new(mc){
		super(mc);
		game.options.push(this);
		type = Std.random(3);

		var a = Math.random()*6.28;
		var speed = 1;
		vx = Math.cos(a)*speed;
		vy = Math.sin(a)*speed;
		root.gotoAndStop(type+1);

		ray = 10;
		timer = 200;


	}


	//
	override public function update(){
		super.update();

	}


	//
	override public function kill(){
		game.options.remove(this);
		super.kill();
	}


//{
}








