import mt.bumdum9.Lib;

class StockModule extends McStockModule {
	
	static var EC = 20;
	
	public var num:Int;
	public var price:Int;
	
	public var min:Int;
	public var max:Int;
	public var inc:Int;
	public var id:Int;
	
	public var incMod:Float;
	
	var timer:Int;
	var bmp:flash.display.BitmapData;
	
	
	public function new(id) {
		super();
		this.id  = id;
		icon.gotoAndStop(id+1);
		num = 0;
		inc = 0;
		timer = EC;
		
		incMod = [2, 0.5, 1, 3][id];
		
		bmp = new flash.display.BitmapData( Std.int(screen.width), Std.int(screen.height), false, 0x550000);
		var mc = new flash.display.Bitmap(bmp);
		screen.addChild(mc);
		
		sell.addEventListener( flash.events.MouseEvent.CLICK, fsell );
		buy.addEventListener( flash.events.MouseEvent.CLICK, fbuy );
		
		maj();
	}
	
	
	public function update() {
		timer--;
		bmp.scroll( -1, 0);
		var color = 0x550000;
		bmp.fillRect( new flash.geom.Rectangle(bmp.width-1,0,1,bmp.height),color);
		
		if( timer == 0 ) {
			timer = EC;
			inc += Std.random(3) - 1;
			inc = Math.round( inc * 0.75);
			
			if( Std.random(40) == 0 ) inc = Std.random(11) - 5;
			if( price == max && Std.random(10) == 0 ) inc -= 3;
			if( price == min && Std.random(10) == 0 ) inc += 3;
			
			var opy = getY(price);
			price = Num.clamp(min, price + Math.round(inc*incMod), max);
			var py = getY(price);
			
			var brush = new StockLine();
			var dx = EC;
			var dy = py - opy;
			var m = new flash.geom.Matrix();
			
			m.scale( Math.sqrt(dx * dx + dy * dy) * 0.01, 1);
			m.rotate( Math.atan2(dy,dx));
			m.translate(bmp.width - EC, opy);
			bmp.draw( brush, m );
			
			maj();
		}
	}
	
	function getY(price) {
		var c = 1 - (price-min) / (max - min);
		var ma = 2;
		return Std.int(ma+ c * (bmp.height-2*ma));
		
	}
	
	public function setMidPrice() {
		price = Std.int(min + (max - min) * 0.5);
	}
	
	public function maj() {
		field.text = price + " $";
		sell.alpha = (num > 0)?1:0.25;
		buy.alpha = (Stock.me.gold >= price)?1:0.25;
		
		var a:Array<flash.display.SimpleButton> = [sell, buy];
		for( but in a ) {
			var ok = but.alpha >= 0.5;
			but.mouseEnabled = ok;
		}
		
	}
	
	function fsell(e) {
		num--;
		Stock.me.gold += price;
		Stock.me.majAll();
	}
	
	function fbuy(e) {
		num++;
		Stock.me.gold -= price;
		Stock.me.majAll();
	}
	
}


class Stock extends Game{//}

	public var gold:Int;
	public var modules:Array<StockModule>;
	public static var me:Stock;
	var mbg:BgStock;

	override function init(dif) {
		
		gameTime = 2000;
		super.init(dif);
		me = this;
		
		
		// BG
		mbg = new BgStock();
		dm.add(mbg, 0);
		

		
		// MODULES
		modules = [];
		var a  = [50, 100, 5, 20, 90, 110, 200, 300];
		for( i in 0...4 ) {
			var mod = new StockModule(i);
			mod.min = a[i * 2];
			mod.max = a[i * 2 + 1];
			mod.x = 10 + (i % 2) * 195;
			mod.y = 70 + Std.int(i / 2) * 115;
			mod.setMidPrice();
			
			dm.add(mod, 1);
			modules.push(mod);
			
		}
		//
		gold = 200;
		majAll();
	}

	override function update(){

		for( mod in modules ) mod.update();
		super.update();
	}
	
	public function majAll() {
		for( mod in modules ) mod.maj();
		mbg.field.text = gold + " $";
	}

	function displayStock() {
		
	}
	
	

//{
}








