package fx;

class MudWall extends State {

	var f : Fighter;
	var remove : Bool;
	
	public function new(f : Fighter, remove : Bool) {
		super();
		this.f = f;
		this.remove = remove;
		addActor(f);
	}
	
	override function init() {
		super.init();
		if( remove )  {
			f.fxRemoveMudWall();
		} else {
			f.fxMudWall();
		}
		haxe.Timer.delay( end, 1000 );
	}
	
}