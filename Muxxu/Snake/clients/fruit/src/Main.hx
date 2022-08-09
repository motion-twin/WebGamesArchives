import Protocole;
import mt.bumdum9.Lib;
typedef FruitNum = { id:Int, num:Int };

class Main{//}
	
	public static var MOUSE_IN = false;
	
	public static var MAX = 8;
	public static var COLUMNS = 2;
	public static var MARGIN = 2;
	public static var mcw = 440;
	public static var mch = 212;
	
	public static var PAGE_MAX = 0;
	public static var LEFT_MARGIN = 0;
	
	public static var root:flash.display.Sprite;
	public static var vigs:Array<Vig>;
	public static var buts:Array<But>;
	public static var page:Int;
	public static var data:Array<FruitNum>;
	public static var fieldPage:flash.text.TextField;
	
	public static var screen:pix.Screen;
	
	static function main() {
		Gfx.init();
		Lang.init();
		Codec.VERSION = Data.CODEC_VERSION ;
		//Data.init();
		root = new flash.display.Sprite();
		root.graphics.beginFill(0xFFFFFF);
		root.graphics.drawRect(0, 0, mcw, mch);
		var params = flash.Lib.current.loaderInfo.parameters;
		
		var fp:_FruitPage;
		if( Reflect.field(params, "data") != null ) {
			fp = Codec.getData("data");
		}else {
			fp = { _list:[] };
			for( i in 0...301 ) fp._list.push(Std.random(10));
		}
		
		data = [];
		for( id in 0...DFruit.MAX ) data.push( { id:id, num:fp._list[id] } );
		data.sort(sortData);
		
		PAGE_MAX = Std.int(DFruit.MAX / MAX);
		LEFT_MARGIN = Std.int((mcw - (COLUMNS * Vig.WIDTH + (COLUMNS - 1) * MARGIN)) * 0.5);
		
		// SCREEN
		screen = new pix.Screen(root, mcw*2, mch*2 , 2);
		flash.Lib.current.addChild(screen);
				
		// DISPLAY
		vigs  = [];
		page = 0;
		initMouseTracker();
		initButtons();
		displayPage();
		
		flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME, update);
		
	}
	
	static public function update(e) {
		for( b in buts ) b.update();
	}
	
	static public function initButtons() {
		
		// FIELD
		fieldPage = Snk.getField(0xCCCCCC, 8, -1, "nokia");
		fieldPage.x = mcw * 0.5 - 30;
		fieldPage.y = mch - 11;
		root.addChild(fieldPage);
		
		// BUTS
		var mid = mcw * 0.5;
		buts = [];
		for( i in 0...2 ) {
			for( n in 0...2 ) {
				var sens = n * 2 - 1;
				var frames = [];
				for( k in 0...3 ) frames.push(Gfx.bg.get(k+i*3, "arrow"));
			
				var f = function () { Main.incPage(sens * (1 + (1-i) * 9) ); };
				var b = new But(f, frames);
				b.scaleX = sens;
				buts.push(b);
				root.addChild(b);
				b.x = mid + sens * (185 + i * 32);
				b.y = mch - 6;
			}
		}
	}

	static public function incPage(inc) {
		
		page += inc;
		if( page < 0 )			page = 0;
		if( page > PAGE_MAX )	page = PAGE_MAX;
		displayPage();
	}
	static public function displayPage() {
		
		while(vigs.length > 0) vigs.pop().kill();
		
		var line = 4;
		var max = Main.MAX;

		for( n in 0...max ) {
			var i = page * max + n;
			if( i >= DFruit.MAX ) continue;
			var o = data[i];
			var vig = new Vig(o.id, o.num);
			vig.x = LEFT_MARGIN + Std.int( n / line)*(Vig.WIDTH+MARGIN);
			vig.y = ( n % line) * (Vig.HEIGHT + MARGIN);
			vigs.push(vig);
		}
		
		// FIELD
		fieldPage.text = Lang.PAGE+" " + (page+1) + " / " + (PAGE_MAX+1);
		screen.update();
	}
	
	static public function sortData(a:FruitNum, b:FruitNum) {
		var ra = DFruit.LIST[a.id].rank;
		var rb = DFruit.LIST[b.id].rank;
		if( ra < rb ) return -1;
		return 1;
	}

	
	static public function initMouseTracker() {

		var mc = flash.Lib.current.stage;
		mc.addEventListener( flash.events.Event.MOUSE_LEAVE,		function(e) { Main.MOUSE_IN = false;}, false, 0, true );
		mc.addEventListener( flash.events.MouseEvent.MOUSE_MOVE,	function(e) { Main.MOUSE_IN =true;}, false, 0, true );


	}
	
//{
}












