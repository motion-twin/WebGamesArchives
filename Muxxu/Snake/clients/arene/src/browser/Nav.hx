package browser;
import Protocole;
import mt.bumdum9.Lib;
typedef SlotCard = { card:Card, c:Float, tx:Null<Float>, teleport:Bool, available:Bool, datas:Array<_DataCard>};

class Nav {//}
	
	public static var HEIGHT = 72;

	var slots:Array<SlotCard>;
	var scroll:flash.display.Sprite;
	var vx:Float;
	
	
	public var root:flash.display.Sprite;
	
	public function new() {
		root = new flash.display.Sprite();
		Browser.me.dm.add(root, 1);
		
		//
		slots = [];
		vx = 0;

		//
		initBg();
		
		scroll = new flash.display.Sprite();
		scroll.mouseEnabled = false;
		root.addChild(scroll);
		
	
		
	}
	
	function initBg() {
		return;
		var bg = new flash.display.Sprite();
		root.addChild(bg);
		bg.graphics.beginFill(Gfx.col("green_2"));
		bg.graphics.drawRect(0, 0, Cs.mcw, HEIGHT);
		
	}
	
	public function set(data:Array<_DataCard>) {
		
	
		
		// CLEAN
		while(slots.length > 0) {
			var sl =	slots.pop();
			sl.card.sprite.parent.removeChild(sl.card.sprite);
		}
		// SORT
		data.sort(sortDataCard);

		// FILL
		for( o in data ) add(o,false);
		
		maj();
	
	
		
	}
	public function sortDataCard(a:_DataCard, b:_DataCard) {
		if( a._available ) return 1;
		return -1;
		/*
		var na = 0.0;
		var nb = 0.0;
		if( a._date != null ) na = a._date;
		if( b._date != null ) nb = b._date;
		if( na > nb ) return -1;
		return 1;
		*/
	}
	
	// MAJ
	public function maj() {
		//trace("maj("+Std.random(9)+")");
		// SORT
		slots.sort(sortId);
		//slots.sort(sortMojo);
		
		//
		var a = slots.copy();
		a.sort(sortSlotByCost);
		// DISPLAY
		var ec = 3;
		var ma = (Cs.mcw - ((a.length * Card.WIDTH) + ((a.length - 1) * 3)))*0.5;
		ma = Std.int(Math.max( 0, ma ));
		var id = 0;
		for( slot in a ) {
			var card = slot.card;
			slot.tx = 24 + ma + id * (Card.WIDTH+ec);
			if( slot.teleport ) {
				slot.card.sprite.x = slot.tx;
				slot.teleport = false;
			}
			card.sprite.y = HEIGHT * 0.5;
			card.flipIn();
			card.coef = 1;
			//
			
			var data =  slot.datas[slot.datas.length - 1];
			slot.available = data._available;
			
			//slot.time = data._date;
			if( !slot.available ) 	slot.card.displayChrono();
			else					slot.card.removeChrono();
			
			
			//
		
			slot.card.displayCopies(slot.datas.length);
			
			
			//
			id++;
		}
	}
	function sortId(a:SlotCard,b:SlotCard) {
		if( Type.enumIndex(a.card.type) < Type.enumIndex(b.card.type) ) return -1;
		return 1;
	}
	function sortMojo(a:SlotCard,b:SlotCard) {
		if( a.card.mojo > b.card.mojo ) return -1;
		if( a.card.mojo == b.card.mojo ) return 0;
		return 1;
	}
	
	// SLOTS
	function getSlot(o:_DataCard) {
		
		for( slot in slots  ) 	if( slot.card.type == o._type ) 	return slot;
		
		var card = new Card( o._type );
		var slot = { card:card, c:0.0, tx:null, teleport:true, available:false, datas:[] };
		card.shade.visible = false;

		scroll.addChild(card.sprite);
		slots.push(slot);
		return slot;
	}
	public function add(o:_DataCard,domaj=true) {
		var slot = getSlot(o);
		slot.datas.push(o);
		if(domaj)maj();
		return slot;
	}
	public function remove(o:_DataCard) {
		var slot = getSlot(o);
		slot.datas.remove(o);
		if(slot.datas.length == 0) {
			scroll.removeChild(slot.card.sprite);
			slots.remove(slot);
		}
		maj();
	}
	public function getSlotPos(o:_DataCard) {
		var slot = add(o);
		var x = slot.card.sprite.x;
		var y = slot.card.sprite.y;
		remove(o);
		return { x:scroll.x + x, y:scroll.y + y };
	}
	
