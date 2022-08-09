package st;
import Data;

class Death extends State{//}

	var f:Fighter;

	public function new(fid) {
		super();

		setMain();

		f = Game.me.getFighter(fid);
		f.flDeath = true;
		Game.me.fighters.remove(f);
		Game.me.cadavers.push(f);

		f.playAnim("death");
		cs = 0.05;


	}



	override function update() {
		super.update();

		if(coef>=1){
			end();
			kill();
		}


	}



//{
}