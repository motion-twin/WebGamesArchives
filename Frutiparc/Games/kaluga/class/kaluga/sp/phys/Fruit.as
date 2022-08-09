class kaluga.sp.phys.Fruit extends kaluga.sp.Phys{//}
	
	// CONTANTES
	var antResist:Number = 400;
	var cBoundGround:Number = 0.7;
	var cBoundSide:Number = 0.9;
	var maxCrunchFrame:Number = 6;
	var dunkPowerLimit:Number = 18//24;
	var treeFallSpeed:Number = 0.04
	
	//VARIABLES

	var flPanier:Boolean;
	var flTree:Boolean;
	var flGold:Boolean;
	var flSky:Boolean;
	var flScoreAble:Boolean;
	//
	var flScDirect:Boolean;
	var flScBound:Boolean;
	var flScSide:Boolean;
	var flScDunk:Boolean;
	var flScNoLink:Boolean;
	var flScHead:Boolean;
	var flScSquirrel:Boolean;
	var flScBird:Boolean;
	var flScLateral:Boolean;
	//
	var growCoefBonus:Number;
	var antMove:Number;
	var treeTimer:Number;
	var ray:Number;
	var circ:Number;
	var vitRoll:Number
	var holeNum:Number;
	var caterNum:Number;
	//var antNum:Number;
	var depthNum:Number;
	var crunch:Number;
	var headCoolDown:Number;
	
	var antList:Array;
			
	// REFERENCE
	var panier: MovieClip;
	
	// MOVIECLIP 
	var mask:MovieClip;
	var pomme:MovieClip;
	var light:MovieClip;
	var queue:MovieClip;
	
	function Fruit(){
		this.init()
	}
	
	function init(){
		this.type = "Fruit"
		super.init();
		this.holeNum = 0;
		this.caterNum = 0;
		//this.antNum = 0;
		this.depthNum = 0;
		this.vitRoll = 0;
		this.antList = new Array();
		this.flPanier = false ;
		this.flSky = false ;
		this.flScoreAble = true;
		//
		if(this.flGold){
			this.gotoAndStop(2)
		}else{
			this.gotoAndStop(1)
		}
		this.pomme.stop();		
		//
		this.setRay(this.weight*12); ;
		this.pomme._xscale = this.ray*2;
		this.pomme._yscale = this.ray*2;
		this.light._xscale = this.ray*2;
		this.light._yscale = this.ray*2;
		this.queue._xscale = this.ray*2;
		this.queue._yscale = this.ray*2;		
		//
		this.flScDirect = 	this.flTree
		this.flScBound = 	false;
		this.flScSide = 	false;
		this.flScDunk = 	false;
		this.flScNoLink = 	true;
		this.flScHead = 	false;
		this.flScSquirrel = 	false;
		this.flScBird = 	false;
		this.flScLateral = 	false;

	}
	
	function initDefault(){
		if(this.weight == undefined) this.weight = 1;
		super.initDefault();
		if( this.treeTimer == undefined )	this.treeTimer = 0
		if( this.crunch == undefined )		this.crunch = 0;
		if( this.flGold == undefined )		this.flGold = false;
		if( this.growCoefBonus == undefined )	this.growCoefBonus = 1;

	}
	//
	function update(){
		super.update();
		
		if( this.headCoolDown>0 ) this.headCoolDown -=kaluga.Cs.tmod;
		
		if(this.flTree){
			this.treeTimer += this.treeFallSpeed * this.growCoefBonus * kaluga.Cs.tmod
			var r = this.ray
			this.y = this.treeTimer - r;
			if( this.treeTimer > 2*r ){
				//if(this.flGold)this.game.newBird();
				this.flTree = false
				this.exitGroundMode();
			}
		}else{
			if( this.flGround ){
				// GROUND ROLL
				if(!this.flPanier){
					var vx = Math.abs(this.vitx)
					if(vx>0 || groundId == undefined ){
						//_root.test = (this.vitx/this.circ)*360
						this.vitRoll = (this.vitx/this.circ)*360
						this.vitx *= this.game.groundFrict;
						this.updateGroundId();
						if(vx<0.01)this.vitx=0;
					}
				}
				// CATERPILLAR GENERATOR
				if(this.caterNum==2 && this.game.caterpillarList.length < this.game.caterLimit && random(4000/kaluga.Cs.tmod)<this.weight*6){
					var mc = this.dropCaterpillar();
					mc.setScale(40);
					mc.flGrowing = true;
					this.caterNum++;
					this.game.stat.incVal("bébé vers",1)
				}
				// CHECK OUT
				var m = 2
				if( this.x+this.ray<m || this.x-this.ray>this.map.width-m){
					// LACHE LES CHENILLES
					while(this.caterNum>0){
						this.dropCaterpillar()
					}
					// LACHE LES FOURMIS
					while(this.antList.length>0){
						this.dropLastAnt()
					}
					this.kill();
				}					
			}else{
				// SEEK TZONGRE
				if( !this.game.flEndGame && !this.game.tzongre.flScotched){
					var dist = this.getDist(this.game.tzongre)
					if( dist < this.ray ){
						this.hitTzongre(this.game.tzongre)
					}
				}
				if(!this.flPanier){
					// PANIER CHECK
					if( this.vity>0 and this.parentLink==undefined ){
						var x = this.x - this.game.panier.x;
						var r = this.ray
						var pr = this.game.panier.openRay
						var niv = this.game.panier.y + this.game.panier.openLevel
						if( x-r >= -pr and x+r <= pr and this.y+r>niv and !this.game.flEndGame){
							if((this.y+r)-(this.vity*kaluga.Cs.tmod)<niv){
								this.flScDunk = this.vity > this.dunkPowerLimit;
								this.flScLateral = Math.abs(this.vitx)>Math.abs(this.vity)
								this.game.panier.addFruit(this)
							}
						}
					}
				}
				// SKY
				if(this.y < 0){
					if( !this.flSky and this.game.flFeuillage ) this.game.shootFeuillage(this.x,this.getPower())
					this.flSky = true
				}else{
					if( this.flSky and this.game.flFeuillage ) this.game.shootFeuillage(this.x,this.getPower())
					this.flSky = false;
				}	
				// SOL
				var gy;
				if(this.flPanier){
					gy = this.panier.ray;
				}else{
					gy = this.map.height - this.map.groundLevel;
				}
				if(this.vity>0 && this.y+this.ray> gy){
					this.y = gy-this.ray
					this.flScDirect = false;

					

					if(this.vity>4){
						this.playHitSound();
						if(!this.flPanier)this.hitGround();
						this.vity *= -this.cBoundGround
						this.vitRoll += (this.vitx/this.circ)*100
					}else{
						if(this.parentLink == undefined){
							this.vity = 0;
							this.initGroundMode();
						}
					}
				}
				
				// FLYCOL
				this.checkFlyCollision();
				// ROLLFRICT
				this.vitRoll *= this.game.frict
				// ANT-DECOL
				if(this.antList.length>0){
					this.antMove += random((Math.abs(vitx) + Math.abs(vity))*kaluga.Cs.tmod);
					if(this.antMove>this.antResist){
						this.antMove = random(this.antResist);
						this.dropLastAnt();
					}
				}
				
			}
			// BORD
			var limitLeft,limitRight;
			if(this.flPanier){
				limitLeft =  -this.panier.openRay
				limitRight = this.panier.openRay
			}else{
				limitLeft = 0;
				limitRight = this.map.width;
			}
			if( this.x + this.ray > limitRight && this.flScoreAble ){
				this.x = limitRight - this.ray
				if(this.flPanier and this.y + this.ray > this.panier.openLevel){
					this.panier.vitx += this.vitx*this.weight
				}
				this.vitx *= -this.cBoundSide
				this.flScSide = true;
	
			}		
			if( this.x - this.ray < limitLeft && this.flScoreAble ){
				this.x = limitLeft + this.ray
					if(this.flPanier && this.y + this.ray > this.panier.openLevel){
					this.panier.vitx += this.vitx*this.weight
				}
				this.vitx *= -this.cBoundSide
				this.flScSide = true;
			}
			
			if(this.flPanier){
				// GLURP
				if(this.flGround){
					this.y += this.panier.glurpSpeed * kaluga.Cs.tmod
					if( (this.y-this.ray)*0.9 > this.game.panier.openLevel){
						this.kill();
					}
				}
			}
		}
		// ANT CRUNCH
		if(this.antList.length>0){
			this.updateAspect();
			if(this.crunch/this.weight>1){
				while(this.antList.length>0){
					this.dropLastAnt()
				}
				this.flScoreAble = false;
				this.game.onFruitEatFinish(this);
			}
		}
		// ANT MOVE
		for(var i=0; i<this.antList.length; i++){
			this.antList[i].update();
		}
		// VITROLL
		this.pomme._rotation += this.vitRoll
		this.queue._rotation += this.vitRoll
		//
		

		this.endUpdate()
	}
	//
	function exitGroundMode(){
		super.exitGroundMode();
		this.antMove = 0;
	}
	
	function checkFlyCollision(){
		// BIRD
		var power = this.vity*this.weight
		if( this.vity>0 && power>10 && this.parentLink == undefined ){
			for( var i=0; i<this.game.birdList.length; i++ ){
				var mc = this.game.birdList[i];
				if(mc.mode == 0 && this.hitTest(mc.sub.h)){
					this.playHitSound();
					mc.fruitHit(power)
					this.vity*=-0.6;
					this.flScBird = true;
				}
			}
		}
	};
	
	function hitTzongre(tzongre){
		this.flScHead = true;
		//var cyn = Math.abs(this.vitx) + Math.abs(this.vity)
		//var power = ( this.weight*2 + cyn )
		var power = this.getPower();
		if( this.weight>1 and power/(tzongre.nbDodge+tzongre.bonusDodge) >12 ){
			this.game.tzongre.fruitCrash(this);
		}else{
			var difx = this.x - tzongre.x
			var dify = this.y - tzongre.y
			var a = Math.atan2(dify,difx)
			var cos = Math.cos(a)
			var sin = Math.sin(a)
			
			var p = 2
			tzongre.vitx -= cos * power/p
			tzongre.vity -= sin * power/p
			this.vitx += cos * power/p
			this.vity += sin * power/p
			tzongre.hit(power)
			if( this.headCoolDown<0 ){
				this.game.stat.incVal("Coups-de-tête", 1 );
				this.headCoolDown = 8;
			}
		}
		this.vitRoll = (random(2)*2-1)*power/(this.weight*2)
	}
	
	function addCaterpillar(){
		if(this.caterNum==0)this.game.stat.incVal("Quantité mangée par des vers", this.weight*10 );
		this.holeNum++;
		this.caterNum++;
		var flTryAgain;
		var t = 0;
		do{
			this.attachMovie( "trou", "trou"+this.holeNum, this.holeNum )
			var mc = this["trou"+this.holeNum]
			var dMax = Math.round(this.ray)
			var d = random(dMax-2);	
			mc.t._y = d;
			mc.t._yscale = 100*Math.cos((d/dMax)*1.57);
			mc.t._xscale = 100
			mc._rotation = random(360);
			t++
			flTryAgain = holeNum==2 and mc.hitTest(this["trou1"])  and t<10
			
		}while(flTryAgain)
		
		// DEGRIFFAGE DE LA POMME
		this.flScoreAble = false;
		
		// EVACUATION DES FOURMIS
		while(this.antList.length>0){
			this.dropLastAnt()
		}		
		
	}
	
	function kill(){

		//if(this.flGround)this.game.removeFromGround(this.gList,this.groundListId);
		if(this.flPanier){
			this.mask.removeMovieClip();
			this.panier.removeFruit(this)
		}else{
			this.game.removeFruit(this)
		}
		super.kill();
	}
	
	function hitGround(){
		
		
		
		this.flScBound = true;
		//this.updateGroundId();
		var id = Math.floor(this.x/this.game.groundCaseSize)
		var list = this.game.groundList[id]
		for(var i=0; i<list.length; i++){
			var mc = list[i];
			if(mc.type == "Caterpillar"){
				mc.splash();
			}
	
		}
		var list = new Array();
		for(var i=-1; i<=1; i++)list = list.concat(this.game.groundList[id+i]);
		for(var i=0; i<list.length; i++){
			var mc = list[i];
			//_root.test+="fruitHitGround("+mc+")\n"
			var power = this.getPower()
			if( mc.type == "Squirrel" &&  power > 20 ){
				mc.stunCounter = power*20;
				mc.initMode(3);
			}		
		}
		
		
	}
	
	function addAnt(mc){
		//this.depthNum++;
		mc.fruit = this;
		mc.mode = 1;
		mc.x = 0;
		mc.y = 0;
		this.game.removeFromGround(mc.gList,mc)	 // RETIRE LA FOURMI DU SOL
		var d = this.game.depthList.pop();
		this.attachMovie("spBadsAnt","ant_"+d, 10+d, mc)
		this.antList.push( this["ant_"+d] )
		mc.kill();
	}
	
	function dropLastAnt(){
		//_root.test += "[Fruit] DropLastAnt \n"
		var mcf = this.antList.pop();
		var mc = this.game.newAnt(mcf);
		mc.exitGroundMode();
		mc.mode = 0;
		mc.flFreeze=false;
		//_root.test = "mc.flGround"+mc.flGround+"\n"
		//_root.test = "mc.flPhys"+mc.flPhys+"\n"
		mc.x = this.x;
		mc.y = this.y;
		mc.vitx = this.vitx + (random(200)-100)/100;
		mc.vity = this.vity + -random(200)/100
		mc.vitr	= random((Math.abs(mc.vitx)+Math.abs(mc.vity))*2)
		mcf.removeMovieClip();
	}
	
	function dropCaterpillar(){
		if(this.caterNum>0){
			this.caterNum--;
			var mc = this.game.newCaterpillar();
			mc.x = this.x + random(20)-10
			mc.y = this.map.height - this.map.groundLevel;
			mc.setSens((random(2)*2)-1)
			//_root.test+="dropCaterpillar("+mc+")("+mc.x+","+mc.y+") sens("+mc.sens+")\n="
			return mc;
		}
		
	}
	
	function initGroundMode(){
		super.initGroundMode();
		//_root.test+="initGroundMode() ("+!this.flScoreAble+","+(this.x+this.ray<0)+","+(this.x-this.ray>this.map.width)+")\n"

	}

	function setRay(ray){
		this.ray = ray;
		this.circ = Math.PI*2*this.ray;
	}

	function onLink(parent){
		super.onLink(parent);
		this.flScSquirrel = false;
		this.flScBird = false;
		this.flScNoLink = false;
	}
	
	function unLink(){
		super.unLink();
		this.flScBound = 	false;
		this.flScSide = 	false;
		this.flScHead = 	false;
	}
	
	function recal(){
		var limitLeft = 0;
		var limitRight = this.map.width;
		if( this.x + this.ray > limitRight ){
			this.x = limitRight - this.ray
		}		
		if( this.x - this.ray < limitLeft ){
			this.x = limitLeft + this.ray
		}
	}
	
	function updateAspect(){
		var ratio = this.crunch/this.weight;
		var frame = 1+Math.floor(ratio*this.maxCrunchFrame);
		this.pomme.gotoAndStop(frame);
		this.light.gotoAndStop(frame);	
	}
	
	function playHitSound(){
		// SOUND
		var chan = 100+random(100)
		var r = random(3)
		var link
		if(r==0) link= "sGroundHit0"
		if(r==1) link= "sGroundHit1"
		if(r==2) link= "sGroundHit2"
		this.game.mng.sfx.playSound(link,chan)
		this.game.mng.sfx.setVolume(chan,this.vity*2)
		//	
	}
		
	// DEBUG
	function traceInfo(){
		_root.test += "[Fruit] info :\n"
		_root.test += "flGround("+this.flGround+")\n"
		_root.test += "groundId("+this.groundId+")\n"
		_root.test += "caterNum("+this.caterNum+")\n"
		_root.test += "antList.length("+this.antList.length+")\n"
		_root.test += "this.flScoreAble("+this.flScoreAble+")\n"
		_root.test += "this.linkList.length("+this.linkList.length+")\n"
		_root.test += "this.parentLink("+this.parentLink+")\n"
		
	}
	
	//{
}








