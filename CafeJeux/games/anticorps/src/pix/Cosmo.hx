package pix;
import Common;
import mt.bumdum.Lib;
import mt.bumdum.Phys;

typedef Pod = {
	>flash.MovieClip,
	dec:Int,
	x:Int,
	y:Int,
	gid:Int,
	anim:Tween
}
typedef Tween = {
	sx:Float,
	sy:Float,
	sr:Float,
	ex:Float,
	ey:Float,
	er:Float,
	c:Float
}
typedef Ball = { >flash.MovieClip, id:Int}

class Cosmo extends pix.Phys {//}


	static var STYLE_LIFE = 1;
	static var BOUNCE_MAX = 20;

	static var COLORS = [0xFF0000,0x0000FF];
	static var SNIPE_RAY = 200;

	public var flAutoTurnHead:Bool;
	public var flPoison:Bool;
	public var flMine:Bool;
	public var flJump:Bool;
	public var flDeath:Bool;
	public var flWaitHand:Bool;

	public var state:CosmoState;
	public var shoeGrip:Float;
	public var balance:Float;
	public var startZone:Float;

	public var ga:Float;
	public var ray:Float;
	public var sens:Int;
	public var colorId:Int;
	public var lastActionId:Int;
	public var snipeRay:Int;
	public var type:CosmoType;

	public var hpMax:Int;
	public var bounceCount:Int;
	public var hp:Int;
	public var jumpPower:Float;
	public var glowDecal:Float;


	public var mox:Int;
	public var bal:Float;
	public var vbal:Float;

	public var escapeTimer:Int;
	var escapeTimerMax:Int;

	public var jumpDecal:Float;
	public var jumpDecal2:Float;
	public var jumpShake:Float;

	public var pods:Array<Pod>;
	public var actions:Array<{mod:Mod,ammo:Int}>;
	public var team:Array<pix.Cosmo>;
	public var menu:{ list:Array<Ball>, sens:Int, c:Float};

	public var dm:mt.DepthManager;

	public var strike:Strike;


	var mcEscape:flash.MovieClip;
	var mcMiniTarget:{>flash.MovieClip,fade:Int};
	var mcLife:{>flash.MovieClip,field:flash.TextField, act:Int, bar:flash.MovieClip, timer:Float };
	public var mcWeapon:{>flash.MovieClip,vs:Float,ts:Float};
	public var head:{>Phys,tx:Float,ty:Float};


	public function new(mc,type,flMine) {

		super(mc);
		ray = 7;
		weight = 0.5;
		frict = 0.98;
		colFrict = 0.5;
		Game.me.cosmos.push(this);
		sens = 1;
		setType(type);

		// TEAM AND FUNKY STUFF
		this.flMine = flMine;
		if(flMine) team=Game.me.myCosmos; else team=Game.me.oppCosmos;
		team.push(this);


		colorId = 0;
		var flColor = flMine;
		if(!Game.me.flMain)flColor = !flColor;
		if(!flColor)colorId+=1;


		//
		initSkin();
		actions = [];
		var list = Cs.ACTIONS[Cs.getCosmoTypeId(type)];
		for( mod in list ){
			actions.push({mod:mod,ammo:Cs.getAmmo(mod)});
		}


		// Cs.ACTIONS[Cs.getCosmoTypeId(type)].copy();
		// snipeRay = 200;

		// miniMap
		initMapPos(colorId+1);

		//
		hp = hpMax;

		//
		root.onRollOver = over;
		root.useHandCursor = false;


	}
	public function startDrop(){
		initLife();
	}

	function setType(n){
		type = n;
		switch(type){
			case CosmoDev:
				hpMax = 100;
				jumpPower = 20;
				shoeGrip = 100;
				balance = 4;
				startZone = 100;

			case CosmoScout:
				hpMax = 50;
				jumpPower = 16;
				shoeGrip = 6;
				balance = 4;
				startZone = 150;

			case CosmoSoldat:
				hpMax = 100;
				jumpPower = 12;
				shoeGrip = 3;
				balance = 4;
				startZone = 100;

			case CosmoTank:
				hpMax = 200;
				jumpPower = 6;
				shoeGrip = 2;
				balance = 1.2;
				startZone = 100;

			case CosmoMedic:
				hpMax = 70;
				jumpPower = 10;
				shoeGrip = 3;
				balance = 1.6;
				startZone = 100;

			case CosmoNinja:
				hpMax = 100;
				jumpPower = 20;
				shoeGrip = 10;
				balance = 4;
				startZone = 50;

			case CosmoMage:
				hpMax = 50;
				jumpPower = 10;
				shoeGrip = 3;
				balance = 1.6;
				startZone = 100;
		}
	}

