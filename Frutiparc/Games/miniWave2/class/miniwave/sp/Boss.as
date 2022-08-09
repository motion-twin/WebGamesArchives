class miniwave.sp.Boss extends miniwave.Sprite{//}

	// CONSTANTES
	var turning:Number = 	3;
	var ray:Number = 	25;
	var hpShell:Number = 	30//60//80;
	var hpCasque:Number = 	30//40//60;
	var hpOrange:Number = 	30//40//60;
	
	var handRay:Number =	25;
	var coudeRay:Number =	36;

	
	// VARIABLES
	
	var flShooting:Boolean;
	
	var step:Number;
	var form:Number;
	var vitx:Number;
	var vity:Number;
	
	var mvx:Number;
	var mvy:Number;
	
	var speedCoef:Number;
	var hp:Number;	
	var hpMax:Number;
	var specialCoolDown:Number;
	var timer:Number;
	
	var mvt:Object;
	var shootInfo:Object;
	var shield:Object;
	var flash:Object;
	
	// REFERENCE
	var game:miniwave.game.Main
	
	// MOVIECLIP
	var lightPath:MovieClip;
	var base:MovieClip;
	
	var shell:MovieClip;
	var orange:MovieClip;
	var h0:MovieClip;
	var h1:MovieClip;
	var casque:MovieClip;
	
	
	function Boss(){
		this.init();
	}
		
	function init(){
		super.init();
		//
		this.flShooting = false;
		this.speedCoef = 1;
		this.initStep(0);
		//
		this.stop();
		this.endUpdate();
		
	}

	function initStep(step){
		
		this.step = step;
		switch( this.step ){
			case 0:		//{ SHELL INIT
				this.form = 0;
				this.lightPath = this.shell.light;
			
				this.x = this.game.mng.mcw/2;
				this.y = -100;
				this.hpMax = this.hpShell
				this.hp = this.hpMax
				//this.updateHP();
			
				this.base = this.shell;
				this.vitx = 0;
				this.vity = 0;
				this.specialCoolDown = 0 	
				this.mvt = new Array();
				for( var i=0; i<2; i++) {
					var o = {
						d:157,
						s:0,
						st:5+random(5)
					}
					this.mvt[i] = o;
				}			
				break; //}
			case 1:		//{ SHELL BASE

				break; //}
			case 2:		//{ SHELL SIDE-DASH
				this.shootInfo = {
					type:0,
					toShoot:3,
					timer:0,
					interval:2
				}
				var sens = (this.x<this.game.mng.mcw/2)*2 -1
				this.vitx += 15*sens;
				this.speedCoef = 8;
				this.specialCoolDown = 100;
				break; //}
			case 3:		//{ SHELL DEATH-WHEEL
				this.shootInfo = {
					type:1,
					toShoot:10,
					timer:36,
					interval:3
					//flFreeze:true
				}
				this.specialCoolDown = 200;			
				break; //}
			case 9:		//{ SHELL DESTRUCT
				this.turnShell();
							
				this.timer = 20//0;
				
				this.mvt.cx = this.game.mng.mcw/2;
				this.mvt.cy = 120;
				
				this.vitx = 0;
				this.vity = 0;
								
				break; //}		
			case 10:	//{ CASQUE INIT
				this.gotoAndStop(2);
				this.h0.stop();
				this.h1.stop();
				this.form = 1;
				this.lightPath = this.casque.light;				
				for(i=0; i<12; i++){
					var a = (i/12)*6.28
					var vit = 3+random(30)/10
					var initObj = {
						x:this._x,
						y:this._y,
						vitx:Math.cos(a)*vit,
						vity:Math.sin(a)*vit,
						vitr:4,
						timer:8+random(12),
						flGrav:false

					}					
					var mc = this.game.newPart("miniWave2SpPartShellWing",initObj);
					//_root.test+="mc("+mc+")\n"
					mc._rotation = a/(Math.PI/180);
				}
				
				this.hpMax = this.hpCasque
				this.hp = this.hpMax;
				//this.updateHP();
				this.specialCoolDown = 100;
				

				this.orange.regard.stop();
				this.orange.bouche.stop();
				this.timer = 10;
				this.base = this.orange;
				this.vitx = 0
				this.vity = 0
				
				this.h1._xscale = -100
				
				for( var i=0; i<2; i++){
					var h = this["h"+i]
					var sens = i*2-1;
					h.x = sens * 20;
					h.y = 18;
					h.r = 0;
					h.tx = sens * 30;
					h.ty = 15;
					h.tr = 0;
				}				
				

				
				this.mvt = {
					dy:0,
					//ty:0,
					vy:10,
					cy:80,		// centre y
					ey:30,		// ecart max y
					coy:1,		// coef multiplicateur de vy
					cox:1,		// coef multiplicateur de speed
					speed:2,
					sens:1,
					hs:3		// handSpeed;
				}
				
				this.moveHands();
				
				break; //}
			case 11:	//{ CASQUE BASE
								
				this.mvt.cox = 1
				//delete this.mvt.ty;
				for( var i=0; i<2; i++){
					var h = this["h"+i]
					var sens = i*2-1;
					h.tx = sens * 30;
					h.ty = 15;
					h.tr = 0;
				}					
				
				
				break; //}
			case 12:	//{ CASQUE FLAME STRAFE
				this.shootInfo = {
					type:2,
					toShoot:50,
					timer:40,
					interval:2.5
				}
				
				for( var i=0; i<2; i++){
					var h = this["h"+i]
					h.tx = (i*2-1) * 36
					h.ty = 13
				}
				this.specialCoolDown = 200;
				this.mvt.ty = 132;
				this.mvt.cox = 0.2;
				break; //}
			case 13:	//{ CASQUE DOUBLE LASER
				this.shootInfo = {
					type:3,
					toShoot:3,
					timer:60,
					interval:20
				}
				this.specialCoolDown = 100;
				break;//}
			case 14:	//{ CASQUE SIMPLE LASER
				this.shootInfo = {
					type:3,
					toShoot:6,
					timer:70,
					interval:9,
					hand:random(2)
				}
				
				var hid = !this.shootInfo.hand
				var h = this["h"+Number(hid)]
				h.tx = (hid*2-1) * 40
				h.ty = -16
				h.tr = -(hid*2-1)*1.30

				
				this.specialCoolDown = 100;
				break;//}	
			case 19:	//{ CASQUE DESTRUCT
				this.mvt = {
					d:10,	//tremble
					timerMax:10,		// 100
					x:this.x,
					y:this.y
				}
				this.timer = this.mvt.timerMax;
				break;//}
			case 20:	//{ ORANGE INIT
				
				for(i=0; i<16; i++){
					var a = random(628)/100
					var vit = 5+random(50)/10
					var dx  = Math.cos(a)
					var dy  = Math.sin(a)
					var initObj = {
						x:this.x+dx*(random(this.ray)+this.ray/2),
						y:this.y+dy*(random(this.ray)+this.ray/2),
						vitx:dx*vit,
						vity:dy*vit - random(5),
						vitr:random(21)-10,
						timer:8+random(12),
						flGrav:true
					}					
					var mc = this.game.newPart("miniWave2SpPartCasqueDebrit",initObj);
					//_root.test+="mc("+mc+")\n"
					mc._rotation = a/(Math.PI/180);
					mc.gotoAndStop(i+1)
				}
				this.form = 2;
				this.h0.gotoAndStop(2)
				this.h1.gotoAndStop(2)
				this.casque._visible = false;
				this.timer = 20;
				this.vitx = 0;
				this.vity = 0;
				
				this.hpMax = this.hpOrange
				this.hp = this.hpMax;
				
				this.mvt = {
					dy:0,
					ty:100,
					vy:16,
					cy:100,		// centre y
					ey:60,		// ecart max y
					coy:1,		// coef multiplicateur de vy
					cox:1,		// coef multiplicateur de speed
					speed:4,
					sens:1,
					hs:3,		// handSpeed;
					physHand:true
				}
				
				
				break;//}
			case 21:	//{ ORANGE BASE
				this.mvt.cy = 100;
				this.mvt.ey = 60;
				this.mvt.hs = 3;
				
				for( var i=0; i<2; i++){
					var h = this["h"+i]
					var sens = i*2-1;
					h.vx = 0;
					h.vy = 0;
					h.tr = 0
					h.flPhys = true;
					h.gotoAndStop(3)
				}
				break;//}
			case 22:	//{ ORANGE MULTI BALLS
				this.shootInfo = {
					type:4,
					toShoot:5,
					timer:20,
					interval:14,
					hand:random(2)
				}				
				
				var hid = this.shootInfo.hand
				var h = this["h"+hid]
				h.tx = (hid*2-1) * 50
				h.ty = -8
				h.tr = -(hid*2-1)*0.75
				h.flPhys = false;
				h.gotoAndStop(2)
				
				this.specialCoolDown = 140;
				
				break;//}
			case 23:	//{ ORANGE BADS SHIELD
				this.shootInfo = {
					timerMax:60
				}
				this.timer = this.shootInfo.timerMax
				this.mvt.hs = 100
				for( var i=0; i<2; i++){
					var h = this["h"+i]
					var sens = i*2-1;
					h.tx = 0;
					h.ty = 0;
					h.tr = 0
					h.flPhys = false;
					h.gotoAndStop(2)
				}	
				
				this.specialCoolDown = 180;
				
				break;//}
			case 24:	//{ ORANGE MORSURE DU SOLEIL
				
				this.shootInfo = {
					step:0
				}
				this.mvt.ty = 0
				this.mvt.cy = 50
				this.mvt.ey = 10
				this.mvt.hs = 100
				
				for( var i=0; i<2; i++){
					var h = this["h"+i]
					var sens = i*2-1;
					h.tx = 20*sens;
					h.ty = 14;
					h.tr = -2.10*sens
					h.flPhys = false;
					h.gotoAndStop(2)
				}	
				this.timer = 80
				this.specialCoolDown = 200;
				
				break;//}				
			case 25:	//{ ORANGE STRAFE SHOT
				var sens = (this.x<this.game.mng.mcw/2)*2 -1
				this.shootInfo = {
					type:6,
					toShoot:8,
					timer:0,
					interval:3,
					hand:(sens+1)/2
				}
				
				
				var h = this["h"+this.shootInfo.hand];
				h.gotoAndStop(2);
				h.vx += sens*4
				//this.vitx += 15*sens;
				//this.speedCoef = 8;
				this.specialCoolDown = 80;			

					break//}
			case 29:	//{ ORANGE DESTRUCT
					this.mvt = {
						d:8,//8	//tremble
						timerMax:80,		// 100
						x:this.x,
						y:this.y
					}
					this.timer = this.mvt.timerMax;
					
					this.orange.regard.gotoAndStop(2);
					this.orange.bouche.gotoAndStop(2);
					//
					this.game.mng.client.giveItem("$arcade");
					this.game.mng.newTitem++					
					
					break//}
			case 30:	//{ ORANGE EXPLOSION
					this.clear();
					this.timer = 80
					this.orange._visible = false;
					this.h0._visible = false;
					this.h1._visible = false;
					
	
					for(var n=0; n<2; n++ ){
						var sens = 2*n-1
						for(var i=0; i<13; i++ ){
						
							var dx  = Math.cos(a)
							var dy  = Math.sin(a)
							
							var initObj = {
								vitr:random(5)-2,
								timer:16+random(16),
								weight:0.3,
								flGrav:false
							}
							
							var mc = this.game.newPart("miniWave2SpPartBoss",initObj,i>1);
							mc.gotoAndStop(i+1)
							mc.p.gotoAndStop(i+1)
							
							//_root.test+="mc("+mc.p._currentframe+")\n"
							
							mc.x  = this._x + mc.p._x*sens
							mc.y  = this._y + mc.p._y*sens
							
							if( sens == 1 ){
								mc._rotation = 180
								miniwave.MC.setPColor( mc, 0xC7772D, 0 )
							}
							
							
							var a = Math.atan2( mc.p._y*sens, mc.p._x*sens)
							var dist = Math.sqrt( mc.p._x*mc.p._x + mc.p._y*mc.p._y)
							
							mc.vitx = Math.cos(a)*(dist/(8+sens*2))
							mc.vity = Math.sin(a)*(dist/(8+sens*2)) - 1
							
							//_root.test+="mc("+mc.x+")\n"
								
							mc.endUpdate();
							
						}
					}
					break//}			


					
		}		
		
	}
		
	function update(){
		//_root.test = ">"+this.game.badsList.length+"\n"
		
		super.update();
		this.speedCoef = this.speedCoef*0.9 + 0.1
		
		this.moveBase();
		this.checkHeroCol();
		
		switch( this.step ){
		
			case 0:		//{ SHELL INIT
				this.turnShell()
				this.y += 6 * Std.tmod;
				if( this.y > this.game.mng.mch/2 ){
					this.initStep(1)
				}
				
				break; //}
			case 1:		//{ SHELL BASE
				this.turnShell()
				this.moveShell()
				this.checkBehaviour();
				this.checkHeroShot();
				break; //}
			case 2:		//{ SHELL SIDE-DASH
				this.turnShell()
				this.moveShell()
				this.checkShoot();
				if( this.shootInfo.toShoot == 0 ) this.step = 1;
				this.checkHeroShot();
				break //}
			case 3:		//{ SHELL DEATH-WHEEL
				this.turnShell()
				this.moveShell()
				this.checkShoot();
				
				this.mvt[0].s *= 0.8;
				this.mvt[1].s *= 0.8;
				this.speedCoef *= 1.1 				
				
				if( this.shootInfo.toShoot == 0 ) this.step = 1;
				this.checkHeroShot();
				break //}
			case 9:		//{ SHELL DESTRUCT
				
				var dx = this.mvt.cx - this._x;
				var dy = this.mvt.cy - this._y;
				var lim = 1
				
				this.vitx +=  Math.min( Math.max( -lim, dx/10 ), lim ) * Std.tmod;
				this.vity +=  Math.min( Math.max( -lim, dy/10 ), lim ) * Std.tmod;
				
				var frict = Math.pow(0.99,Std.tmod)
				this.vitx *= frict;
				this.vity *= frict;
				
				this.x += this.vitx;
				this.y += this.vity;
				
				this.shell._x = this.shell._x*0.5 + ( random(11)-5 )*0.5
				this.shell._y = this.shell._y*0.5 + ( random(11)-5 )*0.5
				
				var c = Math.min(this.timer/100,1)
				
				if( !random(c*10/Std.tmod) ){
					var a = random(628)/100
					var d = random(this.ray)
					var initObj = {
						x:this._x+Math.cos(a)*d,
						y:this._y+Math.sin(a)*d,
						flGrav:false
					}
					var mc = this.game.newPart("miniWave2SpPartImpact",initObj)
					mc._rotation = random(360)
					mc._xscale = 100 + random(100)*(1-c)
					mc._yscale = 100 + random(100)*(1-c)
				}
				
				
				if( this.timer < 0 ){
					this.initStep(10);
				}else{
					this.timer -= Std.tmod
				}
				
				break //}
			case 10:	//{ CASQUE INIT
				this.checkLook();
				this.moveHands();
				if( this.timer < 0 ){
					delete this.timer;
					this.initStep(11)
				}else{
					this.timer -= Std.tmod;
				}
				break //}
			case 11:	//{ CASQUE BASE
				this.checkLook();
				this.moveOrange();
				this.moveHands();
				this.checkBehaviour();
				this.checkHeroShot();
				
				var chp = this.hp / this.hpMax
				if( !random((40+40*chp)/Std.tmod) ){
					this.shootInfo = {
						type:3,
						toShoot:0,
						timer:-1
					}					
					this.checkShoot();
				}				
				
				break //}
			case 12:	//{ CASQUE FLAME STRAFE
				this.checkLook();
				this.moveOrange();
				this.moveHands();
				this.checkShoot();
				
			
				if( this.shootInfo.toShoot == 0 ) this.initStep(11);
				this.checkHeroShot();
				break; //}
			case 13:	//{ CASQUE DOUBLE LASER
				this.checkLook();
				this.moveOrange();
				this.moveHands();
				this.checkShoot();	
				
				for( var i=0; i<2; i++){
					var h = this["h"+i]
					//var sens = i*2-1;
					var hero = this.game.getHeroTarget();
					var dx = hero.x - (this.x+h.x)
					var dy = hero.y - (this.y+h.y)
					var a = Math.atan2(dy,dx) - 1.57
					a = Math.min( Math.max(-0.3, a ),0.3 )
					h.tr = a;
				
				}
				
				if( this.shootInfo.toShoot == 0 ) this.initStep(11);
				this.checkHeroShot();
				break; //}
			case 14:	//{ CASQUE SIMPLE LASER
				this.checkLook();
				this.moveOrange();
				this.moveHands();
				this.checkShoot();	
				

				var h = this["h"+this.shootInfo.hand]
				//var sens = i*2-1;
				var hero = this.game.getHeroTarget();
				var dx = hero.x - (this.x+h.x)
				var dy = hero.y - (this.y+h.y)
				var a = Math.atan2(dy,dx) - 1.57
				a = Math.min( Math.max(-0.5, a ),0.5 )
				h.tr = a;
				

				
				if( this.shootInfo.toShoot == 0 ) this.initStep(11);
				this.checkHeroShot();
				break; //}				
			case 19:	//{ CASQUE DESTRUCT
				
				var c = 1 - this.timer/this.mvt.timerMax
				this.x = this.mvt.x + ( random(this.mvt.d*2)-this.mvt.d ) * c;
				this.y = this.mvt.y + ( random(this.mvt.d*2)-this.mvt.d ) * c;
								
				if( this.timer < 0 ){
					this.initStep(20);
				}else{
					this.timer -= Std.tmod;
				}
				
				break;//}
			case 20:	//{ ORANGE INIT
								
				if( this.timer < 0 ){
					delete this.timer;
					this.initStep(21)
				}else{
					this.timer -= Std.tmod;
				}				
				break;//}
			case 21:	//{ ORANGE BASE
				this.checkLook();
				this.moveOrange();
				this.moveHands();
				this.checkHeroShot();
				this.checkBehaviour();
				
				var chp = this.hp / this.hpMax
				if( !random((20+30*chp)/Std.tmod) ){
					this.shootInfo = {
						type:5,
						toShoot:0,
						timer:-1
					}
					this.checkShoot();
				}
				this.mvt.cox = this.mvt.cox*0.5 + 0.5
				this.mvt.coy = this.mvt.coy*0.5 + 0.5
				
					
				break;//}
			case 22:	//{ ORANGE MULTI BALLS
				
				this.checkLook();
				this.moveOrange();
				this.moveHands();
				this.checkShoot();
				
				this.mvt.cox *= 0.7
				this.mvt.coy *= 0.7
				
				if( this.shootInfo.toShoot == 0 ) this.initStep(21);
				this.checkHeroShot();							
				break;//}
			case 23:	//{ ORANGE BADS SHIELD
				
				this.checkLook();
				this.moveOrange();
				this.moveHands();
				//this.checkShoot();
				this.checkHeroShot();	
				var c = this.timer / this.shootInfo.timerMax
				
				for( var i=0; i<2; i++){
					var h = this["h"+i]
					var a = (c*3.14 - 3.14*i)+1.57
					h.tx = Math.cos(a)*50
					h.ty = Math.sin(a)*50
					h.tr = a+1.30
					h.flPhys = false;
				}	
				
				
				
				this.mvt.cox *= 0.95
				this.mvt.coy *= 0.95
				
				if( this.timer < 0 ){
					this.shield = {
						ray:50,
						speed:6,
						decal:0
					}
					var max = 12
					for( var i=0; i<max; i++ ){
						var a = i/max * 6.28;
						var initObj = {
							flWave:false,
							x:this.x+Math.cos(a)*this.shield.ray,
							y:this.y+Math.sin(a)*this.shield.ray,
							a:a
						}					
						var mc = this.game.newBads(1,initObj);
						mc.step = 2;
					}
					
					delete this.timer;
					this.initStep(21)
				}else{
					this.timer -= Std.tmod;
				}
				
						
				break;//}
			case 24:	//{ ORANGE MORSURE DU SOLEIL
				//this.checkLook();
				this.moveOrange();
				this.moveHands();
				//this.checkShoot();
				this.checkHeroShot();
				
				this.orange._rotation = this.orange._rotation*0.7
				
				if( this.timer < 0 ){
					
					switch(this.shootInfo.step){
						case 0:
							for( var i=0; i<2; i++){
								var h = this["h"+i];
								var sens = i*2-1;
								h.tx = 40*sens;
								h.ty = 8;
							}
							this.timer = 26;
							this.mvt.cox = 0;
							this.mvt.coy = 0;
							this.shootInfo.step = 1
							
							this.orange.regard.gotoAndStop(3)
							this.orange.bouche.gotoAndStop(3)
							this.orange.hitTimer = 16;
							
							//var a:miniwave.sp.Hero;
							this.game.hero.blind(300);
							
							break;
						case 1:
							delete this.timer;
							this.mvt.ty = 0;
							this.initStep(21);
							break;							
					}
				}else{
					this.timer -= Std.tmod;
				}				
				break;//}
			case 25:	//{ ORANGE STRAFE SHOT
				this.checkLook();
				this.moveOrange();
				this.moveHands();
				this.checkShoot();
				
				this.mvt.cox *= 0.9
				
				if( this.shootInfo.toShoot == 0 ) this.initStep(21);
				this.checkHeroShot();
				break;//}
			case 29:	//{ ORANGE DESTRUCT
				
				var c = 1 - this.timer/this.mvt.timerMax
				this.x = this.mvt.x + ( random(this.mvt.d*2)-this.mvt.d ) * c;
				this.y = this.mvt.y + ( random(this.mvt.d*2)-this.mvt.d ) * c;
				
				
				
				if(!random((20*(1-c))/Std.tmod)){
					
					var d = 5+random(this.ray-5)
					var a = random(628)/100
					
					var initObj = {
						x:this.x+this.base._x+Math.cos(a)*d,
						y:this.y+this.base._y+Math.sin(a)*d,
						vitx:0,
						vitx:0,
						flGrav:false
					}
									
					var mc = this.game.newPart("miniWave2SpPartOrangeJuice",initObj);
					//mc._xscale = 40+d*5
					mc._rotation = a/(Math.PI/180)
					
					
				}
				
				
				if( this.timer < 0 ){
					this.initStep(30);
				}else{
					this.timer -= Std.tmod;
				}
				
				break;//}
			case 30:	//{ ORANGE DESTRUCT
			
				if( this.timer < 0 ){
					this.kill();
				}else{
					this.timer -= Std.tmod;
				}
				
				break;//}
			}
			
		
		switch( this.form ){
			case 1:
				this.drawArms();
				this.casque._x = this.orange._x
				this.casque._y = this.orange._y
				break;
			case 2:
				if(this.step<30)this.drawArms();
				if( this.shield != undefined ){
					this.shield.decal = (this.shield.decal+this.shield.speed)%628
					var list =this.game.badsList;
					for( var i=0; i<list.length; i++ ){
						var mc = list[i];
						//_root.test+="mc("+mc+")\n"
						var a = mc.a+this.shield.decal/100//(i/list.length)*6.28
						mc.x = this.x + Math.cos(a) * this.shield.ray;
						mc.y = this.y + Math.sin(a) * this.shield.ray;
						//mc.update();
						mc.waveUpdate();
					}
					
					if(list.length == 0 )delete this.shield;
					
				
				}
				
				break;
			
			
		}
		
		
		if( this.flash != undefined ) this.updateFlash();
		
		this.endUpdate();
	}

	// SHELL
	function turnShell(){
		this.shell.wr._rotation += this.turning*this.speedCoef;
	}
	
	function moveShell(){
		
		// BASE 
		var c = 0.95;
		for( var i=0; i<2; i++ ){
			var o = this.mvt[i]
			o.s = o.s*c + o.st*(1-c);
			o.d = ( o.d+o.s*Std.tmod )%628;
			
			if(!random(200/Std.tmod)){
				o.st = 5+random(5);
			}
		}
		var m = 50
		var w = this.game.mng.mcw/2 
		var h = 100
		this.x = w + Math.cos(this.mvt[0].d/100) * (w-m)
		this.y = h + Math.sin(this.mvt[1].d/100) * 40
		
		// SHELL

		
	}
	
	function moveBase(){
		
		
		var m = 5
		var v = 0.5
		if( this.base._x < -m )		this.vitx += v * Std.tmod;
		if( this.base._x > m )		this.vitx -= v * Std.tmod;
		if( this.base._y < -m )		this.vity += v * Std.tmod;
		if( this.base._y > m )		this.vity -= v * Std.tmod;
		
		var frict = Math.pow(0.95,Std.tmod)
		
		this.vitx *= frict;
		this.vity *= frict;
		
		//_root.test="("+this.vitx+","+this.vity+")"
		
		this.base._x += this.vitx * Std.tmod;
		this.base._y += this.vity * Std.tmod;	
	
	}
	
	
	// ORANGE
	function checkLook(){
		var h = this.game.getHeroTarget();
		var dx = this.x - h.x;
		var c = dx / (this.game.mng.mcw/2);
		c = Math.min( Math.max( -1, c ), 1 );
		
		var b= 20
		
		this.orange.regard.o1.gotoAndStop( Math.round( (b+1) + (c*b) ) )
		this.orange.regard.o2.gotoAndStop( Math.round( (b+1) - (c*b) ) )
			
		this.orange._rotation = -dx/8
		this.casque._rotation = this.orange._rotation*0.5
	}
	
	function moveOrange(){
		
		var chp = this.hp / this.hpMax
		 
		var vx = ( this.mvt.speed + (1-chp)*6 )*this.mvt.cox*this.mvt.sens ;
		this.x += vx*Std.tmod;
		
		this.mvt.dy = ( this.mvt.dy+this.mvt.vy*this.mvt.coy* Std.tmod )%628;
		var y = this.mvt.cy +Math.cos(this.mvt.dy/100)*this.mvt.ey;
		
		//_root.test="<>\n"
		if( this.mvt.ty != undefined){
			//_root.test+=" t != undefined\n"
			switch(this.step){
				case 11:
				case 21:
				case 24:
					this.mvt.ty = y
					if( Math.abs(this.y-this.mvt.ty)<2 ) delete this.mvt.ty;
					break;
			}

			this.y = this.y*0.9 + this.mvt.ty*0.1;
		}

		if( this.mvt.ty == undefined){
			this.y = y
		}
		
		if( this.x < this.ray ){
			this.x = this.ray;
			this.mvt.sens *= -1;
		}
		
		if( this.x > this.game.mng.mcw-this.ray ){
			this.x = this.game.mng.mcw-this.ray
			this.mvt.sens *= -1;
		}
		
		// FACE
		if( this.orange.hitTimer != undefined){
			if(this.orange.hitTimer<0){
				delete this.orange.hitTimer;
				this.orange.regard.gotoAndStop(1)
				this.orange.bouche.gotoAndStop(1)
			}else{
				this.orange.hitTimer -= Std.tmod;
			}
		}
		
		// MVT
		
		this.mvx = this.x - this._x
		this.mvy = this.y - this._y


		// VITX VITY
		this.orange._x += this.vitx
		this.orange._y += this.vity
		
		
	}
	
	function moveHands(){
		for(var i=0; i<2; i++ ){
			var h = this["h"+i]
			
			if(h.flPhys){
				// FORCES
				h.vx -= this.mvx/50
				h.vy -= this.mvy/50

				// GRAVITE
				h.vy += 0.5*Std.tmod;
				
				// TENSION
				//*
				var ta = this.orange._rotation*(Math.PI/180);
				var s = i*2-1
				var a = ta+(1-i)*3.14
				var p = {
					x:this.orange._x + Math.cos(a)*this.coudeRay,
					y:this.orange._y + Math.sin(a)*this.coudeRay
				}
				
				var dx = h.x - p.x
				var dy = h.y - p.y
								
				var dist = Math.sqrt( dx*dx + dy*dy ) 
				var a = Math.atan2( dy, dx )
				
				if(dist>16){
					var c = dist/16
					h.vx -= Math.cos(a)*c*0.8 * Std.tmod
					h.vy -= Math.sin(a)*c*0.8 * Std.tmod
					
					var max = 48
					if(dist>max){
						h.x = h.x*0.5 + (p.x + Math.cos(a)*max)*0.5
						h.y = h.y*0.5 + (p.y + Math.sin(a)*max)*0.5
						
					}
					
				}
				
				
				
				//*/
				
				h.vx *= this.game.frict;
				h.vy *= this.game.frict;
				
				h.x += h.vx * Std.tmod
				h.y += h.vy * Std.tmod
				
			}else{
				
				var dx = h.tx - h.x
				var dy = h.ty - h.y
		
				
				//if( h.tx == undefined )_root.test += ">>h.tx("+h.tx+")\n"
				
				h.x += Math.min( Math.max( -this.mvt.hs, dx*0.3 ), this.mvt.hs )
				h.y += Math.min( Math.max( -this.mvt.hs, dy*0.3 ), this.mvt.hs )
			
				
			}
			var dr = h.tr - h.r;
			while(dr>3.14)dr-=6.28
			while(dr<-3.14)dr+=6.28				
			h.r +=  dr*0.2;
			h._rotation = h.r/(Math.PI/180)
			
			h._x = h.x;
			h._y = h.y;				
				
		}		
	
	}
	
	function drawArms(){
		/*
		this.h0._alpha = 10
		this.h1._alpha = 10
		this.orange._alpha = 10
		this.casque._alpha = 10
		*/
		this.clear();
		var ta = this.orange._rotation*(Math.PI/180);
		for( var i=0; i<2; i++ ){
			var s = i*2-1
			
			var a = ta+(1-i)*3.14
			var p1 = {
				x:this.orange._x+Math.cos(a)*this.handRay,
				y:this.orange._y+Math.sin(a)*this.handRay
			}
			var a1 = {
				x:this.orange._x+Math.cos(a)*this.coudeRay,
				y:this.orange._y+Math.sin(a)*this.coudeRay
			}			
			var p2 = {
				x:this["h"+i].x,
				y:this["h"+i].y
			}
						
			this.lineStyle(8,0x65380E)
			this.moveTo( p1.x, p1.y )
			this.curveTo( a1.x, a1.y, p2.x, p2.y )
			
			this.lineStyle(6,0xF57C03)
			this.moveTo( p1.x, p1.y )
			this.curveTo( a1.x, a1.y, p2.x, p2.y )			
			
			
			
		}
		
		
	}
	
	
	function checkHeroCol(){
		var dx = this.game.hero.x - (this.x+this.base._x)
		var dy = this.game.hero.y - (this.y+this.base._y)
		var dist = Math.sqrt( dx*dx + dy*dy )
		if( dist < this.ray + this.game.hero.ray ){
			this.game.hero.hit(10);
		}
	}
	
	function checkHeroShot(){
		for( var i=0; i<this.game.hShotList.length; i++){
			var mc = this.game.hShotList[i]
			if( mc.flHit && this.hTest(mc.x,mc.y) ){
				this.tryToHit(mc)
			}
		}
	}
	
	function checkBehaviour(){
		if( this.specialCoolDown < 0 ){
			var chp = this.hp/this.hpMax
			
			switch(this.form){
				case 0:
					if( this.y< 100 && !random(100/Std.tmod) ){
						this.vity = 18;
						this.specialCoolDown = 80 
					}
					if(  !random(100/Std.tmod) ){
						this.initStep(2)
					}
					if(  chp<0.5 && !random(100/Std.tmod) ){
						this.initStep(3)
					};
					break;
				case 1:
					if(  !random(100/Std.tmod) ){
						this.initStep(12)
					}
					if(  !random(100/Std.tmod) ){
						this.initStep(13)
					}
					if(  !random(100/Std.tmod) ){
						this.initStep(14)
					}					
					break;
				case 2:
					if(  !random(100/Std.tmod) ){
						this.initStep(22)
					}
					if(  this.shield == undefined && !random(60/Std.tmod) ){
						this.initStep(23)
					}
					if(  !random(160/Std.tmod) ){
						this.initStep(24)
					}
					if(  !random(100/Std.tmod) ){
						this.initStep(25)
					}						
					break;						
			}
		}else{
			this.specialCoolDown -= Std.tmod
		}		
		
		
	}
	
	function checkShoot(){
		var o = this.shootInfo
		if( o.timer<0 ||  o.timer == undefined ){

			switch(o.type){
				case 0:
				case 1:		//{ SHELL MISSILE
					var initObj = {
						x:this.x+this.base._x,
						y:this.y+this.base._y
					}
					var mc = this.game.newBShot(initObj);
					mc.gotoAndStop(157);
					var h = this.game.getHeroTarget();
					var a = this.getAng({x:h.x-this.base._x,y:h.y-this.base._y});
					mc.vitx = Math.cos(a)*6.5;
					mc.vity = Math.sin(a)*6.5;
					mc.updateRotation();
					break;//}
				case 2:		//{ FLAME
					for( var i=0; i<2; i++ ){
						var initObj = {
							x:this.x+this["h"+i].x,
							y:this.y+28,
							vitx:this.mvx*0.8 + (random(20)-10)/20,
							vity:6//,
							//time:20,
							//behaviourId:19
						}
						var mc = this.game.newBShot(initObj);
						mc.gotoAndStop(158);
					}
					break;//}
				case 3:		//{ LASER
					for( var i=0; i<2; i++ ){
						if(this.shootInfo.hand == undefined || this.shootInfo.hand == i){
							var h = this["h"+i]
							var a = (h._rotation+90) * (Math.PI/180)

							//_root.test+="h("+h.x+","+h.y+")\n"
							var cx = Math.cos(a)
							var cy = Math.sin(a)
							var initObj = {
								x:this.x+h.x+cx*10,
								y:this.y+h.y+cy*10,
								vitx:cx*10,
								vity:cy*10
							}
							var mc = this.game.newBShot(initObj);
							mc.gotoAndStop(159);
							mc.killMargin = 100
						}
					}
					break;//}
				case 4:		//{ MULTIBALL
					var max = 18
					for( var i=0; i<max; i++ ){

							var h = this["h"+this.shootInfo.hand]
							var a = i/max * 6.28
							//var paire = //Math.floor(this.shootInfo.toShoot/2) == this.shootInfo.toShoot/2
							a += (this.shootInfo.toShoot%2)* (6.28/(max*2))
							var initObj = {
								x:this.x+h.x,
								y:this.y+h.y,
								vitx:Math.cos(a)*5,
								vity:Math.sin(a)*5
							}
							var mc = this.game.newBShot(initObj);
							mc.gotoAndStop(160);

					}
					break;//}
				case 5:		//{ NRJ

					var h = this.game.getHeroTarget();
					var dx = h.x - this.x;
					var dy = h.y - this.y;
					
					var a = Math.atan2(dy,dx)
					
					var cx = Math.cos(a)
					var cy = Math.sin(a)
					var initObj = {
						x:this.x+this.base._x+cx*this.handRay,
						y:this.y+this.base._y+cy*this.handRay,
						vitx:cx*3.5,
						vity:cy*3.5
					}
					var mc = this.game.newBShot(initObj);
					mc.vitRot = 4
					mc.gotoAndStop(161);
					break;//}
				case 6:		//{ HANDSHOT
					
					var h = this["h"+this.shootInfo.hand]
					h.vy += -1.5;
					var initObj = {
						x:this.x+h.x,
						y:this.y+h.y,
						vitx:2*(Math.random()*2-1),
						vity:4
					}
					var mc = this.game.newBShot(initObj);
					mc.vitRot = 4
					mc.gotoAndStop(161);				
					
					
					break;//}
					
			}

			if( o.toShoot == 0 || o.toShoot == undefined ){
				this.flShooting = false;				
			}else{
				o.toShoot--;
				o.timer += o.interval
			}	
			
			
			
		}else{
			this.shootInfo.timer-=Std.tmod;
		}
		
	}
		
	function tryToHit(mc){
		//_root.test+="tryToHit\n"
				
		if(mc.behaviourId == 10 ){
			mc.kill();
			return;
		}
		
		switch(this.form){
			case 0:
				//_root.test=" ! "+this.speedCoef+"\n"
				if( this.speedCoef > 1.5 ){
					this.klongShot(mc);
				}else{
					this.hit(mc);
					mc.onHit();
				}
				break;
			case 1:
				this.hit(mc);
				mc.onHit();
				break;
			case 2:
				if( this.step == 24 && this.shootInfo.step == 0 ){
					this.klongShot(mc);
				}else{
					this.hit(mc);
					mc.onHit();				
				}
				break;
				
		}
		mc.kill();
	}
	
	function klongShot(mc){
		var part = mc.klong();
		var dx = mc.x - this.x 
		var dy = mc.y - this.y
		var a = Math.atan2(dy,dx)
		part.vitx = Math.cos(a)*4 + this.vitx;
		part.vity = Math.sin(a)*4 + this.vity;
		part.timer = 20	
	}
	

	function hit(mc){
		this.hp--;
		this.updateHP()

		var coef = 1
		switch( mc.behaviourId ){
			case 8 : // HOMING NAMAZAN
				coef = 0.1 
				break;
		}
		
		switch(this.form){
			case 0:
				this.speedCoef += 4;
				var dx = this.x - mc.x
				this.vitx += dx/6
				this.vity += - 12*coef
				if( hp <= 0 ) this.initStep(9);
				break;
			case 1:
				this.vity += -1*coef
				this.vitx += (Math.random()*2-1)*1
				this.orange.regard.gotoAndStop(2)
				this.orange.bouche.gotoAndStop(2)
				this.orange.hitTimer = 6;
				if( hp <= 0 ) this.initStep(19);
				break;		
			case 2:
				this.vity += -2*coef
				this.vitx += (Math.random()*2-1)*2
				this.orange.regard.gotoAndStop(2)
				this.orange.bouche.gotoAndStop(2)
				this.orange.hitTimer = 6;
				if( hp <= 0 ) this.initStep(29);
				break;			
		}
		
		this.flash = { p:60, d:0 }

	}
	
	function updateHP(){
		var c = this.hp/this.hpMax
		
		var cr = Math.min(	(1-c)*2,	1 )
		var cg = Math.min(	c*2,	1 )
		
		var col = {
			r:255*cr,
			g:255*cg,
			b:0
		}
		//_root.test+=" updateHP("+col.r+","+col.g+","+col.b+") ("+this.shell.light+")\n\n"
		
		//this.shell.light
		//_root.test+="this.lightPath("+this.lightPath+") c("+c+")\n"
		miniwave.MC.setColor(this.lightPath,col)
	
	}
	
	function updateFlash(){
		this.flash.d = (this.flash.d+42*Std.tmod)%628
		this.flash.p += ( 1.5+Math.cos(this.flash.d/100)*8 )*Std.tmod
		var p
		if( this.flash.p > 100 ){
			p = 100;
			if(this.flash.p > 120){
				delete this.flash;
			}
		}else{
			p = this.flash.p;
		}
		miniwave.MC.setPColor(this,0xFF0000,p)
	}
	
	
	// ON 
	function onHeroKill(){
		//_root.test+="[BOSS] onHeroKill()\n"
		this.specialCoolDown = 100
		switch( this.step ){
			case 2:
			case 3:
			case 4:
				this.step = 1;
				break;
			case 12:
			case 13:
			case 14:
				this.initStep(11);
				break;
			case 22:
				this.initStep(21);
				break;				
		}	
	}
	
	//
	function hTest( x, y ){
		var rayCoef = 1
		if(this.form == 0 ) rayCoef = 1.3
		
		var d = this.getDist({x:x-this.base._x,y:y-this.base._y})
		return d < this.ray*rayCoef	
		
		
	}
	
	function kill(){
		this.game.nextLevel = this.game.level+1
		this.game.initStep(3)
		super.kill();
	}
	
	
	
	
	
	
//{	
}