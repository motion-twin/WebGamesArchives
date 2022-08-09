class kaluga.Menu extends kaluga.Slot{//}

	// CONSTANTES
	
	// PARAMETRES
	
	// VARIABLES
	var slotNum:Number;
	var menuList:Array;
	var ombreList:Array;
	var animList:kaluga.AnimList;
	var selectId:Number;
	// REFERENCES
	var root:MovieClip;

	// MOVIECLIP
	var menuBar:MovieClip;
	var optionTable:MovieClip;
	var console:kaluga.Console;
	
	
	function Menu(){
		this.init();
	}
	
	function init(){
		//_root.test += "[Menu] init()\n"
		super.init();
		this.animList = new kaluga.AnimList();
		this.slotNum = 0;
		this.ombreList = new Array();
		this.genMenuList();
		this.attachBar();		
		this.attachConsole();
		// SOUNDS
		this.mng.music.loop("sMenuLoop",40)
	}
	
	
	// SLOT
	function genMenuList(){
		//_root.test+="genMenuList\n"
		this.menuList = [
			{ id:0, name:"CHALLENGE"},
			{ id:1, name:"OLYMPIQUE", list:[
							{id:10, name:"LANCER DE VERS"},		// 1	
							{id:11, name:"LANCER D'ECUREUIL"},	// 1
							{id:12, name:"PLANTAPOMME"},		// 4
							{id:13, name:"LANCER DE FOURMIS"},	// 0.5
							{id:14, name:"PLANTER DE VERS"},	// 20
							{id:15, name:"DEXTERIPOMME"},		// 3
							{id:16, name:"COURSE GRENOUILLES"},	// 1
							{id:17, name:"TRIATHLON"},
							{id:18, name:"HEPTATHLON"}]
			},							
			{ id:2, name:"CHRONO", list:[
							{id:20, name:"FACILE"},
							{id:21, name:"STANDARD"},
							{id:22, name:"DIFFICILE"},
							{id:23, name:"INFERNAL"}]
			},	
			{ id:3, name:"SURVIE", list:[
							{id:30, name:"FACILE"},
							{id:31, name:"STANDARD"},
							{id:32, name:"DIFFICILE"},
							{id:33, name:"INFERNAL"}]
			},			
			{ id:4, name:"INVASION", list:[
							{id:40, name:"FACILE"},
							{id:41, name:"STANDARD"},
							{id:42, name:"DIFFICILE"},
							{id:43, name:"INFERNAL"}]
			},
			{ id:5, name:"PISTE", list:[
							{id:50, name:"FACILE"},
							{id:51, name:"STANDARD"},
							{id:52, name:"DIFFICILE"},
							{id:53, name:"INFERNAL"}]
			},
			{ id:6, name:"SEQUENCE", list:[
							{id:60, name:"INTRODUCTION"},
							{id:61, name:"CREDITS"}]
			},
			{ id:9, name:"PREPARATION"	},
			{ id:7, name:"OPTIONS"	}
							
			
		]
		//
		//_root.test+="this.mng.client.isWhite()["+this.mng.client.isWhite()+"]\n"
		if(this.mng.client.isWhite()){
			this.menuList[0].name = "ESSAIS"
			
		}			
		// CASSE MODES			
		var list = this.mng.card.$mode
		for( var m=0; m<list.length; m++ ){
			
			var a = list[m]
			if(m==0){
				if(!a){
					this.menuList[0] = undefined
					//_root.test+="casse menu\n"
				};
				
			}else{
				var visible = false;
				for( var i=0; i<a.length; i++ ){
					if( !a[i] ){
						this.menuList[m].list[i] = undefined
						//_root.test+="casse sous-menu\n"
					}else{
						visible = true;
					}

					
				}
				if(!visible){
					this.menuList[m] = undefined
				}				
			}
		}
		// CASSE SEQ
		var list = this.mng.card.$seq
		//_root.test+="this.menuList[6].list "+this.menuList[6].list+"\n"
		//_root.test+="list"+list+"\n"
		for(var i=0; i<list.length; i++){
			//_root.test+="list[i] "+list[i]+"\n"
			
			if(!list[i])this.menuList[6].list[i] = undefined;
		}
		
		
		for( var m=0; m<this.menuList.length; m++ ){
			var a = this.menuList[m]
			if( a == undefined ){
				this.menuList.splice(m,1)
				m--
			}else{
				for( var i=0; i<a.list.length; i++ ){
					if(a.list[i] == undefined){
						//_root.test+="splice\n"
						a.list.splice(i,1)
						i--
					}
				}
			}
		}
		//
		

			
			
			
	}
	
	function attachBar(){
		this.attachMovie("menuBar","menuBar",10)
		this.menuBar.createEmptyMovieClip("menu",10)
		this.menuBar.createEmptyMovieClip("shadow",8)
		this.menuBar.shadow._x = 20
		this.displayMenu();
		
		/*
		for(var i=0; i<0; i++){
			this.attachMovie("ombreMenu","ombre"+i,240+i)
			var mc = this["ombre"+i]
			//_root.test+="("+mc+")\n"
			mc.gotoAndStop(i+1)
			mc.d = random(628)
			mc.y = mc.base._y
			this.ombreList.push(mc)
		}
		*/
	}

	function addSlot(info){
		var d = this.slotNum++
		this.menuBar.menu.createEmptyMovieClip("slot"+d,10+d)
		var mc = this.menuBar.menu["slot"+d];
		mc._x = this.menuBar.shadow._x
		// TITLE
		mc.attachMovie("slotTitle","title",100)
		mc.title.gotoAndStop(info.id+1)
		// TEXTE
		mc.title.title.text = info.name
		// BUTTON
		mc.attachMovie("transp","but",110)
		mc.but._xscale = 232
		mc.but._yscale = 32
		mc.but.onPress = function(){
			_parent._parent._parent._parent.selectSlot(_parent.info.id)
		}
		mc.but.onRollOver = function(){
			_parent._parent._parent._parent.rollOverSlot(_parent.info.id, _parent)
		}		
		mc.but.onRollOut = function(){
			_parent._parent._parent._parent.rollOutSlot(_parent.info.id, _parent)
		}
		mc.but.onDragOut = mc.but.onRollOut
		// SHADOW
		this.menuBar.shadow.attachMovie("slotShadow","shadow"+d,10+d)
		mc.shadow = this.menuBar.shadow["shadow"+d]
		mc.shadow.gotoAndStop(info.id+1)
		// LIGHT
		mc.title.light.gotoAndStop(info.id+1)
		mc.title.light.alpha = 0
		mc.title.light._alpha = 0
		mc.title.light._visible = false;

		mc.info = info;
		info.path = mc;
		info.flOpen = false;
		
		return mc;
	}
	
	function removeSlot(info){
		info.path.shadow.removeMovieClip();
		info.path.removeMovieClip();
		
		delete info.path;
	}
		
	function update(){
		//_root.test+="o"
		this.console.update();
		
		for( var i=0; i<this.ombreList.length; i++ ){
			var mc = this.ombreList[i]
			mc.d = (mc.d+10)%628
			var c = Math.cos(mc.d/100)
			mc.base._xscale = 100+c*6
			mc.base._y = mc.y + c*2
		}
	}	

	function selectSlot(id){
		//_root.test+= "[Menu] selectSlot("+id+")\n"
		//var info = this.menuList[id]
		
		this.mng.sfx.play("sClic");
		
		switch(id){
			case 1:
			case 2:
			case 3:
			case 4:
			case 5:
			case 6:
				this.toggle(id)			
				break;
			case 9:
				this.launchGame("gameTrain")	
				//this.mng.addSlot("loader","anim/end.swf")
				//this.kill();
				break;
			case 7:
				this.displayOption();			
				break;			
			case 8:
				this.displayMenu();			
				break;				
			case 0:
				this.launchGame("gameClassic")
				break;
			case 10:
				this.launchGame("gameCaterLaunch")	//
				break;
			case 11:
				this.launchGame("gameSquirrelLaunch")
				break;			
			case 12:
				this.launchGame("gamePlant")
				break;
			case 13:
				this.launchGame("gameAntLaunch")
				break;					
			case 14:
				this.launchGame("gameCaterPlant")
				break;
			case 15:
				this.launchGame("gameDexFruit")		
				break;
			case 16:
				this.launchGame("gameFrogRun")
				break;
			case 17:
				this.launchTournament("triathlon")
				break;
			case 18:
				this.launchTournament("heptathlon")
				break;					
			case 20:
			case 21:
			case 22:
			case 23:
				this.launchGame("gameChrono",{level:id-20})
				break;
			case 30:				
			case 31:
			case 32:
			case 33:
				this.launchGame("gameSurvival",{level:id-30})
				break;
			case 40:				
			case 41:
			case 42:
			case 43:
				this.launchGame("gameInvasion",{level:id-40})
				break;					
			case 50:				
			case 51:
			case 52:
			case 53:
				this.launchGame("gameRing",{level:id-50})
				break;
			case 60:
				this.launchAnim("animLoader", { link:"anim/intro.swf", width:350, height:240 } )
				break;
			case 61:
				this.launchAnim("animLoader", { link:"anim/credits.swf", width:350, height:135 } )
				break;							
						
		}
	}
	
	function rollOverSlot(id,mc){
		//var info = this.menuList[id]
		this.animList.addAnim( "anim"+id, setInterval(this,"animSlotLight",25,mc.title.light,1,id));
		this.animList.addPaint( "paint"+id, mc.title.title, {r:255,g:255,b:255}, 0, undefined, 2)
		mc.title.light._visible = true;
	}
	
	function rollOutSlot(id,mc){
		var info = this.menuList[id]
		this.animList.addPaint( "paint"+id, mc.title.title, {r:172,g:70,b:45}, 100, undefined, 2)
		this.animList.addAnim("anim"+id,setInterval(this,"animSlotLight",25,mc.title.light,-1,id));
	}	
	
	function animSlotLight(mc,sens,id){
		mc.alpha = Math.max( 0, Math.min( mc.alpha+(sens*kaluga.Cs.tmod*10), 100) );

		mc._alpha = mc.alpha
		if(sens==-1 and mc.alpha==0 ){
			this.animList.remove("anim"+id)
			mc._visible = false;
		}
		if(sens==1 and mc.alpha==100 ){
			this.animList.remove("anim"+id)
		}		
	}
	
	function sortSlot(){
		var y = 100
		for(var i=0; i<this.menuList.length; i++){
			
			var info = this.menuList[i];
			info.path._y = y
			info.path.shadow._y = y
			y+=29
			if(info.flOpen){
				for(var s=0; s<info.list.length; s++){
					var sInfo = info.list[s]
					//_root.test+
					sInfo.path._y = y
					sInfo.path.shadow._y = y
					y+=21
				}
			}
			
		}		
	}
	
	function toggle(id){
		
		var info;
		for(var i=0; i<this.menuList.length; i++){
			info = this.menuList[i]
			if(info.id==id)break;
		}
		
		
		
		
		//_root.test+="toggle("+id+")("+info.list.length+")\n"
		if(info.flOpen){
			for(var i=0; i<info.list.length; i++){
				this.removeSlot(info.list[i])
			}
			info.flOpen = false;
		}else{
			for(var i=0; i<info.list.length; i++){
				this.addSlot(info.list[i])
			}
			info.flOpen = true;			
		}
		this.sortSlot();
	}
	
	function launchGame(link,initObj){
		//_root.test+="[Menu]launchGame()\n"
		if( initObj == undefined ) initObj = new Object();
		if( initObj.mode == undefined ) initObj.mode = "single";
		initObj.root = this.root;
		initObj.tzongreInfo = this.mng.tzInfo[this.console.tzList[this.console.index]]//this.console.tzList[this.console.index];
		this.mng.startGameInfo = { link:link, initObj:initObj }
		if(link=="gameTrain" || true ){	// CORRECTION BUG HEPTATHLON TRIATHLON
			this.mng.started();
			
		}else{
			this.mng.client.startGame();
		}
		//this.mng.addSlot(link,initObj);
		
		this.kill();
	}
	
	function launchTournament(mode){
		//_root.test+="launchTournament\n"
		
		// PLAYERLIST
		var ti = this.mng.tzInfo[this.console.tzList[this.console.index]];
		var playerList = [0,1,2,3,4];
		playerList.splice(ti.id,1);
		playerList.push(ti.id);
		
		this.mng.tournament = new Object();
		this.mng.tournament.eventId = 0;
		
		this.mng.tournament.stats = new Array();
		var stats = this.mng.tournament.stats;
		//var coefList = [1,1,32,0.5,20,3,1];
		var coefList = [1,1,50,0.1,10,3,0.4];
		var max, difCoef;
		switch(mode){
			case "triathlon":
				max = 3;
				difCoef = 0.8; 
				break;
			case "heptathlon":
				max = 7;
				difCoef = 1.2; 
				break;			
		}
		for(var i=0; i<playerList.length; i++ ){
			
			var player = new Object(); 
			player = new Object();
			player.id = playerList[i];
			player.results = new Array();
			for(var r=0; r<max; r++){
				player.results[r] = {base:0,coef:coefList[r],score:0}
			}
			
			this.mng.tournament.stats[i] = player
		}
		this.mng.tournament.difCoef = difCoef;
		//_root.test+="this.mng.tournament.stats("+this.mng.tournament.stats+")\n"

		var initObj = {
			mode:mode,
			tournament:this.mng.tournament
		}
		this.mng.waitList.push({link:"gameSquirrelLaunch",initObj:initObj});
		this.mng.waitList.push({link:"gamePlant",initObj:initObj});	
		if(mode =="heptathlon"){
			this.mng.waitList.push({link:"gameAntLaunch",initObj:initObj});
			this.mng.waitList.push({link:"gameCaterPlant",initObj:initObj});	
			this.mng.waitList.push({link:"gameDexFruit",initObj:initObj});	
			this.mng.waitList.push({link:"gameFrogRun",initObj:initObj});	
		}
		//this.mng.waitList.push({link:"menu",initObj:initObj});
		this.launchGame("gameCaterLaunch",initObj)
		//_root.test+="this.mng.waitList.length("+this.mng.waitList.length+")\n"
		
		
	}
	
	function launchAnim(link,initObj){
		//_root.test+="[Menu]launchGame()\n"
		if( initObj == undefined ) initObj = new Object();
		initObj.root = this.root;
		this.mng.addSlot(link,initObj)
		this.kill();
	}
	
	// CONSOLE
	function attachConsole(){
		this.attachMovie("console","console",4,{menu:this});
		this.console._x = 240
		this.console.update();

	}
		
	// OPTIONS
	function displayOption(){
		/*
		this.menuBar.menu._visible = false;
		this.menuBar.shadow._visible = false;
		*/
		for(var i=0; i<this.menuList.length; i++){
			this.removeSlot( this.menuList[i] )
		}		
		
		
		this.attachMovie("optionTable","optionTable",32)
		this.optionTable._x = 138;
		this.optionTable._y = 330;
		
		// PARAM
		for(var i=0; i<3; i++){
			var mc = this.optionTable["b"+i]
			mc.id = i;
			mc.flag = this.mng.pref.$param[i]
			this.updateDisc(mc);
		}		
		
		// KEY
		this.optionTable.tabCode = new asml.KeyManager()
		for(var i=0; i<6; i++){
			var mc = this.optionTable["k"+i]
			mc.id = i;
			var n = this.mng.pref.$key[i]
			this.setKeyCode(mc,n);
		}
		
		// RETOUR
		/*
		var info = {
			id:6,
			name:"retour"
		}
		var mc = this.addSlot(info)
		//_root.test+="mc("+mc+")("+mc._x+","+mc._y+")\n"
		//mc._x = 140
		mc._y = 440
		//mc.shadow._x = mc._x-1
		mc.shadow._y = mc._y
		//_root._alpha = 50
		*/
		
		
	}
	
	function closeOption(){
		this.optionTable.removeMovieClip();
		this.displayMenu();
	}
	
	function initKey(mc){
		if( this.optionTable.mck != undefined ){
			if(this.optionTable.mck == mc)return;
			this.pushKey(this.mng.pref.$key[this.optionTable.mck.id])
		}
		this.optionTable.mck = mc;
		var listener = new Object();
		listener.root = this;
		listener.onKeyDown = function (){
			this.root.pushKey(Key.getCode())
		}
		
		mc.gotoAndPlay(2);		
		mc.field.text = "---";		
		Key.addListener(listener)
		
	}
	
	function pushKey(n){
		if( this.optionTable.mck != undefined ){
			var id = this.optionTable.mck.id
			this.setKeyCode(this.optionTable.mck,n)
			this.mng.pref.$key[id] = n;
			this.mng.client.saveSlot(1);
			this.optionTable.mck.gotoAndStop(1)
			delete this.optionTable.mck;
		}
		
	}
	
	function setKeyCode(mc,n){
		mc.field.text = this.optionTable.tabCode.getKeyName(n);		
	}
	
	function rOver(mc){
		var txt
		switch(mc._name){
			case "k0":
				txt = "redéfinir la touche d'acceleration."
				break;
			case "k1":
				txt = "redéfinir la touche pour tourner vers la gauche."
				break;
			case "k2":
				txt = "redéfinir la touche pour tourner vers la droite."
				break;
			case "k3":
				txt = "redéfinir la touche pour foncer vers le sol."
				break;
			case "k4":
				txt = "redéfinir la touche pour lancer le fil de la tzongre."
				break;
			case "k5":
				txt = "redefinir la touche qui ne sert a rien."
				break;
			case "b0":
				txt = "la musique du jeu."
			case "b1":
				if(txt==undefined) txt = "les effets sonores du jeu."
			case "b2":
				if(txt==undefined) txt = "les effets de particules."
				if(mc.flag){
					txt = "desactiver "+txt
				}else{
					txt = "activer "+txt
				};
				break;
		}
		this.setDesc(txt)
		
	}
	
	function rOut(mc){
		setDesc("")
	}
	
	function setDesc(str){
		this.optionTable.field.text = str
		this.optionTable.field._y = -232 -this.optionTable.field.textHeight/2
	}
	
	function updateDisc(mc){
		//_root.test+="updateDisc("+(11*mc.flag+mc.id)+")\n"
		mc.gotoAndStop((10*mc.flag)+mc.id+1)
	}
	
	function pushDisc(mc){
		mc.flag = !mc.flag;
		this.mng.pref.$param[mc.id] = mc.flag
		this.mng.client.saveSlot(1);
		this.mng.updateParams();
		this.updateDisc(mc)
		this.rOver(mc);
		
		
	}
	
	function displayMenu(){
		for(var i=0; i<this.menuList.length; i++){
			this.addSlot( this.menuList[i] )
		}
		this.sortSlot();	
	};
		
	function kill(){
		this.mng.music.stopSound("sMenuLoop",40)
		super.kill();
		//this.removeMovieClip();
	}	
		
//{	
}




