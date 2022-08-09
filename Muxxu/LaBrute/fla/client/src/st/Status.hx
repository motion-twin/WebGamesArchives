package st;
import Data;

class Status extends State{//}

	var f:Fighter;
	var sid:Int;



	public function new(fid,sid,flag) {
		super();
		f = Game.me.getFighter(fid);
		this.sid = sid;
		setMain();



		if( !flag || sid==1 ){
			f.status[sid] = flag;
			kill();
			end();
			return;
		}

		step = 0;
		cs = 0.1;
		switch(sid){
			case 0 : f.playAnim("brute");
		}





	}



	override function update() {
		super.update();

		if(  coef>= 1 ){
			switch(step){
				case 0:
					step++;
					f.status[sid] = true;

					coef = 0;
				case 1:
					f.backToNormal();
					kill();
					end();
			}


		}
	}



//{
}