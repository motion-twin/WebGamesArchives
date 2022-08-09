package st;


class Leave extends State{//}


	var f:Fighter;

	public function new(fid) {
		super();
		setMain();
		f = Game.me.getFighter(fid);
		f.recal();
		f.setSens(-1);
		f.playAnim("run");
		f.flRecal = false;
	}



	override function update() {

		super.update();
		f.x += (f.team*2-1)*20;
		var ma = 60;
		
		if( f.x<-ma || f.x > Cs.mcw+ma){
			Game.me.fighters.remove(f);
			
			end();
			kill();
		}

	}




//{
}