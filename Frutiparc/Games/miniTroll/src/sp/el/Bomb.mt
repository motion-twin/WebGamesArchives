class sp.el.Bomb extends sp.Element{//}

	// CONSTANTE
	static var RAY = 64

	
	var life:int;
	
	function new(){
		et = 4;
		link = "bomb";
		flFront = true;
		super();
	}

	function init(){
		super.init();
	}

	function update(){
		super.update();
	}
	
	function blast(){
		super.blast();
		var list = Cs.game.pList
		for( var i=0; i<list.length; i++ ){
			var f = list[i]
			var dist = getDist(f);
			if( dist < RAY ){
				var a = getAng(f)
				var c = 1-(dist/RAY)
				f.harm(c*200);
				f.vitx += Math.cos(a)*c*20
				f.vity += Math.sin(a)*c*20
			}
		}
		
		// PART
		var dec = Cs.game.ts*0.5
		var max = 14
		for( var i=0; i<14; i++ ){
			var p = Cs.game.newPart("partFlameBall",null)
			var a = Math.random()*6.28
			var ca = Math.cos(a)
			var sa = Math.sin(a)
			p.x = x+(ca+1)*dec
			p.y = y+(sa+1)*dec
			var sp = Math.random()*2
			p.vitx  = ca*sp
			p.vitx  = ca*sp
			p.weight = -(0.2+Math.random()*0.3)
			p.flGrav = true;
			p.timer = 8+Math.random()*20
			p.scale = 100+Math.random()*100
			p.skin.gotoAndPlay(string(1+int((1-(i/max))*6)))
			p.fadeTypeList = [1]
			p.init();
			
		}
		
		
		var p = Cs.game.newPart("partBombEplosion",null)
		p.x = x+dec
		p.y = y+dec
		p.init();
		
		
		kill();
	}
//{	
}


	
