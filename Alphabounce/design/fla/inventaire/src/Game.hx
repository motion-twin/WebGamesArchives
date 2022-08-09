import mt.bumdum.Lib;
import Text;

typedef Field = {>flash.MovieClip,field:flash.TextField};



class Game {//}za

	static var InventoryText = TextFr;
	static var mcw = 460;
	static var mch = 320;

	var self:Bool;
	var pi:PlayerInfo;
	var swfUrl:String;

	public static var me:Game;
	var dm:mt.DepthManager;
	var root:flash.MovieClip;
	var base:flash.MovieClip;

	var bmp:flash.display.BitmapData;

	var hint:{ >flash.MovieClip, field:flash.TextField, bg:flash.MovieClip, flActive:Bool  };

	public function new( mc : flash.MovieClip ){
		var lang = Reflect.field(flash.Lib._root, "lang");
		InventoryText = switch (lang){
			case "fr": cast TextFr;
			case "en": cast TextEn;
			case "es": cast TextEs;
			case "de": cast TextDe;
			default:   cast TextFr;
		}
		root = mc;
		me = this;
		dm = new mt.DepthManager(root);

		pi = new PlayerInfo();
		var str = Reflect.field(flash.Lib._root,"pi");
		if( str == null )initTestMode(); else pi.parseInfo(str);

		swfUrl = Reflect.field(flash.Lib._root,"swfUrl");
		if(swfUrl == null )swfUrl =  "../../../../web/www/swf/";

		self = (Reflect.field(flash.Lib._root,"self") == "true");

		initPage();

		hint = cast dm.attach("mcHint",10);
		hint._alpha = 0;
		hint.cacheAsBitmap = true;
	}

