class base.Forest extends base.Aventure{//}


	var mcMap:{
		>MovieClip,
		scroller:MovieClip,
		list:Array<{>MovieClip,field:TextField,fieldTitle:TextField}>,
		sMax:float
	};
	
	function new(){
		super();
		Cm.card.$stat.$game[0]++
		
	}

	function init(){
		//if( fi.isReadyForBattle() ) initFaerieInterface();
		super.init();
		
		if(Cm.card.$checkpoint>0){
			initCheckpoint();
		}else{
			launch();
		}
	}
	
	function maskInit(){
		super.maskInit()
		if(mcMap!=null)initButQuit();
	}
	
	
	function launch(){
		if( fi.isReadyForBattle() ) initFaerieInterface();
		super.launch()
	}
	
	function initGame(){
		super.initGame()
		
		game.width = 132
		game.height = 240
		
		initFaerie();
		game.setPieceSpeed( 0.03 + level*0.002 )
		
	}
		
	function initSkin(){
		super.initSkin();
		intUp = dm.attach("interfaceRacine",Base.DP_SKIN_UP)
		intMiddle = dm.attach("interfaceRacine",Base.DP_SKIN_MIDDLE)
		intDown = dm.attach("interfaceRacine",Base.DP_SKIN_DOWN)
		intUp.gotoAndStop("1")
		intMiddle.gotoAndStop("2")	
		intDown.gotoAndStop("3")	
	}
	
	// UPDATE
	function update(){
		super.update()
		if(mcMap!=null){
			var dy = (_ymouse-Cs.mch*0.5)*0.1
			mcMap.scroller._y = Cs.mm(-mcMap.sMax,(mcMap.scroller._y-dy),0)
		}
	}
	
	//
	
	
	// WIN
	function setWin(flag){
		super.setWin(flag)
		if(flag){
			level+=1;
			initStep(2)
		}
	}
	
	function endGame(){
		
		// RUN
		Cm.card.$stat.$run += int(Math.pow(level,2))
		
		// EXPERIENCE
		if( !mf.flDeath ){
			mf.fi.incExp(int((level*1.5)+1))
		}
		
		// WIN
		if( level%20 == 0 ){
			if( level == (Cm.card.$checkpoint+1)*20 ){
				Cm.card.$checkpoint += 1
				Manager.fadeSlot("news",120,120);
				downcast(Manager.slot).setNews(10+Cm.card.$checkpoint)
				downcast(Manager.slot).itemList = itemList;
			}else{
				tryToClose();
			}
			return;
		}
		super.endGame();
	}
	
	// ON
	function onLevelClear(){
		super.onLevelClear();
		setWin(true)
	}
	
	function onNewTurn(){
		super.onNewTurn();
		game.updatecolorList();	
	}
	
	// LEVEL
	function getLevel(){
	
		
		var flTrace = true//false;
		

		var dif = 10+(level*2) 
		if(flTrace)Manager.log( "Difficulté de base: "+dif );
		
		// HAUTEUR
		
		var hMax = int( Math.min( Math.sqrt(level), game.yMax-7 ) )
		var h = int( Math.max( Math.pow(level,0.35), 2+Std.random(hMax) ) )
				
		var malusHauteur = Math.pow(h,2.2) 
		dif -= malusHauteur
		if(flTrace)Manager.log( "hauteur("+h+") : -"+malusHauteur+" ...max("+(1+hMax)+")" );
		
		
		// COULEUR
		var colorLimit = 40
		while( dif > colorLimit ){
			dif -= colorLimit
			game.colorList.push(game.colMax)
			game.colMax++;
			if(flTrace)Manager.log( "newColor("+game.colMax+")! : -"+colorLimit );
			colorLimit*=2;
		}
		
	
		// GENERATION
		var table = getElementInfoTable();
		var lvl = new Array();
		for(var x=0; x<game.xMax; x++){
			lvl[x] = new Array();
			for(var y=0; y<game.yMax; y++){
				if( y >= game.yMax-h ){
					var o = getRandomElementInfo(table);
					lvl[x][y] = { et:o.et, n:o.n }
				}				
			}		
		}		

		// EYE
		var eyeNum = 0
		while( Std.random(int(dif)) > 10 && eyeNum<int(level/10) ){
			var he = 1+Std.random(h)
			dif -= (h-he)*7
			var px = Std.random(game.xMax)
			var py  = game.yMax-he	
			lvl[px][py] = {et:Cs.E_EYE,n:0}
			
			
			if(flTrace)Manager.log( "newEye(-"+(h-he)+")! : -"+((h-he)*5) );
			
		}
		
		
		// IMP
		var impNum = 0
		while( dif>7 && impNum<7 ){
			var maxLevel = int( Math.min( Math.pow(level, 0.4), 5 ) )
			
			if(maxLevel == 0 )break;
			
			var n = Std.random(maxLevel)+1
			var cost = null
			do{
				n--;
				cost = (n+1)*6;	//12/18/24/30
			}while( dif < cost )
			
			dif -= cost
			var px = Std.random(game.xMax)
			var py = game.yMax-(1+Std.random(h))
			lvl[px][py] = {et:Cs.E_CELL,n:n}
			
			if(flTrace)Manager.log( "add Imp("+n+")! : -"+cost );
			impNum++;
		}
		
		// ITEM
		if( level%20 > 2 && Std.random(Cs.itemRate) == 0 ){
			var px = Std.random(game.xMax)
			var py = game.yMax-(1+Std.random(h-1))
			var n = Item.getRandomId( mf.fi, level )
			if( n != null ) lvl[px][py] = { et:1, n:n };
		}


		return lvl
	}
	
