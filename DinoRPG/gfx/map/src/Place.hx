
class Place {

	var map : Map;
	public var mc : flash.MovieClip;
	public var id : String;
	public var px : Int;
	public var py : Int;
	public var target : Bool;
	public var confirm : Bool;
	public var text : String;

	public function new( m, p ) {
		id = p._id;
		map = m;
		mc = map.dmanager.attach("city",2);
		var inf = p._inf.split(":");
		if( inf == null ) {
			// hack
			var r = new mt.Rand(id.charCodeAt(0)+id.charCodeAt(1)+id.charCodeAt(3));
			inf = cast [
				50 + r.random(200),
				50 + r.random(200),
				1,
			];
		}
		px = Std.parseInt(inf[0]);
		py = Std.parseInt(inf[1]);
		mc._x = px;
		mc._y = py;
		text = p._name;
		mc.gotoAndStop(inf[2]);
		mc.onRollOver = callback(map.show,this);
		mc.onRollOut = mc.onReleaseOutside = map.hideText;
		mc.useHandCursor = false;
	}

	public function selectAsCurrent() {
		mc.filters = [new flash.filters.GlowFilter(0xffffff,1,3,3,20)];
	}

	public function selectAsTarget(text,confirm) {
		target = true;
		this.confirm = confirm;
		this.text = text;
		mc.useHandCursor = true;
		mc.onRelease = callback(map.goto,this,confirm);
		map.blinks.push( {mc:mc,t:0.0} );
	}

}