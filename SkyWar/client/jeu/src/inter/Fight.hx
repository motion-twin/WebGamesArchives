package inter;
import Datas;
import mt.bumdum.Lib;
import mt.bumdum.Trick;


typedef Projectile = {
	>flash.MovieClip,
	tw:Tween,
	trg:FightEntity,
	damage:Int,
	c:Float,
	wait:Float,
};
typedef FightEntity = {
	>flash.MovieClip,
	id:Int,
	fet:Int,
	life:Int,
	lifeMax:Int,
	sid:Int,
	bx:Float,
	by:Float,
	tx:Float,
	ty:Float,
	ray:Float,
	shake:Float,
	boom:Float,
	mcLife:flash.MovieClip,
	dm:mt.DepthManager,
}
typedef McMiniShip = {
	>FightEntity,
	data:DataShip,
	sx:Float,
	sy:Float,
}
typedef McMiniBuilding = {
	>FightEntity,
	data:DataBuilding,
}

class Fight {//}

	public static var DP_SHIPS_INTER =	10;
	public static var DP_PROJECTILES =	8;
	public static var DP_PLASMA =		6;
	public static var DP_SHIPS = 		4;

	public static var FL_SHOW_LIFE = true;

	static var SHIP_SCALE = 30;
	static var ISLE_ECX = Board.WIDTH*0.5;
	static var ISLE_ECY = 75;
	static var SHIP_EC = [50,30,20];
	static var FIGHT_ANGLE = 1.57*0.75;

	var animCoef:Float;
	var fstep:Int;
	var eventId:Int;
	var fallSeed:Int;

	var wait:Float;
	var unitLine:Float;
	var isleLine:Float;

	var pop:FightEntity;
	var ents:Array<FightEntity>;
	var blds:Array<McMiniBuilding>;
	var ships:Array<McMiniShip>;
	var squads:Array<Array<{h:Int,a:Array<DataShip>,n:Int}>>;
	var events:Array<_FightEvent >;
	var projectiles:Array<Projectile>;
	var work:Array<FightEntity>;
	var grid:Array<Array<flash.MovieClip>>;

	//var mcIsle:flash.MovieClip;
	var plasma:mt.bumdum.Plasma;
	var plasmaCycle:Int;
	var fightAction:Void->Void;


	var isle:Isle;
	var data:DataFight;

	public var dm:mt.DepthManager;
	public var root:flash.MovieClip;

	public var mcScreen:{>flash.MovieClip,bmp:flash.display.BitmapData};




	public function new(isle:Isle,data:DataFight){
		this.isle = isle;
		this.data = data;
		root = Inter.me.dm.empty(10);
		dm = new mt.DepthManager(root);

		fstep = 0;
		animCoef = 0;

		ships = [];
		squads = [];
		blds = [];
		ents = [];

		initScreen();



		isleLine = Cs.mcw;
		unitLine = 140;

		var flNoDefender = true;
		for( o in data._ships )if(o._owner==data._defenderId){ flNoDefender = false; break; };
		if( flNoDefender ){
			isleLine = Cs.mcw*0.6;
			unitLine = 250;
		}


		// BLD
		placeBuildings();

		// UNITS
		placeUnits();

		/// HISTORY
		events = data._history.copy();

		// PLASMA
		initPlasma();



	}
	function placeBuildings(){
		buildIsle(data);
		for( o in data._bld )linkBld(o);
	}
	function placeUnits(){



		// UNITS
		for( i in 0...2 ){
			var sens = -(i*2-1);

			// ATTACH
			var ec = 28;

			var trj = 150;
			var trjx = -sens*50;
			var trjy = 0;

			var a = [];
			for( o in data._ships ){
				if( (i==0) == (o._owner==data._defenderId) )a.push(o);
			}


			var ymax = Math.ceil( Math.pow(Math.sqrt(a.length), 1.1)  );
			var xmax = Math.ceil( a.length/ymax );
			var ma = unitLine - xmax*ec*0.5;
			var y = 0;
			var x = 0;

			var by = (Cs.mch-(ec*ymax))*0.5;

			for( o in a ){

				var tx = Cs.mcw*i+(ma+x*ec)*sens;
				var ty = by+y*ec;
				var mc = attachShip(o,tx,ty);
				mc._xscale = -sens*100;
				mc.sx = mc.tx;
				mc.sy = ty;
				if(o._owner!=data._defenderId)mc.sx = mc.tx - sens*(xmax*ec+ma);
				mc._x = mc.sx;
				mc._y = mc.sy;

				var player = Game.me.getPlayer(o._owner);
				Col.setColor(mc.smc,Cs.COLORS[player._color]);

				y++;
				if(y==ymax){
					y = 0;
					x++;
				}
			}

		}


	}

