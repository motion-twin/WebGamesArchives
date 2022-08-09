class Score {

	static var C1000 = KKApi.const(1000);
	static var C100 = KKApi.const(100);
	static var C10 = KKApi.const(10);

	var dmanager : DepthManager;
	var nmiss : int;
	var ncombos : int;
	var combo : Announce;
	var lastKey : int;
	var game_over_flag : bool;

	var slots : Array<bool>;
	var announces : Array<Announce>;

	var color : Color;
	var flash_time : float;

	var stats : {
		$f : int,
		$i : int,
		$m : int,
		$c : Array<int>,
		$k : Array<int>
	};

	function new(dman) {
		dmanager = dman;
		stats = { $f : 0, $i : 0, $m : 0, $c : [0,0,0,0], $k : [] };
		color = new Color(dmanager.getMC());		
		slots = new Array();
		announces = new Array();
		nmiss = 0;
		ncombos = 0;
	}

	function falling() {
		stats.$f++;
		KKApi.addScore( KKApi.const(-KKApi.val(C100)) );
		display(7,0.9,1.1);
	}	

	function invalidKey() {
		stats.$i++;
		nmiss++;
		if( nmiss > 6 )
			nmiss = 6;
		flash_time = 1;
		KKApi.addScore( KKApi.const(-int(nmiss * KKApi.val(C10))) );
		display(8,0.8,1.2);
	}

	function validKey(dist,speed) {		
		var d = dist * Math.sqrt(speed);

		KKApi.addScore(KKApi.const(int(d)));
		if( d < 80 )  {
			stats.$c[0]++;
			display(2,0.95,1.05); // Bouh
		} else if( d < 250 ) {
			stats.$c[1]++;
			display(3,0.9,1.1); // OK
		} else if( d < 300 ) {
			stats.$c[2]++;
			display(4,0.85,1.15); // Great
		} else {
			stats.$c[3]++;
			display(5,0.8,1.2); // Perfect
		}
		
		var time = Std.getTimer();		
		if( time - lastKey < 180 || combo != null ) {			
			ncombos++;
			display(6,0.8,1.2);
			downcast(combo.mc).t.text = ncombos;
		}
		lastKey = time;
	}

	function mixKey(n) {
		stats.$m++;
		KKApi.addScore(KKApi.const(KKApi.val(C1000) * n));
		display(9,0.8,1.2); // mix
	}
	
	function danger() {	
		display(1,0.9,1.1);
	}

	function gameOver() {
		game_over_flag = true;
	}

	function display(frame,zmin,zmax) {
		var is_combo = (frame == 6);

		if( is_combo && combo != null ) {
			combo.time = -1;
			return;
		}

		var i;
		for(i=announces.length-1;i>=0;i--)
			if( announces[i].frame == frame ) {
				announces[i].time = -1;
				return;
			}

		var mc = dmanager.attach("announce",1);
		var slot = 0;
		if( is_combo ) {
			mc._x = 250;
			mc._y = 260;
			slot = -1;
		} else {
			while( slots[slot] )
				slot++;
			slots[slot] = true;
			mc._x = 260 - slot * 40;
			mc._y = 30;
		}
		mc.gotoAndStop(string(frame));
		var a = {
			mc : mc,
			frame : frame,
			z : zmin,
			zmin : zmin,
			zmax : zmax,
			zway : true,
			a : 0,
			time : -1,
			slot : slot
		};
		if( is_combo )
			combo = a;
		announces.push(a);
	}

	function pad(s : String,n) {
		while( s.length < n )
			s = "0"+s;
		return s;
	}

	function finishCombo() {
		combo = null;
		if( ncombos > 0 ) {
			stats.$k.push(ncombos);
			KKApi.addScore(KKApi.const(ncombos * KKApi.val(C100)));
		}
		ncombos = 0;
	}

	function main() {
		var i;

		if( flash_time > 0 ) {
			flash_time -= Timer.tmod / 10;
			if( flash_time < 0 ) {
				flash_time = 0;
				color.reset();
			} else {
				color.setTransform({
					ra : 100,
					rb : int(100 * flash_time),
					ga : 100,
					gb : 0,
					ba : 100,
					bb : 0,
					aa : 100,
					ab : 0
				});
			}
		}

		for(i=0;i<announces.length;i++) {
			var a = announces[i];
			if( a.time == -1 ) {
				a.a += 30 * Timer.tmod;
				if( a.a >= 100 )
					a.time = 0.2;
			} else if( a.time > 0 )
				a.time -= Timer.deltaT;
			else {
				a.a -= 30 * Timer.tmod;
				if( a.a <= 0 ) {
					if( a == combo )
						finishCombo();
					a.mc.removeMovieClip();
					slots[a.slot] = false;
					announces.splice(i,1);
					i--;
				}
			}
			if( a.zway ) {
				a.z += 0.03 * Timer.tmod;
				if( a.z > a.zmax ) {
					a.z = a.zmax;
					a.zway = false;
				}
			} else {
				a.z -= 0.03 * Timer.tmod;
				if( a.z < a.zmin ) {
					a.z = a.zmin;
					a.zway = true;
				}
			}
			a.mc._xscale = a.z * 100;
			a.mc._yscale = a.z * 100;
			a.mc._alpha = a.a;
		}
	}

}