class miniwave.sp.Opt extends miniwave.Sprite {//}
	
	// CONSTANTES
	var speed:Number = 	2;
	var ray:Number = 	10;
	
	// VARIABLES
	var type:Number;
	var vitRot:Number;
	// REFERENCES
	var opt:MovieClip;
	var game:miniwave.game.Main
	
	function Opt(){
		this.init();
	}
	
	function init(){

		super.init();
		
		
		switch(this.type){
			case 0:
			case 1:
			case 2:
			case 3:
				this.gotoAndStop(1)
				var col = [0xF2D1AA,0xFFFFFF,0xFFF58A,0xA5F89E]
				miniwave.MC.setColor(this.opt.piece,col[this.type])
				break;
			case 4:
			case 5:
			case 6:
				
				this.gotoAndStop(2)
				this.opt.center.gotoAndStop(this.type-3)
				for(var i=0; i<4; i++){
					this.opt.atome.duplicateMovieClip("atome"+i,10+i)
					var mc = this.opt["atome"+i]
					mc._rotation = random(360)
					mc.gotoAndPlay(random(40)+1)
				}
				break;
			case 7:
			case 8:
			case 9:
				this.gotoAndStop(3)
				var col = [0xFF0000,0x00FF00,0x0000FF]
				miniwave.MC.setColor(this.opt.col,col[this.type-7])
				//this.vitRot = 8;
				break;
			case 10:
				this.gotoAndStop(4)
				this.opt.id = random(5)
				this.opt.gotoAndStop(this.opt.id+1)
			default:
				this.gotoAndStop(this.type)
		}
		
	}
	
	function update(){
		super.update();
		
		// CHECK HERO
		this.y += this.speed*Std.tmod

		// CHECK HERO TAKE
		var h = this.game.hero
		if(h._visible){
			var d = this.getDist(this.game.hero)
			if( d < h.ray+this.ray ){

				this.getBonus();
				this.kill();
			}
		}
		// CHECK OUT
		if( this.y-this.ray > this.game.mng.mch ){
			this.kill();
		}
		
		// SPECIFIC
		if(this.vitRot!=undefined)this._rotation+=this.vitRot;
		
		
		this.endUpdate();
	}

	function getBonus(){
		this.game.mng.sfx.playSound( "sMetalHit", 14 )
	
		switch(this.type){
			case 0:
				this.game.incCred(1)
				break;
			case 1:
				this.game.incCred(5)
				break			
			case 2:
				this.game.incCred(10)
				break				
			case 3:
				this.game.incCred(50)
				break		
			case 4:
			case 5:
			case 6:
				var warpList=[5,10,20]
				this.game.setWarp(warpList[this.type-4])
				break;

			case 7: //{ CARD RED : HANABI
				var max = 32;
				for( var i=0; i<max; i++ ){
					var a = 6.28*i/max
					var o = {
						x:this.x,
						y:this.y,
						vitx:Math.cos(a)*5,
						vity:Math.sin(a)*5,
						vitRot:10,
						time:60+random(60)
					}
					var mc = this.game.newHShot(o)
					mc.gotoAndStop(163)
					mc.behaviourId = 24
					mc.shot.gotoAndPlay(random(10)+1)
					
				}			
				break; //}
			case 8: //{ CARD GREEN : HOMING

					var o = {
						x:this.x,
						y:this.y,
						vitx:0,
						vity:0,
						vitRot:10,
						killMargin:200,
						flIndestructible:true,
						time:200+random(200)
					}
					var mc = this.game.newHShot(o);
					mc.gotoAndStop(164);
					mc.behaviourId = 8;
			
				break; //}	
			case 9: //{ CARD BLUE : WAVE

					var o = {
						x:this.game.mng.mcw/2,
						y:this.y,
						vitx:0,
						vity:-10,
						flIndestructible:true

					}
					var mc = this.game.newHShot(o);
					mc.gotoAndStop(165);
					mc.behaviourId = 25;
			
				break; //}
			case 10: //{ CARD BLUE : WAVE
				this.game.addLife( this.opt.id+1 )
				break; //}						
		}
	}
	
	function kill(){
		this.game.removeFromList( this, this.game.optList );
		super.kill();
	}
	
		
//{	
}