class miniwave.sp.Shot extends miniwave.Sprite {//}

	// CONSTANTES
	var killMargin:Number = 20;
	
	// VARIABLES 
	var flHit:Boolean;
	var flStandardHeroShot:Boolean;
	var flIndestructible:Boolean;
	var listName:String
	
	
	// PARAMETERS
	var speed:Number;
	var vitx:Number;
	var vity:Number;
	var vitRot:Number;
	//var flRotate:Number;
	var time:Number;
	var behaviourId:Number;
	var behaviourInfo:Object;
	
	var shot:MovieClip;
	var flare:MovieClip;
	
	function Shot(){
		this.init();
	}
	
	function init(){
		//_root.test+="hteth\n"
		super.init();
		this.stop();
		this.updateRotation();
	
	}
	
	function initDefault(){
		super.initDefault();
		if( this.vitx == undefined ) this.vitx = 0;
		if( this.vity == undefined ) this.vity = 0;
		if( this.flHit == undefined ) this.flHit = true;
		if( this.flHit == undefined ) this.flHit = true;
		if( this.flIndestructible == undefined ) this.flIndestructible = false;
		if( this.behaviourInfo == undefined ) this.behaviourInfo = new Object();
	}
	
	function update(){
		super.update();
		this.x += this.vitx*Std.tmod
		this.y += this.vity*Std.tmod
		
		if(this.vitRot!=undefined)this._rotation += this.vitRot*Std.tmod;
		
		switch( this.behaviourId ){
			case 0:		//{ PAMPLEMOUSSE 
				var flExplode = false;
				for( var i=0; i<this.game.hShotList.length; i++){
					var mc = this.game.hShotList[i]
					if( this.hTest(mc.x,mc.y) ){
						mc.kill();
						flExplode = true;
					}
				};
				if( this.y > this.game.mng.mch-12 ) flExplode = true;
				if(flExplode){
					var initObj = {
						time:40,
						x:this.x,
						y:this.y,
						vitx:2,
						vity:0
					}
					var mc = this.game.newBShot(initObj);
					mc.gotoAndStop(150);
					initObj.vitx*=-1;
					var mc = this.game.newBShot(initObj);
					mc.gotoAndStop(150);
					this.kill();
				}
				break;
				//}
			case 1:		//{ MURE
				var limit = 1.8
				var difx = this.game.hero.x-this.x;
				this.x += Math.min( Math.max( -limit, difx/8 ) , limit )
				break;
				//}
			case 2:		//{ BAIES
				var h = this.game.hero
				if( h._visible != true ) h = { x:this.game.mng.mcw/2, y:-200 };					
				this.follow( this.game.hero, 0.3, 0.5);
				
				break;
				//}
			case 3:		//{ CITRUS
				this.vity += Std.tmod*0.4
				this.vitx *= this.game.frict;
				this.vity *= this.game.frict;
				this.updateRotation();
				
				break;
				//}
			case 4:		//{ TITI

				switch( this.behaviourInfo.step ){
					case 0:
						if( this.y > this.game.mng.mch-10 ){
							this.behaviourInfo.step = 1
							this.behaviourInfo.coef = 0
							this;_alpha = 70;
							this.flHit = false;
						};				
						break;
					case 1:
						this.behaviourInfo.coef +=  0.02 * Std.tmod
						var c = this.behaviourInfo.coef
						
						var x = this.behaviourInfo.path.x + (this.behaviourInfo.id*9 -4.5)
						var y = this.behaviourInfo.path.y + 4.5
						
						if( c<0.6 ){
							this.x = this.x*(1-c) + x*c
							this.y = this.y*(1-c) + y*c
						}else{
							this.behaviourInfo.path.returnPunch( this.behaviourInfo.id )
							this.kill();
						}
						
						break;
					
				}
				break;	
				//}
			case 5:		//{ MIRABELLE
				
				var o = this.behaviourInfo
				o.parcouru+=this.vity;
				var c = Math.min( o.parcouru/o.length, 1 )
				this.shot.square._xscale = c *100
				this.flare._xscale = (1-c)*100
				this.flare._yscale = (1-c)*100
				this.flare._x = -c*o.length 
				
				var h = this.game.hero
				if( this.y > h.y-h.ray && this.y-o.length < h.y+ h.ray){
					if( Math.abs( h.x - this.x) < h.ray ){
						h.hit();
					} 
				}
				break;
				//}
			case 6:		//{ PASTAGA MISSILE
				if( Key.isDown(this.game.hero.key[2]) ){
					this.kill();
				}
				break;
				//}				
			case 7:		//{ PASTAGA EXLPOSION
				//_root.test+="rggrzggz\n"
				var o = this.behaviourInfo
				o.ray += o.raySpeed*Std.tmod
				o.ray *= Math.pow(o.frict,Std.tmod);
				o.timer -= Std.tmod;
				
				this._xscale = o.ray*2
				this._yscale = o.ray*2
				
				if(o.timer<0){
					this.kill();
				}else if( o.timer < 10 ){
					this._alpha = o.timer*10;
				}
				if( o.timer>5 ){
					var list = this.game.badsList;
					for( var i=0; i<list.length; i++ ){
						var mc = list[i]
						var dx = mc.x - this.x 
						var dy = mc.y - this.y
						var dist = Math.sqrt(dx*dx+dy*dy)
						if(dist<o.ray)mc.hit();
					}				
				}
				
				
				
				break;
				//}				
			case 8:		//{ HOMING HERO -> BADS
				
				var o = this.behaviourInfo
				if(o.target == undefined || o.target._visible != true ){
					var list = this.game.badsList
					if(list.length>0){
						o.target = list[random(list.length)]
					}else if(this.game.step == 4){
						o.target = this.game["boss"]	// PAS BÖ
					}else{
						this.vanish();
					}
				}
				this.follow( o.target, 1, 0.5);
				
				this.queue("miniWave2SpPartHomingQueue")

				break;
				//}				
			case 9:		//{ CURASO SHOT
				var o = this.behaviourInfo;
				o.d = (o.d+o.decalSpeed)%628;
				var dx = Math.cos(o.d/100)*o.decal;
				this.x = o.x + dx
				this.queue("miniWave2SpPartCurasoQueue")
				break;
				//}			
			case 10:	//{ CURASO SPECIAL
				
				
				
				break;
				//}					
			case 11:	//{ STRAWBERRY
				var o = this.behaviourInfo
				var c;
				if( o.timer>0 ){
					o.timer -= Std.tmod;
					c = this.game.hero
					if( c._visible != true ) c = { x:this.game.mng.mcw/2, y:this.game.mng.mch-10 };	
				}else{
					c = o.launcher
					if( c._visible != true ) c = { x:this.game.mng.mcw/2, y:-200 };	
					var dx = c.x - this.x;
					var dy = c.y - this.y;
					var dist = Math.sqrt(dx*dx+dy*dy);
					if(dist<10){
						o.launcher.catchShot();
						this.kill();
					}
				}
				
				
				this.follow( c, 0.3, 0.5);
				this._rotation = random(360)
				
				break;
				//}				
			case 12:	//{ GROSEILLE
				var o = this.behaviourInfo
				this.follow( o.target, 0.7, 0.5);
				this.queue("miniWave2SpPartGroseilleQueue")
				
				if(this.y > this.game.mng.mch+4 ) this.kill();
				
				break;
				//}					
			case 13:	//{ NECTARINE
				var o = this.behaviourInfo
				
				c = this.game.hero
				if( c._visible != true ) c = { x:this.game.mng.mcw/2, y:this.game.mng.mch-10 };	
				
				if( this.y > c.y ){
					this.y = c.y;
					this.vitx = 0;
					this.vity = 0;
					this.shot.play();
					this.shot.flLoop = true;
					o.flBlackHole = true;
					o.timer = 100;
				}
				if( o.flBlackHole ){
					if(o.timer>0){
						o.timer -= Std.tmod;
						var dif = this.game.hero.x - this.x
						this.game.hero.x -= Math.min(Math.max( -2, 40/dif ),2 )*Std.tmod;
					}else{
						this.shot.flLoop = false;
					}
				}
				break;
				//}				
			case 14:	//{ CORINTHE
				var o = this.behaviourInfo
				var c = Math.pow(0.8,Std.tmod)
				this.vitx *= c
				this.vity *= c
				
				if(this.vity>1)this.queue("miniWave2SpPartGroseilleQueue");
				
				if( this.vity<0.1 ){
					this.vity = this.behaviourInfo.speed
					this.vitx = this.behaviourInfo.speed*(random(3)-1)
					o.oldPos = { x:this.x, y:this.y }
				}
				
				
				
				break;
				//}				
			case 15:	//{ KUMQUAT
				
				if( (this.x < 0 || this.x > this.game.mng.mcw) && this.y<this.game.mng.mch-10){
					c = this.game.hero
					if( c._visible != true ) c = { x:this.game.mng.mcw/2, y:this.game.mng.mch-10 };						
					var a = this.getAng(c)
					this.vitx = Math.cos(a)*4
					this.vity = Math.sin(a)*4
					this.updateRotation();
					
				}
				this.queue("miniWave2SpPartKumquatQueue")
				
				break;
				//}
			case 16:	//{ SHOOTABLE
				//_root.test+="-\n"
				for( var i=0; i<this.game.hShotList.length; i++){
					var mc = this.game.hShotList[i]
					if( this.hTest(mc.x,mc.y) ){
						mc.kill();
						this.shot.play();
						this.flHit = false;
					}
				};				
				break;
				//}
			case 17:	//{ LEMON THUNDER BALL
				
				var o = this.behaviourInfo
				if( o.step == undefined ) o.step = 0;

				for( var i=0; i<this.game.hShotList.length; i++){
					var mc = this.game.hShotList[i]
					if( this.hTest(mc.x,mc.y) ){
						mc.kill();
						this.shot.play();
						this.flHit = false;
					}
				};
				if(this.flHit){
					c = this.game.hero
					switch(o.step){
		
						case 0 :
							if( c._visible ){
								var d = this.getDist(c)
								if( d < 100){
									o.step = 1;
								}
							}
							break;
						case 1 :
							if( c._visible ){
								this.follow(c,0.7,2)
							}else{
								this.kill();
							}						
							break;
					}
				}

				
				break;
				//}
			case 18:	//{ JELLY EMP
				
				break
				//}
			case 19:	//{ COURGE SINUS
				var o = this.behaviourInfo
				o.amp += Std.tmod*0.6
				o.d = (o.d+18)%628
				this.x = o.x + Math.sin(o.d/100)*o.amp
				
				this.queue("miniWave2SpPartKumquatQueue")
				break //}
			
			case 20:	//{ BULBE HOMING
				this.follow( this.game.hero, 0.25, 5  );
				this.vity += 0.3*Std.tmod
				mc.updateRotation();
				break //}
				
			case 21:	//{ CASSIS HOMING
				var o = this.behaviourInfo
				//if(o.timer == undefined )o.timer = 20;
				
				if(o.timer > 0 ){
					o.timer -= Std.tmod
					this.follow( this.game.hero, 0.5, 1  );

					if( o.timer<=0  ){
						this.time = 100
					}
				}
				//mc.updateRotation();
				//this.queue("miniWave2SpPartGroseilleQueue")
				break //}
			case 22:	//{ POIS CHIHE CRAZY SHOT
				var o = this.behaviourInfo
				switch(o.step){
					case 0:
						if(!random(60)){
							o.step = 1
							o.ty = this.y-80
							o.vitx = -this.vitx
							o.vity = this.vity
							this.vitx = 0
							this.vity = 0
						}
						if( this.x < 0 ) this.vitx = Math.abs(this.vitx)
						if( this.x > this.game.mng.mcw ) this.vitx = -Math.abs(this.vitx)
						
						break;
					case 1:
						dy = o.ty-this.y
						this.y += dy*Math.pow(0.5,Std.tmod)
						if( Math.abs(dy) < 2 ){
							this.vitx = o.vitx
							this.vity = o.vity
							o.step = 0
						}
						break;
				}
				this.queue("miniWave2SpPartKumquatQueue")
				//mc.updateRotation();
				//this.queue("miniWave2SpPartGroseilleQueue")
				break //}

			case 23:	//{ BRUGNON BOMB
				var o = this.behaviourInfo
				// SHOOTABLE
				for( var i=0; i<this.game.hShotList.length; i++){
					var mc = this.game.hShotList[i]
					var d = this.getDist(mc)
					//_root.test="d("+d+")"
					if( d < 10 ){
						mc.kill();
						this.shot.gotoAndPlay("death");
						this.flHit = false;
						this.vitRot = 0;
					}
				};
				
				if(!random(18/Std.tmod) && this.flHit ){
					var a = random(628)/100
					var initObj = {
						x:this.x,
						y:this.y,
						vitx:Math.cos(a)*4,
						vity:Math.sin(a)*4,
						vitRot:random(60)-30
					}
					var mc = this.game.newBShot(initObj)
					mc.gotoAndStop(162)
					
				}
				break //}
			case 24:	//{ CARD RED : HANABI
				if( this.x < 0 ) this.vitx = Math.abs(this.vitx)
				if( this.x > this.game.mng.mcw ) this.vitx = -Math.abs(this.vitx)		
				if( this.y > this.game.mng.mch ) this.vity = -Math.abs(this.vity)				
				break //}
			case 25:	//{ CARD BLUE : WAVE
				var list = this.game.badsList;
				for( var i=0; i<list.length; i++ ){
					var mc = list[i]
					if( mc.y > this.y ){
						mc.explode();
					}
				}

				
				break //}				
				
		}

		
		// TIME
		if( this.time!=undefined ){
			this.time -= Std.tmod
			if( this.time < 0 ){
				this.kill();
			} else if ( this.time < 10 ) {
				this._alpha = this.time*10;
			}
		}
		
		// HORS LIMITE
		if( this.x < -this.killMargin || this.x > this.game.mng.mcw+this.killMargin || this.y < -this.killMargin || this.y > this.game.mng.mch+this.killMargin ){
			if(this.flStandardHeroShot)this.game.incScore(-1);	
			this.kill();
		}
		
		
		this.endUpdate();
	}
	
