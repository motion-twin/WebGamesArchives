package st;
import Data;
import mt.bumdum.Lib;
class Poison extends State{//}

	var f:Fighter;
	var damage:Int;
	


	public function new(fid,d) {
		super();
		damage = d;
		f =Game.me.getFighter(fid);
		step = 0;
		cs = 0.2;
		f.recal();


	}



	override function update() {
		super.update();
		
		switch(step){
			case 0:
				if( coef == 1 ){
					step++;
					coef = 0;
					cs = 0.05;					
					f.hurt(damage);
					setMain();					
				}
			case 1:
				var color = 0x00FF00;
				Col.setPercentColor(f.root,Std.int((1-coef)*100),color);
				
				
				if(  coef>= 1 ){			
					f.backToNormal();
					kill();
					end();
				}			
		}
		



	}



//{
}