	function getElementInfoTable(){

		var t = [
			{ et:0,	n:0,	freq:0 		}	// 0 TOKEN
			{ et:0,	n:1,	freq:0 		}	// 1 TOKEN - ETOILE
			{ et:0,	n:2,	freq:0		}	// 2 TOKEN - ARMURE
			{ et:2,	n:2,	freq:0	 	}	// 3 PIERRE
			{ et:4,	n:null,	freq:0	 	}	// 4 BOMB
		]
		
		// TOKEN
		if( level < 3 ){
			t[0].freq = 1000 
		}else if( level < 8 ){
			t[0].freq = 700
			t[1].freq = 300
		}else if( level < 15 ){
			t[0].freq = 500
			t[1].freq = 400
			t[2].freq = 100				
		}else if( level < 30 ){
			t[0].freq = 400
			t[1].freq = 350
			t[2].freq = 250			
		}else{	
			t[0].freq = 200
			t[1].freq = 400
			t[2].freq = 400			
		}
			
		// PIERRE
		if( level > 10 ){
			t[3].freq = Math.min( level*6, 200 )
		}	
			
		
		// BOMB
		if( level > 25 ){
			t[4].freq = Math.min( level, 100 )
		}

		
		// SUM
		var sum = 0
		for( var i=0; i< t.length; i++ ) sum += t[i].freq;
		
		return {sum:sum,list:t}
	}
	
	function getRandomElementInfo( table:{sum:int,list:Array<{et:int,freq:int,n:int}>} ){
		
		var n = Std.random(table.sum)
		var s = 0;
		for( var i=0; i<table.list.length; i++ ){
			s += table.list[i].freq;
			if( s > n ){
				return table.list[i];
			}
		}
		
		//Manager.log("ERROR: erreur dans le tirage Elements ")
		return null;		
		
		
	}
	
	// CHECKPOINT
	function initCheckpoint(){
		mcMap = downcast(dm.attach("mcForestMap",Base.DP_GAME))
		mcMap.scroller = Std.createEmptyMC(mcMap,1)
		var max = Cm.card.$checkpoint+1
		var x = 8
		var y = 8
		for( var i=0; i<max; i++ ){
			var mc  = downcast(Std.attachMC( mcMap.scroller,"mcCheckpointPicture",i))
			mc._x = x
			mc._y = y
			var lvl = i*20 +1
			mc.field.text = lvl
			mc.fieldTitle.text = Lang.checkpointName[i]
			mc.gotoAndStop(string(1+i))
			mc.onPress = callback(this,mapSelect,lvl-1)
			y+=108
		}
		
		mcMap.sMax = Math.max(0,(16+max*108)-Cs.mch)

	}
	
	function mapSelect(lvl){
		level = lvl
		mcMap.removeMovieClip();
		mcMap = null;
		butQuit.removeMovieClip();
		butQuit = null;
 		launch();
	}
	
	
	function kill(){
		Cm.card.$stat.$forestMax = int( Math.max(Cm.card.$stat.$forestMax,level+1) )
		super.kill();
	}
	
	
//{	
} 






















