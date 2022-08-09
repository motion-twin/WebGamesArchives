
class InterfInvent extends Inventory {

	static var blockBitmaps = new IntHash<flash.display.BitmapData>();
	
	var tw : mt.deepnight.Tweenie;
	var invMC : flash.display.Sprite;
	var invCurrent : flash.display.Sprite;
	var blockSnapshot : Array<{count:String, block:Block}>;
	var chargeSnapshot : Array<{count:String, kind:Int}>;
	var invContent : Array<{
		mc : flash.display.Sprite,
		count : Null<flash.text.TextField>,
		block : Block,
		index : Int,
	}>;
	var invCharges : Array<{
		mc : flash.display.Sprite,
		count : flash.text.TextField,
		kind : Int,
	}>;

	public function new(infos, root, tw) {
		super(infos);
		invMC = root;
		this.tw = tw;
		invContent = [];
		invCharges = [];
	}

	public function clean() {
		for( c in invContent ) {
			c.mc.parent.removeChild(c.mc);
			if( invCurrent == c.mc ) invCurrent = null;
		}
		for( c in invCharges )
			c.mc.parent.removeChild(c.mc);
		invContent = new Array();
		invCharges = new Array();
	}
	
	function drawInvBase(mc:flash.display.Sprite) {
		mc.graphics.clear();
		mc.graphics.beginFill(0x0, 0);
		mc.graphics.drawRect(0,0,40,40);
		mc.graphics.beginFill(0x0, 0.2);
		mc.graphics.moveTo(20,20);
		mc.graphics.lineTo(40,30);
		mc.graphics.lineTo(20,40);
		mc.graphics.lineTo(0,30);
		mc.graphics.endFill();
	}
	
	public function useBlocksIndexes( b : Block, count : Int ) : Array<Int> { // returns changed indexes
		var n = count;
		if( count < 0 ) return [];
		if( count == 0 ) return [0];
		for( i in inv.t )
			if( i != null && i.k == b.index ) {
				n -= i.n;
				if( n <= 0 ) break;
			}
		if( n > 0 ) return [];
		var indexes = [];
		for( i in 0...inv.t.length ) {
			var s = inv.t[i];
			if( s != null && s.k == b.index ) {
				indexes.push(i);
				if( s.n > count ) {
					s.n -= count;
					break;
				}
				inv.t[i] = null;
				count -= s.n;
				if( count == 0 ) break;
			}
		}
		if( indexes.length>0 ) display() else redraw();
		return indexes;
	}

	public function cancelBlock( b : Block, index : Int, use : Bool ) {
		var s = inv.t[index];
		if( use ) {
			if( s == null ) {
				inv.t[index] = { k : b.index, n : 1 };
				display();
				return;
			}
			if( s.k != b.index )
				return;
			s.n++;
		} else {
			if( s == null || s.k != b.index )
				return;
			s.n--;
			if( s.n == 0 ) {
				inv.t[index] = null;
				display();
				return;
			}
		}
		redraw();
	}
	
