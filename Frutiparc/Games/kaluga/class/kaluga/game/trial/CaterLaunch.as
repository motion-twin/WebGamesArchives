class kaluga.game.trial.CaterLaunch extends kaluga.game.Trial{//}

	// CONSTANTES
	var launchPoint:Number = 1400
	
	// VARIABLES
	var flValidate:Boolean;
	var timer:Number;
	var step:Number;
	var distance:String;
	var caterPoint:Number;
	
	// REFERENCES
	var cater:kaluga.sp.bads.Caterpillar;
	var squirrel:kaluga.sp.bads.Squirrel;
	
	function CaterLaunch(){
		this.init();
	}
	
	function init(){
		this.type = "$caterLaunch"
		this.trialId = 0;
		this.mapInfo = {
			skinLink:this.mng.client.getFileInfos("map/olympic_a.swf").name,
			scrollerInfo:{
				//coef:1,
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
	
	function initSprites(){
		super.initSprites();
		this.genTzongre();
		this.genSquirrelJudge(this.launchPoint);
		this.genCaterpillar(-1);
		this.squirrel.focus = this.tzongre;
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
		//
	};
	
	function genCaterpillar(side){
		var mc = this.newCaterpillar();
		if( side == undefined ) side = random(2)*2 - 1
		var w = this.map.width/2
		mc.x = w + (w+10)*side
		mc.y = this.map.height - this.map.groundLevel;
		mc.setSens(-side)
		mc.endUpdate();
		this.cater = mc;
		
		return mc;
	}
	//
	function update(){
		super.update();
		
		//_root.test += "this.cater.x("+this.cater.x+")\n"
		
		if(this.masterStep == 1 ){
			switch(this.step){
				case 0 :	// PREPARATION
					break;
				case 1 :	// SOULEVER
					if( this.squirrel.status == undefined and this.cater.x > this.launchPoint ){
						this.squirrel.setStatus(0);
						this.flValidate = false;
					}
					break;			
				case 2 :	// LANCER
					if(this.flLinkActive)this.deActiveLink();
					if( this.squirrel.status == undefined and this.cater.x > this.launchPoint ){
						this.squirrel.setStatus(1);
						this.flValidate = true;
					}
					
					if( this.cater.flGround){
						//_root.test+="cater.flGround\n"
						this.step = 3;
						this.timer = 120
						this.caterPoint = Math.round((this.cater.x-1400)*10)/10
						this.distance = this.caterPoint+"cm";
						this.attachMeterLog(this.cater.x,this.cater.y,this.caterPoint+"cm");
					}
					break;
				case 3 :	// PLANTER
					
					this.timer -= kaluga.Cs.tmod
					if( this.timer < 0 ){
						
						if(!this.flValidate){
							this.setCameraFocus(this.squirrel)
							if(this.timer<-40){
								this.loose("Vous avez dépassé la ligne de lancé !")
								this.step = 4;
							}
						}else{
							this.score = this.caterPoint;
							this.addScore();
							this.step = 4;
							this.endGame();
						}
						
					}
					break;
				case 4 :	// ENDGAMEPANEL
					break;				
					
			}
		}
		
	}
	//
	function onTzRelease(tzongre){
		this.setCameraFocus(tzongre.linkList[0])
		if(this.step==1){
			this.step=2;
			//var c = 1 + random(10)/100
			//this.cater.vitx *= c
			//this.cater.vity *= c
		}
		this.map.initRuler(this.launchPoint);
	}	

	function onTzLink(tzongre){
		//this.focus = tzongre.linkList[0]
		this.step = 1;
		this.squirrel.focus = this.cater
	}

	function getEndPanelObj(statList){
		var obj = {
			//label:"caterLaunch",
			list:[
				{
					type:"bigScore",
					frame:1,
					score:this.distance
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
		
		if( this.mng.client.isWhite() ){
			/*
			_root.test="!this.mng.card.$bonus[0]("+!this.mng.card.$bonus[0]+")\n"
			_root.test+="this.caterPoint > 1000("+(this.caterPoint > 1000)+")\n"
			_root.test+="this.caterPoint("+this.caterPoint+")\n"
			*/
			if( !this.mng.card.$bonus[0] && this.caterPoint > 1000 ){
				this.addTitem("$squirrel0")
				this.mng.card.$bonus[0] = 1
				this.mng.client.saveSlot(0);
			}
		}
		
		return obj		
	}
	
	function updateResult(player){
		var score;
		switch(player.id){
			case 0: // KALUGA
				score = 8000+random(4000)	// 1000
				break;
			case 1: // PIWALI
				score = 9000+random(5000)	// 1150
				break;
			case 2: // NALIKA
				score = 8000+random(4000)	// 1000
				break;
			case 3: // GOMOLA
				score = 5000+random(4000)	// 700
				break;
			case 4: // MAKULO
				score = 8000+random(6000)	// 1100
				break;
		}
		score *= this.tournament.difCoef/10;
		player.results[this.tournament.eventId].base = score;
		super.updateResult(player);
	}
	
//{	
}






















