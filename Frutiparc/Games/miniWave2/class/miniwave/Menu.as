class miniwave.Menu extends miniwave.Slot{//}
	
	
	// CONSTANTES	
	var dp_page:Number =		100;
	var dp_bads:Number =		50;

	var margin:Number =		10;
	
	var marginUp:Number =		54
	
	// PARAMETRES

	// VARIABLES
	var flLowBad:Boolean;
	var shipStockList:Array;
	var pageList:Array;
	var badsList:Array;
	var badsRun:Number;
	var badsTimer:Number;
	var depthRun:Number;
	var step:Number;
	var nextPage:Object;
	var gameInfo:Object;
	var timer:Number;
	// REFERENCES
	var mng:miniwave.Manager
	var badsLayer:MovieClip;
	var title:MovieClip;
	var page:miniwave.Page
	
	
	function Menu(){
		this.init();
	}
	
	function init(){
		this.gameInfo = new Object();

		this.depthRun = 0;
		this.step = 0;
		this.pageList = new Array();
		
		this.initPage({link:"miniWave2PageMain"})
		
		this.mng.music.loop( "sMenu", 1 )
		this.mng.music.setVolume( 1, 50 )
		
		super.init();
		
		this.title.onPress = function(){
			this._parent.mng.backToMenu();
		}		
	}

	function update(){
		super.update();
				for(var i=0; i<this.pageList.length; i++ ){
					var mc = this.pageList[i];
					mc.update();
				}
		switch(this.step){
			case 0:

				break;
			case 1:
				// TITLE
				var c = Math.pow(0.8,Std.tmod)
				this.title._y = title._y*c - 60*(1-c)
				
				//TIMER
				if(this.timer<0){
					
					this.mng.genSlot(this.gameInfo.type,this.gameInfo)
				}else{
					this.timer-=Std.tmod;
				}
			
			
				break;
		}
	}
	
	function initPage(obj){
		//if(this.page._visible)this.page.kill();
		// INTERRUPTION
		if( obj.link == "miniWave2PageMain" && this.checkPowerUp() )return;
		
		
		
		if(obj.link=="launchGame"){
			this.vanish();
		}else{
			this.newPage(obj.link,obj.initObj)
		}
	}
	
	function newPage(link,initObj){
		if(initObj == undefined )initObj = new Object();
		initObj.menu = this;
		initObj.width = this.mng.mcw-this.margin*2;
		initObj.height = this.mng.mch-(this.margin+this.marginUp);
		var d = this.depthRun++;
		this.attachMovie( link, "page"+d, this.dp_page+d, initObj )
		
		var mc = this["page"+d]
		mc._x = this.margin
		mc._y = this.marginUp;
		this.pageList.push(mc)
		//_root.test+="newPage("+mc+")\n"
	}

	function setNextPage(obj){
		//this.nextPage = obj;
		for(var i=0; i<this.pageList.length; i++ ){
			var mc = this.pageList[i];
			mc.vanish();
		}
		this.initPage(obj)		
		
	}
	
	/*
	function tryToGoToMain(){
		if( !this.checkPowerUp() ){
			this.initPage({link:"miniWave2PageMain"})
		}	
	}
	*/
	
	// PowerUp
	function checkPowerUp(){
		_root.test+="checkPowerUp()\n"
		// GRADE
		var score = 0;
		var f = this.mng.fc[0]
		
		var max = f.$cons.$bonus.length
		//f.$cons.$main += 10	// HACK
		var c = f.$cons.$main*0.1*(10-max)
		
		for( i=0; i<max; i++ ){
			c += f.$cons.$bonus[i]*0.1
		}

		for( var i=0; i<f.$badsKill.length; i++ ){
			//f.$badsKill[i] += 1 // HACK
			score +=  this.mng.badsInfo[i].value * f.$badsKill[i]
		}
		_root.test+="- c:"+c+" score:"+score+"\n"
		score = Math.round(score*c/10000)
		var lvl = Math.round( Math.pow(score, 0.2 ) )
		
		_root.test+="- score:"+score+" lvl:"+lvl+"\n"
		if( lvl > f.$lvl  && lvl < this.mng.gradeName.length ){
			f.$lvl = lvl
			this.mng.client.saveSlot(0)
			var initObj = {
				type:"grade",
				num:lvl,
				nextPage:{link:"miniWave2PageMain"}
			}
			this.initPage( { link:"miniWave2PagePowerUp", initObj:initObj } )
			return true
		}
		
		// CHECK BADSKILL
		//_root.test+="checkBadsKill()\n"
		var list = this.mng.fc[0].$badsKill
		for( var i=0; i<this.mng.badsKillToCheck.length; i++ ){
			if( this.mng.badsKillToCheck[i] && list[i] >= this.mng.titemKillLimit ){
				//_root.test+="Found one\n"
				this.mng.badsKillToCheck[i] = undefined
				this.mng.client.giveItem("$bads"+i)
				var initObj = {
					type:"titem",
					num:i,
					nextPage:{link:"miniWave2PageMain"}
				}
				this.initPage( { link:"miniWave2PagePowerUp", initObj:initObj } )
				return true;
			}
		}
		
		// CHECK NEW TITEM
		if( this.mng.newTitem > 0 ){
			this.mng.newTitem--;
			var initObj = {
				type:"titem",
				num:i,
				nextPage:{link:"miniWave2PageMain"}
			}
			this.initPage( { link:"miniWave2PagePowerUp", initObj:initObj } )
			return true;			
		}
		
		return false;
		
		
	}
	

	function vanish(){
		this.timer = 40
		this.step = 1;
	}
	
	function selectMainLevel(){
		if(this.gameInfo.lvl == undefined ){
			//var info = this.mng.lvlInfoMain
			var info = miniwave.lvl.Main.level
			this.gameInfo.waveInfo = info.lvl 
			this.gameInfo.name = info.name
			this.gameInfo.shipMax = info.ship				
		}
		this.setNextPage({link:"miniWave2PageSelectShip"}); //this.setNextPage({link:"selectShip"});
	}
	
	function kill(){
		this.mng.music.stopSound("sMenu",1)
		super.kill();
	}
	
	
	
//{
}