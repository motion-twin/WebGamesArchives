package world;
import mt.bumdum9.Lib;
import Protocole;

typedef WorldInterBar = { bg:flash.display.Sprite, dm:mt.DepthManager };
typedef InvIcon = { el:pix.Element, box:flash.display.Sprite, action:Void->Void, active:Bool, name:String, desc:String };



enum InterState {
	IS_PLAY;
	IS_INVENTORY;
}


class Inter {//}
	
	public static var BLUE_DARK = 0x101f41;

	public static var BH = 13;
	public static var BGH = 74;// 57;
	public static var FADE = 60;
	
	var freeze:Bool;
	var bagRollOver:Bool;
	
	var visit:Int;
	
	var width:Int;
	var height:Int;
	var cloverRadiate:mt.fx.Radiate;
	
	public var lrx:Float;

	var bars:Array<WorldInterBar>;
	var field:flash.text.TextField;
	var fieldKey:flash.text.TextField;
	var bag:pix.Sprite;
	
	var state:InterState;
	var warningTimer:Null<Int>;
	
	var lastIceCube:pix.Element;
	var lastPinkIceCube:pix.Element;
	var currentIcon:InvIcon;
	var step:Int;
	var coef:Float;
	var mcInv:flash.display.Sprite;
	var idm:mt.DepthManager;
	var buts:Array<InvIcon>;
	
	static public var me:Inter;
	
	public function new() {
		me = this;
	
		width = Std.int(Cs.mcw * 0.5);
		statusIcons = [];
		
		// BARS
		bars = [];
		for( i in 0...2 ) {
			var sp = new flash.display.Sprite();
			World.me.dm.add(sp, World.DP_INTER);
			if( i == 0 ){
				sp.graphics.beginFill(0, 1);
				sp.graphics.drawRect(0, 0, Cs.mcw * 0.5, BH);
			}
			sp.y = ((Cs.mcrh * 0.5) - BH)*i;
			bars.push( { bg:sp, dm:new mt.DepthManager(sp) } );
		}
		
		// INV
		var inv = new pix.Element();
		inv.drawFrame(Gfx.inter.get("inv"), 0, 0 );
		inv.y = 0;
		bars[1].dm.add(inv, 0);
		
		
		// BAG
		bag = new pix.Sprite();
		bag.setAnim(Gfx.inter.getAnim("bag"),false);
		bag.anim.play(0);
		bag.x = 8;
		bag.y = 6;
		bars[1].dm.add(bag, 0);
		
		// KEY
		var key = new pix.Element();
		key.drawFrame(Gfx.inter.get(0,"bonus_ground"));
		key.x = width-14;
		key.y = 6;
		bars[1].dm.add(key, 0);
		
		fieldKey = Cs.getField(0xFFFFFF, 8, -1, "nokia");
		fieldKey.x = key.x + 5;
		fieldKey.text = "0";
		bars[1].dm.add(fieldKey, 0);
		
		
		// ISLAND NAME
		field = Cs.getField(0xFFFFFF, 8, -1, "nokia");
		field.filters = [new flash.filters.GlowFilter(0,1,2,2,40)];
		bars[1].dm.add(field,0);
			
		//
		state = IS_PLAY;
		bagRollOver = false;
		
		//
		majStatus();
			
		//
		flash.Lib.current.stage.addEventListener(flash.events.MouseEvent.CLICK, click);
		
	}
	
