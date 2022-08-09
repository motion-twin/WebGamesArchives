package world.ent;
import Protocole;
import mt.bumdum9.Lib;




class Reward extends world.Ent {//}
	
	var el:pix.Element;
	public var rew:_Reward;
	
	public function new(island, sq, t:_Reward ) {
		type = EBonus;
		super(island, sq);
		rew = t;
		
		// ELEMENT
		el = new pix.Element();
		el.y = -2;
		addChild(el);

		//
		majGfx();
		
		
	}
	public function majGfx(){
		var fr = getFrame(rew);
		el.filters = [];

		
		if( isSuperChest(rew,sq.id) ) {
			fr = Gfx.world.get(isWin()?3:2 , "chest");
			block = true;
		}else if( Common.isChest(rew) ) {
			fr = Gfx.world.get(isWin()?1:0 , "chest");
			block = true;
		}else {
			Filt.glow(el, 2, 4, 0x550000);
		}
		el.drawFrame(fr);
		
		el.visible = !isWin() || block;
		
	}


	override function heroIn() {
		if( !World.me.sendReady() || isWin()) return;
		grab();
		
		new fx.GroundGrab(rew);
		if( isContainer(rew) ) 	majGfx();
		else					kill();
		
		
	}
		
	override function trigSide() {
		if( !isContainer(rew) ) 		return false;
		if( !World.me.sendReady() ) {
			World.me.setControl(true);
			return true;
		}
		
		var ok = false;
		if( Common.isChest(rew)  ) {
			ok = world.Loader.me.data._inv._key > 0;
			if( !ok ) world.Inter.me.displayHint(Lang.NEED_KEY);
		}
		if( isSuperChest(rew,sq.id)  ) {
			ok = world.Loader.me.have(Wand);
			if( !ok ) world.Inter.me.displayHint(Lang.NEED_WAND);
		}
						
		if( ok && !isWin() ) {
			grab();
			var fr = world.ent.Reward.getFrame(Key);
			//if( isSuperChest(rew) ) fr = world.ent.Reward.getFrame(Item(Wand));
			new fx.OpenChest(this,fr);
		}else {
			World.me.setControl(true);
		}
		return true;
	}
	
	override function isTrig() {
		return isContainer(rew) && !isWin();
	}
	
	function grab() {
		
		World.me.send( _Grab( sq.id, rew ) ) ;
		sq.conquest();
	
	}
	
	
	override function kill() {
		
		super.kill();
		el.visible = false;
	}
	
	//
	function isWin() {
		var sta = island.getStatus();
		switch(sta) {
			case ISL_DONE : return true;
			case ISL_EXPLORE(a,rew) : return rew==null;
			case ISL_UNKNOWN : return false;
		}
	}
	
	// STATIC TOOLS
	public static function getFrame(rew:_Reward) {
		var fr:pix.Frame = null;
		switch(rew) {
			case Item(item):		fr = Gfx.inter.get(Type.enumIndex(item),"items");
			case IBonus(b):			fr = Gfx.inter.get(Type.enumIndex(b),"bonus_island");
			case Cartridge(id):		fr = Gfx.inter.get(4,"bonus_ground");
			case Heart:				fr = Gfx.inter.get(3,"bonus_ground");
			case IceBig:			fr = Gfx.inter.get(2,"bonus_ground");
			case Ice:				fr = Gfx.inter.get(1,"bonus_ground");
			case Key:				fr = Gfx.inter.get(0,"bonus_ground");
			case GBonus(b):			fr = Gfx.inter.get(Type.enumIndex(b), "bonus_game");
			case Portal	:			fr = Gfx.world.get(0, "portal");
		}
		
		return fr;
	}
	public static function isSuperChest(rew,sqid) {
		switch( rew ) {
			case Item(item) :
				var a = [MagicRing, Windmill, Voodoo_Doll, Voodoo_Mask ];
				for( it in a ) 	if( item == it ) return true;
				return false;
			case IceBig :			return sqid % 4 == 0;
			case Cartridge(id) :	return id % 8 == 0;
			default : 				return false;
		}
	}
	public static function isContainer(rew) {
		if( Common.isChest(rew) ) 		return true;
		return false;
	}
	
	//
	override function getProtectValue() {
		return 5;
	}
	
	
//{
}