	function initScreen(){
		mcScreen = cast dm.empty(11);
		mcScreen.bmp = new flash.display.BitmapData(Cs.mcw,Cs.mch,false,0xFF0000);
		mcScreen.bmp.draw(Inter.me.root);
		mcScreen.attachBitmap(mcScreen.bmp,0);
		isle.root._visible = false;
		isle.bg._visible = false;
	}

	// UPDATE
	var blist:Array<flash.MovieClip>;
	public function update(){

		switch(fstep){
			case 0: // INTRO
				animCoef = Math.min(animCoef+0.05,1);
				mcScreen._alpha = 100-animCoef*100;

				if(animCoef==1){
					mcScreen._visible = false;
					animCoef = 0;
					fstep++;
				}

			case 1: // UNITS COME


				if( updateFightMove(1) ){
					for( mc in ships )if(FL_SHOW_LIFE)showLife(mc);
					eventId = 0;
					initEvent();
				}

			case 2:	// SALVE
				updateEvent();

			case 3: // SALVE WAIT
				animCoef = Math.min(animCoef+0.1,1);
				for( e in ents ){
					if(e.mcLife!=null && !FL_SHOW_LIFE){
						e.mcLife._alpha = (1-animCoef)*100;
						if(animCoef==1){
							e.mcLife.removeMovieClip();
							e.mcLife = null;
						}

					}
				}


				if(animCoef==1 && wait<=0 ){
					if(eventId<events.length){
						initEvent();
					}else{
						fstep = 6;
						wait = 20;
					}
				}

			case 6:	// WAIT
				wait -= mt.Timer.tmod;
				if(wait<=0 ){
					animCoef = 0;
					fstep = 4;
					for(e in ents )e.mcLife.removeMovieClip();
				}

			case 4: // UNIT GO BACK
				if( updateFightMove(-1) ){
					animCoef = 0;
					fstep = 5;

				}



			case 5: // SCROLL BACK ISLE
				animCoef = Math.min(animCoef+0.05,1);
				mcScreen._visible = true;
				mcScreen._alpha = animCoef*100;

				if(animCoef==1){
					isle.endFight();
				}


		}

		updateBooms();

		// PLASMA
		plasmaCycle = (plasmaCycle+1)%3;
		if(plasmaCycle==0)plasma.update();

	}

	// FIGHT MOVE
	function updateFightMove(sens){
		animCoef++;
		var id = ships.length;
		if(sens==-1)id = 0;
		var flNext = true;
		var speedCoef = 3;
		for(sh in ships){
			if( sh.data._owner != data._defenderId ){
				id-=sens;
				var c = Num.mm(0,(animCoef*speedCoef-id)/30,1);
				if(c<1)flNext = false;
				c = 1-(0.5+Math.cos(c*3.14)*0.5);
				var c2 = 1-c;
				if(c>0)if(sh._xscale*sens < 0 )sh._xscale *= -1;

				if(sens==-1){
					c = 1-c;
					c2 = 1-c2;
				}



				sh._x = sh.sx *c2 + sh.tx*c;
				sh._y = sh.sy *c2 + sh.ty*c;
			}



		}


		return flNext;
	}

