

class Line extends mt.bumdum.Phys {//}

	public function new(){
		var mc = Game.me.dm.attach("mcLine",Game.DP_PARTS);
		super(mc);
	}

	override function update(){
		super.update();
		root._rotation = Math.atan2(vy,vx)/0.0174;
		root._xscale = Math.sqrt(vx*vx+vy*vy)*1.5;

	}


//{
}