	public function setState(st){

		if(state==Fly)Game.me.anims.remove(this);
		state = st;
		switch(state){
			case Fly:	initFly();
			case Ground :
				flAutoTurnHead = true;
				grip();

				//var eq = Num.hMod((-1.57-ga),3.14);



				var ec = 3;
				for( i in 0...pods.length ){
					var sens = Std.int(i*2-1);
					var p = pods[i];
					p.x = x;
					p.y = y;
					p.gid = gid;
					p.dec = -sens*ec;
					translatePod(p,ec,sens);
				}
				vx = 0;
				vy = 0;
			case Levit :
				if(bal==null)bal = 0;
				if(vbal==null)vbal = 0;
				head.tx = 0;
				head.ty = 0;

			case Freeze :
		}

	}
	public function initTurn(){
		flAutoTurnHead = true;
		if(mcWeapon!=null)removeWeapon();
	}

	// UPDATE
	public function main(){
		/*
		if(flMine){
			var d = Cs.DIR[gid];
			MMApi.print( "glue:   "+Game.me.isGlue(x+d[0],y+d[1]) );
			MMApi.print( "ground: "+Game.me.isFree(x+d[0],y+d[1]) );
		}
		*/



		switch(state){
			case Ground : 	updatePods();
			default:
		}

		moveHead();
		updateWeapon();
		updateMenuBalls();
		updateEscape();
		updateGlow();
		updateLife();
		updateMiniTarget();
		//trace(sens);

	}
	public function update() {
		updateFly();
	}

	// FLY
	public function initFly(){
		Game.me.setFocus(cast this);
		jumpDecal = Math.random()*628;
		jumpDecal2 = Math.random()*628;
		jumpShake = 3;
		flJump = false;

		head.tx = 0;
		head.ty = 0;
		bounceCount = 0;
		///head.updatePos();


		ox = 0.5;
		oy = 0.5;
		gid = null;
		Game.me.anims.push(this);
		Game.me.setReady(false);
	}
	public function updateFly(){



		fly();
		if(Math.abs(vx)/vx != sens )setSens(-sens);
		if(y>Game.me.mapHeight+10)die();

		applyDanger();

	}
	override function onBounce(sx,sy){
		super.onBounce(sx,sy);
		//trace(getDir(sx,sy)+"___"+isFree(x+sx,y+sy));
		var vit = Math.sqrt(vx*vx+vy*vy);

		var flGlue = Game.me.isGlue(x+sx,y+sy);
		var flSmoke = false;

		if( vit < shoeGrip  || flJump || flGlue || bounceCount>BOUNCE_MAX ){
			grip();
			if( checkBalance() || bounceCount>BOUNCE_MAX ){
				setState(Ground);
				parc = 0;
				applyDanger();

				var max = Std.int( Math.min(vit*3,12) );
				var spm =  Math.min(vit*0.5,3) ;
				if( MMApi.isReconnecting() ) max = 0;
				if(flGlue){

					for( i in 0...max ){
						var p = getGlue(ga);
						var a = ga+(Math.random()*2-1)*1.57;
						var speed = 0.2+Math.random()*spm;
						p.vx = Math.cos(a)*speed;
						p.vy = Math.sin(a)*speed;
						p.weight *= 1.2;
						p.timer += 3;
					}
				}else{
					for( i in 0...Std.int(max*0.5) ){
						var p = new Phys( Game.me.mdm.attach("partSmokeGround",Game.DP_PARTS) );
						var a = ga+1.57;
						var speed = (0.2+Math.random()*1.5)*(Math.random()*2-1);
						p.x = x;
						p.y = y;
						p.vx = Math.cos(a)*speed;
						p.vy = Math.sin(a)*speed;
						p.timer = 10+Math.random()*10;
						p.root._rotation = ga/0.0174;
						p.fadeType = 0;
						p.setScale(150-Math.abs(speed)*50);
					}
				}


			}else{
				gid = null;
				flSmoke = true;
			}

		}else{
			flSmoke = true;

		}
		if(flSmoke){
			var max = 3;
			if( MMApi.isReconnecting() ) max = 0;
			for( i in 0...max ){
				var p = new Phys( Game.me.mdm.attach("partSmokeGround",Game.DP_PARTS) );
				var a = ga+(Math.random()*2-1)*1.57;
				var speed = (0.2+Math.random()*1.5)*(Math.random()*2-1);
				p.x = x;
				p.y = y;
				p.vx = Math.cos(a)*speed;
				p.vy = Math.sin(a)*speed;
				p.timer = 10+Math.random()*10;
				p.root._rotation = Math.random()*360;
				p.fadeType = 0;
				p.setScale(100+Math.random()*50);
				p.vr = (Math.random()*2-1)*8;
			}
			bounceCount++;

		}



	}
	public function checkBalance(){
		var eq = Num.hMod((-1.57-getNormal()),3.14);
		var d = Cs.DIR[gid];
		return Math.abs(eq)<1.57 || Game.me.isGlue(x+d[0],y+d[1]);
		//return Math.abs(eq) < balance;
	}

