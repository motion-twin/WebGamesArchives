package utils;
import Protocole;
import mt.bumdum9.Lib;
import Fruit;
import mt.bumdum9.Lib;
/*
typedef FruitSlot = {
	but:flash.display.Sprite,
	el:pix.Element,
	data:DataFruit,
}

*/
class FruitEditor {//}

	static var MARGIN = 120;

	public var options:Array<Bool>;
	
	public var slots:Array<FruitSlot>;
	public var tags:Array<TagSlot>;
	public var opts:Array<TagSlot>;
	public var mode:TagSlot;
	public var root:flash.display.Sprite;
	public var drag:FruitSlot;
	public var selection:FruitSlot;
	
	public var seekString:Null<String>;
	
	// INTER
	var screen:pix.Element;
	var fieldName:flash.text.TextField;
	var fieldScore:flash.text.TextField;
	var fieldAvScore:flash.text.TextField;
	var fieldCal:flash.text.TextField;
	var fieldVit:flash.text.TextField;
	var fieldSta:flash.text.TextField;
	var fieldFreq:flash.text.TextField;
	var fieldTags:flash.text.TextField;
	
	static public var me:FruitEditor;

	public function new() {
		me = this;
		root = new flash.display.Sprite();
		Main.dm.add(root, 1);
		
		//
		//seekString = "ine";
		options = [false, false, false];
		paintMode = 0;
		paint = null;
		
		// BG
		var bg = new flash.display.Sprite();
		bg.graphics.beginFill(Gfx.col("green_0"));
		bg.graphics.drawRect(0, 0, Cs.mcw * 2, Cs.mch * 2);
		root.addChild(bg);
		bg.addEventListener(flash.events.MouseEvent.MOUSE_UP, endDrag);
		
		// SLOTS
		slots = [];
		while( DFruit.LIST.length < DFruit.MAX ) {
			var o = { score:10, cal:10, vit:10, sta:10, rank:DFruit.LIST.length, tags:[], freq:1 };
			DFruit.LIST.push(o);
		}
		
		for ( id in 0...DFruit.LIST.length ) new FruitSlot(id);
	
		// MODE
		var me = this;
		var ma = 1;
		var bx = MARGIN + 0.0;
		var by = Cs.mch * 2 - 16;
		mode = new TagSlot( null, 1 );
		mode.x = MARGIN;
		mode.y = by;
		mode.setState(3);
		mode.addEventListener(flash.events.MouseEvent.CLICK, function(e) { me.cyclePaint(); } );
		bx += mode.width + ma;
		
		// TAGS
		tags = [];
		var a = Type.getEnumConstructs(FTag);
		for ( str in a ) {
			var tag  = new TagSlot( Type.createEnum(FTag, str)  );
			tag.x = bx;
			tag.y = by;
			bx += tag.width + ma;
			tag.addEventListener(flash.events.MouseEvent.CLICK, function(e) { me.trigTag(tag); } );
			tags.push(tag);
			if( bx > Cs.mcw*2-30 ) {
				bx = MARGIN;
				by -= 16;
			}
		}
		
		
		
		// DISPLAY OPTIONS
		bx = MARGIN;
		opts = [];
		for( i in 0...3 ){
			var opt = new TagSlot( null, 2, i );
			opt.x = bx;
			opt.y = by-16;
			opt.setState(0);
			bx += opt.width + ma;
			opt.addEventListener(flash.events.MouseEvent.CLICK, function(e) { me.trigOpt(i); } );
			opts.push(opt);
		}
		
		
		// KEYBOARD
		Keyb.init();
		Keyb.actions[83] = save;
		//Keyb.pressAction = newFruit;
		
		//
		majSlotPos();
		

	}
	/*
	function addSlot(data:DataFruit) {
		var slot = Fruit.getSlot(data);
	}
	*/

