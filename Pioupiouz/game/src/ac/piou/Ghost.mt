class ac.piou.Ghost extends ac.Piou{//}


	
	
	function new(x,y){
		super(x,y)
	}
	
	function init(){
		super.init();
		
		piou.root.gotoAndStop("fall")
		flExclu = true
		var fl = new flash.filters.GlowFilter();
		fl.blurX = 10
		fl.blurY = 10
		fl.strength= 3
		fl.color = 0xFFFFFF
		fl.knockout = true
		downcast(piou.root).sub.filters = [fl];
	
		timer = 5
		Std.attachMC(piou.root,"mcPiouFader",10)
		
		var max = 14
		var ray = 4
		for( var i=0; i<max; i++ ){
			var a = i/max * 6.28
			var ca = Math.cos(a)
			var sa = Math.sin(a)
			var sp = 2
			var p = Cs.game.newPart("partLightFlip")
			p.timer = 14
			if(i%2==0){
				sp+=1
				p.timer += 5
			}
			
			p.x = piou.x+ca*ray
			p.y = piou.y+sa*ray - Piou.RAY
			p.vx = ca*sp
			p.vy = sa*sp + 0.5
			p.fadeType = 0
		}
		
	}
	
	function update(){
		super.update();
		piou.vy += Piou.WEIGHT
		if( timer<0 && Level.isFree(piou.x,piou.y) ){
			downcast(piou.root).sub.filters = []
			piou.updateColor(piou.root)
			Std.attachMC(piou.root,"mcPiouFader",10)
			piou.fall();
			kill();
		}
	}	
	
	
//{
}