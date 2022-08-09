class base.Chrono extends Base{//}

	// CONSTANTE


	// VARIABLE
	var level:int;
	var step:int;
	var maxGame:int;
	var index:int;
	var result:int;
	
	var timer:float;
	var startTime:int;

	var console:{>MovieClip,fieldTime:TextField,wheel:{>MovieClip, h:MovieClip}};
	
	function new(){
		super();
	}	
		
	function init(){
		super.init();
		level = 0;
		dif = 50
		genGameList();

		initStep(0)
		startTime = Std.getTimer();
	}

	function initStep(n){
		step = n
		switch(step){
			case 0:
				flWin  = null;
				attachConsole();
				timer = 40
		
				break;
			case 1:
				removeConsole();
				nextGame = getRandomGame()
				newGame();			
				break;
			case 2:
				attachConsole();
				timer = 160
				result = Std.getTimer()-startTime
				console.fieldTime.text = Cs.getTimeString(result)
				break;
		}
	}

	
	function update(){
		
		super.update();
		switch(step){
			case 0:
				console.fieldTime.text = Cs.getTimeString(Std.getTimer()-startTime)
				timer-=Timer.tmod;
				if(timer<=0){
					fadeOut(0xFFFFFF)
					initStep(10)
				}
				break;
			case 1:
				// GAME
				break;
			case 2:
				console.fieldTime._visible = timer%16 < 4
				timer-=Timer.tmod;
				if(timer<=0){
					Cm.endChrono(result)
					leave();
				}
				break;					
		}		
		
	}
	//

	function setNext(){
		super.setNext();
		if( flWin != null ){
			if(flWin){
				gameList.splice(index,1)
				incDif(10)
			}else{
				incDif(-10)
			}
			removeGameTimer();
			game.kill();
			if( gameList.length > 0 ){
				initStep(0)
			}else{
				initStep(2)
			}
		}else{
			initStep(1)
		}
	}

	function incDif(inc){
		dif = int(Cs.mm(0,dif+inc,90))
	}
	

	
	// GAME
	function newGame(){
		genGame(nextGame.link);
		Cm.incPlay(nextGame.id)
		initGameTimer(game.gameTime);

	}
	
	// CONSOLE
	
	function attachConsole(){
		console = downcast(dm.attach("mcChronoConsole",8))
		console._x = Cs.mcw*0.5
		console._y = Cs.mch*0.5
		var co =  downcast(console)
		
		// DIF
		for(var i=0; i<9; i++){
			var mc = Std.getVar(console,"$d"+i)
			if( dif*0.09 >= i ){
				mc.gotoAndStop("2")
			}else{
				mc.gotoAndStop("1")
			}
		}
		
		// HALF
		var c = gameList.length/maxGame
		console.wheel.h._rotation = -c*180
		
	}
	
	function removeConsole(){
		console.removeMovieClip();

	};
	
	// UPDATE TIMEFIELD

	
	//
	function getRandomGame(){
		index = Std.random(gameList.length)
		var game = gameList[index];
		return game;
	}
	
	function genGameList(){
		super.genGameList();
		//* HACK
		while(gameList.length>5){
			gameList.splice(Std.random(gameList.length),1)
		}
		//
		maxGame = gameList.length;
	}
	

	
	
	/*
		A mettre dans la base :
	
		- TourneBoule
		- phrase d'encouragement.
		- vie restante.
		- numero de partie :
		? ratio temps de chaque jeux
	
	
	*/
	
//{	
}	
	
	