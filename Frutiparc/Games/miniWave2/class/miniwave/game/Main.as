class miniwave.game.Main extends miniwave.Game{//}
	
	// CONSTANTES
	var eventTimerMax:Number = 100;
	
	// VARIABLES
	//var flBoss:Boolean ;
	var optionPointMax:Number;
	var eventTimer:Number
	var saucerCompt:Number;
	var nextLevel:Number;
	
	
	var optList:Array;
	var optionList:Array;
	var saucerList:Array;
	
	// CHEAT
	var keyCoolDown:Number;
	
	// REFERENCES
	var lifePanel:miniwave.panel.Life	
	var boss : miniwave.sp.Boss	
	
	function Main(){
		this.init();
	}
	
	function init(){
		super.init();
		this.optList = new Array();
		this.saucerList = new Array();
		this.genOptionList();
		
		this.fadeCb = {
			obj:this,
			method:"initStep",
			args:0
		}
		
		this.keyCoolDown = 0
		
	};

	function initDecor(){
		super.initDecor();
		this.decor.gotoAndStop(1)
		this.decor.bg0.gotoAndStop(1)
		this.decor.bg1.gotoAndStop(2)
		this.decor._y = this.mng.mch;
	}
	
	function initStep( step ){
		this.step = step;
		switch( this.step ){
		
			case 0:	// NEW LEVEL
				var info = this.waveInfo[this.level]
				if( info != undefined ){
					if( info.name == "boss" ){
						var initObj = {
							type:3,
							timer:160,
							list:[],
							cb:{ obj:this, method:"initStep", args:4 }
						}				
					}else{
						this.mng.music.playSound("sJingle2", 33 )
						this.mng.music.setVolume( 33, 80 )						
						var initObj = {
							type:0,
							timer:80,
							list:[ "level "+(this.level+1), info.name ],
							cb:{ obj:this, method:"initStep", args:1 }
						}
					}
					

				}else{
					var initObj = {
						type:2,
						timer:160,
						list:[ this.getEndMsg() ],
						cb:{ obj:this, method:"endGame" }
					}				
				}
				this.genMsg(initObj)
				break;
			case 1: // WAVING
				this.initLevel();
				this.checkHero();
				break;
			case 2: // GAME
				for( var i=0; i<this.badsList.length; i++ ){
					this.badsList[i].startWaveAttack();
				}
				this.checkHero();
				break;
			case 3: // FORWARD
				this.timer = this.endTimerMax;
				this.cleanShots()				
				break;
			case 4: // BOSS
				this.initBoss();
				this.checkHero();			
				break;				
			
		}
	}	
	
	function update(){

		if( this.checkWaveInfoLoading() )return;
		super.update();
		switch(this.step){
			case 0 :	// PANEL
				break;
			case 1 :	// WAVING
				if( this.isWaveReady() ){
					this.initStep(2)
				}
				break;
			case 2 :	// GAME
				if(this.badsList.length>0){
					this.checkEvent();			
					this.updateWave();
				}
				//
				this.checkEnd();
				//* CHEAT
				if(this.mng.flTestMode)this.checkCheatKey();
				//*/
				break;
			case 3 : 	// FORWARD
				this.timer -= Std.tmod
				var c = this.timer/this.endTimerMax;
				var d = (this.nextLevel-this.level)*c
				var dy = ((this.nextLevel-d)*this.decorDecal)
				this.moveMap(dy)
				
			
				
				if( this.timer <0 ){
					//this.level++;
					this.level = this.nextLevel;
					this.initStep(0);
				}
				
				break;
			case 4 :	// BOSS
				this.checkCheatKey();
				break;
		}		
		
		this.moveAll();
		
		// UPDATE
		/*
		if( this.flDebugScrolling ){
			var dy = (this._ymouse/this.mng.mch)*4000
			_root.test = dy
			this.moveMap(dy)	
		}
		*/
		
	}
	//
	
	//
	function initLevel(){
		super.initLevel();
		this.saucerCompt = 0;
		this.eventTimer = this.eventTimerMax;
		if( this.name == "arcade" ){
			switch(this.level){
				case 48:
					this.shipBounds.max = this.mng.mcw+60
					break;
			}
		}
		
	}
	
	function initBoss(){
		//this.flBoss = true;
		var initObj = {
		
		}
		this.boss = this.newSprite("miniWave2SpBoss",initObj)
	}
	
	function initInterface(){
		super.initInterface();
		// LIFE
		this.lifePanel = this.newPanel("miniWave2PanelLife")
		//_root.test += "this.lifePanel("+this.lifePanel+")\n"
		for(var i=0; i<this.heroList.length; i++){
			//_root.test += "-("+this.lifePanel.addLife+")\n"
			var index = this.heroList.length-(i+1)
			this.lifePanel.addLife(this.heroList[index])
		}
		
	}
	
	function checkHero(){
		if(this.hero._visible == undefined){
			this.callNewHero();
		}		
	}
	
	function callNewHero(){
		this.lifePanel.removeLife()
	}
	
	function checkEnd(){
		if(toKill<=0 && this.saucerList.length==0 && this.optList.length==0 ){
			this.nextLevel = this.level+1 // HACK random(200)
			this.initStep(3)
		};
		
	}
	
	function checkEvent(){
		if( this.eventTimer < 0 ){
			this.eventTimer = this.eventTimerMax
			
			if( !random(3+Math.pow(3,this.saucerCompt+1)) && this.saucerList.length == 0 ){
				this.genSaucer();
			}
		}else{
			this.eventTimer -= Std.tmod;
		}
	}	
	
	function setWarp(n){
		this.mng.sfx.playSound( "sWarp0", 15 )
		//this.game.mng.sfx.setVolume( 15, 80 )
		
		//_root.test+="setWarp(+"+n+")\n"
		while( this.badsList.length>0 )this.badsList[0].warp();
		while( this.saucerList.length>0 )this.saucerList[0].kill();
		while( this.optList.length>0 )this.optList[0].kill();
		
		this.cleanShots();
		this.nextLevel = Math.min(this.level+n,this.waveInfo.length-1)
		this.initStep(3)	
	}
	
	function genSaucer(){
		var sens = random(2)*2 -1
		var w = this.mng.mch/2
		var initObj = {
			x:w-(w+miniwave.sp.Saucer.margin)*sens,
			y:20,
			sens:sens,
			speed: 1 + (random(10)/10) + this.saucerCompt*0.5 + Math.min( Math.round(this.level/50), 3 )
		}
		var mc = newSprite("miniWave2SpSaucer",initObj);
		this.saucerList.push(mc);
		this.saucerCompt++;	
	}
	
	function addLife(n){
		this.heroList.unshift(n)
		this.lifePanel.addLife(n)	
	}
	
	function getEndMsg(){
		return "vous avez repoussé l'attaque des fruits mutants";
	}
	
	// ON
	function onHeroKill(){
		
				
		if(this.heroList.length>0){
			
			this.cleanShots();
			if( this.step == 2 ){
				// RETRAITE DE LA WAVE
				var resetList = new Array();
				for( var i=0; i<this.badsList.length; i++ )resetList.push(this.badsList[i]);
				
				for( var i=0; i<resetList.length; i++ ){
					resetList[i].reset(i*2);
				}
				this.step = 1;
			}else{
				//_root.test+="!!\n"
				this.callNewHero();
			}
			
			if( this.step == 4){
				this.boss.onHeroKill();
			}
			
			
			
		}else{
			var initObj = {
				type:1,
				list:[  ]
			}
			this.gameOver(initObj);
			
		}

	}
	
	// OPTIONS
	function genOptionList(){
		
		this.optionList = [
			40,		// BRONZE 1
			20,		// ARGENT 5
			5,		// GOLD 10
			1,		// PLATINIUM 50
			12,		// WARP 5
			6,		// WARP 10
			2,		// WARP 20
			5,		// CARD RED HANABI
			5,		// CARD GREEN HOMING
			5,		// CARD BLUE WAVE
			8		// LIFE UP
		
		]
		this.optionPointMax = 0
		for(var i=0; i<this.optionList.length; i++ )this.optionPointMax += this.optionList[i];
		
	}
	
	function getOptionType(){
		var n = random(this.optionPointMax)
		var s = 0;
		for( var i=0; i<this.optionList.length; i++ ){
			s += this.optionList[i];
			if( s > n ) return i;
		}
		_root.test += "!!! ERROR !!! getOptionType()\n";
		
	}
	
	function genOption(x,y){
		var initObj = {
			x:x,
			y:y,
			type:this.getOptionType()
		}
		var mc = this.newSprite( "miniWave2SpOpt", initObj)
		this.optList.push(mc)
	}
	
	function getWaveName(){
		return "mainWave"
	}
	
	// ENDGAME
	function endGame(){
		//_root.test+="endGame("+p+","+this.mng.fc[0].$cons.$main+")"
		if( this.name == "arcade" ){
			var p = this.getCons();
			if( p > this.mng.fc[0].$cons.$main ){
				this.mng.fc[0].$cons.$main = p
				/*
				if( p == 100 ){
					this.mng.client.giveItem("$arcade");
					this.mng.newTitem++
				}
				*/
			}
			this.mng.fc[0].$arcade.$bestScore = Math.max( this.mng.fc[0].$arcade.$bestScore, this.score );
			this.mng.fc[0].$arcade.$bestLevel = Math.max( this.mng.fc[0].$arcade.$bestLevel, (this.level+1) );
		}
		super.endGame();
	}
	
	// CHEAT
	function armageddon(sens){
		/*
		while( this.badsList.length>0 ){
			this.badsList[0].explode();
		}
		
		if(!flUp){
			this.level--;

		}else{
			if(Key.isDown(Key.SHIFT)){
				this.level+=200//9;
				//this.incScore(10000)
			}
			
		}
		*/
		this.setWarp( (1+Key.isDown(Key.SHIFT)*200)*sens )
	
		
	}
	
	function checkCheatKey(){
		if(this.keyCoolDown<0){
			if(Key.isDown(33))this.armageddon(1);	this.keyCoolDown=4;
			if(Key.isDown(34))this.armageddon(-1);	this.keyCoolDown=4;
			if(Key.isDown(96))this.addLife(0);		this.keyCoolDown=4;
			if(Key.isDown(97))this.addLife(1);		this.keyCoolDown=4;
			if(Key.isDown(98))this.addLife(2);		this.keyCoolDown=4;
			if(Key.isDown(99))this.addLife(3);		this.keyCoolDown=4;
			if(Key.isDown(100))this.addLife(4);		this.keyCoolDown=4;
			if(Key.isDown(101))this.addLife(5);		this.keyCoolDown=4;
			if(Key.isDown(36))this.genSaucer();		this.keyCoolDown=4;
		}else{
			this.keyCoolDown -=Std.tmod
		}		
	}

	// STATS
	function addNewPlay( name ){
		if(name==undefined)name = "$main";
		super.addNewPlay(name)
	}		

	
//{	
}














