package ac.hero;
import Protocole;
import mt.bumdum9.Lib;



class HealGroupStatus extends Action {//}
	


	var max:Int;
	
	public function new(max) {
		super();
		this.max = max;
		
		
	}
	override function init() {
		super.init();
		var a = [];
		for ( h in game.heroes ) {
			for ( o in h.status ) {
				var data  = Data.STATUS[Type.enumIndex(o.sta)];
				if ( !data.boost ) a.push( { hero:h, status:o.sta } );				
			}
		}
		
		if ( a.length > max ) {
			Arr.shuffle(a);
			a = a.slice(0, max);
		}
		
		
		
		var hstars = [0,0,0];
		for ( o in a ) {
			o.hero.removeStatus(o.status);
			hstars[o.hero.getPos()] += 3;
		}
		
		for ( hid in 0...3 ) {
			var num = hstars[hid];
			if ( num == 0 ) continue;
			var h = game.heroes[hid];
			h.folk.fxHeal();
			h.majInter();
		}
		
		

	}
	
	override function update() {
		super.update();

		if ( timer == 10 ) kill();
		
	}
	
	

	
	//
	


	
	
//{
}