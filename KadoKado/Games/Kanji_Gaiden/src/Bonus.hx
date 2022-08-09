

class Bonus {//}
	var mc 			: flash.MovieClip;
	var type 		: mt.flash.Volatile<Int>;
	var lifeTime 	: Float;
	public var qte 		: mt.flash.Volatile<Int>;

	public function new (bt:Int){
		mc = Game.me.dm.attach("bonus",Game.DP_BONUS);	
		type = bt;
		lifeTime = Cs.bLife;
		mc._xscale = -80;
		mc._yscale = 80;
		mc._x = Cs.mch-35;
		mc._y = Cs.mch-35;
		
		
		
		apply();	
	}
	
	function apply(){
		switch (type) {
			case 0:
			//trace("speed shuriken");
			Game.me.hero.sType = 2;
			qte = Cs.AMMO;
			case 1:
			//trace("power shuriken");
			Game.me.hero.sType = 3;
			qte = Cs.AMMO;
			case 2:
			//trace("iron banana");	
			Game.me.hero.sType = 4;
			qte = Cs.AMMO - 10 ;
			case 3:
			//trace("speed up");
			Game.me.hero.speedy = true;
			
		}
		
		mc.smc.gotoAndStop(type+1); 
			
	}
	
	
	public function update(){
		switch (type) {
			case 0:
			
			case 1:
			
			
			case 2:
			
			
			case 3:
			lifeTime -= mt.Timer.tmod; 
		}
		
		if ( (lifeTime < 0 ) || (qte <0)) {
		destroy();
		}
	}
	
	
	public function destroy(){
		Game.me.hero.sType = 1;
		Game.me.hero.speedy = false;
		
		mc.gotoAndPlay("_vanish");
		Game.me.bonus.remove(this);
	}	
	
	
//{
}







