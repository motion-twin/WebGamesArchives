class miniwave.sp.hero.Cherry extends miniwave.sp.Hero {//}

	
	var speed:Number = 3;
	var coolDownSpeed:Number = 3;

	var bossTimer:Number;
	
	var flLaser:Boolean;
	var laserTimer:Number;
	var laser:MovieClip;
	
	function Cherry(){
		this.type = 5
		this.init();
	}
	
	function init(){
		this.type = 5;
		this.hp = 2;
		super.init();
	}
	
	function update(){
		super.update();
		
		if(this.flLaser){
			this.laserTimer -= Std.tmod
						
			this.laser.x = this.x
			this.laser.y = this.y
			
			var list = this.game.badsList
			for( var i=0; i<list.length; i++ ){
				var mc = list[i];
				if( Math.abs(mc.x-this.laser.x)<this.laser.gfx._width/2){
					mc.hit();
				}
			}					
			
			if( this.game.step == 4 ){
				if( this.bossTimer < 0){
					if( Math.abs(this.game.boss.x-this.laser.x) < (this.game.boss.ray+this.laser.gfx._width/2) ){
						this.game.boss.hit();
						this.bossTimer = 2.5;
					}				
				}else{
					this.bossTimer -= Std.tmod
				}
				

				
			}
			
			if( this.laserTimer < 0 ){
				this.flLaser = false;
				this.speed = 3
				this.laser.kill();
			}else if(this.laserTimer>10){
				var scale = Math.min(40-this.laserTimer,10)*10
				this.laser.gfx._xscale = scale
				this.laser.eclat._xscale = scale
			}else{
				this.laser.gfx._xscale = this.laserTimer*10
				this.laser.eclat._xscale = this.laserTimer*10
			}
			
			
			
			
		}
		
		this.endUpdate();
	}
	
	function bomb(){
		super.bomb();
		this.game.mng.sfx.playSound( "sBigLaser", 62 )
		var initObj = {
			x:this.x,
			y:this.y,
			flGrav:false
		};
		this.laser = this.game.newPart("miniWave2SpPartCherryLaser",initObj,true)

		this.laser.gfx._xscale = 0;
		this.laser.gfx._yscale = this.game.mng.mch;
		this.laser.eclat._xscale = 0;
		
		this.speed = 1;
		this.laserTimer = 40;
		this.bossTimer = 0;
		this.flLaser = true;
	}
	
	function shoot(){
		
		super.shoot();
		if( this.hp == 1 ){
			this.game.mng.sfx.playSound( "sLaser7", 10 )
			for( var i=0; i<2; i++){
				var s = ((i*2)-1)
				var initObj = {
					x:this.x+s*5,
					y:this.y-6,
					vitx:s*0.5,
					vity:-2.5,
					flStandardHeroShot:true
				}
				var mc = this.game.newHShot(initObj)
				mc.gotoAndStop(156)		
			}
		}else{
			this.game.mng.sfx.playSound( "sLaser6", 10 )
		}
	}
	
	function hit(){
		super.hit();
		if(this.hp==1){
			this.coolDownSpeed = 2
			this.gotoAndStop(2);
		}
	}
	
	function kill(){
		if(this.flLaser) this.laser.kill();		
		super.kill();
	}
	

	
	
//{	
}