	// ISLE
	function buildIsle(data:DataFight){
		var pgr = isle.pl.getGrid();


		//var isl = dm.empty(DP_SHIPS);
		//var idm = new mt.DepthManager(isl);
		//isl.blendMode = "overlay";

		// LAND
		var ec = 22;
		var mcIsle = dm.empty(Fight.DP_SHIPS);
		var idm = new mt.DepthManager(mcIsle);
		mcIsle.blendMode = "overlay";

		var xMin = 999;
		var yMin = 999;
		var xMax = 0;
		var yMax = 0;
		grid = [];
		var a = [];
		for( x in 0...Cns.GRID_MAX ){
			grid[x] = [];
			for( y in 0...Cns.GRID_MAX ){
				if(pgr[x][y]!=null){

					var mc = idm.attach("mcIconesBatiments",Fight.DP_SHIPS);
					grid[x][y] = mc;
					mc._x = x*ec;
					mc._y = y*ec;
					mc.smc.stop();
					mc.smc.smc.gotoAndStop(3);
					if(x>xMax)xMax = x;
					if(y>yMax)yMax = y;
					if(x<xMin)xMin = x;
					if(y<yMin)yMin = y;
					a.push(mc);

					mc.smc.blendMode = "overlay";
					var bg:flash.MovieClip  = cast(mc).bg;
					bg.gotoAndStop(Game.me.raceId+1);

				}
			}
		}

		var ww = (xMax-xMin)*ec;
		var hh = (yMax-yMin)*ec;
		var idx = (isleLine-ww)*0.5 - xMin*ec;
		var idy = (Cs.mch-hh)*0.5 - yMin*ec;

		for( mc in a ){
			mc._x += idx;
			mc._y += idy;
		}

		blist = a;


		// GEN BLD
		for( o in data._bld ){
			var mc = idm.attach("mcIconesBatiments",Fight.DP_SHIPS);
			grid[o._x][o._y] = mc ;
			mc._x = o._x*ec + idx;
			mc._y = o._y*ec + idy;

			mc.smc.blendMode = "overlay";
			var bg:flash.MovieClip  = cast(mc).bg;
			bg.gotoAndStop(Game.me.raceId+1);


			if( Cs.isBig(o._type) ){
				mc._x -= ec;
				mc._y -= ec;
				bg._xscale = bg._yscale = 200;
			}
			isle.displayBld(mc.smc,o);
		}


		// pop
		pop = cast dm.empty(Fight.DP_SHIPS);
		pop._x = idx + (xMin+(xMax-xMin)*0.5)*ec;
		pop._y = idy + (yMin+(yMax-yMin)*0.5)*ec;
		pop.tx = pop._x;
		pop.ty = pop._y;
		pop.id = 0;
		pop.bx = pop._x;
		pop.by = pop._y;

	}

	//
	function linkBld(o:DataBuilding){

		var mc:McMiniBuilding = cast grid[o._x][o._y];
		var car = BuildingLogic.get(o._type);

		var cen = 11;
		if( Cs.isBig(o._type) )cen+=11;

		mc.dm = new mt.DepthManager(mc);
		mc.data = o;
		mc.life = o._life;
		mc.lifeMax = car.life;
		mc.bx = mc._x;
		mc.by = mc._y;
		mc.tx = mc._x+cen;
		mc.ty = mc._y+cen;
		mc.fet = 1;
		mc.sid = Type.enumIndex(o._type)+100;
		mc.id = o._id;
		blds.push(mc);
		ents.push(mc);
	}

	function attachShip(data:DataShip,tx,ty){


		var mc = genShip(data,tx,ty);

		mc.fet = 0;
		mc.sid = Type.enumIndex(data._type);

		mc.tx = tx;
		mc.ty = ty;
		mc.sx = mc.tx;
		mc.sy = mc.ty;
		mc.bx = mc.tx;
		mc.by = mc.ty;
		mc.data = data;
		mc.life = data._life;
		mc.id = data._id;
		var car = Tools.getShipCaracs(data._type, Game.me.getPlayer(data._owner)._tec, null, null);
		mc.lifeMax = car.life;

		var cy = mc.ty/150;
		Col.setPercentColor(mc.smc,70-cy*50,0x97AB97);
		ents.push(mc);
		ships.push(mc);

		return mc;
	}
	function genShip(data:DataShip,tx,ty){

		var mc:McMiniShip = cast dm.empty(Fight.DP_SHIPS);
		mc.dm = new mt.DepthManager(mc);
		mc.smc = mc.dm.attach("mcMapShip",0);
		mc.smc.gotoAndStop(Type.enumIndex(data._type)+1);

		return mc;
	}