	//
	function initPage(){
		var mc = dm.empty(0);
		bmp = new flash.display.BitmapData(mcw,mch,true,0);
		mc.attachBitmap(bmp,0);

		// BG
		var bg = dm.attach("mcBg",0);
		bmp.draw(bg);
		bg.removeMovieClip();

		// CADRES
		var cadres  = dm.attach("cadres",0);
		bmp.draw(cadres);
		cadres.removeMovieClip();

		// SHADE
		var shade = dm.attach("mcShade",0);
		bmp.draw(shade);
		shade.removeMovieClip();

		// ELEMENTS
		initPad();
		initDrones();
		initMissiles();
		initStars();
		initCenter();
		initPlanets();
		initGadgets();
		initEarthMap();
		initPassengers();

		// BALLS
		var max = 0;
		if( pi.gotItem( MissionInfo.BALL_DRILL ) )	max = 1;
		if( pi.gotItem( MissionInfo.BALL_SOLDAT ) )	max = 2;
		if( pi.gotItem( MissionInfo.BALL_POWER ) )	max = 3;
		if( pi.gotItem( MissionInfo.BALL_BLACK ) )	max = 4;

		var line = 2;
		var ec = 15;
		for( i in 0...4 ){
			var mc = dm.attach("mcBall",1);
			mc._x = 13 + ec*(i%line);
			mc._y = 53 + ec*Std.int(i/line);
			mc._xscale = mc._yscale = 80;
			if(i<max){
				mc.gotoAndStop(i+1);
				setHint(mc, createTip(InventoryText.getText(i)));
			}else{
				mc.gotoAndStop(10);
			}
		}

		// MAPS
		var a = [ pi.gotItem(MissionInfo.MAP_SHOP), pi.shopItems[ShopInfo.MISSILE_MAP], false  ];
		for( i in 0...3 ){

			var mc = dm.attach("mcMap",1);
			mc._x = 17 + 43*i;
			mc._y = 90;
			var fr = 1;
			if( a[i] ){
				fr = 2+i;
				setHint(mc, createTip(InventoryText.getText(12+i)));
			}
			mc.gotoAndStop(fr);

		}

		// GENERATOR
		var mc:Field = cast dm.attach("mcGenerator",1);
		mc._x = 130;
		mc._y = 20;
		mc.smc.stop();
		if( pi.engine > 1 ){
			mc.field.text = Std.string(pi.engine-1);
			setHint( mc, createTip(InventoryText.getTip(TGenerator), [pi.engine]) );
		}else{
			Col.setPercentColor(mc,100,0x384561);
		}

		// RADAR
		var mc:Field = cast dm.attach("mcGenerator",1);
		mc._x = 60;
		mc._y = 59;
		mc.smc.gotoAndStop(3);
		if( pi.radar > 1 ){
			mc.field.text = Std.string(pi.radar-1);
			setHint( mc, createTip(InventoryText.getTip(TRadar), [pi.radar]) );
		}else{
			Col.setPercentColor(mc,100,0x384561);
		}

		// REACTEUR DE SURFACE
		var mc:Field = cast dm.attach("mcGenerator",1);
		mc._x = 130;
		mc._y = 59;
		mc.smc.gotoAndStop(2);
		var reactor = 0;
		if( pi.gotItem(MissionInfo.LANDER_REACTOR) ){
			reactor = 1;
			for(i in 0...3) if( pi.shopItems[ShopInfo.LANDER_REACTOR_0+i]==1 ) reactor++;
			mc.field.text = Std.string(reactor);
			setHint( mc, createTip(InventoryText.getTip(TReactor), [reactor]) );
		}else{
			Col.setPercentColor(mc,100,0x384561);
		}

		// POD
		var mc = dm.attach("mcPod",1);
		mc._x = 99;
		mc._y = 60;
		var n = 0;
		if(pi.shopItems[ShopInfo.PODS]==1){
			n = 1;
			for(i in 0...3) if( pi.shopItems[ShopInfo.PODS_EXTEND_0+i]==1 ) n++;
			setHint( mc, createTip(InventoryText.getTip(TPods), [n*2]) );
			mc.gotoAndStop(n);
		}else{
			Col.setPercentColor(mc,100,0x384561);
			mc.stop();
		}





	}
	function initPad(){
		var sr = 32;
		if( pi.gotItem(MissionInfo.EXTENSION) ) sr += 10;

		var pad = dm.attach("mcPad",1);
		var skin:{>flash.MovieClip,side0:flash.MovieClip,side1:flash.MovieClip,mid:{>flash.MovieClip,bar:flash.MovieClip}} = cast pad;
		var w = sr-12;
		skin.mid._xscale = w*2;
		skin.mid._x = -w;
		skin.side0._x = -sr;
		skin.side1._x = sr;

		skin.mid.stop();
		skin.side0.stop();
		skin.side1.stop();

		var fr = 1;
		if( pi.gotItem(MissionInfo.MEDAL) ) fr=2;
		skin.mid.smc.gotoAndStop(fr);
		skin.side0.smc.gotoAndStop(fr);
		skin.side1.smc.gotoAndStop(fr);

		pad._x = 55;
		pad._y = 5;


		// MINIPAD
		for( i in 0...4 ){
			var mc = dm.attach("mcMiniPad",1);
			mc._x = 18 + i*25;
			mc._y = 30;
			var life = pi.getLife();
			if( i < life ){
				var str = life+InventoryText.EXTRA_LIFES;
				if( life==1 )
					str = life+InventoryText.EXTRA_LIFE;
				setHint(mc,str);
			}else{
				Col.setPercentColor(mc,100,0x384561);
			}
		}
	}