	var statusIcons:Array<pix.Element>;
	public function majStatus() {
		var dm = bars[0].dm;
		var d = Loader.me.data;
		while(statusIcons.length > 0) statusIcons.pop().kill();
		
		
		lastIceCube = null;
		lastPinkIceCube = null;
		
		// PLAYS
		var bx = 7;
		var a  = [];
		if(d._plays <= 10) {
			for( i in 0...d._plays ) a.push(1);
		}else {
			var sp = getIceCube(1);
			sp.x = bx;
			var field = Cs.getField(0xFFFFFF, 8, -1, "nokia");
			field.text = Std.string(d._plays);
			field.x = bx + 5;
			field.width = field.textWidth + 3;
			var el = new pix.Element();
			el.addChild(field);
			dm.add(el, 0);
			statusIcons.push(el);
			lastPinkIceCube = sp;
			
			bx = Std.int(field.x + field.width+7);
			
		}
		for( i in 0...d._dailyPlays ) 	a.push(0);
		
	
		var id = 0;
		for( n in a ) {
			var sp = getIceCube(n);
			sp.x = bx + id * 11;
			id++;
			lastIceCube = sp;
			if( n == 1 ) lastPinkIceCube = sp;
		}
		dm.ysort(0);
		
		// RAINBOW
		lrx = 200;
		for( i in 0...d._rainbows ) {
			var sp = new pix.Element();
			dm.add(sp, 0);
			sp.drawFrame( Gfx.inter.get("rainbow") );
			sp.x = width - ( 10 + i * 11 );
			sp.y = 7;
			lrx = sp.x;
			Filt.glow(sp, 2, 4, 0);
			statusIcons.push(sp);
		}
		
		// KEY
		var n = d._inv._key;
		if( n > 9 ) n = 9;
		fieldKey.text = Std.string(n);
		
		
	}
	public function getIceCube(fr) {
		var sp = new pix.Element();
		bars[0].dm.add(sp, 0);
		sp.drawFrame( Gfx.inter.get(fr, "icecube") );
		sp.y = 7;
		statusIcons.push(sp);
		return sp;
	}
	
	public function majIslandName(?name) {
		if( name == null ) name = World.me.hero.island.getName();
		field.htmlText = name;
		field.width = field.textWidth + 3;
		field.x  = Std.int( (width - field.width) * 0.5 );
	}
	
	//
	public function update() {
		if( freeze ) return;
		switch(state) {
			case IS_PLAY :
			
				var fl =  bars[1].bg.mouseY > 0;
				if( !World.me.control ) fl = false;
				if( bagRollOver != fl ) {
					bagRollOver = fl;
					majIslandName(bagRollOver?Lang.CHECK_INVENTORY:null);
					bag.anim.play(bagRollOver?1: -1);
				}
				
			case IS_INVENTORY :

				updateInventory();
				
		}
		
		if( warningTimer != null ) {
			field.visible = warningTimer % 10 < 7;
			if(warningTimer-- == 0 ) {
				warningTimer = null;
				field.textColor = 0xFFFFFF;
				cleanName();
				field.visible = true;
			}
		}
		
	}
	//
	public function setFreeze(fl) {
		freeze = fl;
		hideHint();
	}
	
	// PLAY
	function initBarMode() {
		state = IS_PLAY;
		bagRollOver = true;
	}
	
