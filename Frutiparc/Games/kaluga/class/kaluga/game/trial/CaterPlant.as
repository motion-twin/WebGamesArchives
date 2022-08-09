class kaluga.game.trial.CaterPlant extends kaluga.game.Trial{//}

	// CONSTANTES
	var plantPoint:Number = 350;
	var zoneRay:Number = 	145;//50
	
	// VARIABLES
	var flWin:Boolean;
	var flValidate:Boolean;
	var score1:Number;
	var score2:Number;
	var waitTimer:Number;
	var step:Number;
	var distance:String;
	
	// REFERENCES
	var cater:kaluga.sp.bads.Caterpillar;
	var squirrel:kaluga.sp.bads.Squirrel;
	var meterLog:MovieClip;
	
	
	function CaterPlant(){
		this.init();
	}
	
	function init(){
		//_root.test+="bonjour!\n"
		this.type = "$caterPlant"
		this.trialId = 3;
		
		this.mapInfo = {
			skinLink:this.mng.client.getFileInfos("map/olympic_a.swf").name,
			width:700,
			height:480,
			groundLabel:"grassMountain"
		}
		
		super.init();
		this.step = 0;
		this.initScroller();
	}

	function initStartPanel(){
		super.initStartPanel();
		this.startPanel.toRead = 4;
	};
	
	function initSprites(){
		//_root.test+="bleeeeeeeeeurch!\n"
		super.initSprites();
		this.genTzongre();
		this.genCaterpillar(-1);
		this.genSquirrelJudge(this.plantPoint+this.zoneRay+130);
		this.squirrel.focus = this.tzongre;
		// PIQUET
		var y = this.map.height - this.map.groundLevel
		//this.newDecor("decorPiquet",{x:this.plantPoint+this.zoneRay,y:y})
		//this.newDecor("decorPiquet",{x:this.plantPoint-this.zoneRay,y:y})
		this.newDecor("decorFrontPiquet",{ x:this.plantPoint, y:kaluga.Cs.mch, depthCoef:1.01 })
	}
	
	function genTzongre(){
		var initObj = this.tzongreInfo
		initObj.x = kaluga.Cs.mcw/2
		initObj.y = kaluga.Cs.mch/2
		initObj.vity = -4
		initObj.flLauncher = true
		this.tzongre = this.newTzongre(initObj);
		this.tzongre.endUpdate();
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
		
	function initDefault(){
		super.initDefault();
	}
	//
	function update(){
		super.update();
		
		switch(this.step){
			case 0 :	// PREPARATION
				break;
			case 1 :	// SOULEVER
				break;			
			case 2 :	// LANCER
				break;
			case 3 :	// PLANTER
				//_root.test = this.waitTimer
				this.waitTimer -= kaluga.Cs.tmod
				if( this.waitTimer < 0 ){
					this.attachMeterLog(this.cater.x,this.cater.y,this.score+"cm");
					this.step=5
					this.waitTimer=120
				}
				break;
			case 4 :	// ANALYSE
				
				break;
			case 5 : 	// DECAL END
				this.waitTimer -= kaluga.Cs.tmod
				if( this.waitTimer < 0 ){
					this.step = 99;
					this.endGame();
				}
				break;
		}
	}
	//
	function onTzRelease(tzongre){
		this.setCameraFocus(tzongre.linkList[0])
		if(this.step==1)this.step++;
	}
	
	function onTzLink(tzongre){
		//this.focus = tzongre.linkList[0]
		this.step = 1;
		this.squirrel.focus = this.cater
	}

	function getEndPanelObj(statList){
		var obj = {
			list:[
				{
					type:"bigScore",
					frame:5,
					score:this.score1+"cm"
				},
				{
					type:"bigScore",
					frame:6,
					score:this.score2+"cm"
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
					value:1
				},
				{
					type:"graph",
					gfx:"partGraphBar",
					box:{x:20,y:6,w:420,h:170},
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
		return obj;
	}
	
	function onCaterCrash(power){

		var dif = Math.abs(this.cater.x-this.plantPoint)
		if(  dif<this.zoneRay ){
			this.score1 = Math.round(power*25)/10
			this.score2 = Math.round((1-(dif/this.zoneRay))*1000)/10//Math.round((this.zoneRay-dif)*10)/10
			this.score = this.score1+this.score2
			this.addScore();
			//this.distance = this.score+"cm"
			this.squirrel.setStatus(1);
			this.step = 3;
			this.waitTimer = 20			
		}else{
			this.squirrel.setStatus(0);
			this.step = 5
			this.waitTimer = 40
			//this.step = 99;
			//this.endGame();
			var obj = {
				label:"basic",
				list:[
					{
						type:"msg",
						title:"Hors-zone!",
						msg:"La chenille doit etre plantée entre les deux piquets."
					}
				]
			}
			this.endPanelStart.push(obj)
		}
		this.deActiveLink();
	}
	
	function updateResult(player){
		var score;
		switch(player.id){
			case 0: // KALUGA
				score = 500+random(500)		// 75
				break;
			case 1: // PIWALI
				score = 300+random(500)		// 55
				break;
			case 2: // NALIKA
				score = 500+random(200)		// 60
				break;
			case 3: // GOMOLA
				score = 450+random(500)		// 70
				break;
			case 4: // MAKULO
				score = 0+random(1000)		// 50
				break;
		}
		score *= this.tournament.difCoef/10;
		score *= 1.5
		player.results[this.tournament.eventId].base = score;
		super.updateResult(player);
	}	
	
//{	
}






















