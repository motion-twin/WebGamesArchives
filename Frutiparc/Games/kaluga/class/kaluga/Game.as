class kaluga.Game extends kaluga.Slot{//}
	
	// CONSTANTES
	var dp_debugDraw:Number =	6200;
	var dp_endGamePanel:Number =	5880;
	var dp_mapLoading:Number =	5864;
	var dp_whiteScreen:Number =	5860;
	var dp_infoBar:Number =		5840;
	var dp_scroller:Number =	5820;
	var dp_feuillage:Number =	5800;
	var dp_frontDecor:Number =	5790;
	var dp_ground:Number =		5780;
	var dp_FX:Number =		5000;
	var dp_tzongre:Number =		2500;
	var dp_bads:Number =		1800;
	var dp_fruit:Number =		1000;
	var dp_fruitBack:Number =	450;
	var dp_fil:Number = 		500;
	
	var dp_panier:Number =		45;
	var dp_decor:Number = 		15;
	var dp_map:Number = 		10;
	
	var depthListMax:Number = 	500;
	var FXMax:Number =		500;
	//
	//var antLimit:Number = 18;
	//
	var groundCaseSize:Number = 	28;	// was 20
	//
	var whiteFadeSpeed:Number =	3;
	var whiteFadeMax:Number =	60;
	
	// PARAMETRES
	var tzongreInfo:Object;

	// VARIABLES
	var flEndGame:Boolean;
	var flEndingGame:Boolean;
	var flFeuillage:Boolean;
	var flLinkActive:Boolean;
	var flFading:Boolean;
	var flWhiteScreen:Boolean;
	var flSavingScore:Boolean;
	
	var friction:Number;
	var groundFriction:Number;
	var grav:Number;
	//
	var score:Number;
	var frict:Number
	var groundFrict:Number
	var fxNum:Number;
	var level:Number;
	var masterStep:Number;
	var endTimer:Number;
	//
	var type:String;
	var endGameMsg:String;
	var mode:String;
	//
	var depthList:Array;
	var coupleList:Array;
	var groundList:Array;
	var spriteList:Array;
	var fruitList:Array;
	var badList:Array;
	var birdList:Array;
	var caterpillarList:Array;
	var physList:Array;
	var antList:Array;
	var squirrelList:Array;
	var frogList:Array;
	var butterflyList:Array;
	var particuleList:Array;
	var decorList:Array;

	//var endPanelList:Array;
	var endPanelStart:Array;
	var endPanelMiddle:Array;
	var endPanelEnd:Array;

	//
	var stat:ext.game.Stat;
	var statCombo:ext.game.Stat;
	var mapDecal:Object;
	//
	var camFocus:Object;
	var camBox:Object;
	var mapInfo:Object;
	var keyListener:Object;
	var tournament:Object;
	
	//DEBUG
	var debugCoef:Number;
	var dbgGroundLineList:Array;
	
	// REFERENCES
	var scorePanel:kaluga.bar.Score;
	var kiloPanel:kaluga.bar.Disc;
	var card:Object;
	
	// MOVIECLIPS
	var map:kaluga.Map;
	var mask:MovieClip;
	var tzongre:MovieClip;
	var panier:MovieClip;
	var fil:MovieClip;
	var scroller:MovieClip;
	var infoBar:MovieClip;
	var whiteScreen:MovieClip;
	var endGamePanel:MovieClip;
	var startPanel:MovieClip;
	var decor:MovieClip;
	var frontDecor:MovieClip;
	var mcGround:MovieClip;
	var feuillage:MovieClip;
	var mapLoading:MovieClip;
	var debugDraw:MovieClip;
	
	function Game(){
		//this.init();
	}
	
	function init(){
		//_root.test+="init()\n"
		this.initDefault();
		super.init();
		this.flFading  = false;
		this.flWhiteScreen  = false;
		this.initWhiteScreen(100);
		this.mapDecal = {x:0,y:0};
		this.initMap(this.mapInfo);
		this.masterStep = 0;
		// SOUNDS
		this.mng.music.stop(42)
		this.mng.music.loop("sJeuLoop0",42)
		//this.mng.music.loop("sMenuLoop",42)
		
		//* DEBUG DRAW
		this.createEmptyMovieClip( "debugDraw", this.dp_debugDraw )
		this.debugDraw.createEmptyMovieClip( "line", 1 )
		//*/
		

	}

	function initMap(initObj){
		initObj.game = this;
		this.attachMovie( "map", "map", this.dp_map, initObj )
		this.map.loadBackground(initObj.skinLink,true)
		
		this.attachMovie("mapLoading","mapLoading",this.dp_mapLoading)
		
		/*
		// MASK	
		this.attachMovie("mask","mask",this.dp_map+1)
		this.mask._xscale = kaluga.Cs.mcw
		this.mask._yscale = kaluga.Cs.mch
		this.map.setMask(this.mask)
		*/
		// FIL
		this.createEmptyMovieClip("fil",this.dp_fil)
		/*
		// SOL
		this.attachMovie("ground","mcGround",this.dp_ground)
		this.mcGround._y = kaluga.Cs.mch
		if(initObj.groundLabel == undefined )
		this.mcGround.gotoAndStop(initObj.groundLabel)
		*/
	}	
	
	function initGame(){
		this.mapLoading.removeMovieClip();
		//_root.test+="initGame()\n"
		this.fadeTo(60,{obj:this, method:"initStartPanel"})
		//
		this.stat = new ext.game.Stat();
		this.statCombo = new ext.game.Stat();
		this.flEndGame = false;
		this.flEndingGame = false;
		this.initList();
		for(var i=0; i<this.depthListMax; i++)this.depthList[i]=i;
		this.fxNum = 0;
		this.score = 0;
		this.initDecor();
		this.initGroundList();
		this.initSprites();
		this.initInfoBar();
		this.initEndPanelList();
		// DEBUG
		this.debugCoef = 0	
		this.dbgGroundLineList = new Array();		
	}
	
	function startGame(){
		this.masterStep = 1;
		this.tzongre.unFreeze();
	}
	
	function initStartPanel(){
		// _root.test+="initStartPanel()\n"
		this.attachMovie("startPanel","startPanel",this.dp_endGamePanel)
		this.startPanel.pano.gotoAndStop(this.type)
		this.startPanel._x = kaluga.Cs.mcw/2
		this.startPanel._y = kaluga.Cs.mch/2
		
		this.startPanel.onPress = function(){
			this._parent.startPanelForward()
		}
		
		this.keyListener = new Object();
		this.keyListener.game = this
		this.keyListener.onKeyDown = function () {
			if(Key.isDown(Key.SPACE)){
				this.game.startPanelForward();
			}
		}
		Key.addListener(this.keyListener);
		
		
		
	}
	
	function startPanelForward(){
		this.startPanel.toRead--
		if(this.startPanel.toRead==0){
			this.startPanel.gotoAndPlay("ready")
		}else{
			this.startPanel.pano.nextFrame();
		}
	}
			
	function endStartPanel(){
		//_root.test+="endStartPanel\n"
		this.startPanel.removeMovieClip();
		this.fadeTo(0,{obj:this, method:"startGame"})
		Key.removeListener(this.keyListener);
	}
	
	function initEndPanelList(){
		//_root.test+="[GAME] initEndPanelList this.mng.waitList.length("+this.mng.waitList.length+")\n"
		
		this.endPanelStart = new Array();
		this.endPanelMiddle = new Array();
		this.endPanelEnd = new Array();
		// REJOUER
		//_root.test+="initEndPanelList this.mode("+this.mode+")\n"

		var max;
		switch(this.mode){
		
				case "single":
					if( this.mng.client.isWhite() || this.type=="$train" ){
						this.addReplayPanel()
					}else{
						this.endPanelEnd.push("kill")
					}		
					break;
				case "triathlon":
					var max = 2
				case "heptathlon":
					if( max == undefined ) max = 6;
					//_root.test+="evantId:"+this.mng.tournament.eventId+" < max:"+max+"\n"
					if( this.mng.tournament.eventId < max ){
						
						this.addContinuePanel()
					}else{
						if( this.mng.client.isWhite() ){
							this.endPanelEnd.push("menu")
						}else{
							this.endPanelEnd.push("kill")
						}
					}
					break;
			
		}
	}
	
	function addReplayPanel(){
		var obj = {
			list:[
				{
					type:"margin",
					value:100
				},
				{
					type:"title",
					title:"Rejouer?"
				},
				{
					type:"but",
					title:"oui",
					callback:{obj:this,method:"reset"}
				},
				{
					type:"but",
					title:"non",
					callback:{obj:this.mng,method:"backToMenu"}
				}				
			]
		}
		this.endPanelEnd.push(obj)
	}
	
	function addContinuePanel(){
		var obj = {
			list:[
				{
					type:"margin",
					value:100
				},
				{
					type:"title",
					title:"Continuer?"
				},
				{
					type:"but",
					title:"oui",
					callback:{obj:this,method:"kill"}
				},
				{
					type:"but",
					title:"non",
					callback:{obj:this.mng,method:"backToMenu"}
				}				
			]
		}
		this.endPanelEnd.push(obj)		
	}
		
	function initList(){
		//
		this.particuleList = new Array();
		this.depthList = new Array();
		this.decorList = new Array();
		//SPRITES
			this.butterflyList = new Array();
			// BADS
			this.badList = new Array();
			this.birdList = new Array();
			this.caterpillarList = new Array();
			this.squirrelList = new Array();
			this.frogList = new Array();
			this.antList = new Array();
			//
			this.fruitList = new Array();
			this.physList = new Array();
	}
	
	function initDefault(){
		//_root.test+="[Game] initDefault\n"
		if(this.flLinkActive == undefined) 	this.flLinkActive = true;
		if(this.friction == undefined)		this.friction = 0.982 //0.982//0.982;
		if(this.groundFriction == undefined)	this.groundFriction = 0.9;
		if(this.grav == undefined)		this.grav = 0.5;
		if(this.level == undefined) 		this.level = 0;
		//if(this.card == undefined) 		this.card = this.mng.card[this.type]
		if(this.mapInfo == undefined){
			this.mapInfo = {
				width:700,
				height:480,
				skinLink:this.mng.client.getFileInfos("map/dawn.swf").name
			}
		}
		
		//_root.test+="this.card("+this.card+")\n"
		//_root.test+="this.mng.card("+this.mng.card+")\n"
		//_root.test+="this.type("+this.type+")\n"
		
	}
	
	function initDecor(){
		this.createEmptyMovieClip("decor",this.dp_decor)
		this.createEmptyMovieClip("frontDecor",this.dp_frontDecor)
		this.decor.d = 0;
		this.frontDecor.d = 0;
		//this.decor._alpha = 20;
	}
	
	function initGroundList(){
		this.groundList = new Array();
		var max = Math.ceil(this.map.width/this.groundCaseSize)
		for(var i=0; i<max; i++){
			this.groundList.push(new Array())
		}
	}
	
	function initSprites(){

	}
	
	function initScroller(){
		this.attachMovie("scroller","scroller",this.dp_scroller)
	}

	function initInfoBar(){
		this.attachMovie("infoBar","infoBar",this.dp_infoBar)
		this.infoBar._x = kaluga.Cs.mcw;
	}	
	
	function initFeuillage(frame){
		if(frame == undefined) frame = 1;
		this.attachMovie("feuillage","feuillage",this.dp_feuillage)
		this.feuillage.gotoAndStop(frame)
		this.flFeuillage = true;
		
	}
	
	function genPanier(){
		var initObj ={
			game:this,
			map:this.map,
			vity:0,
			cScale:1
		}
		this.attachMovie("spPhysPanier","panier",this.dp_panier,initObj)
		this.panier.x = random(kaluga.Cs.mcw)
		this.panier.y =  this.map.height-(this.map.groundLevel + this.panier.ray)
		
		this.panier.endUpdate();

	}
	//
	function update(){
		
		//this.updateDebugDraw();
		
		
		if( this.flFading ){
			this.fade();
		}
		
		//_root.fps = this.fruitList.length;
		
		switch(this.masterStep){
			case 0:
				break;
			case 1:
				// FAIT BOUGER LA MAP
				if(this.camFocus!=undefined){
					this.moveMap(true);
				}
				this.map.update();		
				
				// EFFACE LES FILS
				this.fil.clear();
				this.fil.lineStyle(1,0xFFFFFF,50)		
				// CALCUL DE LA FRICTION
				this.frict = Math.pow(this.friction,kaluga.Cs.tmod)
				this.groundFrict = Math.pow(this.groundFriction,kaluga.Cs.tmod)
				
				if(!this.flEndGame){
					// BOUGE LA TZONGRE
					this.tzongre.update();
					// BOUGE LE PANIER
					this.panier.update();
					// BOUGE LES BADS
					for(var i=0; i<this.badList.length; i++){
						//_root.test+="this.badList[i]("+this.badList[i]+")\n"
						this.badList[i].update();
					}
					// BOUGE LES BUTTERFLY
					for(var i=0; i<this.butterflyList.length; i++){
						this.butterflyList[i].update();
					}		
					// BOUGE LES FRUITS
					for(var i=0; i<this.fruitList.length; i++){
						this.fruitList[i].update();
					}
					// BOUGE LES DECORS
					for(var i=0; i<this.decorList.length; i++){
						this.updateDecor(this.decorList[i])
					}		
					// BOUGE LES PARTICULES
					this.moveParticule();
					
					// ENDGAME
					if( this.flEndingGame ){
						this.endTimer -= kaluga.Cs.tmod;
						if( this.endTimer < 0 ){
							this.tzongre.freeze();
							this.fadeTo(80,{obj:this,method:"genEndGamePanel"})
							this.masterStep = 2;
						}
					}
				}

				// DESSINE LES LINKS
				this.tzongre.drawLink();	
				
				break;
				
				
			case 2:
				//_root.test+="this.endGamePanel("+this.endGamePanel+")\n"
				this.endGamePanel.sheet.panel.update();
				break;
				
				
		}
		
		
		// FPS
		_root.fps = 40/kaluga.Cs.tmod;
		
		// COMMAND
		if( Key.isDown(Key.ENTER) && _root.command != "" ){
			this.executeCommand(_root.command);
			_root.command=""

		}		
		
		
		
			
	}
	//

	function updateScore(){
		this.score = Math.max( 0, this.score )
		this.scorePanel.setScore(this.score)
	}
	
	function newFruit(initObj){
		var d = this.depthList.pop();	
		if( initObj == undefined) initObj = new Object();
		initObj.game = this;
		initObj.map = this.map;
		initObj.depth = d
		this.attachMovie("spPhysFruit","fruit"+d,this.dp_fruit+d,initObj);
		var mc = this["fruit"+d]
		this.fruitList.push(mc)
		this.physList.push(mc)
		return mc;
	}
	
	function setCameraFocus(focus){
		if(focus!=undefined && this.camBox==undefined)this.setCameraBox("wide");
		this.camFocus = focus
		
	}
	
	function setCameraBox(box){
		 if(box=="wide"){
			box = {
				x:0,
				y:0,
				w:this.map.width,
				h:this.map.height
			}		
		}
		this.camBox = box
	}
	
	function moveMap(lagFlag){
		//_root.test+="moveMap("+this.mapDecal.x+","+this.mapDecal.y+")\n"
		var c = Math.pow(0.8,kaluga.Cs.tmod);	//0.5
		var x = kaluga.Cs.mcw/2 - this.camFocus.x;
		var y = kaluga.Cs.mch/2 - this.camFocus.y;
		var box = this.camBox
		x = Math.max( kaluga.Cs.mcw-box.w, Math.min(x,box.x) );
		y = Math.max( kaluga.Cs.mch-box.h, Math.min(y,box.y) );
		if(lagFlag){
			this.mapDecal.x = c*this.mapDecal.x + x*(1-c);
			this.mapDecal.y = c*this.mapDecal.y + y*(1-c);
		}else{
			this.mapDecal.x = x;
			this.mapDecal.y = y;	
		}

	}

	function removeFromGround(list,mc){
		for( var i=0; i<list.length; i++ ){
			if( list[i] == mc ){
				list.splice(i,1);
				delete mc.groundId;
				return;
			}
		}		
	}
	
	// TZONGRE
	function newTzongre(initObj,d){
		if( initObj == undefined ) initObj = this.tzongreInfo;
		if( d == undefined ) d = 0;
		initObj.game = this
		initObj.map = this
		
		
		this.attachMovie("spPhysTzongre","tzongre"+d,this.dp_tzongre+d,initObj)
		var mc = this["tzongre"+d]
		this.spriteList.push(mc);
		return mc;
	}	
	
	// BADS
	function newBird(initObj){
		var d = this.depthList.pop();
		if( initObj == undefined) initObj = new Object();
		initObj.game = this;
		initObj.map = this.map;
		initObj.depth = d		
		this.attachMovie("spBadsBird","bird"+d,dp_fruit+d,initObj);
		var mc = this["bird"+d];
		this.badList.push(mc)
		this.birdList.push(mc)
		this.spriteList.push(mc);
		this.tzongre.target = mc;
		return mc;
	}	
	
	function newCaterpillar(initObj){
		var d = this.depthList.pop();
		if( initObj == undefined) initObj = new Object();
		initObj.game = this;
		initObj.map = this.map;
		initObj.depth = d		
		this.attachMovie("spBadsCaterpillar","caterpillar"+d,dp_bads+d,initObj);
		var mc = this["caterpillar"+d];
		//_root.test+="caterPillar("+mc+")\n"
		this.badList.push(mc)
		this.caterpillarList.push(mc)
		this.physList.push(mc)
		this.spriteList.push(mc);
		return mc;
	}		

	function newAnt (initObj){
		var d = this.depthList.pop();
		if( initObj == undefined) initObj = new Object();
		initObj.game = this;
		initObj.map = this.map;
		initObj.depth = d;
		this.attachMovie("spBadsAnt","ant"+d,dp_bads+d,initObj);
		var mc = this["ant"+d];
		this.antList.push(mc)
		this.badList.push(mc);
		this.physList.push(mc);
		this.spriteList.push(mc);
		return mc;
	}	

	function newSquirrel (initObj){
		var d = this.depthList.pop();
		if( initObj == undefined) initObj = new Object();
		initObj.game = this;
		initObj.map = this.map;
		initObj.depth = d;
		this.attachMovie("spBadsSquirrel","squirrel"+d,dp_bads+d,initObj);
		var mc = this["squirrel"+d];
		this.squirrelList.push(mc);
		this.badList.push(mc);
		this.physList.push(mc);
		this.spriteList.push(mc);
		return mc;
	}	
	
	function newButterfly(initObj){
		var d = this.depthList.pop();
		if( initObj == undefined) initObj = new Object();
		initObj.game = this;
		initObj.map = this.map;
		initObj.depth = d;
		this.attachMovie( "spButterfly", "butterfly"+d, dp_bads+d, initObj );
		var mc = this["butterfly"+d];
		this.butterflyList.push(mc);
		this.spriteList.push(mc);
		return mc;	
	}
	
	function newFrog (initObj){
		var d = this.depthList.pop();
		if( initObj == undefined) initObj = new Object();
		initObj.game = this;
		initObj.map = this.map;
		initObj.depth = d;
		this.attachMovie( "spBadsFrog", "frog"+d, dp_bads+d, initObj );
		var mc = this["frog"+d];
		//_root.test+="frog("+mc+")"
		this.frogList.push(mc);
		this.badList.push(mc);
		this.physList.push(mc);
		this.spriteList.push(mc);
		return mc;		
	}
	
	// PARTICULES
	function newFX(link){
		this.fxNum = (this.fxNum+1)%this.FXMax
		this.attachMovie(link,link+"_"+this.fxNum, this.dp_FX + this.fxNum)
		var mc = this[link+"_"+this.fxNum]
		mc.x = 0
		mc.y = 0
		mc.vitx = 0
		mc.vity = 0
		return mc;
	}

	function moveParticule(){
		for(var i=0; i<this.particuleList.length; i++){
			//_root.test+="o"
			var mc = this.particuleList[i]
			var death = false;
			switch(mc.mode){
				case 0:	//¨PLUME
					//_root.test+="mc.vity("+mc.vity+")\n"
					if(mc.flGround!=true){
						mc.vity += 0.2;	
						mc.vitx *= this.frict;
						mc.vity *= this.frict;
						mc.x += mc.vitx * kaluga.Cs.tmod;
						mc.y += mc.vity * kaluga.Cs.tmod;
						mc._x = mc.x + this.mapDecal.x;
						mc._y = mc.y + this.mapDecal.y;
					}
					mc.time -= kaluga.Cs.tmod;
				
					if(mc.time<10){
						mc._alpha = mc.time*10;
						if(mc.time<0){
							mc.removeMovieClip();
							death = true;
						}
					}
					//ground
					var gy = this.map.height-this.map.groundLevel
					if(mc._y>gy){
						mc.flGround = true;
						mc._y = gy
					}
					break ;
				case 1:	//FIXE
					mc._x = mc.x + this.mapDecal.x;
					mc._y = mc.y + this.mapDecal.y;				
					break;
			}
			if(death){
				this.particuleList.splice(i,1)
				i--;
			}
		}
	}
	
	function dropFeuille(x,y){
		var mc = this.newFX("plume");
		this.particuleList.push(mc);
		var sens = random(2)*2-1
		mc.gotoAndPlay(random(40)+1)
		mc.vitx = random(10)-5;
		mc.vity = 0
		mc.x = x
		mc.y = 0
		mc._xscale = sens*100
		mc.time = 60+random(20);
		mc.mode = 0;
		mc.p.gotoAndStop(2+random(4))
		return mc;
	}
	
	function shootFeuillage(x,power){
		
		if(this.mng.pref.$param[2]){
			var p = power/(20*kaluga.Cs.tmod);
			var max = p+random(p)
			for(var i=0; i<max; i++){
				this.dropFeuille(x,-random(20))
			};
		}
		// SOUND
		this.mng.sfx.playSound("sBush",11)
		this.mng.sfx.setVolume(11,power*1.5)
		
		
		
	}
	
	function deActiveLink(){
		this.flLinkActive = false;
		if(this.tzongre.linkList.length>0)this.tzongre.release();
	}
	
	function activeLink(){
		this.flLinkActive = true;
	}
	
	
	// A FACTORISER
	function removeFruit(fruit){
		for(var i=0; i<this.fruitList.length; i++){
			if( this.fruitList[i] == fruit){
				this.fruitList.splice(i,1)
				return;
			}
		}
	}
	
	function removePhys(phys){
		for(var i=0; i<this.physList.length; i++){
			if( this.physList[i] == phys){
				this.physList.splice(i,1)
				return;
			}
		}
	}
	
	function removeCaterpillar(mc){
		for(var i=0; i<this.caterpillarList.length; i++){
			if( this.caterpillarList[i] == mc ){
				this.caterpillarList.splice(i,1);
				return;
			}
		}
	}		
	/*
	function removeBad(mc){
		for(var i=0; i<this.badList.length; i++){
			if( this.badList[i] == mc ){
				this.badList.splice(i,1);
				return;
			}
		}
	}
	*/
	function removeFromList(mc,listName){
		var list = this[listName]
		for(var i=0; i<list.length; i++){
			if( list[i] == mc ){
				list.splice(i,1);
				return;
			}
		}
	}
	
	
	// OPTIONS EFFECTS
	function fruitJumpIn(){
		for(var i=0; i<this.fruitList.length; i++){
			var fruit = this.fruitList[i]
			if( fruit.flGround and !fruit.flTree ){
				fruit.exitGroundMode();
				fruit.flScNoLink = false
				var dif = fruit.x - this.panier.x;
				fruit.vity = -( 8+(random(100)/10)+(fruit.weight*10) )
				fruit.vitx = -dif/((16-(fruit.vity*1.2))-(fruit.weight*4))
			}
		}
	}
	
	function fruitJumpOut(){
		for(var i=0; i<this.fruitList.length; i++){
			var fruit = this.fruitList[i]
			if( !fruit.flScoreAble && fruit.flGround && !fruit.flTree ){
				fruit.exitGroundMode();
				var center = this.map.width/2
				var dif = (fruit.x-center);
				fruit.vitx = (center*4*fruit.weight)/dif //dif*fruit.weight/10
				fruit.vity = -(6+random(100)/10);
			}
		}			


	}
	
	
	// ENDGAME
	function loose(msg){
		//this.endGameMsg = msg;
		var obj = {
			label:"basic",
			list:[
				{
					type:"msg",
					title:"Perdu !",
					msg:msg
				}
			
			]
		}
		this.endPanelStart.push(obj)
		this.endGame();	
	}
	
	function endGame(timer){
		if(!this.flEndingGame){
			this.initEndGame(timer);
		}
	}
	
	function initEndGame(timer){
		//_root._rotation = 2
		//_root.test+="initEndGame("+timer+"))\n"
		if( timer == undefined ) timer = 0;
		this.endTimer = timer;
		this.flEndingGame = true;
		
		// SAVESCORE
		//_root.test+="[GAME] initEndGame //saveScore("+this.score+",{tz:"+this.tzongreInfo.id+"})\n"
		//_root.test+=" - ("+this.mng.client.saveScore+")\n"
		
		if(this.type!="$train" && this.tournament == undefined ){
			this.saveScore(this.score);
		}
		this.mng.client.saveSlot(0);
	}
	
	
	function saveScore(score){
	
		this.flSavingScore = true;
		this.mng.client.saveScore( score, {tz:this.tzongreInfo.id} );		
		var obj = {
			label:"basic",
			wait:{ o:this, v:"flSavingScore" },
			list:[
				{
					type:"msg",
					title:"",
					msg:"sauvegarde du score..."
				}
			]
		}
		this.endPanelStart.push(obj)				
		break;		
	}
	
	
		
	function genEndGamePanel(){
		this.attachMovie("endGamePanel","endGamePanel",this.dp_endGamePanel)
		//_root.test+="genEndGamePanel("+this.endGamePanel+")!!!\n"
	}
	
	function setEndGamePanel(sheet){
		var initObj = new Object();
		initObj.game = this;
		initObj.list = this.endPanelStart.concat(this.endPanelMiddle).concat(this.endPanelEnd)//this.endPanelList;
		//_root.test+="("+this.endPanelStart.length+","+this.endPanelMiddle.length+","+this.endPanelEnd.length+")\n"
		sheet.attachMovie("panel","panel",1,initObj);
	}
	
	function checkUnlock(n){
		if( this.mng.client.isWhite() ){
			var list = this.mng.card.$mode[n]
			
			//_root.test+="this.score:"+this.score+"\n"
			//_root.test+="goal:"+this.goalList[this.level]+"\n"


			if( this.level<3 && !list[this.level+1] ){
				var o = {
					label:"congrat",
					list:[
						{
							type:"congrat",
							text:"Vous avez débloqué le mode "+this.mng.difNameList[this.level+1]+"!!\n",
							id:10
						}
					]
				};
				this.endPanelMiddle.push(o)					
				this.mng.card.$mode[n][this.level+1] = 1;
			};
			// TITEM + TZONGRES
			switch(this.level){
				case 0:
					this.addTitem("$butterfly"+(n-2))
					break;
				case 1:
					this.addTitem("$smiley"+(n-2))
					break;
				case 2:
					var tzUnlockList = [1,4,3,2]
					var id = tzUnlockList[n-2]
					var o = {
						label:"congrat",
						list:[
							{
								type:"congrat",
								text:"Vous avez débloqué une nouvelle tzongre : "+this.mng.tzInfo[id].name+"!!\n",
								id:id
							}
						]
					};
					this.endPanelMiddle.push(o)					
					this.mng.card.$tz[id] = 1;
					this.addTitem("$tz"+id)

					break;
				case 3:
					var unlockList = [ "$basket", "$bird", "$ring", "$ant" ]
					this.addTitem(unlockList[n-2])
					break;
			}
			// SAVE SLOT
			this.mng.client.saveSlot(0);
		}
	}
	
	function addTitem(str){
		var o = {
			label:"congrat",
			list:[
				{
					type:"congrat",
					text:"Un nouveau Titem est disponible dans votre inventaire !\n",
					id:10
				}
			]
		};
		this.endPanelMiddle.push(o)
		this.mng.client.giveItem(str)
	}
	
	function addKagulga(){

		var o = {
			label:"congrat",
			list:[
				{
					type:"congrat",
					text:"Vous avez gagné la kagulga !\nEn véritable cuir de Tzongre, cette cagoule vous permettra de garder la fruticlasse en toutes circonstances !",
					id:14
				}
			]
		};
		this.endPanelMiddle.push(o)
		this.mng.client.giveAccessory("$kagulga");
	}
	
		
	
	//FADE
	function fade(){
		//_root.test+="fade\n"
		
		var c = Math.pow( 0.8, kaluga.Cs.tmod )
		this.whiteScreen.alpha = this.whiteScreen.alpha*c + this.whiteScreen.cible*(1-c);
		this.whiteScreen._alpha = this.whiteScreen.alpha
		
		if( Math.abs(this.whiteScreen.alpha-this.whiteScreen.cible) < 3 ){
			this.flFading = false;
			var c = this.whiteScreen.callback;
			c.obj[c.method](c.args);
			//_root.test+= c.obj+"["+c.method+"]("+c.args+");\n"
			if(this.whiteScreen.cible == 0 ) this.removeWhiteScreen();
		}
		
	}
	
	function fadeTo(cible,callback){
		//_root.test+="fadeTo\n"
		this.flFading = true;
		if(!this.flWhiteScreen){
			this.initWhiteScreen();
		}
		this.whiteScreen.cible = cible
		this.whiteScreen.callback = callback
		
	}

	function initWhiteScreen(alpha){
		//_root.test+="initWhiteScreen("+alpha+")\n"
		if( alpha == undefined ) alpha =0;
		this.flWhiteScreen = true;
		this.attachMovie("whiteScreen","whiteScreen",this.dp_whiteScreen)
		//this.whiteScreen._xscale = kaluga.Cs.mcw;
		//this.whiteScreen._yscale = kaluga.Cs.mch
		this.whiteScreen.alpha = alpha;
		this.whiteScreen._alpha = alpha;
	}
	
	function removeWhiteScreen(){
		//_root.test+="removeWhiteScreen()\n"
		this.flWhiteScreen = false;
		this.whiteScreen.removeMovieClip();
	}	
	
	
	// DECOR
	function newDecor(link,initObj){
		if( initObj == undefined ) initObj = new Object();
		if( initObj.depthCoef == undefined ) initObj.depthCoef = 1;
		if( initObj.xscale == undefined ) initObj.xscale = 100;
		if( initObj.yscale == undefined ) initObj.yscale = 100;
		if( initObj.width == undefined ) initObj.width = 0;
		if( initObj.corner == undefined ) initObj.corner = 0;
		
		initObj.visible = false;
		initObj.link = link;
		this.decorList.push(initObj)
		this.updateDecor(initObj);
		/*
		var base = this.decor;
		if(initObj.depthCoef>1) base = this.frontDecor;
		var d = base.d++;
		base.attachMovie(link,"decor"+d,d,initObj)
		var mc =base["decor"+d];
		if(mc.frame)mc.gotoAndStop(mc.frame);
		mc._xscale = 50 + mc.depthCoef*50
		mc._yscale = (mc.yscale/2) + mc.depthCoef*(mc.yscale/2)
		this.decorList.push(mc)
		this.updateDecor(mc);
		return mc;
		*/
		return initObj;
	}
	
	function updateDecor(obj){
		var mx = kaluga.Cs.mcw/2
		var my = kaluga.Cs.mch/2

		var dx = (obj.x + mapDecal.x)-mx
		obj.rx = mx + dx*obj.depthCoef
		obj.ry = obj.y + this.mapDecal.y*obj.depthCoef				
		
		if(obj.widthCoef != undefined ){
			var x = dx*obj.depthCoef - dx*obj.widthCoef
			obj.xscale = x*2
		}
		
		var w = obj.width*obj.xscale/100
		/*
		if(obj.width == 100 ){
			_root.test = "w>"+w+"\n"
			_root.test += "scale>"+obj.xscale+"\n"
		}
		*/
		switch(obj.corner){
			case 0 : // CENTER
				var xmin = Math.min( obj.rx-w/2, obj.rx+w/2 );
				var xmax = Math.max( obj.rx-w/2, obj.rx+w/2 );
				break;
			case 1 : // UPLEFT
				var xmin = Math.min( obj.rx, obj.rx+w );
				var xmax = Math.max( obj.rx, obj.rx+w );
				break;
		}
		
		

		var ymin = obj.ry;
		var ymax = obj.ry;		
		
		if( xmax<0 || xmin>kaluga.Cs.mcw ){
			if(obj.visible){
				//this.removeFromList(obj.path,"decor")
				obj.path.removeMovieClip();
				delete obj.path;
				obj.visible = false;				
			}else{
				
			}
		}else{
			if(!obj.visible){
				var base = this.decor;
				if(obj.depthCoef>1) base = this.frontDecor;
				
				var d = base.d++;
				base.attachMovie(obj.link,"decor"+d,d,obj)
				obj.path = base["decor"+d];
				if(obj.frame)obj.path.gotoAndStop(obj.frame);
				
				obj.path._xscale = 50 + obj.depthCoef*50
				obj.path._yscale = (obj.yscale/2) + obj.depthCoef*(obj.yscale/2)	

				obj.visible = true
			}
			
			var mc = obj.path
			//_root.test="mc>"+mc+"\n"
			mc._x = obj.rx
			mc._y = obj.ry
			mc._xscale = obj.xscale
		
		}
		
	}
		
	
	// RESET
	function reset(initObj){
		//_root.test="reset()\n"
		if( initObj==undefined ) var initObj = new Object();
		initObj.tzongreInfo = this.tzongreInfo;
		initObj.mode = "single";
		this.mng.waitList.push({link:"same",initObj:initObj});
		//_root.test="this.mng.waitList.length("+this.mng.waitList.length+")\n"
		this.kill();
	}
	
	
	// ON
	function onAddFruit(){
	}
	
	function onFruitEatFinish(){
	}
	
	function onTzDeath(){
		this.endGame(60)
	}
	
	function onPause(){
		this.mng.setPause(true)
	}
	
	
	// DEBUG
	function executeCommand(c){
		
		var space = c.indexOf(" ")
		var com = c.substring(0,space)
		//_root.test+="com("+com+")\n"
		switch(com){
			case "kill":
				var list = this[c.substring(space+1,c.length)+"List"]
				while(list.length>0)list[0].kill();
				break;
			case "trace":
				var name = c.substring(space+1,c.length)
				switch(name){
					case "ground":
						this.traceGroundList()
						break;
					default:
						_root.test+=name+"("+this[name]+")\n"
						break;
				}
				break;
		}
	}	
	
	function traceGroundList(){
		while(this.dbgGroundLineList.length>1 ){
			this.dbgGroundLineList.pop().removeMovieClip()
		}
		var d=0;
		for (var i=0; i<this.groundList.length; i++){
			var list = this.groundList[i]
			if(list.length>0){
				d++;
				this.attachMovie("groundListTracer","glt"+d,50000+d,{num:list.length})
				var mc = this["glt"+d]
				mc._x = i*this.groundCaseSize
				mc._y = this.map.height-this.map.groundLevel;
				this.dbgGroundLineList.push(mc)
			}
		}
	}
	
	function kill(){
		this.mng.music.stopSound("sJeuLoop0",42);
		super.kill();
	}
	
	function updateDebugDraw(){
		this.debugDraw.clear();
		this.debugDraw.line.clear();
		
		for (var i=0; i<this.groundList.length; i++){
			var list = this.groundList[i]
			var st = {
				x:Math.floor((i+0.5)*this.groundCaseSize),
				y:this.map.height - this.map.groundLevel
			}
			var end,col;
			for(var n=0; n<list.length; n++){
				var mc = list[n]
				if( mc == undefined ){
					end = { x:st.x, y:st.y-100}
					col = 0xFF0000
				}else if( mc.groundId != i ){
					end = { x:st.x, y:st.y-100}
					col = 0x00FF00				
				}else{
					end = mc
					col = 0xFFFFFF				
				}
				this.debugDraw.line.lineStyle(1,col)
				this.debugDraw.line.moveTo(st.x,st.y)
				this.debugDraw.line.lineTo(end.x,end.y)
				
			}
			
		}		
	}
	
	
	//
	function scoreSaved(){
	
	}
	//
	
//{	
}


























