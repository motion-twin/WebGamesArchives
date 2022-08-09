class cp.Digital extends Component{//}
		
	// CONSTANTES
	var dp_barLevel:Number =	70
	var dp_iconBut:Number =		20
	var dp_icon:Number =		10
	var iconMax:Number =		6
	var nameList:Array;
	
		
	// VARIABLE
	var ladderPos
	var iconList:Array;
	var animList:AnimList;
	
	// MOVIECLIPS
	var barLevel:bar.Level;
	var field:TextField;
	//var fieldLevel:TextField;
	
	

	/* ID INFOS
	
	0 GASPARD 
	1 FORUM
	2 EMAILs
	3 HISTO
	4 EVENMENTS
	5 JEUX
	
	*/
	
	function Digital(){
		this.init()
		this.animList = new AnimList();
	}
	
	function init(){
		this.fix = {w:130,h:45}
		super.init();
		//_root.test+="[Digital] init()\n"
		this.initDefault();
		this.initIcons();
		this.initNameList();
		this.initBarLevel();
		this.setLadderPos(this.ladderPos)
		
		this.barLevel.setLevel(1,0);
		_global.me.addListener("xp",{obj: this,method: "onXp"});
		_global.me.addListener("xppos",{obj: this,method: "onXpPos"});
		_global.me.digitalScreen = this;
	}
	
	function initDefault(){
		
	}
	
	function initNameList(){
		this.nameList =[
			"gaspard",
			"forum",
			"messages",
			"historique",
			"evenements",
			"jeux"
		]
	}
	
	function initIcons(){
		this.iconList = new Array();
		for(var i=0; i<this.iconMax; i++){
			this.attachMovie("digitalIcon","icon"+i,this.dp_icon+i)
			var mc = this["icon"+i]
			mc._x = 42+i*15
			mc._y = 33
			mc.gotoAndStop(i+1)
			this.attachMovie("transp","but"+i,this.dp_iconBut+i)
			var but = this["but"+i]
			//_root.test+="Button("+but+")\n"
			but._x = mc._x-7.5;
			but._y = mc._y-7.5;
			but._xscale = 15
			but._yscale = 15
			but.id = i;
			but.onPress = function(){
				_parent.select(this.id)
			}
			but.onRollOver = function(){
				_parent.rollOver(this.id)
			}
			but.onRollOut = function(){
				_parent.rollOut(this.id)
			}
			this.iconList.push(mc)
			this.sleep(i);
		}
	}
	
	function initBarLevel(){
		//this.createEmptyMovieClip("barLevel",this.dp_barLevel)
		this.attachMovie("barLevel","barLevel",this.dp_barLevel)
	}
	
	function select(id){
		switch(id){
			case 0: // Gaspard
				_global.uniqWinMng.open("help");
				break;
			case 1: // Forum	
				_global.openForum();
				break;
			case 2: // EMails
				_global.openInbox();
				break;
			case 3: // HISTO
				_global.uniqWinMng.open("userLog");
				break;
			case 4: // EVENTS
				_global.uniqWinMng.open("siteLog");
				break;
			case 5: // JEUX
				_global.openGame();
				break;
		}
	}
	
	function rollOver(id){
		this.field.text = this.nameList[id]
		//_root.test+="select("+id+")\n"
	}	
	
	function rollOut(id){
		this.field.text = this.ladderPos;
		//_root.test+="select("+id+")\n"
	}	
	
	function setLadderPos(pos){
		if( pos == undefined ) pos = "inconnu";
		
		this.ladderPos = pos
		this.field.text = this.ladderPos;
	}


	// TODO: revoir toutes les couleurs et la manière de les appeler parce que là c un peu le bordel ce que j'ai fait...
	// (couleurs: sleep, unSleep normal, unSleep clignotant)
	function sleep(id){
		var mc = this.iconList[id];
		this.animList.remove("animFlash"+id);
		
		FEMC.killColor();
		FEMC.setPColor( mc, { r:162, g:235, b:86 }, 0 )
	}
	
	function unSleep(id){
		var mc = this.iconList[id];
		this.animList.addColorFlash("animFlash"+id,mc,{ color: 0xA6110D , alpha: 100,max: 20},{obj: this.animList,method: "endFlashColor",args: mc});
	}
	
	function onXp(xp){
		var lvl = UserMng.xpToLevel(xp);
		var lvlComplRate = UserMng.xpLevelCompletionRate(xp);
		this.barLevel.setLevel(lvl,lvlComplRate);
	}
	
	function onXpPos(xppos){
		this.setLadderPos(xppos);
	}
//{
}













