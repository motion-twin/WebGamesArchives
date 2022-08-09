class Game {//}



	static var FL_CHEAT = false;

	static var DP_INTER = 		12
	static var DP_PARTS = 		10
	static var DP_SHOTS = 		8
	static var DP_HERO = 		9
	static var DP_BADS = 		7
	static var DP_DRAW = 		5
	static var DP_UNDERPARTS =	3
	static var DP_BG =		2

	static var SCROLL_SPEED = 0.0001//5//10
	static var SCROLL_SPEED_MAX = 6//5//10
	static var PLASMA_CACHE = 100

	static var PM = 1;

	//
	var stats:{
		$k:Array<Array<int>>,
		$b:Array<Array<int>>
	}


	var gfxMode:int;
	var step:int;
	var lagTimer:float;
	var timer:float
	var flashouille:float;
	var pq:float;


	var sList:Array<Sprite>;
	var pList:Array<Part>;
	var shotList:Array<Shot>;
	var badsList:Array<Bads>;
	var bonusList:Array<Bonus>;

	var dm:DepthManager;
	var hero:Hero;

	var root:MovieClip;
	var bg:MovieClip;
	var shots:{>MovieClip,layer:Array<{>MovieClip, dm:DepthManager}> }
	var plasma:{>MovieClip,layer:Array<{>MovieClip, bmp:flash.display.BitmapData}>};

	var baseList:Array<MovieClip>
	var baseBmp:flash.display.BitmapData;

	var bt:{trg:float,timer:float,val:float}

	var knTurnRay:float;
	var knTurnDecal:float;
	var knTurnSpeed:float;
	var kidnappers:Array<Phys>;
	var chouquette:Phys;

	function new(mc) {

		Cs.game = this
		dm = new DepthManager(mc);
		root = mc;

		sList = new Array();
		shotList = new Array();
		badsList = new Array();
		bonusList = new Array();

		bg = dm.attach("mcBg",DP_BG)


		lagTimer = 0
		gfxMode = 4


		stats = {
			$k:[],
			$b:[]
		}

		initStep(0);
		initKeyListener();


	}

	function initStep(n:int){
		step = n
		switch(n){
			case 0:

				// CHOUQUETTE
				chouquette = new Phys(dm.attach("mcChouquette",DP_BADS))
				chouquette.x = Cs.mcw*0.5 - 5
				chouquette.y = Cs.mch+10
				chouquette.frict = 0.92

				// KIDNAPPERS
				knTurnRay = 10
				knTurnDecal = 0
				knTurnSpeed = 0
				kidnappers = new Array();
				for( var i=0; i<3; i++ ){
					var sp  = new Phys(dm.attach("mcBads",DP_BADS))
					sp.root.gotoAndStop("6");
					kidnappers.push(sp)
					sp.x  = -100
					sp.y  = -100
					sp.updatePos();
				}



				// BASE
				var pl = dm.attach("mcPlanet",DP_BG)
				pl._x = Cs.mcw
				pl._y = 160
				baseList = [ pl, dm.attach("base2",DP_BG), dm.attach("base1",DP_PARTS)];


				//
				pq = 0.5
				initPlasma();
				initShots();
				//initStep(1)
				break;
			case 1:
				hero = new Hero(dm.attach("mcHero",DP_HERO))
				break;
			case 2:

				break;
		}
	}

	//
	function main() {

		if(bt!=null)updateBulletTime();
		updateFlash();
		updatePlasma();

		// SPRITE
		var list = sList.duplicate();
		for( var i=0; i<list.length; i++ ){
			list[i].update();
		}

		//
		switch(step){
			case 0:

				if(chouquette.y>Cs.mch*0.5){
					chouquette.vy -= 0.3*Timer.tmod;
				}else{
					initStep(1)
				}
				knTurnRay += 0.35*Timer.tmod;
				updateKidnappers();
				timer = 60
				break;
			case 1:
				knTurnSpeed += 0.15*Timer.tmod;
				if(timer>0){
					/*
					if(Math.random()*10<1){
						var p = new Part(dm.attach("partText",DP_PARTS))
						p.x = chouquette.x+10 + Math.random()*20;
						p.y = chouquette.y-(8 + Math.random()*20);
						p.timer = 20;
						p.vy = -0.2
						p.fadeType = 0
						p.root.gotoAndStop("1")
						Cs.glow( p.root,2,5,0)
					}
					*/
					timer-=Timer.tmod;
				}else{
					chouquette.vy -= 0.8*Timer.tmod;
					if(chouquette.y<-100){
						while(kidnappers.length>0)kidnappers.pop().kill();
						chouquette.kill();
						initStep(2)
					}
				}
				updateKidnappers();
				Stykades.update();
				break;
			case 2: // PLAY
				Stykades.update();
				break;

		}

		// BG
		if(SCROLL_SPEED>0)updateScroll();

		//GFXMODE
		updateGfxMode();


	}

	function updateKidnappers(){
		for( var i=0; i<kidnappers.length; i++ ){
			var k = kidnappers[i]
			var c = i/kidnappers.length

			knTurnDecal = (knTurnDecal+knTurnSpeed*Timer.tmod)%628

			k.x = chouquette.x + Math.cos(knTurnDecal*0.01 +c*6.28 )*knTurnRay
			k.y = chouquette.y + Math.sin(knTurnDecal*0.01 +c*6.28 )*knTurnRay

		}
	}

	function updateGfxMode(){

		if(Timer.tmod>2 ){
			lagTimer+=Timer.tmod;
			if(lagTimer>16){
				lagTimer = -150
				switch(gfxMode){
					case 4:
						setPq(0.3)
						break;
					case 3:
						downcast(root)._quality  = "$LOW".substring(1)
						Bads.scoreDisplayLimit = 500;
						break;
					case 2:
						plasma.layer[0].bmp.dispose()
						plasma.layer[0].removeMovieClip();
						plasma.layer[0] = null;
						break;
					case 1:
						plasma.layer[1].bmp.dispose()
						plasma.removeMovieClip();
						break;
					case 0:
						break;
				}
				gfxMode--;
				PM *= 0.7
				Stykades.BADS_LIMIT = Math.max(10,Stykades.BADS_LIMIT-2)
			}
		}else{
			if(lagTimer>0){
				lagTimer-=Timer.tmod;
			}else{
				lagTimer+=Timer.tmod;
			}
		}
	}

	//
	function updateBulletTime(){

		var dif = bt.trg - bt.val
		bt.val += dif*0.1
		if( Math.abs(dif)<0.1 )	bt.val = bt.trg;
		Timer.tmod = bt.val
		if( bt.timer--<=0 )	bt.trg = 1;
		if( bt.val==1 ){
			bt = null;
			bg.filters = []
		}else{
			//if(Cs.game.root.filters.length>0)return;
			var fl = new flash.filters.ColorMatrixFilter();
			var c = 1-bt.val
			var sat = 0.3
			var inc = Math.random()*15
			fl.matrix = [
				1+c*sat,	0,		0,		0,	inc+200*c,
				0,		1+c*sat,	0,		0,	inc-50*c,
				0,		0,		1+c*sat,	0,	inc-50*c,
				0,		0,		0,		1,	0

			]
			bg.filters = [fl]
		}

	}
	function updateFlash(){
		if(flashouille!=null){
			var prc = Math.min(flashouille,100)
			flashouille *= 0.6
			if( flashouille < 2 ){
				flashouille = null
				prc = 0
			}
			Cs.setPercentColor(root,prc,0xFFFFFF)
		}
	}

	//SHOTS
	function initShots(){
		shots = downcast(dm.empty(DP_SHOTS));
		shots.layer = new Array();
		var dm = new DepthManager(shots)
		for( var i=0; i<3; i++ ){
			var mc = downcast(dm.empty(0))
			mc.dm = new DepthManager(mc)
			shots.layer.push(mc)
		}
	}


	// PLASMA
	function initPlasma(){
		plasma = downcast(dm.empty(DP_BG));
		plasma.layer = new Array();
		var dm = new DepthManager(plasma)
		for( var i=0; i<2; i++ ){
			var mc = downcast(dm.empty(0))
			mc.bmp = new flash.display.BitmapData(int(Cs.mcw*pq), int((Cs.mch+PLASMA_CACHE)*pq), true, 0x00000000 );
			mc.attachBitmap(mc.bmp,0)
			plasma.layer.push(mc)
			mc._y = -PLASMA_CACHE*pq

			if(i==0)mc.blendMode = BlendMode.ADD;
			//if(i==1)mc.blendMode = BlendMode.OVERLAY;

		}
		plasma._xscale = 100/pq;
		plasma._yscale = 100/pq;


	}
	function updatePlasma(){


		plasmaDraw(shots.layer[0],0)
		var bfl = new flash.filters.BlurFilter()

		for( var i=0; i<plasma.layer.length; i++ ){
			if(plasma.layer[i]!=null){
				var bmp = plasma.layer[i].bmp
				switch(i){
					case 0:
						var blp = Math.max(2*pq*Timer.tmod,1.5)
						bfl.blurX = blp
						bfl.blurY = blp
						bmp.applyFilter(bmp, bmp.rectangle, new flash.geom.Point(0,0), bfl );
						var inc = -2
						var ct = new flash.geom.ColorTransform( 1, 1, 1, 1, inc, inc, inc, 0)
						bmp.colorTransform( bmp.rectangle, ct );

						break;
					case 1:
						var blp = Math.max(10*pq*Timer.tmod,1)
						bfl.blurX = blp
						bfl.blurY = blp
						bmp.applyFilter(bmp, bmp.rectangle, new flash.geom.Point(0,0), bfl );

						var inc = -10
						var mult = 0.8
						var ct = new flash.geom.ColorTransform( 0.95, mult, mult, 1, inc, inc*2, inc*2, -10)
						bmp.colorTransform( bmp.rectangle, ct );


						//if(gfxMode>=3)Cs.zoom(bmp,1.02);

						break;

				}

				if(SCROLL_SPEED>0.2)bmp.scroll(0,int(SCROLL_SPEED*3*pq));
			}




		}
	}
	function plasmaDraw(mc,n){


		if(plasma.layer[n]==null)return;
		var bmp = plasma.layer[n].bmp



		var m = new flash.geom.Matrix();
		m.scale((mc._xscale/100)*pq, (mc._yscale/100)*pq)
		m.rotate(mc._rotation*0.0174)
		m.translate((mc._x)*pq,(mc._y+PLASMA_CACHE)*pq)

		var ct = new flash.geom.ColorTransform( 1, 1, 1, 1, 0, 0, 0, -255 + mc._alpha*2.55)
		var b = mc.blendMode

		bmp.draw( mc, m, ct, b, null, false )
		//*/
	}
	function plasmaPoint(x,y,color){
		var bmp = plasma.layer[0].bmp;
		bmp.setPixel32(int(x),int(y),color);
	}
	function setPq(n){
		pq = n;
		plasma.removeMovieClip();
		initPlasma();
	}


	//SCROLL
	function updateScroll(){
		if(gfxMode<3){

			SCROLL_SPEED*=0.95;
			if(SCROLL_SPEED<0.5)SCROLL_SPEED = 0;
		}else{
			if(step>1){
				SCROLL_SPEED = Math.min( SCROLL_SPEED+0.01*Timer.tmod, SCROLL_SPEED_MAX )
			}
		}

		bg._y += SCROLL_SPEED//*Timer.tmod;
		if(bg._y>0)bg._y-= 1800//-Cs.mch//+Cs.mch;


		for( var i=0; i<baseList.length; i++ ){
			var b = baseList[i]
			if(b._y==0)b._y=Cs.mch;
			b._y += SCROLL_SPEED
			if(b._y>Cs.mch+100){
				b.removeMovieClip()
				baseList.splice(i--,1)
			}
		}

	}

	// KEY
	function initKeyListener(){
		var kl = {
			onKeyDown:callback(this,onKeyPress),
			onKeyUp:callback(this,onKeyRelease)
		}
		Key.addListener(kl)

	}
	function onKeyPress(){
		var n = Key.getCode();

		if(FL_CHEAT){
			if(n>=96 && n<107 ){
				hero.addWeapon(n-96)
			}
			if(n>=49 && n<54 ){
				hero.addBox()
			}
			if(n>=54 && n<59 ){
				var bonus = new Bonus(null)
				bonus.x = Math.random()*Cs.mcw;
				bonus.y = -bonus.ray
			}
		}

		switch(n){
			case Key.CONTROL:
			case Key.SHIFT:
				hero.sacrifice(null)
				break;
		}

	}
	function onKeyRelease(){

	}



//{
}









