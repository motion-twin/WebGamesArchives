class kaluga.sp.phys.Tzongre extends kaluga.sp.Phys{//}
	
	// CONSTANTES
	var dp_line:Number = 10;
	//
	var cBoundSide:Number = 0.8;
	var margin:Number = 10;
	var pitchAccel:Number = 1
	var eyeRay:Number = 3.4
	var groundResist:Number = 8
	
	// PARAMETERS
	var id:Number;
	var name:String;	
	var cligneRand:Number;

	// VARIABLES
	var flSky:Boolean;
	var flLauncher:Boolean;
	var flDashBottom:Boolean;
	var flDashUp:Boolean;
	var flScotched:Boolean;
	var flReleaseShoot:Boolean;
	var flLift:Boolean;
	var flSuper:Boolean;
	//var flWeak:Boolean;
	
	//var dashBottomCount:Number;
	var dashUpCount:Number;
	var thrustCoef:Number;
	//var skinNum:Number;
	var pitch:Number;
	var coolDownShoot:Number;
	var cBoost:Number;
	var lNum:Number;
	var superTimer:Number;
	var bzzz:Number
	
	var key:Object;
		
		// CARACS
		var nbPower:Number;
		var nbBoost:Number;
		var nbBoostFrict:Number;
		var nbDodge:Number;
		var nbFilMax:Number;
		
		// CONTROLE
		var nbThrust:Number;
		var nbFrict:Number;
		var nbTurn:Number;
		var nbFall:Number;
		var nbTurnMalus:Number;
		var nbDashUp:Number;
		var nbDashBottom:Number;
		
		// FIL
		var fil:Object;
		var nbMulti:Number;
		var nbCombo:Number;
	
		// BONUS
		var bonusMulti:Number;
		var bonusCombo:Number;
		var bonusPower:Number;
		var bonusDodge:Number;
		var bonusFilMax:Number;
		
	var target:Object;
	var bonusMemory:Object;
	var box:Object;
	
	// MOVIECLIPS
	var fx:MovieClip;
	var a1:MovieClip;
	var a2:MovieClip;
	var yeux:MovieClip;
	var corps:MovieClip;
	var pattes:MovieClip;
	var tz:MovieClip;
	
	
	function Tzongre(){
		this.init();
	}
	
	function init(){
		//_root.test+="[Tzongre] init\n"
		this.type = "Tzongre"
		this.dashUpCount = 0;
		//
		this.flSky = false;
		this.flScotched = false;
		this.flReleaseShoot = false;
		this.flLift = false;
		this.flSuper = false;
		//this.flWeak = false;
		this.coolDownShoot = 0
		this.bonusMulti = 0
		this.bonusCombo = 0
		this.bonusPower = 0
		this.bonusDodge = 0
		this.bonusFilMax = 0
		this.bzzz =0;
		this.lNum = 0;
		this.pitch = 0;
		this.cBoost = 1;
		this.searchTimer = 0;
		this.thrustCoef = 1 / Math.pow(this.nbFrict,8);
		super.init();
		this.setSkin()
		this.updateRange();
		this.updateTake();
		//
		if(this.box==undefined)this.setBox();
		//
		this.game.mng.sfx.stop(10)
		this.game.mng.sfx.loop("sFly",10)
		this.game.mng.sfx.setVolume(10,0)
		//
		this.freeze();		
		
		//_root.test+="thrustCoef("+this.thrustCoef+")\n"
		
	}
	
	function initDefault(){
		if(this.weight == undefined)		this.weight = 0.3;
		if(this.nbTake == undefined)		this.nbTake = 120;
		//
		super.initDefault();
		//
		//if( this.skinNum == undefined ) this.skinNum = random(3)+1;
		//
		if(this.nbThrust == undefined)		this.nbThrust = 0.9;
		if(this.nbTurn == undefined)		this.nbTurn = 2.4;
		if(this.nbFall == undefined)		this.nbFall = 0.8;
		
		
		if(this.flLauncher == undefined)	this.flLauncher = false;
		//if(this.nbPower == undefined)		this.nbPower = 2;
		//if(this.nbBoost == undefined)		this.nbPower = 0.02;
		
		
		if(this.nbTurnMalus == undefined)	this.nbTurnMalus = 0.8;
		if(this.nbDashUp == undefined)		this.nbDashUp = 20;
		if(this.nbDashBottom == undefined)	this.nbDashBottom = 24;
		if(this.nbMulti == undefined)		this.nbMulti = 0;
		if(this.nbCombo == undefined)		this.nbCombo = 0;
		if(this.nbDodge == undefined)		this.nbDodge = 1;		//1
		if(this.nbFilMax == undefined)		this.nbFilMax = 200;		//1
		if(this.key == undefined){
			this.key = {
				left:this.game.mng.pref.$key[1],
				right:this.game.mng.pref.$key[2],
				up:this.game.mng.pref.$key[0],
				down:this.game.mng.pref.$key[3],
				shoot:this.game.mng.pref.$key[4]
			}
		}
		if(this.fil == undefined){
			this.fil = {
				tensionMax:60
			}
		}		
	}
	
	function control(){
		var sensible = 3
		// DASH
		
		if(this.flDashUp) this.dashUpCount -= kaluga.Cs.tmod
		/*
		if(this.flDashBottom) this.dashBottomCount -= kaluga.Cs.tmod;
		*/
		// TOURNER
		if(Key.isDown(this.key.left)){
			this._rotation -= this.nbTurn * kaluga.Cs.tmod
			this.power = Math.max(0,this.power-(this.nbTurnMalus*kaluga.Cs.tmod))
		}
		if(Key.isDown(this.key.right)){
			this._rotation += this.nbTurn * kaluga.Cs.tmod
			this.power = Math.max(0,this.power-(this.nbTurnMalus*kaluga.Cs.tmod))
		}
		
		// ACCELERER
		if(Key.isDown(this.key.up)){
						
			var bonus = 0
			
			/*
			if(this.dashUpCount>0 and this.flDashUp){
				bonus = this.nbDashUp;
				_root.test+="[Tzongre] dashUp\n"
			}
			*/
			this.dashUpCount= sensible
			this.flDashUp = false;
			
			this.thrust(bonus);
			this.pitch += this.pitchAccel;
			//this.power += this.nbPower * kaluga.Cs.tmod
			var c = Math.pow(this.cBoost,kaluga.Cs.tmod)
			this.cBoost *= this.nbBoostFrict;
			this.updatePower();
			
			// SOUND
			this.bzzz = Math.min( this.bzzz+0.1*kaluga.Cs.tmod, 1 )
			
		}else{
			if(!this.flDashUp){
				this.flDashUp = true;
				this.cBoost = 1
				this.updatePower();
				this.a1.gotoAndStop(1);
				this.a2.gotoAndStop(1);
			}
			this.bzzz = Math.max(this.bzzz-0.1*kaluga.Cs.tmod,0)
		}
		this.game.mng.sfx.setVolume(10,2+this.bzzz*8)
				
		
		// TOMBER
		if(Key.isDown(this.key.down)){
			this.vity += this.nbFall * kaluga.Cs.tmod * (0.5+this.thrustCoef*0.5) ;
			//this.pitch += this.pitchAccel;	// A CALCULER
			/*
			if(this.dashBottomCount>0 and this.flDashBottom){
				this.vity += this.nbDashBottom * kaluga.Cs.tmod;
			}
			this.dashBottomCount= sensible;
			this.flDashBottom = false;
			*/
		}else{
			/*this.flDashBottom = true;*/
		}
		
		// FIL
		this.coolDownShoot -= kaluga.Cs.tmod
		if(Key.isDown(this.key.shoot)){
			//this.searchTimer += kaluga.Cs.tmod;
			if(this.coolDownShoot<=0 && this.game.flLinkActive ){
				this.search(this.nbCombo+this.bonusCombo);
			}
			if(this.flLift){
				this.coolDownShoot = 6;
				this.release();
			}
			this.flReleaseShoot = false;
		}else{
			if(!this.flReleaseShoot)this.activeLink();
			this.flReleaseShoot = true;
			this.searchTimer = 0;
		}
	}
	//
	function update(){
		
		//_root.test+="("+this.x+","+this.y+")\n"
		if(this.flScotched){
			this.endUpdate();
			return;
		}
		//if(!this.flScotched)this.control();
		this.control();
		super.update();

		// SKY
		if(this.y < this.box.top){
			if( !this.flSky && this.game.flFeuillage ) this.game.shootFeuillage(this.x,this.getPower())
			this.flSky = true
			if(this.vity < 0)this.vity *= 0.5;
			if(this.y < this.box.top-20){
				this.vity=0;
				this.y = this.box.top-20;
			}
		}else{
			if( this.flSky && this.game.flFeuillage ) this.game.shootFeuillage(this.x,this.getPower())
			this.flSky = false;
		}	
		
		// BORD 
		if( this.x > this.box.right ){
			this.x = this.box.right
			this.vitx *= -this.cBoundSide
		}		
		if( this.x < this.box.left ){
			this.x = this.box.left
			this.vitx *= -this.cBoundSide
		}		
		
		// SOL

		if(this.y > this.box.bottom){
			this.y = this.box.bottom;
			if(this.vity+Math.abs(this.vitx)/2<this.groundResist*(this.nbDodge+this.bonusDodge)){
				this.vity*=-0.6;
			}else{
				this.y += this.margin;
				
				this.groundCrash()
				
			}
		}

		// LINK
		if(this.flLift)this.updateLink(this.fil.tensionMax, new Array());

		// TENSION CHECK 
		if(!this.flReleaseShoot){
			for( var i=0; i<this.linkList.length; i++ ){
				var link = this.linkList[i];
				var difx = this.x - link.x
				var dify = this.y - link.y
				var dist = Math.sqrt((difx*difx)+(dify*dify))
				//_root.test ="dist = "+dist+" ("+this.nbFilMax+")\n"
				if(dist>(this.nbFilMax+this.bonusFilMax)){
					//_root.test ="remove\n"
					this.removeLink(link);
				}
			}			
		}
		
		// PITCH
		this.pitch *= this.game.groundFrict;
		this.yeux._y  = -this.pitch/2
		this.corps._y = this.pitch/2
		this.corps._yscale = 100+this.pitch*2
		this.pattes._y = this.pitch/2
		this.pattes._yscale = this.pitch*20
		// LOOK
		this.updateLook();
		
		// CHECK PAPILLONS
		for( var i=0; i<this.game.butterflyList.length; i++ ){
			var mc:kaluga.sp.Butterfly = this.game.butterflyList[i]
			var difx = mc.x - this.x
			var dify = mc.y - this.y
			if( Math.abs(difx)+Math.abs(dify)<32){
				this.catchButterFly(mc);
			}
		}
		
		// SUPER MODE
		if( this.flSuper ){
			this.superTimer -= kaluga.Cs.tmod
			if( this.superTimer>0 ){
				if( random(kaluga.Cs.tmod*this.superTimer)>20 ){
					var d = (this.lNum++)%100;
					this.fx.attachMovie("superLine","line"+d,this.dp_line+d);
					var mc = this.fx["line"+d];
					mc._alpha = 50;
					mc._rotation = random(360);
				}
			}else{
				this.bonusMulti = this.bonusMemory.multi;
				this.bonusCombo = this.bonusMemory.combo;
				this.bonusPower = this.bonusMemory.power;	
				this.bonusDodge	= this.bonusMemory.dodge;
				this.updateRange();
				this.flSuper = false;
			}
		}
		
		// TZONGRE SPECIAL FRICT
		var frict = Math.pow( this.nbFrict, kaluga.Cs.tmod )
		this.vitx *= frict;
		this.vity *= frict;
		
		
		this.endUpdate()		
	}
	//
	function updateLook(){
		if(this.target==undefined || this.target._visible != true ){
			if(this.linkList.length>0){
				this.target = this.linkList[0];
				return;
			}
			this.yeux.p1.x = -2.5;
			this.yeux.p1.y = 1;
			this.yeux.p2.x = 2.5;
			this.yeux.p2.y = 1;
		}else{
			var difx = this.target.x - this.x
			var dify = this.target.y - this.y
			var a = Math.atan2(dify,difx) - this._rotation * ( Math.PI/180 )
			
			var cos = Math.cos(a)
			var sin = Math.sin(a)
			
			var r = this.eyeRay-1;
			
			this.yeux.p1.x = cos * r - this.eyeRay;
			this.yeux.p1.y = sin * r;
			
			this.yeux.p2.x = cos * r + this.eyeRay;
			this.yeux.p2.y = sin * r;
			
		}
	
		//
		var c = Math.pow(0.8,kaluga.Cs.tmod)
		this.yeux.p1._x = this.yeux.p1._x*c + this.yeux.p1.x*(1-c)
		this.yeux.p1._y = this.yeux.p1._y*c + this.yeux.p1.y*(1-c)
		this.yeux.p2._x = this.yeux.p2._x*c + this.yeux.p2.x*(1-c)
		this.yeux.p2._y = this.yeux.p2._y*c + this.yeux.p2.y*(1-c)
		//
		if(!random(this.cligneRand/kaluga.Cs.tmod)){	//200
			this.yeux.play()//gotoAndPlay((this.id+1)*10);
		}
		
		
	}
	
	function thrust(bonus){
		var a = (this._rotation-90)*(Math.PI/180);
		
		var vit = (this.nbThrust+bonus)*kaluga.Cs.tmod*this.thrustCoef
		
		
		vitx+= Math.cos(a)*vit;
		vity+= Math.sin(a)*vit;
		// AGITE LES AILES
		this.a1.nextFrame();
		this.a2.nextFrame();
		//sFly.setVolume(20);	A IMPLEMENTER
		//liftCoef *= frict2;	A IMPLEMENTER
	}
	
	function release(){
		//
		this.game.onTzRelease(this);
		//
		if(this.linkList[0] == this.target)delete this.target;
		this.flLift = false;
		this.unLink();
		//
		
	}
	
	function activeLink(){
		if(this.linkList.length>0){
			this.flLift = true;
		}
	}
	
	function scotch(mc){
		this.game.mng.sfx.stopSound("sFly",10)
		this.game.onTzDeath();
		this.flScotched=  true;
		this.vitx = 0;
		this.vity = 0;
		if(this.linkList.length>0)this.release();
		if( mc != undefined ){
			//_root.test+="[Tzongre] scotch to mc("+mc+") this("+this+")\n"
			var x = this.x - mc.x
			var y = this.y - mc.y
			var point = {x:x, y:y};
			//_root.test+="point("+point.x+","+point.y+")\n"
			mc.localToGlobal(point);
			//_root.test+="point("+point.x+","+point.y+")\n"
			mc.pomme.globalToLocal(point);
			//_root.test+="point("+point.x+","+point.y+")\n"
			
			mc.pomme.attachMovie("spPhysTzongre","tzongre",120,this);
			mc.pomme.tzongre._xscale = 100/(mc.pomme._xscale/100)
			mc.pomme.tzongre._yscale = mc.pomme.tzongre._xscale
			mc.pomme.tzongre.scotch();
			mc.pomme.tzongre._x = point.x//this.x - mc.x 
			mc.pomme.tzongre._y = point.y//this.y - mc.y
			mc.pomme.tzongre._rotation = this._rotation
			this._visible = false;
		}else{
			this.gotoAndStop("scotched")
		}
	}
	
	function kill(){
		_root.test+="[Tzongre] kill()\n"
		this.game.mng.sfx.stopSound("sFly",10)
		this.release();
		super.kill();
	}
	
	function hit(){
		this.yeux.play();
	}
	
	function setSkin(){
		this.corps.gotoAndStop(this.id+1)
		this.yeux.gotoAndStop((this.id+1)*10);
		this.yeux.p1.gotoAndStop(this.id+1)
		this.yeux.p2.gotoAndStop(this.id+1)
		this.pattes.gotoAndStop(this.id+1)
		if( this.id == 2 ){		// AILES DE NALIKA
			this.a1._xscale = 180
			this.a2._xscale = 180
		}else if(this.id != 3){
			this.a1._xscale = 120
			this.a2._xscale = 120		
		}	
	}
	
	function catchButterFly(mc){
		//
		switch(mc.id){
			case 0:	// MULTI
				this.nbMulti++
				this.game.scroller.put("Multi up!","("+this.nbMulti+")");
				this.updateRange();
				break;
			case 1:	//COMBO
				this.nbCombo++
				this.game.scroller.put("Chain up!","("+this.nbCombo+")");
				break;
			case 2:	// POWER
				this.bonusPower += 2
				this.game.scroller.put("Power up!","("+(this.bonusPower/2)+")");
				break;
			case 3:	// DODGE
				this.bonusDodge += 1
				this.game.scroller.put("Armor up!","("+this.bonusDodge+")");
				break;
			case 4:	// SUPER
				this.flSuper = true;
				this.bonusMemory = {
					multi:this.bonusMulti,
					combo:this.bonusCombo,
					power:this.bonusPower,	
					dodge:this.bonusDodge
				}
				this.bonusMulti = 5;
				this.bonusCombo = 5;
				this.bonusPower = 10;	
				this.bonusDodge	= 10;
				this.superTimer = 500;
				this.updateRange();
				break;
			case 5:	// JUMP IN
				this.game.fruitJumpIn();
				break;
			case 6: // JUMP OUT
				this.game.fruitJumpOut();
				break;
			case 7:	// ABONDANCE
				for(var i=0; i<10; i++){
					var fruit = this.game.genTreeFruit();
					fruit.growCoefBonus = 6;
				};
				break;
		}
		
		
		
		
		// PARTICULE
		//_root.test+="particule("+this.game.mng.pref.$param[2]+")\n"
		if(this.game.mng.pref.$param[2]){
			for(var i=0; i<10/kaluga.Cs.tmod; i++){
				var p = mc.dropPaillette();
				p.vitx = 2*(random(200)-100)/100
				p.vity = 2*(random(200)-100)/100
			}
		}
		// SOUNDS
		this.game.mng.sfx.play("sRadian")
		
		mc.kill();
		
	}
	
	function updatePower(){
		this.power = this.nbPower + this.nbBoost*(1-this.cBoost) + this.bonusPower
		//_root.test = this.power+"\n"
	}
	
	function updateRange(){
		this.range = this.nbMulti+this.bonusMulti+1
	}
	
	function updateTake(){
		this.nbTake = (this.nbFilMax+this.bonusFilMax)*0.7
	}	
	
	function groundCrash(){
		var titleList = [
			"Splorch!",
			"Sbleurch!",
			"Ploush!",
			"Skonk!"
		]
		
		var msgList = [
			this.name+" s'est ecrasé(e) sur le sol...",
			"La gravité a rattrapé "+this.name,
			this.name+" a joué trop près du sol..."
		]
		var obj = {
			label:"basic",
			list:[
				{
					type:"msg",
					title:titleList[random(titleList.length)],
					msg:msgList[random(msgList.length)]
				}
			
			]
		}
		this.game.endPanelStart.push(obj)
		this.flGround = true;
		this.scotch();
	}
	
	function fruitCrash(fruit){
		var titleList = [
			"Plourch!",
			"Blaarch!",
			"Sponk!",
			"Paf!"
		]
		
		var msgList = [
			this.name+" a percuté la pomme un peu trop fort.",
			this.name+" n'a pas réussi à éviter la pomme.",
			"La pomme a percuté de plein fouet notre pauvre "+this.name+", paix a son  âme...",
			"Malgré de bons reflexes, "+this.name+" n'a pas pu esquiver la pomme à temps.",
			"La pomme dans un élan meurtrier a emporté "+this.name+" dans sa chute.",
			"La pomme lancée a grande vitesse, a ecrasé "+this.name+" qui passait par là."
		]
		var obj = {
			label:"basic",
			list:[
				{
					type:"msg",
					title:titleList[random(titleList.length)],
					msg:msgList[random(msgList.length)]
				}
			
			]
		}
		this.game.endPanelStart.push(obj)
		this.scotch(fruit)
	}
	
	function setBox(box){
		if(box==undefined){
			box = {
				left:0,
				right:this.map.width,
				top:0,
				bottom:this.map.height-this.map.groundLevel
			};
		};
		box.left +=	this.margin;
		box.right -=	this.margin;
		box.top +=	this.margin;
		box.bottom -=	this.margin;
		this.box = box;
		
		
		// new Object();
		
	}

	function linkTo(link){
		super.linkTo(link);
		this.game.onTzLink(this);
	}
	
	function unFreeze(){
		this.a1.a.play();
		this.a2.a.play();
	}

	function freeze(){
		this.a1.a.stop();
		this.a2.a.stop();
	}
		
	/*
	function disableLink(){
		_root.test+="disableLink()\n"
		if(!this.flWeak){
			this.flWeak = true;
			if(this.linkList.length>0)this.release();
		}
	}
	*/
	
	//{	
}














































