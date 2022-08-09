package st;
import Data;
import mt.bumdum.Lib;

class Escape extends State{//}


	var list:Array<Fighter>;
	var att:Fighter;


	public function new(aid,a:Array<Int>) {
		super();

		att = Game.me.getFighter(aid);
		list = [];
		for( fid in a )list.push( Game.me.getFighter(fid) );

		setMain();

		coef = 0;
		cs = 0.05;
		step = 0;

		//att.playAnim("shout");
		att.playAnim("brute");



	}



	override function update() {
		super.update();

		switch(step){
			case 0:
				if(coef>0.75)genVoice();
				if(coef>=1){
					step++;
					for( f in list ){
						f.recal();
						f.playAnim("run");
						f.setSens(-1);
						f.flRecal = false;
					}
				}
			case 1:

				genVoice();

				var a = list.copy();
				for( f in a ){

					f.x += 16*f.side;
					var m = f.ray + 100;
					if( f.x < -m || f.x > Cs.mcw+m ){
						list.remove(f);
						f.kill();
					}
				}
				if( list.length == 0 ){
					att.backToNormal();
					step = 2;
					coef = 0;
					cs = 0.1;
				}
			case 2:
				if(coef>=1){
					end();
					kill();
				}

		}

	}

	function genVoice(){

		var p = new mt.bumdum.Phys( Game.me.dm.attach("partVoice",Game.DP_PARTS) );
		p.x = att.root._x - att.side*(45+Math.random()*25);
		p.y = att.root._y - (17+Math.random()*30);


		p.vx = -att.side*(4+Math.random()*5);
		p.frict = 0.95;

		p.timer = 10+Math.random()*10;
		p.fadeType = 0;

		p.setScale(50+Math.random()*50);

		//Filt.glow(p.root,2,2,0);

	}




//{
}