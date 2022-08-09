class kaluga.game.Ring extends kaluga.Game{//}

	// CONSTANTES
	var goalList:Array;
	// PARAMETRES
	//var level:Number;
	
	// VARIABLES
	var timer:Number;
	var step:Number;
	var maxTimer:Number;
	var levelData:Object;
	var currentRing:Number;
	var ringSpace:Number;
	var ringList:Array;
	
	// REFERENCES
	var piste:MovieClip;
	var fruit:kaluga.sp.phys.Fruit;
	var barTimer:kaluga.bar.Timer
	
	
	function Ring(){
		this.init();
	}
	
	function init(){
		//_root.test+="[game.Ring] init()\n"

		this.goalList = [45000,90000,90000,90000]
		
		this.type = "$ring"
		this.levelData = this.getLevelData();
		//_root.test="levelData.list("+this.levelData.list+")\n"

		this.mapInfo = {
			skinLink:this.mng.client.getFileInfos("map/forest.swf").name,
			width:this.levelData.e+150,
			height:480
		};
		super.init();
		this.step = 0;
		this.initScroller();
	}

	function initStartPanel(){
		super.initStartPanel();
		this.startPanel.text = ext.util.MTNumber.getTimeStr(this.goalList[this.level],"'","''")
		this.startPanel.toRead = 1;
	};
	
	function initSprites(){
		super.initSprites();
		this.genGroundFruit();
		this.genTzongre();
		var pmax = 20
		this.genPiste();

	}
	
	function genPiste(){
		
		var pStart = this.levelData.s
		var pEnd = this.levelData.e
		
		
		// POTEAU
		this.newDecor("decorPoteau",	{ x:pStart,	y:this.map.height,	depthCoef:0.8,	width:30	})
		this.newDecor("decorPoteauGong",{ x:pEnd,	y:this.map.height,	depthCoef:0.9,	width:30	}) 
		
		// STARTFLAG
		this.newDecor("decorStartFlag",{ x:pStart, y:(this.map.height-320), depthCoef:1, widthCoef:0.8,	width:100 })		
		
		// GONG
		this.newDecor("decorGong",{ x:pEnd, y:this.map.height, depthCoef:1, widthCoef:0.9,	width:100 })
		
		
		// RING
		var ringMax = this.levelData.list.length;
		this.ringSpace =  (pEnd-pStart)/(ringMax-1)
		
		//_root.test+="ring("+ringMax+")\n"
		this.ringList = new Array();
		for( var i=0; i<(ringMax-1); i++ ){
			var info = this.levelData.list[i];
			var  obj = this.newDecor("decorRing",{ x:pStart+i*this.ringSpace, y:info.y, depthCoef:1.0001, widthCoef:0.9, width:info.r, yscale:info.r, frame:1 })
			this.ringList.push(obj)
		}
		
		// POTEAU
		this.newDecor("decorPoteau",{ x:pStart, y:this.map.height, depthCoef:1.25,	width:30 })
		this.newDecor("decorPoteauGong",{ x:pEnd, y:this.map.height, depthCoef:1.11,	width:30 })
		
			
	}
	
	function genTzongre(){
		var initObj = this.tzongreInfo
		
		//initObj.game = this;
		initObj.x = kaluga.Cs.mcw/2
		initObj.y = kaluga.Cs.mch/2
		initObj.vity = -4
		this.tzongre = this.newTzongre(initObj);
		//this.tzongre.vx = 100
		//this.tzongre.x = 200
		//this.focus = this.tzongre;
		this.setCameraFocus(this.tzongre)
		this.tzongre.endUpdate();
		
	};
	
	function genGroundFruit(){
		var w =1;
		var initObj = {
			x:20,
			weight:w			
		};
		this.fruit = this.newFruit(initObj);
		this.fruit.y = this.map.height-(this.map.groundLevel+this.fruit.ray)
		this.fruit.endUpdate();
	}	

	function update(){
		super.update();
		//_root.test=">"+this.step+"\n"
		//var x = this.fruit.x + this.mapDecal.x
		//var y = this.fruit.y + this.mapDecal.y

		switch(this.step){
			case 0 :	// 
				break;
			case 1 :	// 
				this.barTimer.update();
				if( this.fruit.x < this.levelData.s){
					this.step = 1.5;
					this.currentRing = 0
					this.changeRingLight(2)
				}
				break;
			case 1.5:
				this.barTimer.update();
				if( this.fruit.x > this.levelData.s ){
					if(this.checkFruitInRing()){
						this.step = 2;
						this.changeRingLight(1)
						this.currentRing++;
						this.changeRingLight(2)
						this.barTimer.startTimer();
						break;
					}else{
						this.step = 1;
						this.changeRingLight(1)
					}
				}
				break ;
			case 2 :	// 
				this.barTimer.update();
				
				var nextX = this.levelData.s+this.currentRing*this.ringSpace;
				
				if( this.fruit.x>nextX ){
					if(this.checkFruitInRing()){
						//_root.test+=">"+this.currentRing+"\n"
						this.changeRingLight(1)
						this.currentRing++;
						this.changeRingLight(2)

						
						if( this.currentRing == this.levelData.list.length ){
							this.hitGong();
							break;
						}else{
							this.mng.sfx.play("sRing");
						}
					}else{
						this.tzongre.release();
						this.barTimer.kill();
						this.step = 0;
						// CHECK COLLIDE
						var ring = this.levelData.list[this.currentRing]
						var dify = Math.abs(this.fruit.y - ring.y)
						//_root.test+="dify("+dify+") ring.r+this.fruit.ray("+((ring.r/2)+this.fruit.ray)+")\n"
						if( dify < (ring.r/2)+this.fruit.ray ){
							this.fruit.vitx*=-0.8
						}
						// ETEINT TOUTE LES RINGS
						for(var i=0; i<this.ringList.length; i++){
							this.currentRing = i
							this.changeRingLight(1)
						}
					}
				};
				break;
			case 3 :	//
				this.timer -= kaluga.Cs.tmod;
				if(timer<0){
					this.endGame();	
					this.step = 4					
				}
				break;
			case 4 :	//  
				break;				
				
		}
	}
	
	function onTzLink(tzongre){
		if( this.step == 0 ){
			this.step = 1;
			this.barTimer = this.infoBar.addElement("barTimer")
			this.barTimer.setTimer(0)			
		}
		
	}
	
	function hitGong(){
		this.mng.sfx.play("sGong");
		//
		this.barTimer.stopTimer();
		this.score = this.barTimer.time;
		this.addScore();
		this.timer = 24;
		//
		this.tzongre.release();
		this.fruit.vitx *= -1;
		this.step = 3;
	}
	
	function onTzRelease(tzongre){
		if(step==1){
			this.step = 0;
			this.barTimer.kill();
		}
	}
	
	function addScore(){
				//
		var card = this.mng.card.$ring
		var info = card.$level[this.level]
		
		//_root.test+="card>"+card+"\n"
		//_root.test+="info>"+info+"\n"
		// VERIFIE POUR MAJ LE SCORE
		if(this.score<info.$s){
			info.$s = this.score;
			info.$t = this.tzongreInfo.id
		}

		
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
					score:ext.util.MTNumber.getTimeStr(info.$s,"'","''")
				}

			]
		}
		this.endPanelMiddle.push(obj)
		
		// DEBLOQUAGE DE MODE
		if( this.score <= this.goalList[this.level] ){
			this.checkUnlock(5)
		}
		
		// SAVE SLOT
		this.mng.client.saveSlot(0)
		
	}
	
	function checkFruitInRing(ring){
		var ring = this.levelData.list[this.currentRing]
		var y = this.fruit.y
		return ( y+this.fruit.ray < ring.y+ring.r/2 && y-this.fruit.ray > ring.y-ring.r/2 )
		
	}

	function reset(){
		var initObj = {
			level:this.level
		}
		super.reset(initObj)
	}
	
	function changeRingLight(frame){
		var obj = this.ringList[this.currentRing]
		obj.frame = frame
		if( obj.path != undefined )obj.path.gotoAndStop(frame);	
	}
	
	//DATA
	function getLevelData(){
		
		var o = {
			s:250,
			e:2250			
		}
		switch(this.level){
			case 0:
				//{
				o.list = [
					{ y:270, r:200 },		
					{ y:260, r:200 },
					{ y:250, r:200 },
					{ y:260, r:200 },
					{ y:260, r:200 },
					{ y:250, r:200 },
					{ y:240, r:200 },
					{ y:230, r:190 },
					{ y:220, r:180 },
					{ y:210, r:170 },
					{ y:210, r:160 },
					{ y:220, r:150 },
					{ y:240, r:140 },
					{ y:260, r:150 },
					{ y:280, r:160 },
					{ y:300, r:170 },
					{ y:290, r:180 },
					{ y:280, r:190 },
					{ y:270, r:200 },
					{ y:260, r:200 },
					{ y:250, r:200 },
					{ y:260, r:200 },
					{ y:270, r:200 },
					{ y:270, r:160 }
				]
				o.e = 7000
				//}
				break;
			case 1:
				//{
				o.list = [
					{ y:270, r:170 },		
					{ y:270, r:170 },		
					{ y:270, r:170 },		
					{ y:320, r:170 },
					{ y:220, r:170 },
					{ y:320, r:170 },
					{ y:220, r:170 },
					{ y:270, r:170 },
					{ y:270, r:170 },
					{ y:270, r:160 },
					{ y:270, r:150 },
					{ y:270, r:140 },
					{ y:270, r:130 },
					{ y:270, r:120 },
					{ y:270, r:110 },
					{ y:270, r:100 },
					{ y:270, r:110 },
					{ y:270, r:120 },
					{ y:270, r:130 },
					{ y:270, r:140 },
					{ y:270, r:150 },
					{ y:270, r:160 },
					{ y:270, r:170 },
					{ y:270, r:170 },
					{ y:270, r:170 },
					{ y:260, r:170 },
					{ y:240, r:170 },
					{ y:210, r:170 },
					{ y:170, r:170 },
					{ y:140, r:170 },
					{ y:120, r:170 },
					{ y:110, r:170 },
					{ y:120, r:170 },
					{ y:140, r:170 },
					{ y:170, r:170 },
					{ y:210, r:170 },
					{ y:260, r:170 },
					{ y:300, r:170 },
					{ y:330, r:170 },
					{ y:350, r:170 },
					{ y:360, r:170 },
					{ y:360, r:170 },
					{ y:360, r:170 },
					{ y:350, r:170 },
					{ y:330, r:170 },
					{ y:300, r:170 },
					{ y:300, r:170 },
					{ y:300, r:170 },
					
					{ y:290, r:170 },
					{ y:310, r:170 },
					
					{ y:280, r:170 },
					{ y:320, r:170 },
					
					{ y:270, r:170 },
					{ y:330, r:170 },
					
					{ y:260, r:170 },
					{ y:340, r:170 },
					
					{ y:250, r:170 },
					{ y:350, r:170 },
					
					{ y:260, r:170 },
					{ y:340, r:170 },
					
					{ y:250, r:170 },
					{ y:350, r:170 },
					
					{ y:260, r:170 },
					{ y:340, r:170 },
					
					{ y:270, r:170 },
					{ y:330, r:170 },
					
					{ y:280, r:170 },
					{ y:320, r:170 },
					
					{ y:290, r:170 },
					{ y:310, r:170 },
					
					{ y:270, r:180 }
				]
				o.e = 15000
				// AJUSTEMENT
				for( var i=0; i<o.list.length; i++ ) o.list[i].r += 10;
					
					
				//}
				break;
			case 2:
				//{
				o.list = [
					{ y:320, r:200 },		
					{ y:310, r:190 },	
					{ y:290, r:170 },	
					{ y:260, r:140 },	
					{ y:240, r:120 },	
					{ y:230, r:110 },
					{ y:230, r:110 },
					{ y:220, r:120 },
					{ y:200, r:140 },
					{ y:170, r:170 },
					{ y:150, r:190 },
					{ y:140, r:200 },
					{ y:140, r:200 },
					{ y:150, r:190 },
					{ y:150, r:190 },
					{ y:170, r:170 },
					{ y:200, r:140 },
					{ y:220, r:120 },
					{ y:230, r:110 },
					{ y:230, r:110 },
					{ y:230, r:110 },
					{ y:230, r:110 },
					{ y:230, r:110 },
					{ y:250, r:110 },
					{ y:290, r:110 },
					{ y:310, r:110 },
					{ y:320, r:110 },
					{ y:320, r:110 },
					{ y:310, r:110 },
					{ y:290, r:110 },
					{ y:250, r:110 },
					{ y:240, r:110 },
					{ y:250, r:110 },
					{ y:290, r:110 },
					{ y:310, r:110 },
					{ y:320, r:110 },
					{ y:320, r:120 },
					{ y:310, r:130 },
					{ y:300, r:140 },
					{ y:290, r:150 },
					{ y:280, r:160 },
					{ y:270, r:170 },
					{ y:260, r:160 },
					{ y:250, r:150 },
					{ y:240, r:140 },
					{ y:230, r:130 },
					{ y:220, r:120 },
					{ y:210, r:110 },
					{ y:200, r:100 },
					{ y:190, r:90 },
					{ y:190, r:90 },
					{ y:190, r:90 },
					{ y:190, r:90 },
					{ y:180, r:90 },
					{ y:160, r:90 },
					{ y:130, r:90 },
					{ y:110, r:90 },
					{ y:100, r:90 },
					{ y:100, r:90 },
					{ y:110, r:90 },
					{ y:130, r:100 },
					{ y:160, r:110 },
					{ y:180, r:120 },
					{ y:190, r:130 },
					{ y:200, r:130 },
					{ y:210, r:130 },
					{ y:220, r:130 },
					{ y:230, r:130 },
					{ y:240, r:130 },
					{ y:250, r:130 },
					{ y:250, r:130 },
					{ y:250, r:130 },
					
					{ y:190, r:150 },
					{ y:310, r:150 },
					
					{ y:190, r:140 },
					{ y:310, r:140 },
					
					{ y:190, r:130 },
					{ y:310, r:130 },
					
					{ y:200, r:120 },
					{ y:300, r:120 },
					
					{ y:210, r:110 },
					{ y:290, r:110 },
					
					{ y:220, r:100 },
					{ y:280, r:100 },
					
					{ y:230, r:90 },
					{ y:270, r:90 },
					
					{ y:240, r:80 },
					{ y:250, r:80 },
					
					{ y:245, r:80 },
					{ y:250, r:90 },
					{ y:255, r:100 },
					{ y:260, r:110 },
					{ y:265, r:120 },
					{ y:270, r:130 }
				]
				o.e = 16000;
				for( var i=0; i<o.list.length; i++ ) o.list[i].r += 20;
				//}
				break;
			case 3:
				//{
				o.list = [
					{ y:320, r:120 },
					{ y:320, r:130 },
					{ y:320, r:140 },
					{ y:320, r:150 },
					{ y:320, r:160 },
					{ y:320, r:170 },
					{ y:320, r:180 },
					{ y:320, r:190 },
					{ y:320, r:200 },
					{ y:100, r:150 },
					{ y:300, r:150 },
					{ y:200, r:150 },
					{ y:400, r:150 },
					{ y:100, r:150 },
					{ y:300, r:150 },
					{ y:200, r:150 },
					{ y:400, r:150 },
					
					{ y:100, r:150 },
					{ y:200, r:150 },
					{ y:300, r:150 },
					{ y:400, r:150 },
					
					{ y:100, r:150 },
					{ y:200, r:150 },
					{ y:300, r:150 },
					{ y:400, r:150 },
					
					{ y:100, r:150 },
					{ y:200, r:150 },
					{ y:300, r:150 },
					{ y:400, r:150 },
					
					{ y:405, r:140 },
					{ y:415, r:120 },
					{ y:430, r:90 },
					{ y:440, r:70 },
					{ y:445, r:60 },
					{ y:445, r:60 },
					{ y:445, r:60 },
					{ y:445, r:60 },
					{ y:445, r:60 },
					{ y:445, r:60 },
					{ y:445, r:60 },
					{ y:445, r:60 },
					{ y:445, r:60 },
					{ y:445, r:60 },
					{ y:445, r:60 },
					{ y:445, r:60 },
					
					{ y:300, r:80 },
					{ y:300, r:80 },
					{ y:300, r:80 },
					{ y:300, r:80 },
					{ y:300, r:80 },
					{ y:300, r:80 },

					{ y:200, r:80 },
					{ y:200, r:80 },
					{ y:200, r:80 },
					{ y:200, r:80 },
					{ y:200, r:80 },
					{ y:200, r:80 },
					
					{ y:100, r:80 },
					{ y:100, r:80 },
					{ y:100, r:80 },
					{ y:100, r:80 },
					{ y:100, r:80 },
					{ y:100, r:80 },
					
					{ y:270, r:130 }
				
				]
				o.e = 14000;
				//}
				break;
		}	
		
		return o;
		
	}
		
//{	
}






















