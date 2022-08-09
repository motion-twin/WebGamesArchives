class miniwave.game.Survival extends miniwave.Game{//}
	
	// CONSTANTES
	var spawnLimit:Number = 48
	var badsTypeMax = 45
	
	// VARIABLE
	var xStart:Number;
	var waveWidth:Number;
	var waveSpace:Number;
	var levelTimer:Number;
	var levelTimerFull:Number;
	
	// REFERENCES
	var lifePanel:miniwave.panel.Life	
	//var boss : miniwave.sp.Boss	
	
	function Survival(){
		this.init();
	}
	
	function init(){
		this.heroList = [0]
		this.level = 0;
		super.init();		
		//_root.test +="[SURVIVAL] init()\n"
		this.fadeCb = {
			obj:this,
			method:"initStep",
			args:0
		}
		
		
		
	};

	function initDecor(){
		super.initDecor();
		this.decor.gotoAndStop(2)
		this.decor._y = this.mng.mch;
	}
		
	function initLevel(){
		//_root.test+="initLevel()\n"

		this.shipBounds = {
			min:0,
			max:this.mng.mcw //+100 //HACK
		}
		
		this.fallSpeed = 5
		this.waveSpeed = 0.6		
		this.waveSens = 1;
		
		this.waveWidth = 4
		this.waveSpace = 24
		this.xStart = 0
		
		var e = this.waveSpace
		
		var dx = (this.mng.mcw-(this.waveWidth*this.waveSpace))/2
		
		for( var y=0; y<3; y++ ){
			for( var x=0; x<this.waveWidth; x++ ){
				var initObj = {
					x: dx + x*this.waveSpace,
					y: (y+1)*this.waveSpace
					//waveId:i,
					//lineId:n
				};
				var mc = this.newBads( random(Math.min(this.level+3,this.badsTypeMax)) ,initObj )
				mc.step = 2;
				mc.ty = mc.y
				//_root.test += "mc("+mc+")\n"
				
			}
		}
		
		//super.initLevel();
	}
	
	function initInterface(){
		super.initInterface();
		// LIFE
		this.lifePanel = this.newPanel("miniWave2PanelLife")
		for(var i=0; i<this.heroList.length; i++){
			var index = this.heroList.length-(i+1)
			this.lifePanel.addLife(this.heroList[index])
		}
		
	}
		
	function initStep( step ){
		//_root.test+="initStep("+step+")\n"
		this.step = step;
		switch( this.step ){
		
			case 0:	// PREINIT
				break;
			case 1: // INIT
				break;
			case 2: // GAME
				this.initLevel();
				this.callNewHero();
				
				this.levelTimerFull = 800;
				this.levelTimer = this.levelTimer
			
			
				break;
		}
	}	
	
	function update(){
		if( this.checkWaveInfoLoading() )return;
		super.update();
		switch(this.step){
			case 0 :	// PREINIT
				this.initStep(1);
				break;
			case 1 :	// INIT
				this.initStep(2);
				break;
			case 2 :	// GAME
				//_root.test=">>>\n"
				this.checkLast();
				this.updateWave();
				if(this.levelTimer<=0){
					this.levelUp();
				}else{
					this.levelTimer -= Std.tmod 
				}
				break;
		}		
		
		this.moveAll();
		
	}
	
	//

	function checkLast(){
		var y = this.mng.mch;
		for(var i=0; i<this.badsList.length; i++){
			var mc = this.badsList[i];
			y = Math.min(y,mc.ty)
		}
		
		if( y > this.spawnLimit ){
			this.genNewLine();
		}
	
	}
	
	function genNewLine(){
		var dx = (this.mng.mcw-(this.waveWidth*this.waveSpace))/2
		var y = 0
		for( var x=0; x<this.waveWidth; x++ ){
			var initObj = {
				x: dx + x*this.waveSpace,
				y: (y+1)*this.waveSpace
			};
			var mc = this.newBads( random(Math.min(this.level+3,this.badsTypeMax)) ,initObj )
			mc.step = 2;
			mc.ty = mc.y
			mc.y -= 40
		}
		
		
		
	}
		
	function levelUp(){
		this.level++;
		this.levelTimerFull *= 1.1;
		this.levelTimer = this.levelTimerFull
		
		this.waveWidth = Math.min( 3+Math.floor(Math.sqrt(this.level)) , 8)
		this.waveSpeed = 0.6 + this.level*0.03;

		
		//_root.test+="("+this.level+") levelUp ! speed:"+this.waveSpeed+"\n"
		
	
	}
	
	function checkHero(){
		if(this.hero._visible == undefined){
			this.callNewHero();
		}		
	}
	
	function callNewHero(){
		this.lifePanel.removeLife()
	}
	
	function addLife(n){
		this.heroList.unshift(n)
		this.lifePanel.addLife(n)	
	}
	
	//
	function endGame(){
		this.mng.fc[0].$survival = Math.max( this.mng.fc[0].$survival, this.score );
		super.endGame();
	}	
	
	// ON
	function onHeroKill(){
		
				
		if(this.heroList.length>0){
			this.callNewHero();						
		}else{
			var initObj = {
				type:1,
				list:[  ]
			}
			this.gameOver(initObj);
			
		}

	}

	// STATS
	function addNewPlay(){
		super.addNewPlay("$survival")
	}	
	
//{
}











