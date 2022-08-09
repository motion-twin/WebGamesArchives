class miniwave.Manager extends MovieClip{//}

	// CONSTANTES	
	var flTestMode:Boolean = false;
	var fcVersion:Number = 0.93;
	var titemKillLimit:Number = 200;
	
	var heroInfo:Array;
	var badsInfo:Array;
	var gradeName:Array;
	
	// PARAMETRES
	var mcw:Number;
	var mch:Number;
	
	// VARIABLES
	var flPause:Boolean;
	var flReleasePause:Boolean;
	var pauseAlpha:Number;
	var newTitem:Number;
	var badsKillToCheck:Array;
	
	var so:Object;
	var fc:Object;
	var cache:Object;
	
	// REFERENCES
	var slot:miniwave.Slot;
	var client:miniwave.Client;
	var mcLoading:MovieClip;
	var mcDebug:MovieClip;
	var mcPause:MovieClip;
	var mcDecompress:MovieClip;
	var music:miniwave.SoundManager;
	var sfx:miniwave.SoundManager;	
	
	function Manager(){
		this.init();
	}
	
	function init(){
		_root.test+="[MNG] init("+fcVersion+")\n"
		this.initConstant();
		this.initSoundManager();
		
		this.flPause = false;
		this.newTitem = 0;
		this.client = new miniwave.Client();
		this.client.mng = this;
		this.client.serviceConnect()		
		this.attachLoading()
		//_root._alpha = 50;
		if(this.flTestMode)this.attachDebug();
		this.cache = new Object();
	}
	//
	function update(){
		//Std.tmod = 1
		//* TMOD EMULATION
		Std.update();
		//*/
		//_root.test = 40/Std.tmod
		
		// PAUSE
		if( Key.isDown(80) || Key.isDown(27) ){
			if( this.flReleasePause && !this.client.forcePause ){
				this.setPause();
				this.flReleasePause = false;
			}
		}else{
			this.flReleasePause = true;
		}
				
		if(!this.flPause){
			this.slot.update();
		}else{
			this.pauseAlpha *= 0.5
			miniwave.MC.setPColor(this.slot,0x000000,50+this.pauseAlpha)
		}
		
		// DEBUG
		if(this.flTestMode){
			this.mcDebug._visible =  Key.isDown(8)	
		}
		
		
	}
	//
	function genSlot( link, initObj){
		_root.test += "genSlot !!"
		if( this.slot._visible ) this.slot.kill();
		if( initObj == undefined ) initObj = new Object();
		initObj.mng = this
		this.attachMovie( "miniWave2"+link, "slot", 20, initObj );
		//_root.test += ("miniWave2"+link)+">"+slot+"\n"

	}
		
	function initConstant(){
		#include "../inc/badsInfo.as"
		#include "../inc/heroName.as"
		//#include "../inc/level/bonus.as"
		//#include "../inc/level/main.as"
		
		this.gradeName = [
			"Apprenti",		// -
			"Aspirant",		// -
			"Cornette",		// v
			"Pilote",		// v
			"Patrouilleur",		// v
			"Chef d'escadre",	// v
			"Sergent",		// v*
			"Major",		// v*
			"SousLieutenant",	// I
			"Lieutenant",		// II
			"Capitaine",		// oooo
			"Commandant",		// OO
			"Colonel"
		]
		
	}
	
	function loadFruticard(){
		if( this.client.STANDALONE ){
			this.so = _root.loadData("miniWave2/card");
			this.fc = so.data.fruticard;
			if(this.fc == undefined){
				this.fc = new Array();
				so.data.fruticard = this.fc;
			}
			
		}else{
			this.fc = this.client.slots;
		}
			
		//_root.test+="_root.loadData("+this.fc[0]+")\n"
		
		if(  this.fc[0] == undefined || ( Key.isDown(70) && Key.isDown(Key.SPACE) )  ){
			this.formatFruticard();
		}
		
		if( this.fc[0].$vs < this.fcVersion ){
			this.patchFruticard();			
		}
		
		
		if( this.fc[1] == undefined ){
			this.formatPref();
		}		
		
		this.updateSound()
		
		//_root.test+=" $ship ->"+this.fc[0].$ship+"\n"
		
		/*
		_root.test+="kill\n"
		var list = this.fc[0].$badsKill
		for(var i=0; i<list.length; i++ ){
			_root.test+="- "+this.badsInfo[i].link+" : "+list[i]+"\n"
		}
		//*/
		/*
		var o = this.fc[0].$stats.$play
		_root.test+="stats("+o+"):\n"
		for(var e in o ){
			_root.test+="- "+e+" : "+o[e]+"\n"
		}  
		*/
		/*
		if(   Key.isDown(Key.ENTER) && Key.isDown(Key.SPACE)  ){
			this.fc[0].$credit = 1000
		}		
		*/
	}
	
	function formatFruticard(){
		
		_root.test += "format card !!!\n"
		
		// TITEM BASE
		this.client.giveItem("$ship00");
		
		
		this.fc[0] = new Object();
		this.fc[0].$vs = this.fcVersion
		
		
		// VAISSEAU
		this.fc[0].$ship = [1,0,0,0,0,0];

		// MODES
		this.fc[0].$mode = [
			1,
			[0,0,0,0,0,0,0,0],
			[0,0,0],
			1,
			1
		];
		// ARCADE
		this.fc[0].$arcade = {
			$bestScore:0,
			$bestLevel:0
		}
		
		// SPECIAL RECORD
		this.fc[0].$letter = 0
		this.fc[0].$survival = 0
		this.fc[0].$time = 0
		this.fc[0].$bonus = [0,0,0,0,0,0,0,0]
		
		// CONSECRATION
		this.fc[0].$cons = {
			$main:0,
			$bonus:[0,0,0,0,0,0,0,0],
			$letter:0
		}
		// KILL
		this.fc[0].$badsKill = new Array();
		for( var i=0; i<this.badsInfo.length; i++ )this.fc[0].$badsKill[i]=0;
		this.fc[0].$saucerKill = 0
		
		// SHOP
		this.fc[0].$credit = 0//10000;
		this.fc[0].$shop = [ 1,1,1,1,1, 1,1,1,1,1, 1,1,1,1,1, 1,1,1,1,1 ]
		
		// GRADE
		this.fc[0].$lvl = 0;
		
		// STATS
		this.fc[0].$stats = {
			$play:{
				$main:0,
				$mission:0,
				$survival:0,
				$letter:0
			},
			$buy:[]
			
		}
		
				
		// SAVE
		this.client.saveSlot(0)
		so.data.fruticard = this.fc
		
		
	}
	
	function patchFruticard(){
		
		if( this.fc[0].$vs < 0.92 ){ // PATCH 0.9 RAJOUTE LE TITEM MONSTRE LETTRE
			//_root.test+="grzgrgr\n"
			if(this.fc[0].$badsKill[50] >= this.titemKillLimit){
				this.client.giveItem("$bads50")
			}
		}
		
		if( this.fc[0].$vs < 0.93 ){ // RAJOUTE LES DEUX MISSION 
			//_root.test+="grzgrgr\n"
			while( this.fc[0].$shop.length < 20 ){
				this.fc[0].$shop.push(1)
			}

		}
		
		this.fc[0].$vs = this.fcVersion
		this.client.saveSlot(0)
	}
	
	function formatPref(){
		this.fc[1] = {
			$sound:[1,1],
			$key:[Key.LEFT,Key.RIGHT,Key.SPACE,Key.DOWN]
			
		}
		this.client.saveSlot(1)
	}
	
	//
	function initBadsCheck(){
		this.badsKillToCheck = new Array();
		var list = this.fc[0].$badsKill
		//
		for( var i=0; i<list.length; i++ ){
			if( list[i] < this.titemKillLimit ) this.badsKillToCheck[i] = 1;
		}
		//
		//_root.test+="initBadsCheck("+this.badsKillToCheck+")\n"
	}
	
	// PAUSE
	function setPause(flag){
		if(flag==undefined) flag = !this.flPause;
		this.flPause = flag;
		
		if(this.flPause){
			
			this.attachMovie("mcPause","mcPause",262)
			this.pauseAlpha = 50
		}else{
			this.mcPause.removeMovieClip();
			miniwave.MC.setPColor(this.slot,0x000000,100)
		}
		
		this.slot.onPause();
		
		/* JUSTE POUR ESSAYER
		if(this.flPause){
			this.stopAll(this.slot,[]);
			_parent.play();
		}
		*/
	}
	
	function stopAll(mc,list){
		//_root.test+="stopAll("+mc+")\n"
		for( var elem in mc ){
			var o = mc[elem]
			if( typeof o == "movieclip"){
				var flAdd = true
				for(var i=0; i<list.length; i++){
					if( list[i] == o ){
						flAdd = false;
						break;
					}
				}
				if( flAdd ){
					list.push(o);
					list = this.stopAll(o,list);
					o.stop();
				}
				
			}
		}
		return list;
	}
	
	// CLIENT
	function connected(){
		//
		_root.test += " connected !!"
		//
		this.removeLoading();
		this.loadFruticard();
		
		if(_root.flTest){
			this.genSlot("GameMain",{heroList:[0,0,3],level:parseInt(_root.jumpTo,10)});
			//this.genSlot("GameLetter",{heroList:[0,0,3],level:parseInt(_root.jumpTo,10)});
			//this.genSlot("GameSurvival");
		}else{
			this.genSlot("Menu");
		}
		
		
	}
	
	function backToMenu(){
		this.genSlot("Menu")
	}
	
	// LOADING
	function attachLoading(){
		this.attachMovie("mcLoading","mcLoading",144)
	}
	
	function removeLoading(){
		this.mcLoading.removeMovieClip();
	}	

	// SOUNDS
	function initSoundManager(){
		this.attachMovie("miniWave2SoundManager","music",3)
		this.attachMovie("miniWave2SoundManager","sfx",4)
	}

	function updateSound(){
		//_root.test+="[MANAGER] updateParams ("+this.pref.$param[0]+","+this.pref.$param[1]+")\n"
		this.music.setActive(this.fc[1].$sound[0]);
		this.sfx.setActive(this.fc[1].$sound[1]);
	}
	
	// DEBUG
	function attachDebug(){
		this.attachMovie("mcDebug","mcDebug",264)
		this.mcDebug._visible = false;
	}
	
	
//{	
}