	// GIVE HAND
	public function giveHand(){
		Game.me.setFocus(cast this);
		if(mcWeapon!=null)removeWeapon();
		flWaitHand = false;
		if(!flMine || !MMApi.hasControl() || MMApi.isReconnecting() )return;
		var mode:mod.ac.Move = cast Game.me.setMod(Move,this);
		if(escapeTimer!=null){
			mode.flCancel = false;
			if(mcEscape==null)initEscapeBar();
		}
	}
	/*
	public function pass(){
		//trace("pass!");
		MMApi.queueMessage(PlayNext());
		MMApi.endTurn();
	}
	*/
	public function next(){
		if(!flMine)return;
		Game.me.pass();
		/*
		if( type == CosmoScout && Game.me.myCosmos.length>1 ){
			MMApi.queueMessage(PlayNext(true));
		}else{
			pass();
		}
		*/
	}
	public function cover(){
		snipeRay = SNIPE_RAY;
		initWeapon(11);

	}

	// MENU
	public function initMenu(){
		if(!MMApi.hasControl())return;


		Game.me.setMsg("Choisissez une action");
		//haxe.Log.clear();
		//trace("initMenu");
		if(menu==null){
			menu = {
				list:[],
				sens:1,
				c:0.0
			}
			for( id in 0...actions.length ){
				var o = actions[id];
				if(o.ammo==0 || !isActionAvailable(o.mod) ){

				}else{
					var mc:Ball = cast Game.me.mdm.attach("mcMenuIcon",Game.DP_MENU);
					mc.gotoAndStop(Cs.getModId(o.mod)+1);
					mc.id = id;
					menu.list.push(mc);
					mc.onPress = callback(useAction,mc);
					mc.onRollOver =  callback(lightBall,mc);
					mc.onRollOut =  callback(unlightBall,mc);
					mc.onDragOut =  callback(unlightBall,mc);
				}
			}

		}
		menu.sens = 1;
		updateMenuBalls();

		updatePos();
		updatePos();
		updatePos();
	}
	public function removeMenu(){
		menu.sens = -1;
	}
	public function updateMenuBalls(){
		menu.c = Num.mm( 0, menu.c + 0.2*menu.sens*mt.Timer.tmod, 1 );
		var max = menu.list.length;
		var c = Math.pow(menu.c,0.3);


		var ray = 30*menu.c;
		for( i in 0...max ){
			var mc = menu.list[i];
			var a = (i/max + c*0.5 ) * 6.28;
			mc._x = x + Math.cos(a)*ray + head.tx;
			mc._y = y + Math.sin(a)*ray + head.ty;
			mc._xscale = 50+menu.c*50;
			mc._yscale = mc._xscale;
		}
		if( menu.sens ==-1 && menu.c == 0 ){
			for( mc in menu.list )mc.removeMovieClip();
			menu = null;
		}


	}

	function useAction(mc:Ball){
		if(menu.c<1)return;
		var id = mc.id;
		Game.me.flClick = false;
		var ac  = actions[id].mod;
		Game.me.setMod(ac,this);
		removeMenu();
		lastActionId = id;
	}
	function lightBall(mc:Ball){
		if(menu.c<1)return;
		var id = mc.id;
		var o = actions[id];
		var aid = Cs.getModId(o.mod);
		//var name = Lang.ACTION_NAME[aid].toUpperCase();
		//if(o.ammo>0) name+= " ["+o.ammo+"]";
		//Game.me.setWeaponTip(name,Lang.ACTION_DESC[aid]);
		Game.me.setWeaponTip(aid,o.ammo);
		mc._xscale = mc._yscale = 120;


	}
	function unlightBall(mc:Ball){
		var id = mc.id;
		Game.me.removeWeaponTip();
		//mc._xscale = mc._yscale = 100;
	}

	public function decAmmo(id:Int){
		//trace("decAmmo("+id+")");
		var ac = actions[id];
		if(ac.ammo!=null)ac.ammo--;
	}

