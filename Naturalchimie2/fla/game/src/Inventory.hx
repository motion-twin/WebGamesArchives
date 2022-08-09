import mt.bumdum.Lib ;
import GameData._Artefact ;
import GameData._ArtefactId ;
import anim.Anim.AnimType ;
import anim.Transition ;
import Game.GameStep ;


class Inventory {
	
	static var DP_BG = 1 ;
	static var DP_SLOT = 2 ;
	static var DP_OBJECT = 3 ;
	static var DP_OVER = 4 ;
	
	static var X = Const.INTER_X ;
	static var Y = 352 ; 
	static var LX = 5 ; 
	static var DX = 5 ; 
	static var DY = 5; 
	static var SD = 1 ; //delta in slot
	static var LINE = 2 ;
	
	public static var SCALE = [60, 100, 135] ;
	static var POS = [ /* pres zoom recals : group.mc.x/y recal , o.omc.mc.x/y recal , halo on click x/y recal*/
				[0, 42, 0, -18, 10, -18], 
				[50, 42, 0, -18, -12, -13],
				[2, 56, 0, 0, 10, -10],
				[53, 76, 0, -10, -12, -10]] ;
	
	
	public var slots : Array<{a : anim.Anim, over : flash.MovieClip}> ;
	public var objects : Array<StageObject> ;
	public var size : Int ;
		
	public var dm : mt.DepthManager ;
	public var mc : flash.MovieClip ;
		
	
	public function new(s : Array<_ArtefactId>) {
		size = s.length ;
		objects = new Array() ;
		slots = new Array() ;
		
		Game.me.gui._inventory_slot.gotoAndStop(size + 1) ;
						
		mc = Game.me.mdm.empty(Const.DP_INVENTORY) ;
		mc._x = 0 ;
		mc._y = Y ;
		
		dm = new mt.DepthManager(mc) ;
		var l = -1 ;
		for (i in 0...size) {
			if (Const.sMod(i, 2) == 0)
				l++ ;
			
			//var slot = {bg : dm.attach("inventory_slot", DP_SLOT), over : dm.attach("inventory_slot", DP_OVER)} ;
			var o = null ;
			switch(i) {
				case 0 : o = Game.me.gui._inventory_slot._obj1 ;
				case 1 : o = Game.me.gui._inventory_slot._obj2 ;
				case 2 : o = Game.me.gui._inventory_slot._obj3 ;
				case 3 : o = Game.me.gui._inventory_slot._obj4 ;
			}
			var slot = {a : null, over : o} ;
			
			
			//slot.over._alpha = 1 ;
			/*slot.over._x = slot.bg._x ;
			slot.over._y = slot.bg._y ;*/
			
			slot.over.onRollOver = callback(function(inv : Inventory, j : Int) {
				//Col.setPercentColor(m, 30, 0xFFFFFF) ;
				var g = inv.objects[j] ;
				if (g == null || Game.me.isGameOver()/* || Game.me.step != Play*/)
					return ;
				if (inv.slots[j].a != null)
					inv.slots[j].a.kill() ;
				
				inv.slots[j].a = new anim.Anim(g.omc.mc._b, Scale, Elastic(-1, 1), {x : Inventory.SCALE[1], y : Inventory.SCALE[1], speed : 0.06}) ;
				inv.slots[j].a.start() ;
				
			}, this, i) ;
			slot.over.onRollOut = callback(function(inv : Inventory, j : Int) {
				//Col.setPercentColor(m, 0, 0xFFFFFF) ;
				var g = inv.objects[j] ;
				if (g == null)
					return ;
				if (inv.slots[j].a != null)
					inv.slots[j].a.kill() ;
				
				inv.slots[j].a = new anim.Anim(g.omc.mc._b, Scale, Elastic(-1, 1), {x : Inventory.SCALE[0], y : Inventory.SCALE[0], speed : 0.06}) ;
				inv.slots[j].a.start() ;
				
			}, this, i) ;
			slot.over.onReleaseOutside = slot.over.onRollOut ;
			
			slots.push(slot) ;
		}
		
		for (a in s) {
			add(a) ;
		}
	
	}
	
	
	public function add(oid : _ArtefactId) {
		if (oid == null)
			return ;
		
		var p = getSlot() ;
		if (p == null)
			return ;
		
	/*	var g = new Group(oid, true) ;
		g.objects[0].inStock = true ;
		objects[p] = g ;*/
		
		//var g = new ObjectMc(oid, dm, 2, null, null, null, null, SCALE[1]) ;
		var g = StageObject.get(oid, Game.me.mdm, Const.DP_NEXT_GROUP, null, null, SCALE[2]) ;
		objects[p] = g ;
		
		var s = slots[p] ;
				
		g.omc.mc._b._xscale = SCALE[0] ;
		g.omc.mc._b._yscale =g.omc.mc._b._xscale ;
		
		g.omc.mc._b._x += POS[p][2] ;
		g.omc.mc._b._y += POS[p][3] ;
		//###
		g.omc.mc._x = Game.me.gui._inventory_slot._x + POS[p][0] + POS[p][2] ;
		g.omc.mc._y = Game.me.gui._inventory_slot._y + POS[p][1] + POS[p][3] ;
				
		/*g.mc._x = LX + s.bg._x + SD + 30 ;
		g.mc._y = Y + s.bg._y + SD + 7 ;*/
		
		s.over.onRelease = callback(function(inv : Inventory, pos : Int) {
			var o = inv.objects[pos] ;
			if (o == null || Game.me.isGameOver() || Game.me.step != Play)
				return ;
				
				var testG = Game.me.inventory.remove(pos) ; 
				if (testG == null)
					return  ;
			
				
				var a = new anim.Anim(g.omc.mc._b, Scale, Linear, {x : 15, y : 15, speed : 0.155}) ;
				a.onEnd = callback(function(oo : StageObject, pp : Int) {
					oo.omc.mc._alpha = 0 ;
					//###
					oo.setHalo(30, 1.3, 7, Inventory.POS[pp][2], Inventory.POS[pp][3]) ;
					
					if (oo.onClick(pos)) {
						Game.me.log.use(oo.getArtId()) ;
						oo.kill() ;
					}
				}, g, pos) ;
				a.start() ;
				
				var b = new anim.Anim(o.omc.mc._b, Color(0xFFFFFF, 1), Linear, {speed : 0.1}) ;
				b.start() ;
			}, this, p) ;
	}
	
	
	function getSlot() : Int {
		for (i in 0...slots.length) {
			if (objects[i] == null)
				return i ;
			
		}
		return null ;
	}
	
	
	public function remove(pos : Int) : StageObject {
		var g = objects[pos] ;
		if (g != null) {
			objects[pos] = null ;
			return g ;
		}
		return null ;
	}
	
}