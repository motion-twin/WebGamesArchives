class miniwave.sp.bads.Cassis extends miniwave.sp.Bads {//}

	
	var tokenList:Array;
	var depthRun:Number;
	var decal:Number;
	
	function Cassis(){
		this.init();
	}
	
	function init(){
		this.freq = 400
		this.coolDownSpeed = 10
		this.type = 46;
		super.init();
		this.tokenList = new Array();
		this.decal = 0;
		this.depthRun = 0;
	}
	
	function waveUpdate(){
		super.waveUpdate();
		this.checkShoot();
		
		if(!random(60/Std.tmod) ){
			var d = this.depthRun++;
			this.attachMovie("cassisToken","token"+d,d)
			var mc = this["token"+d]
			//_root.test+="mc("+mc+")\n"
			this.tokenList.push(mc)
		}
		
		if(this.tokenList.length > 10 ){
			this.shoot();
		}
		
		this.moveToken();
		this.endUpdate();
	}
	
	function moveToken(){
		var max = this.tokenList.length
		this.decal = (this.decal+12)%628
		for( var i=0; i<max; i++ ){
			var mc = this.tokenList[i]
			var a = this.decal+628*i/max
			mc.a = a/100
			mc._x = Math.cos(mc.a)*12
			mc._y = Math.sin(mc.a)*12
			
			
		}		
	}
	
	function shoot(){
		while( this.tokenList.length > 0 ){
			var t  = this.tokenList[0]
			var mc = super.shoot()
			
			mc.x = this.x + t._x
			mc.y = this.y + t._y
			
			
			
			/*  DIRECT
			var h = this.game.getHeroTarget()
			var a = this.getAng(h)
			mc.vitx = Math.cos(a)*8
			mc.vity = Math.sin(a)*8
			//*/
			
			mc.vitx = Math.cos(t.a)*4
			mc.vity = Math.sin(t.a)*4
			
			if( mc.vitx == undefined ||  mc.vity == undefined || mc.x == undefined ||  mc.y == undefined ){
				_root.test+="XXX\nmc.vitx("+mc.vitx+")\nmc.vity("+mc.vity+")\nmc.x("+mc.x+")\nmc.y("+mc.y+")\n"
			}
			
			mc.behaviourId = 21
			mc.behaviourInfo = { timer:14 }
			
			
			t.removeMovieClip();
			this.tokenList.shift();
			
		}
		
		
	}

	

//{
}