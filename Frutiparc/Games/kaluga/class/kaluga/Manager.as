class kaluga.Manager{//}

	// CONSTANTES
	var depthStart:Number = 40;
	var depthMax:Number = 10;
	var fadeColor:Number = 0xADE76B
	var vers:Number = 1.9
	
	var nameList:Array;
	var tzInfo:Array;
	var difNameList:Array;
	var color:Object;

	// PARAMETRES
	var root:MovieClip;

	// VARIABLE
	var flTestBig:Boolean
	var flPause:Boolean;
	var flReleasePause:Boolean;
	var pauseAlpha:Number;	
	var pauseStart:Number;	
	var depth:Number;
	var slotList:Array;
	var waitList:Array;
	var tournament:Object;
	var startGameInfo:Object;
 	var so:Object;

	var card:Object;	// SLOT 0
	var pref:Object;	// SLOT 1
	//var perm:Object;	// SLOT 2

	// REFERENCES
	var mcLoading:MovieClip;
	var current:Object;//kaluga.Slot;
	var client:kaluga.Client;
	var music:kaluga.SoundManager;
	var sfx:kaluga.SoundManager;


	function Manager(root){
		this.flTestBig = false;
		this.root = root;
		//this.card = card;
		//if( this.card == undefined ) this.formatCard();
		
		this.init();
		
	}
	
	function init(){
		_root.test+="[Manager] init()\n"
		//_root.test+="kaluga.Cs.mcw("+kaluga.Cs.mcw+")\n"
		//_root.test+="kaluga.Cs.mch("+kaluga.Cs.mch+")\n"
		this.flPause = false;
		
		this.initConstant();
		this.depth = 0;
		this.waitList = new Array();
		this.slotList = new Array();
		if(this.flTestBig)this.initMask();
		
		this.client = new kaluga.Client();
		this.client.mng = this;
		this.client.serviceConnect()
		
		this.attachLoading()
		this.initSoundManager()
		
		//Std.init(32);
		/*
		_root.test = "---"
		for( var elem in Std){
			_root.test+="-"+elem+" : "+Std[elem]+"\n"
		}
		*/
	
	}
		
	function update(){
		///* TMOD PERSO
		Std.update();
		kaluga.Cs.tmod = Math.min(Std.tmod*1.2,3)
		//_root.test="Cs.tmod "+kaluga.Cs.tmod+"\n"
		//_root.test+="Std.tmod "+Std.tmod+"\n"
		//*/
		
		if( Key.isDown(27) || Key.isDown(80) ){
			if( this.flReleasePause && !this.client.forcePause ){
				this.setPause();
				this.flReleasePause = false;
			}
		}else{
			this.flReleasePause = true;
		}
		
		if(!this.flPause){
			for( var i=0; i<this.slotList.length; i++ ){
				this.slotList[i].path.update();
			}
		}else{
			this.pauseAlpha *= 0.5
			kaluga.MC.setPColor(this.current,this.fadeColor,30+this.pauseAlpha)
		}
		//_root.test="tmod("+kaluga.Cs.tmod+")\n"
	}
	
	function addSlot(link,initObj,flNoMain){
		//_root.test+="addSlot("+link+")\n"
		if( initObj == undefined ) initObj = new Object();
		initObj.mng = this;
		this.depth = (this.depth+1)%this.depthMax;
		var d = this.depth
		//
		//_root.test+="link("+link+")\n slot obfusqué en "+"slot"+"\nroot obfusqué en "+"root"+"\n"
		this.root.attachMovie(link,"slot"+d,d+this.depthStart,initObj);
		var slot = this.root["slot"+d]
		//p_root.test+="slot("+slot+")\n"
		//
		
		//_root.test+="[Manager] addSlot() link:("+link+") slot:("+slot+")\n"
		this.slotList.push({path:slot,link:link});
		if(flNoMain==undefined)this.current = slot;
		
		if(  this.flTestBig ){
			//slot.setMask(this.root.mask)
			this.root.mask._visible = false
			slot._x = this.root.mask._x
			slot._y = this.root.mask._y
		}
		
	}
	
	function removeSlot(rmSlot){
		//_root.test+="removeSlot\n"
		for(var i=0; i<this.slotList.length; i++){
			var slot = this.slotList[i].path;
			if(slot == rmSlot){
				//_root.test+="found this.waitList.length("+this.waitList.length+")\n"
				if( this.waitList.length>0 && slot == this.current){
					//_root.test+="setNext("+this.slotList[i].link+")\n"
					var info = this.waitList.shift();
					if(info.link=="same"){
						var link = this.slotList[i].link
					}else{
						var link = info.link
					}
					this.addSlot(link,info.initObj);
				}
				this.slotList.splice(i,1);
				return true;
			}
		}
		return false;
	}
	
	function loadCard(){
		/*
		_root.test+=" load card from SharedObject...\n"
		this.so = SharedObject.getLocal("kaluga/card")
		this.card = this.so.data.card
		this.pref = this.so.data.pref
		/*///*
		this.card = this.client.slots[0]
		this.pref = this.client.slots[1]
		//*/
		if( !this.client.isWhite() ){
			this.client.lockList[0] = true;
		}
		
		if(this.card == undefined ){
			this.formatCard();
		}
		if(this.pref == undefined ){
			this.formatPref();
		}
		//
		if( this.client.isBlack() || this.client.isGrey() ){
			this.card.$mode = [
				1,
				[0,0,0,0,0,0,0,0,0],
				[0,0,0,0],
				[0,0,0,0],
				[0,0,0,0],
				[0,0,0,0]
			]
		};
		//
		if( this.card.$vs < this.vers ){
			this.patchFruticard();
		}
		//SOUND
		this.updateParams();
		
	}

	function formatCard(){
		_root.test += "formatCard!!!\n"
		
		this.card = new Object();
		
		this.card.$vs = this.vers	// VERSION
		this.card.$tz = [1,0,0,0,0]
		this.card.$seq = [1,0]
		this.card.$bonus = [0,0]
		
		
		// 1 : $squirrel0
		// 2 : $squirrel2
		
		
		//this.card.$tz = [1,1,1,1,1]
		
		this.card.$mode = [
			1,
			[1,1,1,0,0,0,0,1,0],
			//[1,1,1,1,1,1,1,1,1],
			[1,0,0,0],
			[1,0,0,0],
			[1,0,0,0],
			[1,0,0,0]
		]
		
		// STAT
		this.card.$stat = {
			$fruit:0
			
		}
		
		// CLASSIC
		this.card.$classic = { $s:0 }
		
		
		// TRIAL
		this.card.$trial = new Object();
		this.card.$trial.$st = 1;
		this.card.$trial.$tria = {$s:0};
		this.card.$trial.$hept = {$s:0};
		this.card.$trial.$list = new Array();
		for(var i=0; i<7; i++){
			this.card.$trial.$list[i] = new Object();
			var card = this.card.$trial.$list[i]
			card.$list = new Array();
			card.$tz = new Array();
			card.$max = 0;
			for(var ii=0; ii<5; ii++){
				//card.$tz[ii] = { $d:{$d:0, $m:0,$y:0}, $s:0 }
				card.$tz[ii] = { $s:0 }
			};		
		}

		// CHRONO
		this.card.$chrono = new Object();
		this.card.$chrono.$st = 2
		var a = new Array();
		for(var i=0; i<4; i++){
			var a2 = new Array(); 
			var limit = 36000+i*6000
			var max = 6+i*2
			for(var ii=0; ii<max; ii++){
				a2[ii] = (ii+1)*limit/max;
			}
			a[i] = a2;
		};
		this.card.$chrono.$level = a
		
		// SURVIVAL
		this.card.$survival = new Object();
		this.card.$survival.$st = 2
		this.card.$survival.$level = new Array();
		for(var i=0; i<4; i++){
			this.card.$survival.$level[i] = { $s:0, $t:0}
		}
		
		// INVASION
		this.card.$invasion = new Object();
		this.card.$invasion.$st = 2
		this.card.$invasion.$level = new Array();
		for(var i=0; i<4; i++){
			this.card.$invasion.$level[i] = { $s:0, $t:0}
		}
		
		// RING
		this.card.$ring = new Object();
		this.card.$ring.$st = 2
		this.card.$ring.$level = new Array();
		for(var i=0; i<4; i++){
			this.card.$ring.$level[i] = { $s:600000, $t:0}
		}
		
		// LINK
		this.so.data.card = this.card
		
		// SAVECARD
		this.client.slots[0] = this.card
		
		// FIRST TITEM KALUGA
		if( this.client.isWhite() ){
			this.client.giveItem("$tz0")
		}
		
		this.client.saveSlot(0)
		
		
		
	}

	function formatPref(){
		//_root.test += "format¨Pref!!!\n"
		this.pref= {
			$key:[ Key.UP, Key.LEFT, Key.RIGHT, Key.DOWN, Key.SPACE ],
			$param:[1,1,1]
		}
		
		// LINK
		this.so.data.pref = this.pref
		
		// SAVECARD
		this.client.slots[1] = this.pref
		this.client.saveSlot(1)
		
		
		
		
	}

	function patchFruticard(){
		_root.test+="patchFruticard...\n"
		if( this.card.$vs < 1.9 ){  // PATCH 1.9 RAJOUTE LA KAGULGA A CEUX QUI NE L ONT PAS EU
			_root.test+="<1.9\n"
			if(this.card.$mode[1][8]){
				this.client.giveAccessory("$kagulga");
				_root.test+="kagulga added!\n"
			}
		}

		this.card.$vs = this.vers
		this.client.saveSlot(0)
	}
	
	
	
	function backToMenu(){
		//_root.test+="backToMenu() v2.0\n"
		this.waitList = new Array();
		this.waitList.push({link:"menu"});
		
		this.current.kill();
		/*
		while(this.slotList.length>0){
			var slot = this.slotList.pop()
			//_root.test+="killSlot("+slot+")\n"
			slot.path.kill();
		}
		*/
		
		//this.addSlot("menu");
	}	
	
	function initConstant(){
	
		this.color = {
			
			tzPastel:[
				0xB8ECB7,
				0xFFE0BB,
				0xFECFCF,
				0xCCCDEE,
				0xB8C7B8
			]
		}
		
		this.tzInfo = [
			{ id:0,	name:"Kaluga",	weight:0.3,	nbPower:1,	nbBoost:1.5,	nbBoostFrict:0.98,	nbFrict:0.96,	nbResist:0.90,	nbThrust:0.9, 	nbTurn:2.4,	nbTurnMalus:0.8,	nbDodge:1.0,	nbMulti:0,	nbCombo:0,	nbFilMax:200,	cligneRand:200,	stats:[3,4,4,3,3]		},
			{ id:1, name:"Piwali",	weight:0.4,	nbPower:2.5,	nbBoost:3,	nbBoostFrict:0.99,	nbFrict:0.98,	nbResist:0.99,	nbThrust:0.9, 	nbTurn:1.8,	nbTurnMalus:0.8,	nbDodge:1.2,	nbMulti:0,	nbCombo:1,	nbFilMax:110,	cligneRand:40, 	stats:[1,2,3,4,1]		},
			{ id:2, name:"Nalika",	weight:0.2,	nbPower:0.5,	nbBoost:1.5,	nbBoostFrict:0.96,	nbFrict:0.93,	nbResist:0.75,	nbThrust:0.9, 	nbTurn:3.2,	nbTurnMalus:0.2,	nbDodge:0.7,	nbMulti:1,	nbCombo:0,	nbFilMax:300,	cligneRand:200, stats:[6,5,1,1,6]		},
			{ id:3, name:"Gomola",	weight:0.6,	nbPower:5,	nbBoost:4,	nbBoostFrict:0.75,	nbFrict:0.98,	nbResist:0.90,	nbThrust:0.9, 	nbTurn:1.4,	nbTurnMalus:0.4,	nbDodge:2.8,	nbMulti:0,	nbCombo:0,	nbFilMax:150,	cligneRand:200,	stats:[3,1,5,6,2]		},
			{ id:4, name:"Makulo",	weight:0.25,	nbPower:1.5,	nbBoost:7,	nbBoostFrict:0.985,	nbFrict:1,	nbResist:0.95,	nbThrust:0.9, 	nbTurn:3.8,	nbTurnMalus:0.4,	nbDodge:3.2,	nbMulti:0,	nbCombo:0,	nbFilMax:220,	cligneRand:100,	stats:[2,6,6,2,4]		}	
		]
		
		this.difNameList = [
			"facile",
			"standard",
			"difficile",
			"infernal"			
		]
				
		
	}	
	
	// SOUNDS
	function initSoundManager(){
		this.root.attachMovie("mcSoundManager","music",8)
		this.root.attachMovie("mcSoundManager","sfx",9)
		this.music = this.root.music
		this.sfx = this.root.sfx
		//this.sm.play("sBonus")
		//_root.test+="sm("+this.sm+")\n"
	}
	
	function updateParams(){
		//_root.test+="[MANAGER] updateParams ("+this.pref.$param[0]+","+this.pref.$param[1]+")\n"
		this.music.setActive(this.pref.$param[0]);
		this.sfx.setActive(this.pref.$param[1]);
	}
	
	// TESTS
	function initMask(){
		this.root.attachMovie("whiteSquare","mask",100);
		this.root.mask._xscale = kaluga.Cs.mcw
		this.root.mask._yscale = kaluga.Cs.mch
		this.root.mask._x = (1500-kaluga.Cs.mcw)/2
		this.root.mask._y = (1100-kaluga.Cs.mch)/2
	};	
		
	// FRUSION
	
	function attachLoading(){
		this.root.attachMovie("mcLoading","mcLoading",20)	
	}
	
	function removeLoading(){
		this.root.mcLoading.removeMovieClip();
	}
	
	function connected(){
		//_root.test+="[Manager] connected()\n"
		this.loadCard();
		//this.addSlot("animLoader",{link:"anim/intro.swf",width:350,height:240})
		this.addSlot("menu")
		this.removeLoading();
	}
		
	function started(){
		//_root.test+="[Manager] started() this.mcLoading("+this.root.mcLoading+") this.startGameInfo:("+this.startGameInfo+")\n"
		this.addSlot( this.startGameInfo.link, this.startGameInfo.initObj )
		//this.removeLoading();
	}
	
	function scoreSaved(){
		//_root.test+="[Manager] score saved !\n"
		//this.removeLoading();
		this.current.flSavingScore = false;
		this.current.scoreSaved();
	}
	
		// PAUSE
	function setPause(flag){
		
		
		if(flag==undefined) flag = !this.flPause;
		//_root.test+="setPause("+flag+")\n"
		this.flPause = flag;
		if(this.flPause){
			this.root.attachMovie( "mcPause", "mcPause", 1080 )
			this.root.mcPause.field._visible = Key.isDown(Key.ENTER)
			this.pauseStart = getTimer();
			this.pauseAlpha = 70
		}else{
			this.root.mcPause.removeMovieClip();
			kaluga.MC.setPColor(this.current,this.fadeColor,100)
			this.current.barTimer.decal(getTimer()-this.pauseStart);
			
		}
		
		
		
		/* JUSTE POUR ESSAYER
		if(this.flPause){
			this.stopAll(this.slot,[]);
			_parent.play();
		}
		*/
	}
	
	function traceVar(o,sep){		// TRACER D'OBJET ( GERE PAS LES BOUCLES )
		if(sep==undefined)sep ="-";
		sep+="-"
		for ( var elem in o ){
			_root.test += sep+" "+elem+":"+traceVar(o[elem],sep)+"\n"
		}
		return o;
	}
	
	
//{
}















