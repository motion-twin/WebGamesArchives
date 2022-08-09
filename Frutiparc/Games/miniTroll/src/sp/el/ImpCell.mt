class sp.el.ImpCell extends sp.Element{//}

	
	var level:int;
	
	function new(){
		et = 3;
		link = "impCell";
		super();
	}

	function init(){
		super.init();

	}

	function setLevel(n){
		level = n;
		var free = downcast(skin)
		Mc.setColor( free.ball, Cs.impColorList[level][0] );
		Mc.setColor( free.bz, Cs.impColorList[level][1] );
		//Mc.modColor( free.bz, 1, 80 );
		
	}

	function update(){
		super.update();

	}
	
	function blast(){
		
		super.blast();
		if( Std.random(2) == 0 ){
			var dc = Cs.game.ts*0.5
			Cs.game.addImp(x+dc,y+dc,level);
			// FX
				// PENTACLE
				var pen = Cs.game.newPart("partPentacle",Game.DP_PART2)
				pen.x = x+dc
				pen.y = y+dc
				pen.fadeTypeList = [1]
				pen.timer = 16
				pen.init();
			
				for( var i=0; i<10; i++ ){
					var p = Cs.game.newPart("partRay",Game.DP_PART2)
					p.x = x+dc
					p.y = y+dc
					p.timer = 10 + Math.random()*10
					p.vitr = Math.random()*2
					p.skin._xscale = 20+Math.random()*300
					p.skin._rotation = Math.random()*360
					p.init();
				}
			
			//
			Cs.base.flash();
			kill();
		}else{
			
			
			quake();
			
		}
		
		//
	
	}	
	
	function getPart(a){
		var p = Cs.game.newPart("partStone",Game.DP_PART2);
		//var a = Math.random()*6.28
		var ca = Math.cos(a)
		var sa = Math.sin(a)
		p.x = x+(ca+1)*(Cs.game.ts*0.5)
		p.y = y+(sa+1)*(Cs.game.ts*0.5)	
		p.weight = 0.2+Math.random()*0.3
		p.flGrav = true;
		p.timer = 15+Math.random()*15
		p.fadeTypeList = [1]
		
		return p;
	}
	
	
	
//{	
}