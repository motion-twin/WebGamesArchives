class kaluga.sp.bads.Bird extends kaluga.sp.Bads{//}
	
	// CONSTANTE
	var margin:Number = 40;	
	var eatDist:Number = 40;
	
	// PARAMETRES
	var wait:Number;
	var precision:Number;
	var cDashSpeed:Number;
	var hitPoint:Number;
	
	// VARIABLES
	var flDigere:Boolean;
	var flPrepareDash:Boolean;
	var flEatTzongre:Boolean;
	var miniDashCountDown:Number;
	var sens:Number;
	var waitTimer:Number;
	var stunTimer:Number;
	var digereTimer:Number;
	var wayPoint:Object;
	var mode:Number;
	var target:MovieClip;
	
	//MOVIECLIP
	var sub:MovieClip;
	
	function Bird(){
		this.init();
	}
	
	function init(){
		//_root.test+="[Bird] init()\n"
		this.type = "Bird";
		this.flPrepareDash = false;
		this.flEatTzongre = false;
		this.flDigere = false;
		this.flPhys = false;
		this.sens = 1;
		this.stunTimer = 0;
		super.init();
		this.findTarget();
		this.initFlyMode();
	}
	
	function initDefault(){
		super.initDefault();
		if(this.wait == undefined)		this.wait = 200;
		if(this.precision == undefined)		this.precision = 20;
		if(this.cDashSpeed == undefined)	this.cDashSpeed = 0.6;
		if(this.hitPoint == undefined)		this.hitPoint = 40;
	}
	
	function update(){
		super.update()

		if( this.target._visible != true){
			this.findTarget();
		}
		switch(this.mode){
			case 0: // ------------------------ NORMAL ----------------------------- //
				//_root.test=waitTimer+"\n"
				
				if(this.stunTimer>0){
					this.stunTimer -= kaluga.Cs.tmod;
					if(this.stunTimer<0){
						this.sub.h.gotoAndStop("normal");
					}
				}else{
					if(this.target!=undefined and !this.flDigere){
						this.waitTimer -= kaluga.Cs.tmod;
						if( this.waitTimer < this.precision && this.wayPoint == undefined ){
							if(this.target.x>0 and this.target.x<this.map.width){
								this.wayPoint = { x:this.target.x, y:this.target.y }
							}else{
								this.findTarget();
							}
						}
						if(!this.flPrepareDash && this.waitTimer < 10 ){
							this.prepareDash();
						}				
						if( this.waitTimer < 0 ){
							this.initDashMode();
							break;
						}
					}
				}
				// DIGESTION
				if(this.flDigere){
					this.digereTimer-=kaluga.Cs.tmod
					if(this.digereTimer<0){
						this.flDigere = false;
						this.sub.h.h.bec.gotoAndPlay("Caterpillar");
						this.powerUp();
						
					}
				}
				
				// BOUGE
				this.vitx +=  kaluga.Cs.tmod * (random(200)-100)/100
				this.vity +=  kaluga.Cs.tmod * (random(200)-100)/100
				this.vitx *= this.game.frict;
				this.vity *= this.game.frict;				
				this.x += this.vitx * kaluga.Cs.tmod;
				this.y += this.vity * kaluga.Cs.tmod;
				
				// SOL
				var gy = this.map.height-this.map.groundLevel;
				if(this.y+this.margin > gy){
					this.y = gy-this.margin;
				}
				// SIDE
				var limitLeft = this.margin
				var limitRight = this.map.width-this.margin
				if(this.x < limitLeft){
					this.vitx = 0;
					this.x = limitLeft
				}
				// SKY
				if(this.y < this.margin){
					this.vity += kaluga.Cs.tmod;
				}				
				if(this.x > limitRight){
					this.vitx = 0;
					this.x = limitRight
				}
				
				
				if(this.stunTimer<=0){
					// VERIFIE LE SENS
					if(this.sens*(this.x - this.target.x)>0){
						this.swap();
					}
					
					// FIXE LA CIBLE
					var difx = this.target.x - this.x;
					var dify = this.target.y - this.y;
					var a = Math.atan2(dify,difx*this.sens);
					var rot = a/(Math.PI/180);
					this._rotation = rot*0.2*this.sens;
					this.sub.h.h._rotation = rot*0.6;
					this.sub.h.h._y = Math.min(Math.max(-6,dify/10),6);
					
					// CHECK EAT
					if(!this.game.flEndGame and !this.flDigere){
						var difx = this.target.x - (this.x + this.sub.h._x);
						var dify = this.target.y - (this.y + this.sub.h._y);
						var dist = Math.abs(difx)+Math.abs(dify)
						this.miniDashCountDown -= kaluga.Cs.tmod
						if(dist<this.eatDist*2 and this.miniDashCountDown<0){
							//_root.test+="minidash!\n"
							this.miniDashCountDown = 20
							this.vitx += difx/6
							this.vity += dify/6
							this.sub.h.h.bec.gotoAndPlay("open")
							//this.eat(this.target);
						}
						if(dist<this.eatDist){
							this.eat(this.target);
						}
					}
					//SOUND
					if(!random(100/kaluga.Cs.tmod)){
						var link
						switch(random(2)){
							case 0:
								link = "sCrow0"
								break;
							case 1:
								link = "sCrow1"
								break;						
						}
						
						this.game.mng.sfx.play(link)
						this.sub.h.h.bec.gotoAndPlay("open")
					}					
					
				}
				

				

				break;
				
			case 1: // ------------------------ DASH ----------------------------- //
				
				// BOUGE
				this.x = this.x * this.cDashSpeed + this.wayPoint.x * (1-this.cDashSpeed)
				this.y = this.y * this.cDashSpeed + this.wayPoint.y * (1-this.cDashSpeed)
				
				// CHECK EAT
				if(!this.game.flEndGame){
					if( this.getDist(this.target) < 40 ){
						//_root.test+="dash Hit\n"
						this.initFlyMode();
						this.eat(this.target)
					}
				}
				
				// CHECK END
				if( Math.abs(this.x-this.wayPoint.x)+Math.abs(this.y-this.wayPoint.y) < 36 ){

					this.initFlyMode();
					if(this.target.type=="Caterpillar" && this.target.flGround){
						this.eat(this.target);
					}
					this.findTarget();

				
				}

				break;
			case 2: // ------------------------ STASE ----------------------------- //
				this.waitTimer -= kaluga.Cs.tmod
				if( this.waitTimer < 0 ){
					this.exitStaseMode();
				}				
				break;
				
			case 3: // ------------------------ LEAVE ----------------------------- //
				//_root.test="this.y("+this.y+") this.game.flEndGame("+this.game.flEndGame+") this.flFreeze("+this.flFreeze+")\n"
				// BOUGE
				this.vitx += kaluga.Cs.tmod * (random(200)-100)/100
				this.vity -= kaluga.Cs.tmod * 0.3
				this.vitx *= this.game.frict;
				this.vity *= this.game.frict;				
				this.x += this.vitx * kaluga.Cs.tmod;
				this.y += this.vity * kaluga.Cs.tmod;

				// SIDE
				var limitLeft = this.margin
				var limitRight = this.map.width-this.margin
				if(this.x < limitLeft){
					this.vitx = 0;
					this.x = limitLeft
				}
				// SOL
				var gy = this.map.height-this.map.groundLevel;
				if(this.y+this.margin > gy){
					this.y = gy-this.margin;
				}				
				// CHECKLEAVE
				if(this.y < -100){
					if(this.flEatTzongre)this.game.onTzDeath();
					this.kill();
				}
				
				
				break;				
		}
		// TEST
		if(!random(Math.round(400/kaluga.Cs.tmod)))this.dropPlume();

		this.endUpdate();
	}
	
	function initStaseMode(){
		_root.test+="initStaseMode()\n"
		this.mode = 2;
		this.wait *= 0.9;
		this.waitTimer = this.wait*4 +random(this.wait);
		this._visible = false;
	}
	
	function exitStaseMode(){
		_root.test+="exitStaseMode()\n"
		this.initFlyMode();
		this.findTarget();
		this._visible = true;
	}
	
	function initFlyMode(nextMode){
		if( nextMode == undefined ) nextMode = 0;
		//_root.test+="[Bird] initFlyMode()\n"
		this.gotoAndStop("fly")
		this.waitTimer = this.wait + random(this.wait/4);
		this.mode = nextMode;
		this._rotation = 0;
		this.miniDashCountDown = 10;
		this.flPrepareDash=false;
		delete this.wayPoint;
	
	}
	
	function initDashMode(){
		//_root.test+="[Bird] initDashMode()\n"
		this.gotoAndStop("dash")
		this.mode = 1;
		//
		this.sens = 1
		this._xscale = 100
		//
		var difx = this.wayPoint.x - this.x
		var dify = this.wayPoint.y - this.y
		var a =Math.atan2(dify,difx)
		this._rotation = a/(Math.PI/180)
		// PLUME
		var max = 2+random(2)
		for(var i=0; i<max; i++){
			var mc = this.dropPlume();
			mc.vity = -(2+random(4))
		}
		//
		this.vitx = 0;
		this.vity = 0;
		//
		
		
	}
	
	function findTarget(){
		delete this.target;
		var list = this.game.caterpillarList;
		for(var i=0; i<list.length; i++){
			var cater = list[i]
			if(cater.x>0 and cater.x<this.map.width){
				this.target = cater;
				return
			}
		}
		
		if(this.game.tzongre._visible){
			this.target = this.game.tzongre;
		}
		
		/*
		if(random(this.game.level)<this.game.caterpillarList.length){

			this.target = this.game.caterpillarList[random(this.game.caterpillarList.length)]
		}else if(this.game.tzongre._visible){
			// TODO MULTI-TZONGRE

			this.target = this.game.tzongre;
		}
		*/
		//this.target = this.game.caterpillarList[random(this.game.caterpillarList.length)]
		//this.target = this.game.tzongre;
	}

	function swap(){
		//_root.test+="[Bird] swap()\n"
		this.sub.memoryFrame = this.sub._currentframe;
		this.sub.gotoAndPlay("swap")
		this.sens = -this.sens
		this._xscale = this.sens*100
	}

	function prepareDash(){
		this.flPrepareDash=true;
		var difx = this.wayPoint.x - this.x
		var dify = this.wayPoint.y - this.y
		var a =Math.atan2(dify,difx)
		this.vitx -= Math.cos(a)*10		
		this.vity -= Math.sin(a)*10		
	}

	function eat(mc){
		//_root.test += "[Bird] eat("+mc.type+")\n"
		this.sub.h.h.bec.gotoAndStop(mc.type)
		if(mc.type == "Tzongre"){
			var titleList = [
				"Miam!",
				"Crunch!",
				"Glurps!",
				"Scrounch!"
			]
			
			var msgList = [
				mc.name+" a été avalé par le corbeau.",
				mc.name+" n'a pas réussi a esquiver les attaques du corbeau.",
				"Le corbeau a avalé "+mc.name+" en une seule bouchée",
				"Les assauts répétés du corbeau ont eu raison de notre pauvre "+mc.name
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
			this.game.endPanelStart.push(obj);
			//_root.test+="mc.id("+mc.id+")\n"
			this.sub.h.h.bec.gotoAndStop(20+mc.id)
			mc.kill();
			this.flEatTzongre = true;
			this.initFlyMode(3);
			
			
		}else if(mc.type == "Caterpillar"){
			this.game.stat.incVal("Vers mangés par le corbeau",1);
			this.flDigere = true;
			this.digereTimer = 200;
			mc.kill();
			
		};
	}

	function powerUp(){
		this.sub.h.attachMovie("powerUp","powerUp",2)
		this.sub.h.powerUp._x = 9
		this.hitPoint += 60;
	}

	function fruitHit(power){
		//_root.test+="[Bird] fruitHit("+power+") !\n"
		this.vity += power;
		this.stunTimer += power*16;
		this.sub.h.gotoAndStop("stun");
		this.hitPoint -= power
		if(this.hitPoint<0){
			if(this.mode!=3)this.game.stat.incVal("Corbeaux vaincus",1);
			this.mode = 3;
		}
		
		// crache le vers
		if(this.flDigere){
			this.game.stat.incVal("vers sauvés des corbeaux",1);
			this.sub.h.h.bec.gotoAndPlay("spit");
			this.flDigere = false;
			var mc = this.game.newCaterpillar();
			mc.x = this.x + this.sub.h._x + 4
			mc.y = this.y + this.sub.h._y + 2
			mc.exitGroundMode();
		}
		
		this.game.stat.incVal("Coups de pomme sur les corbeaux",1);
		
	}
	
	// FX
	function dropPlume(){
		this.game.stat.incVal("Plumes perdues par les corbeaux",1);
		var mc = this.game.newFX("plume");
		this.game.particuleList.push(mc);
		var sens = random(2)*2-1
		mc.gotoAndPlay(random(40)+1)
		mc.vitx = this.vitx + random(10)-5;
		mc.vity = this.vity
		mc.x = this.x - mc.p._x*sens;
		mc.y = this.y;
		mc._xscale = sens*100
		mc.p.stop();
		
		//mc._xscale = 50 + random(150)
		//mc._yscale = 50 + random(150)
		mc.time = 60+random(20);
		mc.mode = 0;
		//_root.test+="[Bird] drop plume("+mc+")\n"
		return mc;
	}
	
	//
	function kill(){
		//_root.test+="[Bird]kill()"
		this.game.removeFromList(this,"birdList")
		super.kill();
	}
	
	
//{	
}











