	// ACTION
	public function walk(sens:Int){

		if(state!=Ground)return;
		setSens(sens);
		var ox = x ;
		var oy = y ;
		gotoNext(sens);
		for( p in pods ){
			p._x +=  ox-x;
			p._y +=  oy-y;
		}


		//var na = getNormal();
		//ga += Num.hMod(na-ga,3.14)*0.3;
		ga = getNormal();
		checkPods(sens);

		// GLUE
		var d = Cs.DIR[gid];
		var t = Cs.DIR[(gid+1)%4];
		if( Game.me.isGlue(x+d[0],y+d[1]) ){
			var p = getGlue(ga);
			p.updatePos();
		}

		/*

		// BALANCE
		if( !checkBalance() ){
			trace("fall!");

			//jump(1.57,2);
			//Game.me.setReady(false);
			//ga = getNormal();
			//setState(Fly);
			//flWaitHand = true;
			//vx = 0;
			//vy = 0;
		}
		*/



	}
	public function grip(?max){
		if(max==null)max = 60;
		var di = null;
		var di = null;
		var min = max;
		var flOut = Game.me.isFree(x,y);
		for( i in 0...4 ){
			var result = seekGround(i,flOut,max);
			if(result!=null){
				if(result<min){
					min = result;
					di = i;
				}
			}
		}

		if(flOut)min--;

		if( di!=null ){

			var d = Cs.DIR[di];
			x += d[0]*min;
			y += d[1]*min;


			if(!flOut)di = Cs.getDir(di+2);
			gid = di;
			ga = getNormal();

			updatePos();

			// VERIF
			var d = Cs.DIR[gid];
			var gx = x+d[0];
			var gy = y+d[1];
			if( Game.me.isFree(gx,gy) )trace("groundError["+gx+","+gy+"] gid:"+gid);

		}
	}

	public function jump(an:Float,power:Float){


		// PARTS
		var d = Cs.DIR[gid];
		var col = Game.me.mapBmp.getPixel32( x+d[0], y+d[1] );

		var ha = ga+1.57;
		var dx = Math.cos(ha)*8;
		var dy = Math.sin(ha)*8;


		var max = Std.int(power*0.5);
		if( MMApi.isReconnecting() ) max = 0;
		for( i in 0...max ){

			var c = Math.random()*2-1;
			var speed = 0.5+Math.random()*power*0.5;
			var p = new pix.Part(Game.me.mdm.attach("partHeal",Game.DP_PARTS));
			//Game.me.layGlue.dm
			p.x = Std.int(x+dx*c);
			p.y = Std.int(y+dy*c);
			p.vx = Math.cos(an)*speed;
			p.vy = Math.sin(an)*speed;
			p.timer = 10+Math.random()*15;
			//p.fadeType = 0;
			p.setScale(50+Math.random()*60);
			p.weight = 0.05+Math.random()*0.1;
			p.root.gotoAndPlay(Std.random(p.root._totalframes));
			//Col.setColor(p.root,col);
			//Filt.glow(p.root,2,1,0);

		}

		//
		setState(Fly);
		flWaitHand = true;
		vx = Math.cos(an)*power;
		vy = Math.sin(an)*power;
		flJump = true;
	}

