class miniwave.Game extends miniwave.Slot{//}

	
	
	// CONSTANTES	
	var dp_decompress =		4600;
	var dp_msg:Number =		4000;
	var dp_interface:Number =	2950;
	var dp_part:Number =		2000;
	var dp_sprite:Number =		1500;
	var dp_underPart:Number =	500;
	var dp_decor:Number =		40;
	var badsSize:Number =		24;
	
	var badsFlow:Number = 10;
	var beepInterval = 48
	var endTimerMax:Number = 40;
	//var decorDecal:Number = 20;
	var decorDecal:Number = 18.7;

	var depthRunMax:Number = 450
	
	var friction = 0.95
	var gravite = 1
	
	
	
	// PARAMETRES
	var root:MovieClip;
	var heroList:Array;

	// VARIABLES
	var flWaveInfoLoading:Boolean
	var flChangeSens:Boolean;
	var flGameOver:Boolean;
	var depthRun:Number;
	var level:Number;
	var nextLevel:Number

	var fallSpeed:Number;
	var waveSpeed:Number;
	var frict:Number;
	var step:Number;
	var timer:Number;
	var toKill:Number;
	var score:Number;
	var fadePrc:Number;
	var fadeTrg:Number;
	var fadeTimer:Number;
	var beepCount:Number;
	var waveSoundIndex:Number;

	var type:String;
	var name:String;
	var waveInfo:Array;
	var spriteList:Array;
	var badsList:Array;
	var hShotList:Array;
	var bShotList:Array;
	var partList:Array;
	var depthList:Array;
	var panelList:Array;
	var msgList:Array;
	//var badsKill:Array;
	
	var updateList:Array;
	var waveSoundList:Array;
	
	var waveSens:Number;
	var waveIndex:Number;
	
	var fadeCb:Object;
	var gridInfo:Object;
	var shipBounds:Object;
	
	// DEBUG
	var flDebugScrolling:Boolean;
	
	
	// REFERENCES
	var mng:miniwave.Manager;
	var decor:MovieClip;
	//var panel:MovieClip;
	var scorePanel:miniwave.panel.Score
	var hero:miniwave.sp.Hero
	var so:SharedObject;
	var waveInfoLoader:ext.util.PersistCodec;
	
	
	
	
	function Game(){
		//this.init();
	}
	
	function init(){
		super.init();
		
		this.initDepthList();
		//_root.test+="->"+this.level+"\n"
		
		this.spriteList = new Array();
		this.badsList = new Array();
		this.hShotList = new Array();
		this.bShotList = new Array();
		this.partList = new Array();
		this.panelList = new Array();
		this.msgList = new Array();
		
		this.flGameOver = false;
		if(this.level == undefined )this.level = 0;
		
		this.score = 0;
		this.waveIndex = 0;
		this.waveSoundIndex = 0;
		this.beepCount = 0;
		this.initInterface();
		this.initWaveInfo();
		this.initDecor();
		
		this.fadeTrg = 100; 
		this.fadePrc = 0;
		
		this.fade()
		this.mng.initBadsCheck();
		this.addNewPlay()
		
		this.waveSoundList = [ "sWaveBeep0", "sWaveBeep1", "sWaveBeep2", "sWaveBeep3" ]
		
		//
		this.startMusic()
		//
		
	};

	function initDepthList(){
		depthList = new Array();
		for( var i=0; i<depthRunMax; i++ )depthList.push(i);
	};

	function initDecor(){
		this.attachMovie("miniWave2Decor","decor",this.dp_decor)
		
		this.flDebugScrolling = false;
		this.decor.onPress = function (){
			this._parent.flDebugScrolling=true;
		}
		this.decor.onRelease = function (){
			this._parent.flDebugScrolling=false;
		}
	}
	
	function initNextHero(){
		
		//_root.test+="initNextHero\n"
		
		var id = this.heroList.shift();
		var initObj = {
			x : this.mng.mcw/2,
			y : this.mng.mch+14
		}
		var mc = this.newSprite( this.mng.heroInfo[id].link, initObj );
		this.hero = mc;
		
	}
	
