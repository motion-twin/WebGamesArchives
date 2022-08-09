class miniwave.sp.hero.Manzana extends miniwave.sp.Hero {//}

	
	var speed:Number = 4.5;
	var coolDownSpeed:Number = 3.6;

	
	function Manzana(){
		this.type = 3
		this.init();
	}
	
	function init(){
		this.type = 3;
		super.init();
	}
	
	function update(){
		super.update();
		this.endUpdate();
	}
	
	function shoot(){
		this.game.mng.sfx.playSound( "sLaser0", 10 )
		this.game.mng.sfx.setVolume(10, 40 )
		var mc = super.shoot()
		mc.vity = -6
	}
	
	function bomb(){
		super.bomb();
		this.game.mng.sfx.playSound( "sMissile", 62 )
		var max = 8
		for(var i=0; i<max; i++){
			
			var c = (((i/(max-1))*2)-1)
			var a = (77*c-157)/100
			
			var initObj = {
				x:this.x,
				y:this.y-6,
				vitx:Math.cos(a)*4,
				vity:Math.sin(a)*4,
				behaviourId:8
			}
			
			var mc = this.game.newHShot(initObj)
			mc.gotoAndStop(154);
			mc.killMargin = 200

		}
	}
	
	
//{	
}