class miniwave.sp.Bads extends miniwave.Sprite {//}
	
	//var startSpeed:Number = 6;
	
	
	var flWave:Boolean;
	var flReady:Boolean;
	
	var type:Number;
	var lineId:Number;
	
	var freq:Number;
	var ty:Number;
	var ray:Number;
	var waveId:Number;
	//var rot:Number;
	
	var coolDownSpeed:Number;
	var coolDown:Number;
	
	var wpTimer:Number;
	var wayPoint:Object;
	
	function Bads(){
		this.init();
	}
	
	function init(){
		super.init();
		this.flReady = false;
		this.stop();
	}
	
	function initDefault(){
		super.initDefault();
		if( this.flWave == undefined ) this.flWave = true;
		if( this.freq == undefined ) this.freq = 200;
		if( this.coolDownSpeed == undefined ) this.coolDownSpeed = 5;
		if( this.coolDown == undefined ) this.coolDown = 0;
		if( this.ray == undefined ) this.ray = 10;
	}
	
	function waveUpdate(){
		super.update();
		
		//this._rotation = this.game.waveSens*5
		
		//_root.test += "-"+this.ty+"\n"
		//_root.test += " -"+this.game.waveSpeed+"\n"
		//_root.test += " -"+this.game.waveSens+"\n"
		
		if(this.flWave){
			// MOVE
			this.x += this.game.waveSpeed * this.game.waveSens;
			// CHECKSIDE
			var w = this.game.badsSize/2
			if( this.game.waveSens < 0 && this.x < w  ){
				//this.x = w; provoque un décalage ?
				this.hitSide();
			}
			if( this.game.waveSens > 0 && this.x >  this.game.mng.mcw-w){
				//this.x = this.game.mng.mcw-w; provoque un décalage ?
				this.hitSide();			
			}
			// CHECK BOTTOM
			if( this.y > this.game.mng.mch-this.ray ){
				this.game.hero.explode();
			}
			
		}
	
		this.checkHeroShot(this.x,this.y);
		if( this.y+this.ray > this.game.hero.y-this.game.hero.ray ){
			this.checkHeroCol(this.x,this.y);
		}

	}
	
	function checkHeroCol( x, y ){
		var h = this.game.hero
		var difx = h.x - x;
		var dify = h.y - y;
		var limit = 1.2*(this.ray+h.ray)/2
		if( Math.abs(difx)< limit && Math.abs(dify)< limit ){
			this.hit();
			h.hit();
		}
		
	}
	
	function checkHeroShot( x, y ){
		for( var i=0; i<this.game.hShotList.length; i++){
			var mc = this.game.hShotList[i]
			if( mc.flHit && this.hTest(mc.x,mc.y) ){
				mc.onHit();
				//mc.kill();
				this.hit();				
			}
		}
	}
	
	function checkShoot(){
		if(this.coolDown<=0){
			if(!random(this.freq/Std.tmod)){
				this.coolDown = 100
				this.shoot();
			}
		}		
	};
	//
	function update(){
		switch(this.game.step){
			case 1 :	// CALCUL A SIMPLIFIER
				
				if(this.wpTimer<0){
					
					if( this.wayPoint.dx > 0 ) this._rotation = 5;
					if( this.wayPoint.dx < 0 ) this._rotation = -5;					
								
					if( this.wayPoint.dist < this.game.gridInfo.ss ){
						this.x = this.wayPoint.x
						this.y = this.wayPoint.y
						
						if( this.wayPoint.id == this.waveId ){
							this.flReady = true;
							this.ty = this.y
							this._rotation = 0;
						}else{
							this.nextWayPoint();
						}
						
					}else{
						this.x += this.wayPoint.dx
						this.y += this.wayPoint.dy
						this.wayPoint.dist -= this.game.gridInfo.ss
					}
				}else{
					this.wpTimer -= Std.tmod
				}
				this.checkHeroShot();
				this.endUpdate();
				break;
			case 2 :
				// COOLDOWN
				if(this.coolDown>0){
					this.coolDown -= this.coolDownSpeed
				}
				if(this.flWave){
					// SLIDEDOWN
					var dy = (this.ty-this.y)*0.3;
					this.y += Math.min( dy, 4 )*Std.tmod;
				}
				break;
		}
	}
	//
	function nextWayPoint( id ){
		if( this.wayPoint == undefined ){
			this.wayPoint = {id:0}
		}else{
			do{
				this.wayPoint.id++
				var next = this.game.gridInfo.list[this.lineId][this.wayPoint.id]
			}while( next.e && this.wayPoint.id!=this.waveId )
		}
		
		if( id != undefined ) this.wayPoint.id = id;
		
		var data = this.game.gridInfo.list[this.lineId][this.wayPoint.id]
		this.wayPoint.x = data.x
		this.wayPoint.y = data.y
		
		var difx = this.wayPoint.x - this.x
		var dify = this.wayPoint.y - this.y	
		var dist = Math.sqrt( difx*difx + dify*dify );
		
		var a = Math.atan2( dify, difx )
		
		this.wayPoint.dx = Math.cos(a)*this.game.gridInfo.ss
		this.wayPoint.dy = Math.sin(a)*this.game.gridInfo.ss
		this.wayPoint.dist = dist
	}
	
	function hitSide(){
		this.game.flChangeSens = true;	
	}

	function explode(nbPart){
		var link

		switch(random(3)){
			case 0: link = "sPop0"; break;
			case 1: link = "sPop1"; break;
			case 2: link = "sPop2"; break;
		}
		
		this.game.mng.sfx.playSound( link, 11 )
		//this.game.mng.sfx.setVolume(10, 50 )		
		
		if( nbPart == undefined ) nbPart = 5;
		for( var i=0; i<nbPart; i++ ){
			this.dropPart(i+1)
		}
		this.game.incScore(this.game.mng.badsInfo[this.type].value)
		this.game.mng.fc[0].$badsKill[this.type]++;
		this.kill();
	}
	
	function dropPart(frame){
		var initObj = {
			x:this.x,
			y:this.y,
			vitx:8*(random(200)-100)/100,
			vity:8*(-random(100))/100,
			timer:16 + random(14),
			vitr:10*(random(200)-100)/100			
		}
		var mc = this.game.newPart("miniWave2SpPartBads",initObj);
		mc.gotoAndStop(this.type+1);
		mc.skin.gotoAndStop(frame);	
	}
	
	function hit(){
		this.explode();
	}
	
	function kill(){
		this.game.removeFromList( this, this.game.badsList );
		this.game.toKill--;
		//this.game.checkEnd();
		super.kill();
	}
	
	function shoot(){
		this.game.mng.sfx.playSound( "sLaser5", 12 )
		this.game.mng.sfx.setVolume( 12, 20 )
		var initObj = {
			x:this.x,
			y:this.y,
			vitx:0,
			vity:2
		}
		var mc = this.game.newBShot(initObj)
		mc.gotoAndStop(10+this.type)
		return mc;
	}
	
	function startWaveAttack(){
		delete this.wayPoint;
	}
	
	function reset(t){
		this.flReady = false;
		this.nextWayPoint(this.waveId);
		this.wpTimer = t;
	}
	
	function warp(){
		var initObj ={
			x:this.x,
			y:this.y,
			vitx:0,
			vity:0,
			weight:-0.5
		}
		var mc  = this.game.newPart("miniWave2SpPartBadsWarp",initObj)
		mc._rotation = random(360)
		mc._xscale = 70;
		mc._yscale = 70;
		this.kill()
		
	}
	
//{	
}