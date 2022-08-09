package world;
import mt.bumdum9.Lib;
import Protocole;


typedef LoaderBar = {
	field:flash.text.TextField,
	bar:pix.Sprite,
}

class Loader extends flash.display.Sprite {//}
	
	var ww:Int;
	var hh:Int;
	
	public var ready:Bool;
	var step:Int;
	

	var elements : LoaderBar;
	var logField:flash.text.TextField;
	
	public var wdata:WorldData;
	
	// DATA
	public var data:_DataGame;
	public static var me:Loader;

	public function new(wid) {
		me = this;
		super();
		
		ww = Std.int(Cs.mcw * 0.5);
		hh = Std.int(Cs.mcrh * 0.5);
		
		flash.Lib.current.addChild(this);

		//
		ready  = false;
		
		// BG
		//graphics.beginFill(0xe39a2b);
		graphics.beginFill(0xc07716);
		graphics.drawRect(0, 0, ww, hh);
		scaleX = 2;
		scaleY = 2;
		
		//
		elements = getLoaderBar();
		elements.bar.y = hh * 0.5;

		//
		wdata = new WorldData(wid);
		wdata.init();
		step = 0;
		setText(Lang.CREATE_WORLD);
		
	}
	
	var bar :pix.Sprite;
	function getLoaderBar() {
		bar = new pix.Sprite();
		bar.setAnim(Gfx.inter.getAnim("loading_bar"));
		bar.x = ww * 0.5;
		addChild(bar);
		
		var w = 80;
		var field = Cs.getField(0xFFEEAA, 8, -1, "nokia");
		field.y = -16;
		field.width = w * 2;
		bar.addChild(field);
		return { bar:bar, field:field };

	}
	function setText(text:String ) {
		var bar = elements;
		bar.field.text = text;
		bar.field.width = bar.field.textWidth + 3;
		bar.field.x = -Std.int(bar.field.width * 0.5);
	}
	
	// update
	public function update() {
		switch(step) {
			
			case 0 :
				wdata.update();
				if( wdata.ready ) {
					step++;
					setText(Lang.SERVER_CNX);
				}
						
			case 1 : // WAIT DATA
				if( data != null ) {
					ready = true;
					step = 2;
				}
			
		}
		
		elements.bar.update();
		
	}

	// DATAS
	public function requestData() {
	
		#if dev
			var me = this;
			haxe.Timer.delay( function() { me.receiveData(me.getBlankData()); }, Std.random(Cs.TEST_LAG) );
		#else
			Codec.load(Main.domain + "/game/start", data, receiveData ) ;
		#end

	}
	#if dev
	function getBlankData() {
	
		var so = flash.net.SharedObject.getLocal("dev");
		
		if( so.data.dataGame != null  ) {
			var data:_DataGame = haxe.Unserializer.run(so.data.dataGame);
			forceData(data);
			return data;
		}
		
		
		var inv:_Inventory = {
			_key:0,
			
			_volt:0,
			_fireball:0,
			_tornado:0,
			
			_leaf:0,
			_cheese:0,
			_knife:0,
		}
			
		
		var pos = {
			_x:Std.int(WorldData.me.size * 0.5),
			_y:Std.int(WorldData.me.size * 0.5),
		}
		
		var data:_DataGame = {
			_wid:0,
			_god:-1,
			_road:[pos],
			_savePoint:null,
			_islands:[],
			
			_hearts:0,
			_items:[],
			_inv:inv,
			_carts:[],

			_plays:3,
			_dailyPlays:2,
			_rainbows:3,
			
		}
		
		// EXPLORE
		var max = WorldData.me.size * WorldData.me.size;
		for( i in 0...max ) {
			var di = ISL_UNKNOWN;
			data._islands.push(di);
		}
		
		/*
		var cur = data._road[0];
		var bx = cur._x;
		var by = cur._y;
		for( i in 0...24 ) {
			var id = bx * WorldData.me.size	+ by;
			var di = ISL_EXPLORE([]);
			if( Std.random(31) == 0 ) di = ISL_DONE;
			var d = Cs.DIR[Std.random(4)];
			bx += d[0];
			by += d[1];
			data._islands[id] = di;
		}
		
		*/
		
		
		forceData(data);

		return data;
	}
	function forceData(data:_DataGame) {
		if( Cs.CARTRIDGES != null ) 	for( id in Cs.CARTRIDGES )	data._carts.push( { _id:id, _lvl:Std.random(80) } );
		else							for( k in 0...8 ) 			data._carts.push( { _id:Std.random(90), _lvl:Std.random(10) } );
		if( Cs.TELEPORT != null ) 	data._road.unshift( Cs.TELEPORT );
		for( it in Cs.START_ITEMS ) if( !Lambda.has( data._items, it ) ) data._items.push(it);
		if( Cs.FORCE_HEARTS != null ) data._hearts = Cs.FORCE_HEARTS;
	}
	
