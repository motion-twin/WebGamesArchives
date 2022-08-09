package st;
import Data;
import mt.bumdum.Lib;

class Eat extends State{//}

	var f:Fighter;
	var cad:Fighter;
	var life:Int;

	public function new(fid,life,cid) {
		super();
		this.life = life;
		f = Game.me.getFighter(fid);
		cad = Game.me.getCadaver(cid);

		step = 0;
		cs = 0.05;
		f.recal();
		f.playAnim("eat");
		setMain();

	}



	override function update() {
		super.update();

		switch( step ) {
			case 0 :
				cad.root._alpha = (1-coef)*100;
				cad.shade._alpha = cad.root._alpha;
				if( coef >= 1 ){
					step++;
					coef = 0;
					f.heal(life);
				}
				
				/*
				var p = new mt.bumdum.Phys( Game.me.dm.attach("fxPartFlip",Game.DP_PARTS) );
				p.x = cad.root._x + (Math.random()*2-1)*14 ;
				p.y = cad.root._y ;
				p.weight = -Math.random()*0.5;
				p.timer = 15;
				p.updatePos();
				*/
				
				if( Game.me.gtimer%2 == 0 ){
					var p = new mt.bumdum.Phys( Game.me.dm.attach("fxPartMeat",Game.DP_PARTS) );			

					p.vx = (Math.random()*2-1)*2;
					p.vy = -(2+Math.random()*4);
					p.x = cad.root._x + p.vx *7;
					p.y = cad.root._y - 3;
					
					p.weight = 0.3+Math.random()*0.2;
					p.root._rotation = Math.random()*360;
					p.vr = (Math.random()*2-1)*3;
					p.fr = 0.95;
					p.timer = 16+Std.random(8);
					p.updatePos();
					p.root.gotoAndStop(Std.random(p.root._totalframes)+1);
					p.fadeType = 0;
					Filt.glow(p.root,2,4,0);
				}
				
				
				
			case 1 :
				if( coef >= 1 ){
					
					kill();
					end();
				}
			
		}
		
		//
		
		
		/*
		if(  coef>= 1 ){
			if(step==0){
				coef = 0;
				cs = 0.02;
				f.heal(life);
				step++;
			}else if(step==1){
				f.backToNormal();
				kill();
				end();
			}
		}
		*/


	}



//{
}