	// INVENTORY
	function openInventory() {
		
		hideHint();
		//
		step = 0;
		coef = 0;
		state = IS_INVENTORY;
		World.me.setControl(false);
		cleanName();
		
		// INIT INVENTORY
		mcInv = new flash.display.Sprite();
		mcInv.y = 24;
		bars[1].dm.add(mcInv, 1);
		idm = new mt.DepthManager(mcInv);
		buts = [];
		
		var data = Loader.me.data;
		var inv = data._inv;
		

		// BONUS GAME
		var a = [inv._cheese, inv._leaf, inv._knife ];
		for( i in 0...3 ) {
			var but = getBut(a[i]);
			but.el.drawFrame(Gfx.inter.get(i,"bonus_game"));
			but.box.x = 12;
			but.box.y = i * 16;
			but.name = Lang.BONUS_GAME_NAMES[i];
			but.desc = Lang.BONUS_GAME_DESC[i];
			but.action = function(){ me.launchDevAction(i); };
		}
		
		// BONUS ISLAND
		var a = [inv._volt, inv._fireball, inv._tornado ];
		for( i in 0...3 ) {
			var but = getBut(a[i]);
			but.el.drawFrame(Gfx.inter.get(i,"bonus_island"));
			but.box.x = 36;
			but.box.y = i * 16;
			but.name = Lang.BONUS_ISLAND_NAMES[i];
			but.desc = Lang.BONUS_ISLAND_DESC[i];
			var me = this;
			but.action = function(){ me.launchIslandBonus(i); };
		}
		
		// BONUS DAILY
		for( i in 0...2 ) {
			var but = getBut(1);
			but.el.drawFrame(Gfx.inter.get(i,"bonus_daily"));
			but.box.x = 12+i*24;
			but.box.y = 48;
			but.name = Lang.BONUS_DAILY_NAMES[i];
			
			var ok = switch(i) {
				case 0 : inv._cheese > 0 && inv._leaf > 0 && inv._knife > 0;
				case 1 : inv._volt > 0 && inv._fireball > 0 && inv._tornado > 0;
			}
			if( ok ) {
				but.desc = Lang.BONUS_DAILY_DESC[i+2];
			}else {
				//Filt.grey(but.box,null,null,{r:-90,g:-60,b:-20});
				Filt.grey(but.box);
				but.desc = Lang.BONUS_DAILY_DESC[i];
			}
		}
		
		// ITEMS
		var a = [];
		var max = 28;
		for( i in 0...max ) a.push(false);
		for( item in data._items ) a[Type.enumIndex(item)] = true;
		var mod = 7;

		//var me = this;
		var cons = Type.getEnumConstructs(_Item);
		for( i in 0...max ) {
			var but = getBut(a[i]?1:0);
			but.el.drawFrame(Gfx.inter.get(i,"items"));
			but.box.x = 60 + (i % mod)*16;
			but.box.y = (Std.int(i / mod)) * 16;
			but.name = Lang.ITEM_NAMES[i];
			but.desc = Lang.ITEM_DESC[i];
			but.action = function() {  me.useItem( Type.createEnum(_Item, cons[i] )); };
			
			// CLOVER
			if( i == Type.enumIndex(Clover) && a[i] ) {
				var n = getCartProximity();
				if( n != null )	cloverRadiate = new mt.fx.Radiate(but.el,[0.25,0.1,0.02][n]);
			
			}
		}
		
		// HEARTS
		//var h = new pix.Element();
		//idm.add(h, 1);
		var h = getBut(1);
		var hn = data._hearts % 4;
		h.el.drawFrame( Gfx.inter.get(hn, "big_heart"));


		h.box.x = 183;
		h.box.y = 6;
		h.name = Lang.HEARTS_DESC[0];
		h.desc = Lang.HEARTS_DESC[1];
		if( hn > 0 ) {
			h.name = hn + Lang.HEARTS_DESC[2];
			h.desc = Lang.HEARTS_DESC[3];
			
		}

		var hmax = Loader.me.getLifeMax();
		for( id in 0...Data.START_HEARTS+Data.EXTRA_HEARTS) {
			var el = new pix.Element();
			idm.add(el, 1);
			el.x = h.box.x - 9 + (id % 3) * 9;
			el.y = h.box.y + 21 + Std.int(id / 3) * 8;
			el.drawFrame( Gfx.inter.get(id<hmax?0:2,"heart"));
		}
		
		
	}
	function closeInventory() {
		step = 2;
		coef = 0;
		buts =  [];
		unselect();
		mcInv.parent.removeChild(mcInv);
	}
	
	function updateInventory() {
		
		switch(step) {
			case 0:
				coef = Math.min(coef + 0.1, 1);
				var c = 0.5-Math.cos(coef*3.14)*0.5;
				var by = ((Cs.mcrh * 0.5) - BH);
				bars[1].bg.y = by - c * BGH;
				//
				Col.setColor(World.me.island, 0, -Std.int(FADE*coef));
				
				if( coef == 1 ) {
					step++;
				}
				
			case 1:
				var cur = getCurrentIcon();
				if( cur != currentIcon ) select(cur);
				if( currentIcon == null ) {
					if( bars[1].bg.mouseY < 0 ) 	setName(Lang.BACK_TO_GAME);
					else							cleanName();
				}
				
				
			case 2:
				coef = Math.min(coef + 0.1, 1);
				var c = 0.5+Math.cos(coef*3.14)*0.5;
				var by = ((Cs.mcrh * 0.5) - BH);
				bars[1].bg.y = by - c * BGH;
				Col.setColor(World.me.island, 0, -Std.int(FADE*(1-coef)));
				if( coef == 1 ) initBarMode();
		}
	}
	
	function getCurrentIcon() {
		for( b in buts ) {
			var dist = Math.max( Math.abs(b.el.mouseX), Math.abs(b.el.mouseY ));
			if( dist < b.el.width*0.5 ) return b;
		}
		return null;
	}
	function select(ico:InvIcon) {
		if( currentIcon != null ) unselect();
		if( ico == null || !ico.active ) return;
		
		setName(ico.name);
		//
		currentIcon = ico;
		idm.over(currentIcon.box);
		var pow = 16;
		var black = new flash.filters.GlowFilter(0, 1, 2, 2, pow);
		var white = new flash.filters.GlowFilter(0xFFFFFF, 1, 2, 2, pow);
		currentIcon.el.filters = [ black, white, black];
		
		//
		displayHint(ico.desc);
		
	}
	function unselect() {
		hideHint();
		cleanName();
		//
		if( currentIcon == null ) return;
		currentIcon.el.filters = [];
		currentIcon = null;
		
	}
	
