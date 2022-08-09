package fx;
import Protocole;
import mt.bumdum9.Lib;
import Snake;

private typedef BSlot = { el:pix.Element, fruit:pix.Element, data:DataFruit };

class Bounty extends CardFx {//}
	
	static var MAX = 3;

	var board:SP;
	var slots:Array<BSlot>;
	var timer:Null<Int>;
	public static var me:Bounty;
	
	public function new(ca) {
		super(ca);
		board = new SP();
		Game.me.dm.add(board, Game.DP_INTER);
		
		me = this;
		
		slots = [];
		for ( i in 0...MAX ) {
			var el = new pix.Element();
			el.drawFrame(Gfx.main.get("prime"));
			var p = Game.getCardPos(3 + i);
			el.x = p.x;
			el.y = p.y;
			board.addChild(el);		
			
			var fruit = new pix.Element();
			fruit.y = -2;
			el.addChild(fruit);
			
			Filt.grey(fruit, 1);
			fruit.blendMode = flash.display.BlendMode.OVERLAY;
			Filt.glow(fruit, 2, 4, 0x222222 );		
			
			var slot = { el:el, fruit:fruit, data:null };
			slots.push(slot);
			
			el.filters = [
				new flash.filters.GlowFilter(0, 0.5, 2, 2, 4),
				new flash.filters.DropShadowFilter(1,90,0,0.2,0,0,1),
			];
			
			var e = new mt.fx.Spawn(el,0.1,false);
			e.setFadeScale(0, 1);
			
			majBounty(slot);
			
		}

		
		
	}
	

	override function update() {
		super.update();
		if ( timer == null ) return;
		if ( timer-- < 0 ) {
			for (sl in slots ) {
				majBounty(sl);
				new mt.fx.Flash(sl.el);
			}
			timer = null;
		}
		
	}
	
	function majBounty(slot:BSlot ) {
		var rank = Game.me.getRandomFruitRank();
		var data = Fruit.getData(rank);
		slot.data = data;
		var id = Fruit.getId(rank);
		slot.fruit.drawFrame( Gfx.fruits.get(id));	
		slot.fruit.visible = true;
		
	}
	
	public function onEat(fr:Fruit) {
		var max = 0;
		
		for ( sl in slots ) if (sl.fruit.visible) max++;		
		for ( sl in slots ) {
			if ( !sl.fruit.visible || fr.data.rank != sl.data.rank ) continue;
			sl.fruit.visible = false;
			var score = Std.int( 16000*Math.pow(2,3-max));
			max--;			
			Game.me.incScore(score, sl.el.x- Stage.me.root.x, sl.el.y-Stage.me.root.y );
			timer = 1600;
			if ( max == 0 ) timer = 20;
			break;
		}		
	}
	
	
	
	override function kill() {
		super.kill();
		board.parent.removeChild(board);
	}

	
	

	
//{
}












