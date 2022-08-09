import mt.bumdum.Lib;
import mt.bumdum.Sprite;


class Shot extends Pix{//}

	static var AIR_FRICT = 0.99;

	public var flOrient     : Bool;
	public var angle        : Float;
	public var speed        : Float;
	public var weight       : Float;
	
	public var damage       : Float;
	public var rayExplosion : Float;
	public var shockId      : Int;
	
	public var owner	: Hero;
	
	public function new(){
		Cs.game.shotList.push(this);
		var mc = Cs.game.dm.attach("mcShot",Game.DP_SHOT);
		super(mc);
		
		angle = 0;
		speed = 0;
		weight = 0;
		shockId = 0;
		rayExplosion = 50;
		
	}
	
	
	public function update(){
		super.update();
		if(flOrient)orient();
		fly2();
		MMApi.print(vx);
		MMApi.print(vy);
		
		vy += weight;
		
		vx *= AIR_FRICT;
		vy *= AIR_FRICT;
		
	}
	
	// BOUNCE
	function onBounce(a,n){
		switch(shockId){
			case 0:
				explode();
			
		}
	}
	
	// EXPLODE
	function explode(){
		//map.makeHole(link,x,y,sx,sy)
		var sc = (rayExplosion*2)/100;
		Cs.game.map.makeHole("mcHoleRound",px,py,sc,sc);
		Cs.game.map.focus = cast owner;
		kill();
	}
	
	// SET VALUE
	public function setSpeed(n){
		speed = n;
		updateVit();
	}
	public function setAngle(a){
		angle = a ;
		updateVit();
	}
	public function updateVit(){
		vx = Math.cos(angle)*speed;
		vy = Math.sin(angle)*speed;
	}
	public function orient(){
		angle = Math.atan2(vy,vx);
		root._rotation = angle/0.0174;
	}
	
	public function kill(){
		Cs.game.shotList.remove(this);
		super.kill();
	}


//{	
}