	public function setName(str) {
		//if( warningTimer != null ) return;
		field.textColor = 0xFFFFFF;
		field.visible = true;
		warningTimer = null;
		majIslandName(str);
	}
	public function cleanName() {
		 majIslandName("");
	}
	
	public function setWarning(str, color = 0xFF0000) {
		field.textColor = color;
		setName(Lang.col(str,Col.getWeb(color)));
		
		warningTimer = 60;
	}
	
	function getBut(n:Int) {
		var box = new flash.display.Sprite();
		var el = new pix.Element();
		idm.add(box, 0);
		box.addChild(el);
		var o = { action:null, el:el, box:box,active:true,name:"nom",desc:"description"};
		
		if( n == 0 ) {
			Col.setPercentColor(el, 1, BLUE_DARK);
			#if dev
			#else
			o.active = false;
			#end
			
		}else if( n>1 ){
			var field = Cs.getField(0xFFFFFF, 8, -1, "nokia");
			box.addChild(field);
			field.x = 1;
			field.y = -1;
			field.text = Std.string(n);
			field.filters = [new flash.filters.GlowFilter(0,1,2,2,40)];
		}
		
		
		
		buts.push(o);
		return o;
	}
	
	// ACTIONS
	function launchIslandBonus(id:Int){
		
		var fx = new fx.Sorcery(id);
		if( fx.ok ) closeInventory();
	}
	function useItem(it:_Item) {
		
		var data = Loader.me.data;
		var havePlay = data._plays + data._dailyPlays > 0;
		var haveRainbow = data._rainbows > 0;
		switch(it) {
			
			case Prisme :
				if( data._rainbows > 3 ) 	setWarning(Lang.TOO_MUCH_RAINBOW);
				else if( !havePlay )		setWarning(Lang.NO_MORE_ICECUBE);
				else {
					World.me.send(_Prism);
					new fx.Prism();
				}
			
			case FeverX :
				/*
				var playLeft = false;
				playLeft = havePlay || (haveRainbow && Loader.me.have(ChromaX)) )
				if( data._carts.length == 0 ) 	setWarning(Lang.NO_CARTRIDGE);
				else if( !playLeft  )			setWarning(Lang.NO_MORE_ICECUBE);
				else							World.me.launchFeverX();
				
				*/
				
				///*
	
				if( data._carts.length == 0 ) 				setWarning(Lang.NO_CARTRIDGE);
				else if( !Loader.me.haveFeverXPlay()  ) 	setWarning(Lang.NO_MORE_ICECUBE);
				else										World.me.launchFeverX();
				//*/
				
			case Dice :
				if( data._rainbows <= 0 ) setWarning(Lang.NO_MORE_RAINBOW);
				else new world.mod.Dice();
				
			case RainbowString :
				var p = data._savePoint;
				if( p == null ) {
					setWarning(Lang.NO_STATUE);
				} else {
					closeInventory();
					World.me.send(_Teleport);
					new fx.Teleport();
					majStatus();
				}
			

			
			// TOOLS
			case Google :	new world.mod.Google();
			case Radar :	new world.mod.Radar();
			case Book :		new world.mod.Book();
			
			// PERMANENT
			case Shoes : 		setWarning(Lang.PERMANENT_OBJECT);	launchDevAction(3);
			case Umbrella :		setWarning(Lang.PERMANENT_OBJECT);	launchDevAction(4);
			case Voodoo_Doll :	setWarning(Lang.PERMANENT_OBJECT);	launchDevAction(5);
			case ChromaX :		setWarning(Lang.PERMANENT_OBJECT);
			
			// HACK
			//Loader.me.spendPlay();
			//Inter.me.majStatus();

			
			
			default :
			
		}
		
		
	}
	
	// CLICK
	public function click(e) {
		if( freeze ) return;
		switch(state) {
			case IS_PLAY :
				if( bagRollOver && World.me.control && World.me.hero.isWaiting() )
					openInventory();
				
			case IS_INVENTORY :
				if( step == 1 ){
					if( currentIcon != null && currentIcon.action != null  ) currentIcon.action();
					else if( bars[1].bg.mouseY < 0 ) {
						//World.me.island.mapDistanceFrom(World.me.hero.sq);
						World.me.setControl(true);
						closeInventory();
					}
				}
				
				
		}
	}
	
