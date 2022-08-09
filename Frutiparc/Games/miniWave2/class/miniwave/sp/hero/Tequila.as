class miniwave.sp.hero.Tequila extends miniwave.sp.Hero {//}

	
	var speed:Number = 3;
	var coolDownSpeed:Number = 3.2;

	
	function Tequila(){
		this.type = 0
		this.init();
	}
	
	function init(){
		this.type = 0;
		super.init();
	}
	
	function update(){
		super.update();
		this.endUpdate();
	}
	
	function bomb(){
		super.bomb();
		this.game.mng.sfx.playSound( "sExplo2", 62 )
	
		var mc = this.game.newPart( "miniWave2SpPartOnde", undefined, true )
		mc.x = this.x;
		mc.y = this.y;
		mc.flGrav = false;
		mc.onde.gotoAndStop(2)
		mc._xscale = 200
		mc._yscale = 200
		this.game.cleanShots();
		
	}
	
	function shoot(){
		this.game.mng.sfx.playSound( "sLaser1", 10 )
		this.game.mng.sfx.setVolume(10, 50 )		
		super.shoot();
		
	}
	
//{	
}