	public function majSlotPos() {
		
		var b = slots.copy();
		
		// FILTER
		var a = [];
		var have = [];
		var dontHave = [];
		for ( st in tags ) {
			if ( st.state == 1 ) have.push(st.type);
			if ( st.state == 2 ) dontHave.push(st.type);
		}
		
		
		for ( sl in b ) {
			
			// DISPLAY
			var add = true;
			for ( tag in have ) {
				if ( !Lambda.has( sl.data.tags, tag ) ) add = false;
			}
			for ( tag in dontHave ) {
				if ( Lambda.has( sl.data.tags, tag ) ) add = false;
			}
			if( seekString != null ) {
				var name = Data.TEXT[Fruit.getId(sl.data.rank)].fruit;
				add = name.indexOf(seekString) >= 0;
			}
			
			if ( add ) {
				sl.el.visible = true;
				a.push(sl);
			}else {
				sl.el.visible = false;
			}
			
			// SKULL
			sl.icon.visible = options[1] && sl.data.score < 0;
			
		}
		
		
		
		// SORT
		var f = function(a:FruitSlot, b:FruitSlot) {
			if ( a.data.rank < b.data.rank ) return -1;
			return 1;
		}
		a.sort(f);
		
		var size = 28;
		var x = 0;
		var y = 0;
		for ( slot in a ) {
			var tx = MARGIN + x + size * 0.5;
			var ty = y + size * 0.5;
			slot.goto(tx, ty);
			x += size;
			if ( x >= Cs.mcw*2-(size+MARGIN) ) {
				x = 0;
				y += size;
			}
		}
	}
	
	public function update(e) {
		for ( slot in slots ) slot.move();
	}

	// SLOTS
	public function moveOn( trg:FruitSlot ) {
		var nid = trg.data.rank;
		for ( sl in slots ) if (sl.data.rank > drag.data.rank ) 	sl.data.rank--;
		for ( sl in slots ) if ( sl.data.rank >= nid )			sl.data.rank++;
		drag.data.rank = nid;
		
		endDrag();
	}
	public function endDrag(?e) {
		if ( drag == null ) return;
		
		for ( sl in slots ) sl.reset();
		majSlotPos();
		drag.el.stopDrag();
		drag = null;
	}
	
	// INTERFACE
	public function select(slot:FruitSlot) {
		if ( selection != null ) selection.unselect();
		selection = slot;
		//
		if ( screen == null ) initInter();
		screen.drawFrame(slot.el.currentFrame);
		fieldName.text = Data.TEXT[Fruit.getId(slot.data.rank)].fruit;//Data.FRUIT_TEXT[ Fruit.getId(slot.data.rank)]._name;
		fieldScore.text = Std.string( slot.data.score );
		majFinalScore(slot);
		fieldCal.text = Std.string( slot.data.cal );
		fieldVit.text = Std.string( slot.data.vit );
		fieldSta.text = Std.string( slot.data.sta );
		fieldFreq.text = Std.string( slot.data.freq );
		
		var str = "";
		for ( tag in slot.data.tags ) {
			if ( str.length > 0 ) str += ",";
			str += ""+tag;
		}
		fieldTags.text = "tags : [" + str + "]";

				
	}
	public function majFinalScore(slot) {
		fieldAvScore.text = Std.string( Std.int((Fruit.getAverageScore(slot.data.rank)*slot.data.score)/10) );
	}
	
