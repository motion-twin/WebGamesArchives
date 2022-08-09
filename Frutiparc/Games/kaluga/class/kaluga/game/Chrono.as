class kaluga.game.Chrono extends kaluga.Game{//}

	// PARAMETRES
	var goalList:Array;
	
	// VARIABlES
	var step:Number;
	var max:Number;
	//var maxTimer:Number;
	var record:Array;
	//var timer:Number;
	
	//REFERENCES
	var barTimer:kaluga.bar.Timer
	
	
	function Chrono(){
		this.init();		
	}
	
	function init(){
		//_root.test += "[game.Chrono] init() level("+this.level+")\n"
		this.type = "$chrono"
		this.mapInfo = {
			skinLink:this.mng.client.getFileInfos("map/forest.swf").name,
			width:700,
			height:480
		};
		
		super.init();
		this.initScroller();
	};
		
	function initGame(){
		//this.maxTimer = 60000
		this.goalList = [60000,50000,45000,42000]
		super.initGame();
		this.step = 2;
		this.record = new Array();
		//_root.test+="this.level("+this.level+")\n"
	}
	
	function startGame(){
		super.startGame();
		this.barTimer = this.infoBar.addElement("barTimer")
		this.barTimer.startTimer();
		
	}
	
	function initStartPanel(){
		super.initStartPanel();
		this.startPanel.toRead = 1;
		this.startPanel.text = "Ramassez la totalité des pommes en moins de "+ext.util.MTNumber.getTimeStr(this.goalList[this.level],"'","''")+" !"
	};
	
	function initSprites(){
		//_root.test+="initSprite\n"
		super.initSprites();
		this.genTzongre();
		this.genPanier();
		this.max = 6+this.level*2
		for(var i=0; i<this.max; i++){
			this.genGroundFruit();
		}
		
		//this.genButterfly();
		
	}
	
	function update(){
		super.update();
		if(this.masterStep==1){
			switch(this.step){
				case 0:
					break;
				case 1:
					break;			
				case 2:
					//timer += kaluga.Cs.tmod;
					this.barTimer.update();
					if( this.checkEnd() ){
						this.barTimer.stopTimer();
						this.score = this.barTimer.time
						this.addScore();
						this.endGame();
						this.step=3;
					};
					if( this.barTimer.time > this.goalList[this.level] ){
						this.timeUp()
					}
					break;				
				case 3:
					break;
			}
		}
	}
		
	function genGroundFruit(){
		var w = 0.6+(this.level*0.4)+(random(40)/100)
		var r = w*12
		var initObj = {
			x:r+random(kaluga.Cs.mcw-(2*r)),
			weight:w
		};
		var mc = this.newFruit(initObj);
		mc.y = this.map.height-(this.map.groundLevel+mc.ray)
		mc.endUpdate();
	}

	function genTzongre(){
		var initObj = this.tzongreInfo
		initObj.x = kaluga.Cs.mcw/2;
		initObj.y = kaluga.Cs.mch/2;
		initObj.vity = -4;
		this.tzongre = this.newTzongre(initObj);
		this.tzongre.endUpdate();
	}	
	
	function checkEnd(){
		for( var i=0; i<this.fruitList.length; i++ ){
			if(!this.fruitList[i].flPanier)return false;
		}
		//_root.test+="end\n"
		return true;
	}

	function onAddFruit(){
		//_root.test+="this.barTimer.time("+this.barTimer.time+")\n"
		this.record.push(this.barTimer.time)
	}	
	
	function addScore(){
		//
		var card = this.mng.card.$chrono
		var list = card.$level[this.level]
		var rec = list[list.length-1]
		// VERIFIE POUR MAJ LE SCORE
		var best,worst;
		if(this.score<rec){
			card.$level[this.level] = this.record;
			best = this.score
			worst = rec
		}else{
			best = rec
			worst = this.score
		}

		
		// CONSTRUIT LA STAT LIST
		var maxResult = 8
		var statList = new Array;
		for( var i=0; i<this.max; i++ ){
			//var data = list[i];
			var obj = {
				value:this.record[i]/worst,
				ghost:list[i]/worst
				//num:data.s,
				//color:this.mng.color.tzPastel[data.t]
			}
			statList.push(obj)
		}		
		
		var lineCoef = 5000/worst
		//_root.test+="lineCoef("+lineCoef+")\n"
		
		var obj = {
			list:[
				{
					type:"bigScore",
					frame:3,
					score:ext.util.MTNumber.getTimeStr(this.score,"'","''")
				},
				{
					type:"bigScore",
					frame:2,
					score:ext.util.MTNumber.getTimeStr(best,"'","''")
				},
				{
					type:"margin",
					value:15
				},
				{
					type:"graph",
					gfx:"partGraphCurve",
					box:{x:20,y:6,w:420,h:230},
					//color:{main:this.mng.color.tzPastel[this.tzongreInfo.id],line:0xFFFFFF},
					maxResult:this.max,
					margin:10,
					list:statList,
					flGhost:true,
					flLine:true,
					flNode:true,
					flCurve:false,
					nodeFrame:1,
					line:lineCoef,
					lineBase:5,
					marginInt:16,
					marginUp:16,
					lineSuffix:"sec.",
					flBackground:true
				}
			]
		}
		this.endPanelMiddle.push(obj)
		
		// DEBLOQUAGE DE MODE
		if( this.score <= this.goalList[this.level] ){
			this.checkUnlock(2)
		}
		
		// SAVE SLOT
		this.mng.client.saveSlot(0)
		
		
	}
	
	function reset(){
		var initObj = {
			level:this.level
		}
		super.reset(initObj)
	}
	
	function timeUp(){
		var msgList = [
			this.tzongre.name+" n'a pas réussi à rassembler toutes les pommes à temps.",
			"Le temps reglementaire est écoulé, "+this.tzongre.name+" a échoué.",
			this.tzongre.name+" a manqué de précision sur cette partie.",
			"Le panier de "+this.tzongre.name+" n'a pas été rempli dans les temps."
		]
		var obj = {
			label:"basic",
			list:[
				{
					type:"msg",
					title:"Trops tard!",//titleList[random(titleList.length)],
					msg:msgList[random(msgList.length)]
				}
			]
		}
		this.endPanelStart.push(obj)
		this.step = 3
		this.endGame();
	}
//{	
}



















