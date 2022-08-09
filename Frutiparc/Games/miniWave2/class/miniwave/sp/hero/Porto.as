class miniwave.sp.hero.Porto extends miniwave.sp.Hero {//}

	
	var speed:Number = 3;
	var coolDownSpeed:Number = 5;
	
	function Porto(){
		this.type = 1
		this.init();
	}
	
	function init(){
		this.type = 1;
		super.init();
	}
	
	function update(){
		super.update();
		
		this.endUpdate();
	}
	
	function shoot(){
		this.game.mng.sfx.playSound( "sLaser3", 10 )
		//this.game.mng.sfx.setVolume(10, 60 )
		
		var mc = super.shoot();
		
		var a = ((random(80)-40)/100)-Math.PI/2
		mc.vitx  = Math.cos(a)*3
		mc.vity  = Math.sin(a)*3
	}
	
	
	function bomb(){
		super.bomb();
		this.game.mng.sfx.playSound( "sFlameBlop", 62 )
		
		var max = 12
		for(var i=0; i<max; i++){
			var mc = super.shoot();
			mc.gotoAndStop(151)
			var c = (((i/(max-1))*2)-1)
			var a = (77*c-157)/100
			var s = 5-Math.abs(c)*2
			mc.vitx = Math.cos(a)*s
			mc.vity = Math.sin(a)*s
			mc.updateRotation();
		}
	}
		
	
//{	
}