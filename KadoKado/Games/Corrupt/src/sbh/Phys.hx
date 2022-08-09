package sbh;

class Phys extends SpriteBehaviour {//}

	public var vx:Float;
	public var vy:Float;
	public var frict:Float;
	public var weight:Float;

	public function new( sp, vx=0.0, vy=0.0, ?w, ?fr ){
		super(sp);
		this.vx = vx;
		this.vy = vy;
		weight = w;
		frict = fr;

	}
	override function update(){
		if( weight != null ) vy += weight;
		if( frict !=null ){
			vx *= frict;
			vy *= frict;
		}
		sp.x += vx;
		sp.y += vy;
	}

//{
}