	// SHOT
	public function shot(type:Int,angle:Float,power:Float){
		flWaitHand = true;

		//MMApi.logMessage("shot> ["+x+";"+y+"] ga:"+(Std.int(ga*100)/100));


		aimAt(angle);
		/*
		var da = Num.hMod(angle-1.57,3.14);
		sens = if(da>0) -1; else 1;
		setSens(sens);
		*/




		//trace( "shot("+angle+","+power+") from("+x+","+y+") ga("+ga+")");
		switch(type){
			case 0: // BAZOOKA
				var shot = newShot(type, angle, power);
				setEscape(0);
				Game.me.setFocus( cast shot );

			case 1: // MINE
				Game.me.addMine(x,y,getNormal(),flMine);

			case 2: // GUN
				var shot = newShot(2,angle);
				setEscape(120);

			case 3: // GRENADE

				var shot = newShot(type, angle, power);

				setEscape(80);
				Game.me.setFocus( cast shot );

				removeWeapon(true);

			case 4: // OBUS
				var shot = newShot(type, angle, power);
				setEscape(0);
				Game.me.setFocus( cast shot );

			case 6: // SWORD
				strike = new Strike(this,0);
				setEscape(0);

			case 7: // MEDIC MISSILE
				var shot = newShot(type, angle, power);
				setEscape(0);
				shot.bhl = [2];
				Game.me.setFocus( cast shot );

			case 8: // GAZ
				var shot = newShot(type, angle, power);
				setEscape(0);
				Game.me.setFocus( cast shot );
				removeWeapon(true);

			case 9: // PIQURE
				strike = new Strike(this,1);
				setEscape(0);

			case 10: // DASH
				new Dash(this,angle);
				setEscape(100);
				removeWeapon(true);

			case 11: // SHOTGUN
				var shot = newShot(11,angle);
				//setEscape(120);

		}


	}
	function newShot(type:Int,angle:Float,?power:Float){
		if(power==null)power = 1;

		var shot = getShot(type);
		var secDist = (ray+shot.ray)+1;
		shot.x = Std.int( x + head.x + Math.cos(angle)*secDist );
		shot.y = Std.int( y + head.y + Math.sin(angle)*secDist );
		shot.fire(angle,power);
		shot.orient();
		shot.updatePos();

		return shot;
	}
	function getShot(type){
		var shot = null;
		switch(type){
			case 0 : // BAZOOKA
				shot = new pix.Missile(0);
				shot.damage = 50;
				shot.radiusHole = 40;
				shot.radiusDamage = 50;
				shot.eject = 15;
				shot.weight = 0.3;

				shot.speed = 30;

				shot.ray = 6;
				shot.flHole = true;
				shot.bhl = [0];
				shot.flWind = true;

			case 2 : // GUN
				shot = new pix.Missile(1);
				shot.damage = 30;
				shot.radiusHole = 15;
				shot.radiusDamage = 15;
				shot.speed = 500;

				shot.timer = 2;
				shot.flImpactFocus = true;
				shot.lineFrom = this;
				shot.bhl = [4];

			case 3 : // GRENADE
				shot = new pix.Missile(2);
				shot.damage = 60;
				shot.radiusHole = 60;
				shot.radiusDamage = 75;
				shot.eject = 15;
				shot.weight = 0.3;
				shot.flHole = true;
				shot.root.smc.stop();
				shot.root.stop();

				shot.speed = 20;
				shot.timer = 100;

				shot.flBounce = true;
				shot.flAngleBounce = true;
				shot.flTimeExplode = true;
				shot.flOrient = false;
				shot.colFrict = 0.7;
				shot.setSpin(15);
				shot.bhl = [6];

			case 4 : // OBUS
				shot = new pix.Missile(3);
				shot.damage = 75;
				shot.radiusHole = 75;
				shot.radiusDamage = 80;
				shot.eject = 10;
				shot.weight = 0.3;
				shot.speed = 30;
				shot.ray = 6;
				shot.flHole = true;
				shot.bhl = [1];

			case 7 : // MEDIC MISSILE
				shot = new pix.Missile(4);
				shot.damage = 30;
				shot.radiusDamage = 50;
				shot.eject = 0;
				shot.weight = 0.3;

				shot.speed = 30;

				shot.flHeal = true;
				shot.ray = 6;
				shot.bhl = [0];
				Filt.glow(shot.root,2,4,0);

			case 8 : // GAZ
				shot = new pix.Missile(5);
				shot.eject = 0;
				shot.damage = 0;
				shot.radiusHole = 60;
				shot.radiusDamage = 100;

				shot.weight = 0.3;

				shot.timer = 100;
				shot.flBounce = true;
				shot.flAngleBounce = true;
				shot.flTimeExplode = true;
				shot.flOrient = false;
				shot.colFrict = 0.7;
				shot.setSpin(15);

				shot.flPoison = true;
				shot.bhl = [3];
				shot.endTimerMax = 60;

			case 11 : // SHOTGUN
				shot = new pix.Missile(1);
				shot.damage = 15;
				shot.radiusHole = 25;
				shot.radiusDamage = 25;
				shot.eject = 2;
				shot.speed = 500;
				shot.flHole = true;

				shot.timer = 2;
				shot.flImpactFocus = true;
				shot.lineFrom = this;
				shot.bhl = [5];

			default : return new pix.Missile(type);
		}
		return shot;
	}
	function coverShot(c){
		//trace("coverShot("+a+")");
		Game.me.unify();
		var dx = c.x+head.x - (x+head.x);
		var dy = c.y+head.y - (y+head.y);
		var a = Math.atan2(dy,dx);
		shot(11,a,null);
		Game.me.setReady(false);

		snipeRay = null;
		mcMiniTarget.fade = 10;
		removeWeapon();
	}

	// WEAPON
	public function initWeapon(id){
		if(mcWeapon == null ){
			mcWeapon = cast dm.attach("mcWeapon",0);
			mcWeapon.smc._xscale = mcWeapon.smc._xscale = 0;
			mcWeapon.vs = 0;
		}
		mcWeapon.gotoAndStop(id+1);
		mcWeapon.smc.stop();
		mcWeapon.ts = 100;
		updateWeapon();
	}
	public function updateWeapon(){
		if(mcWeapon==null)return;
		mcWeapon._x = head.x;
		mcWeapon._y = head.y;
		mcWeapon._xscale = head.root._xscale;
		mcWeapon._rotation += Num.hMod((head.root._rotation-mcWeapon._rotation),180)*0.5;

		var ds = (mcWeapon.ts - mcWeapon.smc._xscale);
		mcWeapon.vs += ds*0.2;
		mcWeapon.vs *= 0.7;
		mcWeapon.smc._xscale += mcWeapon.vs;
		mcWeapon.smc._yscale = mcWeapon.smc._xscale;

		if( mcWeapon.smc._xscale<=1 && mcWeapon.ts == 0 ){
			mcWeapon.removeMovieClip();
			mcWeapon = null;
		}



		if( Math.abs(mcWeapon.vs)+Math.abs(ds) < 1 ){
			if( mcWeapon.ts==0 ){
				mcWeapon.removeMovieClip();
				mcWeapon = null;
			}
		}

	}
	public function removeWeapon(?flInstant){
		mcWeapon.ts = 0;
		if(flInstant){
			mcWeapon._xscale = 0;
			mcWeapon._yscale = 0;
		}
		flAutoTurnHead = true;
	}
	public function aimAt(angle:Float){
		flAutoTurnHead = false;

		var da = Num.hMod(angle-ga,3.14);
		var sens = Std.int(da/Math.abs(da));
		setSens(sens);

		//cosmo.head.root._rotation = Math.atan2(sa,ca)/0.0174;
		head.root._rotation = angle/0.0174 + ((-sens+1)*0.5)*180;
	}