	function initDrones(){
		var mc = dm.attach("mcDrone",1);
		mc._x = 47;
		mc._y = 163;
		mc._xscale = mc._yscale = 77;
		if( pi.drone == 0 ){
			mc.stop();
		}else{
			mc.gotoAndStop(2);
			setHint(mc, createTip(InventoryText.getTip(TDrone)));
		}

		for( i in 0...10 ){
			var mc = dm.attach("mcDrone",1);
			mc._x = 15 + 16 * (i%5);
			mc._y = 197 + 15 * Std.int(i/5);
			mc._xscale = mc._yscale = 21;
			var fr = 1;
			if( i < pi.drone )fr++;
			mc.gotoAndStop(fr);
		}


		// DRONES OPTIONS
		var a = [ ShopInfo.DRONE_PERFO, ShopInfo.DRONE_SPEED, ShopInfo.DRONE_CONVERTER, ShopInfo.DRONE_COLLECTOR ];
		for( i in 0...4 ){

			var mc = dm.attach("mcDroneCapsule",1);
			mc._x = 108;
			mc._y = 140 + 20*i;
			var fr = i*2 + 1;
			if( pi.shopItems[a[i]] == 1 ){
				fr++;
				setHint(mc, createTip(InventoryText.getText(8+i)));
			}

			mc.gotoAndStop(fr);

		}
	}
	function initMissiles(){

		// TYPE
		var type = 0;
		if( pi.missileMax>0 )				type = 1;
		if( pi.gotItem( MissionInfo.MISSILE_BLUE ) )	type = 2;
		if( pi.gotItem( MissionInfo.MISSILE_BLACK ) )	type = 3;
		if( pi.gotItem( MissionInfo.MISSILE_RED ) )	type = 4;


		// HEAD
		for( i in 0...4 ){
			var mc = dm.attach("mcMisHead",1);
			mc._x = 326 + (i%2)*15;
			mc._y = 18 + Std.int(i/2)*16;
			mc._xscale = mc._yscale = 50;
			var fr = 1;
			if( i<type ){
				setHint(mc, createTip(InventoryText.getText(4+i)));
				fr+=i+1;
			}else{

			}
			mc.gotoAndStop(fr);

		}

		// MISSILE OPTION
		var list = [ ShopInfo.LATERAL, ShopInfo.COOLER, ShopInfo.MISSILE_GENERATOR ];

		for( i in 0...list.length ){
			var id = list[i];
			var mc = dm.attach("mcMissileOpt",1);
			mc._x = 348+i*35;
			mc._y = 6;
			mc.gotoAndStop(i+1);
			mc._xscale = mc._yscale = 85;
			if( pi.shopItems[id]!=1 ){
				Col.setPercentColor(mc,100,0x384561);
			}else{
				setHint(mc, createTip(InventoryText.getText(18+i)));
			}
		}



		// MASSE
		var line = 7;
		for( i in 0...49 ){

			var mc = dm.attach("mcMissile",1);
			mc._x = 323 + (i%line)*8;
			mc._y = 61 + Std.int(i/line)*11;
			mc._xscale = mc._yscale = 60;
			var fr = 1;
			if( i < pi.missileMax ){
				Filt.glow(mc,2,2,0x000044);
				fr+=type;
				if( i >= pi.missile )mc._alpha = 20;
			}
			mc.gotoAndStop(fr);



		}
	}
	function initStars(){

		for( i in 0...7 ){
			var mc = dm.attach("mcStar",1);
			//mc._x = 172 + i*19;
			//mc._y = 180 + (i%2)*24;

			mc._xscale = mc._yscale = 100;
			mc._x = 270;
			mc._y = 192;

			var dx = 24;
			var dy = 17;

			if( i<2 ){
				mc._x += (i*2-1)*dx*0.5;
				mc._y -= dy;
			}else if(i<5){
				mc._x += (i-3)*dx;
			}else{
				mc._x += ((i-5)*2-1)*dx*0.5;
				mc._y += dy;
			}


			var fr = 1;
			if( pi.gotItem(MissionInfo.STAR_RED+i) ){
				fr+=i+1;
				setHint(mc,InventoryText.getStar(i));
			}
			mc.gotoAndStop(fr);
		}
	}
	function initCenter(){

		var cx = 230;
		var cy = 81;

		//
		var ray = 50.6 *0.6;
		var max = 3;
		for( i in 0...max ){
			var a = i/max * 6.28 - 1.57 + 0.04;
			var mc = dm.attach("mcCirclePass",1);
			mc._x = cx+Math.cos(a)*ray;
			mc._y = cy+Math.sin(a)*ray;
			mc._xscale = mc._yscale = 60;
			var fr = 1;
			if( pi.gotItem(MissionInfo.CARD_RED+i) ){
				fr+=1+i;
				setHint(mc, createTip(InventoryText.getText(15+i)));
			}
			mc.gotoAndStop(fr);
		}

		//
		var ray = 55;
		var ray = 60;
		max = 12;
		for( i in 0...max ){
			var a = (i-0.5)/max * 6.28;
			var mc = dm.attach("mcTablet",1);
			mc._x = cx+Math.cos(a)*ray;
			mc._y = cy+Math.sin(a)*ray;

			var fr = 1;
			if( pi.gotItem(MissionInfo.TBL_0+i) ){
				fr+=1;
				setHint(mc,createTip(InventoryText.getTip(TKarbonite)));
			}
			mc.gotoAndStop(fr);
			mc.smc.gotoAndStop(i+1);

		}

	}
	function initPlanets(){

		var xi = 0;
		var y = 244.0;
		var sens = -1;
		for( i in 0...24 ){
			if( i!= ZoneInfo.ASTEROBELT ){
				var mc:{>flash.MovieClip, field:flash.TextField} = cast dm.attach("mcPlanet",1);
				mc._x = 36 + sens*14.5 + xi*59.5;
				mc._y = y;
				xi++;
				if( i==7 || i==15 ){
					y += 27.5;
					sens *= -1;
					xi = 0;
				}
				mc._xscale = mc._yscale = 35;
				var comp = if (pi.comp[i] != null) pi.comp[i] else 0;
				var fr = Std.int( (1-comp/100) * 160) +1;

				mc.gotoAndStop(fr);
				mc.field.text = comp+"%";

				// LOAD
				var url = swfUrl+"planet.swf";
				var mcl = new flash.MovieClipLoader();
				mcl.onLoadComplete = function(mc){  mc.smc.gotoAndStop(i+1); mc.smc.smc._visible = false; };
				mcl.onLoadInit = function(mc){  mc.smc.gotoAndStop(i+1); mc.smc.smc._visible = false; };
				mcl.loadClip(url,mc.smc);

				if( comp > 0 ){
					//var prc = Std.int( comp *10 )/10;
					var desc = InventoryText.EXPLORING;
					if(comp == 100 )desc = InventoryText.getPlanet(i);
					setHint( mc, getTitleDesc(ZoneInfo.list[i].name, desc ));
				}

			}
		}
	}
	function initGadgets(){

		var list = [
			ShopInfo.SUNGLASSES,	// 0
			0,			// 1
			ShopInfo.ANTENNA,	// 2
			0,			// 3
			-79,			// 4
			-110,			// 5
			-113,			// 6
			-92,			// 7
			-127,			// 8
			0,			// 9 AR57
			-MissionInfo.GENERATOR, // 10
			0,			// 11
			-112,			// 12
		];

		var line = 5;
		for( i in 0...15 ){
			var mc = dm.attach("mcGadgetSlot",1);
			mc._x = 316 + (i%line)*28;
			mc._y = 148 + Std.int(i/line)*25;


			var sid = list[i];

			if( pi.shopItems[sid] == 1 || sid == 0 || (sid<0 && pi.gotItem(-sid)) ){
				var mmc =dm.attach("mcGadget",1);
				mmc._x = mc._x;
				mmc._y = mc._y;
				mmc.gotoAndStop(i+1);
				Filt.glow(mmc,2,2,0xFFFFFF);
				var th = createTip(InventoryText.getText(21+i));
				switch( i ){
					case 1:
						var fr = 1;
						if( pi.gotItem(MissionInfo.MEDAL) ){
							mmc.smc.gotoAndStop(2);
							setHint(mc,th);
						}else{
							mmc.smc.gotoAndStop(1);
							var flHint = false;
							for( i in 0...3 ){
								var mc = Reflect.field(mmc.smc,"_p"+i);
								mc._visible = pi.gotItem(MissionInfo.MEDAL_0+i);
								if(mc._visible)flHint = true;
							}
							if(flHint)setHint(mc,createTip(InventoryText.getText(41)));
						}

					case 3:
						var fr = 0;
						for( i in 0...4 )if(pi.gotItem(MissionInfo.ANTIMAT_0+i))fr++;
						if(fr==0){
							mmc.smc.stop();
							mmc._visible = false;
						}else{
							mmc.smc.gotoAndStop(fr);
							setHint(mc, createTip(InventoryText.getTip(TAntimater), [fr]));
						}
					case 8:
						var fr = 1;
						if(pi.shopItems[ShopInfo.MINE_0]==1)fr++;
						if(pi.shopItems[ShopInfo.MINE_1]==1)fr++;
						if(pi.shopItems[ShopInfo.MINE_2]==1)fr++;
						setHint(mc, createTip(InventoryText.getTip(TMine), [fr]));
						mmc.smc.gotoAndStop(fr);
					case 9:
						var fr = 0;
						if(pi.gotItem(MissionInfo.STONE_LYCANS))	fr+=1;
						if(pi.gotItem(MissionInfo.STONE_SPIGNYSOS))	fr+=2;


						if(fr==0){
							mmc.smc.stop();
							mmc._visible = false;
						}else{
							mmc.smc.gotoAndStop(fr);
							var txt =	createTip(InventoryText.getTip(TLycans));
							if(fr==2) txt = createTip(InventoryText.getTip(TSpignysos));
							if(fr==3) txt = createTip(InventoryText.getTip(TAR57));
							setHint(mc,txt);
						}

					case 11:
						var fr = 0;
						for( i in 0...5 )if(pi.gotItem(MissionInfo.CRYSTAL_0+i))fr++;
						if(fr==0){
							mmc.smc.stop();
							mmc._visible = false;
						}else{
							mmc.smc.gotoAndStop(fr);
							setHint(mc, createTip(InventoryText.getTip(TCrystal), [fr]));
						}
					default :
						setHint(mc,th);
				}
			}
		}
	}

