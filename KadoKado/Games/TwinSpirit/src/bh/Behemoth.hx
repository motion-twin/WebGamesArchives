package bh;
import Protocol;

class Behemoth extends Behaviour{//}

	static var CDX = 12;
	static var CDY = 17;

	var wait:Float;
	var rob:Robot;

	public function new(){
		super();

	}

	public function init(b){
		super.init(b);
		wait = 0;
	}


	public function update(){
		wait--;
		if(wait<=0){
			var rnd = b.seed.random(3);

			switch(rnd){
				case 0 :

					// MOVE
					var sens = (b.x<Cs.mcw*0.5)?1:-1 ;
					b.vx += 16*sens;
					if( b.y>Cs.mch*0.5)b.vy -= 12; else b.y -= 5;

					// SHOOT
					var dest = [  ShotType(STSpeed),
						PlayAnim("shoot"),ShotPos(-CDX,CDY), Fire(0,0.1), ShotPos(CDX,CDY), Fire(0,0.05), Wait(1), Back(5,8)
					 ];
					b.addDestiny( dest );
					wait = 60;



				case 1 :

					var mult = 3+b.seed.random(5);
					var w = 10;

					var dest = [  ShotType(STSpeed),
						PlayAnim("shoot"),ShotPos(-CDX,CDY), Aim(0.1), ShotPos(CDX,CDY), Aim(0.1), Wait(w), Back(6,mult)
					 ];
					b.addDestiny( dest );
					wait = (mult+1)*w;

				case 2:

					var fr = b.frict;
					var dest = [  Frict(0.75), Wait(5), Frict(0.5), Wait(5), Frict(0),
						ShotType(STNormal), ShotPos(0,0), Turret(23),
						TurretShoot(2),Wait(3),Back(2,30),
						//TurretShoot(4),Wait(2),Back(2,50),
						ShotType(STSpeed),Frict(fr),

					];

					b.addDestiny( dest );


					wait = 160;





			}
		}

	}






//{
}



