	#end
	
	function receiveData(data:_DataGame) {
		this.data = data;
	}

	// TOOLS DATAS
	public function have(item:_Item) {
		for( it in data._items ) if( it == item ) return true;
		return false;
	}
	public function haveCart(id:Int) {
		for( cart in data._carts ) if( cart._id == id ) return true;
		return false;
	}
	public function getIslandStatus(x,y) {
		return data._islands[x * WorldData.me.size + y];
	}
	public function setIslandStatus(x, y, sta) {
		data._islands[x * WorldData.me.size + y] = sta;
	}
	
	public function havePlay() {
		return data._plays + data._dailyPlays > 0;
	}
	public function haveFeverXPlay() {

		return havePlay() || (data._rainbows > 0 && have(ChromaX));
	}
	
	public function getRunes() {
		var a = [];
		for( it in data._items ) {
			switch(it) {
				case Rune_0 : a.push(0);
				case Rune_1 : a.push(1);
				case Rune_2 : a.push(2);
				case Rune_3 : a.push(3);
				case Rune_4 : a.push(4);
				case Rune_5 : a.push(5);
				case Rune_6 : a.push(6);
				default :
			}
		}
		return a;
	}
	public function getLifeMax() {
		return Data.START_HEARTS + Std.int(data._hearts / 4);
	}
	public function isGod(gid:Int) {
		return data._god == gid;
	}

	// MAJ
	public function spendPlay() {
		if( data._dailyPlays > 0 )  data._dailyPlays--;
		else						data._plays--;
	}
	public function explore(id, px, py ) {
		var k = px * WorldData.me.size + py;
		var status = data._islands[k];
		switch(status) {
			case ISL_DONE :
				//if( id >= 0 ) trace("explore error");
				
			case ISL_EXPLORE(a,rew) :
				a.push(id);
				status = ISL_EXPLORE(a, rew);
				
			case ISL_UNKNOWN :
				var a = [];
				if( id >= 0 ) a = [id];
				status = ISL_EXPLORE(a,wdata.getIslandData(px,py).rew);
		}
		data._islands[k] = status;
	
	}
	
