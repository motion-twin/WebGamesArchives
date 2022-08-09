package fx;
import mt.bumdum9.Lib;



class Gold extends mt.fx.Fx{//}

	var timer:Int;
	var freq:Int;
	var count:Int;
	var onPop:Void->Void;
	public var root:SP;
	
	public function new(count, freq, ?onPop) {
		root = new SP();
		super();
		timer = 0;
		this.count = count;
		this.freq = freq;
		this.onPop = onPop;
		
	}
	
	override function update() {
		super.update();
		
		if ( timer++ > freq ) {
			timer = 0;
			var mc = new fl.CoinAnim();
			var p = new mt.fx.Part(mc);
			p.setPos((Math.random() * 2 - 1) * 18, 0);
			root.addChild(mc);
			p.weight = -(0.1 + Math.random() * 0.05);
			p.timer = 40 + Std.random(10);
			p.fadeType = 2;
			p.fadeLimit = 5;
			//p.setScale(0.6);
			p.twist(12, 1.0);
			p.root.gotoAndPlay(Std.random(20));
			Filt.glow(p.root, 2, 4, 0x442200);
			new mt.fx.Spawn(mc, 0.1,false,true);
			if( onPop!=null )onPop();
			if ( --count == 0 ) kill();
			
		}
	
		
		
	}
	
	
	

	//{
}