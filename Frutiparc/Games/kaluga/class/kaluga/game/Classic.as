class kaluga.game.Classic extends kaluga.Game{//}

	// CONSTANTES
	var caterLimit:Number = 	6;
	var antLimit:Number = 		16;
	var squirrelLimit:Number = 	2;
	var frogLimit:Number = 	3;
	
	// VARIABLES
	var flFruitFalling:Boolean;
	var step:Number;
	var kilo:Number;
	var kiloMax:Number;
	var fruitBase:Number;
	var fruitBaseMax:Number;
	var optionProbaTotal:Number;
	var birdCoolDown:Number;
	
	var optionProbaList:Array;
	var difTimer:Number
	
	// REFERENCES
		
	function Classic(){
		this.init();
	}
	
	function init(){
		/* TZINFO HACK
		this.tzongreInfo = {
			id:0,
			name:"Kaluga",
			weight:0.3,
			nbPower:2,
			nbBoost:1,
			nbBoostFrict:0.98,
			nbResist:0.90,
			nbThrust:0.9,
			nbTurn:2.4,
			nbTurnMalus:0.8,
			nbPower:0.04,
			nbDodge:1.8,
			nbMulti:4,
			nbCombo:4,
			nbFilMax:200,
			cligneRand:200,
			stats:[3,4,4,3,3]
		}
		//*/

		this.type = "$classic"
		var name  = this.mng.client.getFileInfos("map/challenge.swf").name
		//_root.test += " map/challenge.swf >>>"+name+"\n"
		this.mapInfo = {
			skinLink:name,
			groundLabel:"challenge",
			width:700,
			height:480
		};
		this.initOptionProba();
		super.init();
		this.step = 0;
	}
	
	function initGame(){
		super.initGame();
		this.initFeuillage("challenge");	
	}
	
	function startGame(){
		super.startGame();
		this.difTimer = 0;
		this.kilo = 0;
		this.step = 1;
		this.initScroller();
		this.kiloPanel.setCoef(this.kilo/this.kiloMax);
		this.map.bg.animPorte.play();
		this.birdCoolDown = 10000000
		//_root.test+="this.map.bg.animPorte("+this.map.bg.animPorte+")\n"
		//_root.test+="this.map.bg("+this.map.bg+")\n"
	}
	
	function initStartPanel(){
		super.initStartPanel();
		this.startPanel.toRead = 2;
	};

	function initSprites(){
		super.initSprites();
		//this.genTzongre();
		this.genPanier();
		for(var i=0; i<Math.round(this.fruitBase/2); i++){
			this.genGroundFruit();
		}
		// DEBUG
		//this.genButterfly(0)
		//this.genButterfly(1)
		
	}
	
	function initDefault(){
		super.initDefault();
		if(this.level == undefined) 		this.level = 0;
		if(this.fruitBase == undefined) 	this.fruitBase = 4;
		if(this.fruitBaseMax == undefined) 	this.fruitBaseMax = 8;
		if(this.kiloMax == undefined) 		this.kiloMax = 80;
		if(this.flFruitFalling == undefined)	this.flFruitFalling = true;
	}
	
	function initOptionProba(){
		this.optionProbaList = [
			30,	// MULTI
			30,	// CHAIN
			8,	// POWER
			4,	// DODGE
			12,	// SUPER
			2,	// JUMP
			6,	// CLEANER
			10	// ABONDANCE
		]
		this.optionProbaTotal = 0;
		for( var i=0; i<this.optionProbaList.length; i++ ){
			this.optionProbaTotal += this.optionProbaList[i]
		}
	}
	
	function initInfoBar(){
		super.initInfoBar();
		this.kiloPanel = this.infoBar.addElement("barDisc",{width:30, link:"discFruit"})
		this.scorePanel = this.infoBar.addElement("barScore")
		//this.kiloPanel = this.infoBar.addElement("barDisc",{width:36})
		this.updateScore();
		this.kiloPanel.setCoef(0);
	}
	
	function getOption(){
		var rand = random(this.optionProbaTotal)
		var n = 0
		var total = this.optionProbaList[n];
		while( total < rand ){
			n++;
			total += this.optionProbaList[n];
		}
		return n;
	}
	
	//
	function update(){
		
		//_root.test="-"+badList.length+"-\n"
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
				this.birdCoolDown-=kaluga.Cs.tmod
				if( this.birdCoolDown < 0 && this.frogList.length<this.frogLimit){
				 	this.genFrog();
					this.birdCoolDown = 2000;
				}
	
				this.difTimer -= kaluga.Cs.tmod
				if(this.difTimer<0)this.levelUp();

				if( this.flFruitFalling && this.fruitList.length < this.fruitBase ){
					this.genTreeFruit();
				}
				
				this.checkFruit();
				break;			
			
		}
		// CHEAT
		/*
		if(Key.isDown(Key.SHIFT)){
			this.score += 1000;
			this.updateScore();
		}
		*/
		//

		
	}
	//
	function levelUp(){
		//
		this.level++;
		this.difTimer = 500+100*this.level;
		this.fruitBase = Math.min( this.fruitBase+0.2, this.fruitBaseMax)
		
		//_root.test += "this.fruitBase("+this.fruitBase+")\n"

		/*
		this.genButterfly();
		this.genAnt(random(2)*2-1);
		this.genCaterpillar(random(2)*2-1);
		this.genFrog();
		this.genSquirrel();
		*/
		
		
		/*
		if(level==1){
			var side = random(2)*2-1
			var mc = this.genAnt(side);
	
		}
		*/
		
		//* ANT
		if( !random(3) && this.antList.length<this.antLimit ){

			var side = random(2)*2-1
			var max = Math.round(this.level/2.5)
			var max = Math.round(this.level/2.5)
			var max = Math.round(this.level/2.5)
			for(var i=0; i<max; i++){
				var mc = this.genAnt(side);
				mc.x += side*i*10
			}
		}


		//* BUTTERFLY
		if( this.level>1 && !random(3) ){
			this.genButterfly();
		}

		//* CATERPILLAR
		if( level>2 && this.caterpillarList.length<this.caterLimit && !random(3)){
			var side = random(2)*2-1	// NOUVEAU
			this.genCaterpillar(side);
		}		

		//* FROG
		var ratio = this.kilo/this.kiloMax
		if( random(ratio*100) > 40 && random(2) && this.frogList.length<this.frogLimit ){
			this.genFrog();
		}			
		
		//* SQUIRREL
		if( (this.squirrelList.length+1)*10 < this.level  && !random(2)  && this.squirrelList.length<this.squirrelLimit ){
			this.genSquirrel();
		}
		
		// BIRD
		//this.genSquirrel();
		
		//*/
	}
			
	function getFruitWeight(){
		/*
		var toFill = this.kiloMax - this.kilo;
		var w = 0.5+random(10+this.level)/10;//0.5+random(10+this.level)/10;
		//w = 3
		if( w+1 >toFill ){
			w = toFill
		}
		this.kilo += w;
		*/
		var w = 0.5 + random(10+this.level)/10;
		//var w = 1 + random(30)/10;
		var dif = this.kiloMax - (this.kilo+w);
		if(dif<0.5){
			w = this.kiloMax - this.kilo
			this.flFruitFalling = false;
		}
		//_root.test+="final w("+w+")\n"
		this.kilo += w;
		return w;
	}
	
	// GENERATOR
	
	function genButterfly(id){
		if(id==undefined) id = this.getOption();
		var initObj = new Object()
		initObj.id = id
		var mc = this.newButterfly(initObj);
		var side = random(2)*2 - 1;
		var w = this.map.width/2;
		mc.x = w + (w+10)*side;
		mc.y = random(this.map.height - this.map.groundLevel);
		mc.setSens(-side);
		this.stat.incVal("Nombre de papillon",1)
		return mc;
	}
	
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
		var w = getFruitWeight()
		var r = w*12
		var initObj = {
			x:r+random(kaluga.Cs.mcw-(2*r)),
			weight:w
		};
		if(this.kilo == this.kiloMax){
			initObj.flGold = true;
		}
		var mc = this.newFruit(initObj);
		
		mc.y = this.map.height-(this.map.groundLevel + mc.ray)
		mc.endUpdate();	
		this.stat.incVal("Nombre de pomme",1)
	}
	
	function genTreeFruit(){
		var ratio = this.kilo/this.kiloMax
		if(ratio==1)return;
		var w = getFruitWeight()
		var r = w*12
		var initObj = {
			x:r+random(kaluga.Cs.mcw-2*r),
			weight:w,
			flTree:true,
			flGround:true
		};
		if(this.kilo == this.kiloMax){
			initObj.flGold = true;
			this.newBird();
		}
		var mc = this.newFruit(initObj) ;
		mc.y = -1000 ;
		mc.recal() ;
		mc.endUpdate() ;
		// AFFICHAGE
		
		if(this.masterStep==1)this.kiloPanel.setCoef(ratio)
		
		if(ratio==1){
			this.kiloPanel.skin.gotoAndStop(3)
		}
		this.stat.incVal("Nombre de pomme",1)
		//for(var i=0; i<60; i++)this.stat.incVal("truc"+i,1);	// HACK
		return mc;
		
	}
	
	function genCaterpillar(side){
		if( side == undefined ) side = random(2)*2 - 1
		var w = this.map.width/2
		var initObj = {
			x:w + (w+10)*side,
			y:this.map.height - this.map.groundLevel
		}		
		var mc = this.newCaterpillar(initObj);
		mc.setSens(-side)
		this.stat.incVal("Nombre de ver",1)
		return mc;
	}
	
	function genAnt(side){
		if( side == undefined ) side = random(2)*2 - 1
		var w = this.map.width/2
		var initObj = {
			x:w + (w+10)*side,
			y:this.map.height - this.map.groundLevel
		}
		var mc = this.newAnt(initObj);
		mc.setSens(-side)
		this.stat.incVal("Nombre de fourmi",1)
		return mc;
	}
	
	function genSquirrel(side){
		var mc = this.newSquirrel();
		if( side == undefined ) side = random(2)*2 - 1
		var w = this.map.width/2
		mc.x = w + (w+10)*side
		mc.y = this.map.height - this.map.groundLevel;
		mc.setSens(-side)
		this.stat.incVal("Nombre d'écureuil",1)
		return mc;		
	}
	
	function genFrog(){
		var sens = (random(2)*2)-1
		var w = this.map.width/2
		var initObj = {
			x:w-(w+6)*sens,
			y:this.map.height-this.map.groundLevel,
			mobilite:100
		};
		var mc = this.newFrog(initObj);
		mc.setSens(sens)
		mc.endUpdate();
		mc.focus = this.tzongre;
		this.stat.incVal("Nombre de grenouille",1)
		this.mng.sfx.play("sFrog")
		return mc;
	}
	
	function initEndGame(timer){
		
		if( this.mng.client.isWhite() ){
			//_root.test+="---\n"
			if( this.score > this.mng.card.$classic.$s ){
				//_root.test+="-\n"
				var text = "Record général battu !!\n"
				if( this.mng.card.$classic.$s > 0 ){
					text += "Ancien record : "+this.mng.card.$classic.$s+" ("+this.mng.tzInfo[this.mng.card.$classic.$t].name+")\n"
				}
				text += "Nouveau record : "+this.score+" ("+this.mng.tzInfo[this.tzongreInfo.id].name+")\n"
				
				var o = {
					label:"congrat",
					list:[
						{
							type:"congrat",
							text:text,
							id:12
						}
					]
				};
				this.endPanelMiddle.push(o);
				
				this.mng.card.$classic.$s = this.score;
				this.mng.card.$classic.$t = this.tzongreInfo.id;
				this.mng.client.saveSlot(0)
				
				
			}
		}
		
		
		super.initEndGame(timer);
		
		
		
		
		//super.initEndGame(timer);
	}
	
	function onFruitEatFinish(){
		super.onFruitEatFinish()
		this.stat.incVal("Pommes perdues",1)
	}
	
	function onAddFruit(){
		super.onAddFruit(score);
		this.birdCoolDown = 2400//2400;
	};

	function scoreSaved(){
		super.scoreSaved();
		
		// STATS
		var name = "";
		var score = "";
		name += "<b>Général:</b>\n";			score += "\n";
		name += this.stat.getList("name");		score += this.stat.getList("score");
		name += "<b>Combo:</b>\n";			score +="\n";
		name += this.statCombo.getList("name");		score += this.statCombo.getList("score");
	
		var obj = {
			list:[
				{
					type:"bigScore",
					frame:1,
					score:this.score
				},
				{
					type:"stats",
					box:{x:82,y:16,w:280,h:200},
					name:name,
					score:score
				}				
			]
		};
			
		
		// CLASSEMENT CHALLENGE
		if( this.mng.client.isBlack() ||  this.mng.client.isGrey() ){
			//ranking.rankingScore,ranking.oldScore,ranking.oldPos,ranking.bestScorePos
			var rnk  = this.mng.client.ranking
			
			var o = {
					type:"bigScore",
					frame:7,
					score:rnk.bestScorePos		
			}
			
			//_root.test+="this.mng.client.ranking.bestScorePos("+this.mng.client.ranking.bestScorePos+")\n"
			//_root.test+="this.mng.client.ranking("+this.mng.client.ranking+")\n"
			obj.list.splice(1,0,o)
			
			
			if( rnk.rankingScore == rnk.bestScore && rnk.oldPos>0 ){
				var dif = rnk.oldPos-rnk.bestScorePos
				var txt  = "Vous avez battu votre meilleur score!!\n Vous avez gagné "+dif+" place";
				if(dif>1)txt+="s ";
				txt += "\n"
				
				var obj2 = {
					label:"congrat",
					list:[
						{
							type:"congrat",
							text:txt,
							id:11
						}
					]
				};
				this.endPanelMiddle.push(obj2)
				
			}
		}
		
		this.endPanelMiddle.push(obj)
		
	}	
	
	function checkFruit(){
		if( this.fruitList.length == 0 ){
			this.initEndGame(120)
		}
	}
	
//{	
}

























