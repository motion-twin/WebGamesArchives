package ent;
import Protocol;
import mt.bumdum9.Lib;
import api.AKProtocol;

class Bonus extends Ent
{

	public var kind(default, null):BonusKind;
	var gfx:EL;
	
	public function new(kind:BonusKind)
	{
		super();
		this.kind = kind;

		gfx = new EL();
		switch( kind ) {
			case BK_Jump: gfx.goto("shoe");
			case BK_Star: gfx.goto("cap");
		}
		root.addChild(gfx);
		var sq = Game.me.getFreeRandomSquare();
		this.setSquare(sq.x, sq.y);
		new mt.fx.Flash(root);
	}
	
	override function update() {
		super.update();
		/*collision*/
		var h = Game.me.hero;
		if( !h.dead && h.step != JUMPING ){
			var dist = getDistTo(h);
			if( dist < ray + 6 ) {
				Game.me.inter.setBonus( kind );
				kill();
			}
		}
	}
	
	override public function kill() {
		this.square.fxTwinkle();
		this.square.fxTwinkle();
		super.kill();
	}
}