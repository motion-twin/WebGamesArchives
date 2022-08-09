class miniwave.sp.Hero extends miniwave.Sprite {//}

	
	// PARAMETRES
	var moveLine:Number;
	var hp:Number;
	var speed:Number;
	var coolDownSpeed:Number;
	//var bombCoolDownSpeed:Number;
	var ray:Number;
	
	// VARIABLES
	var flBomb:Boolean;
	var flLine:Boolean;
	var flEMP:Boolean;
	var type:Number;
	var coolDown:Number;
	//var bombCoolDown:Number;
	var step:Number;
	var sens:Number;
	
	
	var EMPTimer:Number;
	var blindTimer:Number;
	
	var key:Array;
	
	var newShield:Object;
	//var vity:Number;
	
	// REFERENCE
	var mcEMP:MovieClip;
	
	// CAST
	var game:miniwave.game.Main
	
	
	function Hero(){

	}
	
	function init(){

		
		this.key = this.game.mng.fc[1].$key
		
		this.flLine = false;
		this.coolDown = 0;
		//this.bombCoolDown = 0;
		this.flBomb = true;
		this.sens = 1;
		this.newShield = {t:160,d:0};
		this.flEMP = false;
		this.stop();
		super.init();
		
		
		
		
	}
	
	function initDefault(){
		super.initDefault();
		if( this.hp == undefined )			this.hp = 1;
		if( this.speed == undefined )			this.speed = 3;
		if( this.coolDownSpeed == undefined )		this.coolDownSpeed = 4;
		//if( this.bombCoolDownSpeed == undefined )	this.bombCoolDownSpeed = 1;
		if( this.ray == undefined )			this.ray = 8;
		if( this.moveLine == undefined )		this.moveLine = 11;
	}
	
	function update(){
		super.update();
		if(!this.flLine){
			var ty =  this.game.mng.mch-this.moveLine;
			var dy = this.y - ty;
			this.y -= Math.min( 2 , dy*0.3 )
			if(Math.abs(dy)<0.5){
				this.y = ty;
				this.flLine = true;
			}
		}
		
		this.coolDown -= this.coolDownSpeed*Std.tmod;
		//this.bombCoolDown -= this.bombCoolDownSpeed*Std.tmod;
		
		this.control();
		
		// COLLISIONS TIRS
		for( var i=0; i<this.game.bShotList.length; i++ ){
			var shot:miniwave.sp.Shot = this.game.bShotList[i];
			var difx = shot.x - this.x;
			var dify = shot.y - this.y;
			if( Math.abs(difx)<this.ray && Math.abs(dify)<this.ray ){
				if(shot.flHit){
					this.hit();
				}
				shot.onHit();
			}
		}
		
		// RETOUR SUR TERRE
		var ty =  this.game.mng.mch-this.moveLine;
		if( this.y < ty )this.y += 0.8*Std.tmod;
		
		// EMP COOLDOWN
		if( this.flEMP ){
			if( this.EMPTimer > 0 ){
				this.EMPTimer -= Std.tmod
				if( this.EMPTimer < 20 ) this.mcEMP._alpha = this.EMPTimer*5;
			}else{
				this.flEMP = false;
				this.mcEMP.removeMovieClip();
			}
		}
		
		// BLIND COOLDOWN
		if( this.blindTimer != undefined ){
			this.blindTimer -= Std.tmod
			if( this.blindTimer < 0 ){
				this.sens = 1;
				delete this.blindTimer;
			}
		}
		
		// NEW TIMER
		if( this.newShield != undefined ){
			

			
			if( this.newShield.t > 0 ){
				this.newShield.t -= Std.tmod
				var inc = 50
				if( this.newShield.t < 30 ) inc+=50
				this.newShield.d = ( this.newShield.d+inc*Std.tmod )%628
				//_root.test = "("+this.newShield.t+","+this.newShield.d+")\n"
				miniwave.MC.setPColor(this,0xFFFFFF,50+Math.cos(this.newShield.d/100)*50)				
			}else{
				delete this.newShield;
				miniwave.MC.setPColor(this,0xFFFFFF,100)
			}
			
		}
		
		// CHECKWARP
		if( this.x > this.game.mng.mcw ){
			var initObj = {
				x:this.game.mng.mcw+6,
				y:this.y + (Math.random()*2-1)*this.ray,
				vitx:-(3+random(6)),
				vity:(Math.random()*2-1)*4,
				vitr:random(30)/10,
				flGrav:false,
				timer:30			
			}
			var mc = this.game.newPart("miniWave2SpPartWarpStar",initObj);
			
			if( this.x > this.game.mng.mcw+this.ray ){
				this.game.setWarp(100);
				this.game.addLife(this.type)
				this.kill();
			}
		}
		
		
	}
	
	function control(){
		
		if( Key.isDown(this.key[0]) ){
			this.x = Math.max( this.x - this.speed*this.sens*Std.tmod, this.game.shipBounds.min+this.ray )
		}
		if( Key.isDown(this.key[1]) ){
			this.x = Math.min( this.x + this.speed*this.sens*Std.tmod, this.game.shipBounds.max-this.ray )
		}
		if( this.coolDown<=0 && Key.isDown(this.key[2]) && !this.flEMP && this.shootOK() ){
			this.shoot();
		}
		
		if( this.flBomb && Key.isDown(this.key[3]) && this.shootOK() ){
			this.bomb();
		}		
		
		
	}
	
	function shoot(){
		//this.game.mng.sfx.playSound( "sLaser1", 10 )
		//this.game.mng.sfx.setVolume(10, 50 )
		
		this.coolDown = 100;
		var initObj = {
			x:this.x,
			y:this.y-6,
			vitx:0,
			vity:-3,
			flStandardHeroShot:true
		}		
		var mc = this.game.newHShot(initObj)
		mc.gotoAndStop(this.type+1)
		return mc;
	}
	
	function bomb(){
		//this.bombCoolDown = 100;
		this.flBomb = false;
	}
	
	function hit(power){
		if(power == undefined ) power = 1;
		if( this.newShield == undefined ){
			this.hp -= power;
			var mc = this.game.newPart( "miniWave2SpPartOnde", undefined, true )
			mc.x = this.x;
			mc.y = this.y;
			mc.flGrav = false;
			mc.onde.gotoAndStop(1)
			if(hp<=0){
				this.explode();
				mc._xscale = 150
				mc._yscale = 150			
			}else{
				this.newShield = {t:80,d:0};
				mc._xscale = 50
				mc._yscale = 50		
			}
		}
	}
	
	function hitEMP( deg ){
		if( this.flEMP ){
			this.EMPTimer += deg
		}else{
			this.flEMP = true
			this.EMPTimer = deg
			this.attachMovie("mcEMP","mcEMP",40)
		}
	}
	
	function explode(){
		this.game.mng.sfx.playSound( "sBlast0", 14 )
		for( var i=0; i<5; i++ ){
			var mc = this.game.newPart("miniWave2SpPartHero");
			mc.gotoAndStop(this.type+1);
			mc.skin.gotoAndStop(i+1);
			mc.x = this.x;
			mc.y = this.y;
			mc.vitx = 8*(random(200)-100)/100;
			mc.vity = 8*(-random(100))/100;
			mc.timer = 16 + random(14)
			mc.vitr = 10*(random(200)-100)/100;
		}		
		this.death();
	}
	
	function death(){
		this.game.onHeroKill();
		this.kill();
	}
	
	function kill(){
		delete this.game.hero;
		super.kill();
	}
	
	function blind(t){
		if( t == undefined ) t = 100;
		this.blindTimer = t;
		this.sens = -1
	}
	
	function shootOK(){
		return ( this.game.step == 1 || this.game.step == 2 || this.game.step == 4 )
	}
	
//{	
}




















