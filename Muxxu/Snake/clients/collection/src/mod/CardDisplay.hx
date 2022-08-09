package mod;
import Protocole;
import mt.bumdum9.Lib;

typedef ColCard = { _type:_CardType, _num:Int };

class CardDisplay  extends Module{//}
	
	static var SCROLL_SPEED = 0.025;
	static var MARGIN_SCROLL = 100;
	static var BH = 12;
	static var EC = 3;



	var xmax:Int;
	var ymax:Int;
	var mx:Int;
	var my:Int;
	
	var pid:Int;
	var comp:Float;
	var tot:Int;
	var timer:Int;
	
	var page:flash.display.Sprite;
	var pageBox:flash.display.Sprite;
	var pageMask:flash.display.Sprite;
	var cards:Array<ColCard>;
	var arrow:pix.Element;
	
	public function new( a) {
		
		cards = a;
		super();
		mch -= BH;
		graphics.beginFill(Gfx.col("green_0"));
		graphics.drawRect(0, 0, mcw, mch);
		graphics.beginFill(Gfx.col("green_1"));
		graphics.drawRect(0, mch, mcw, BH);
		
		xmax = Std.int((mcw + EC) / (GfxCard.WIDTH + EC));
		ymax = Std.int((mch + EC) / (GfxCard.HEIGHT + EC));
		
		mx = mcw - ((xmax * GfxCard.WIDTH) + ((xmax - 1) * EC));
		my = mch - ((ymax * GfxCard.HEIGHT) + ((ymax - 1) * EC));
		mx = Std.int(mx * 0.5);
		my = Std.int(my * 0.5);
		
		// COMP
		tot = 0;
		for( o in cards )if(o._num > 0) tot++;
		comp = tot / cards.length;
		
		// PAGE
		pageBox = new flash.display.Sprite();
		pageMask = new flash.display.Sprite();
		pageMask.graphics.beginFill(0xFF0000);
		pageMask.graphics.drawRect(0, 0, mcw, mch);
		pageBox.mask = pageMask;
		addChild(pageBox);
		addChild(pageMask);
		
		// ARROW
		arrow = new pix.Element();
		arrow.drawFrame(Gfx.collection.get("arrow"));
		addChild(arrow);
			
		//
		cards.sort(order);
		timer = 0;
		pid = 0;
		initBar();
		displayPage();
		
		addEventListener(flash.events.MouseEvent.CLICK,click);
		
	}
	
	// ORDER
	function getFreq(str:String ) {
		if( str == "C" ) return 0;
		if( str == "U" ) return 1;
		if( str == "R" ) return 2;
		return 0;
	}
	function order(a:ColCard,b:ColCard) {
		var id_a = Type.enumIndex(a._type);
		var id_b = Type.enumIndex(b._type);
		var score_a = getFreq(Data.CARDS[id_a].freq)*400 + id_a;
		var score_b = getFreq(Data.CARDS[id_b].freq)*400 + id_b;
		if( score_a < score_b ) return -1;
		return 1;
	}
	
	// BAR
	var fieldLeft:flash.text.TextField;
	var fieldRight:flash.text.TextField;
	function initBar() {
		var textColor = Gfx.col("green_0");
		textColor = Col.brighten(textColor, 50);
		
		fieldLeft = Snk.getField(textColor, 8, -1, "nokia");
		fieldLeft.x = 1;
		fieldLeft.y = mch - 1;
		addChild(fieldLeft);
		
		fieldRight = Snk.getField(textColor, 8, 1, "nokia");
		fieldRight.width = 180;
		fieldRight.x = mcw-fieldRight.width;
		fieldRight.y = mch - 1;
		addChild(fieldRight);
		
		fieldRight.htmlText =  Lang.CARDS+" : "+white(Std.string(tot))+"  "+Lang.COMPLETION+" : "+white(Std.int(comp * 100)+"%");
		
		majBar();
	}
	function majBar() {
		fieldLeft.text = Lang.PAGE+" : " + (pid + 1) + "/" + Math.ceil(cards.length / (xmax * ymax));
		
	}
	inline function white(str) {
		return "<font color='#FFFFFF'>" + str + "</font>";
	}
		
	// DISPLAY
	function displayPage() {
		if( page != null ) removeChild(page);
		page = getPage(pid);
		
	}
	function getPage(pid) {
		var index = pid * xmax * ymax;
		var page = new flash.display.Sprite();
		pageBox.addChild(page);
		for( y in 0...ymax ) {
			for( x in 0...xmax ) {
				var o = cards[index + y*xmax + x ];
				if( o == null ) break;
				var card = new GfxCard(2);
				card.setType(o._type);
				card.x =  mx + (x + 0.5) * GfxCard.WIDTH + x * EC;
				card.y =  my + (y + 0.5) * GfxCard.HEIGHT + y * EC;
				card.x = Std.int(card.x);
				card.y = Std.int(card.y);
			
				if( o._num > 1 )card.displayCopies(o._num);
				card.coef = 0.25;
				card.majSprite();
				card.alpha = o._num == 0?0.25:1;
				card.blendMode = flash.display.BlendMode.LAYER;
				page.addChild(card);
			}
		}
		return page;
	}
		
	// SCROLL
	function click(e) {
		if( !mouseEnabled ) return;			// o_O
		if( mouseX < MARGIN_SCROLL ) 		scroll( -1);
		if( mouseX > mcw-MARGIN_SCROLL ) 	scroll( 1);
	}
	function scroll(inc) {
		if( pid + inc < 0 ) return;
		if( (pid + inc ) * xmax * ymax > cards.length ) return;
		
		pid += inc;
		var p = getPage(pid);
		p.x = inc * mcw;
		
		var fx = new mt.fx.Tween(p, 0, 0, SCROLL_SPEED);
		fx.curveInOut();
		var fx = new mt.fx.Tween(page, -mcw*inc, 0, SCROLL_SPEED);
		fx.curveInOut();
		fx.onFinish = callback( swapPages, p);
		
		majBar();
		mouseEnabled = false;
	}
	function swapPages(p:flash.display.Sprite ) {
		
		pageBox.removeChild(page);
		page = p;
		mouseEnabled = true;
		page.x = Std.int(page.x);
		
	}

	//
	override function update() {
		timer++;
		
		arrow.x = Std.int(mouseX);
		arrow.y = Std.int(mouseY);
		arrow.visible  = false;
		flash.ui.Mouse.show();
		
		if(timer % 32 == 0 ) new mt.fx.Flash(arrow);
		
		if( arrow.x > 0 && arrow.x < MARGIN_SCROLL ) {
			arrow.visible = true;
			arrow.scaleX = -1;
			flash.ui.Mouse.hide();
		}
		if( arrow.x > mcw-MARGIN_SCROLL ) {
			arrow.visible = true;
			arrow.scaleX = 1;
			flash.ui.Mouse.hide();
		}
		
	}
	


	
//{
}








