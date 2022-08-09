class sp.el.Stone extends sp.Element{//}

	var life:int;

	function new(){
		et = 2;
		link = "stone";
		//flFront = true;
		super();
	}

	function init(){
		super.init();
	}

	function setLife(n){
		var flInit = false;
		if(life == null)flInit = true;
		life = n;
		if(life==0){
			explode();
		 	kill();
		}else{
			if(!flInit){
				for( var i=0; i<3; i++){
					var p = getPart(Math.random()*6.28)
					p.skin.gotoAndStop(string(Std.random(10)+1))
					p.scale = 20+Math.random()*40
					p.init();
					
				}			
				quake();
			}
			skin.gotoAndStop(string(life))
		}
	}

	function update(){
		super.update();

	}
	
	function blast(){
		
		super.blast();
		setLife(life-1)
	
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
	
	function explode(){
		super.explode();
		for( var i=0; i<10; i++){
			var a = Math.random()*6.28
			var p = getPart(a)
			var speed = 0.3+Math.random()*2
			p.vitx = Math.cos(a)*speed
			p.vity = (Math.sin(a)-0.5)*speed
			p.skin.gotoAndStop(string(1+i))
			p.init();
		}	
	}
	
//{	
}