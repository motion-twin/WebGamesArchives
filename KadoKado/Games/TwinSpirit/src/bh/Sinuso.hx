package bh;

class Sinuso extends Behaviour{//}

	var xmin:Float;
	var xmax:Float;
	var ymin:Float;
	var ymax:Float;

	var vx:Float;
	var vy:Float;

	var dcx:Float;
	var dcy:Float;

	public function new(xmin,xmax,ymin,ymax,vx,vy){

		this.xmin = xmin;
		this.xmax = xmax;
		this.ymin = ymin;
		this.ymax = ymax;

		this.vx = vx;
		this.vy = vy;

		super();
	}

	public function init(b){
		super.init(b);

		dcx = (1-b.x/Cs.mcw) * 314;
		dcy = 0;


	}

	public function update(){

		dcx = (dcx+vx)%628;
		dcy = (dcy+vy)%628;

		var tx = xmin+b.ray+ ( 1+Math.cos(dcx*0.01) ) * (xmax-(xmin+b.ray*2)) * 0.5;
		var ty = ymin+b.ray+ ( 1+Math.cos(dcy*0.01) ) * (ymax-(ymin+b.ray*2)) * 0.5;

		//b.x = tx;
		//b.y = ty;

		var c = 0.1;

		b.vx += (tx-b.x)*c;
		b.vy += (ty-b.y)*c;

		b.vx *= 0.9;
		b.vy *= 0.9;



	}


//{
}