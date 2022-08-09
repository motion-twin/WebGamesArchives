package ac ;
import Fight ;
import mt.bumdum.Lib;

class Notification extends fx.GroupEffect {

	public var notif : _Notification ;
	var mcs : List<flash.MovieClip>;
	var lf : List<Fighter>;
	public function new( lf : List<Fighter>, n : _Notification) {
		super(null, null);
		this.notif = n ;
		this.lf = lf;
		castingWait = false;
		spc = 0.05;
		init();
	}
	
	override function init() {
		super.init();
		mcs = new List();
		for( f in lf ) {
			var mc = f.bdm.attach("mcNotifIcons", Fighter.DP_FRONT);
			//mc._x = f.root._x;// - mc._width / 2;
			mc._y = -f.skin._height / 2;
			mcs.add(mc);
			//
			var notifName = Std.string(notif).substring(2).toLowerCase();
			mc.gotoAndStop( notifName );
		}
	}
	
	public override function update() {
		super.update();
		if( castingWait ) return;
		
		switch( step ) {
			case 0:
				if( coef == 1.0 ) {
					for( mc in mcs )
						Filt.blur(mc, 0, 1);
					spc = 0.025;
					nextStep();
				}
			case 1:
				for( mc in mcs ) {
					Filt.blur(mc, 0, 1+3*coef);
					mc._y -= 3;
					mc._alpha -= 5;
				}
				if( coef == 1.0 ) {
					for( mc in mcs )
						mc.removeMovieClip();
					end();
				}
		}
	}
}
