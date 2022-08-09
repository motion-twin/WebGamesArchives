class base.Dungeon extends base.Aventure{//}

	var difficulty:int;
	var heightTimer:float;
	var heightCycle:float;
	
	var wSpeed:float;
	
	var elevator:MovieClip;
	var ws:{>MovieClip,r0:MovieClip,r1:MovieClip,r2:MovieClip};
	var wsb:{>MovieClip,r0:MovieClip,r1:MovieClip,r2:MovieClip};
	
	var diam:sp.Part;
	var diamGlow:sp.Part;
	
	function new(){
		super();
		difficulty = Cm.card.$dungeon.$lvl//Std.random(5);
		Cm.card.$stat.$game[2]++
		
	}
	
	function init(){
		Cm.incKey(-1)
		if( fi.isReadyForBattle() ) initFaerieInterface();
		super.init();
		launch();
	}
	
	
	function initGame(){
		super.initGame()
		game.colMax = 3+Cm.card.$dungeon.$loop
		
		game.width = 132
		game.height = 240
		
		initFaerie();
		game.setPieceSpeed( 0.03 + level*0.001 )
		
		initElevator();
		if( level < 9 ){
			heightCycle = 250
		}else{
			heightCycle = 500
		}
		
		heightTimer = heightCycle*0.5
		wSpeed = 0;
		
	}
	
	function initSkin(){
		super.initSkin();
		intUp = dm.attach("interfaceDungeon",Base.DP_SKIN_UP)
		intMiddle = dm.attach("interfaceDungeon",Base.DP_SKIN_MIDDLE)
		intDown = dm.attach("interfaceDungeon",Base.DP_SKIN_DOWN)
		intUp.gotoAndStop("1")
		intMiddle.gotoAndStop("2")
		intDown.gotoAndStop("3")	
	}
	
	function initFaerieInterface(){
		super.initFaerieInterface();
		intFace.setSkin(2)
		intFace.margin = 10
		intLife.skinFrame = 2
		intMana.skinFrame = 2
	}	
	
	function initElevator(){
		
		elevator = game.dm.attach( "mcElevator", Game.DP_SPRITE_FRONT )
		elevator._x = 8
		elevator._y = Cs.mch
		
		ws = downcast( game.dm.attach( "mcWheelSystem", Game.DP_SPRITE_FRONT ) )
		ws._x = 0
		ws._y = Cs.mch
		
		wsb = downcast( game.dm.attach( "mcWheelSystemBack", Game.DP_UNDER ) )
		wsb._x = 0
		wsb._y = Cs.mch		
	}

	//
	function initStep(n){
		super.initStep(n)
		switch(step){

			case 1:  // OPENING 2 - FAERIE
				if( level == 9 ){
					for( var i=0; i<2; i++ ){
						game.addImp( Cs.game.width*0.5, Cs.game.height*0.5, difficulty )
					}
				}
				break;
			case 21:
				if(Cm.card.$dungeon.$loop>0){
					initStep(22);
					break
				}
				diam = game.newPart("mcDiamant",null);
				diam.skin.gotoAndStop(string(difficulty+1));
				diam.x = Cs.game.width*0.5;
				diam.y = -20;
				diam.vity = 0.5;
				diam.friction = 1;
				diam.init();
				
				diamGlow = game.newPart("partFlipGlow",Game.DP_PART2);
				diamGlow.x = diam.x;
				diamGlow.y = diam.y;
				diamGlow.scale = 40
				diamGlow.init();
				
				
				mf.trg = upcast(diam)
				mf.flForceWay = true;
				break;
				
				
			case 22:
				flashInfo = {prc:1, frict:1.1, color:0xFFFFFF}
				diam.vity = 0;
				break;
		}
	}
	
	//

	//
	function update(){
		super.update();
		

		
		switch(step){
			case 1:
				if( game.step == 2 ){
					heightTimer -= Timer.tmod
				}
				break;
			case 21:
				lightDiam()
				diamGlow.y = diam.y;
				if( diam.y > Cs.game.height*0.5 ){
					
					initStep(22)
				}
				break;
			case 22:
				lightDiam();
				if( flashInfo.prc == 100){
					flashInfo = null;
					Manager.fadeSlot( "menu", Cs.game.width*0.5, Cs.game.height*0.5 )
					
					//game.kill();
					//initStep(11)

				}	
				break;
		}
		
		if( heightTimer < 0 && step < 21 ){
			wSpeed += 1*Timer.tmod
		}
		
		if( wSpeed > 0.1 ){
			wSpeed *= Math.pow(0.95,Timer.tmod)
			
			ws.r0._rotation += wSpeed
			ws.r1._rotation += wSpeed*2
			ws.r2._rotation -= wSpeed*2
			
			wsb.r0._rotation -= wSpeed*0.66
			wsb.r1._rotation -= wSpeed*1.25
			wsb.r2._rotation += wSpeed*2						
		}
		
		
	}
	
	function lightDiam(){
		if(diam==null)return;
		for( var i=0; i<3; i++ ){
			var p = Cs.game.newPart( "partRay", Game.DP_PART2 )
			p.x = diam.x;
			p.y = diam.y;
			p.vity = diam.vity
			p.vitr = (Math.random()*2-1)*10
			p.fadeTypeList = [4]
			p.timer = 15+Math.random()*10
			p.init();
			p.skin._rotation = Math.random()*360
			p.skin._xscale = 20+Math.random()*100
		}
	}
	
	// WIN
	function setWin(flag){
		super.setWin(flag)
		if(flag){
			if(level==9){
				game.initStep(10)
				initStep(21)
				Cm.winDungeon();
				if( !mf.flDeath ){
					mf.fi.incExp( 100*difficulty )
				}
				
			}else{
				level+=1;
				if( !mf.flDeath ){
					mf.fi.incExp( level*(difficulty+1) )
				}			
				initStep(2);
			}
		}
	}
	
		
	// ON
	function onLevelClear(){
		super.onLevelClear();
		setWin(true)
	}
	
	function onNewTurn(){
		super.onNewTurn();
		game.updatecolorList();
		if( heightTimer <= 0 && wSpeed > 8 ){
			heightTimer = heightCycle;
			for( var x=0; x<game.xMax; x++ ){
				for( var y=0; y<game.yMax; y++ ){
					var e = game.grid[x][y]
					if( e!= null ){
						game.removeFromGrid(e)
						e.py--;
						game.insertInGrid(e)
						e.updatePos();
						e.update();
					}
				}
			}
			game.yMax--;
			elevator._y = game.getY(game.yMax) 
		}
	}	
	
	//
	function getLevel(){

		// HAUTEUR	// 5 DIF
		var dif = level * ( 0.3+(difficulty*0.1) );
				
		var special = 1
		if(dif%1>0.5){
			special = 2
		}
		
		var h = Math.floor(dif)+2;
	
		if( level == 9 )h--;
		
		// GENERATION
		var lvl = new Array();
		for(var x=0; x<game.xMax; x++){
			lvl[x] = new Array();
			for(var y=0; y<game.yMax; y++){
				if( y >= game.yMax-h ){
					var et = Cs.E_TOKEN;
					var n = special;
					if( y == game.yMax-h ){
						et = Cs.E_STONE
						n = 2
					}
					lvl[x][y] = { et:et, n:n }
				}
			}
		}
		return lvl
	}
	
	
//{	
} 






