	function initPlasma(){
		plasma = new mt.bumdum.Plasma(dm.empty(DP_PLASMA),Cs.mcw,Cs.mch,0.5);
		plasma.ct = new flash.geom.ColorTransform(1,1,1,1,0,0,0,-36);
		plasma.root.blendMode = "overlay";

		var fl = new flash.filters.BlurFilter();
		fl.blurX = 2;
		fl.blurY = 2;
		//plasma.filters.push(fl);

		plasmaCycle = 0;
	}

	function getSquad(nc:Float,big:Array<DataShip>,medium:Array<DataShip>,small:Array<DataShip>){
		var h = 40;
		var squad = [];
		for( n in 0...3 ){
			var ec =  SHIP_EC[n]*nc;
			var list = [big,medium,small][n];
			var d = 0.0;
			var dmax = getDistMax(h);
			var line = {h:h,a:[],n:n};
			for( o in list ){
				line.a.push(o);
				d+=ec;
				if(d>dmax){
					squad.push(line);
					h += Std.int(ec*0.75);
					d = 0;
					dmax = getDistMax(h);
					line = {h:h,a:[],n:n};
				}
			}

			if( line.a.length>0 ){
				squad.push(line);
				h += Std.int(ec*0.75);
			}

		}
		return squad;

	}


	// EVENTS
	function initEvent(){
		fstep = 2;
		animCoef = 0;
		work = [];
		var event = events[eventId];
		switch(event){
			case Assault(a):	initAssaults(a);
			case Flower(a):		initSpells(a,0);
			case Destroy(a):	initDestroy(a);
			default:
		}
	}
	
	function updateEvent(){
		if (fightAction != null)
			fightAction();
		else
			fstep++;
	}
	
	function endEvent(){
		for( mc in ships )mc.filters = [];
		for( mc in blds )mc.filters = [];
		eventId++;
		fstep = 3;
		animCoef = 0;
	}

	// ASSAULT
	function initAssaults(a:Array<DataAssault>){
		fightAction = updateAssaults;
		projectiles = [];
		for( o in a ){
			var att = getEnt(o._id);
			var trg = getEnt(o._trg);
			var mc:Projectile = cast dm.attach("mcProjectile",DP_PROJECTILES);
			mc.tw = new Tween(att.tx,att.ty,trg.tx,trg.ty);
			mc.damage = o._damage;
			mc.trg = trg;
			mc.c = 0;
			mc.wait = Math.random()*24;

			var size = 30;
			if(o._damage >= 5 )size = 60;
			if(o._damage >= 10 )size = 100;
			if(o._damage >= 30 )size = 200;
			if(o._damage >= 60 )size = 300;
			if(o._damage >= 100 )size = 400;
			mc._xscale = mc._yscale = size;
			projectiles.push(mc);
			Col.setPercentColor(att,100,0xFFFFFF);
			work.push(att);
			att.filters = [];
			Filt.glow(att,2,4,0xFF0000,true);
		}

	}
	function updateAssaults(){

		animCoef = Math.min(animCoef+0.05,1);

		updateFlash();
		moveProjectiles(0);
		var flNext = updateShake();

		// CHECK
		if( flNext && projectiles.length == 0 )endEvent();

	}

