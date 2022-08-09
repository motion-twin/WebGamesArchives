class spell.imp.Bind extends spell.Imp{//}

	var step:int;
	var timer:float;

	function new(){
		super();
	}
	
	function store(){
		super.store();
		//Manager.log("storeBind!!")
		
	}	
	
	function cast(){
		super.cast();
		//Manager.log("castBind!!")
		endActive();
		
	}
	
	function initStep(n){
		step = n 
		switch(step){
			case 0:
	
				
				break;
			case 1:

				break;
			case 2:

				break;
		}
	}
	
	function activeUpdate(){

		switch(step){
			case 0:

				break;

			case 1:

				break;
			
		}
	}
	
	function update(){
		super.update();

		var mc = Cs.game.line
		mc.lineStyle(1,0xFFFFFF,75)
		
		var p = Cs.game.piece;
		
		for( var i=0; i<p.list.length; i++ ){
			
			
			var pos = p.list[i]
			var x = Cs.game.getX(pos.x+p.x+p.cx+0.5)
			var y = Cs.game.getY(pos.y+p.y+p.cy+0.5)
			var trg = {x:x,y:y};
			
			mc.moveTo( caster.x, caster.y )	
			
			var dist = caster.getDist(trg)
			
			var lim = 80
			
			if( dist < lim ){
				var cx = (x+caster.x)*0.5
				var cy = (y+caster.y)*0.5
				cy += (lim*0.5)*(1-(dist/lim))
				mc.curveTo(cx,cy,x,y)
			}else{
				mc.lineTo(x,y)
			}

			if( dist>lim ){
				var a = caster.getAng(trg);
				var po = 1*(dist-lim)/lim
				caster.vitx += Math.cos(a)*po*Timer.tmod
				caster.vity += Math.sin(a)*po*Timer.tmod
				
			}
			

		}
		
		p.flBind = true;
		
	}
	
	function onUpkeep(){
		super.onUpkeep();
		dispel();
	}
	
	function dispel(){
		Cs.game.piece.flBind = false;
		super.dispel()
		//Manager.log("Dispel fils paralysants!")
	}
	
	function getName(){
		return "Fils Paralysants "
	}
	
	
//{	
}
