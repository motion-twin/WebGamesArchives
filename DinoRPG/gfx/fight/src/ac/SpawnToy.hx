package ac ;

import Fighter.Mode ;
import Fight ;

class SpawnToy extends State {

	public static var list:Array<Phys>;
	public static var RAY = 10;

	var tid : Int ;


	public function new(tid:Int,sx:Int,sy:Int,sz:Int,vx:Float,vy:Float,vz:Float ) {
		super();

		if(sz==null)sz = -RAY;
		if(vx==null)vx = 0;
		if(vy==null)vy = 0;
		if(vz==null)vz = 0;

		var toy = new Phys( Scene.me.dm.attach("mcToy", Scene.DP_FIGHTER)  );
		toy.weight = 0.5;
		toy.ray = RAY;
		toy.x = sx;
		toy.y = sy;
		toy.z = sz;
		toy.vx = vx;
		toy.vy = vy;
		toy.vz = vz;
		toy.root.gotoAndStop(tid+1);
		toy.dropShadow();

		if( list == null ) list = [];
		list.push(toy);


	}



	override function update(){

		super.update();
		if(coef==1)end();
	}



}