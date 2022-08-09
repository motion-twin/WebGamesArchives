class miniwave.sp.hero.Curaso extends miniwave.sp.Hero {//}

	
	var speed:Number = 3;
	var coolDownSpeed:Number = 3;
	
	function Curaso(){
		this.type = 4
		this.init();
	}
	
	function init(){
		this.type = 4;
		super.init();
	}
	
	function update(){
		super.update();
		this.endUpdate();
	}
	
	function shoot(){
		this.game.mng.sfx.playSound( "sLaser4", 10 )
		//this.game.mng.sfx.setVolume(10, 60 )	
		
		for(var i=0; i<2; i++){
			var mc = super.shoot();
			var x = this.x+((i*2)-1)*7
			
			mc.behaviourId = 9;
			mc.behaviourInfo = {
				x:this.x,
				d:314*(1-i),
				decalSpeed:20,
				decal:8
			}
			
			mc.x = x
			mc.vity = -3.5
		}
		
		
		
		

	}

	function bomb(){
		super.bomb();
		this.game.mng.sfx.playSound( "sZap", 62 )
		
		var initObj = {
			x:this.x,
			y:this.y-6,
			vitx:0,
			vity:-5,
			behaviourId:10
		}
		
		var mc = this.game.newHShot(initObj)
		mc.gotoAndStop(155)
	}
	
	
	
//{	
}