package st;
import Data;
import mt.bumdum.Lib;

class Fx extends State{//}

	var f:Fighter;


	public function new(fid,type) {
		super();
		
		f = Game.me.getFighter(fid);
		setMain();

		f.hitFx = type;
		
		/*
		switch(type){
			case 0 : // RESIST
				var mc = Game.me.dm.attach("mcFxResist",Game.DP_PARTS);
				mc._x = f.root._x;
				mc._y = f.root._y;			
		}
		*/

		
		end();
		kill();
		
	}





//{
}