	function updateFlash(){
		var c = Math.max((1-animCoef*10),0);
		for(mc in work){
			var prc = c*100;
			Col.setPercentColor(mc,c*100,0xFFFFFF);

		}
	}
	function moveProjectiles(type){
		var brush = dm.attach("mcQueue",0);
		var a = projectiles.copy();
		for( mc in a ){
			if(mc.wait==null){
				var flFirst=  mc.c == 0;
				mc.c = Math.min(mc.c+0.05,1);
				var c = mc.c;
				var p = mc.tw.getPos(c);
				p.y -= Math.sin(c*3.14)*50;


				var dx = p.x - mc._x;
				var dy = p.y - mc._y;
				mc._x = p.x;
				mc._y = p.y;

				if(!flFirst){
					brush._rotation = 180+Math.atan2(dy,dx)/0.0174;
					brush._xscale = Math.sqrt(dx*dx+dy*dy)+0.25;
					brush._yscale = mc._xscale*0.8;
					brush._x = p.x;
					brush._y = p.y;
					plasma.drawMc(brush);
				}

				if( c==1 ){
					if( type == 0 ) hitEnt(mc.trg,mc.damage);
					if( type == 1 ) fxSpell(mc.trg,mc.damage);
					mc.removeMovieClip();
					projectiles.remove(mc);
				}
			}else{
				mc.wait--;
				if(mc.wait<=0)mc.wait=null;
			}
		}
		brush.removeMovieClip();
	}
	function updateShake(){
		var flNext = true;
		var shk = 10;
		for( mc in ents ){
			if(mc.shake!=null){
				flNext = false;
				mc.shake *= 0.85;
				mc._x = mc.bx + (Math.random()*2-1)*mc.shake*shk/(mc.fet*2+1);
				if(mc.shake<0.1){
					mc.shake = null;
				}

			}

			// BAR
			var bar = mc.mcLife.smc;
			var ts = (mc.life/mc.lifeMax)*100;
			var ds = ts - mc.mcLife.smc._xscale;
			if( Math.abs(ds)>1 ){
				bar._xscale += ds*0.2;
				if( bar._xscale < 75 )Col.setPercentColor(bar,100,0xFFFF00);
				if( bar._xscale < 50 )Col.setPercentColor(bar,100,0xFF8800);
				if( bar._xscale < 25 )Col.setPercentColor(bar,100,0xFF0000);
				flNext = false;
			}else{
				bar._xscale = ts;
			}

		}
		return flNext;

	}

	// SPELLS
	var spellId:Int;
	function initSpells(a:Array<DataAssault>,sid:Int){
		spellId = sid;
		fightAction = updateSpells;
		projectiles = [];
		for( o in a ){
			var att = getEnt(o._id);
			var trg = getEnt(o._trg);
			var mc:Projectile = cast dm.attach("mcProjectile",DP_PROJECTILES);
			mc.tw = new Tween(att.tx,att.ty,trg.tx,trg.ty);
			mc.damage = o._damage;
			mc.trg = trg;
			mc.c = 0;
			mc.wait = Math.random()*24;
			var size = 30;
			mc._xscale = mc._yscale = size;
			projectiles.push(mc);

			Col.setPercentColor(att,100,0xFFFFFF);
			work.push(att);
			att.filters = [];
			Filt.glow(att,2,4,0xFF0000,true);
		}
	}
	function updateSpells(){

		animCoef = Math.min(animCoef+0.05,1);

		updateFlash();
		moveProjectiles(1);
		var flNext = updateShake();

		// CHECK
		if( flNext && projectiles.length == 0 )endEvent();

	}

	// DESTROY
	function initDestroy(a:Array<Int>){
		fightAction = updateDestroy;
		fallSeed = Std.random(88);
		for( id in a ){
			var mc = getEnt(id);
			work.push(mc);
		}

		for( mc in ships )	if(mc.mcLife!=null)mc.mcLife.removeMovieClip();
		for( mc in blds )	if(mc.mcLife!=null)mc.mcLife.removeMovieClip();

	}
	function updateDestroy(){
		animCoef = Math.min(animCoef+0.02,1);
		var seed = new mt.Rand(fallSeed);
		for( mc in work ){
			var fall = 20+seed.random(40);
			var rot = (seed.rand()*2-1)*45;
			if(mc.id>=1000){
				mc._y = mc.ty+fall*animCoef;
				mc._rotation = rot*animCoef;
			}
			mc._alpha = Math.min(300-300*animCoef,100);

			fxBoom(mc);


		}
		if(animCoef==1){
			for( mc in work ){
				if(mc.id>=1000){
					ships.remove(cast mc);
					mc.removeMovieClip();
				}
				ents.remove(mc);
			}
			if( FL_SHOW_LIFE )for( e in ents )showLife(e);


			endEvent();
		}

	}

