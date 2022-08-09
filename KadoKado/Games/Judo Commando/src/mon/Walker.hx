package mon;
import Protocole;
class Walker extends Mon {//}


	var walkSpeed:Float;
	public function new(){
		super();
		setSens(1);
		walkSpeed = 0.02;

		initWalk();


	}

	override function update(){

		switch(state){
			case Normal:	updateWalk();
			default:
		}

		super.update();
	}



	function initWalk(){
		state = Normal;
		playAnim("walk");
	}

	function updateWalk(){
		walk(walkSpeed*sens);
	}

	override function initNormal(){
		super.initNormal();
		playAnim("walk");
	}


//{
}
