	function initEarthMap(){
		var bg = dm.attach("mcEarthMap",1);
		bg._x = 162;
		bg._y = 169;
		bg.gotoAndStop(1);

		//var flDisplay = false;
		//var flCoord = true;

		var xmax = 7;
		var ymax = 6;
		var cs = 8;
		var grid = [];
		var n = 0;
		for( x in 0...xmax ) grid[x] = [];
		for( i in 0...xmax*ymax){
			var flag = pi.gotItem(MissionInfo.EMAP_0+i);
			grid[i%xmax][Std.int(i/xmax)] = flag;
			if(flag)n++;

		}
		if(n==0)return;
		var max = xmax*ymax;
		var flCoord = n == max;

		// SEED SHUFFLE
		var seed = new mt.Rand(456);

		var flFirst = true;
		var val = false;
		for( i in 0...100 ){
			var ax = seed.random(xmax);
			var ay = seed.random(ymax);
			var bx = seed.random(xmax);
			var by = seed.random(ymax);
			var aval = grid[ax][ay];
			var bval = grid[bx][by];
			grid[ax][ay] = bval;
			grid[bx][by] = aval;
		}

		bg.gotoAndStop(2);

		var seed = new mt.Rand(pi.pid);
		var ray = 1500+seed.random(500);
		var ex = seed.random(ray)*(seed.random(2)*2-1);
		var ey = (ray-Math.abs(ex))*(seed.random(2)*2-1);

		var field:flash.TextField = cast(bg).field;
		var field2:flash.TextField = cast(bg).field2;
		field._visible = flCoord && self;
		field2._visible = flCoord && self;
		field.text = "["+ex+"]";
		field2.text = "["+ey+"]";



		var base = new flash.display.BitmapData(xmax*cs,ymax*cs,true,0);
		var bmp = new flash.display.BitmapData(xmax*cs,ymax*cs,true,0);
		base.draw( bg, new flash.geom.Matrix() );


		for( x in 0...xmax ){
			for( y in 0...ymax ){
				if( grid[x][y] ){
					bmp.copyPixels(base,new flash.geom.Rectangle(x*cs,y*cs,cs,cs),new flash.geom.Point(x*cs,y*cs));
				}
			}
		}

		var mc = dm.empty(1);
		mc.attachBitmap(base,0);
		mc._x = bg._x;
		mc._y = bg._y;
		mc._alpha = 20;

		var mc = dm.empty(1);
		mc.attachBitmap(bmp,0);
		mc._x = bg._x;
		mc._y = bg._y;
		Filt.glow(mc,2,4,0x00FF00);


		if(n<max) setHint(mc, createTip(InventoryText.getTip(TEarthMap), [max-n]));
		else setHint(mc, createTip(InventoryText.getTip(TEarthMapComplete)));

		//
		bg.gotoAndStop(1);



	}
	function initPassengers(){
		var list = [];
		if( pi.gotItem(MissionInfo.DOUGLAS) )list.push("Douglas");
		if( pi.gotItem(MissionInfo.SALMEEN) )list.push("Salmeen");
		for( tr in pi.travel ){
			list.push(tr._name);
		};

		var y = 0;
		for( str in list ){
			var mc = dm.attach("mcPassenger",1);
			var field:flash.TextField = (cast mc).field;
			field.text = str;
			mc._x = 394;
			mc._y = 55+y*13;
			y++;
			if(y==6)return;

			Filt.glow(mc,2,4,0x283541);
		}

	}

