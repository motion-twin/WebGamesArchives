package st;


class ComeIn extends State{//}


	var f:Fighter;
	var sx:Float;
	var tx:Float;

	public function new(f) {
		super();
		step = 0;
		this.f = f;

		cs = 0.1;

		sx = Cs.mcw*0.5 + (Cs.mcw*0.5 + 20)*f.side;
		tx = Cs.mcw*0.5 + (Cs.mcw*0.5 - (80+Math.random()*40) )*f.side;

		f.x = sx;
		f.y = Math.random()*Cs.HEIGHT;
		f.z = -100;

		if( !Game.me.isFree( tx, f.y ) ){
			
			var max = 100;
			for( i in 0...max ){
				f.y = (i/max)*Cs.HEIGHT;
				if( Game.me.isFree(tx,f.y,f) )break;
				if( i == max-1 ) trace("echec");
			}
		}
		
		setMain();

	}



	override function update() {


		super.update();
		if(f.loaded<2)return;

		switch(step){
			case 0:


				f.x = sx*(1-coef) + tx*coef;
				f.z = -Math.cos(coef*1.57)*100;
				f.vz = 0;

				if( coef==1 ){
					f.z = 0;
					f.vz = 0;
					f.weight = 0;
					f.playAnim("land");
					step++;
					coef = 0;
				}
			case 1:
				if( coef == 1 ){
					kill();
					end();					
				}
		}

	}




//{
}