	function initInter() {
		
		var y = 0.0;
		
		// SCREEN
		var bg = new flash.display.Sprite();
		bg.graphics.beginFill(0xFFFFFF, 0.15);
		bg.graphics.drawRect(0, y, MARGIN, MARGIN);
		bg.blendMode = flash.display.BlendMode.ADD;
		root.addChild(bg);
		
		screen = new pix.Element();
		screen.scaleX = screen.scaleY = 4;
		screen.x = MARGIN * 0.5;
		screen.y = MARGIN * 0.5 + y;
		root.addChild(screen);
		
		y += MARGIN + 2;
		
		// NAME
		fieldName = getField();
		var tf = fieldName.defaultTextFormat;
		tf.align = flash.text.TextFormatAlign.CENTER;
		fieldName.defaultTextFormat = tf;
		fieldName.multiline = true;
		fieldName.wordWrap = true;
		fieldName.y = y;
		fieldName.height = 30;
		
		y += 60;
		
		var ecy = 24;
		
		// SCORE
		var title = getField(1);
		title.y = y;
		title.text = " score:";
		fieldScore = getField();
		fieldScore.y = y;
		y += 16;
		var average = getField(1);
		average.y = y;
		average.text = "av.score :";
		fieldAvScore = getField(1);
		fieldAvScore.y = y;
		var tf = fieldAvScore.defaultTextFormat;
		tf.align = flash.text.TextFormatAlign.RIGHT;
		fieldAvScore.defaultTextFormat = tf;
		
		y += ecy;
		
		// CAL
		var title = getField(1);
		title.y = y;
		title.text = " calories:";
		fieldCal = getField();
		fieldCal.y = y;
		y += ecy;
		
		// VIT
		var title = getField(1);
		title.y = y;
		title.text = " vitamines:";
		fieldVit = getField();
		fieldVit.y = y;
		y += ecy;
		
		// STAMINA
		var title = getField(1);
		title.y = y;
		title.text = " stamina:";
		fieldSta = getField();
		fieldSta.y = y;
		y += ecy;
		
		// FREQ
		var title = getField(1);
		title.y = y;
		title.text = " freq:";
		fieldFreq = getField();
		fieldFreq.y = y;
		y += ecy;
		
		// TAGS
		fieldTags = getField(1);
		fieldTags.y = y;
		y += ecy;
	}
	function getField(type=0) {
		var field = new flash.text.TextField();
		var tf = new flash.text.TextFormat("verdana", 10, 0xFFFFFF, true);
		switch(type) {
			case 0 :
				tf.align = flash.text.TextFormatAlign.RIGHT;
				field.type = flash.text.TextFieldType.INPUT;
				var fl = new flash.filters.GlowFilter(0x187700, 1, 2, 2, 8);
				field.filters = [fl];
				//field.addEventListener(flash.events.FocusEvent.FOCUS_OUT, saveSelection);
				//field.addEventListener(flash.events.TextEvent.TEXT_INPUT, saveSelection,true);
				field.addEventListener(flash.events.Event.CHANGE, saveSelection);
			case 1 :
				tf = new flash.text.TextFormat("verdana", 10, Gfx.col("green_2"), true);
		}
		
		field.defaultTextFormat = tf;
		field.text = "test";

		

		root.addChild(field);
		field.width = MARGIN;
		field.height = 20;
		return field;
	}
	function saveSelection(e) {
	
		selection.data.score = Std.parseInt( fieldScore.text );
		selection.data.cal = Std.parseInt( fieldCal.text );
		selection.data.vit = Std.parseInt( fieldVit.text );
		selection.data.sta = Std.parseInt( fieldSta.text );
		selection.data.freq = Std.parseInt( fieldFreq.text );
		majFinalScore(selection);
	}
	
	// TAGS
	public var paint:FTag;
	public var paintMode:Int;
	function trigTag(tag:TagSlot) {
		tag.cycleState();
		paint = tag.type;
		
		paintMode = tag.state;
		majPaint();
		
		mode.maj();
		/*
		if ( tag.state == 2 ) {
			for ( t in tags ) if ( t != tag && t.state == 2 ) t.setState(0);
			setPaint(tag.type);
		}
		if ( paint != null ) {
			var tag = tags[Type.enumIndex(paint)];
			if ( tag.state != 2 )setPaint(null);
		}
		*/
		majSlotPos();
	}
	function setPaint(type) {
		paint = type;
		if ( paint == null ) {
			for ( sl in slots ) sl.reset();
		}else {
			for ( sl in slots ) {
				sl.waitPaintBehaviour();
				
			}
		}
	}
	
	function cyclePaint() {
		paintMode = (paintMode + 1) % 3;
		mode.maj();
		majPaint();

	}
	function majPaint() {
		if ( paintMode == 0 ) {
			for ( sl in slots )
				sl.reset();
		}else {
			for ( sl in slots )
				sl.waitPaintBehaviour();
		}
	}
	
