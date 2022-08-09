import Protocole;
import mt.bumdum.Lib;

class Mine extends Ent {//}


	var timer:Int;

	public function new(){
		super( Game.me.dm.attach("mcMine",Game.DP_ENT) );
		timer = 500;
	}

	override function update(){
		super.update();

		if(timer--<0)kill();


		// A OPTIMISER

		var a = getNears(8,HERO);
		for( e in a )boum();

		var a = getNears(16,MONSTER);
		for(e in a )if( e.state == Crash )boum();

		var a = getNears(8,MONSTER);
		for(e in a )if( e.state == KnockOut )boum();






	}

	function boum(){
		if(flDeath)return;
		Game.me.fxShake(36);
		explode(20);
		kill();
	}



//{
}




















