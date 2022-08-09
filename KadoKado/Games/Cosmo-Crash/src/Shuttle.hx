import mt.bumdum.Lib;

class Shuttle extends Element{//}

	static var ASC = 40;

	var step:Int;
	public var wait:Int;
	var speed:Float;
	var angle:Float;
	var tx:Float;
	var ty:Float;
	var plat:Plat;

	public function new(){
		super( Game.me.dm.attach("mcShuttle", Game.DP_SHUTTLE) );
		speed = 0;
		root.gotoAndStop("flight");
		step = 0;

	}

	override function update(){

		switch(step){
			case 0:
				speed += 0.1;
				speed *= 0.98;

				if( y <-50 )kill();
			case 1:
				if(wait-->0)return;
				root._visible = true;
				if( Num.hMod(tx-x,Cs.lw*0.5) < 3 ){
					step = 2;
					x = tx;
					y = ty - ASC;
					speed = 0;
					updatePos();
				}
			case 2:

				setAngle(angle*0.93);
				y+=1;
				if( y > ty ){
					plat.newShuttle();
					kill();
				}

		}

		vx = Math.cos(angle)*speed;
		vy = Math.sin(angle)*speed;

		super.update();


	}

	public function setAngle(a){
		angle = a;
		root._rotation = a/0.0174;
	}

	public function setPlat(pl:Plat){
		step = 1;

		plat = pl;
		tx = plat.x + plat.skin.rampe._x+10;
		ty = plat.y-10;
		setAngle( 0.3+Math.random()*0.5 );
		var dist = 400;
		x = tx-Math.cos(angle)*dist;
		y = ty-( Math.sin(angle)*dist + ASC );
		speed = 1.5;
		root._visible = false;

		updatePos();

	}




	// ellon in the dark
	// Escape from Lycans

//{
}
















