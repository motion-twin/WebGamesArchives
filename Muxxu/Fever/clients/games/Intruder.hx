import mt.bumdum9.Lib;


class Intruder extends Game{//}

	static var XMAX = 5;
	static var YMAX = 3;
	static var CARD_MIN = 3;
	static var CARD_TYPE_MAX = 45;
	var types:Array<Int>;
	var ids:Array<Int>;
	var cards:Array<pix.Element>;
	var timer:Int;
	var prec:Int;
	var swap:mt.flash.Volatile<Int>;
	var field:flash.text.TextField;
	
	override function init(dif:Float){
		gameTime = 500-100*dif;
		super.init(dif);
		
		//X2
		box.scaleX = box.scaleY = 2;
		
		// BG
		bg = new flash.display.MovieClip();
		for( i in 0...2 ) {
			var el = new pix.Element();
			el.x = i*200;
			el.drawFrame(Gfx.games.get("horde_bg"), 0, 0);
			bg.addChild(el);
			if( i == 0 ) el.scaleY *= -1;
			el.rotation = 90;
		}
		dm.add(bg, 0);
		
		// ids
		ids = [];
		var max = XMAX * YMAX;
		var pos = [];
		types = [];
		for( i in 0...CARD_TYPE_MAX ) types.push(i);
		for( i in 0...max ) {
			ids.push( -1);
			pos.push(i);
		}
		Arr.shuffle(pos);
		Arr.shuffle(types);
		var cmax = CARD_MIN + Math.round((max - CARD_MIN) * Math.min(Math.pow(dif,1.5), 1));
		var cpos = [];
		for( i in 0...cmax ) {
			var id = pos.pop();
			cpos.push(id);
			ids[id] = types.pop();
		}
		swap = cpos[Std.random(cpos.length)];
		
		//
		timer = Std.int(gameTime * 0.3);
		
		displayCards();
			
	}

	override function update() {
		
		switch(step) {
			
			case 1 : // SEE
				if(timer-- == 0 ) 	lightOut();
				
			case 2 : // VANISH
				timer--;
				Col.setPercentColor( bg, (1 - timer / 30) * 0.5, 0);
				if( timer == 0 ) initCounter();
				
			case 3 : // COUNT
				timer--;
				var n = Math.ceil(timer / 40);
				field.text = Std.string(n);
				field.width = field.textWidth + 3;
				field.height = field.textHeight + 3;
				field.x = Std.int( (Cs.mcw*0.5 - field.width)*0.25 )*2;
				field.y = Std.int( (Cs.mch*0.5 - field.height)*0.25 )*2;
				if( timer == 0 ) lightIn();
			
			case 4 : // FIND
			
		}
		
		
		super.update();
	}
	
	function displayCards() {
		
		cards = [];
		var id = 0;
		for( x in 0...XMAX ) {
			for( y in 0...YMAX ) {
				var card = getCard(ids[id]);
				cards.push(card);
				card.x = 48 + x * 26;
				card.y = 74 + y * 28;
				id++;
			}
		}
		
	}
	function getCard(n) {
		var card = new pix.Element();
		card.drawFrame(Gfx.games.get("horde_card"));
		card.blendMode = flash.display.BlendMode.LAYER;
		dm.add(card, 1);
		if( n >= 0 ){
			var icon = new pix.Element();
			icon.drawFrame(Gfx.games.get(n, "horde_toys"));
			card.addChild(icon);
		}
		
		return card;
		
		
	}
	
	
	function lightOut() {
		while(cards.length > 0) {
			var card = cards.pop();
			new mt.fx.Vanish( card, Std.int(( (card.x + card.y) * 0.2 )) - 20, 5, true );
			
		}
		step ++;
		timer = 30;
	}
	
	
	function initCounter() {
		step++;
		field = Cs.getField(0xFFFFFF, 20, -1, "upheaval");
		field.scaleX = field.scaleY = 2;
		timer = Std.int(gameTime * 0.35);
		dm.add(field, 2);
	}
	
	function lightIn() {
		step++;
		field.visible = false;
		prec = ids[swap];
		ids[swap] = types.pop();
		Col.setPercentColor( bg, 0, 0);
		displayCards();
		
		var id = 0;
		var me = this;
		for( card in cards ) {

			if( ids[id] >= 0 ){
				card.addEventListener( flash.events.MouseEvent.CLICK, callback(choose,card,id) );
				card.mouseEnabled = true;
				card.useHandCursor = true;
				card.buttonMode = true;
			}
			id++;
			
		}
		
	}
	
	function choose(card:pix.Element, id, e) {
		if( win != null ) return;
		setWin( id == swap, 30 );
		
		if( win ) {
			ids[swap] = prec;
			// FX
			var max = 12;
			var cr = 8;
			for( i in 0...max ) {
				var a = i / max * 6.28;
				var speed = 0.1 + Math.random() * 3;
				var p = new pix.Part();
				p.setAnim(Gfx.fx.getAnim("spark_twinkle"));
				p.anim.gotoRandom();
				p.vx = Math.cos(a) * speed;
				p.vy = Math.sin(a) * speed;
				p.xx = card.x + p.vx * cr*0.5;
				p.yy = card.y + p.vy * cr;
				p.timer = 10 + Std.random(20);
				p.frict = 0.94;
				p.weight = 0.05 + Math.random() * 0.1;
				p.updatePos();
				dm.add(p, 3);
			}
			//
			while(cards.length > 0) cards.pop().kill();
			displayCards();
			
			var fx = new mt.fx.Flash(cards[swap]);
			fx.glow( 2, 4);
			
			
		}else {
			var id = 0;
			for( card in cards ) {
				card.alpha = 0.25;
				card.mouseEnabled = false;
				card.useHandCursor = false;
				if( id == swap ) {
					card.alpha = 1;
					var blink = getCard(prec);
					blink.x = card.x;
					blink.y = card.y;
					var fx = new mt.fx.Blink(blink, 1000, 6, 6);
				}
				id++;
			}
		}
		
		
		
	}
	


//{
}

