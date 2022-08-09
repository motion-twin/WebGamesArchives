package lander;

import mt.bumdum.Lib;
import mt.bumdum.Phys;


enum Scenario {
	Casino;
	Traveler;
	Seller;
	Swapper;
	Empty;
	Locked;
	Treasure;
	Furi;
	Info;
	ItemGiver(id:Int);
}


class House{//}




	var game:lander.Game;

	public var sx:Int;
	public var x:Int;
	public var y:Int;
	public var type:Int;
	public var alienBehaviour:Int;

	public var scn:Scenario;

	public var seed:mt.OldRandom;
	public var eventSeed:mt.OldRandom;

	public var mask:flash.MovieClip;
	public var mcAlien:flash.MovieClip;


	public function new(rnd,scn) {
		game = lander.Game.me;
		game.houses.push(this);
		seed = new mt.OldRandom(rnd);


		// SCN
		this.scn = scn;

		// POSITION
		var ma = 100;
		var mc  = game.dm.attach("mcHouse",0);
		x = Std.int( ma + seed.rand()*(lander.Game.WIDTH-ma*2) );
		y = game.getGround(x);



//

		// TYPE
		type = 0;

		// Y
		var my = y-(lander.Game.HEIGHT-game.pl.dMax);

		// SX
		var a = [];
		for( n in 0...2 ){
			var rx = x+(n*2-1)*80;
			var gy = game.getGround(rx);
			a.push(gy);
		}
		var dx = a[1]-a[0];
		sx = Std.int( dx / Math.abs(dx) );
		if(dx==0)sx = 1;


		// DRAW
		var m = new flash.geom.Matrix();
		m.scale(sx,1);
		m.translate(x,my);
		game.bmpForeground.draw(mc,m);
		var fr = 3;
		if( scn == Locked )fr = 2;
		mc.smc.gotoAndStop(fr);
		game.bmpDecor.draw(mc,m);
		mc.removeMovieClip();




		// SCENARIO





	}

	public function dig(){

		var mc  = game.dm.attach("mcHouse",0);
		mc.smc.gotoAndStop(4);
		var m = new flash.geom.Matrix();
		m.scale(sx,1);
		m.translate( x, y-(lander.Game.HEIGHT-game.pl.gMax) );
		game.bmpGround.draw(mc,m,null,"erase");
		mc.removeMovieClip();

	}

	//
	public function update(){

		// TODO FADE IN DU MASK
		var h = lander.Game.me.hero;

		switch(alienBehaviour){
			case 0:
				var c = 0.5;
				var dx = h.x - mcAlien._x ;
				var dy = h.y - mcAlien._y ;
				var dist = Math.sqrt(dx*dx+dy*dy);
				var a = Math.atan2(dy,dx);
				var d = 3+Math.sqrt(h.vx*h.vx+h.vy*h.vy);
				mcAlien._x += Math.cos(a)*d;
				mcAlien._y += Math.sin(a)*d;
				mcAlien._alpha = Num.mm(0,dist*5,100);
				if( dist < 6 ){
					alienBehaviour = null;
					mcAlien.removeMovieClip();
				}
		}
	}

	//
	public function active(){

		eventSeed = seed.clone();

		switch(scn){

			case Empty:

			case Locked:
				lander.Game.me.hero.setIcon("lock");
				return;

			case Treasure:
				var min = new lander.Mineral(seed);
				min.setValue(100+seed.random(Std.int(lander.Game.me.level.dst*5)));
				min.root._x = x+(eventSeed.rand()*2-1)*10;
				min.dropToSurface();
				mark();

			default:
				initAlien();



		}

		// MASK
		if( mask == null ){
			mask = game.fdm.attach("mcHouse",1);
			mask._x = x;
			mask._y = y;
			mask.gotoAndStop(type+1);
			mask.smc.gotoAndStop(4);
			mask.blendMode = "erase";
			//mask._alpha = 0;
			mask._xscale = sx*100;
		}
	}
	public function unactive(){
		mask.removeMovieClip();
		mask = null;

		if(mcAlien!=null){
			mcAlien.removeMovieClip();
			mcAlien = null;
			navi.Map.me.removeMenu(0);
		}
	}

