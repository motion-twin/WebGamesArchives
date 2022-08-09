package ev;
import mt.bumdum.Lib;
import mt.bumdum.Phys;




class Ouverture extends Event {//}

	var timer:Float;
	var range:Int;


	public function new(){
		super();
		range = 3;




		crush();

	}

	override public function update(){
		super.update();
		timer += mt.Timer.tmod;
		if(timer>10)crush();

		if(range==0)kill();
	}

	public function crush(){

		var list = Game.me.blocks.copy();
		for( bl in list  ){
			if(bl.update!=null){
				bl.removeUpdate();
				bl.kill();
			}
		}


		//
		range--;
		for( n in 0...2 ){
			var sens = (n*2-1);
			var max = Std.int(Cs.XMAX*0.5) +1;
			for( i in 0...max ){
				var sx = Cs.XMAX*n -1;
				var x = sx - i*sens;
				var a = Game.me.grid[x];
				for( bl in a ){
					if(bl!=null){
						/*
						var nx = x+sens;
						if(bl.update!=null){
							bl.removeUpdate();
							bl.kill();
						}
						*/

						var nx = x+sens;
						if( nx>=0 && nx<Cs.XMAX ){


							bl.unregister();
							bl.setPos( nx, bl.y );
							bl.register();
							if(Std.random(3)==0)bl.fxFrout(1);
						}else{
							bl.kill();
						}
					}
				}
			}
		}
		timer = 0;
		Game.me.shake = 10;



	}



//{
}