	// DANGER
	public function applyDanger(){

		return false;


		var def = getDefender(true);
		if(def!=null){
			//trace("coverShot! VictimPos("+def.c.x+","+def.c.y+")("+def.a+")");
			def.c.coverShot(this);

			return true;
		}

		// MINES
		return Game.me.checkMines(x,y);
	}
	public function getDefender(flAim){

		//var ray = 200;
		for( c in Game.me.cosmos ){
			if(c.flMine != flMine && ( c.snipeRay!=null || !flAim )  ){

				var ray = c.snipeRay;
				if( !flAim )ray = SNIPE_RAY;

				var dx =  x+head.x - (c.x+c.head.x);
				var dy =  y+head.y - (c.y+c.head.y);	// FAILLE SYNCHRO

				if( Math.abs(dx)<ray && Math.abs(dy)<ray ){
					var a = Math.atan2(dy,dx);
					var dist = Math.sqrt(dx*dx+dy*dy);
					var ca = Math.cos(a);
					var sa = Math.sin(a);
					for( n in 0...ray ){
						var x = Std.int(c.x+c.head.x+ca*n);
						var y = Std.int(c.y+c.head.y+sa*n);
						if( !Game.me.isFree(x,y) ){
							if(flAim)c.setMiniTarget(x,y,a);
							break;
						}
						if(n>=dist){
							if(flAim)c.setMiniTarget(x,y,a);
							return {c:c,a:a};
						}
					}
				}

			}
		}
		return null;
	}

	public function setMiniTarget(x,y,a){
		if( mcMiniTarget==null ){
			mcMiniTarget = cast Game.me.mdm.attach("mcMiniTarget",Game.DP_PARTS);
			Filt.glow(mcMiniTarget,2,4,0);
		}
		mcMiniTarget.fade = 100;
		mcMiniTarget._x = x;
		mcMiniTarget._y = y;

		//
		aimAt(a);

	}
	function updateMiniTarget(){
		if(mcMiniTarget==null)return;
		mcMiniTarget.fade--;
		mcMiniTarget._xscale = Math.min(mcMiniTarget.fade*10,100);
		mcMiniTarget._yscale = mcMiniTarget._xscale;

		if(mcMiniTarget.fade==0){
			mcMiniTarget.removeMovieClip();
			mcMiniTarget = null;
		}

	}

	// HP
	public function initLife(){

		switch(STYLE_LIFE){
			case 0:
				mcLife = cast Game.me.mdm.attach("mcLife",Game.DP_COSMO);
				Filt.glow(mcLife,2,8,COLORS[colorId]);
			case 1:
				mcLife = cast Game.me.mdm.attach("mcLifeBar",Game.DP_COSMO);
			default:
		}
		viewLife();
		mcLife.act = 0;
	}
	public function incHp(inc){
		hp = Std.int(Num.mm(0,hp+inc,hpMax));
		if( hp == 0 ){
			die();
		}
		if( inc<0 && Game.me.currentCosmo == this && flMine ){
			Game.me.endAnim = Game.me.pass;
			escapeTimer = null;
			flWaitHand = false;
		}

		viewLife();

	}
	function updateLife(){
		mcLife._x = root._x+head.x;
		mcLife._y = root._y+head.y;

		if(mcLife.act!=hp){
			var lim = 5;
			mcLife.act += Std.int(Num.mm(-lim,(hp-mcLife.act),lim));
			switch(STYLE_LIFE){
				case 0:
					mcLife.field.text = Std.string(mcLife.act);
				case 1:
					mcLife.bar._xscale = (mcLife.act/hpMax)*100;
					if( hp <= 30 ){
						Col.setPercentColor( mcLife.bar, 100, 0xFF0000 );
					}
				default:
			}
			//
		}

		// TIME
		if( mcLife.timer> 0)mcLife.timer -= mt.Timer.tmod;
		if( mcLife.timer< 10 ){
			mcLife._alpha = mcLife.timer*10;
		}


	}
	public function viewLife(){
		mcLife._alpha = 100;
		mcLife.timer = 60;
	}

	public function setPoison(fl){
		flPoison = fl;
		if( flPoison ){
			Filt.glow(head.root,10,1,0x8800CC,true);
			//Col.setPercentColor( head.root,40,0x00CC00);
		}else{
			head.root.filters = [];
			//Col.setPercentColor( head.root,0,0);
		}
	}
	public function heal(n){
		if(flPoison)setPoison(false);
		incHp(n);
	}

