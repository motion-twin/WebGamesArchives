class miniwave.sp.Saucer extends miniwave.Sprite {//}

	static var margin:Number = 40;
	var sens:Number;
	var speed:Number;
	
	
	// CAST
	var game:miniwave.game.Main
	
	
	
	function Saucer(){
		this.init();
	}
	
	function init(){
		//_root.test+=" init Saucer("+this.sens+")\n"
		super.init();
		
		this.game.mng.sfx.loop( "sSaucer", 57 )
		//this.mng.music.setVolume( 1, 60 )
		
	}	
	
	function update(){
		super.update();
		this.x += this.speed*this.sens
		
		if( this.x+margin < 0 || this.x-margin > this.game.mng.mcw ){
			this.kill();
		}
		this.checkHeroShot();
		
		this.endUpdate();
	}
	
	function checkHeroShot(){
		for( var i=0; i<this.game.hShotList.length; i++){
			var mc = this.game.hShotList[i]
			if( mc.flHit && this.hTest(mc.x,mc.y) ){
				mc.onHit();
				mc.kill();
				this.game.genOption(this.x,this.y)
				this.explode();
			}
		}
	}
	
	function explode(){
		this.game.mng.sfx.playSound( "sPop0", 11 )
		for( var i=0; i<8; i++ ){
			this.dropPart(i+1)
		}
		//var score =  Math.min( Math.pow(2,Math.floor(this.speed))*50, 1000 )
		this.game.incScore( 200 )
		this.game.mng.fc[0].$saucerKill++;
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
		mc.gotoAndStop(100);
		mc.skin.gotoAndStop(frame);
	}
		
	function kill(){
		this.game.mng.sfx.stop( 57 )
		this.game.removeFromList( this, this.game.saucerList );
		super.kill();
	}
	
//{
}