import mt.bumdum.Sprite;
import mt.bumdum.Lib;




class Onde extends Sprite{//}

	var size:Float;
	var coef:Float;
	var tm:Float;
	public var pool:{n:Int,multi:Int};

	public function new( x, y, size ){
		var mc = Game.me.edm.attach("mcOnde",Game.DP_ONDE);
		super(mc);
		this.size = size;
		this.x = x;
		this.y = y;

		coef = 0;
		tm = 0;

		var mc = Game.me.dm.attach("mcImpact",Game.DP_PARTS);
		mc._x = x;
		mc._y = y;
		mc._xscale = mc._yscale = size*8;


	}


	override function update(){
		super.update();

		tm += mt.Timer.tmod;
		while(tm>=1){
			tm--;
			coef += (1-coef)*0.5;
		}
		var ray = size*coef*0.5 + 4;
		root._xscale = root._yscale = ray*2;

		var list = Game.me.missiles.copy();
		for( mis in list ){
			var dx = mis.x - x;
			var dy = mis.y - y;
			var dist = Math.sqrt(dx*dx+dy*dy);
			if( dist < ray && mis.y > 15){

				mis.explode(pool);
				pool.n = Std.int(Math.min(pool.n+1,Cs.SCORE_MISSILE.length-1)) ;
			}
		}

		if(coef > 0.997)kill();
	}



//{
}



























