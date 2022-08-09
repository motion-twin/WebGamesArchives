class miniwave.sp.bads.Citrus extends miniwave.sp.Bads {//}

	var nbShoot:Number = 5
	
	var hp:Number;
	
	function Citrus(){
		this.init();
	}
	
	function init(){
		this.freq = 280
		this.coolDownSpeed = 3
		this.hp = 3
		this.type = 17;
		super.init();
	}
	
	function waveUpdate(){
		super.waveUpdate();
		if(hp==1)this.checkShoot();
		this.endUpdate();
	}
	
	function hit(){
		this.hp--;
		if( this.hp == 0 ){
			this.explode();
		}else{
			if(this.hp==1)this.dropPart(5);
			this.nextFrame();
		}
	}

	function shoot(){
		for( var i=0; i<nbShoot; i++ ){
			var mc = super.shoot();
			mc.vitx = 8*(random(200)-100)/100
			mc.vity = -(3+random(30)/10)
			mc.behaviourId = 3;
		}
		
	}	

	function explode(){
		super.explode(4)
	}
//{
}