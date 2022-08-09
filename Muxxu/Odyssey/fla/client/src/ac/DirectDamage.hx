package ac;
import Protocole;
import mt.bumdum9.Lib;



class DirectDamage extends Action {//}
	
	var vic:Ent;
	var damage:Damage;
	
	public function new(vic,value:Int,?types) {
		super();
		if ( types == null ) 	types = [PHYSICAL];			
		this.vic = vic;
		this.damage = {types:types,value:value,source:null};
		
	}
	override function init() {
	
		vic.hit(damage);		

	}
	

	
	// UPDATE
	override function update() {
		super.update();
		if (timer > 20) kill();
		
	}


	
	
//{
}