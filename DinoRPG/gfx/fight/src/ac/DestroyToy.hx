package ac ;

import Fighter.Mode ;
import Fight ;

class DestroyToy extends State {

	var tid : Int ;


	public function new(tid) {
		super();
		this.tid = tid;

		var a = ac.SpawnToy.list.copy();
		for( toy in a ){
			if( toy.root._currentframe-1 == tid ){
				toy.kill();
				ac.SpawnToy.list.remove(toy);
				break;
			}
		}

	}

	override function update(){

		super.update();
		if(coef==1)end();
	}




}