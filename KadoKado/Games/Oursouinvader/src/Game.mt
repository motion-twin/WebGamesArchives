class Game{//}


	static var FL_CHEAT =false//true

	static var BASESPEED = 2;
	static var MAXSPEED = 10;
	var dm:DepthManager;
	var root:MovieClip;

	volatile var mSpeed:float;
	var fValue:float;

	var xmRange:int;
	var ymRange:int;

	var bg:MovieClip;
	var hero:Ship;
	var mechant:Monster;

	var direction: float;
	volatile var totalMonster: int;

	var m2move:int;
	var mIndex:int;
	var nbIntro:int;
	var flTurn:bool;

	var shotList:Array<Shot>;
	var monsterList:Array<Monster>
	var sList:Array<Sprite>;
	var bonusList:Array<Sprite>;
	var pList:Array<Part>;


	volatile var difficulty:float;
	volatile var diffLevel:float;
	var lagTimer:float;
	var mcLim:MovieClip;

	static var MONSTERLEVELMAX=4;

	static var MONSTERS = null;

	var step:int;
	var mcWave:{>MovieClip,bx:float,field:TextField};

	var burb:Array<{>MovieClip,bmp:flash.display.BitmapData, h:float}>


	//debug
	volatile var zeLevel:int;
	var flReady:int;

	function new(mc) {

		Cs.game = this
		root = mc;
		dm = new DepthManager(root);

		MONSTERS = [
			{ mc:"mcBadBoy"	, diff:1},
			{ mc:"mcOcto"		, diff:9},
			{ mc:"mcBomber"	, diff:35},
			{	mc:"mcOyster"	, diff:69}
		];

		mIndex = 0;
		mSpeed = BASESPEED ;
		fValue = 4 ;

		xmRange = 6;
		ymRange = 4;
		totalMonster = xmRange*ymRange;

		//Difficulté
		difficulty = xmRange*ymRange;
		diffLevel = difficulty;


		flTurn = false;

		direction = 1;

		sList = new Array();
		pList = new Array();
		shotList = new Array();
		monsterList = new Array();
		bonusList = new Array();
		//debug
		flReady = 0;
		lagTimer = 0;


		bg = dm.attach("mcBg",0)
		initBurbulisseur();

		hero = new Ship( dm.attach("mcHero",1) )
		mcLim = dm.attach("mcLimit",1)
		mcLim._y = 220//240
		mcLim.stop();

		zeLevel = -1;
		initStep(0)
	}


/*************************************************
*											MAIN
**************************************************/


	function initStep(n:int){
		step = n
		switch(step){
			case 0: // SPAWN
				nbIntro = 0
				initMonsters()
				hero.initState();

				// CLEAN
				while(shotList.length>0)shotList.pop().kill();
				while(bonusList.length>0)bonusList.pop().kill();

				// LEVEL DISPLAY
				if(mcWave!=null)mcWave.removeMovieClip();
				mcWave = downcast(dm.attach("mcLevelDisplay",8))
				mcWave.bx = 100

				var gfl = new flash.filters.GlowFilter()
				gfl.blurX = 4
				gfl.blurY = 4
				gfl.strength = 50
				gfl.color = 0xFFFFFF

				var fl = new flash.filters.BlurFilter()
				fl.blurX = mcWave.bx
				fl.blurY = 0
				mcWave.filters =  [gfl,fl]
				mcWave.field.text = "VAGUE "+(zeLevel+1)


				//initStep(1)
				break;
			case 1: // GAME
				for( var i=0; i<monsterList.length; i++ ){
					var sp = monsterList[i]
					sp.x = sp.tx;
					sp.y = sp.ty;
					sp.vx = 0;
					sp.vy = 0;
					sp.step = 1
				}
				break;
		}
	}

	function main() {
		// SPRITE
		moveSprites();

		updateBurbulisseur();
		updateGfxMode();

		switch(step){
			case 0: // SPAWN
				if(nbIntro >= monsterList.length)initStep(1);
				mcWave.bx *= 0.75;
				if(mcWave.bx<2)mcWave.bx=0;
				var a = mcWave.filters;
				var fl:flash.filters.BlurFilter = downcast(a[1]);
				fl.blurX = mcWave.bx;
				mcWave.filters = a;

				break;
			case 1: // GAME
				if(mcWave!=null){
					mcWave.bx += 1;
					mcWave.bx *= 1.5;
					var a = mcWave.filters;
					var fl:flash.filters.BlurFilter = downcast(a[1]);
					fl.blurX = mcWave.bx;
					mcWave.filters = a;
					if(mcWave.bx>200){
						mcWave.removeMovieClip();
						mcWave = null();
					}
				}

				moveMonster();

				if(FL_CHEAT)updateCheat();

				break;
		}


	}

	function moveSprites(){
		var list = sList.duplicate();
		for( var i=0; i<list.length; i++ ){
			list[i].update();
		}
	}


/*************************************************
*										Monster Handler
**************************************************/
	function moveMonster(){
		var flTurn = false
		var ymax = 0
		for ( var i = 0; i < monsterList.length; i++) {
			var monster = monsterList[i]
			if(!monster.flKamikaze){
				monster.x += direction*mSpeed*Timer.tmod ;
				if ( ( monster.x < ( 0 + monster.ray) ) ||( monster.x > ( 300 - monster.ray) ) ){
					flTurn = true ;
					if (mSpeed< MAXSPEED ) {
						mSpeed += (mSpeed/monsterList.length)/5;
					}
				}
				ymax = Math.max(monster.y,ymax)
			}
		}
		if(flTurn){
			direction *= -1
			for ( var i = 0; i < monsterList.length; i++) {
				var monster = monsterList[i]
				monster.y += fValue;
			}
		}
		var warningMargin = 20
		if( ymax+warningMargin>mcLim._y && mcLim._currentframe==1){
			mcLim.gotoAndStop("2");
		}
		if( ymax+warningMargin<mcLim._y && mcLim._currentframe==2){
			mcLim.gotoAndStop("1");
		}
		if (monsterList.length==0){
			initStep(0);
		}
	}

	function initMonsters() {
		zeLevel++;
		difficulty = difficulty + (difficulty/4) + (Math.round(Math.random()*(difficulty))) ;
		// init la speed ( pk pas augmenter au fur et a mesure...)
		mSpeed = BASESPEED ;
		waveGenerator();
	}

	function waveGenerator(){

		if ( zeLevel < 12){
			//var waveTest = Math.round(Math.random()*4);
			var waveTest = 1+Std.random(4);
			switch (waveTest)    {
			     case 1:
				  waveMirror();
				  break;
			     case 2:
				   waveSide();
				   break;
			     case 3:
				   waveHole();
				   break;
			     case 4:
				   waveTop();
				   break;
			}
		}else {

			waveBoss();
		}


	//waveNormal();
	//waveMirror();
	//waveSide();
	//waveHole();
	//waveTop();


	}

	/******************************************************************************** WAVE NORMAL*/
	function waveNormal(){
			diffLevel = difficulty;
			for (var y = 0 ;  y < ymRange; y++) {
				for ( var x = 0; x < xmRange; x++) {
					var nbMonsterLeft = totalMonster - monsterList.length;
					putMonster(MONSTERLEVELMAX-1,nbMonsterLeft,x,y);
				}
			}
		}

	function putMonster(mLevel:int,nbMonsterLeft:int,x:int,y:int):void{
			var diffLeft:int;
			if ( mLevel == 0 ){
				diffLeft = (MONSTERS[mLevel].diff)*(nbMonsterLeft-1) + (MONSTERS[mLevel].diff) ;
			}else {
				 diffLeft = (MONSTERS[mLevel-1].diff)*(nbMonsterLeft-1) + (MONSTERS[mLevel].diff) ;
			}
			if ( diffLeft <= diffLevel ) {
				initMonster(MONSTERS[mLevel].mc,mLevel,x,y);
				diffLevel = diffLevel - MONSTERS[mLevel].diff;
			}else{
				putMonster(mLevel-1,nbMonsterLeft,x,y);
			}
		}

	/******************************************************************************** WAVE MIRROR*/
	function waveMirror(){
			diffLevel = Math.round( difficulty / 2 );
			var nbMonsterLeft = Math.round( totalMonster / 2);
			for (var y = 0 ;  y < ymRange; y++) {
				for ( var x = 0; x < ( xmRange/2 ); x++) {
					if ( ( x != 0 ) || ( y != 0 ) ){
						if ( ( x != 0 ) || ( y != 3 ) ){
							putMonsterMirror(MONSTERLEVELMAX-1,nbMonsterLeft ,x,y);
							nbMonsterLeft--;
						}
					}
				}
			}
		}

	function putMonsterMirror(mLevel:int,nbMonsterLeft:int,x:int,y:int):void{
			var diffLeft:int;
			if ( mLevel == 0 ){
				diffLeft = (MONSTERS[mLevel].diff)*(nbMonsterLeft-1) + (MONSTERS[mLevel].diff) ;
			}else {
				 diffLeft = (MONSTERS[mLevel-1].diff)*(nbMonsterLeft-1) + (MONSTERS[mLevel].diff) ;
			}
			if ( diffLeft <= diffLevel ) {
				var xprime = (xmRange - 1  - x);
				if ( y == 3 ){
					initMonster(MONSTERS[0].mc,0,x,y);
					initMonster(MONSTERS[0].mc,0,xprime,y);
					diffLevel = diffLevel - MONSTERS[mLevel].diff;
				}else{
					initMonster(MONSTERS[mLevel].mc,mLevel,x,y);
					initMonster(MONSTERS[mLevel].mc,mLevel,xprime,y);
					diffLevel = diffLevel - MONSTERS[mLevel].diff;
					}


			}else{
				putMonsterMirror(mLevel-1,nbMonsterLeft,x,y);
			}
		}

	/******************************************************************************** WAVE SIDER */

	function waveSide(){
		diffLevel = Math.round( difficulty / 2 );
			var nbMonsterLeft = Math.round( totalMonster / 2) - 5;
			for ( var x = 0; x < ( xmRange/2 ); x++) {
				for (var y = 0 ;  y < ymRange; y++) {
					if ( ( x != 1 ) ){
						if ( ( x != 2 ) || ( y != 3 ) ){
							putMonsterMirror(MONSTERLEVELMAX-1,nbMonsterLeft ,x,y);
							nbMonsterLeft--;
						}
					}
				}
			}
			putMonsterMirror(MONSTERLEVELMAX-1,nbMonsterLeft ,1,3);
		}

	/******************************************************************************** WAVE SIDER */
	function waveHole(){
		diffLevel = Math.round( difficulty / 2 );
			var nbMonsterLeft = Math.round( totalMonster / 2) - 2;
			for ( var x = 0; x < ( xmRange/2 ); x++) {
				for (var y = 0 ;  y < ymRange; y++) {
					if ( ( x != 2 ) || ( y != 3 ) ){
						if ( ( x != 0 ) || ( y != 0 ) ){
							putMonsterMirror(MONSTERLEVELMAX-1,nbMonsterLeft ,x,y);
							nbMonsterLeft--;
						}
					}

				}
			}
		}

	/******************************************************************************** WAVE TOP */
	function waveTop(){
		diffLevel = Math.round( difficulty / 2 );
			var nbMonsterLeft = Math.round( totalMonster / 2) - 1;
			for (var y = 0 ;  y < ymRange; y++) {
				for ( var x = 0; x < ( xmRange/2 ); x++) {
					if ( ( y != 1 ) || ( x != 0 ) ){
							putMonsterMirror(MONSTERLEVELMAX-1,nbMonsterLeft ,x,y);
							nbMonsterLeft--;
					}
				}
			}
		}

	function waveBoss(){
		var monster = new Monster(dm.attach("mcBoss",8),5);
		monster.tx = 120;
		monster.ty = 60;

		diffLevel = 240;
		var nbMonsterLeft = 4;
		for ( var x = 0; x < ( xmRange/2 ); x++) {
			for (var y = 0 ;  y < ymRange; y++) {
				if ( x != 1 ){
					if ( x != 2 ) {
						putMonsterMirror(MONSTERLEVELMAX-1,nbMonsterLeft ,x,y);
						nbMonsterLeft--;
					}
				}
			}
		}
	}

	function initMonster(mc,mType,x,y){
		var monster = new Monster(dm.attach(""+mc+"",mType+5),mType+1);
		monster.tx = Cs.MARGE + x*40 ;
		monster.ty = Cs.MARGE + y*35 ;
	}


	// FX
	function initBurbulisseur(){
		burb = []
		for( var i=0; i<2; i++ ){
			var mc = downcast(dm.empty(0));
			mc.h = 90+i*20
			mc.bmp = new flash.display.BitmapData(Cs.mcw,mc.h,true,0x00000000);
			mc.attachBitmap(mc.bmp,0)
			mc._y = Cs.mch+30-mc.h
			burb.push(mc)
		}
	}
	function updateBurbulisseur(){
		var bubble = dm.attach("mcSmallBubble",0)
		for( var i=0; i<burb.length; i++ ){
			var mc = burb[i];
			if( Math.random()/Timer.tmod < 1/(i+1) ){
				var m = new flash.geom.Matrix();
				var sc = (0.6+Math.random()*0.8)*(i*0.5+0.5)
				m.scale(sc,sc)
				m.translate(Math.random()*Cs.mcw, mc.h-20)
				mc.bmp.draw(bubble,m,null,null,null,null)
			}
			var inc = 0
			var mult = 1
			var ct = new flash.geom.ColorTransform( mult, mult, mult, 1, inc, inc, inc, -(3+i))
			mc.bmp.colorTransform( mc.bmp.rectangle, ct );
			mc.bmp.scroll(0,-1*(i+1))
		}
		bubble.removeMovieClip();

		if( Math.random()/Timer.tmod < burb.length*0.1 ){
			var p = new Part( dm.attach("mcSmallBubble",8) );
			p.x = Math.random()*Cs.mcw;
			p.y = Cs.mch+40;
			p.vy = -(1+Math.random()*2)
			p.setScale(50+Math.random()*50);
			p.timer = 40+Math.random()*40;
			p.fadeType = 0
		}



	}
	function updateGfxMode(){

		if(Timer.tmod>1.4 ){
			lagTimer+=Timer.tmod;
			if(lagTimer>16){
				lagTimer = -150
				var mc = burb.pop()
				mc.bmp.dispose();
				mc.removeMovieClip();
			}
		}else{
			if(lagTimer>0){
				lagTimer-=Timer.tmod;
			}else{
				lagTimer+=Timer.tmod;
			}
		}
	}

	function dispScore(sc,x,y){
		var p = new Part(dm.attach("mcScore",8))
		p.x = x;
		p.y = y;
		p.vy = -3.5
		p.frict = 0.95
		downcast(p.root).field.text = KKApi.val(sc);
		p.timer = 30;

		var gfl = new flash.filters.GlowFilter()
		gfl.blurX = 2
		gfl.blurY = 2
		gfl.strength = 5
		gfl.color = 0xFFFFFF

		p.root.filters = [gfl]

	}

	// CHEAT
	function updateCheat(){
		if ( flReady > 0 ) flReady--;
		if ( (Key.isDown(Key.ENTER)) && ( flReady == 0 )){
			flReady = 10;
			var tempList = monsterList.duplicate();
			monsterList = new Array();
			for (var i = 0; i < tempList.length ; i++){
				tempList[i].explode();
			}
		}
	}


	/***************************************************************************************** DUMP **/
	// SPACE INVADERS move algo
	function moveMonster2(){
		var wSize = 10;
		for (var i = 0; i < wSize ; i++){
			var monster = monsterList[mIndex+i];
			monster.x += direction*5//mSpeed ;
			if ( ( monster.x < ( 0 + monster.ray) ) ||( monster.x > ( 300 - monster.ray) ) ){
				flTurn = true ;
			}
			if ( mIndex+i == monsterList.length-1 ){
				if(flTurn){
					direction *= -1;
					for ( var n = 0; n < monsterList.length; n++) {
						monsterList[n].y += fValue;
					}
				}
				flTurn = false;
				mIndex = -(i+1);
				for(var n=0; n<monsterList.length; n++ ){
					if(monsterList[n].flDeath){
						monsterList.splice(n--,1)
					}
				}
			}
		}
		mIndex +=wSize;
		//if (nbMonsters != monsterList.length ){Log.trace("yeau")};
	}




//{
}









