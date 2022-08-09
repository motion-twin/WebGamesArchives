import Protocole;


enum WorldStep {
	WS_LOADING;
	WS_PLAY;
}

class World {//}
		
	public static var DP_INTER = 	2;
	public static var DP_MAP = 		0;
	
	public var control:Bool;
	
	public var px:mt.flash.Volatile<Int>;
	public var py:mt.flash.Volatile<Int>;
	
	public var timer:Int;

	public var root:flash.display.Sprite;
	
	public var dm:mt.DepthManager;
	public static var me:World;
	public var fxm:mt.fx.Manager;
	
	public var island:world.Island;
	public var hero:world.Hero;
	
	var step:WorldStep;
	
	
	public var action:Void->Void;
	public var screen:pix.Screen;
	var inter:world.Inter;
	
	public var so:flash.net.SharedObject;
	public var params:FeverParams;
	
	var loader:world.Loader;
	
	
	public function new() {
		haxe.Log.setColor(0xFFFFFF);
		me = this;
		root = new flash.display.Sprite();
		dm = new mt.DepthManager(root);
		fxm = new mt.fx.Manager();
		
		//
		timer = 0;
		
		// ROOT
		Main.root.addChild(root);
		root.visible = false;
		root.scaleX = root.scaleY = 2;
		
		// UPDATE
		#if dev
		root.addEventListener(flash.events.Event.ENTER_FRAME, update );
		#else
		root.addEventListener(flash.events.Event.ENTER_FRAME, secureUpdate );
		#end
		
		// SO
		so = flash.net.SharedObject.getLocal("fever");
		if( so.data.params != null ) {
			params = so.data.params;
		} else {
			params = { noEntry:0 };
			so.data.params = params;
			so.flush();
		}
		
		//
		control = false;
		loader = new world.Loader(Main.wid);
		loader.requestData();
		step = WS_LOADING;
		
		
		
		#if dev
		Keyb.init();
		Keyb.pressAction = showSpriteList;
		#end
		
		
		
	}
	
	// UPDATE
	public function secureUpdate(e) {
	
		try {
			update();
		}catch(e:flash.errors.Error) {
			Main.traceError(Std.string(e));
		}catch(e:Dynamic) {
			Main.traceError(Std.string(e));
		}
	}
	public function update(?e) {
		timer++;
		
		switch(step) {
			
			case WS_LOADING :
				loader.update();
				if( loader.ready ){
					loader.hide();
					initPlay();
				}
				
			case WS_PLAY :
				
				if( action != null ) action();
				inter.update();
				
				updateSendListener();
				if( action != null ) screen.update();

		}
		fxm.update();
		
		
	}
	
	// DEBUG LAG
	var chr:Float;
	public function chronoStart() {
		chr = Date.now().getTime();
	}
	public function flag(str = "chrono step!") {
		var now = Date.now().getTime();
		trace(str + " : " + (now - chr));
		chr = now;
	}

	// PLAY
	public function initPlay() {
		step = WS_PLAY;
		
		// SCREEN
		screen = new pix.Screen( root, Cs.mcw, Cs.mcrh, 2 );
		Main.root.addChild(screen);
		
		var data = loader.data;
		var cur = data._road[0];
		px = cur._x;
		py = cur._y;
		
		//map = new world.Map( px, py );
		//dm.add(map, DP_MAP);
		
		island = new world.Island(px, py);
		island.attachOcean();
		dm.add( island, DP_MAP);
		
		
		var pos = {
			x : Std.int(world.Island.XMAX*0.5),
			y : Std.int(world.Island.YMAX*0.5),
		}
		var prec = world.Loader.me.data._road[1];
		if( prec != null ) {
			var di = Cs.getDir(island.px, island.py, prec._x, prec._y);
			var sq = island.seekJumpStone(di);
			if( sq != null ) pos = { x:sq.x, y:sq.y };
		}
		
		

		// INTER
		inter = new world.Inter();
		inter.majIslandName(island.getName());
		
		// HERO
		hero = new world.Hero(island, island.get( pos.x, pos.y ) );
		action = updatePlay;
		setControl(true);
				
		//
		
		
		
	}
	function updatePlay() {
		//haxe.Log.clear();
		//haxe.Log.setColor(0xfFFFFF);
		//trace(pix.Sprite.all.length);
		
		
		var a = pix.Sprite.all.copy();
		for( sp in a ) sp.update();
		
		updateMouse();
		island.update();
		hero.update();
		mouseScroll();
		
		island.ssortElements();
		
		
	}
	
