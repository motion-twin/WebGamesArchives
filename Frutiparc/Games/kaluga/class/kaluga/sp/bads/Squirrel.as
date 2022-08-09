class kaluga.sp.bads.Squirrel extends kaluga.sp.Bads{//}
	
	// CONSTANTE
	var speed:Number = 10;
	var baseSpeed:Number = 15;
	//var length:Number = 31;
	//var posListMaxLength:Number = 20
	var margin:Number = 120;
	var maxJumpDist:Number = 300;
	// PARAMETRES

	// VARIABLES
	var flJump:Boolean;
	var flPlante:Boolean;
	var mode:Number;
	var sens:Number;
	var compt:Number;
	var status:Number;
	var stunCounter:Number;
	var posList:Array;
	
	var anim:kaluga.FrameAnimManager;
	
	// REFERENCE
	var focus:Object;
	var jumpTarget:MovieClip//sp.Phys;

	// MOVIECLIP
	var h:MovieClip;
	var head:MovieClip;
	var body:MovieClip;

	function Squirrel(){
		//_root.test+="---\n"
		this.init();
	}
	
	function init(){
		//_root.test+="[Squirrel] init()\n"
		this.type = "Squirrel";
		this.anim  = new kaluga.FrameAnimManager( { start:24, end:40, root:this } );
		this.flJump = false;
		super.init();
		if( this.mode == undefined ){
			this.initMode(0);
		}else{
			this.initMode(this.mode);
			
		}
	}
	
	function initDefault(){
		if( this.flPhys == undefined ) this.flPhys = false;
		if( this.weight == undefined ) this.weight = 0.5
		if( this.adr == undefined ) this.adr = 2;
		super.initDefault();
		
	}
	//
	function update(){
		super.update()
		switch(this.mode){
			case 0: //{---------------- NORMAL --------------
				// ANIM
				this.anim.update(this.game.debugCoef+(this.speed/this.baseSpeed));
				// MOVE
				this.x += this.speed * this.sens * kaluga.Cs.tmod * (this.game.debugCoef+1);
				this.updateGroundId();
				// CHECK FOR SENS
				if(this.sens == 1 && this.x>this.map.width+this.margin ){
					this.setSens(-1);
				};
				if(this.sens == -1 && this.x<-this.margin){
					this.setSens(1);
				};
				// CHECK FLYING FRUIT or BUTTERLFY
				var list = this.game.tzongre.linkList.concat(this.game.butterflyList)
				for(var i=0; i<list.length; i++){
					var mc = list[i]
					if( mc.type=="Fruit" or mc.type=="Butterfly" /*&& mc.weight>0*/ ){
						var difx = mc.x - this.x
						var dify = mc.y - this.y
						if( difx*this.sens > 0 ){
							var dist = Math.sqrt((difx*difx)+(dify*dify));
							if( dist>50 and dist < this.maxJumpDist){
								var a = Math.atan2(dify,difx)
								var jumpHighCoef = 0.8
								var jumpPower = 24*(dist/300)
								a = a*jumpHighCoef - (Math.PI/2)*(1-jumpHighCoef)
								this.vitx = Math.cos(a)*jumpPower;
								this.vity = Math.sin(a)*jumpPower;
								//
								this.flJump = true;
								this.jumpTarget = mc;
								//this.exitGroundMode();
								this.initMode(1);
								this.gotoAndStop("jump")
							}
						}
					}
				}
				break;//}
			case 1: //{---------------- PHYS --------------

				// GROUND
				var gy = this.map.height - this.map.groundLevel;
				if(this.y> gy){
					this.y = gy
					this.landing()
					break;
				}
				if(!this.flJump){
					// MOVE HEAD BODY TAIL
					var a = Math.atan2(this.vity-8,-this.vitx*this.sens)
					var a1 = this.body._rotation-90
					var a2 = (a/(Math.PI/180))
					var dif = a1-a2
					while(dif>180)dif-=360;
					while(dif<-180)dif+=360;
					this.body._rotation -= dif/4;
					this.head._rotation += dif/2;
					this.head._rotation /= 1.5;
					this.head.head.gotoAndStop(Math.max(1,Math.round(-this.vity*5)))
					var mc = this.body;
					while(mc._visible){
						mc = mc.q;
						mc._rotation = dif/1.5;
					};
					for(var i=1; i<=4; i++){
						mc = this.body["p"+i]
						mc._rotation = dif;
					};
				}else{
					// MOVE BODY
					var a = Math.atan2(this.vity,this.vitx)
					this._rotation = a/(Math.PI/180) +180*(1-(this.sens+1)/2)
					
					// CHECK FRUIT OR BUTTERFLY COLLISION
					if( this.jumpTarget != undefined ){
						if(this.hitTest(this.jumpTarget)){
							this.hitTarget();
						};
					};
				}
				
				if( this.parentLink!= undefined && !random(70/kaluga.Cs.tmod) ){
					this.vitx += (Math.random()*2-1)*8;
					this.vity += (Math.random()*2-1)*8;
				}
				
				
				//
				break;//}
			case 2: //{---------------- JUDGE --------------
				var coef = this.focus.y/this.map.height
				this.head.head.gotoAndStop(22-Math.round(21*coef))
				var d = Math.max(-3,Math.min((this.focus.x - this.x)/100,3))
				this.head.head.yeux.o1.p._x = d
				this.head.head.yeux.o2.p._x = d
				//_root.test=">"+this.head.yeux.o2.p+"\n"
				break;//}
			case 3:	//{---------------- STUNNED --------------
				this.stunCounter -= kaluga.Cs.tmod;
				if( this.stunCounter < 0 ){
					this.initMode(0);
				};
				break;//}

		}
		this.endUpdate();
	}
	//
	function hitTarget(){


		if(this.jumpTarget.type=="Fruit"){
			//this.jumpTarget:sp.phys.Fruit;
			this.jumpTarget.flScSquirrel = true;
			/*
			this.jumpTarget.parentLink.removeLink(this.jumpTarget);
			this.jumpTarget.unLink();
			*/
			this.game.tzongre.release();
			this.jumpTarget.vitx += this.vitx;
			if(!this.jumpTarget.flGround)this.jumpTarget.vity += this.vity;			
		}else if(this.jumpTarget.type=="Butterfly"){
			//
			this.h.attachMovie("powerUp","powerUp",2)
			switch(this.jumpTarget.id){
				case 0:
				case 1:
					this.maxJumpDist += 80;
					break;
				default:
					this.speed += 4;
					break;

			}
			//
			for(var i=0; i<10/kaluga.Cs.tmod; i++){
				var p = this.jumpTarget.dropPaillette();
				p.vitx = 2*(random(200)-100)/100
				p.vity = 2*(random(200)-100)/100
			}
			this.jumpTarget.kill();

		}
		delete this.jumpTarget;	
	}
	
	function landing(){
		this.vity = 0;
		var dif = Math.abs(this.x - (this.map.width/2))
		if(dif<(this.map.width/2)+this.margin or this.flJump){
			this.initMode(0);
		}else{
			this.stunCounter = dif*2;
			this.initMode(3);			
		};
	}

	function exitGroundMode(flExt){
		//_root.test+="exitGroundMode\n"
		super.exitGroundMode();
		//this.initPhysMode();
		if(flExt)this.initMode(1);	// BRICOLAGE
	}
	
	function initMode(mode){
		this.exitMode(this.mode)
		switch(mode){
			case 0: //---------------- NORMAL --------------
				this.initGroundMode();
				this.flJump = false;
				this._rotation = 0;
				break;
			case 1:	//---------------- PHYS --------------
				this.initPhysMode();	
				if(!this.flJump)this.setSens(-1);
				this.gotoAndStop("fly")
				this.head.stop();
				break;

			case 2: //---------------- JUDGE --------------
				this.gotoAndStop("judge");
				this.head.head.stop();
				break;
			case 3: //---------------- STUNNED --------------
				this.gotoAndPlay("stunned")
				this.flGround = true;		// WARNING
				break;
			
		}
		this.mode = mode;
	}
	
	function exitMode(mode){
		switch(mode){
			case 0: //---------------- NORMAL --------------
				this.exitGroundMode();
				break;
				
			case 1:	//---------------- PHYS --------------
				this.exitPhysMode();
				break;
			case 2: //---------------- JUDGE --------------
				this.flFreeze = false;	
				break;
		}	
	}	
	
	function setSens(sens){
		if(sens!=undefined)this.sens = sens;
		this._xscale = -100*this.sens;
	}

	function setStatus(status){
		//_root.test+="[Squirrel] setStatus("+status+")\n"
		this.status = status;
		this.gotoAndPlay("flag");
	}
	
	function kill(){
		this.game.removeFromList(this,"squirrelList")
		super.kill();	
	}
	
	
	
//{	
}




