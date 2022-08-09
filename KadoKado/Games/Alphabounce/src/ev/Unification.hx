package ev;
import mt.bumdum.Lib;
import mt.bumdum.Phys;




class Unification extends Event {//}

	var cx:Float;
	var cy:Float;
	var ray:Float;
	var list:Array<{bl:Block,ray:Float}>;

	public function new(){
		super();
		ray = 0;
		list = [];
		cx = Cs.XMAX*0.5;
		cy = 5;
		for( bl in Game.me.blocks ){
			var dx = bl.x-cx;
			var dy = bl.y-cy;
			list.push({bl:bl,ray:Math.sqrt(dx*dx+dy*dy)});
		}

	}

	override public function update(){
		super.update();
		ray+=0.2*mt.Timer.tmod;
		var a = list.copy();
		for( o in a ){
			if( o.ray < ray ){
				list.remove(o);
				o.bl.setType(10);
			}
		}

		//
		var max = Std.int(2+Cs.getPerfCoef()*14);
		var rdec = Math.random();
		for( i in 0...max ){
			var a = (rdec+(i/max-1))*6.28;
			var p = new Phys(Game.me.dm.attach("partTwinkle",Game.DP_PARTS));
			p.x = Cs.getX(cx+0.5+Math.cos(a)*(ray+1));
			p.y = Cs.getY(cy+0.5+Math.sin(a)*(ray+1));
			p.fadeType = 0;
			p.timer = 10+Math.random()*10;
		}

		if(list.length==0)kill();

	}

	override public function kill(){
		super.kill();
	}


//{
}