	// DISPLAY OPTION
	function trigOpt(id) {
		var opt = opts[id];
		var fl = !options[id];
		options[id] = fl;
		opt.setState(fl?1:0);
		

		switch(id) {
			case 0 :
				if( fl )	fieldName.addEventListener(flash.events.Event.CHANGE, trigSeeker );
				if( !fl ) {
					fieldName.removeEventListener(flash.events.Event.CHANGE, trigSeeker );
					seekString = "";
				}
				
		}
		
		majSlotPos();
		
		
	}
	function trigSeeker(e) {
		seekString = fieldName.text;
		majSlotPos();
	}
	
	// COMMANDS
	function newFruit() {
		var rank = DFruit.LIST.length;
		var score = Fruit.getAverageScore(rank);
		var data = { cal:10, vit:10, score:score, tags:[], rank:rank, sta:10, freq:1 };
		DFruit.LIST.push(data);
		new FruitSlot(rank);
		
		majSlotPos();
	}
	
	

	
	public function resetScores() {
		for ( data in DFruit.LIST )
			data.score = Fruit.getAverageScore(data.rank);

	}
	
	function save() {
		//trace("SAVE");
		var str = "	static public var LIST:Array<DataFruit> = [\n";
		
		for ( slot in slots ) {
			var d = slot.data;
			str += "		{ score:" + d.score + ", cal:" + d.cal + ", vit:" + d.vit + ", sta:" + d.sta + ", freq:" + d.freq + ", rank:" + d.rank;
			str += ", tags:[";
			for ( t in d.tags ) str += t + ",";
			str += "] },\n";
		}
		
		str += "	];\n";
		flash.system.System.setClipboard(str);
	}
	
	
//{
}


class FruitSlot {
	static var SIZE = 30;

	var wp: { x:Float, y:Float };
	
	public var gid:Int;
	public var data:DataFruit;
	public var icon:pix.Element;
	public var el:pix.Element;
	public var but:flash.display.Sprite;
	public var timer:Int;

	
	public function new(id) {
		gid = id;
		data = DFruit.LIST[gid];
		
		el = new pix.Element();
		var gid = FruitEditor.me.slots.length;
		el.drawFrame(Gfx.fruits.get(gid));
		FruitEditor.me.slots.push( this );
		FruitEditor.me.root.addChild(el);
		el.mouseEnabled = false;
		reset();
		
		icon = new pix.Element();
		icon.drawFrame(Gfx.main.get("icon_skull"));
		icon.visible = false;
		icon.mouseEnabled = false;
		el.addChild(icon);
	}
	