	// MOUSE INTERACT
	function updateMouse() {
		if( !control ) return;
		if( island == null ) return ;
		
		var x = Std.int(island.mouseX / 16);
		var y = Std.int(island.mouseY / 16);
		island.rollOver(x, y);
	}
	public function click(e) {
		if( hero.arrowDir != null && sendReady()  ) {
			
			if( hero.getMouseDir() == hero.arrowDir && root.mouseY<Cs.mch*0.5 ) {
				var p = island.getNextIslandPos(hero.arrowDir);
				World.me.send( _MoveTo( p.x, p.y ) );
				world.Inter.me.majStatus();
				new fx.IslandJump(hero.arrowDir);
				hero.removeArrow();
				return;
			}
		}
		
		
		var sq = island.activeSquare;
		if( !island.selector.visible ) return;
		hero.goto(sq);
	
	}
		
	// SCROLL
	public function mouseScroll() {
		
	
		var p = hero.root.localToGlobal(new flash.geom.Point(0, 0) );
		p = island.globalToLocal( p);
		
		
		var scw = Cs.mcw*0.5;
		var sch = inter.getScreenHeight();
		
		
		island.x =  scw * 0.5 - p.x;
		island.y  = world.Inter.BH +  sch * 0.5 - p.y;
		island.x = Std.int(island.x);
		island.y = Std.int(island.y);
		
		/*
		var sc = map.scaleX;
			
		map.x  = scw * 0.5 - p.x*sc;
		map.y  = world.Inter.BH +  sch* 0.5 - p.y;
		
		map.x = Std.int(map.x);
		map.y = Std.int(map.y);
		*/
		
		
	}
	
	// LAUNCH LEVEL
	var player:player.Adventure;
	public var victory:Bool;
	public var mainSquare:world.Square;
	
	public function launchLevel(sq:world.Square) {
		mainSquare = sq;
		cacheSprites();
		
		player = new player.Adventure( sq.getMonsterData(), sq.ints[0] );
		//player.end = endPlayer;
		
		new fx.FadeStarIn(player);
		
		action = null;
		
		//
		setControl(false);
		send(_Play(mainSquare.id));
		inter.majStatus();
		screen.update();
		
	}

	public function backIn() {
		//mt.fx.Fx.DEFAULT_MANAGER = fxm;
		action = updatePlay;
		player.kill();
		uncacheSprites();
		//
		switch( player.endFxId ) {
			
			case 0 : // STANDARD
				if( victory ){
					setControl(true);
					mainSquare.ent.destroy();
					island.mapDistanceFrom(hero.sq);
					
					// TEST HERE
					
					
				}else {
					setControl(true);
					island.mapDistanceFrom(hero.sq);
				}
				
			case 1 :
				new fx.StoneHero();
			
			case 2 :
				World.me.setControl(true);
				mainSquare.ent.destroy("_stone");
				island.mapDistanceFrom(hero.sq);
			
		}
		player =  null;
		
	}
	
	// LAUNCH FEVER X
	public function launchFeverX() {

		cacheSprites();
		screen.visible = false;
		action = null;
		inter.setFreeze(true);
		
		var feverX = new player.FeverX(world.Loader.me.data._carts);
		feverX.drawWorldBg();
		
		flash.Lib.current.addChild(feverX);
		//dm.add(feverX, DP_INTER);

		
	}
	public function leaveFeverX() {
		
		//mt.fx.Fx.DEFAULT_MANAGER = fxm;
		uncacheSprites();
		screen.visible = true;
		action = updatePlay;
		inter.setFreeze(false);
		
	}
		
	// SPRITES CACHE
	var spriteCache:Array<pix.Sprite>;
	public function cacheSprites() {
		spriteCache = pix.Sprite.all.copy();
		pix.Sprite.all = [];
	}
	public function uncacheSprites() {
		//pix.Sprite.all = spriteCache;
		pix.Sprite.all = pix.Sprite.all.concat(spriteCache);
	}
	
	// CONTROL
	public function setControl(fl:Bool) {
		if( control == fl ) return;
		control = fl;
		if( control )	flash.Lib.current.stage.addEventListener(flash.events.MouseEvent.CLICK, click);
		else			flash.Lib.current.stage.removeEventListener(flash.events.MouseEvent.CLICK, click);
		
		if(control) {
			island.mapDistanceFrom(hero.sq);
			hero.sq.heroIn();
		}else {
			island.selector.visible = false;
			hero.removeArrow();
		}
		
	}
		
	// PROTOCOLE SERVER
	public var sendTimer:Null<Int>;
	public function send(ac:_PlayerAction) {
		sendTimer = 10000;
		inter.showLoadingIcon();
		var data:_DataAction  = {	_action:ac 	};
		
		#if dev
			var me = this;
			haxe.Timer.delay( function() { me.confirm({_done:"ok",_url:null}); }, Cs.TEST_LAG );
		#else
			Codec.load(Main.domain + "/game/action", data, confirm) ;
		#end
		
		// AUTO MAJ
		world.Loader.me.majAction(ac,island);

		
		
		
		
	}
	
