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

	override function onBounce(px,py){
		Game.me.hit(px,py,cast this);
		hit();

	}
	public function hit(){
		kill();
	}

//{
}













