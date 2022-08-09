package mod;
import Common;



class Start extends mod.Action{//}

	public function new(?cosmo) {
		super(cosmo);
		//trace("je commence!");
		cosmo.select();

		Game.me.setMsg("Approchez le curseur de votre cosmo");
	}

	// UPDATE
	override function update(){
		super.update();


	}



//{
}











