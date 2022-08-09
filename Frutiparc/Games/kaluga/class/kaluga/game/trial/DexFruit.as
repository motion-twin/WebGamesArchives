class kaluga.game.trial.DexFruit extends kaluga.game.Trial{//}
	// CONSTANTES
	var launchPoint:Number = 1400
	var minPoint:Number = 1500
	var panAccel:Number = 1;
	
	// VARIABLES
	var flValidate:Boolean;
	var flPanPressLeft:Boolean;
	var flPanPressRight:Boolean;
	var timer:Number;
	var step:Number;
	var scoreTarget:Number;
	var distance:String;
	//var meterLogList:Array;
	//var camWaitList:Array;
	//var scoreList:Array;
	
	// REFERENCES
	var panCompt:MovieClip;
	var fruit:kaluga.sp.phys.Fruit;
	
	function DexFruit(){
		this.init();
	}
	
	function init(){
		this.type = "$dexFruit"
		this.trialId = 1;
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
		//this.meterLogList = new Array;
		
		this.flPanPressLeft = false
		this.flPanPressRight = false
		this.initScroller();
	}

	function initSprites(){
		super.initSprites();

		this.genPanier();
		this.panier.x = this.minPoint
		this.panier.y = this.map.height - ( this.map.groundLevel + 90 )
		this.setCameraFocus(this.panier)
		this.moveMap(false);
		//_root.test+="<("+this.mapDecal.x+","+this.mapDecal.y+")\n"
		this.map.update();
		this.panier.endUpdate();
		
		this.genSquirrelJudge(this.launchPoint);
		this.squirrel.focus = this.panier;
		
	}
	
	function startGame(){
		super.startGame();
		this.attachMovie( "panierCompteur", "panCompt", this.dp_panier+1, { _x:this.panier._x, _y:this.panier._y } )
		_root.test += "panCompt("+this.panCompt+")\n"
		this.step = 10;
	}
	
	function initStartPanel(){
		super.initStartPanel();
		this.startPanel.toRead = 2;
	};	
	
	function genGroundFruit(){
		var initObj = {
			x:200,
			weight:1
		};
		this.fruit = this.newFruit(initObj);
		this.fruit.y = this.map.height+this.map.groundLevel - this.fruit.ray
		this.fruit.endUpdate();
	}
	
	function genTzongre(){
		var initObj = this.tzongreInfo
		initObj.x = kaluga.Cs.mcw/2
		initObj.y = kaluga.Cs.mch/2
		initObj.vity = -4
		initObj.flLauncher = true
		this.tzongre = this.newTzongre(initObj);
		this.tzongre.unFreeze();
		this.setCameraFocus(this.tzongre)
	};
	
	//
	function update(){
		//_root.test = this.step;
		
		super.update();
		//_root.test=" antList "+this.antList.length+"\n"
		switch(this.step){
			case 0 :	// PREPARATION
				break;
			case 1 :	// SOULEVER
				if( this.squirrel.status == undefined && this.fruit.x > this.launchPoint ){
					this.squirrel.setStatus(0);
					this.flValidate = false;
					// A DEPLACER
					var obj = {
						label:"basic",
						list:[
							{
								type:"msg",
								title:"Faute !",
								msg:"Vous avez dépassé la ligne de lancé"
							}
						]
					}
					this.endPanelStart.push(obj)	
				}
				break;			
			case 2 :	// LANCER
				if( this.squirrel.status == undefined and this.fruit.x > this.launchPoint ){
					this.squirrel.setStatus(1);
					this.flValidate = true;
				}
				
				if( this.fruit.flGround){
					this.miss()
				}
				break;				
			case 3 :	// END TIMER
				this.timer -= kaluga.Cs.tmod;
				if(this.timer<0){
					this.endGame();
					this.step = 99;				
				}
				break;
			case 4 :	// ENDGAMEPANEL
				break;	
			case 10: 	// PLACE LE PANIER
				this.movePanier()
				this.panCompt._x = this.panCompt._x*0.8 + this.panier._x*0.2
				this.panCompt._y = this.panCompt._y*0.8 + this.panier._y*0.2
				this.scoreTarget = Math.round((this.panier.x - this.launchPoint))
				this.panCompt.field.text =  this.scoreTarget + " cm"
				break;
		}

	}
	//
	
	function movePanier(){
		if( Key.isDown(this.mng.pref.$key[1]) or this.flPanPressLeft ){
			this.panier.vitx -= this.panAccel*kaluga.Cs.tmod
			this.panCompt.f1.gotoAndPlay(10);
			this.panCompt.f2.gotoAndPlay(1);
		}
		if( Key.isDown(this.mng.pref.$key[2]) or this.flPanPressRight ){
			this.panier.vitx += this.panAccel*kaluga.Cs.tmod
			this.panCompt.f1.gotoAndPlay(1);
			this.panCompt.f2.gotoAndPlay(10);			
		}
		if( Key.isDown(this.mng.pref.$key[4]) ){
			this.step = 0;
			this.genTzongre();
			this.setCameraFocus(this.tzongre);
			this.squirrel.focus = this.tzongre;
			this.panCompt.removeMovieClip();
			this.genGroundFruit();
		}
		if( this.panier.x<this.launchPoint+100 ){
			this.panier.vitx *= -1;
			this.panier.x = this.launchPoint+100;
		}
		
		this.panier.compt._rotation = -this.panier._rotation;
	}
	
	function miss(){
		//_root.test+=" ground!\n"
		this.step = 3;
		this.timer = 60
		
		var obj = {
			label:"basic",
			list:[
				{
					type:"msg",
					title:"Perdu !",
					msg:" Vous n'avez pas réussi atteindre le panier"
				}
			]
		}
		this.endPanelStart.push(obj)
	}
	
	function onTzRelease(tzongre){
		this.setCameraFocus(this.tzongre.linkList[0])
		if(this.step==1){
			this.step++;
			this.map.initRuler(this.launchPoint);
		}
		this.flLinkActive = false;
		//tzongre.disableLink()
	}	

	function onTzLink(tzongre){
		this.step = 1;
	}

	function onAddFruit(){
		_root.test+="onAddFruit\n"
		this.setCameraFocus(this.panier)
		if(this.flValidate){
			this.score = this.scoreTarget;
			this.addScore();
		}
		
		this.timer = 50;
		this.step = 3;
		//this.endGame();
	}
		
	function overTheLine(){
		var obj = {
			label:"basic",
			list:[
				{
					type:"msg",
					title:"Faute!",
					msg:"Vous devez lacher la pomme avant qu'elle ne franchisse la ligne !"
				}
			]
		}
		this.endPanelStart.push(obj)
	}
		
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
				score = 500+random(600)		// 800
				if(!random(8))score=0;
				break;
			case 1: // PIWALI
				score = 1000+random(400)		// 1200
				if(!random(2))score=0;
				break;
			case 2: // NALIKA
				score = 400+random(200)		// 500
				if(!random(20))score=0;
			case 3: // GOMOLA
				score = 1600+random(800)		// 2400
				if(!random(2))score=0;
				break;
			case 4: // MAKULO
				score = 300+random(1600)		// 1100
				if(!random(4))score=0;
				break;
		}
		score *= this.tournament.difCoef/10;
		player.results[this.tournament.eventId].base = score;
		super.updateResult(player);
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
//{	
}