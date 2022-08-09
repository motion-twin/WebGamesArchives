package ev;
import mt.bumdum.Lib;
import mt.bumdum.Phys;




class UltraViolet extends Event {//}

	static var CYCLE = 4;
	var timer:Float;
	var ammo:Int;

	public function new(){
		super();
		ammo = 30;
		timer = 0;
	}

	override public function update(){
		super.update();
		timer -= mt.Timer.tmod;
		if( timer < 0 ){
			shoot();
			timer = CYCLE;
			ammo--;
			if(ammo==0)kill();
		}

		if( Std.random(3) == 0 ){
			var sp = new fx.Tracer( Game.me.dm.attach("mcUltraRay",Game.DP_BLOCK) );
			sp.x = Cs.mcw*0.5;
			sp.y = Cs.mch+10;
			sp.root._rotation = 90-Math.random()*180 ;
			sp.root.blendMode = "add";
			sp.updatePos();
		}


	}

	function shoot(){
		var yMax = Cs.YMAX;
		var list = [];
		for( i in 0...Cs.YMAX ){
			for( x in 0...Cs.XMAX ){
				var y = Cs.YMAX-(i+1);
				var bl = Game.me.grid[x][y];
				if( bl!=null )list.push(bl);
				if( list.length>6 ) break;

			}
			if( list.length>6 ) break;

		}


		if( list.length>0 ){
			var bl = list[Std.random(list.length)];

			var sp = new fx.Tracer( Game.me.dm.attach("mcUltraViolet",Game.DP_BLOCK) );
			//sp.x = Cs.mcw*Math.random();
			sp.x = Cs.mcw*0.5;
			sp.y = Cs.mch+10;

			var dx = Cs.getX(bl.x+0.5) - sp.x;
			var dy = Cs.getY(bl.y+0.5) - sp.y;

			sp.root._rotation = Math.atan2(dy,dx)/0.0174;
			sp.root._xscale = Math.sqrt(dx*dx+dy*dy);
			sp.updatePos();

			//
			bl.explode();

			// ONDE
			var mc = Game.me.dm.attach("mcOndeAnim",Game.DP_PARTS);
			mc._x = Cs.getX(bl.x+0.5);
			mc._y = Cs.getY(bl.y+0.5);
			mc.blendMode = "add";


		}


	}



//{
}













