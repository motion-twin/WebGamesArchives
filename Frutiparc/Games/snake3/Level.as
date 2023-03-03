import snake3.Const;
import snake3.Manager;

class snake3.Level {
	
	public static var BARRE_UP = 60;
	public static var BARRE_DOWN = 10;
	public static var BORDER = 10;
	public static var FRUTIBARRE_SIZE = 15;

	public var corner, corner_down;

	var bg;
	var dmanager;
	var width, height;
	public var fruits, bonuses;

	function Level(dman) {
		dmanager = dman;
		width = Const.WIDTH - BORDER*2;
		height = Const.HEIGHT - (BARRE_DOWN + BARRE_UP);
		corner = { x : BORDER, y : BARRE_UP };
		corner_down = { x : BORDER+width, y :BARRE_UP+height };
		bg = dmanager.attach("background",Const.PLAN_BACKGROUND);
		bg.playField._x = corner.x;
		bg.playField._y = corner.y;
		bg.playField._width = width;
		bg.playField._height = height;
		fruits = new Array();
		bonuses = new Array();
	}



	function bounds() {
		return { left : corner.x, top : corner.y, right : corner.x + width, bottom : corner.y + height };
	}

	function nfruits() {
		return fruits.length;
	}

	function nbonus() {
		return bonuses.length;
	}

	function generate_pos(mc,w,h) {
		var b = BORDER+10;		
		var x = b+random(int(Const.WIDTH-b*2-w))+w/2;
		var y = b+BARRE_UP+random(int(Const.HEIGHT-b*2-h-BARRE_UP-FRUTIBARRE_SIZE))+h/2;
		mc._x = x;
		mc._y = y;
	}

	function generate_fruit(id) {
		var f = dmanager.attach("snake3_fruit",Const.PLAN_FRUITS);
		var time = 250+random(125);
		var fmc = Std.getVar(f,"f")
		fmc.gotoAndStop(id);		
		generate_pos(f,fmc._width*(100/fmc._xscale),fmc._height*(100/fmc._yscale));
		var fruit : snake3.Fruit = Std.cast(f);
		fruit.init(dmanager,id,time);
		fruits.push(fruit);
		//Manager.smanager.play(Const.SOUND_FRUIT_APPEAR);
		return fruit;
	}

	function generate_bonus(id) {
		var b = dmanager.attach("snake3_bonus",Const.PLAN_BONUSES);
		var time = 300+random(150);
		var fmc = Std.getVar(b,"f")
		fmc.gotoAndStop(id);		
		generate_pos(b,fmc._width*(100/fmc._xscale),fmc._height*(100/fmc._yscale));
		var bonus : snake3.Bonus = Std.cast(b);
		bonus.init(dmanager,id,time);
		bonuses.push(bonus);
		return bonus;
	}

	function update(game) {
		var i;
		for(i=0;i<fruits.length;i++) {
			var f = fruits[i];
			if( !f.move() ) {
				Manager.smanager.play(Const.SOUND_DISAPPEAR);
				f.timeout();
				fruits.remove(f);
			}
		}
		for(i=0;i<bonuses.length;i++) {
			var b = bonuses[i];
			b.update(game);
			b.time -= Std.tmod;
			if( b.time <= 0 ) {
				Manager.smanager.play(Const.SOUND_DISAPPEAR);
				b.timeout();
				bonuses.remove(b);
			}
		}
	}

	function get_fruit(col) {
		var i;
		for(i=0;i<fruits.length;i++) {
			var f : snake3.Fruit = fruits[i];
			if( f.eat(col) ) {
				fruits.remove(f);
				return f;
			}
		}
		return null;
	}

	function hit_fruit(mc) {
		var i;
		for(i=0;i<fruits.length;i++) {
			var f : snake3.Fruit = fruits[i];
			if( Std.hitTest(f,mc) ) {
				fruits.remove(f);
				return f;
			}
		}
		return null;
	}

	function pushFruit(f) {
		fruits.push(f);
	}

	function get_bonus(col) {
		var i;
		for(i=0;i<bonuses.length;i++) {
			var b : snake3.Bonus = bonuses[i];
			if( !b.isMoving() && Std.hitTest(b,col) ) {
				bonuses.remove(b);
				return b;
			}
		}
		return null;
	}

}