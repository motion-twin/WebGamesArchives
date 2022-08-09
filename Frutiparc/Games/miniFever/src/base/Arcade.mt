class base.Arcade extends Base{//}

	// CONSTANTE
	static var DIF_INFO = [
		{lvl:40,life:7,min:0,max:40},
		{lvl:80,life:6,min:0,max:60},
		{lvl:100,life:5,min:0,max:100},
		{lvl:100,life:4,min:50,max:100},
		{lvl:40,life:3,min:0,max:40}
	]
	
	
	var lifeRay:float;
	
	// VARIABLE
	var level:int;
	var life:int;
	var step:int;
	var popId:int;
	var toss:float;
	
	var timer:float;
	
	var lifeList:Array<MovieClip>
	var bList:Array<sp.Bubble>
	var pList:Array<{mc:MovieClip,t:float,vx:float,vy:float}>

	
	var console:MovieClip;
	var bgStar:MovieClip;

	function new(){
		lifeRay = 26.5;
		super();
	}	
		
	function init(){
		//Log.trace( "[BASEARCADE]init()\n" );
		super.init();
		life = DIF_INFO[infoList[0]].life;
		level = 0;
		toss = 0;
		genGameList();
		attachConsole();

		pList = new Array();
		
		nextGame = getRandomGame()
		initStep(3)
		//initStep(2)	
	}
		
	function initStep(n){
		step  = n
		switch(step){
			case 0:
				break;
			case 1:	// DEBRIEFING
				removeGameTimer();
				popId = null;
				if(flWin){
					downcast(console).center.gotoAndPlay("turn");
					incLevel(1)
				}else{	
					life--;
					downcast(console).center.stop();
					popId = Std.random(bList.length)
				}
				flWin = null;
				timer = 40
				break;
			case 2: // TIRAGE
				nextGame = getRandomGame()
				var co = downcast(console)
				co.center.stop();
				toss = 10
				
			
				//timer = 60
				break;
			case 3: // BRIEFING
				downcast(console).center.stop();
				timer = 20
				break;					
		}
	}
	
	function incLevel(inc){
		level += inc

		var o = DIF_INFO[infoList[0]]
		if( level == o.lvl ){
			//Log.trace(level)
			Manager.queue.push({link:"congrat",infoList:[infoList[0]]});
			leave();
			return;
		}
		var c = level/o.lvl
		dif =  o.min + Math.round((o.max-o.min)*c)
	
	}
	
	//
	function update(){
		super.update();
		scrollBg();

		switch(step){
			case 0:
				break;
			case 1:
				timer -= Timer.tmod;
				if(timer<0){
					if(life>0){
						initStep(2)
					}else{
						Manager.queue.push({link:"gameOver",infoList:null});
						leave();
						//Manager.slot.init();
					}
				}			
				break;
			case 2: // TOSS
				var lim = 1
				toss -= Math.max(0.05,toss*0.05) * Timer.tmod;
				if(toss<0){
					toss = 0//.000000000000000001
					initStep(3)
				}
				updateVignette();
				break;
			case 3:	
				timer -= Timer.tmod;
				if(timer<0){
					fadeOut(0xFFFFFF)
					initStep(0)
				}
				break;			
		}
		
		movePop();
		movePart();
		

		
	}
	//

	function movePop(){
		if(popId!=null){
			var b = bList[popId]
			b.sc *= Math.pow(0.95,Timer.tmod)
			if(b.sc < 2 ) b.sc = 0;
			
			if( Math.random()*20 < b.sc  ){
				var co = downcast(console)
				var mc = dm.attach("mcPartLife",20)
				mc._x = co._x + co.life._x + b.x
				mc._y = co._y + co.life._y + b.y
				var a = Math.random()*6.28
				var vit = 2+Math.random()*3
				var vx = Math.cos(a)*vit
				var vy = Math.sin(a)*vit
				pList.push({t:20,mc:mc,vx:vx,vy:vy})
			}
		}	
	}

	function movePart(){
		for( var i=0; i<pList.length; i++ ){
			var o  = pList[i]
			o.mc._x += o.vx*Timer.tmod;
			o.mc._y += o.vy*Timer.tmod;
			o.t -= Timer.tmod
			if( o.t < 0 ){
				o.mc.removeMovieClip();
				pList.splice(i--,1)
			}else if( o.t < 10){
				o.mc._xscale = o.t*10;
				o.mc._yscale = o.t*10;
			}
			//Log.print(o.sp.skin)
		}
	}	
	
	function setNext(){
		super.setNext();
		if( flWin != null ){
			closeGame();
		}else{
			removeConsole();
			newGame();
			
		}
	}

	function closeGame(){
		game.kill();
		attachConsole();
		initStep(1)
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
	

	
	function updateVignette(){
		var p = downcast(console).gamePicture
		
		var id = (nextGame.id+toss)%gameList.length
		var coef = toss%1
		var frame = 1+Math.round(40*coef)
		p.gotoAndStop(string(frame))
		frame = 1+Math.round(id)
		if( frame > gameList.length ) frame -= gameList.length
		p.v1.gotoAndStop(frame)
	}
	
	function scrollBg(){
		// BG
		var mc = downcast(bgStar)
		var speed = 0.5+dif*0.05;
		mc.bg._x = (mc.bg._x+speed*Timer.tmod)%60;
		mc.bg._y = (mc.bg._y+speed*Timer.tmod)%60;
		
		// LIFE
		moveBubble()

		
		
	};
	
	function moveBubble(){
		var co = downcast(console)
		var c = { x:0, y:0 }
		for( var i=0; i<bList.length; i++ ){
			var sp = bList[i]
			var dist = sp.getDist(c)
			var ray  = lifeRay-sp.skin._xscale*0.5
			if( dist >  ray ){
				var d = dist-ray
				var a = sp.getAng(c)
				sp.x += Math.cos(a)*d
				sp.y += Math.sin(a)*d
			}
			sp.update();
		}	
	}
	// CONSOLE
	
	function attachConsole(){
		
		// BG STAR
		bgStar = dm.attach("bgStar",6)
	
		// CONSOLE
		console = dm.attach("mcConsole",8)
		console._x = Cs.mcw*0.5
		console._y = Cs.mch*0.5
		var co =  downcast(console)
		updateLevelField()
		co.obj = this;
		
		// LIFE
		bList= new Array();
		for( var i=0; i<life; i++ ){
			
			var sp = new sp.Bubble();
			//sp.setSkin( dm.attach( "menuBubble", 9 ) )
			sp.setSkin( Std.attachMC(co.life.zone,"menuBubble",i) )
			
			var a = Math.random()*6.28
			

			sp.sc = 10+Std.random(20);
			sp.x = 0//co._x + co.life._x;
			sp.y = 0//co._y + co.life._y;
			var d = Math.random()*(lifeRay-sp.sc*0.5);
			sp.tx = sp.x + Math.cos(a)*d;
			sp.ty = sp.y + Math.sin(a)*d;
			sp.skin._xscale = 1
			sp.skin._yscale = 1
			sp.skin.gotoAndStop("1")
			sp.ray = Std.random(10)
			sp.vx = (Math.random()*2-1)*10
			sp.vy = (Math.random()*2-1)*10
			sp.list= bList;
			sp.init();
			
			bList.push(sp)			
		}
		// DIF
		for(var i=0; i<9; i++){
			var mc = Std.getVar(console,"$d"+i)
			if( dif*0.09 >= i ){
				mc.gotoAndStop("2")
			}else{
				mc.gotoAndStop("1")
			}
		}
		
		
		// VIGNETTE
		updateVignette();
		
		
	}
	
	function removeConsole(){
		console.removeMovieClip();
		bgStar.removeMovieClip();	
	};
		
	function updateLevelField(){
		downcast(console).center.text.field.text = Math.floor(level+1)
	}
		
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
