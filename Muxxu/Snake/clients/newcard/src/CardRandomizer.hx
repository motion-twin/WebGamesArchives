import Protocole;
import Protocole._CardType;
import mt.bumdum9.Lib;


class CardRandomizer{//}
	
	public static var SPEED_MIN = 0.1;

	var fadeIn:Bool;
	var turnCoef:Float;
	var card:GfxCard;
	var but:But;
	var speed:Float;
	var field:flash.text.TextField;
	var blinkField:flash.text.TextField;
	var icon:pix.Sprite;
	
	var step:Int;
	var timer:Int;
	var cardId:_CardType;
	
	var root:flash.display.Sprite;
	var screen:pix.Screen;
	var fxm:mt.fx.Manager;

	public function new() {
		
		root = new flash.display.Sprite();
		root.addEventListener(flash.events.Event.ENTER_FRAME, update);
		
		
		// BG
		root.graphics.beginFill(Gfx.col("green_1"));
		root.graphics.drawRect(0, 0, Main.mcw, Main.mch);
		var ma = 60;
		
		root.graphics.beginFill(Gfx.col("green_0"));
		root.graphics.drawRect(ma, 0, Main.mcw - 2 * ma, Main.mch);
		
		
		/*
		root.graphics.beginFill(Gfx.col("green_0"));
		root.graphics.drawRect(0, 0, Main.mcw, Main.mch);
		
		
		root.graphics.beginFill(Gfx.col("green_2"));
		root.graphics.drawRect(0, 0, Main.mcw, 68);
		
		root.graphics.beginFill(Gfx.col("green_1"));
		root.graphics.drawRect(0, 0, Main.mcw, 67);
		*/
		
		// CARD
		card = new GfxCard();
		
		card.x = Std.int(Main.mcw * 0.5);
		card.y = 46;
		//card.scaleX = card.scaleY = 2;
		
		// BUT
		but = new But("acheter",action);
		but.x = card.x;
		but.y = card.y + 36 ;
		
		
		// FIELD
		field = Main.getField(0xDDFF88, 8, -1,"nokia");
		field.text = Lang.CARD_PRICE + Main.price;
		centerField(field);
		field.y = but.y + 15;
		
		// ICON
		icon = new pix.Sprite();
		icon.drawFrame(Gfx.main.get("token"),0,0);
		icon.x = Std.int(field.x + field.width );
		icon.y = field.y+2;
		
		//
		root.addChild(card);
		root.addChild(but);
		root.addChild(field);
		root.addChild(icon);
		
		
		// SCREEN
		screen = new pix.Screen(root, Main.mcw*2, Main.mch*2,2);
		flash.Lib.current.addChild(screen);
		
		//
		fxm = new mt.fx.Manager();
		
		//
		timer = 0;
		turnCoef = 0;
		step = 0;
		fadeIn = true;
		update(null);
	
	}
	
	function action() {
		step = 1;
		but.kill();
		icon.visible = false;
		field.text = Lang.LOADING+"...";
		field.y -= 5;
		centerField(field);
		

		if( Main.domain != null ) {
			Codec.load(Main.domain + "/buyCard", null, receiveCard) ;
		}else{
			var me = this;
			var f = function() {
				var o = { _c:Snk.getEnum(_CardType, Std.random(20)) };
				me.receiveCard(o);
			}
			f = noMoney;
			haxe.Timer.delay( f, 1000);
		}
	
	}
	
	function receiveCard(o:_NewCard) {
		if( o._c == null ) {
			noMoney();
			return;
		}
		cardId = o._c;
		step = 2;
		speed = 1 ;
		field.text = Lang.DRAW;
		centerField(field);
	}
	
	public function update(e) {
		timer++;
		switch(step) {
			
			case 0 :
				if(fadeIn)Col.setPercentColor(screen, 1-turnCoef, 0xFFFFFF);
				turn(0.05);
				but.update();
				
			case 1 :
				turn(0.1);
				
			case 2 :
				turn(speed * 0.1);
				var lim = SPEED_MIN;
				speed = Math.max(speed - 0.01, SPEED_MIN);
				if( speed == SPEED_MIN && turnCoef > 0.75 ) {
					card.setType(cardId);
					step++;
				}
				
			case 3 :
				turn(SPEED_MIN*0.1);
				if( Math.abs(turnCoef - 0.25) < 0.01) displayFinal();
				
			case 4 :
				blinkField.visible = timer%12 < 8 ;
			case 5 :
				turnCoef = Math.min(turnCoef + 0.1, 1);
				Col.setPercentColor(screen, turnCoef, 0xFFFFFF);
				
				
				
				if(turnCoef == 1) {
					flash.Lib.current.removeChild(screen);
					root.removeEventListener(flash.events.Event.ENTER_FRAME, update);
					new CardRandomizer();
					step++;
				}
				
		}
	
		fxm.update();
		screen.update();
	}
	
	function turn(inc:Float) {
		turnCoef += inc;
		card.coef = turnCoef;
		while( turnCoef > 1 ) {
			turnCoef--;
			if(step != 3) card.setType(Main.getEnum(_CardType, Std.random(60)));
			fadeIn = false;
		}
		card.majSprite();
		
		// FX
		
		
	}
	
	function displayFinal() {
		step++;
		
		// CARD
		turnCoef = 0.25;
		card.coef = turnCoef;
		card.majSprite();
		
		// FIELD
		field.multiline = true;
		field.wordWrap = true;
		field.text = card.data._desc;// Lang.CARD_DESC[Type.enumIndex(cardId)];
		field.height = field.textHeight + 3;
		field.y -= 11;
		//field.y = (Main.mch - 30) - Std.int( (field.height-16) * 0.5);
		//while(field.y+field.height > Main.mch) field.y--;
		centerField(field,170);
		
		var tf = field.getTextFormat();
		var col = tf.color;
		//tf.align = flash.text.TextFormatAlign.JUSTIFY;
		tf.color = 0xFFFFFF;
		field.setTextFormat(tf);
		field.filters = [ new flash.filters.GlowFilter(Gfx.col("green_2"), 1, 2, 2, 100)];
		
		// FIELD 2
		var f = Main.getField(col, 8, -1, "nokia");
		root.addChild(f);
		f.text = Lang.CARD_ADDED;
		centerField(f);
		blinkField = f;
		
		//
		flash.Lib.current.stage.addEventListener(flash.events.MouseEvent.CLICK, reset);
		
	}
	
	function noMoney() {
		field.text = Lang.NOT_ENOUGH_TOKEN;
		centerField(field);
		new mt.fx.Blink(field, 50, 4, 4);
		var me = this;
		haxe.Timer.delay( function() { me.reset(null); }, 2500);
	}
	
	function reset(e) {
		
		var url = new flash.net.URLRequest(Main.domain+"/card");
		flash.Lib.getURL(url,"_self");
		
		/*
		turnCoef = 0;
		step = 5;
		flash.Lib.current.stage.removeEventListener(flash.events.MouseEvent.CLICK, reset);
		*/
		
		//flash.Lib.current.removeChild(screen);
		//new CardRandomizer();
	}
	
	function centerField(f:flash.text.TextField,?ww:Float) {
		if( ww == null ) ww = f.textWidth + 3;
		f.width = ww;
		f.x = Std.int( (Main.mcw - f.width) * 0.5 );
		
	}

//{
}