	//
	function resetBut() {
		if ( but != null ) el.removeChild(but);
		but = new flash.display.Sprite();
		el.addChild(but);
		but.graphics.beginFill( 0xFF0000, 1);
		but.graphics.drawRect( -SIZE * 0.5, -SIZE * 0.5, SIZE, SIZE);
		but.alpha = 0;
	}
	public function reset() {
		resetBut();
		var me = this;
		but.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, click);
	}
	
	function click(e) {
		el.startDrag(false);
		FruitEditor.me.drag = this;
		var me = this;
		for ( sl in FruitEditor.me.slots ) {
			if ( sl != this ) sl.waitDropBehaviour();
		}
		but.mouseEnabled = false;
		var par = el.parent;
		par.removeChild(el);
		par.addChild(el);
		select();
	}
	function waitDropBehaviour() {
		resetBut();
		but.addEventListener(flash.events.MouseEvent.MOUSE_OVER, dragOver );
		but.addEventListener(flash.events.MouseEvent.MOUSE_OUT, dragOut );
		but.addEventListener(flash.events.MouseEvent.MOUSE_UP, dropOn );
	}
	public function waitPaintBehaviour() {
		resetBut();
		but.addEventListener(flash.events.MouseEvent.MOUSE_OVER, rollOver );
		but.addEventListener(flash.events.MouseEvent.MOUSE_OUT, rollOut );
		but.addEventListener(flash.events.MouseEvent.CLICK, paint );
	}
	
	function dragOver(e) {
		but.alpha = 0.1;
	}
	function dragOut(e) {
		but.alpha = 0;
	}
	function dropOn(e) {
		
		FruitEditor.me.moveOn(this);
		dragOut(e);

	}
	
	function rollOver(e) {
		but.alpha = 0.1;
		switch(FruitEditor.me.paintMode) {
			case 1,2:
				select();
			
		}
		
	}
	function rollOut(e) {
		but.alpha = 0;
	}
	function paint(e) {
		var ptag = FruitEditor.me.paint;
		switch(FruitEditor.me.paintMode) {
			case 0:
				trace("PAINT ERROR");
			case 1:
				data.tags.remove(ptag);
			case 2:
				for ( t in data.tags ) if ( t == ptag ) return;
				data.tags.push(ptag);
			
		}
		FruitEditor.me.majSlotPos();
	}
	
	
	// SELECT
	function select() {
		FruitEditor.me.select(this);
		var fl = new flash.filters.GlowFilter( 0xFFFFFF,1,4,4,4);
		var fl2 = new flash.filters.GlowFilter( 0xFFFF00,0.5,8,8,1);
		el.filters  = [fl, fl2];
		
	}
	public function unselect() {
		el.filters  = [];
	}
	
	// FX
	public function move() {
		
		if ( wp == null || FruitEditor.me.drag==this ) return;
		var dx = wp.x - el.x;
		var dy = wp.y - el.y;
		var c = 0.13;
		el.x += dx * c;
		el.y += dy * c;
	}
	public function goto(x,y) {
		wp = { x:x, y:y };
	}

}

class TagSlot extends flash.display.Sprite {
	
	var id:Int;
	var mode:Int;
	
	public var type:FTag;
	public var state:Int;
	public var field:flash.text.TextField;
	
	public function new(t, m = 0, id = 0 ) {
		this.id = id;
		super();
		type = t;
		mode = m;
		FruitEditor.me.root.addChild(this);
		
		// FIELD
		field = new flash.text.TextField();
		var tf = new flash.text.TextFormat();
		tf.size = 10;
		tf.color = 0xFFFFFF;
		tf.align = flash.text.TextFormatAlign.CENTER;
		tf.font = "verdana";
		field.defaultTextFormat = tf;
		

		field.background = true;
		field.backgroundColor = Gfx.col("green_2");
		field.selectable = false;
		addChild(field);
		//var str = Type.enumConstructor(type);
		field.text = getString();
		field.width = field.textWidth + 6;
		field.height = field.textHeight + 4;
		
		setState(0);
	}
	
	public function setState(n) {
		state = n;
		var bgColor = 		0xFFFFFF;
		var textColor = 	0;
		switch(n) {
			case 0 :
				bgColor = 		Gfx.col("green_2");
				textColor = 	Gfx.col("green_0");
			case 1 :
				bgColor = 		Gfx.col("or_2");
				textColor = 	Gfx.col("or_0");
			case 2 :
				bgColor = 		Gfx.col("red_2");
				textColor = 	Gfx.col("red_0");
			case 3 :
				bgColor = 		0x8888FF;
				textColor = 	0x000044;
		}
		
		field.backgroundColor = bgColor;
		var tf = field.defaultTextFormat;
		tf.color = textColor;
		field.defaultTextFormat = tf;
		field.text = getString();
	}
	
	public function cycleState() {
		setState( (state + 1) % 3 );
	}

	public function maj() {
		field.text = getString();
	}
	
	function getString() {
		switch(mode) {
			case 0 : return Type.enumConstructor(type);
			case 2 :
				var name = ["seek name", "show negative"][id];
				return [name+" off",name+" on"][state];
		}
		switch( FruitEditor.me.paintMode ) {
			case 0 : return "simple selection";
			case 1 : return "untag : "+FruitEditor.me.paint;
			case 2 : return "tag : "+FruitEditor.me.paint;
		}
		
		return "nada";
	}

}