	function vanish(){
		var mc = this.game.newPart("miniWave2SpPartVanish")
		//_root.test+=">"+mc+"\n"
		mc.x = this.x
		mc.y = this.y
		mc.flGrav = false;
		this.kill();
	}
	
	function kill(){
		this.onKill();
		var list;
		if( this.listName == "hShot"){
			list = this.game.hShotList;
		}else{
			list = this.game.bShotList;
		}
		this.game.removeFromList( this, list );
		super.kill();
	}
	
	function updateRotation(){
		this._rotation = Math.atan2(this.vity,this.vitx)/(Math.PI/180)
	}
	
	function onKill(){
		switch( this.behaviourId ){
			
			case 6:		//{ PASTAGA
				this.game.mng.sfx.playSound( "sExplo4", 62 )
				var initObj = {
					x:this.x,
					y:this.y,
					vitx:0,
					vity:0,
					behaviourId:7,
					behaviourInfo:{
						ray:0,
						raySpeed:12,
						frict:0.85,
						timer:22
					}
				}
				var mc = this.game.newHShot(initObj);
				mc._xscale = 0
				mc._yscale = 0
				mc.gotoAndStop(153)
				break;
				//}
				
		}	
	}
	
	function onHit(){
		switch( this.behaviourId ){
			case 10:	//{ CURASO SPECIAL
			
				var max = 5
				for(var i=0; i<max; i++){
					var a = ((i/max)*628)/100
					var initObj = {
						x:this.x,
						y:this.y,
						vitx:Math.cos(a)*4,
						vity:Math.sin(a)*4,
						time:20,
						behaviourId:10
					}
					var mc = this.game.newHShot(initObj);
					//_root.test+=">"+a+"\n"
					mc.gotoAndStop(155)
				}
				
				this.kill();
				break;
				//}				
			case 18:	//{ JELLY EMP
				this.game.hero.hitEMP(100)
				this.kill();
				break
				//}					
			default:	//{ DEFAULT
				var initObj = {
					x:this.x,
					y:this.y,
					flGrav:false
				}
				var mc = this.game.newPart("miniWave2SpPartImpact",initObj);
				//_root.test+="mc("+mc+")\n"
				mc._rotation = random(360)
				
				
				if(!this.flIndestructible)this.kill();
				break;
				//}		
				
		}	
	}
		
