package ent;

class Chest {
	
	public var game : Game;
	var id : Null<Int>;
	public var x : Int;
	public var y : Int;
	public var z : Int;
	var hpos : { x : Float, y : Float, z : Float };
	
	var changed : Bool;
	var ispr : flash.display.Sprite;
	var i : InterfInvent;
	var curSwap : { i : InterfInvent, idx : Int };
	
	public function new(game,x,y,z) {
		this.game = game;
		this.x = x;
		this.y = y;
		this.z = z;
		hpos = { x : game.hero.x, y : game.hero.y, z : game.hero.z };
		changed = false;
	}
	
	public function open() {
		game.api.send(CGetProperties(x, y, z), onOpen);
	}

	function onOpen( c : Protocol.BlockProperties ) {
		if( id == -1 ) return;
		id = c.id;
		ispr = new flash.display.Sprite();
		i = new InterfInvent( { t : c.content, maxWeight : c.max, charges : [] }, ispr, game.tw);
		i.display();
		i.select(-1);
		game.root.addChild(ispr);
		ispr.x = (game.root.stage.stageWidth - ispr.width) * 0.5;
		ispr.y = 50;
		game.interf.onInventorySelect = callback(checkSwap, game.interf);
		i.onInventorySelect = callback(checkSwap, i);
		game.actionKeys = false;
	}
	
	function checkSwap( i : InterfInvent, index : Int ) {
		if( curSwap == null ) {
			if( i.inv.t[index] == null )
				i.select(-1);
			else if( index >= 0 )
				curSwap = { i : i, idx : index };
			return;
		}
		if( index < 0 )
			return;
		i.select( -1);
		
		var srcInv = curSwap.i;
		var src = srcInv.inv.t;
		var isrc = curSwap.idx;
		var dst = i.inv.t;
		var idst = index;
		
		var bsrc = src[isrc];
		var bdst = dst[idst];
		
		var split = mt.flash.Key.isDown(flash.ui.Keyboard.SHIFT);
		var one = mt.flash.Key.isDown(flash.ui.Keyboard.CONTROL);
		var smax = one ? 1 : (split ? Math.ceil(bsrc.n * 0.5) : bsrc.n);
		
		if( bdst != null && bdst.k == bsrc.k ) {
			// merge
			var max = Block.all[bdst.k].getMax(i.inv.maxWeight);
			
			if( bdst.n >= max ) return; // already full

			var n = max - bdst.n;
			if( n > smax ) n = smax;
			bdst.n += n;
			bsrc.n -= n;
			if( bsrc.n == 0 ) {
				src[isrc] = null;
				curSwap = null;
			}
		} else if( bdst == null ) {
			// move-split
			dst[idst] = { k : bsrc.k, n : smax };
			bsrc.n -= smax;
			if( bsrc.n == 0 ) {
				src[isrc] = null;
				curSwap = null;
			}
		} else {
			// swap
			dst[idst] = bsrc;
			src[isrc] = bdst;
			curSwap = null;
		}
		if( curSwap == null )
			srcInv.select( -1);
		changed = true;
		i.clean();
		i.display();
		if( srcInv != i ) {
			srcInv.clean();
			srcInv.display();
		}
	}
	
	public function update() {
		var dx = hpos.x - game.hero.x;
		var dy = hpos.y - game.hero.y;
		var dz = hpos.z - game.hero.z;
		if( Math.sqrt(dx * dx + dy * dy + dz * dz) > 0.5 ) {
			close();
			return false;
		}
		return true;
	}
	
	public function close() {
		if( i == null ) {
			id = -1; // prevent open result while we closed already
			return;
		}
		i.clean();
		ispr.parent.removeChild(ispr);
		game.actionKeys = true;
		game.interf.onInventorySelect = function(_) { };
		if( changed )
			game.api.send(CMoveContent(id, game.interf.inv.t, i.inv.t), function(ok) {
				if( !ok ) flash.Lib.getURL(new flash.net.URLRequest("/"));
			});
	}
	
}