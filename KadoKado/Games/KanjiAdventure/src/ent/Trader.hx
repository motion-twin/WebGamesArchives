package ent;
import Protocol;
import mt.bumdum.Lib;



class Trader extends Ent{//}


	public function new(){
		super();
		flTrader = true;
		lifeMax = 5;
		init();

	}



	//
	override function attach(){
		root = sq.dm.attach("mcTrader",Square.DP_ACTOR);
	}

	//
	override function die(){

		var id = 3;
		if( Std.random(5)==0 ) id = 4;
		sq.addItem(id);
		sq.showItem();

		root.gotoAndPlay("die");
		root = null;

		super.die();
	}

	/*
	public function setSquare(sq:Square){
		//trace("setSq("+sq+")");
		super.setSquare(sq);
	}
	*/

//{
}

/*





enum AttackBehaviour {
	ABRandom(c:Float);
	ABStick;
	ABCoward;
}
enum MoveBehaviour {
	ABFollow;
	ABRandom(c:Float);
}





*/