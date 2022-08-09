package ac ;
import Fight ;

class Status extends State {

	var f : Fighter ;
	public var status : _Status ;

	public function new(f : Fighter, s : _Status) {
		super();
		this.f = f ;
		this.status = s ;
		addActor(f);
	}

	override function init(){
		f.addStatus(status);
		f.lockTimer = 10;
		end();
	}
}