class kaluga.game.trial.AntLaunch extends kaluga.game.Trial{//}

	// CONSTANTES
	var launchPoint:Number = 1400
	
	// VARIABLES
	var flValidate:Boolean;
	var timer:Number;
	var step:Number;
	var distance:String;
	var meterLogList:Array;
	var camWaitList:Array;
	var scoreList:Array;
	
	// REFERENCES
	var squirrel:kaluga.sp.bads.Squirrel;
	
	function AntLaunch(){
		this.init();
	}
	
	function init(){
		this.type = "$antLaunch"
		this.trialId = 4;
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
		this.meterLogList = new Array;
		this.scoreList = new Array;
		this.camWaitList = new Array;
		this.step = 0;
		this.initScroller();
	}

	function initStartPanel(){
		super.initStartPanel();
		this.startPanel.toRead = 3;
	};
	
	function initSprites(){
		super.initSprites();
		this.genTzongre();
		this.tzongre.bonusMulti = 4
		this.tzongre.bonusCombo = 1
		this.tzongre.updateRange();
		this.genSquirrelJudge(this.launchPoint);
		for(var i=0; i<4; i++){
			var mc = this.genAnt();
			mc.x -= i*10
		}
		this.squirrel.focus = this.tzongre;
	}

	function genAnt(){
		var mc = this.newAnt();
		var w = this.map.width/2
		mc.x = 0
		mc.y = this.map.height - this.map.groundLevel;
		mc.setSens(1)
		return mc;
	}
	
	function genTzongre(){
		var initObj = this.tzongreInfo
		initObj.x = kaluga.Cs.mcw/2
		initObj.y = kaluga.Cs.mch/2
		initObj.vity = -4
		initObj.flLauncher = true
		this.tzongre = this.newTzongre(initObj);
		this.setCameraFocus(this.tzongre)
		this.moveMap(true);
		this.map.update();
		this.tzongre.endUpdate();		
	};
	
	//
	function update(){
		super.update();
		//_root.test=" antList "+this.antList.length+"\n"
		switch(this.step){
			case 0 :	// PREPARATION
				break;
			case 1 :	// SOULEVER
				for( var i=0; i<this.antList.length; i++ ){
					var ant = this.antList[i]
					if( this.squirrel.status == undefined && ant.x > this.launchPoint ){
						this.squirrel.setStatus(0);
						this.flValidate = false;
					}
				}
				break;			
			case 2 :	// LANCER
				if(this.flLinkActive)this.deActiveLink();
				var first;
				for( var i=0; i<this.antList.length; i++ ){
					var ant = this.antList[i]
					if(ant.flGround){
						this.landing(ant)
					}
					if( ant.x > this.launchPoint ){
						if( this.squirrel.status == undefined ){
							this.squirrel.setStatus(1);
							this.flValidate = true;
						}


					}
					if(first==undefined or ant.y>first.y){
						first = ant;
					}
					
				}
				if(this.camWaitList.length>0){
					var o = this.camWaitList[0]
					first = o.path
					o.timer-=kaluga.Cs.tmod;
					if(o.timer<0){
						this.camWaitList.shift();
					}
				}
				

				if(this.camFocus!=first){
					this.setCameraFocus(first);
				}
				
				if(first==undefined){
					if(this.flValidate){
						this.score = 0;
						for( var i=0; i<this.scoreList.length; i++){
							this.score += this.scoreList[i];
						}
						this.addScore()
						this.endGame();
						this.step = 99;
					}else{
						this.setCameraFocus(this.squirrel)
						this.overTheLine()
						this.timer = 60;
						this.step = 3;

					}
				}
				break;
			case 3 :	// LOOSE TIMER
				this.timer -= kaluga.Cs.tmod;
				if(this.timer<0){
					//this.loose("Vous avez dépassé la ligne de lancé !")
					this.endGame();
					this.step = 99;				
				}
				break;
			case 4 :	// ENDGAMEPANEL
				break;				
				
		}

	}
	//
	function landing(ant){
		//
		var score = Math.round((ant.x-1400)*10)/10
		this.scoreList.push(score);
		var mc = this.attachMeterLog(ant.x,ant.y,score+"cm");
		//
		for(var i=0; i<this.meterLogList.length; i++){
			var meterLog = this.meterLogList[i]
			if( meterLog.y == mc.y && Math.abs(meterLog.x-mc.x) < 100 ){
				mc.y = meterLog.y-36;
				i=0;
			}
		}
		this.meterLogList.push(mc)
		//
		//BIDOUILLE
		var obj = this.newDecor("spBadsAnt", { x:ant.x, y:ant.y, depthCoef:1 } )
		ant.kill();
		//
		this.camWaitList.push({timer:100,path:obj})
	}
	
	function onTzRelease(tzongre){
		if(this.step==1)this.step++;
		this.map.initRuler(this.launchPoint);
	}	

	function onTzLink(tzongre){
		this.step = 1;
		//this.squirrel.focus = this.cater
	}

	function overTheLine(){
		var obj = {
			label:"basic",
			list:[
				{
					type:"msg",
					title:"Faute!",
					msg:"Vous devez lacher les fourmis avant que l'une d'entre elle ne franchisse la ligne !"
				}
			]
		}
		this.endPanelStart.push(obj)
	}
	
	
	function getEndPanelObj(statList){
		var obj = {
			//label:"caterLaunch",
			list:[
				{
					type:"margin",
					value:8
				},
				{
					type:"littleScore",
					title:"fourmi numero 1 :",
					score:this.scoreList[0]+"cm"
				},
				{
					type:"littleScore",
					title:"fourmi numero 2 :",
					score:this.scoreList[1]+"cm"
				},
				{
					type:"littleScore",
					title:"fourmi numero 3 :",
					score:this.scoreList[2]+"cm"
				},
				{
					type:"littleScore",
					title:"fourmi numero 4 :",
					score:this.scoreList[3]+"cm"
				},				
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
					value:10
				},
				{
					type:"graph",
					gfx:"partGraphBar",
					box:{x:20,y:6,w:420,h:150},
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
				score = 34000+random(10000)	// 3900
				break;
			case 1: // PIWALI
				score = 38000+random(6000)	// 4100
				break;
			case 2: // NALIKA
				score = 40000+random(4000)	// 4200
				break;
			case 3: // GOMOLA
				score = 31000+random(12000)	// 3700
				break;
			case 4: // MAKULO
				score = 34000+random(16000)	// 4200
				break;
		}
		score *= 3	// AJUSTEMENT
		score *= this.tournament.difCoef/10;
		player.results[this.tournament.eventId].base = score;
		super.updateResult(player);
	}	
	
	
//{	
}






