	//
	public function mark(){
		scn = Empty;
		navi.Map.me.removeMenu(0);
		lander.Game.me.flMarkHouse = true;
	}

	// SCENARIO
	static var SCN_STATS = [
		{ scn:Casino,		w:0	},
		{ scn:Swapper,		w:0	},
		{ scn:Treasure,		w:6	},

		{ scn:Traveler,		w:15	},
		{ scn:Furi,		w:10	},
		{ scn:Seller,		w:7	},
		{ scn:Info,		w:8	},

		{ scn:Empty,		w:10	},
		{ scn:Locked,		w:10	},
		{ scn:Locked,		w:10	},
	];
	static public function getScenario(zid,seed:mt.OldRandom){

		// GIVE ITEM
		var a = [
			MissionInfo.SALMEEN_COUSIN,
			MissionInfo.BADGE_FURI,
			MissionInfo.BALL_DOUBLE,
			MissionInfo.RETROFUSER,
			MissionInfo.KARBONITE,
			MissionInfo.COMBINAISON,
		];
		for( i in 0...12 )a.push(MissionInfo.TBL_0+i);
		for( i in 0...42 )a.push(MissionInfo.EMAP_0+i);

		for( n in a ){
			var p = MissionInfo.ITEMS[n];
			if( Cs.pi.x == p.x && Cs.pi.y == p.y ){
				return navi.menu.ItemGiver.getScn(n);
			}

		}

		// ALREADY DONE
		//for( p in Cs.pi.houseDone )	if( Cs.pi.x == p[0] && Cs.pi.y == p[1] ) 	return Empty;
		if( lander.Game.me.flHouseVisited ) 	return Empty;

		// DESERT
		if( lander.Game.me.pl.pop*seed.rand() < 1 )return null;

		// INHABITE
		if( lander.Game.me.pl.pop == null )return null;

		//
		var sum = 0;
		for( o in SCN_STATS ) sum += o.w;
		var rnd = seed.random(sum);
		sum = 0;
		var id = 0;
		var scn = null;
		for( o in SCN_STATS ){
			sum += o.w;
			if( sum > rnd ){
				scn = o.scn;
				break;
			}
			id++;
		}

		/*
		// CHECK ALREADY DONE
		switch(scn){
			case Traveler:
				for( o in Cs.pi.travel ) 	if( Cs.pi.x == o._sx && Cs.pi.y == o._sy ) 	return Empty;
			default:
		}
		*/



		return scn;
	}

	public function initAlien(){

		mcAlien = game.bdm.attach( "landerAlien", lander.Game.DP_HERO );
		navi.menu.Shop.initAlien(mcAlien,seed.clone());
		mcAlien._x = x+(eventSeed.rand()*2-1)*30;
		mcAlien._y = game.getGround(x);
		mcAlien._xscale = sx*100;
		Filt.glow(mcAlien,2,4,0);
		navi.Map.me.newMenu(0,launchScreen,seed.clone());
		//navi.Map.me.newMenu(0,null,seed.clone());



	}

	public function launchScreen(){

		var x = mcAlien._x+lander.Game.me.base._x - (mcAlien._width+16)*0.5;
		var y = mcAlien._y+lander.Game.me.base._y - (mcAlien._height+16)*0.5;

		switch(scn){
			case Casino:
				navi.Map.me.menu = new navi.menu.World(x,y);

			case Traveler:
				navi.Map.me.menu = new navi.menu.Traveler(x,y,seed.clone());

			case Seller:
				navi.Map.me.menu = new navi.menu.Shop(x,y,seed.clone());

			case Swapper:
				navi.Map.me.menu = new navi.menu.World(x,y,seed.clone());

			case ItemGiver(id):
				navi.Map.me.menu = new navi.menu.ItemGiver(x,y,seed.clone(),id);

			case Furi:
				navi.Map.me.menu = new navi.menu.Furi( x, y, seed.clone() );

			case Info:
				navi.Map.me.menu = new navi.menu.Info( x, y, seed.clone() );

			default:

		}



	}


//{
}











