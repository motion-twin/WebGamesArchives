class base.Rainbow extends base.Aventure{//}


	var intWheel:inter.Wheel;
	
	var item:{>MovieClip,vy:float};
	var itemGlow:sp.Part;

	var dTimer:float;
	var intWheelSpeed:float;
	
	function new(){
		super();
		Cm.card.$stat.$game[3]++
	}
	
	function init(){
		if( fi.isReadyForBattle() ) initFaerieInterface();
		initWheel();
		super.init();
		launch();
	}
	
	
	function initGame(){
		super.initGame()
		
		game.width = 132
		game.height = 226
		game.colMax = 8;
		
		initFaerie();
		
		game.setPieceSpeed( 0.03 + level*0.001 )
		
	}
	
	function initSkin(){
		super.initSkin();
		intUp = dm.attach("interfaceRainbow",Base.DP_SKIN_UP)
		intMiddle = dm.attach("interfaceRainbow",Base.DP_SKIN_MIDDLE)
		intDown = dm.attach("interfaceRainbow",Base.DP_SKIN_DOWN)
		intUp.gotoAndStop("1")
		intMiddle.gotoAndStop("2")
		intDown.gotoAndStop("3")	
	}
	
	function initFaerieInterface(){
		super.initFaerieInterface();
		intFace.setSkin(3);
		intFace.margin = 10;
		intLife.skinFrame = 3;
		intMana.skinFrame = 3;
		intFace.mx = 10;
		intLife.mx = 10;
		intMana.mx = 10;
	}	
	
	function initWheel(){
		intWheel = new inter.Wheel(this)
		intWheel.init();
		intWheel.setCount(100)
		intWheel.mx = 10
		
		intWheel.setPrize(Cm.card.$rainbow.$it);
		

		
		//intWheel.setSkin(3);
	}
	

	//
	function initStep(n){
		super.initStep(n)
		//Manager.log("initStep("+n+")")
		switch(step){

			case 1:  // OPENING 2 - FAERIE
				break;
			
			case 21:
				dTimer = 20
				intWheelSpeed = 0.5
				break;			
			case 22:
				grab(intWheel.prize);
				Cm.removeRainbow();
				dTimer = 0;
				break;
			case 23:
				var it = Item.newIt(intWheel.prize)
				item = downcast(it.getPic(game.dm,Game.DP_PART))
				item._x = Cs.game.width*0.5;
				item._y = Cs.game.height+20
				item._xscale = 20
				item._yscale = 20
				item.vy = -5.5
			
				itemGlow = game.newPart("partFlipGlow",Game.DP_PART2);
				itemGlow.x = item._x;
				itemGlow.y = item._y;
				itemGlow.scale = 40
				itemGlow.init();
				
				///mf.trg = upcast(item)
				//mf.flForceWay = true;
				break;

		}
	}
	
	//
	function update(){
		super.update();

		switch(step){
			case 1:

				break;
			
			case 21:
				
				if(dTimer < 0 ){
					intWheelSpeed *= 1.1
					intWheel.skin._x += intWheelSpeed
					if( intWheel.skin._x > Cs.mcw )initStep(22);
					
				}else{
					dTimer-=Timer.tmod
				}
				break;
			case 22:
				dTimer += 5*Timer.tmod
				var list = game.eList;
				for( var i=0; i<list.length; i++ ){
					var e = list[i]
					if(e.x+e.y*1.1<dTimer){
						for( var n=0; n<3; n++ ){
							var p = Cs.game.newPart("partHoriLight",Game.DP_PART2)
							var a = Math.random()*6.28
							p.x = e.x + game.ts*0.5 + Math.cos(a)*4;
							p.y = e.y + game.ts*0.5 + Math.sin(a)*4;
							var speed = (Math.random()*2-1)*10
							p.vitx = -speed
							p.vity = speed
							p.timer = 10+Math.random()*10
							p.init()
							p.skin._xscale = 100+Math.random()*200
							p.skin._rotation = -45
						}
						e.kill();
					}
				}
				if( list.length == 0  ){
					
					initStep(23)
				}
				break;
				
			case 23:
				item._y += item.vy
				item.vy *= Math.pow(0.97,Timer.tmod)
				itemGlow.y = item._y
				if( item.vy>-0.1 ){
					tryToClose();
				}
				break;
			
			
		}
		

		
	}
	
	
	// WIN
	function setWin(flag){
		super.setWin(flag)
	}
	
	
	// ON
	function onNewTurn(){
		super.onNewTurn();
		intWheel.incCount(-1.15);
		if( intWheel.count == 0 ){
			game.initStep(10)
			initStep(21)
			if( !mf.flDeath ){
				mf.fi.incExp(100)
			}	
		}
	}	
	
	//
	function getLevel(){
		var lvl = new Array();
		return lvl
	}
	
	
	
	
//{	
} 






















