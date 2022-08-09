import Protocole;
import mt.bumdum9.Lib;


class Promo extends flash.display.Sprite{//}
	
	static var WIDTH = 136;
	static var HEIGHT = 200;

	
	//static var PIX = "<font color='#0092d930'>.</font>";
	
	var but:But;

	public function new() {
		super();

		initBg();
		
		// BUT
		but = new But(Lang.I_SUBSCRIBE,subscribe);
		addChild(but);
		but.x = WIDTH * 0.5;
		but.y = HEIGHT - 20;
		
		// TEXTE
		initText();
		

		
	}

	function initBg() {
		
		var border = 1;
		var shade = 1;
		
		graphics.beginFill(0xFFFFFF);
		graphics.drawRect(0, 0, WIDTH, HEIGHT);
		
		graphics.beginFill(Gfx.col("green_1"));
		graphics.drawRect(border, border, WIDTH-border*2, HEIGHT-border*2);
		
		var m = border + shade;
		graphics.beginFill(Gfx.col("green_0"));
		graphics.drawRect(m, m, WIDTH-m*2, HEIGHT-m*2 );
		
		graphics.beginFill(Gfx.col("green_2"));
		graphics.drawRect(0, HEIGHT, WIDTH, 1);
	}
	
	
	public function update() {
		but.update();
	}
	
	
	
	function initText() {
		var ma = 7;
		
		var y = 20.0;
		
	#if dev
		var a = [
			"Choisissez une stratégie grâce aux " + red("60 cartes") + " de"+Cs.PIX+" l'arène !",
			"Collectionnez plus"+Cs.PIX+"<br/>de "+red("200 fruits")+" et percez"+Cs.PIX+" leurs mystères !",
			"Comparez vos scores"+Cs.PIX+" dans un classement exclusif à votre groupe"+Cs.PIX+" d'amis. ",
		];
	#else
		if( Main.slogan == null ) Main.slogan = "param slogan not found!" ;
		var a = Main.slogan.split(";");
	#end
		
		for( str in a) {
			var f = Cs.getField(0xFFFFFF, 8, 0, "nokia");
			
			//f.gridFitType = flash.text.GridFitType.NONE;
			
			f.width = WIDTH - (ma+1);
			f.multiline = true;
			f.wordWrap = true;
			f.htmlText = center(str);
			f.x = ma;
			f.y = y;
			f.height = f.textHeight + 6;
			addChild(f);
			y += f.height + 6;
			
			f.filters  = [ new flash.filters.DropShadowFilter(1,90,Gfx.col("green_1"),1,0,0,10)];
			
			
		}
		
		// FIELDS

	}
	function red(str) {
		return "<font color='#FF6666'>" + str + "</font>";
	}
	function center(str) {
		//return str;
		return "<p align='center'>" + str + "</p>" ;
	}
	
	
	function subscribe() {
		/*var url = new flash.net.URLRequest(Main.subscribe);
		flash.Lib.getURL(url,"_self");*/
		
		flash.external.ExternalInterface.call("_twSignUp", []) ;
	}
	

	
	
//{
}











