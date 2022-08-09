class miniwave.sp.hero.Pastaga extends miniwave.sp.Hero {//}

	
	var speed:Number = 2;
	var coolDownSpeed:Number = 2.2;

	
	function Pastaga(){
		this.type = 2
		this.init();
	}
	
	function init(){
		this.hp = 2
		this.type = 2;
		super.init();
	}
	
	function update(){
		super.update();
		this.endUpdate();
	}
	
	function shoot(){
		this.game.mng.sfx.playSound( "sLaser2", 10 )
		//this.game.mng.sfx.setVolume(10, 50 )

		var mc = super.shoot();
		mc.x += 6
		mc.vity = -2.6
		var mc = super.shoot();
		mc.x -= 6
		mc.vity = -2.6
	}
	
	function bomb(){
		super.bomb();
		this.game.mng.sfx.playSound( "sMissileLaunch", 62 )
		var mc = super.shoot();
		mc.behaviourId  = 6
		mc.gotoAndStop(152)
		mc.vity = -2
		
	}
	
//{	
}