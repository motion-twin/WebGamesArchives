class kaluga.game.Train extends kaluga.Game{//}

	// CONSTANTES
	
	// VARIABLES
	var step:Number;

	// REFERENCES
		
	function Train(){
		this.init();
	}
	
	function init(){
		this.type = "$train"
		var name  = this.mng.client.getFileInfos("map/challenge.swf").name
		//_root.test += " map/challenge.swf >>>"+name+"\n"
		this.mapInfo = {
			skinLink:name,
			groundLabel:"challenge",
			width:700,
			height:480
		};
		super.init();
		this.step = 0;
	}
	
	function initGame(){
		super.initGame();
		this.initFeuillage("challenge");	
	}
	
	function startGame(){
		super.startGame();
		this.step = 1;
		this.map.bg.animPorte.play();
	}
	
	function initStartPanel(){
		super.initStartPanel();
		this.startPanel.toRead = 3;
	};

	function initSprites(){
		super.initSprites();
		//this.genPanier();
		for(var i=0; i<6; i++){
			this.genGroundFruit();
		}
	}
	
	function initDefault(){
		super.initDefault();
		if(this.level == undefined) 		this.level = 0;
	}

	function update(){
		super.update();
		switch( this.step ){
			case 0:
				break;
			case 1:
				if(this.map.bg.animPorte._currentframe>70){
					this.step = 2;
					this.genTzongre();
					this.tzongre.unFreeze();
				};
				break;
			case 2:
				if( !random(1000) )this.genButterfly();
				
				//
				break;			
		}
	}
	//

	function genButterfly(){
		var id = random(3);
		var initObj = new Object();
		initObj.id = id;
		var mc = this.newButterfly(initObj);
		var side = random(2)*2 - 1;
		var w = this.map.width/2;
		mc.x = w + (w+10)*side;
		mc.y = random(this.map.height - this.map.groundLevel);
		mc.setSens(-side);
		return mc;
	}
	
	
	
	// GENERATOR

	function genTzongre(){
		var initObj = this.tzongreInfo
		this.tzongre = this.newTzongre(initObj);
		this.tzongre.x = this.map.bg.animPorte._x
		this.tzongre.y = this.map.bg.animPorte._y
		this.tzongre.vitx = 8
		this.tzongre.vity = -4
		
		this.tzongre.endUpdate();
	}		
	
	function genGroundFruit(){
		var w = 0.5+random(10)/10
		var r = w*12
		var initObj = {
			x:r+random(kaluga.Cs.mcw-(2*r)),
			weight:w
		};
		var mc = this.newFruit(initObj);
		
		mc.y = this.map.height-(this.map.groundLevel + mc.ray)
		mc.endUpdate();	
	}


//{	
}

























