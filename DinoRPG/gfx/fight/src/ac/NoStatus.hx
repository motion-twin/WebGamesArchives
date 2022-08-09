package ac ;

import Fight ;

class NoStatus extends State {

	var f : Fighter ;
	var status : _Status ;

	public function new(f : Fighter, s : _Status) {
		super();
		this.f = f ;
		this.status = s ;
		addActor(f);
	}

	override function init(){
		f.removeStatus(status);
		f.lockTimer = 5;
		end();
	}
}