	function updateSendListener() {
		if( sendTimer == null ) return;
		sendTimer--;
	}
	
	public function sendReady() {
		return sendTimer == null;
	}
	
	public function confirm( data:_DataConfirm ) {
		if( data._done != "ok" ) {
			Main.traceError(Lang.GENERIC_ERROR) ;
			return;
		}
		if( data._url != null ) {
			var url = new flash.net.URLRequest(data._url);
			flash.Lib.getURL(url,"_self");
			return;
		}
		
		sendTimer = null;
		inter.hideLoadingIcon();
	}
	
	
	// PARAMS
	public function saveParams() {
		so.data.params = params;
		so.flush();
	}
	
	
	// DBUG
	public function traceStats() {
		var ice = 0;
		var iceBig = 0;
		var chest = 0;
		var keys = 0;
		var rewardTotal = 0;
		var worldArea  = WorldData.me.size * WorldData.me.size;
		var monsters = [];
		for( id in Data.DATA._monsters ) monsters.push(0);
		var bonusGame = [0, 0, 0];
		var bonusIsland = [0, 0, 0];
		var portal = { x:0, y:0 };
		
		for(x in 0...WorldData.me.size ) {
			for(y in 0...WorldData.me.size ) {
				var data = WorldData.me.getIslandData(x, y);
				var rew = data.rew;
				if( rew == null ) continue;
				rewardTotal++;
				if( Common.isChest(rew) ) chest++;
				switch(rew) {
					case Ice :			ice++;
					case IceBig :		iceBig++;
					case Key:			keys++;
					case GBonus(b):		bonusGame[Type.enumIndex(b)]++;
					case IBonus(b):		bonusIsland[Type.enumIndex(b)]++;
					case Portal :		portal = { x:x, y:y };
					default:
				}
				for( mid in data.geo.monsters ) monsters[mid]++;
				
			}
		}
		
		var str = "rewardTotal : " + rewardTotal + "(" + Std.int( (rewardTotal / worldArea) * 100 ) + "%)\n";
		str += "chest : "+ chest + "(" + Std.int( (chest / worldArea) * 100 ) + "%) 	keyCheck :"+keys+"\n";
		str += "extra : " + (ice * Data.VALUE_ICECUBE + iceBig * Data.VALUE_ICECUBE_BIG) + " cubes - repartition : " + ((ice + iceBig) * 100 / worldArea) + "%\n";
		str += "\n";
		
		str += "bonus island :\n";
		for( i in 0...3 ) str += Lang.BONUS_ISLAND_NAMES[i] + " : " + bonusIsland[i]+"\n";
		str += "\n";
		
		str += "bonus game :\n";
		for( i in 0...3 ) str += Lang.BONUS_GAME_NAMES[i] + " : " + bonusGame[i]+"\n";
		str += "\n";
		
		var mid = 0;
		var mtot = 0;
		for( num in monsters ) mtot += num;
		str += "monsters : "+mtot+"\n";
		for( num in monsters ) {
			var name = Data.DATA._monsters[mid]._name;
			while(name.length < 18 ) name = name + " ";
			str +=  name+ " : " +num + " 	("+(Std.int(num*1000/mtot)/10)+"%)\n";
			mid++;
		}
		
		
		str += "portal is : " + portal.x + "," + portal.y + "\n";
		
		//trace("");
		//trace("");
		//trace("");
		//trace( str );
		
		flash.system.System.setClipboard(str);
		
		
	}
	public function showSpriteList() {
		var table = new flash.display.Sprite();
		dm.add(table, 20);
		table.graphics.beginFill(0, 0.8);
		table.graphics.drawRect(0, 0, Cs.mcw, Cs.mch);
		var x = 20;
		var y = 20;
		for( sp in pix.Sprite.all ) {
			table.addChild(sp);
			sp.x = x;
			sp.y = y;
			x += 10;
			if( x > 380 ) {
				x = 0;
				y += 10;
			}
		}
		
		
		action = null;
		screen.update();
		
		
	}
	
	public function clipLimits() {
		var str = "[";
		for( x in 0...WorldData.me.size ) {
			for( y in 0...WorldData.me.size ) {
				var data = WorldData.me.getIslandData(x, y);
				str +=  WorldData.me.getIslandLim(data) + ",";
			}
		}
		flash.system.System.setClipboard(str);
	}
	
	
	
	
	
	
	
//{
}