	override function display() {
		for( index in 0...inv.t.length ) {
			var i = inv.t[index];
			if( i == null ) {
				var mc = new flash.display.Sprite();
				drawInvBase(mc);
				invMC.addChild(mc);
				invContent.push( { mc : mc, count : null, block : null, index : index } );
			}
			else
				addInventory(Block.all[i.k], index);
		}
		for( index in 0...invContent.length ) {
			var s = invContent[index];
			s.mc.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, function(e:flash.events.MouseEvent) { e.stopPropagation(); select(index); onInventorySelect(s.index); } );
			s.mc.addEventListener(flash.events.MouseEvent.MOUSE_UP, function(e:flash.events.MouseEvent) e.stopPropagation());
			s.mc.buttonMode = true;
		}
		inv.charges.sort( function(a,b) return Reflect.compare(a.c, b.c) );
		for( c in inv.charges ) {
			var mc = new flash.display.Sprite();
			mc.addChild( Interface.getIcons().getSprite("charge", c.c) );
			var tf = Interface.newTextField(8);
			tf.width = 40;
			tf.x = 0; // recalé dans redraw
			tf.y = 1;
			mc.addChild(tf);
			invCharges.push( { mc : mc, count : tf, kind : c.c } );
			invMC.addChild(mc);
		}
		redraw();
		select(blockIndex);
	}
	
	function scrollInventory(delta) {
		var index = blockIndex;
		if( delta < 0 ) index++ else index--;
		if( index>= invContent.length ) index = invContent.length-1;
		if( index<0 ) index = 0;
		select(index);
	}
	
	public function select( index : Int ) {
		blockIndex = index;
		var c = invContent[index];
		if( invCurrent != null )
			invCurrent.filters = [];
		invCurrent = c == null ? null : c.mc;
		if( invCurrent != null )
			invCurrent.filters = [new flash.filters.GlowFilter(0xFFFFFF, 1, 4, 4, 5)];
	}
	
	public dynamic function onInventorySelect( index : Int ) {
	}

	override function redraw() {
		for( i in 0...invContent.length ) {
			var c = invContent[i];
			var s = c.mc;
			s.x = Std.int(i * 44);
			s.y = 0;
			if( c.count == null ) continue;
			var i = inv.t[c.index];
			var max = c.block.getMax(inv.maxWeight);
			c.count.text = Std.string(i.n);
			c.count.textColor = i.n >= max ? 0xF08080 : Interface.TEXT_COLOR;
			c.count.x = Std.int(20 - c.count.textWidth*0.5);
		}
		var colors = [0xFFBF00, 0x7DC9F7, 0xE8B3FF, 0xFFFFFF];
		for( i in 0...invCharges.length ) {
			var c = invCharges[i];
			var s = c.mc;
			s.x = Std.int( -20 );
			s.y = Std.int( i*16 );
			c.count.text = Std.string(inv.charges[i].n);
			c.count.x = Std.int( -c.count.textWidth-3 );
			c.count.textColor = colors[c.kind];
		}
	}
	
	public override function useCharge(ck) {
		makeblockSnapshot();
		var b = super.useCharge(ck);
		bumpDifferences();
		return b;
	}
	
	public override function addBlock(b) {
		makeblockSnapshot();
		var n = super.addBlock(b);
		bumpDifferences();
		return n;
	}
	
	public override function addBlocks( b : Block, count : Int ) {
		makeblockSnapshot();
		var n = super.addBlocks(b,count);
		bumpDifferences();
		return n;
	}

	function makeblockSnapshot() {
		blockSnapshot = new Array();
		for( c in invContent )
			if( c==null )
				blockSnapshot.push({count:"", block:null});
			else
				blockSnapshot.push({
					count : c.count==null ? "" : c.count.text,
					block : c.block,
				});
		chargeSnapshot = new Array();
		for( c in invCharges )
			chargeSnapshot.push({
				count : c.count==null ? "" : c.count.text,
				kind : c.kind,
			});
	}
	
	function bumpDifferences() {
		for( i in 1...invContent.length ) {
			var c = invContent[i];
			var s = blockSnapshot[i];
			if( c==null && s!=null || c!=null && s==null || c!=null && (c.count!=null && c.count.text!=s.count || c.block!=s.block) )
				bumpBlock(i);
		}
		for( i in 0...invCharges.length ) {
			var c = invCharges[i];
			var s = chargeSnapshot[i];
			if( c==null && s!=null || c!=null && s==null || c!=null && (c.count!=null && c.count.text!=s.count || c.kind!=s.kind) )
				bumpCharge(i);
		}
	}


	function bumpBlock(idx:Int) {
		if( invContent[idx]==null )
			return;
			
		var mc = invContent[idx].mc;
		tw.terminate(mc, "y");
		mc.y += 10;
		tw.create( mc, "y", mc.y-10, TElasticEnd, 450 );
		
		// nom
		var name = invContent[idx].block.getName();
		var tf = Interface.newTextField(8);
		tf.width = 120;
		tf.height = 40;
		tf.wordWrap = tf.multiline = true;
		tf.text = name;
		tf.x = Std.int(mc.x + 20 - tf.textWidth*0.5);
		tf.y = mc.y+32;
		invMC.addChild(tf);
		
		tw.create(tf, "y", tf.y+10, TEaseOut, 500).fl_pixel = true;
		tw.create(tf, "alpha", 0, TEaseIn, 2000).onEnd = function() tf.parent.removeChild(tf);
	}
	
	function bumpCharge(idx:Int) { // TODO
		var c = invCharges[idx];
		if( c!=null ) {
			var mc = c.mc;
			tw.terminate(mc, "x");
			mc.x -= 10;
			tw.create( mc, "x", mc.x+10, TElasticEnd, 450 );
		}
	}

	function addInventory( block : Block, index : Int ) {
		var me = this;
		var s = new flash.display.Sprite();
		var bmp = blockBitmaps.get(block.index);
		if( bmp == null ) {
			bmp = Game.inst.render.renderBlock(block, 45);
			blockBitmaps.set(block.index, bmp);
		}
		var b = new flash.display.Bitmap(bmp);
		s.addChild(b);
		var tf = Interface.newTextField(8);
		tf.width = 40;
		tf.y = 32;
		s.addChild(tf);
		invContent.push( { mc : s, block : block, count : tf, index : index } );
		invMC.addChild(s);
	}
	
	
}