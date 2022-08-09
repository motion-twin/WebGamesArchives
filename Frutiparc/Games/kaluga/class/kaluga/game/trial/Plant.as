class kaluga.game.trial.Plant extends kaluga.game.Trial{//}

	// CONSTANTES
	var plantPoint:Number = 	350;
	var zoneRay:Number = 		24;
	var distanceMax:Number =	50;
	var shotMax:Number =		3;
	
	// VARIABLES
	//var flUnder:Boolean;
	var waitTimer:Number;
	var step:Number;
	var shot:Number;
	var distance:Number;
	var scoreList:Array;
	var picPos:Object;
	
	// REFERENCES
	var tzongre:kaluga.sp.phys.Tzongre;
	var fruit:kaluga.sp.phys.Fruit;
	var scorePanel:kaluga.bar.Score;
	var piquet:MovieClip;
	
	function Plant(){
		this.init();
	}
	
	function init(){
		_root.test+="[game.trial.Plant] init()\n"
		this.type = "$plant"
		this.trialId = 5;
		this.mapInfo = {
			skinLink:this.mng.client.getFileInfos("map/olympic_a.swf").name,
			width:700,
			height:480,
			groundLabel:"grassMountain"
		}
		super.init();
		this.scoreList = new Array();
		this.step = 0;
		this.initScroller();
	}
	
	function initGame(){
		super.initGame();
		this.shot = this.shotMax;
		this.distance = this.distanceMax;
	}

	function initStartPanel(){
		//_root.test+="initStartPanel\n"
		super.initStartPanel();
		this.startPanel.toRead = 2;
	};
		
	function initSprites(){
		super.initSprites();
		this.genTzongre();
		
		this.genGroundFruit();
		
		// PIQUET
		var y = this.map.height - this.map.groundLevel
		var obj = this.newDecor("decorPiquetPlant",{x:this.plantPoint,y:y})
		this.piquet = obj.path
		this.piquet.p._y = -this.distanceMax;
		this.picPos = {x:this.plantPoint,y:y-this.distanceMax}
		//
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
	
	function genGroundFruit(){
		var w = 1.4
		var r = w*12
		var initObj = {
			x:r+random(kaluga.Cs.mcw-(2*r)),
			weight:w
		};
		this.fruit = this.newFruit(initObj);
		this.fruit.y = this.map.height - (this.map.groundLevel + this.fruit.ray)
		this.fruit.endUpdate();
	
	}
	
	//
	function update(){
		super.update();
		switch(this.step){
			case 0 :	
				break;
			case 1 :
				/*	
				var flWasUnder = this.flUnder;
				var flUnder = this.fruit.y > this.picPos.y;
				if(this.flUnder){
					
				}
				*/
				var y = this.fruit.y+this.fruit.ray;
				//_root.test="this.picPos.y("+this.picPos.y+")\n"
				//_root.test+="this.fruit.y("+this.fruit.y+")\n"
				
				if( this.fruit.vity>1 && y > this.picPos.y && (y-this.fruit.vity*kaluga.Cs.tmod) < this.picPos.y ){
					//_root.test+="trav!\n"
					var dif = this.fruit.x - this.picPos.x;
					if( Math.abs(dif)<this.zoneRay){
						//_root.test+="plounc!\n"
						this.hitPiquet(dif);
					}
				};
			
			
				break;
			case 2 :
				this.waitTimer -= kaluga.Cs.tmod
				if( this.waitTimer<0 ){
					this.score = 0;
					for( var i=0; i<this.shotMax; i++){
						this.score += this.scoreList[i];
					}
					this.addScore()
					this.endGame();
					this.step=99;
				}
				break;

		}
	}
	//
	function hitPiquet(dif){
		this.fruit.vity *= -1;
		var p = Math.max((this.fruit.getPower()-Math.abs(dif)),0)/2.8;
		p *= 1.4
		p = Math.min(p,this.distance)
		this.scoreList.push( Math.round(p*10)/10 );
		this.distance -= p;
		this.piquet.p._y = -this.distance
		this.piquet._rotation += p*dif/50
		
		var a = (piquet._rotation-90)*(Math.PI/180)
		this.picPos.x =	this.piquet.x + Math.cos(a)*this.distance
		this.picPos.y =	this.piquet.y + Math.sin(a)*this.distance
		
		this.shot--;
		this.scorePanel.setScore(this.shot)
		if(this.shot>0){
			this.step = 0;
		}else{
			this.step = 2;
			this.waitTimer = 100;
		}
		this.tzongre.release();
		
	}
	
	function onTzLink(tzongre){
		if( this.step == 0 ){
			this.step = 1;
			if( this.scorePanel == undefined ){
				this.scorePanel = this.infoBar.addElement("barScore")
				this.scorePanel.setScore(this.shot)
			}
		}
		
	}	
	
	function onTzRelease(tzongre){
		/*
		if(step==1){
			this.step = 0;
			//this.barTimer.kill();
		}
		*/
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
					title:"1er coup :",
					score:this.scoreList[0]+"cm"
				},
				{
					type:"littleScore",
					title:"2eme coup :",
					score:this.scoreList[1]+"cm"
				},
				{
					type:"littleScore",
					title:"3eme coup :",
					score:this.scoreList[2]+"cm"
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
		//_root.test+="[trial.Plant] updateResult\n"
		var score;
		switch(player.id){
			case 0: // KALUGA
				score = 80+random(180)		// 17
				break;
			case 1: // PIWALI
				score = 120+random(120)		// 18
				break;
			case 2: // NALIKA
				score = 40+random(120)		// 10
				break;
			case 3: // GOMOLA
				score = 160+random(200)		// 26
				break;
			case 4: // MAKULO
				score = 60+random(300)		// 21
				break;
		}
		score *= this.tournament.difCoef/10;
		player.results[this.tournament.eventId].base = score;
		super.updateResult(player);
	}
	
//{	
}
