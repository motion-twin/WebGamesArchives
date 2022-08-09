import GameData._ArtefactId ;
import Map.Bounds ;

enum TypeInfo {
	MorePa ;
	Chouettex ;
	Tired ;
}



class PopInfo {
	
	static var DX = 2 ;
	static var DY = 2 ;
	
	static var FIELD_COLOR = 0xFFFFFF ;
	static var FIELD_COLOR_OVER = 0xfbc317 ;
	
	public var mc : {>flash.MovieClip, _title : flash.TextField, _field : flash.TextField} ;
	public var mcHide : flash.MovieClip ;
	public var dm : mt.DepthManager ;
	public var omc : ObjectMc ;
	public var omcQty : {>flash.MovieClip, _field : flash.TextField} ;
	public var type : TypeInfo ;
	var map : RegionMap ;
	var mcField : flash.MovieClip ;
	
	public var fAction : Void -> Void ;
	
	
	public function new(t : TypeInfo, r : RegionMap, b : Bounds, p : Place) {
		map = r ;
		
		mcHide = Map.me.dm.empty(Map.DP_GREY) ;
		mcHide.beginFill(0x000000, 50) ;
		mcHide.moveTo(0, 0) ;
		mcHide.lineTo(ScrollMap.WIDTH, 0) ;
		mcHide.lineTo(ScrollMap.WIDTH, ScrollMap.HEIGHT) ;
		mcHide.lineTo(0, ScrollMap.HEIGHT) ;
		mcHide.lineTo(0, 0) ;
		mcHide.endFill() ;
		
		mcHide.onRelease = this.kill ;
		
		mc = cast Map.me.dm.attach("mapInfo", Map.DP_MSG) ;
		//mc._xscale = mc._yscale = 75 ;
		mc._x = ScrollMap.WIDTH / 2 ;
		mc._y = ScrollMap.HEIGHT / 2 ;
		dm = new mt.DepthManager(mc) ;
		//setPos(b, p) ;
		
		Map.me.rMap.noMove = true ;
		
		var format = new flash.TextFormat() ;
		format.font = "Trebuchet MS";
		format.bold = true ;
		format.underline = true ;
		format.color = 0xFFFFFF ;
				
		
		switch (t) {
			case MorePa :
				mc._title.text = "Tu es fatigué !" ;
				mc._field.setNewTextFormat(format) ;
				mc._field.selectable = false ;
				mc._field.text = "Boire une potion de vigueur et aller à : " + p.text ;
			
				fAction = callback(function(p : PopInfo, pl : Place) {
					if (Map.me.loader.isLoading())
						return ;
					if (p.omcQty != null)
						p.omcQty._field.text = "x " + Std.string(Map.me.data._ppa - 1) ;
					//Map.me.refill() ;
					p.blockClicks() ;
					p.map.callMove(pl, false, true) ;
					//p.kill() ;
				}, this, p) ;

			case Chouettex : 
				mc._title.text = "Plus de potion de vigueur !" ;
				mc._field.setNewTextFormat(format) ;
				mc._field.selectable = false ;
				mc._field.text = "Vite ! Appeler Chouette-Ex !" ;
			
				mc._field._y = 3 ;
			
				fAction = callback(function(p : PopInfo) {
					if (Map.me.loader.isLoading())
						return ;
					Map.me.loader.initLoading(1) ;
					p.blockClicks() ;
					flash.Lib.getURL("/act/shop/s24835?p=Pa","_self");
				}, this) ;

			case Tired : 
				mc._title.text = "Tu es fatigué !" ;
				mc._field.setNewTextFormat(format) ;
				mc._field.selectable = false ;
				mc._field.text = "Impossible de bouger... Mais c'est quoi ce bruit ? " ;
			
			
				fAction = callback(function(p : PopInfo) {
					if (Map.me.loader.isLoading())
						return ;
					Map.me.loader.initLoading(1) ;
					p.blockClicks() ;
					flash.Lib.getURL("/act?did=helpChx","_self");
				}, this) ;
		}
		
		omc = new ObjectMc(_Pa, dm, 2, null, null, null, 150) ;
		
		mcField = dm.empty(0) ;
		mcField.beginFill(1, 0) ;
		mcField.moveTo(mc._field._x, mc._field._y) ;
		mcField.lineTo(mc._field._width + mc._field._x, mc._field._y) ;
		mcField.lineTo(mc._field._width + mc._field._x, mc._field._height + mc._field._y) ;
		mcField.lineTo(mc._field._x, mc._field._height + mc._field._y) ;
		mcField.lineTo(mc._field._x, mc._field._y) ;
		mcField.endFill() ;
		mcField.onRelease = fAction ;
		
		mcField.onRollOver = callback(function(p : PopInfo, pp : Place) {
			var tf = new flash.TextFormat() ;
			tf.color = PopInfo.FIELD_COLOR_OVER ;
			p.mc._field.setTextFormat(tf) ;
			//pp.mc.onRollOver() ;
			pp.map.highlightRoad(pp) ;
		}, this, p) ;
		mcField.onRollOut = callback(function(p : PopInfo, pp : Place) {
			var tf = new flash.TextFormat() ;
			tf.color = PopInfo.FIELD_COLOR ;
			p.mc._field.setTextFormat(tf) ;
			pp.map.hideRoad() ;
			//pp.mc.onRollOut() ;
		}, this, p) ;
		
		omc.mc._x = -120 ;
		omc.mc._y = -8 ;
		/*omc.mc._xscale = 150 ;
		omc.mc._yscale = 150 ;*/
		
		omc.mc.onRelease = fAction ;
		omc.mc.onRollOver = mcField.onRollOver ;
		omc.mc.onRollOut = mcField.onRollOut ;

		mc.onRelease = omc.mc.onRelease ;
		mc.onRollOver = omc.mc.onRollOver ;
		mc.onRollOut = omc.mc.onRollOut ;
		
		omcQty = cast omc.mc.attachMovie("mcQty", "mcQty_0", 2) ;

		omcQty._xscale = 85 ;
		omcQty._yscale = omcQty._xscale ;
		omcQty._x = 0 ;
		omcQty._y = 25 ;
		omcQty._field.text = "x " + Std.string(Map.me.data._ppa) ;
		
		
	}
	
	
	public function blockClicks() {
		if (mcHide != null) {
			mcHide.onRelease = null ;
		}
		
		if (mc != null) {
			mc.onRelease = null ;
			mc.onRollOver = null ;
			mc.onRollOut = null ;
		}
		
		if (omc != null && omc.mc != null) {
			omc.mc.onRelease = null ;
			omc.mc.onRollOver = null ;
			omc.mc.onRollOut = null ;
		}
		
	}
	