	//
	function createTip( tip, ?vars:Array<Dynamic> ){
		if (vars != null)
			for (i in 0...vars.length)
				tip.desc = StringTools.replace(tip.desc, "$"+i, vars[i]);
		return getTitleDesc(tip.title, tip.desc);
	}

	function getTitleDesc(title,str){
		return "<b>"+title+"</b>\n<font size='9'>"+str+"</font>";
	}

	// HINT
	function setHint(mc:flash.MovieClip,str){

		mc.onRollOver = callback(displayHint,str);
		mc.onRollOut = removeHint;
		mc.onDragOver = mc.onRollOver;
		mc.onDragOut = mc.onRollOut;
		//mc.onEnterFrame = updateHint;


	}
	function displayHint(str){

		hint.cacheAsBitmap = true;
		hint.field._width = 150;
		hint.field.htmlText = str;
		hint.field._width = hint.field.textWidth+5;
		hint.field._height = hint.field.textHeight+5;
		hint.bg._xscale = hint.field.textWidth+8;
		hint.bg._yscale = hint.field.textHeight+6;

		hint.field._x = 1;
		hint.field._y = 1;

		hint.onEnterFrame = updateHint;
		hint.flActive = true;

	}

	function removeHint(){
		hint.flActive = false;
	}

	function updateHint(){
		if( hint.flActive ){
			hint._alpha = Math.min(hint._alpha+20,100);
		}else{
			hint._alpha = Math.max(hint._alpha-20,0);
			if(hint._alpha==0)hint.onEnterFrame = null;

		}


		//
		var dx = 10.0;
		var dy = 24.0;
		if( root._xmouse > mcw*0.5 )	dx = -(10+hint.field._width);
		if( root._ymouse > mch*0.7 )	dy = -(hint.field._height);

		//
		var c = 0.5;
		hint._x += ((root._xmouse+dx)-hint._x)*c;
		hint._y += ((root._ymouse+dy)-hint._y)*c;

		/*
		trace(hint.flActive);
		trace(hint.bg._xscale);
		trace(hint.bg._yscale);
		trace(hint._alpha);
		*/

	}


