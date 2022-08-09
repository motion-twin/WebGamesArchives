package ac ;

import Fighter.Mode ;
import Fight ;

class AttackCastle extends State {


	var a : Fighter ;
	var tx : Float;
	var ty : Float;
	var fxt:_CastleEffect;

	var damages:Int;
	var step:Int;

	public function new(f : Fighter, life, ?fxt:_CastleEffect) {
		super();

		damages = life;

		tx = Scene.WIDTH-f.ray;
		ty = f.y;
		this.fxt = fxt;
		this.a = f ;
		addActor(a);
		step = 0;


	}


	override function init() {

		a.playAnim("run");
		a.saveCurrentCoords();
		var dist = a.getDist({x:tx,y:ty});
		spc = a.runSpeed / dist ;
		a.moveTo(tx,ty);


	}


	public override function update() {
		super.update();
		if(castingWait)return;


		switch(step){
			case 0:
				a.updateMove(coef);
				if(coef==1 ){
					a.playAnim("attack");
					var mc = Scene.me.dm.attach("points",Scene.DP_INTER) ;
					var py = Scene.getY(a.y);
					var p = new sp.Score(mc,Scene.WIDTH,py,damages,null);
					spc = 0.1;
					Main.me.castle.damage(damages,a);


				}
			case 1:
				if(coef==1 ){
					a.initReturn( null );
					spc = 0.1;
				}
			case 2:
				a.updateMove(coef);
				if(coef==1 )end();
		}

		if(coef==1){
			coef = 0;
			step++;
		}


	}

}