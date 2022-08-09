package st;
import Data;

class Medecine extends State{//}

	var f:Fighter;
	var life:Int;



	public function new(fid,life) {
		super();
		this.life = life;
		f =Game.me.getFighter(fid);
		step = 0;
		cs = 0.05;
		f.recal();
		f.playAnim("drink");
		setMain();

	}



	override function update() {
		super.update();

		if(  coef>= 1 ){
			if(step==0){
				coef = 0;
				cs = 0.02;
				f.heal(life);
				step++;
			}else if(step==1){
				f.backToNormal();
				kill();
				end();
			}
		}


	}



//{
}