	function initInterface(){
		// SCORE
		this.scorePanel = this.newPanel( "miniWave2PanelScore" );
		this.scorePanel.setScore( this.score );
	}
	
	function initLevel(){
		
		this.waveSens = 1;
	
		this.shipBounds = {
			min:0,
			max:this.mng.mcw //+100 //HACK
		}
		
		//var info = this.waveInfo[this.level]
		this.gridInfo  = this.waveInfo[this.level]
		
		this.fallSpeed = this.gridInfo.fallSpeed
		this.waveSpeed = this.gridInfo.moveSpeed	
		this.toKill = 0;

		
		if(this.gridInfo.sd == undefined ) this.gridInfo.sd = 6;	
		if(this.gridInfo.ss == undefined ) this.gridInfo.ss = 6;	
		
		//*
		for(var n=0; n<this.gridInfo.list.length; n++){
			
			var line = this.gridInfo.list[n]
			if( line.length > 1 ){
				
				var difx = line[0].x - line[1].x
				var dify = line[0].y - line[1].y
				var a = Math.atan2( dify, difx )//
				
				var dx = Math.cos(a)*10
				var dy = Math.sin(a)*10
				
				var sp ={ x: line[0].x, y: line[0].y	}
				var to = 0
				do{
					sp.x += dx
					sp.y += dy
					if(to++>100){
						_root.test+="recal failure layer no"+n+"\n"
						break;
					}
				}while( !this.isOut(sp.x,sp.y,20) );	
				
	
				var nbShip = 0
				for( var i=0; i<line.length; i++ ){
					if(line[i].t!=undefined)nbShip++
				}
				var wp = 0
				for( var i=0; i<line.length; i++ ){
					var data = line[i]
					if( data.t != undefined ){
						var initObj = {
							x: sp.x,// + dx*(max-(i+1)),
							y: sp.y,// + dy*(max-(i+1)),
							wpTimer:(nbShip-((i-wp)+1))*this.gridInfo.sd,
							waveId:i,
							lineId:n
						};
						var mc = this.newBads(data.t,initObj)
						mc.nextWayPoint();
						this.toKill++;
					}else{
						wp++
					}
				}
			}
		}
		//*/
		
		
		
		
	}
	
	//
	function update(){
		super.update();
		
		//if(this.checkInfoLoading())return;
		this.frict = Math.pow(this.friction,Std.tmod)
		this.updateList = new Array();
		this.updateList = this.updateList.concat( this.spriteList );
		this.updateList = this.updateList.concat( this.msgList );		
		this.updateList = this.updateList.concat( this.panelList );		
		
		// FADE
		this.fade();
	
	}
	//

	function moveAll(){
		for(var i=0; i<this.updateList.length; i++ ){
			this.updateList[i].update();
		}
	}
	
	function updateWave(){
		
		//var updateList = 
		
		for(var i=0; i<this.badsFlow; i++ ){
			var mc = this.badsList[this.waveIndex]
			mc.waveUpdate();
			if( mc._visible ){
				this.waveIndex++;
			}
			if( this.waveIndex >= this.badsList.length ){
				this.waveIndex = 0;
				this.checkWaveSens();
				this.beepCount++
				if( this.beepCount > this.beepInterval && this.badsList.length>0 ){
					this.beepCount = 0
					this.mng.music.playSound(this.waveSoundList[this.waveSoundIndex], 32 )
					this.mng.music.setVolume( 32, 25 )
					this.waveSoundIndex = (this.waveSoundIndex+1)%this.waveSoundList.length
				}
			}
		}	
	}
	
	function checkWaveSens(){
		if( this.flChangeSens ){
			this.flChangeSens = false;
			this.waveSens *= -1;
			for(var i=0; i<this.badsList.length; i++ ){
				var mc = this.badsList[i]
				mc.ty += this.fallSpeed
			}
		}	
	}
	
	
	// ATTACH SYSTEM
	function newMovie( link, initObj, dp ){
		if( initObj == undefined ) initObj = new Object();
		if( dp == undefined ) dp = this.dp_sprite;
		initObj.game = this;
		var d = this.giveDepth()
		this.attachMovie( link, "sprite"+d, dp+d, initObj )
		var mc = this["sprite"+d]
		mc.depth = d;
		return mc;	
	}
	