	// TOOLS
	public function getScreenHeight() {
		return bars[1].bg.y - BH;
	}
	
	// FX
	public function getLastIceCube() {
		var cube = lastIceCube;
		if( cube == null ){
			cube = getIceCube(1);
			cube.x = 7;
		}
		return cube;
	}
	public function getLastPinkIceCube() {
		return lastPinkIceCube;
	}
	
	// ICON WAIT
	var iconWait:McIconWait;
	public function showLoadingIcon() {
		if( iconWait != null ) return;
		iconWait = new McIconWait();
		iconWait.x = Cs.mcw - 12;
		iconWait.y = 36;
		flash.Lib.current.addChild(iconWait);
		iconWait.blendMode = flash.display.BlendMode.ADD;
	}
	public function hideLoadingIcon() {
		if( iconWait == null ) return;
		new mt.fx.Vanish(iconWait);
		iconWait = null;
	}
	
	// HINT
	var boxHint:flash.display.Sprite;
	var fieldHint:flash.text.TextField;
	public function displayHint(str:String) {
		var ma = 4;
		
		if( boxHint == null ) {
			boxHint = new flash.display.Sprite();
			bars[1].dm.add(boxHint,1);
			fieldHint = Cs.getField(0xFFFFFF, 8, -1, "nokia");
			fieldHint.multiline = true;
			fieldHint.wordWrap = true;
			fieldHint.x = ma+1;
			fieldHint.y = ma;
			boxHint.addChild(fieldHint);
		}
		
		boxHint.visible = true;
		fieldHint.width = 180;
		fieldHint.htmlText = Lang.col(str,"#CCCCCC");
		fieldHint.width = fieldHint.textWidth + 5;
		fieldHint.height = fieldHint.textHeight + 4;
		
		
		boxHint.graphics.clear();
		boxHint.graphics.beginFill(0);
		boxHint.graphics.drawRect( 0, 0, fieldHint.width + ma*2, fieldHint.height + ma*2);
		
		boxHint.x = Std.int((Cs.mcw * 0.5 - boxHint.width ) * 0.5);
		boxHint.y = -(boxHint.height+ma );
		
	}
	public function hideHint() {
		//trace("hide!");
		if( boxHint == null ) return;
		boxHint.visible = false;
	}
	
	// GET CART PROXIMITY
	function getCartProximity() {
		var ray = 2;
		var max = ray * 2 + 1;
		var min:Null<Int> = null;
		for( dx in 0...max ) {
			for( dy in 0...max ) {
				var ddx = dx - ray;
				var ddy = dy - ray;
				var dist = Std.int( Math.max( Math.abs(ddx),  Math.abs(ddy) ));
				if( min != null && min <= dist ) continue;
				var np = WorldData.getPos(World.me.island.px + ddx,World.me.island.py + ddy);
				var sta = world.Loader.me.getIslandStatus(np.x, np.y);
				var data = WorldData.me.getIslandData(np.x, np.y);
				if( data.rew == null ) continue;
				switch(data.rew) {
					case Cartridge(id) : if( !Loader.me.haveCart(id) )min = dist; //trace(np.x+";;"+np.y);
					default :
				}
			}
		}
		return min;
		
	}
	
	
	
	//
	function launchDevAction(id) {
		#if dev
		switch(id) {
			case 0 :
				Loader.me.saveLocalGame();
				setWarning("partie sauvegardée !");
				
			case 1 :
				Loader.me.destroyLocalGame();
				setWarning("partie réinitialisée!");
				
			case 2 :
				Loader.me.data._plays++;
				majStatus();
				
			case 3 :	// TRACE STATS
				World.me.traceStats();
				setWarning("stats copiées!");
				
			case 4 :	// FILL BONUSES
				setWarning("réapprovisionnement!");
				var o = Loader.me.data._inv;
				o._key = 10;
				o._cheese = 100;
				o._leaf = 100;
				o._knife = 100;
				o._volt = 100;
				o._fireball = 100;
				o._tornado = 100;
				
			case 5:		// CLIP LIMITS
				World.me.clipLimits();
				setWarning("limites copiées!");
		}
		majStatus();
		#end
		
	}
	

	
//{
}











