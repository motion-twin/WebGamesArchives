import Data._Super;
import Data._Talent;
typedef MC = flash.MovieClip;
typedef TF = flash.TextField;

class Inventory {

	public static var WIDTH = 310;
	public static var HEIGHT = 600;

	var data : Data.InventoryData;
	var dm : mt.DepthManager;
	var gl : Gladiator;
	var bonus : Array<Int>;
	var weapons : Array<MC>;
	var mcPet: {> MC, dog:MC, num:MC, big:MC };
	var mcHint : {> MC, field:TF, d1 : TF, d2 : TF, ico : MC } ;
	var names : Array<String>;

	function new(mc) {
		data = Codec.getData("data");
		Lang.setLang(data._l);
		dm = new mt.DepthManager(mc);
		dm.attach("mcBg",0);

		names = [];
		for( id in 0...Lang.PCOUNT )
			names.push( Lang.PERMANENTS[id] );
		for( id in 0...Lang.SCOUNT )
			names.push( Lang.SUPERS[id] );
		for( id in 0...Type.getEnumConstructs(_Talent).length )
			names.push( Lang.TALENTS[id] );

		initGladiator();
		initWeapons();
		initIcons();
		initPets();
	}

	function initGladiator() {
		gl = new Gladiator(data._s);
		gl.setLevels(data._level,data._bits);
		//gl.setLevels(100,haxe.io.Bytes.alloc(100));
		bonus = [];
		if( data._a )
			for( i in 0...Lang.PCOUNT + Lang.SCOUNT + Type.getEnumConstructs(_Talent).length )
				bonus.push(i);
		else
		for( b in gl.bonus ){
			switch(b){
			case Permanent(p):
				bonus.push( Type.enumIndex(p) );
			case Super(s):
				bonus.push( Type.enumIndex(s)+Lang.PCOUNT );
			case Followers(f):
			case Weapons(w):
			case Talent(t):
				bonus.push( Type.enumIndex(t)+Lang.PCOUNT+Lang.SCOUNT );
			}
		}
	}

	function initWeapons() {
		var wmc = dm.attach("mcWeapons",0);
		wmc._xscale = wmc._yscale = 97;
		wmc._x = 10;
		wmc._y = 8;
		weapons = [];
		var id = 1;
		while(true){
			var mc = Reflect.field(wmc,"_w"+id);
			weapons.push(mc);
			if( mc==null && id!=12 )break;
			id++;
			mc._visible = false;
		}
		//
		for( wp in gl.weapons ){
			var id = Type.enumIndex(wp);
			weapons[id-1]._visible = true;
		}
	}

	function initIcons(){
		var fl = getShadowFilter();
		var mod = 7;
		var icons = [];
		var ec = 42;
		for( i in 0...names.length ){
			var mc = dm.attach("mcIcons",0);
			mc._x = 14 +(i%mod)*ec;
			mc._y = 220 + Std.int(i/mod)*ec;
			mc.gotoAndStop(i+1);
			mc.filters = [fl];
			mc._alpha = 20;
			icons.push(mc);
		}
		for( id in bonus ){
			var mc = icons[id];
			mc._alpha = 100;
			makeHint(mc,id);
		}
	}

	function initPets(){
		mcPet = cast dm.attach("pets",1);
		mcPet._y = HEIGHT;
		var dogs = 0;
		var bigPet = null;
		for( fol in gl.followers ){
			switch(fol){
				case DOG_0 :	dogs++;
				case DOG_1 :	dogs++;
				case DOG_2 :	dogs++;
				case PANTHER :	bigPet = 0;
				case BEAR :	bigPet = 1;
			}
		}
		mcPet.dog._visible = dogs > 0;
		mcPet.num._visible = dogs > 1;
		mcPet.big._visible = bigPet!=null;
		mcPet.big.gotoAndStop(bigPet+1);
		mcPet.num.gotoAndStop(dogs-1);
	}

	// UPDATE
	public function update() {

	updateHint();

	}

	//
	public function makeHint(mc:flash.MovieClip,id){
		mc.onRollOver = callback(displayHint,id);
		mc.onDragOver = callback(displayHint,id);
		mc.onRollOut = killHint;
		mc.onDragOut = mc.onRollOut;
		//mc.onReleaseOutside = mc.onRollOut;
	}
	function displayHint(id){
		if(mcHint==null){
			mcHint = cast dm.attach("mcHint",2);
			var fl = getShadowFilter();
			mcHint.filters = [fl];
			mcHint.field.text = names[id];

			//
			var t = Lang.DESCRIPTIONS[id];
			var t2 = t.split(" ");
			var t1 = new Array();

			while( mcHint.d1.maxscroll <= 1 && t2.length > 0 ){
				t1.push(t2.shift());
				mcHint.d1.text = t1.join(" ");
			}
			if( mcHint.d1.maxscroll > 1 )
				t2.unshift(t1.pop());
			mcHint.d1.text = t1.join(" ");
			mcHint.d2.text = ( t2.length > 0 ) ? t2.join(" ") : "";
		}

		mcHint.ico.gotoAndStop(id+1);
		updateHint();
	}
	function killHint(){
		mcHint.removeMovieClip();
		mcHint = null;
	}
	function updateHint(){
		var ma = 5;
		var pos = dm.getMC()._xmouse-mcHint._width*0.5;
		if( pos < ma ) pos = ma;
		pos = Math.min(pos,WIDTH-(ma+mcHint._width));
		mcHint._x = Std.int( pos );
		mcHint._y = Std.int( dm.getMC()._ymouse )+20;
	}

	//
	function getShadowFilter(){
		var fl = new flash.filters.DropShadowFilter();
		fl.blurX = 4;
		fl.blurY = 4;
		fl.strength = 0.25;
		fl.angle = 45;
		fl.distance = 4;
		fl.color = 0x660000;
		return fl;
	}

	static var inst : Inventory;
	static function main() {
		inst = new Inventory(flash.Lib._root);
	}

}