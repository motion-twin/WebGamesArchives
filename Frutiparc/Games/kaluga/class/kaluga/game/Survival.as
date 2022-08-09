class kaluga.game.Survival extends kaluga.Game{//}

	// CONSTANTES
	var goalList:Array;
	
	
	// PARAMETRES
	

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
	
	
	function Survival(){
		this.init();		
	}
	
	function init(){
		//_root.test += "[game.Survival] init() level("+this.level+")\n"
		this.goalList = [ 45000, 60000, 80000, 150000 ]
		
		this.type = "$survival"
		this.mapInfo = {
			skinLink:this.mng.client.getFileInfos("map/field.swf").name,
			width:700,
			height:480,
			groundLabel:"field"
		};
		super.init();
		this.initScroller();
	};

	function initStartPanel(){
		super.initStartPanel();
		var txt = "Repoussez les assauts des corbeaux le plus longtemps possible.\n"
		txt += "Si vous tenez plus de "+ext.util.MTNumber.getTimeStr(this.goalList[this.level],"'","''")+", c'est gagné !!!"
		this.startPanel.text = txt
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
		//_root.test+="initSprite\n"
		super.initSprites();
		this.genTzongre();
		this.genGroundFruit();
		/*
		this.genPanier();
		this.max = 6+this.level*2
		for(var i=0; i<this.max; i++){
			this.genGroundFruit();
		}
		
		//this.genButterfly();
		*/
	}
	
	function update(){
		//_root.test = this.birdList.length+"\n";
		//_root.test += this.badList.length;
		super.update();
		if(this.masterStep==1){
			this.barTimer.update();
			this.difTimer -= kaluga.Cs.tmod;
			if(this.difTimer<0)this.difUp();
		}
		
	}
	
	function difUp(){
		this.dif ++;
		if(this.birdList.length<10)this.newBird( { hitPoint:40+level*10 } );
		this.difTimerBase = Math.max(100,this.difTimerBase-50);
		this.difTimer = this.difTimerBase
		
	}
	
	function genGroundFruit(){
		var w = 1.2 + this.level*0.1
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
	
	function addScore(){
		//
		var card = this.mng.card.$survival
		var info = card.$level[this.level]
		
		if(this.score>info.$s){
			info.$s = this.score;
			info.$t = this.tzongreInfo.id
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
			this.checkUnlock(3)
		}
		
		// SAVE SLOT
		this.mng.client.saveSlot(0)		
		
		
		
	}
	
	function stopTimer(){
		this.barTimer.stopTimer();
		this.score = this.barTimer.time
		this.addScore();
	}
	
	function onTzDeath(){
		super.onTzDeath();
		this.stopTimer();
	}
	
	function reset(){
		var initObj = {
			level:this.level
		}
		super.reset(initObj)
	}
	
//{	
}