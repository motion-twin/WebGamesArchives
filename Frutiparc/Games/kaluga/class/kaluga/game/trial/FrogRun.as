class kaluga.game.trial.FrogRun extends kaluga.game.Trial{//}
	// CONSTANTES
	var startPoint:Number = 1400
	var fullTime:Number = 40000;
	
	// VARIABLES
	var timer:Number;
	var step:Number;
	var endTime:Number;
	var barTimer:kaluga.bar.Timer;
	
	// REFERENCES
	var squirrel:kaluga.sp.bads.Squirrel;
	var frog:kaluga.sp.bads.Frog;
	
	
	function FrogRun(){
		this.init();
	}
	
	function init(){
		//_root.test+="[game.FrogRun] init()\n"
		this.type = "$frogRun"
		this.trialId = 6;
		this.mapInfo = {
			skinLink:this.mng.client.getFileInfos("map/olympic_a.swf").name,
			scrollerInfo:{
				height:30
			},
			groundLabel:"olympic",
			width:10000,
			height:480
		};
		super.init();
		this.step = 0;
		this.initScroller();
	}

	function initStartPanel(){
		super.initStartPanel();
		this.startPanel.toRead = 3;
	};	
	
	function startGame(){
		this.initTimer();
		super.startGame();
		
	}
	
	
	function initTimer(){
		//_root.test+="this.infoBar("+this.infoBar+")\n"
		this.barTimer = this.infoBar.addElement("barTimer");
		this.barTimer.setTimer(this.fullTime);
		this.endTime = getTimer()+this.fullTime;
	}
		
	function initSprites(){
		super.initSprites();
		this.genTzongre();
				
		
		this.genFrog();
		this.frog.focus = this.tzongre;
		
	}

	function genFrog(){
		var initObj = {
			x:this.startPoint,
			y:this.map.height-this.map.groundLevel,
			mobilite:1000
		};
		this.frog = this.newFrog(initObj);
		this.frog.endUpdate();
	}
	
	function genTzongre(){
		var initObj = this.tzongreInfo
		initObj.x = this.startPoint+1//kaluga.Cs.mcw/2
		initObj.y = kaluga.Cs.mch/2
		initObj.vity = -4
		initObj.flLauncher = true
		this.tzongre = this.newTzongre(initObj);
		this.setCameraFocus(this.tzongre)
		this.moveMap(false)
		this.map.update()
		this.tzongre.endUpdate();
	};
	
	function genSquirrel(){
		var initObj = {
			mode:2,
			x:this.startPoint,
			y:this.map.height - this.map.groundLevel
		}
		this.squirrel = this.newSquirrel(initObj);
		this.squirrel.endUpdate();
	}
	//
	function update(){
		super.update();
		if(this.masterStep ==1 ){
			switch(this.step){
				case 0 :	
					this.timer = this.endTime-getTimer()
					if( this.timer>0 ){
						this.barTimer.setTimer(this.timer);
					}else{
						this.barTimer.setTimer(0);
						this.step = 1;
	
					}
					break;
				case 1 :	
					if( this.frog.step == 0 || this.frog.step == 1 ){
						this.step = 99;
						this.score = Math.round((this.frog.x-1400)*10)/10
						this.addScore();
						this.endGame();	
					}
					break;
			}
		}
	}

	function onTzDeath(){
		super.onTzDeath();
		this.step = 99;
		this.endGame(70);	
	}
	//
				
	function getEndPanelObj(statList){

		//
		var obj = {
			//label:"caterLaunch",
			list:[
				{
					type:"bigScore",
					frame:1,
					score:this.score+"cm"
				},
				{
					type:"bigScore",
					frame:2,
					score:this.card.$max+"cm"
				},
				{
					type:"margin",
					value:15
				},
				{
					type:"graph",
					gfx:"partGraphBar",
					box:{x:20,y:6,w:420,h:230},
					//color:{main:this.mng.color.tzPastel[this.tzongreInfo.id],line:0xFFFFFF},
					margin:10,
					marginInt:6,
					list:statList,
					flNumber:true,
					flBackground:true,
					flTriangle:true
				}
			]
		}
		return obj		
	}
	
	function updateResult(player){
		var score;
		switch(player.id){
			case 0: // KALUGA
				score = 20000+random(10000)	// 2500
				if(!random(10))score=0; 
				break;
			case 1: // PIWALI
				score = 24000+random(12000)	// 3000
				if(!random(5))score=0; 
				break;
			case 2: // NALIKA
				score = 32000+random(4000)	// 3400
				if(!random(50))score=0; 
				break;
			case 3: // GOMOLA
				score = 15000+random(14000)	// 2200
				if(!random(8))score=0; 
				break;
			case 4: // MAKULO
				score = 10000+random(36000)	// 2800
				if(!random(200))score=0; 
				break;
		}
		score *= this.tournament.difCoef/10;
		player.results[this.tournament.eventId].base = score;
		super.updateResult(player);
	}
	
	
	
//{	
}
	