	function newSprite( link, initObj, dp ){
		var mc = this.newMovie( link, initObj, dp );
		this.spriteList.push(mc);
		return mc;
	}
	
	function newBads( type, initObj ){
		var mc = this.newSprite( this.mng.badsInfo[type].link, initObj);
		this.badsList.push(mc);
		return mc;
	}
	
	function newHShot( initObj ){
		if( initObj == undefined ) initObj = new Object();
		initObj.listName = "hShot"
		var mc = this.newSprite( "miniWave2SpShot", initObj );
		this.hShotList.push(mc)
		return mc
	}

	function newBShot( initObj ){
		if( initObj == undefined ) initObj = new Object();
		initObj.listName = "bShot"
		var mc = this.newSprite( "miniWave2SpShot", initObj );
		this.bShotList.push(mc)
		return mc
	}
		
	function newPart( name, initObj, flUnder ){
		var d;
		if(flUnder){
			d=this.dp_underPart;
		}else{
			d=this.dp_part;
		}
		var mc = this.newSprite( name, initObj, d );
		this.partList.push(mc);
		return mc	
	}
	
	function newPanel( name, initObj ){
		if( initObj == undefined ) initObj = new Object();
		initObj.game = this;
		var mc = this.newMovie( name, initObj, this.dp_interface );
		this.panelList.push(mc);
		return mc	
	}
	
	function genMsg (initObj){
		if( initObj == undefined ) initObj = new Object();
		initObj.game = this;
		var mc = this.newMovie( "miniWave2Msg", initObj, this.dp_msg );
		this.msgList.push(mc);
		return mc;
	}
	
	function removeFromList(mc,list){
		//var list = this[listName+"List"]
		for(var i=0; i<list.length; i++){
			if( list[i] == mc ){
				list.splice(i,1);
				return;
			}
		}
	}

	function giveDepth(){
		return depthList.pop();
	}
	
	function releaseDepth(mc){
		if(_root.test)
		depthList.push(mc.depth);
	}
	
	
	// FADE
	function fade(){
		if( this.fadeTrg != undefined ){
			if(this.fadeTimer != undefined){
				this.fadeTimer -= Std.tmod
				if(this.fadeTimer<0)delete this.fadeTimer;
				return;
			}
			var dif =  this.fadeTrg - this.fadePrc
			var flExe = false;
			if( Math.abs(dif) > 1 ){
				this.fadePrc += dif*0.15
			}else{
				this.fadePrc = this.fadeTrg
				delete this.fadeTrg
				flExe = true;
			}
			miniwave.MC.setPColor( this, 0x4A4A84, this.fadePrc );
			if(flExe)this.fadeCb.obj[this.fadeCb.method](this.fadeCb.args);
			//_root.test="this.fadePrc("+this.fadePrc+")\n"
			//_root.test="this.fadeCb.obj("+this.fadeCb.obj+")\n"
			//_root.test="this.fadeCb.method("+this.fadeCb.method+")\n"
			//_root.test="func("+this.fadeCb.obj[this.fadeCb.method]+")\n"
		}
	}
	
	function checkEnd(){

	}
		
	function cleanShots(){
		while(this.bShotList.length>0)this.bShotList[0].vanish();
		while(this.hShotList.length>0)this.hShotList[0].vanish();
	};
	
	function incScore(n){
		this.score += n;
		this.scorePanel.setScore(this.score)
	}
	
	function incCred(n){
		var initObj = {
			x:this.hero.x,
			y:this.hero.y-this.hero.ray,
			vity:-1,
			timer:30,
			flGrav:false,
			txt:"+"+n
		}
		var mc = this.newPart("miniWave2SpPartField",initObj);
		//_root.test+="<"+mc+">\n"
		this.mng.fc[0].$credit += n;
	}
	