	function initTestMode(){
		//*
		root._alpha = 0;
		root._visible = false;
		//while(true){};
		return;
		//*/


		trace("mode test");

		pi.setToDefault();

		pi.engine += Std.random(6);
		//pi.life = Std.random(5);


		for( i in 0...3 )pi.items[MissionInfo.CARD_RED+i] = 2;

		pi.items[MissionInfo.BALL_DRILL] = 2;
		if(Std.random(2)==0)pi.items[MissionInfo.BALL_SOLDAT] = 2;
		if(Std.random(3)==0)pi.items[MissionInfo.BALL_POWER] = 2;
		if(Std.random(4)==0)pi.items[MissionInfo.BALL_BLACK] = 2;

		if(Std.random(2)==0) pi.items[MissionInfo.EXTENSION] = 2;

		if(Std.random(2)==0)pi.items[MissionInfo.MAP_SHOP] = 2;

		if(Std.random(4)==0)pi.items[MissionInfo.MISSILE_BLUE] = 2;
		if(Std.random(8)==0)pi.items[MissionInfo.MISSILE_BLACK] = 2;
		if(Std.random(16)==0)pi.items[MissionInfo.MISSILE_RED] = 2;

		for( i in 0...7 )if(Std.random(7)==0)pi.items[MissionInfo.STAR_RED+i] = 2;
		for( i in 0...4 )if(Std.random(2)==0)pi.items[MissionInfo.ANTIMAT_0+i] = 2;
		for( i in 0...12 )if(Std.random(2)==0)pi.items[MissionInfo.TBL_0+i] = 2;
		for( i in 0...42 )if(Std.random(50)!=0)pi.items[MissionInfo.EMAP_0+i] = 2;
		for( i in 0...5 )if(Std.random(2)==0)pi.items[MissionInfo.CRYSTAL_0+i] = 2;


		if(Std.random(10)==0)pi.shopItems[ShopInfo.DRONE_CONVERTER] = 1;
		if(Std.random(3)==0)pi.shopItems[ShopInfo.DRONE_PERFO] = 1;
		if(Std.random(2)==0)pi.shopItems[ShopInfo.DRONE_SPEED] = 1;
		if(Std.random(2)==0)pi.shopItems[ShopInfo.DRONE_COLLECTOR] = 1;

		if(Std.random(2)==0)pi.shopItems[ShopInfo.COOLER] = 1;
		if(Std.random(2)==0)pi.shopItems[ShopInfo.MISSILE_GENERATOR] = 1;
		if(Std.random(2)==0)pi.shopItems[ShopInfo.LATERAL] = 1;

		if(Std.random(2)==0)pi.shopItems[ShopInfo.SUNGLASSES] = 1;
		if(Std.random(2)==0)pi.shopItems[ShopInfo.ANTENNA] = 1;

		if(Std.random(2)==0)pi.shopItems[ShopInfo.MINE_0] = 1;
		if(Std.random(2)==0)pi.shopItems[ShopInfo.MINE_1] = 1;
		if(Std.random(2)==0)pi.shopItems[ShopInfo.MINE_2] = 1;

		if(Std.random(2)==0)pi.items[MissionInfo.MEDAL_0] = 2;
		if(Std.random(2)==0)pi.items[MissionInfo.MEDAL_1] = 2;
		if(Std.random(2)==0)pi.items[MissionInfo.MEDAL_2] = 2;
		if(Std.random(3)==0)pi.items[MissionInfo.MEDAL] = 2;

		if(Std.random(2)==0)pi.items[MissionInfo.SUPER_RADAR] = 2;
		if(Std.random(2)==0)pi.items[MissionInfo.SYNTROGEN] = 2;
		if(Std.random(2)==0)pi.items[MissionInfo.RETROFUSER] = 2;
		if(Std.random(2)==0)pi.items[MissionInfo.COMBINAISON] = 2;
		if(Std.random(2)==0)pi.items[MissionInfo.MINES] = 2;
		if(Std.random(2)==0)pi.items[MissionInfo.STONE_LYCANS] = 2;
		if(Std.random(2)==0)pi.items[MissionInfo.STONE_SPIGNYSOS] = 2;
		if(Std.random(2)==0)pi.items[MissionInfo.GENERATOR] = 2;

		if(Std.random(2)==0)pi.items[MissionInfo.DOUGLAS] = 2;
		if(Std.random(2)==0)pi.items[MissionInfo.SALMEEN] = 2;

		if(Std.random(2)==0)pi.items[MissionInfo.LANDER_REACTOR] = 2;
		if(Std.random(2)==0)pi.items[MissionInfo.BALL_DOUBLE] = 2;

		if(Std.random(2)==0)pi.shopItems[ShopInfo.MISSILE_MAP] = 1;
		if(Std.random(2)==0)pi.shopItems[ShopInfo.PODS] = 1;
		for(i in 0...3)if(Std.random(2)==0)pi.shopItems[ShopInfo.LANDER_REACTOR_0+i] = 1;
		for(i in 0...3)if(Std.random(2)==0)pi.shopItems[ShopInfo.PODS_EXTEND_0+i] = 1;


		while(Std.random(2)==0)pi.radar += 1;

		pi.drone = 3;
		pi.missileMax = Std.random(30);
		pi.missile = Std.random(pi.missileMax);

		for( i in 0...23 )pi.comp[i] = 100;//Std.int(Num.mm(0,Math.random()*3-1.5,1)*100);
	}


	// Voir les numero des missiles ramassés.
	// Voir les destinations des passagers.
	// Decaler de 1 en arriere les numerotations des réacteurs de surface.


//{
}












