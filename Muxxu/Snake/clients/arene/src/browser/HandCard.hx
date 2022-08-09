package browser;
import Protocole;
import mt.bumdum9.Lib;

class HandCard extends flash.display.Sprite { //}
	
	static public var SPEED = 16;
	
	public var data:_DataCard;
	public var id:Int;
	public var card:Card;
	public var tween:Tween;
	var coef:Float;
	var spc:Float;
	public var onDest:Void->Void;
	public var leave:Bool;
	var sleep:Null<Int>;
	
	public function new(d:_DataCard) {
		super();
		data = d;
		id = Browser.me.getHandTotal();
		Browser.me.hand.push(this);
		
		leave = false;
		
		card = new Card(data._type);
		card.shade.visible = false;
		addChild(card.sprite);
		card.flipIn();
		card.coef = 1;
		Browser.me.dm.add(this, Browser.DP_CARDS);
	}
	
	public function update() {
		if( sleep != null ) {
			sleep--;
			if( sleep <= 0 ) {
				sleep = null;
				visible = true;
			}
			
			return;
		}
		if( tween != null ) {
			coef = Math.min(coef + spc, 1);
			var p = tween.getPos(coef);
			x = p.x;
			y = p.y;
			if( coef == 1 ) {
				if( onDest != null ) onDest();
				tween = null;
			}
		}
		
		card.update();
		
	}
	public function setSleep(n) {
		sleep = n;
		visible = false;
	}
	
	public function moveTo(ex:Float, ey:Float) {
		var dx = ex - x;
		var dy = ey - y;
		var dist = Math.sqrt(dx * dx + dy * dy);
		tween = new Tween( x, y, ex, ey );
		coef = 0;
		spc = SPEED / dist;
		
	}
	public function moveToHand() {
		
		var by = Browser.me.getHandY() + Card.HEIGHT * 0.5;
		var mx = 0;
		if( Browser.me.mojoBox.visible ) mx += MojoBox.WIDTH;
		
		var max = Browser.me.getHandTotal();
		var ec = 3;
		var ww = max * Card.WIDTH + (max - 1) * ec + mx;
		
		if( ww > Cs.mcw ) {
			var dif = ww - Cs.mcw;
			ec -= Math.ceil(dif / (max - 1));
			ww = max * Card.WIDTH + (max - 1) * ec + mx;
			
		}
		
		var bx = (Cs.mcw - ww) * 0.5;



		moveTo( Std.int(  mx+bx+(id+0.5)*(Card.WIDTH+ec)), by );
		
		/*
		var margin = Browser.MOJO_BAR+4;
		var by = Browser.TOP_BAR + Nav.HEIGHT + Browser.DESC_BAR + Card.HEIGHT * 0.5 + 4;
		var ec = 3;
		moveTo( margin + (id + 0.5) * (Card.WIDTH + ec), by );
		*/
		
		
		
	}
	public function moveToGamePos() {
		card.id = id;
		card.flipOut();
		var p = Game.getCardPos(id);
		moveTo(p.x, p.y);
	}
	
	
	//
	public function insertInPool() {
		Browser.me.nav.add(data);
		
		kill();
		//Browser.me.majTuto();
	}
	
	//
	public function kill() {
		Browser.me.hand.remove(this);
		Browser.me.handCards.remove(this);
		parent.removeChild(this);
	}

//{
}