	function follow( target, speed, tol ){
		var difx = target.x-this.x;
		var dify = target.y-this.y;
		
		if( difx > tol )	this.vitx += Std.tmod*speed;
		if( difx < -tol )	this.vitx -= Std.tmod*speed;
		if( dify > tol )	this.vity += Std.tmod*speed;
		if( dify < -tol )	this.vity -= Std.tmod*speed;			
		
		this.vitx *= this.game.frict;
		this.vity *= this.game.frict;
		this.updateRotation();	
	}
	
	function queue( link ){
		var o = this.behaviourInfo
		if( o.oldPos != undefined ){
			var initObj = {
				x:this.x,
				y:this.y,
				flGrav:false
				
			}
			var mc = this.game.newPart( link, initObj, true )
			var dx = this.x - o.oldPos.x
			var dy = this.y - o.oldPos.y
			var dist = Math.sqrt(dx*dx+dy*dy)
			var a = Math.atan2(dy,dx)
			
			mc._xscale = dist;
			mc._rotation = a/(Math.PI/180);
			
			
		}
		o.oldPos = { x:this.x, y:this.y }
	}
	
	function klong( initObj){
		if( initObj == undefined )initObj = new Object();

		initObj.x = this.x;
		initObj.y = this.y;
		initObj.flOrient = true;

		var part = this.game.newPart("miniWave2SpPartCustom",initObj);
		part.attachMovie( "miniWave2SpShot", "skin", 10 );
		part.skin.gotoAndStop( this._currentframe );
		
		return part;		
		
	}
	
	function getSpeed(){
		return Math.sqrt( this.vitx*this.vitx + this.vity*this.vity );
	}
	
	
//{	
}