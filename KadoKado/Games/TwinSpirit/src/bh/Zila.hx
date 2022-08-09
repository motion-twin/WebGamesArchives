package bh;
import Protocol;

class Zila extends Behaviour{//}

	var wait:Float;

	public function new(){
		super();
	}

	public function init(b){
		super.init(b);
		wait = b.seed.random(20);


	}

	public function update(){
		wait--;

		if(wait<=0){
			var rnd = b.seed.random(3);
			switch(rnd){
				case 0 :
					var w = 2;
					var mult = 4;
					var dest = [ ShotPos(0,10), Aim( 0.2 ), Wait(w), Back(2,mult), Wait(20) ];
					b.addDestiny( dest );
					wait = w*(mult+1)+25;

				case 1 :

					var dest = [ ShotPos(0,10), AddStatus(INVINCIBLE),PlayAnim("protect"),  Aim(0.1), Wait(20), Back(2,3)   , RemoveStatus(INVINCIBLE),PlayAnim("release")];
					b.addDestiny( dest );
					wait = 80+10;

				case 2 :

					var dest = [  ShotPos(0,0), PlayAnim("attack"), Wait(40), ShotType(STSpeed),
					 Fire(0,0.1),Wait(1),Back(2,12), PlayAnim("defense") ];
					b.addDestiny( dest );
					wait = 100;

			}
		}


	}


//{
}