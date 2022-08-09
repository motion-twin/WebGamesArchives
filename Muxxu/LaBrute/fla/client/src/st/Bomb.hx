package st;
import Data;

class Bomb extends State{//}


	var damage:Int;
	var f:Fighter;
	var opps:Array<Fighter>;

	var sx:Float;
	var sy:Float;
	var dx:Float;
	var dy:Float;

	var bomb:Phys;

	public function new(fid,damage) {
		super();
		this.damage = damage;
		step = 0;
		f = Game.me.getFighter(fid);



		cs = 0.35;
		f.playAnim("launch");

		setMain();
	}


	override function update() {
		super.update();

		switch(step){
			case 0:
				if(coef>=1){
					bomb = new Phys(Game.me.dm.attach("mcBomb",Game.DP_FIGHTERS));
					bomb.ray = 10;
					bomb.dropShadow();
					bomb.x = f.x;
					bomb.y = f.y+1;
					bomb.z = -50;
					bomb.updatePos();

					coef = 0;
					cs = 0.05;
					step = 1;

					sx = bomb.x;
					sy = bomb.y;
					var tx = Cs.mcw*0.5 - f.side*Cs.mcw*0.25;
					var ty = Cs.HEIGHT*0.5;
					var p = Cs.getTeamMid(1-f.team);
					tx = p.x;
					ty = p.y;
					dx = tx-sx ;
					dy = ty-sy ;

				}
			case 1:
				bomb.x = sx+dx*coef;
				bomb.y = sy+dy*coef;
				bomb.z = -Math.sin(0.14+coef*3)*150;
				opps = [];
				if(coef>=1){
					for( opp in Game.me.fighters ){
						if( opp.team != f.team ){
							var dx = f.x-bomb.x;
							opp.hurt(damage);
							if( (opp.x-bomb.x)*opp.side < 0 ){
								opp.setSens(-1);
								opp.vx *= -1;
							}
							opps.push(opp);

						}
					}
					f.backToNormal();
					step = 2;
					coef = 0;
					cs = 0.07;

					var p = new Phys( Game.me.dm.attach("mcBombExplo",Game.DP_FIGHTERS) );
					p.x = bomb.x;
					p.y = bomb.y;
					p.updatePos();

					Game.me.shake = 10;

					bomb.kill();


				}

			case 2:
				if(coef>=1){
					for(opp in opps){
						opp.setSens(1);
						opp.backToNormal();
					}
					end();
					kill();
				}

		}



	}









//{
}