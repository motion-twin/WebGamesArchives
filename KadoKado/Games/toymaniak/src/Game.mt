class Game {//}

	var dmanager : DepthManager;
	var rails : Array<Rail>;
	var sels : Array<{> MovieClip, toy : {> MovieClip, but : MovieClip }, t : int }>;

	var stats : {
		$c : Array<Array<int>>,
		$b : Array<Array<int>>,
		$s : Array<Array<int>>
	};

	var cursor : Toy;
	volatile var nbrokens : int;
	volatile var time : float;
	volatile var speed : float;
	volatile var nbonuses : int;

	function new(mc) {

		if( Std.random(500) == 0 )
			Toy.TOYS[3] = 3;
		else if( Std.random(1000) == 0 )
			Toy.TOYS[3] = 11;
		else if( Std.random(5000) == 0 )
			Toy.TOYS[3] = 10;

		dmanager = new DepthManager(mc);
		var bg = dmanager.attach("bg",0);
		time = 0;
		nbonuses = 0;
		speed = 1;

		var box = downcast(dmanager.attach("box",0));
		box._x = 150;
		box._y = 300;
		nbrokens = 0;

		stats = null;/*{
			$c : [[],[],[]],
			$b : [[],[],[]],
			$s : [[],[],[]]
		};*/

		var i;
		rails = new Array();
		for(i=0;i<3;i++)
			rails[i] = new Rail(this,i);

		sels = [box.s0,box.s1,box.s2];
		for(i=0;i<3;i++) {
			var s = sels[i];
			s.t = Std.random(Const.NELEMENTS);
			s.gotoAndPlay("fall");
			s.onPress = callback(this,selectSlot,i);
			KKApi.registerButton(s);
			updateToy(s,i);
		}
	}

	function updateToy(s,i) {
		s.toy.gotoAndStop(string(Toy.TOYS[s.t]));
		s.toy.but._alpha = 0;
	}

	function initCursor(t : int) {
		cursor = new Toy(this,t,null,true);
		//Std.deleteField(cursor.mc.but,"onPress");
		//cursor.mc.but.onPress = null;
		//cursor.mc.but.useHandCursor = false;
		//KKApi.registerButton(cursor.mc.but);
		cursor.mc.but._visible = false;
		dmanager.swap(cursor.mc,3);
		updateCursor();

	}

	function selectSlot(i : int) {
		var s = sels[i];

		if( s.t == -1 ) {
			if( cursor == null )
				return;
			s.t = cursor.t;
			cursor.destroy();
			cursor = null;
			s.gotoAndStop("16");
			updateToy(s,i);
			return;
		}

		if( cursor == null ) {
			initCursor(s.t);
			s.t = -1;
			s.gotoAndPlay("empty");
		} else {
			var ot = s.t;
			s.t = cursor.t;
			cursor.setType(ot);
			updateToy(s,i);
		}
	}

	function selectToy( t : Toy ) {
		if( t.lock )
			return;

		if( cursor == null ) {
			if( t.t == -1 )
				return;
			initCursor(t.t);
			t.setType(-1);
		} else {
			if( t.t == -1 ) {
				t.setType(cursor.t);
				cursor.destroy();
				cursor = null;
			} else {
				var ot = cursor.t;
				cursor.setType(t.t);
				t.setType(ot);
			}
		}
	}

	function updateCursor() {
		var b = cursor.mc.getBounds(cursor.mc);
		cursor.mc._x = Std.xmouse() - (b.xMin + b.xMax)/2;
		cursor.mc._y = Std.ymouse() - (b.yMin + b.yMax)/2 - 10;
	}

	function main() {
		var i,j;
		time += Timer.deltaT;
		var ok = false;
		for(i=0;i<rails.length;i++)
			if( rails[i].update() )
				ok = true;
		if( cursor != null && cursor.t != -1 )
			ok = true;
		if( sels[0].t != -1 || sels[1].t != -1 || sels[2].t != -1 )
			ok = true;

		updateCursor();
		if( time >= Const.GAMETIME && !ok ) {
			for(i=0;i<rails.length;i++)
				stats.$c[i].push(rails[i].ncombos);
			KKApi.gameOver(stats);
		}
	}

 	function destroy() {
	}
//{
}