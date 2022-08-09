package sbh;

class Timer extends SpriteBehaviour {//}

	static var TIME_FACTOR = 1;

	public var t:Float;
	public var fadeType:Int;
	public var fadeLimit:Float;

	public function new( sp, time, ?timeRandom, ft=0, fl=10 ){
		super(sp);
		fadeType = ft;
		fadeLimit = fl;
		t = time;
		if( timeRandom!=null )t+=timeRandom*Math.random();

	}
	override function update(){
		t -= TIME_FACTOR;

		if( t < fadeLimit ){
			var c = t/fadeLimit;
			switch(fadeType){
				case 0:
					sp.root._alpha = c*100;
				case 1:
					sp.root._xscale = sp.scx*c*100;
					sp.root._yscale = sp.scy*c*100;

			}
		}

		if( t <= 0 ){
			sp.kill();
		}

	}

//{
}