	function hitEnt(mc:FightEntity,damage){

		mc.shake = 1;
		mc.boom = damage/15;
		if(mc.mcLife==null)showLife(mc);
		mc.life = Std.int(Math.max(mc.life-damage,0));
	}
	function showLife(mc:FightEntity){
		mc.mcLife = dm.attach("mcShipLifeBar",DP_SHIPS_INTER);
		var coef = mc.life/mc.lifeMax;
		mc.mcLife.smc._xscale = coef*100;
		mc.mcLife._x = mc.tx;
		mc.mcLife._y = mc.ty-14;
		var bar = mc.mcLife.smc;
		if( bar._xscale < 75 )Col.setPercentColor(bar,100,0xFFFF00);
		if( bar._xscale < 50 )Col.setPercentColor(bar,100,0xFF8800);
		if( bar._xscale < 25 )Col.setPercentColor(bar,100,0xFF0000);
	}

	// FX
	function fxSpell(mc:FightEntity,damage){
		mc.shake = 1;
		var fx = mc.dm.attach("fxSpell",1);
		fx._rotation = Math.random()*360;
		Col.setPercentColor(fx,100,[0xFFCC00,0x00FF00][spellId]);

	}
	function fxBoom(mc:FightEntity){


		if(Std.random(4)==0){
			var ray = 6;
			var mcp = mc.dm.attach("mcExplosion",0);
			if( mc.id<1000 ){
				ray = Cs.isBig(cast(mc).data._type)?22:11;
				mcp._x = ray;
				mcp._y = ray;

			}

			mcp._x += (Math.random()*2-1)*ray;
			mcp._y += (Math.random()*2-1)*ray;

		}

		/*
		if( mc.id>=1000 ){
			if(Std.random(2)==0){
				var sc = 100/mc._yscale;
				var ec = 6*sc;
				var mcp = mc.dm.attach("mcExplosion",0);
				mcp._x = (Math.random()*2-1)*ec;
				mcp._y = (Math.random()*2-1)*ec;
				mcp._xscale = mcp._yscale = sc*100;
			}

		}else{
			var data:DataBuilding = (cast mc).data;
			var flBig = Cs.isBig(data._type);
			var proba = 4;
			if(flBig)proba=1;
			if(Std.random(proba)==0){
				var mcp = dm.attach("mcExplosion",DP_PLASMA);
				mcp._x = isle.mcIsle._x + Isle.getX(data._x,data._y);
				mcp._y = isle.mcIsle._y + Isle.getY(data._y,data._y)+Isle.DY;
				var ecx = Isle.DX;
				var ecy = Isle.DY*2;
				if( flBig ){
					ecx*=2;
					ecy*=2;
				}
				mcp._x += (Math.random()*2-1)*ecx;
				mcp._y -= Math.random()*ecy;
			}
		}
		*/





	}
	function updateBooms(){
		for( mc in ents ){
			if( mc.boom != null ){
				if( Math.random()<mc.boom )fxBoom(mc);
				mc.boom *= 0.92;
				if(mc.boom<0.1)mc.boom = null;
			}
		}
	}

	// TOOLS
	function getDistMax(h){
		return h/Math.cos(1.57*0.75);
	}
	function getShip(id){
		for( sh in ships )if(sh.data._id==id)return sh;
		return null;
	}
	function getBld(id){
		for( b in blds )if(b.data._id==id)return b;
		return null;
	}
	function getEnt(id):FightEntity{
		if( id == 0 )	{
			return pop;
		}
		var ent:FightEntity = getShip(id);
		if( ent == null )	ent = getBld(id);
		if( ent != null)	return ent;

		return null;
	}

	//
	public function remove(){
		mcScreen.bmp.dispose();
		mcScreen.removeMovieClip();
		root.removeMovieClip();
		isle.root._visible = true;
		isle.bg._visible = true;
	}


//{
}















