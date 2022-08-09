package bh;

class Mosquito extends Behaviour{//}

	var wait:Float;
	var cs:Float;
	var my:Float;
	var jumpMin:Float;
	var jumpMax:Float;
	var waitMin:Float;
	var waitMax:Float;

	var tx:Float;
	var ty:Float;

	public function new(jumpMin,jumpMax,waitMin,waitMax,?my,?cs){
		if(cs==null)cs = 0.25;
		if(my==null)my = Cs.mch;

		this.jumpMin = jumpMin;
		this.jumpMax = jumpMax;
		this.waitMin = waitMin;
		this.waitMax = waitMax;
		this.cs = cs;
		this.my = my;

		super();
	}

	public function init(b){
		super.init(b);

		nextWp();

	}

	public function update(){

		var dx = tx-b.x;
		var dy = ty-b.y;

		b.vx = dx*cs;
		b.vy = dy*cs;

		if(wait--<0)nextWp();


	}

	public function nextWp(){
		var to = 0;
		while(true){
			var ray = jumpMin + b.seed.rand()*(jumpMax-jumpMin);
			var a = b.seed.rand()*6.28;
			tx = b.x+Math.cos(a)*ray;
			ty = b.y+Math.sin(a)*ray;
			var lim = b.ray;
			if( tx>lim && tx<Cs.mcw-lim && ty>lim && ty<my-lim )break;

			if( to++ >100){
				break;
				trace("ERROR MOSQUITO");
			}
		}

		wait = waitMin + b.seed.rand()*(waitMax-waitMin);


	}






//{
}











