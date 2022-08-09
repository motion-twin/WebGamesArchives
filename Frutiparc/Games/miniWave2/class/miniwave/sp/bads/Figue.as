class miniwave.sp.bads.Figue extends miniwave.sp.Bads {//}

	var shotTime:Number = 48
	var holdTime:Number = 12
	
	var flShooting:Boolean;
	var timer:Number;
	var shot:MovieClip;
	
	function Figue(){
		this.init();
	}
	
	function init(){
		this.freq = 200;
		this.coolDownSpeed = 0.5;
		this.timer = 0;
		this.flShooting = false;
		this.type = 11;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		if(this.flShooting){
			if(this.timer<=0){
				this.removeShot();
			}else if(this.timer<=this.holdTime){
				this.shot.ray._xscale = this.timer*(100/this.holdTime)
			}else if(this.timer<=this.shotTime-this.holdTime){
				this.shot.ray._xscale = 100
				var difx = this.game.hero.x-this.x
				if(Math.abs(difx)<this.game.hero.ray)this.game.hero.hit();
			}else{
				this.shot.ray._xscale = (this.shotTime-this.timer)*(100/this.holdTime)			
			}
		}else{
			this.checkShoot();
		}
		this.endUpdate();
	}
	
	function endUpdate(){
		super.endUpdate();
		if(this.flShooting){
			this.shot._x = this.x
			this.shot._y = this.y
		}
	}
	
	function update(){
		super.update();
		this.timer -= Std.tmod
		
	}
	
	function shoot(){
		this.shot = this.game.newMovie("shotFigue",{},this.game.dp_underPart)
		this.shot.ray._yscale = this.game.mng.mch - this.y
		this.shot.ray._xscale = 0
		//_root.test+="this.shot("+this.shot+")\n"
		this.timer = this.shotTime;
		this.flShooting = true;
	}
	
	function kill(){
		if(this.flShooting)this.shot.removeMovieClip();
		super.kill();
	}

	function reset(t){
		super.reset(t);
		if(this.flShooting)this.removeShot();
	}

	function removeShot(){
		this.shot.removeMovieClip();
		this.flShooting = false;	
	}
	
//{
}