	// SORT
	public function sortSlotById(a:SlotCard, b:SlotCard) {
		var na = Type.enumIndex( a.card.type);
		var nb = Type.enumIndex( b.card.type);
		if( na < nb ) return -1;
		return 1;
	}
	public function sortSlotByCost(a:SlotCard, b:SlotCard) {
		var na = a.card.data.mojo*1000 + Type.enumIndex( a.card.type);
		var nb = b.card.data.mojo*1000 + Type.enumIndex( b.card.type);
		if( na > nb ) return -1;
		if( na < nb ) return 1;
		return sortSlotById(a, b);
	}
	
	// CLICK
	public function click() {
		if( !active || selection==null || !selection.available || !Browser.me.mojoBox.visible ) return;
		selectSlot(selection);
	}
	function selectSlot(slot:SlotCard) {
		
		var hmax = Browser.me.getHandMax();
		if( Browser.me.getHandTotal() >= hmax ) {
			var str = Lang.BROWSER_HAND_LIMIT;
			str = StringTools.replace(str,"%0", Std.string(hmax));
			Browser.me.displayHint( str, 1, true );
			return;
		}
		if( slot.card.data.multi == null ) {
			for( hc in Browser.me.hand ) if(hc.card.type == slot.card.type ) {
				Browser.me.displayHint( Lang.BROWSER_MULTI_LIMIT, 1, true );
				return;
			}
		}
		
		var data = slot.datas[slot.datas.length - 1] ;
		remove(data);
		
		var handCard = new HandCard( data );
		handCard.x = scroll.x + slot.card.sprite.x;
		handCard.y = root.y + scroll.y + slot.card.sprite.y;
		Browser.me.addCard( handCard );
	}
		
	// UPDATE
	public var active:Bool;
	var selection:SlotCard;
	public function update() {
		
		// ACTIVE
		var ym = root.mouseY * 0.5;
		active = ym >= 0 && ym < HEIGHT;
				
		// SCROLL
		updateScroll();
		
		// UPDATE TIME
		//updateTimers();
		
		// MOVE
		for( slot in slots ) {
			if( slot.tx != null ) {
				var dx = slot.tx - slot.card.sprite.x;
				slot.card.sprite.x += dx * 0.5;
				if( Math.abs(dx) < 2 ) {
					slot.card.sprite.x = slot.tx;
					slot.tx = null;
				}
			}
		}
		
		// ACTIVE BREAK
		if( !active ) {
			unselect();
			return;
		}
				
		// SELECTION
		//var mdx = 999.9;
		var sel:SlotCard = null;
		for( slot in slots ) {
			var dx = slot.card.sprite.x - (scroll.mouseX-scroll.x) * 0.5;
			if(  Math.abs(dx) < Card.WIDTH*0.5  ) sel = slot;
		}
		if( sel != selection ) {
			unselect();
			select(sel);
		}


	}
	function updateScroll() {
		
		var xm = root.mouseX * 0.5;
		var ym = root.mouseY * 0.5;
		
		var dx = xm - Cs.mcw * 0.5;
		var lim = 80;
		
		var sens = dx / Math.abs(dx);
		if( dx == 0 ) sens = 1;
		
		dx = Math.max(0, Math.abs(dx) - lim)*sens;
		
		var tvx = 0.0;
		if( active ) tvx = -dx * 0.3;
		vx = tvx;
		
		var osx = scroll.x;
		scroll.x = Num.mm(Cs.mcw-(scroll.width+4), scroll.x + vx, 0 );
		scroll.x = Std.int(scroll.x);
		var rvx = scroll.x - osx;

		scroll.filters = [];
		var n = Math.abs(rvx);
		var lim = 14;

	}
	function formatTime(n:Float) {
		var d = DateTools.parse(n);
		var min = Std.string(d.minutes);
		var sec = Std.string(d.seconds);
		while( min.length < 2 ) min = "0" + min;
		while( sec.length < 2 ) sec = "0" + sec;
		return d.hours + ":" + min + ":" + sec;
	
	}
		
	// SELECT
	function unselect() {
		if( selection == null ) return;
		selection.card.fxOut();
		Browser.me.removeHint();
		selection = null;
	}
	function select(slot) {
		selection = slot;
		if( selection == null ) return;
		if( !slot.available ) {
			Browser.me.displayNotAvailable();
			return;
		}
		
		selection.card.fxOver();
		Browser.me.displayHint(selection.card.getDesc());
	}
	


//{
}
