	function setPos(b : Bounds, p : Place) {
		
		for (i in 0...4) {
			switch(i) {
				case 0 : //NE
					if (mc._width + DX + p.px > map.wbounds.xMax || p.py - DY - mc._height < map.wbounds.yMin)
						continue ;
					mc._x = p.px + DX ;
					mc._y = p.py - DY - mc._height ;
					break ;
				case 1 : //SE
					if (mc._width + DX + p.px > map.wbounds.xMax || p.py + mc._height + DY > map.wbounds.yMax)
						continue ;
					mc._x = p.px + DX ;
					mc._y = p.py + DY ;
					break ;
				case 2 : //SO
					if (p.px - mc._width - DX < map.wbounds.xMin || p.py + mc._height + DY > map.wbounds.yMax)
						continue ;
					mc._x = p.px - DX - mc._width ;
					mc._y = p.py + DY  ;
					break ;
				case 3 : //NO
					if (p.px - mc._width - DX < map.wbounds.xMin || p.py - mc._height - DY < map.wbounds.yMin)
						continue ;
					mc._x = p.px - DX - mc._width ;
					mc._y = p.py - DY - mc._height ;
					break ;
			}
		}
		
	}
	
	
	public function kill() {
		Map.me.rMap.noMove = false ;
		
		if (omc != null)
			omc.kill() ;
		mc.removeMovieClip() ;
		if (mcHide != null)
			mcHide.removeMovieClip() ;
	}
	
	
	
}