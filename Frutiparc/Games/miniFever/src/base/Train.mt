class base.Train extends Base{//}

	// VARIABLE
	var step:int;
	
	var sumList:Array<int>
	
	var vigList:Array<{>MovieClip,vig:MovieClip}>
	var pList:Array<{>MovieClip,pot:MovieClip,field:TextField}>
	

	function new(){
		super();
	}	
		
	function init(){

		super.init();
		genGameList();
		initSum()
		
		showPotions()
		
		initStep(0)
	}

	function initSum(){
		var list = Cm.card.$train.$record
		sumList = [0,0,0,0,0]
		for( var i=0; i<list.length; i++ ){
			var max = list[i]
			for( var n=0; n<max; n++ ){
				sumList[n]++;
			}
		}
	
	}
	
	function initStep(n){
		step = n;
		switch(step){
			case 0:
				dif = 0;
				initVignette();
				break;
			case 1:
				while(vigList.length>0)vigList.pop().removeMovieClip();
				newGame()
				break;
		}
	}

	
	
	
	function update(){
		super.update();
		switch(step){
			case 0:
				
				break;
			case 1:
				break;
		}
		
	}
	//

	function setNext(){
		super.setNext();
		if( flWin != null ){
			removeGameTimer();
			game.kill();
			if(!flWin || dif == 100 ){
				if(Cm.trainResult(nextGame.id,dif)){
					leave();
				}
				return;
			}
		}
		//nextGame = getRandomGame()
		dif = int(Math.min(dif+5,100))
		newGame();
		
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
	
	// INIT VIGNETTE
	function initVignette(){
		var m = 10
		var num = 10
		var size = (Cs.mcw-2*m)/num
		vigList = new Array();
		for( var i=0; i<gameList.length; i++ ){
			var game = gameList[i]
			var mc = downcast(dm.attach("mcTrainVig",1))
			mc._xscale = 20//20*100/54
			mc._yscale = 20//20*100/54
			mc._x = m+(i%num)*size
			mc._y = m+Math.floor(i/num)*size
			//if( Cm.card.$play[game.id] > Cm.TRAIN_LIMIT-1 )
			if( Cm.card.$train.$record[i] != null ){
				
				mc.stop();
				mc.vig.gotoAndStop(string(game.id+1))
				initVig(mc,game)
				
			}else{
				mc.gotoAndStop("2")
			}
			vigList.push(mc)
		}	
	}

	
	function initVig( mc:MovieClip ,game:{id:int,link:String} ){
		var me = this;
		mc.onPress = fun(){
			me.nextGame = game
			me.initStep(1)
		}
		
		mc.onRollOver = fun(){
			me.showInfo(game.id)
		}
		
		mc.onRollOut = fun(){
			me.hideInfo(game.id)
		}
		
		mc.onDragOut = mc.onRollOut
		
	}
	
	function showInfo(id){
		hidePotions();
		//
		pList = new Array();
		//Log.trace("bla!")
		for( var i=0; i<5; i++ ){
			var mc = downcast(dm.attach("mcPotion",2))
			mc._x = 10+i*18
			mc._y = Cs.mch-9
			if( Cm.card.$train.$record[id] > i ){
				mc.gotoAndStop("2")
				mc.pot.gotoAndStop(string(i+1))
			}else{
				mc.stop();
			}
			pList.push(mc)
		}

		
	}
	
	function hideInfo(id){
		while(pList.length>0)pList.pop().removeMovieClip();
		showPotions();
	}
	
	function showPotions(){
		pList = new Array();
		for( var i=0; i<5; i++ ){
			var mc = downcast(dm.attach("mcPotion",2))
			mc._x = 10+i*48
			mc._y = Cs.mch-9
			mc.gotoAndStop("3")
			mc.pot.gotoAndStop(string(i+1))
			mc.field.text = string(sumList[i]);
			
			pList.push(mc)
		}	
	}
	
	function hidePotions(){
		while(pList.length>0)pList.pop().removeMovieClip();
	}
	
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
		
		
		

	}
	
	
	

//{	
}	
	