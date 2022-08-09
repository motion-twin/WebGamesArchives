
class Runner extends mt.bumdum.Phys {//}



	public var pos:Float;
	public var speed:Float;
	public var acc:Float;

	public var dx:Float;
	public var dy:Float;

	public function new(){
		var mc = Game.me.dm.attach("fxSpark",Game.DP_FX);
		super(mc);
		speed = 0;
		acc = 0;
		pos = 0;
		dx = (Math.random()*2-1)*8;
		dy = (Math.random()*2-1)*8;
	}


	override function update(){

		speed += acc*mt.Timer.tmod;
		if(frict!=null)speed*=Math.pow(frict,mt.Timer.tmod);
		pos += speed;
		if( pos < 0 )pos = 0;

		var p = Cs.getPos(pos);

		x = p.x + dx;
		y = p.y + dy;


		super.update();
	}

//{
}