	function gameOver(initObj){
		if( !this.flGameOver ){
			this.flGameOver = true;
			
			this.genMsg(initObj)
			
			this.fadeCb = {
				obj:this,
				method:"endGame"
			}
			this.fadeTimer = 80
			this.fadePrc = 100;
			this.fadeTrg = 0;
		}
	}
	
	
	// MOVE MAP
	function moveMap(dy){
		var frame = Math.floor(dy/1000)+1
		if( this.decor.bg0._currentframe != frame ){
			this.decor.bg0.gotoAndStop(frame);
			this.decor.bg1.gotoAndStop(frame+1);
		}		
		this.decor._y = Math.round(this.mng.mch + dy%1000)	
	}
	
	
	// UTILS
	function isFree(x,y,ray){
		if( ray == undefined ) ray = 24;
		for( var i=0; i<this.badsList.length; i++ ){
			var mc = this.badsList[i]
			var difx = mc.x - x
			var dify = mc.ty - y
			if( Math.abs(difx) < ray && Math.abs(dify) < ray ){
				return false;
			}
		}
		return true;
	}
	
	function isWaveReady(){
		for( var i=0; i<this.badsList.length; i++ ){
			if( !this.badsList[i].flReady ){
				return false;
			}
		}
		return true
	}	
	
	function isOut(x,y,m){
		if( m == undefined ) m=0;
		return x < -m || x > this.mng.mcw+m || y < -m || y > this.mng.mch+m
	}
	
	function getHeroTarget(){
		var h = this.hero;
		if( h._visible != true ){
			h = { x:this.mng.mcw/2, y:this.mng.mch, speed:0 }
		}
		return h;
	}
	
	//ENDGAME
	
	function endGame(){

		this.mng.client.saveSlot(0)
		this.mng.genSlot("Menu");
	}
		

	// WAVEINFO
	
	function initWaveInfo(){
		//_root.test += " >>> "+this.name+" <<<\n "
		if(this.waveInfo == undefined || Key.isDown(67) ){
			this.loadCookie();
			this.waveInfo = so.data.level
			this.flWaveInfoLoading = false
		}else{
			var wi = this.mng.cache[this.getWaveName()]
			if( wi == undefined ){
				this.mng.attachMovie("mcDecompress","mcDecompress",this.dp_decompress)
				this.waveInfoLoader = new ext.util.PersistCodec(this.waveInfo)
				this.flWaveInfoLoading = true;
			}else{
				this.waveInfo = wi
			}
			
			
		}
	}
	
	function checkWaveInfoLoading(){
		if( this.flWaveInfoLoading ){
			//_root.test="->"+this.waveInfoLoader.cache.length+"\n"
			for( var i=0; i<150; i++ ){
				if( this.waveInfoLoader.decode() ){
					this.mng.mcDecompress.removeMovieClip();
					this.waveInfo = this.waveInfoLoader.decoded() ;
					this.flWaveInfoLoading = false ;
					//_root.test+="done ! ("+this.waveInfo+")\n"
					this.mng.cache[this.getWaveName()] = this.waveInfo;
					
					return false ;	
				}
				
			}
			this.mng.mcDecompress.txt += "."
			return true;
		}
		
	}
	
	//
	function loadCookie(){
		//_root.test+="loadCookie:\n"
		so = _root.loadData("miniWave2/level/"+this.getWaveName());
		//_root.test+="-->("+"miniWave2/level/"+this.getWaveName()+")\n"
	}
	
	function getCons(){
		var c = this.level/this.waveInfo.length
		return Math.round(c*100)	
	}
	
	function getWaveName(){
		
	}
	
	// STATS
	function addNewPlay(name){
		this.mng.fc[0].$stats.$play[name]++
	}
	
	// MUSIC
	function startMusic(){
		/*
		this.mng.music.loop( "sGame", 1 )
		this.mng.music.setVolume( 1, 60 )
		*/
	}
	
	// KILL
	function kill(){
		while(this.spriteList.length>0)this.spriteList[0].kill();
		if( this.flWaveInfoLoading ){
			this.mng.mcDecompress.removeMovieClip();		
		}
		this.mng.music.stop(1)
		super.kill();
	}
	
//{	
}