	//
	public function setSens(n){
		//if(state==Fly)trace("!");
		sens = n;
		head.root._xscale = sens*100;
	}
	public function goto(x,y,gid){
		this.x = x;
		this.y = y;
		this.gid = gid;

		//updatePos();
		//updatePods();
	}
	public function setFloatPos(nx,ny){
		x = Std.int(nx);
		y = Std.int(ny);
		ox = nx-x;
		oy = ny-y;
		super.updatePos();
	}
	public function cheese(){


		updatePos();
		head.x = head.tx;
		head.y = head.ty;
		head.vx = 0;
		head.vy = 0;
		head.updatePos();

	}

	// ESCAPE BAR
	function setEscape(n){
		escapeTimerMax = n;
		escapeTimer = n;
	}
	function initEscapeBar(){
		mcEscape = Game.me.dm.attach("mcEscape",Game.DP_INTER);
		mcEscape._y = 10;//Cs.mch;
		mcEscape.smc._xscale =  100;
		mcEscape._xscale =  Cs.mcw;
	}
	function removeEscapeBar(){
		mcEscape.removeMovieClip();
		mcEscape = null;
	}
	public function timeUp(){
		escapeTimer = null;
		removeEscapeBar();
		Game.me.pass();
	}
	function updateEscape(){
		if(escapeTimer>0 && mcEscape!=null ){
			escapeTimer--;
			mcEscape.smc._xscale =  (escapeTimer/escapeTimerMax)*100;
		}
	}

	// SELECT
	public function select(){
		//mapPoint.gotoAndStop(3);
		Game.me.mdm.over(root);
		//if(!flMine)return;
		glowDecal  = 0;

	}
	public function unselect(){
		//mapPoint.gotoAndStop(colorId+1);
		//if(!flMine)return;
		mapPoint._visible = true;
		Col.setPercentColor(root,0,0);
		glowDecal = null;
	}
	function updateGlow(){
		if(glowDecal==null)return;
		glowDecal = (glowDecal+53)%628;
		var n = 20;
		Col.setPercentColor(root,n+Math.cos(glowDecal*0.01)*n,0xFFFFFF);

		//if(mapPoint._currentframe<3) mapPoint.gotoAndStop(3); else mapPoint.gotoAndStop(colorId+1);
		mapPoint._visible = glowDecal <500;

	}

	// MOUSE PLACE
	public function updateMousePlace(){
		if(mox!=null){
			//trace("sens");
			//trace(sens);
			if( (x-mox)*sens > 0 )setSens(-sens);
			//trace(sens);
		}



		x = Std.int(Game.me.map._xmouse);
		y = Std.int(Game.me.map._ymouse-10);
		var ox = x;
		var oy = y;

		var ogid = gid;
		gid = null;
		grip(20);




		if(gid!=null){

			var ga = getNormal();
			var da = Num.hMod(ga+1.57,3.14);
			if( checkBalance() ){
				setState(Ground);
			}else{
				x = ox;
				y = oy;
				gid = null;
				setState(Levit);
				//bal = Num.hMod((ogid-1)*1.57,3.14);
			}

		}else{
			if(ogid!=null){
				setState(Levit);
				bal = Num.hMod((ogid-1)*1.57,3.14);
			}
		}


		updatePos();
		mox = x;

	}

	// SKIN
	function initSkin(){
		Filt.glow(root,2,4,0);

		// HEADz
		dm = new mt.DepthManager(root);
		head = cast new Phys( dm.attach("mcHead",1));
		head.root.gotoAndStop(Cs.getCosmoTypeId(type)+1);
		head.root.smc.gotoAndStop(colorId+1);
		//head.root.gotoAndStop(7);
		//head.root.smc.gotoAndStop(1+colorId);
		head.frict = 0.8;

		// PODS
		pods = [];
		for( i in 0...2 ){
			var mc:Pod = cast dm.attach("mcPod",1);
			if(i==0)dm.under(mc);

			var frame = i+1+colorId*2;
			//var flColor = flMine;
			//if(!Game.me.flMain)flColor = !flColor;
			//if(flColor)frame+=2;
			mc.gotoAndStop(frame);

			pods.push(mc);

		}

		//
		//root.onRollOver = callback(Game.me.mdm.over,root);


	}
	function moveHead(){
		//MMApi.print(head.tx);
		var dx = head.tx - head.x;
		var dy = head.ty - head.y;
		head.vx += dx*0.1;
		head.vy += dy*0.1;
		var tr = (ga+1.57)/0.0174;

		if(flAutoTurnHead)head.root._rotation += Num.hMod((tr-head.root._rotation),180)*0.2;

	}
	public function over(){
		Game.me.mdm.over(root);
		viewLife();
	}