	/*
	public function majExplore(px,py) {
		var k = px * WorldData.me.size + py;
		var status = data._islands[k];
		switch(status) {
			case ISL_DONE :
			case ISL_UNKNOWN :
			case ISL_EXPLORE(a,rew) :
				var max = wdata.getIslandLim(wdata.getIslandData(px, py)).lim;
				if(a.length == max && rew == null ) {
					data._islands[k] = ISL_DONE;
					World.me.island.onComplete();
					
				}

		}
	}
	*/
	
	
	public function grabReward(rew) {
		if( Common.isChest(rew) ) data._inv._key--;
		switch(rew) {
			case Item(item):		data._items.push(item);
			case IBonus(b):			incIslandBonus(b, 1);
			case IceBig:			data._plays += Data.VALUE_ICECUBE_BIG;
			case Heart:				data._hearts++;
			case Cartridge(id):		data._carts.push({_id:id,_lvl:0});
			case Ice:				data._plays += Data.VALUE_ICECUBE;
			case Key:				data._inv._key++;
			case GBonus(b):			incGameBonus(b, 1);
			case Portal:			// END GAME
		}

	}
	public function incIslandBonus(b:_IslandBonus,inc) {
		switch(b) {
			case Volt :		data._inv._volt += inc;
			case Fireball :	data._inv._fireball += inc;
			case Tornado :	data._inv._tornado += inc;
		}
	
	}
	public function incGameBonus(b:_GameBonus,inc) {
		switch(b) {
			case Cheese :	data._inv._cheese+= inc;
			case Leaf :		data._inv._leaf += inc;
			case Knife :	data._inv._knife+= inc;
		}

	}
	public function majAction(ac:_PlayerAction,island) {
		//trace("majAction : "+ac);
		var isl = World.me.island;
		switch(ac) {
			
			case _Play(squareId):				spendPlay();
			case _GameResult(win, a):
				if( win ) explore(World.me.mainSquare.id, World.me.island.px, World.me.island.py );
				// Bonus dépensés dans Adventure
			case _Dice(success):		data._rainbows--;			// Partie ajouté dans world.mod.Dice
			
			case _MajCartridge(c) :		//spendPlay();
			
			case _FeverXPlay:
				if( have(ChromaX) && data._rainbows > 0 ) 	data._rainbows--;
				else										spendPlay();
				
			case _Grab( squareId, rew ):
				var status = isl.getStatus();
				switch(status) {
					case ISL_EXPLORE(a, reward) : setIslandStatus(isl.px, isl.py, ISL_EXPLORE(a, null));
					default:
				}
				grabReward(rew);
			
			case _MoveTo(x, y):
				if(!isIslandComplete(isl.px, isl.py, true) ) data._rainbows--;
				data._road.unshift({_x:x,_y:y});
				if( getIslandStatus(x, y) == ISL_UNKNOWN )
					explore( -1, x, y);	// ==> INITIALISE a ISL_EXPLORE([]);
				
			case _Teleport :
				var p = data._savePoint;
				data._road.unshift(p);
				
			case _Burn(squares, bonus):
				for( id in squares ) explore( id, World.me.island.px, World.me.island.py);
				incIslandBonus(bonus, -1);
				
			case _Prism :
				spendPlay();
				data._rainbows += 3;
			
			case _SavePos(id) :
				data._god = id;
				data._savePoint = data._road[0];
				
			case _EndGame(id) :
				if( id == 1 ){
					data._wid++;
				}
		}
	
		// MAJ EXPLORE
		if( isIslandComplete(isl.px, isl.py) ) setIslandStatus(isl.px, isl.py,ISL_DONE);

		/*
		var k = isl.px * WorldData.me.size + isl.py;
		var status = data._islands[k];
		switch(status) {
			case ISL_DONE :
			case ISL_UNKNOWN :
			case ISL_EXPLORE(a, rew) :
				
				var max = wdata.getIslandLim(wdata.getIslandData(isl.px, isl.py)).lim;
				if(a.length == max && rew == null ) {
					status = ISL_DONE;
					//World.me.island.onComplete();
				}
		}
		data._islands[k] = status;
		*/
		
	
	
	}
	
	#if dev
	public function saveLocalGame() {
		var so = flash.net.SharedObject.getLocal("dev");
		var str = haxe.Serializer.run(data);
		so.data.dataGame = 	str;
		so.flush();
	}
	public function destroyLocalGame() {
		var so = flash.net.SharedObject.getLocal("dev");
		so.data.dataGame = 	null;
		so.flush();
	
	}
	#end
		
	public function isIslandComplete(px,py,monsterOnly=false) {
		var sta = getIslandStatus(px,py);
		var o = wdata.getIslandLim( wdata.getIslandData(px, py));
		switch(sta) {
			case ISL_DONE : 				return true;
			case ISL_EXPLORE(a, rew) : 		return (rew == null || monsterOnly) && a.length == o.lim;
			case ISL_UNKNOWN : 				return false;
		}
	}
	
	// KILL
	public function hide() {
		bar.kill();
		parent.removeChild(this);
	}
	


//{
}