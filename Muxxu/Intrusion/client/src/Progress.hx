import Types;

typedef Bar = {
	mc		: MCField,
	t		: Float,
	target	: Float,
	total	: Float,
	cb		: Void->Void,
	anim	: BarAnim,
}

class Progress {
	static var list		: Array<Bar> = new Array();
	static var kills	: Array<Bar> = new Array();

	public static function start(d:Float, cb:Void->Void, ?label:String, ?anim:BarAnim) {
		if ( label==null ) label = "Chargement...";
		if ( anim==null ) anim = BA_Normal;
		d/=Manager.ME.term.getSpeed();

		if ( d<0.1 ) {
			cb();
			return;
		}

		if ( d>=0.5 )
			Manager.ME.term.startLoop("progress_01");

		var mc : MCField = cast Manager.DM.attach("bar", Data.DP_TOP);
		mc._x = Math.floor( Data.WID*0.5 );
		mc._y = Math.floor( list.length*mc._height*1.1 + 55 );
		mc._x = Data.WID - mc._width-10;
		mc._y = Data.HEI - 50;
		mc.field.text = label;
		mc.smc._xscale = 0;
		mc.onRelease = cancel;
		list.push({
			mc		: mc,
			t		: 0.0,
			target	: 0.0,
			total	: d*32,
			cb		: cb,
			anim	: anim,
		});
	}

	public static function cancel() {
		Manager.ME.term.playSound("single_04");
		Manager.ME.term.stopLoop("progress_01", false);
		Manager.stopLoading();
		destroy(list[0]);
		list.splice(0,1);
	}

	public static function update() {
		// animation de la barre
		var i = 0;
		while ( i<list.length ) {
			var b = list[i];
			b.t+=1;
			var real = Math.round(100 * b.t/b.total);
			b.target = switch(b.anim) {
				case BA_Normal		: real;
				case BA_Chaotic		: if ( Std.random(100)<=94 && real>=10 && real<=85 ) b.target else real;
				case BA_Slow		: if ( Std.random(100)<=92 && real<=85 ) b.target+(real-b.target)*0.01 else real;
			};
			if ( b.mc.smc._xscale<b.target )
				if ( b.anim==BA_Normal )
					b.mc.smc._xscale += (b.target - b.mc.smc._xscale) * (0.1+Std.random(20)/100);
				else
					b.mc.smc._xscale += (b.target - b.mc.smc._xscale) * (0.3+Std.random(20)/100);
			if ( b.t>=b.total ) {
				Manager.ME.term.stopLoop("progress_01", false);
				b.mc.smc._xscale = 100;
				b.cb();
				kills.push(b);
				list.splice(i,1);
				i--;
			}
			i++;
		}

		// disparition
		var i = 0;
		while (i<kills.length) {
			var b = kills[i];
			b.mc._alpha -= 10;
			if ( b.mc._alpha<=0 ) {
				destroy(b);
				kills.splice(i,1);
				i--;
			}
			i++;
		}
	}

	public static function get() : Float {
		return if (list.length>0) list[0].t/list[0].total else 1;
	}

	private static function destroy(b:Bar) {
		b.mc.removeMovieClip();
	}

	public function clear() {
		for (b in list) destroy(b);
		list = new Array();
	}

	public static function isRunning() {
		return list.length>0;
	}
}