	// PODS
	function translatePod(p:Pod,max,sens){
		var ox = p.x;
		var oy = p.y;
		for( n in 0...max ){
			Pix.movePoint( p, sens );
		}
		var a = getNormal(p);
		p.anim = {
			sx:ox*1.0,
			sy:oy*1.0,
			sr:p._rotation,
			ex:p.x*1.0,
			ey:p.y*1.0,
			er:a/0.0174,
			c:0.0
		}

	}
	function checkPods(sens){

		var lim = 6;
		for( p in pods ){
			p.dec+= sens;
			var sens = p.dec/Math.abs(p.dec);
			if( Math.abs(p.dec) > lim ){
				p.dec -= Std.int(lim*2*sens);
				translatePod(p,Std.int(lim*2),Std.int(sens));
			}
		}
	}
	function updatePods(){
		for( p in pods ){
			var an = p.anim;
			if( an!=null){

				an.c = Math.min(an.c+0.26,1);

				var dec = Math.sin(an.c*3.14)*ray*0.5;
				var dx = Math.cos(ga)*dec;
				var dy = Math.sin(ga)*dec;

				p._x = (-x + an.sx + (an.ex-an.sx)*an.c) + dx ;
				p._y = (-y + an.sy + (an.ey-an.sy)*an.c) + dy ;
				p._rotation = an.sr + Num.hMod(an.er-an.sr,180)*an.c;
				if( an.c==1 )p.anim = null;
			}
		}

	}

	// UPDATE POS
	override function updatePos(){
		super.updatePos();
		switch(state){
			case Fly:
				head.tx = 0;
				head.ty = 0;
				jumpDecal = (jumpDecal+33+jumpShake*2)%628;
				jumpDecal2 = (jumpDecal+23)%628;

				var tr = vy*6*sens;
				head.root._rotation += Num.hMod(tr-head.root._rotation,180)*0.5;
				head.root._rotation = Num.mm(-45,head.root._rotation,45);


				var n =-1;
				var ec = Num.mm(0.2,Math.abs(vy*0.1),0.7)+Math.cos(jumpDecal2*0.01)*0.1;
				//var dist = Num.mm( 8, Math.abs(vy*1.5), 12 );

				jumpShake *= 0.95;
				var dist = 10+Math.cos(jumpDecal*0.01)*jumpShake;

				for( p in pods ){

					var a = Math.atan2(vy+6+n,vx);
					var an = a+n*ec;
					var tx = Math.cos(an)*dist;
					var ty = Math.sin(an)*dist;
					p._x += (tx-p._x)*0.5;
					p._y += (ty-p._y)*0.5;
					p._rotation = an/0.0174 +180 ;
					n+=2;

				}

			case Ground:
				var r = ray+2;
				var dx = Math.cos(ga)*r;
				var dy = Math.sin(ga)*r;
				head.tx = dx;
				head.ty = dy;


			case Levit:
				// HEAD
				head.root._rotation *= 0.7;

				if(mox!=null)vbal += (mox-x)*0.01;
				var n = Num.hMod(0-bal,3.14)*0.2;
				vbal += n;
				vbal *= 0.9;
				bal = Num.hMod(bal+vbal,3.14);






				var sens=-1;
				var dist = ray+3;
				var ec = Num.mm(0.2,Math.abs(vbal),0.8);
				for( p in pods ){
					var a = (1.57+bal)+sens*ec;
					//trace(a);

					p._x = Math.cos(a)*dist;
					p._y = Math.sin(a)*dist;
					p._rotation = a/0.0174 +180;
					sens +=2;
				}




			case Freeze:
		}



	}

	// IS
	function isActionAvailable(action){
		switch(action){
			case Mine:
				for( c in Game.me.cosmos ){
					var dx = c.x-x;
					var dy = c.y-y;
					if( c!= this && Math.sqrt(dx*dx+dy*dy) < Cs.MINE_RAY ){
						return false;
					}
				}
				return true;

			case Cover :
				var def = getDefender(false);
				return  def == null;

			default: return true;
		}
	}


	//
	public function die(){
		flDeath = true;
		if(flWaitHand && flMine ){
			Game.me.endAnim = Game.me.pass;
			// pass();
		}

		var p = new Phys(Game.me.mdm.attach( "mcGhost", Game.DP_PARTS ));
		p.x = x;
		p.y = y;
		p.timer = 50;
		p.weight = -(0.05+Math.random()*0.5);
		p.frict = 0.96;

		kill();



		//if(team.length==0)MMApi.victory(!flMine);

	}
	override function kill(){





		// GFX
		//mapPoint.removeMovieClip();
		mcEscape.removeMovieClip();

		// LIST
		if(state==Fly)Game.me.anims.remove(this);
		Game.me.cosmos.remove(this);
		team.remove(this);

		//
		mcLife.removeMovieClip();


		super.kill();
	}


//{
}











