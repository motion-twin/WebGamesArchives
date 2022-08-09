import DefaultImport;
import flash.text.TextField;
import mt.deepnight.Tweenie;
import mt.fx.Blink;
import mt.fx.Sleep;
import mt.fx.Vanish;
import mt.gx.time.FTimer;
using mt.gx.Ex;

class UpBonus extends Bonus
{
	public var pow : CharPowers;
	public var staged = false;
	public var uid = 0;
	static var guid = 0;
	public function new(n:Int,p:CharPowers) 
	{
		pow = p;
		super(n);
		
		if (mc != null)  mc.detach();
		
		mc = Ui.makePow(p);
		isPow = true;
		
		#if debug
		mc.filters = [ new flash.filters.GlowFilter(0xFF0000, 1, 25, 25, 10) ];
		mc.alpha = 1.0;
		#end
		
		//trace("gen up "+mc.y);
		name = "upbonus" + (uid = guid++);
		
		syncPos();
	}
	
	public function toString() {
		return name+" " + cx + " " + cy;
	}
	
	override public function restage()
	{
		if ( game.char.powers.has( pow ) && mc != null)
		{
			mc.detach();
 			mc.visible = false;
			staged = false;
			//trace("destaged " + name+" "+cx+";"+cy);
			return;
		}
		else {
			staged = true;
			//trace("restaged " + name+" "+cx+";"+cy);
			super.restage();			
		}
	}
	
	override public function getHitLabel() {
		return Text.resolve('bonusTxtHit_' + pow.index());
	}
	
	override public function updatePhy() {
		
		if ( game.char.powers.has( pow ))
			FTimer.delay( kill , 1);
		else 
			super.updatePhy();
	}
	
	public function powLit(p) { 
		return switch(p)
		{
			case CP_DOUBLE_JUMP: "dbl";
			case CP_WALL_STICK: "grab";
			case CP_SUPER_JUMP: "super";
			
			case CP_KICK: "kick";
			case CP_CANCEL: "cancel";
		}
	}
	
	public override function kill2(){
	}
	
	public override function onProc()
	{
		var char = game.char;
		super.onProc();
		
		if ( Game.isLevelup())
		{
			var tlit = "lvl_" + (1 + Game.getLevel()) + "&" + powLit(pow);
			if( Text.ALL.exists( tlit ))
				new fx.SMS( Text.resolve( tlit ) );
		}
		char.powers.set(pow); 
		game.level.bonuses.findAndRemove( function( p ) return p.pow == pow );
		
		var pos = mc.getRect( Game.me ); 
		mc.detach();
		mc.x = pos.x;
		mc.y = pos.y;
		game.addChild( mc );
		
		var oe = function()
		{
			mc.detach();
			mc  = null;
			char.powers.set( pow );
		}
		var b = game.ui.powers[pow.index()] ;
		var tx = game.tweenie.create(mc, "x", b.x, TType.TBurnIn, 675  );
		var ty = game.tweenie.create(mc, "y", b.y, TType.TBurnOut, 675 );
		mc.alpha = 0.5;
		tx.onEnd = oe;
		
		if(!Game.isLowQuality())
			tx.onUpdateT = function(r) new fx.Shade( mc, 5 );
	}
}