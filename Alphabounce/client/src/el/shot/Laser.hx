package el.shot;
import mt.bumdum.Lib;

class Laser extends el.Shot{//}

	var flHit:Bool;
	var height:Float;
	var vit:Float;


	public function new(mc){
		super(mc);
		height = 44;
		root.smc._yscale = 0;
		flHit = false;

	}

	override public function update(){
		super.update();
		var sens = 1;
		if(flHit)sens = -1;
		root.smc._yscale = Num.mm( 0, root.smc._yscale+vit*mt.Timer.tmod*sens, height);
 		if( flHit && root.smc._yscale==0 )kill();
		Game.me.plasmaDraw(root);
	}

	public function setVit(n){
		vit = n;
		vy = -n;
	}

	override public function hit(){
		flHit = true;
		vy = 0;
	}





//{
}













