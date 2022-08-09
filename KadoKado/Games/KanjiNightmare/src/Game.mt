class Game {//}

	static var DEBUG_SCALE = null;

	static var FRONT_VISIBILITY_FX =0;
	static var FL_BAVE = false;
	//
	static var DP_BG = 1;
	static var DP_MAP = 2;
	static var DP_FRONT = 3;
	static var DP_INTER = 4;


	//
	static var DP_BACK = 	2;
	static var DP_PLAT = 	2;
	static var DP_ROPE = 	3;
	static var DP_MONS = 	4;
	static var DP_HERO = 	5;
	static var DP_BONUS = 	6;
	static var DP_MEDUSA = 	7;
	static var DP_SHOT = 	8;
	static var DP_PARTS = 	9;
	static var DP_DECOR = 	10;

	static var CL = 60;

	var genPlatCoef:int;
	volatile var dif:float;
	var flMouseDead:bool;
	var mouseDeadTimer:float;
	volatile var parc:float;
	volatile var handicap:float;

	volatile var scrollMin:float;
	volatile var scrollSpeed:float;

	var pList:Array<Part>;
	var sList:Array<Sprite>;
	var mList:Array<Monster>;
	var nsList:Array<Star>;
	var bonusList:Array<Bonus>;
	var platList:Array<Plat>;
	var plans:Array<{>MovieClip,c:float,w:float,x:float,y:float,dy:float,mask:MovieClip,type:int}>


	var stats:{ $opt:Array<int>, $bads:Array<int>, $dif:int }


	var dm:DepthManager;
	var mdm:DepthManager;

	var hero:Hero;

	var root:MovieClip;
	var bg:MovieClip;
	var map:MovieClip;
	var mcLine:MovieClip;
	var medusa:{>Phys,head:{>MovieClip,eatZone:MovieClip}}
	var medusaBody:{>Phys,neck:MovieClip}
	var medusaArms:Array<{>Phys, ab:{>MovieClip,vr:float,rot:float},b:{>MovieClip,vr:float,rot:float},h:MovieClip}>

	var mcCaveTop:{>MovieClip,bmp:flash.display.BitmapData};
	var focus:{x:float,y:float};

	var mcRedLight:MovieClip;
	var bdm:DepthManager;

	function new(mc) {



		Cs.game = this
		dm = new DepthManager(mc);
		root = mc;
		bg = downcast(dm.attach("mcBg",DP_BG))
		bg.stop();

		// LISTS
		sList = new Array();
		mList = new Array();
		pList = new Array();
		nsList = new Array();
		platList = new Array();
		bonusList = new Array();

		initMap();

		flMouseDead = false;

		scrollSpeed = 0.5;
		dif = 0;
		parc = 0;
		genPlatCoef = 10;
		handicap =0;

		stats = {$opt:[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],$bads:[0,0,0],$dif:null}

		scrollMin = map._x+300;

		hero = new Hero(mdm.attach("mcHero",DP_HERO));

		initMedusa();


		// KeyBoard
		var o = {
			onMouseDown:null,
			onMouseUp:null,
			onMouseWheel:null
			onMouseMove:callback(this,mouseMove)
		}
		Mouse.addListener(o);


		// Mouse



		genPlat(0,270,1000);
		genPlat(Cs.mcw*2,200,1000);

		focus = upcast(hero);



		if(DEBUG_SCALE!=null){
			root._xscale = DEBUG_SCALE;
			root._yscale = root._xscale
			root._x += 100
		}

	}
	function initMap(){

		// INIT PLANS
		plans = []
		var cl = [0.1,0.4,0.8,1,1.5];
		for( var i=0; i<cl.length; i++){

			var c = cl[i];
			if( c == 1 ){
				map = downcast(dm.empty(DP_MAP));
				downcast(map).c = 1
				mdm = new DepthManager(map);
			}else{

				for( var n=0; n<2; n++ ){
					var plan = downcast(dm.attach("mcPlan",DP_MAP));
					plan.gotoAndStop(string(i+1))
					plan.w = plan._width
					plan.x = plan.w*n
					plan.y = 0
					plan.c = c;
					plan.type = 0;
					plans.push(plan);

				}
			}
		}

		// CAVE TOP
		mcCaveTop = downcast(mdm.empty(DP_DECOR));
		mcCaveTop.bmp = new flash.display.BitmapData(Cs.mcw*4,CL,true,0x00000000);
		mcCaveTop.attachBitmap(mcCaveTop.bmp,0);
		printCaveTop(0);
		printCaveTop(Cs.mcw);
		printCaveTop(Cs.mcw*2);
		printCaveTop(Cs.mcw*3);

		// LINE
		mcLine = mdm.empty(DP_ROPE)

		// BAVE
		if(FL_BAVE){
			var mc = mdm.empty(DP_PARTS);
			bdm = new DepthManager(mc);
			//Cs.glow(mc,3,4,0xFFFFFF);
			var fl  = new flash.filters.GlowFilter();
			fl.blurX = 8
			fl.blurY = 8
			fl.strength = 4
			fl.color = 0xFFFFFF
			fl.knockout = true;
			mc.filters = [fl]
		}

	}

	function pushKey(){
		var n = Key.getCode();
		/*
		switch(n){
			case Key.SPACE:
				Cs.game.hero.onAction();
				break;
		}
		*/
	}

	function main() {
		//Log.print( int(Math.pow(dif,0.2)*100)/100 )
		Log.setColor(0xFFFFFF)
		/*
		Log.print("pList : "+pList.length)
		Log.print("mList : "+mList.length)
		Log.print("nsList : "+nsList.length)
		Log.print("bonusList : "+bonusList.length)
		Log.print("platList : "+platList.length)
		*/

		mcLine.clear();
		dif += Timer.tmod;
		stats.$dif = int(dif)

		bg._y = map._y*0.5

		updateMedusa();
		updateScroll();
		updateEnvFX();

		var list = sList.duplicate();
		for( var i=0; i<list.length; i++ )list[i].update();



	}

	// SCROLL
	function updateScroll(){

		var base = focus;

		if(hero.flEat){
			var c = 0.9
			base = {
				x:focus.x*c+medusa.x*(1-c),
				y:focus.y*c+medusa.y*(1-c)
			}
		}


		var dec = 300
		scrollMin = Math.min( scrollMin-scrollSpeed*Timer.tmod, map._x+dec)
		scrollSpeed += 0.001*Timer.tmod;

		var ox = map._x
		map._x = Cs.mcw*0.5-base.x
		map._y = Math.min( Cs.mcw*0.5-base.y, 0 )

		// SCROLL PLANS
		scrollDecor(map._x-ox);

		/// RECAL
		if(map._x<-Cs.mcw*2)recalScroll(Cs.mcw);


		// CHECK PLAT
		for( var i=0; i<platList.length; i++ ){
			var pl = platList[i]
			if(pl.x+pl.w<-scrollMin){

				pl.kill();
				i--;
			}
		}
		/*
		for( var n=0; n<mList.length; n++ ){
			var m = mList[n];
			if(m.x < -scrollMin){
				m.kill();
				mList.splice(n--,1);
			}
		}
		*/
	}
	function recalScroll(m){
		scrollMin += m;
		map._x += m;
		for( var i=0; i<sList.length; i++ ){
			var sp = sList[i];
			sp.x -= m;
			sp.root._x = sp.x;
		}
		//for( var i=0; i<platList.length; i++ )platList[i]._x -= m;
		mcCaveTop.bmp.scroll(-m,0);

		//medusa.x -= m;

		// CaveTop
		cleanCaveTop(Cs.mcw*3)
		printCaveTop(Cs.mcw*3);

		// Build Level
		if( Std.random(int(Math.pow(dif,0.24)*genPlatCoef)) < 40 ){
			genPlatCoef = 10;
			genPlat(null,null,null);

		}else{
			genPlatCoef-=3
		}


	}

	function scrollDecor(vx){

		handicap -= vx;
		var lap = 20
		while(handicap>lap){
			handicap -= lap;
			KKApi.addScore(Cs.C10)
		}

		parc -= vx;
		for( var i=0; i<plans.length; i++ ){
			var p = plans[i];
			p.x += p.c*vx;
			p.y = map._y*(0.5+p.c*0.5);
			switch(p.type){
				case 0:
					if(p.x>Cs.mcw)p.x-=p.w*2;
					if(p.x+p.w<0)p.x+=p.w*2;
					break;
				case 1:
					p.y += p.dy;
					if(p.x<-p.w*0.5){
						p.removeMovieClip();
						plans.splice(i--,1)
					}
					break;

			}
			p._x = p.x;
			p._y = p.y;
		}

		// ADD SCROLL ELEMENTS
		var lim = 50
		while(plans.length<20 && parc>lim){
			parc-=lim;
			addScrollElement();
			//parc-=lim
		}

		if(FRONT_VISIBILITY_FX==0)return;
		// CHECK FRONT ALPHA

		for( var i=0; i<plans.length; i++ ){
			var p = plans[i]
			if( p.type==1 && p.c>1 ){
				if(p.hitTest(hero.x+map._x,hero.y+map._y,true)){
					p._alpha += (20-p._alpha)*0.5;
				}else{
					p._alpha += (100-p._alpha)*0.5;

				}
			}
		}

	}
	function addScrollElement(){
		var mc = downcast(dm.attach("mcScrollElement",DP_MAP))
		mc.gotoAndStop(string(Std.random(mc._totalframes)+1))
		mc.c = 0.1+Math.random()*1.2
		mc._xscale = (0.3+mc.c*0.7)*100
		mc._yscale = mc._xscale
		mc._xscale *= (Std.random(2)*2-1);
		mc.w = mc._width;
		mc.x = Cs.mcw+mc.w*0.5;
		mc.y = 0;
		mc.dy = (1-mc.c)*50
		mc.type = 1


		mc._x = mc.x;

		Cs.setPercentColor(mc,(1-mc.c)*70, 0x984e71)
		/*
		if( mc.c>1 ){
			var bc = 1-(1.3-mc.c)/0.3
			var fl = new flash.filters.BlurFilter();
			fl.blurX = int(bc*40);
			fl.blurY = int(bc*40);
			mc.filters = [fl];
		}
		*/

		plans.push(mc);
		orderPlans();

		//Cs.glow(mc,4,4,0xFFFFFF)
		//Cs.glow(mc,20,1,0xFFCC00)


	}
	function orderPlans(){
		var f = fun(a,b){
			if(a.c<b.c)return -1;
			return 1;
		}
		var list = plans.duplicate();
		list.push(downcast(map))
		list.sort(f);
		for( var i=0; i<list.length; i++ )dm.over(list[i]);
	}

	function printCaveTop(x){
		/*
		var fmin = 1+dif*0.004
		var fmax = 2+dif*0.008

		Log.print(int(fmin))
		Log.print(int(fmax))

		var mc = dm.attach("mcCaveElement",DP_BG)
		var max = 4;
		for( var i=0; i<max; i++ ){
			mc.gotoAndStop(string(int(fmin+Math.random()*(fmax-fmin))))
			var m = new flash.geom.Matrix();
			var px = x + Math.random()*(Cs.mcw-mc._width)
			m.translate(px,0);
			mcCaveTop.bmp.draw(mc,m,null,null,null,null);
		}

		mc.removeMovieClip();
		*/

		 // BASE
		{
			var mc = dm.attach("mcCaveTop",DP_BG)
			var m = new flash.geom.Matrix();
			m.translate(x,0);
			mcCaveTop.bmp.draw(mc,m,null,null,null,null);
			mc.removeMovieClip();
		}

		// TOP ELEMENTS
		{
			var mc = dm.attach("mcTopElement",DP_BG)
			for( var i=0; i<5; i++ ){
				mc.gotoAndStop(string(Std.random(mc._totalframes)+1))
				var m = new flash.geom.Matrix();
				var px = x+mc._width*0.5+Math.random()*(Cs.mcw-mc._width)
				var py = Std.random(10);
				m.translate(px,py);
				mcCaveTop.bmp.draw(mc,m,null,null,null,null);
			}
			mc.removeMovieClip();
		}


	}
	function cleanCaveTop(x){
		mcCaveTop.bmp.fillRect( new flash.geom.Rectangle(x,0,Cs.mcw,CL),0x00000000);

	}

	// PLATEFORMES
	function genPlat(x,y,w){

		if(x==null)x = Cs.mcw*3+8+Math.random()*100;
		if(y==null)y = 140+Math.random()*150;
		if(w==null)w = Math.max(60,800-dif*0.25)+Math.random()*200;

		var to = 0;
		while(true){
			var flBreak = true;
			for( var i=0; i<platList.length; i++ ){
				var pl = platList[i]
				if( pl.x+pl.w>x && Math.abs(y-pl.y)<60 ){
					flBreak = false;
				}
			}
			if(flBreak)break;
			x = Cs.mcw*2+8+Math.random()*100;
			y = 140+Math.random()*150;
			if(to++>20)return;
		}

		//var mc = downcast(mdm.attach("mcPlat",DP_PLAT));
		var pl = new Plat(mdm.attach("mcPlat",DP_PLAT));
		pl.x = x;
		pl.setPlat(x,y,w)



		/// MONSTER
		//var mmax = Math.min(Math.ceil(mc.w*0.01), Math.pow(dif,0.2))
		//var max = Std.random(int(mmax))
		var rand =  Std.random(int(Math.pow(dif,0.2)))
		var max =  Math.min( Math.ceil(pl.w*0.02) , rand )
		if( max==0 && pl.w>160 )max++;
		var xl = []
		to = 0;

		for( var i=0; i<max; i++ ){
			var m = new Monster(mdm.attach("mcMonster",DP_MONS));
			var px = null
			do{
				px = pl.x + Math.random()*pl.w;
				var flBreak=true;
				for( var k=0; k<xl.length; k++ ){
					if( Math.abs(xl[k]-px) < 20 ){
						flBreak = false;
						break;
					}
				}
				if(flBreak)break;
				if(to++>200){
					Log.trace("MONSTER POS ERROR !!! ")
					break;
				}
			}while(true);

			if(max==1 && platList.length==1)px = pl.x+pl.w-10;

			xl.push(px)
			m.x = px;
			m.y = pl.y-m.ray;
			m.plat = pl;
			var maxId = 1;
			if(dif>1000)maxId++;
			if(dif>2800)maxId++;
			var id = Std.random(int(Math.min(maxId,max-i)))
			m.setSkin(id);
			max -= id;

		}


	}
	/*
	function setPlat(mc,x,y,w){
		mc._x = x;
		s_y = y;
		mc.w  = w;
		mc.mask._xscale = mc.w-38;
		mc.corner._x = mc.w-19;
		mc.text._x = mc.bx-mc._x
	}
	*/


	// FX
	function updateEnvFX(){
		if( hero.y > Cs.mch ){
			var c = (hero.y-Cs.mch)/Cs.mch
			if(Math.random()*c>0.2){
				var p = newPart("partLargeLight")
				p.x = Math.random()*Cs.mcw + -map._x;
				p.y = Cs.mch+10+Math.random()*20 -map._y;
				p.vy = Math.random()*6
				p.timer = 10+Math.random()*10;
				p.fadeType = 0;
				p.setScale(100+hero.y*0.2+Math.random()*100)
				p.root.blendMode = BlendMode.ADD

			}
		}
		// MOUSEDEAD
		if(mouseDeadTimer>0)mouseDeadTimer-=Timer.tmod;

		// MEDUSE PLONGE
		if(hero.flDeath){
			scrollMin -= 13;
		}
	}

	// COL
	function isFree(x,y){
		var col = mcCaveTop.bmp.getPixel32(x,y);
		var pc = Cs.colToObj32(col);
		return pc.a < 30;
	}

	// MEDUSA
	function initMedusa(){


		// BODY
		medusaBody = downcast(new Phys(mdm.attach("mcMedusaBody",DP_MEDUSA)));
		medusaBody.x = -2000
		medusaBody.neck = downcast(medusaBody.root).neck;
		/*
		var mc = downcast(medusaBody.root)
		for( var i=0; i<2; i++ ){
			var o = {
				b:Std.getVar(mc,"$b"+i),
				ab:Std.getVar(mc,"$ab"+i),
				h:Std.getVar(mc,"$h"+i)
			}
			o.b.vr = 0;
			o.b.rot = 0;
			o.ab.vr = 0;
			o.ab.rot = 0;

			medusaBody.list.push(o);
		}
		*/

		// HEAD
		medusa = downcast(new Phys(mdm.attach("mcMedusa",DP_MEDUSA)));
		medusa.root._visible = false;
		medusa.x = -scrollMin;
		medusa.head = downcast(medusa.root)

		// ARMS
		medusaArms = []
		var adp = [DP_BACK,DP_SHOT]
		for(var i=0; i<2; i++ ){
			var sp = downcast(new Phys(mdm.attach("mcArm",adp[i])));
			sp.x = medusaBody.x;
			sp.y = medusaBody.y;
			sp.b = Std.getVar(sp.root,"$b");
			sp.ab = Std.getVar(sp.root,"$ab");
			sp.h = Std.getVar(sp.root,"$h");
			//
			sp.b.vr = 0;
			sp.b.rot = 0;
			sp.ab.vr = 0;
			sp.ab.rot = 0;
			//
			medusaArms.push(sp);
			//if(i==0)Cs.setPercentColor(sp.root,100,0xEEA2F7);
			if(i==0)Cs.setPercentColor(sp.root,50,0x9D1E91);
		}

		//
		mcRedLight = dm.attach("mcRedLight",DP_FRONT)
		mcRedLight.blendMode = BlendMode.ADD;
		mcRedLight._alpha = 0;
		mcRedLight._y = Cs.mch*0.5;

		// GLOW ALL
		/*
		Cs.glow(medusa.root,2,4,0xFFFFFF)
		Cs.glow(medusa.root,12,1,0xFFAAAA)
		*/



	}
	function updateMedusa(){

		//
		mcRedLight._x = medusa.x+map._x;
		mcRedLight._y = medusa.y+map._y;

		// EAT
		if(hero.flEat){
			medusa.vx+=2*Timer.tmod;
			medusa.vy+=1.5*Timer.tmod;
			var frame = Math.max(1,medusa.head._currentframe-3)
			medusa.head.gotoAndStop(string(frame))

			medusa.head._rotation += 1;
			var lim = 166*(medusa.head._currentframe/30)
			if(Cs.game.hero.y>lim && Cs.game.hero.vy>0){
				Cs.game.hero.y = 166
				Cs.game.hero.vy*=-0.5
			}


		}else{
			var limit = 300;
			var danger = scrollMin+hero.x;
			var c = danger/limit
			var ty = (hero.y+hero.vy*2)-(1-c)*180//140

			mcRedLight._alpha = 100-c*100;
			mcRedLight._xscale = 500-c*200;
			mcRedLight._yscale = mcRedLight._xscale

			medusa.x = -scrollMin//-c*100;
			var lim = 2
			var dy = ty-medusa.y
			medusa.vy += Cs.mm(-lim,dy*0.15,lim)

			if(danger>limit){
				medusa.root._visible = false;
				mcRedLight._visible = false;
				medusaBody.root._visible = false;
			}else{
				if(!medusa.root._visible){
					medusa.y  = ty;
					medusa.root._visible = true;
					mcRedLight._visible = true;
					medusaBody.root._visible = true;
				}


				//
				if(c<0.7){
					var frame = 1+int((1-(c/0.7))*40);
					medusa.head.gotoAndStop(string(frame));
				}


				//*
					medusa.head._rotation = dy*0.1 + medusa.vy*0.5;
				/*/

					var a = medusa.getAng( {x:Cs.game.hero.x,y:Cs.game.hero.y-40} );
					medusa.head._rotation = (a/0.0174) *0.8
				//*/

				if(c<0.5){
					var cc = (c/0.5)*0.1;
					medusa.y += dy*cc;
				}

				if(c<0.33){
					focus  = {x:hero.x,y:hero.y}
					var dm = new DepthManager(medusa.head.eatZone);
					var link = "mcHero"
					if(hero.hp==0)link = "mcHeroSlip";
					var mc = dm.attach(link,0)
					//hero.x -= medusa.x
					//hero.y -= medusa.y
					mc.gotoAndPlay(string(hero.root._currentframe))
					hero.root.removeMovieClip();
					hero.root = mc;
					hero.flEat = true;
					hero.releaseGrap();

					hero.setSens(hero.sens);
					hero.initStep(Hero.FLY)
					hero.vx = -6;
					hero.vy -= medusa.vy;
					hero.weight = -4

					var hx = hero.x+map._x
					var hy = hero.y+map._y
					var hp = Tools.globalToLocal(medusa.head.eatZone,hx,hy)
					hero.x = hp.x;
					hero.y = hp.y;
					hero.updatePos();

					//
					KKApi.gameOver(stats);
				}
			}
		}

		// BODY

			// MAIN
			var trg = {
				x:medusa.x-40,
				y:medusa.y+50
			}
			medusaBody.toward(trg,0.2,100);

			var a = medusaBody.getAng(medusa);
			var dist = medusaBody.getDist(medusa);
			medusaBody.neck._rotation = a/0.0174 - medusaBody.root._rotation;
			medusaBody.neck._xscale = dist;
			medusaBody.root._rotation = (medusaBody.neck._rotation+45)*0.5

			// ARMS
			for( var i=0; i<medusaArms.length; i++ ){
				var arm = medusaArms[i];
				//
				arm.x = medusaBody.x;
				arm.y = medusaBody.y;
				//
				rotArm(arm.b);
				rotArm(arm.ab);
				moveToEdge(arm.ab,arm.b,255,1.57);
				moveToEdge(arm.h,arm.ab,240,0);


				// CHECK PLAT
				var hp = Tools.localToGlobal(arm.root,arm.h._x,arm.h._y)

				if(hp.y<Cs.mch && arm.h._currentframe==1)arm.h.gotoAndStop("2");
				if(hp.y>Cs.mch && arm.h._currentframe==2)arm.h.gotoAndStop("1");

				//Log.print(hp.y>Cs.mch);
				//Log.print(arm.h._currentframe);


				hp.x += 70-map._x;
				hp.y += 70-map._y;

				/*
				if( (hp.x-medusa.x< 200) ){
					arm.b.vr -= 0.2*Timer.tmod;
					arm.ab.vr -= 0.2*Timer.tmod;
				}
				*/
				if( hp.x+map._x>0 && hp.y+map._y<Cs.mcw ){

					/* DEBUG HAND POS
					var p = newPart("partLight")
					p.x = hp.x;
					p.y = hp.y;
					p.timer = 10+Math.random()*10;
					p.setScale(300);
					//*/
					for(var n=0; n<platList.length;n++){
						var pl = platList[n];
						if( hp.x>pl.x && hp.x<pl.x+pl.w && Math.abs(hp.y-pl.y)<16 ){
							arm.b.vr -= 6;
							pl.explode(hp.x);
							break;
						}
					}
				}
			}

			if(medusa.root._visible != true )return;

			// HEAD DESTRUCT PLAT
			var hray = 120
			for(var n=0; n<platList.length;n++){
				var pl = platList[n];
				if( medusa.x+hray>pl.x && medusa.x-hray<pl.x+pl.w &&  Math.abs(medusa.y-pl.y)<hray*1.2 ){
					pl.explode(medusa.x+hray+30+Math.random()*50);

				}
			}

			// RECAL HEAD
			if(medusa.y<80){

				for( var i=0; i<-medusa.vy; i++ ){

					var p = newPart("partDust");
					p.x = medusa.x + Math.random()*120;
					p.y = 16
					p.weight = 0.2+Math.random()*0.3;
					p.vx = (Math.random()*2-1)*6;
					p.timer = 10+Math.random()*30;
					p.fadeType = 0;
				}
				// RECAL
				medusa.y = 80;
				medusa.vy = 0;

			}

			// BAVE
			if(FL_BAVE && medusa.x+map._x+100>0){

				var bp = Tools.localToGlobal(downcast(medusa.root).machoire,90+Math.random()*30,43);
				bp.x += -map._x;
				bp.y += -map._y;


				var p = new Part(bdm.attach("partBave",0))//newPart("partBave");
				p.x = bp.x
				p.y = bp.y
				p.timer = 10+Math.random()*10;
				p.fadeType = 0;
				p.weight = 0.3+Math.random()*0.6
				p.vx = medusa.vx*0.5;
				p.vy = medusa.vy*0.5;
			}




	}
	function rotArm(m){
		m.vr += (Math.random()*2-1)*0.8*Timer.tmod;
		m.vr *= Math.pow(0.9,Timer.tmod);
		m.rot += m.vr*Timer.tmod;
		m.rot *= Math.pow(0.98,Timer.tmod);
		m._rotation = m.rot;
	}
	function moveToEdge(mc,mc2,d,ba){
		var angle = mc2._rotation*0.0174 + ba;
		mc._x = mc2._x + Math.cos(angle)*d;
		mc._y = mc2._y + Math.sin(angle)*d;
	}

	// MOUSE
	function mouseMove(){
		if(flMouseDead && mouseDeadTimer<=0){
			Mouse.show();
			flMouseDead = false;
		}
	}

	//
	function newPart(link){
		var p = downcast(new Part(mdm.attach(link,DP_PARTS)))
		return p;
	}
	function registerMc(mc){
		var px = mc._x;
		var py = mc._y;
		var sp = new Sprite(mc)
		sp.x = px;
		sp.y = py;
		sp.updatePos();
	}
	function spawnBonus(x,y,id){
		if(id==0)return;
		if( (id>=20 && hero.optList[id-20]) || (id==7 && hero.hp>0) ){
			id=1;
		}
		if(dif<500 && Cs.game.hero.hp==0 && Std.random(4)==0 ){
			id = 7;
		}


		var b = new Bonus(mdm.attach("bonus",DP_BONUS))
		b.x = x
		b.y = y
		b.setId(id);

	}

	function genScore(x,y,sc){
		KKApi.addScore(sc)
		var p = Cs.game.newPart("mcScore")
		p.x = x;
		p.y = y;
		p.vy = -1
		p.timer = 24
		downcast(p.root).field.text = string(KKApi.val(sc))
		Cs.glow(downcast(p.root).field,4,2,0)
	}

	// X Bave au levre
	// X Ajustementgameplay des mosntres
	// E Glow orange sur element decor passe devant soleil;
	// X Souris rebond marche pas;
	// X Scoring sur course
	// X Option pour recup ses habits
	// fleche bas pour lacher corde

	// Double strike
	// Poses rebonds a la nba jam

	// REMI
	// ajouter option invincible + kick

//{
}









