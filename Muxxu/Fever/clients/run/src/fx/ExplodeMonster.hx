package fx;

class ExplodeMonster extends mt.fx.Fx{//}
	
	var sq:world.Square;
	var step:Int;
	var timer:Int;
	var sprite:pix.Sprite;


	public function new(sq:world.Square) {
		this.sq = sq;
		super();
		
		sprite = new pix.Sprite();
		sprite.setAnim(Gfx.monsters.getAnim("explode_0"));
		step = 0;
		timer = 0;
		sprite.anim.onFinish = shake;
		sq.island.dm.add(sprite, world.Island.DP_ELEMENTS);
		sprite.x = (sq.x+0.5) * 16;
		sprite.y = (sq.y+0.5) * 16;
				
	}
	
	override function update() {
		
	}
	
	function shake() {
		sprite.setAnim( Gfx.monsters.getAnim("explode_1"), true );
		sprite.anim.onFinish = explode;

	}
	
	function explode() {
		if( timer++ < 6 ) return;
		sprite.setAnim( Gfx.monsters.getAnim("explode_2"), false );
		sprite.anim.onFinish = end;
		World.me.setControl(true);
	}
	
	function end() {
		sprite.parent.removeChild(sprite);
		kill();
	}

	
//{
}








