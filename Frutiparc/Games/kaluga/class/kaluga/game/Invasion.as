class kaluga.game.Invasion extends kaluga.Game{//}

	// PARAMETRES
	var goalList:Array;

	// VARIABlES
	var flTimeRun:Boolean;
	var step:Number;
	var max:Number;
	//var record:Array;
	var dif:Number;
	var difTimer:Number;
	var difTimerBase:Number;
	
	//REFERENCES
	var barTimer:kaluga.bar.Timer
	
	
	function Invasion(){
		//_root.test+="youhouyhou\n"
		this.init();		
	}
	
	function init(){
		//_root.test += "[game.Invasion] init() level("+this.level+")\n"
		this.goalList = [90000,120000,150000,180000]
		
		this.type = "$invasion"
		this.mapInfo = {
			skinLink:this.mng.client.getFileInfos("map/mordor.swf").name,
			width:700,
			height:480,
			groundLabel:"empty"
		};
		super.init();
		this.initScroller();
	};

	function initStartPanel(){
		super.initStartPanel();
		this.startPanel.text = "Si vous tenez plus de "+ext.util.MTNumber.getTimeStr(this.goalList[this.level],"'","''")+" c'est gagné !"
		this.startPanel.toRead = 1;
	};
	
	function startGame(){
		super.startGame();
		this.barTimer = this.infoBar.addElement("barTimer")
		this.barTimer.setTimer(0)
		this.barTimer.startTimer();	
	}
	
	function initGame(){
 		super.initGame();
		this.step = 0;
		this.dif = 0;
		this.difTimer = 0;
		this.difTimerBase = 1000;
	}
	
	function initSprites(){
		super.initSprites();
		this.genTzongre();
		this.genGroundFruit();
		this.genGroundFruit();
		this.genGroundFruit();
	}
	
	function update(){
		super.update();
		if(this.masterStep==1){
			this.barTimer.update();
			this.difTimer -= kaluga.Cs.tmod;
			if(this.difTimer<0)this.difUp();
		}
		
	}
	
	function difUp(){
		this.dif ++;
		//_root.test="dif Up ("+this.dif+") lvl."+this.level+"\n"
		if(this.antList.length<50){
			var side = random(2)*2-1
			var max = Math.round(this.dif*(1+this.level*0.4))
			for(var i=0; i<max; i++){
				//_root.test+="-\n"
				var mc = this.genAnt(side);
				mc.x += side*i*10
			}
		}
		this.difTimerBase = Math.max(100,this.difTimerBase-50);
		this.difTimer = this.difTimerBase		

	}
	
	function genGroundFruit(){
		var w = 1.8 - this.level*0.2
		var r = w*12
		var initObj = {
			x:r+random(kaluga.Cs.mcw-(2*r)),
			weight:w
		};
		var mc = this.newFruit(initObj);
		mc.y = this.map.height-(this.map.groundLevel+mc.ray)
		mc.endUpdate();
	}

	function genTzongre(){
		var initObj = this.tzongreInfo
		initObj.x = kaluga.Cs.mcw/2;
		initObj.y = kaluga.Cs.mch/2;
		initObj.vity = -4;
		this.tzongre = this.newTzongre(initObj);
		this.tzongre.endUpdate();
	}	
	
	function genAnt(side){
		//_root.test+="htethht\n"
		var mc = this.newAnt();
		if( side == undefined ) side = random(2)*2 - 1
		var w = this.map.width/2
		mc.x = w + (w+10)*side
		mc.y = this.map.height - this.map.groundLevel;
		mc.setSens(-side)
		return mc;
	}
		
	function addScore(){
		var card = this.mng.card.$invasion
		var info = card.$level[this.level]
		
		if(this.score>info.$s){
			info.$s = this.score;
			info.$t = this.tzongreInfo.id;
		}
		
		var obj = {
			list:[
				{
					type:"bigScore",
					frame:3,
					score:ext.util.MTNumber.getTimeStr(this.score,"'","''")
				},
				{
					type:"bigScore",
					frame:2,
					score:ext.util.MTNumber.getTimeStr(info.$s,"'","''")
				}
			]
		}
		this.endPanelMiddle.push(obj)

		// DEBLOQUAGE DE MODE
		if( this.score > this.goalList[this.level] ){
			this.checkUnlock(4)
		}

		// SAVE SLOT
		this.mng.client.saveSlot(0)		
		
		
	}
	
	function stopTimer(){
		this.barTimer.stopTimer();
		this.score = this.barTimer.time
		this.addScore();
	}
	
	function initEndGame(){
		super.initEndGame()
		
	}
	
	
	function onTzDeath(){
		super.onTzDeath()
		this.stopTimer();
		
	}
	
	function reset(){
		var initObj = {
			level:this.level
		}
		super.reset(initObj)
	}
	
	function onFruitEatFinish(){
		super.onFruitEatFinish()
		this.stopTimer();
		this.endGame(10);
	}
	

	
//{	
}