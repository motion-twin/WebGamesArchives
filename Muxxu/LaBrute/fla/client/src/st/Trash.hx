package st;
import mt.bumdum.Lib;

class Trash extends State{//}

	var f:Fighter;
	var flDrop:Bool;


	public function new(fid) {
		super();

		f = Game.me.getFighter(fid);
		f.recal();

		f.playAnim("trash");
		cs = 0.05;
		flDrop = false;
		setMain();

	}



	override function update() {
		super.update();

		if(!flDrop && coef > 0.2 ){
			flDrop = true;
			f.fxThrow();
		}

		if(coef>=1){

			f.setWeapon(f.gladiator.defaultWeapon);
			f.backToNormal();
			end();
			kill();
		}
	}



//{
}