class base.Fever extends Base{//}

	// CONSTANTE


	// VARIABLE
	var level:int;

	function new(){
		super();
	}	
		
	function init(){

		super.init();
		level = 0;
		
		genGameList();
		
		setNext();
		
		//initStep(3)
	}


	
	
	function update(){
		super.update();
		
		
	}
	//

	function setNext(){
		super.setNext();
		if( flWin != null ){
			removeGameTimer();
			game.kill();
			if(!flWin){
				if(level>Cm.card.$fever.$max){
					Manager.queue.push({link:"congrat",infoList:[1000+level]});
					Cm.card.$fever.$max = level
				}
				Manager.queue.push({link:"gameOver",infoList:null});
				leave();
				return;
			}
		}
		nextGame = getRandomGame()
		newGame();
		level+=1
		dif = int(Math.min(dif+10,100))
	}

	/*
	function setWin(flag){
		super.setWin(flag);
		if(flWin){
			for( var i=0; i<8; i++ ){
				Manager.genFruit()
			}		
		}
	}
	*/
	
	
	// GAME

	//
	function getRandomGame(){
		var n = Std.random(gameFreqMax)
		var s = 0;
		for( var i=0; i<this.gameList.length; i++ ){
			s += this.gameList[i].freq;
			if( s > n ){
				return gameList[i]
			}
		}
		return gameList[0]
	}
	
	function genGameList(){
	
		super.genGameList();
			
		gameFreqMax = 0;
		for(var i=0; i<this.gameList.length; i++ )gameFreqMax += this.gameList[i].freq;
		

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
	
	