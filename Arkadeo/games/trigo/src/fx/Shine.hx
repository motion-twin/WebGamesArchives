package fx;
import api.AKProtocol;

class Shine extends mt.fx.Fx {

	var block : Block;
	var timer : Int;

	var sp : SP;
	var mask : SP;

	public function new( block : Block ) {
		super();
		this.timer = 0;
		this.block = block;

		sp = new SP();
		sp.graphics.lineStyle(2, 0x333333);
		sp.graphics.drawRect( -Game.BLOCK_SIZE/2, -Game.BLOCK_SIZE/2, Game.BLOCK_SIZE, Game.BLOCK_SIZE );
		sp.graphics.endFill();

		block.sp.addChild( sp );

		mask = new SP();
		mask.graphics.beginFill(0,1);
		mask.graphics.drawRect( -Game.BLOCK_SIZE/2, -Game.BLOCK_SIZE/2, Game.BLOCK_SIZE, Game.BLOCK_SIZE );
		mask.graphics.endFill();
		block.sp.addChild( mask );
		block.sp.mask = mask;

		Game.me.dm.over( block.sp );
	}

	override function update() {
		var t = 1+Math.sin( timer*Math.PI/20 );
		t = 2 + t;

		block.sp.filters = [
			new flash.filters.GlowFilter( 0xFFFFFF, 0.8, 20, 20, t )
		];

		timer++;
	}

	override function kill(){
		super.kill();
		block.sp.mask = null;
		if( sp != null && sp.parent != null )
			sp.parent.removeChild( sp );
		if( mask != null && mask.parent != null )
			mask.parent.removeChild( mask );

		Game.me.dm.ysort(Game.DP_BLOCKS);

		block.sp.filters = [];
	}

}
