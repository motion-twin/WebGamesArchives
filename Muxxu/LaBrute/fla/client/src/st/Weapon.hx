package st;
import Data;
import mt.bumdum.Lib;

class Weapon extends State{//}

	var f:Fighter;
	var wid:_Weapons;
	var flBack:Bool;
	var flSab:Bool;
	var flSabMsg:Bool;


	public function new(fid,wid,sab) {
		super();

		f = Game.me.getFighter(fid);
		f.playAnim("show");
		this.wid = wid;
		flSab = sab;
		flSabMsg = false;

		cs = 0.05;
		setMain();

		//f.removeWeapon(wid);

	}



	override function update() {
		super.update();

		if(flBack){
			if( flSab ){
				Col.setPercentColor( f.root, Std.int((1-coef)*100), 0xFF0000);
			}
			
			if(coef>=1){
				end();
				kill();
			}
		}else{
			if(coef>0.25){
				f.setWeapon(wid);
			}
			
			if( coef> 0.6 && flSab && !flSabMsg){
				flSabMsg = true;
				Game.me.fxHab("SABOTAGE",f.root._x, f.root._y-100 );
					
				
			}
			
			if(coef>=1){
				coef = 0;
				cs =0.1;
				flBack = true;
				f.box.smc.smc.gotoAndPlay("back");
				
				if( flSab ){
					var wp = f.fxThrow();
					f.setWeapon(f.gladiator.defaultWeapon);
					f.fxHurt(-1);
					cs = 0.05;
				}
				
				
			}
		}

	}



//{
}