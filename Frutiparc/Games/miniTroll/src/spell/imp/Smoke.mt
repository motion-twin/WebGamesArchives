class spell.imp.Smoke extends spell.Imp{//}

	var step:int;
	var timer:float;

	var pos:{x:float,y:float}
	var level:int;
	
	function new(){
		super();
	}
	
	function cast(){
		super.cast();

		pos = { x:caster.x, y:caster.y };
		level = imp.level;
		newCloud()
		endActive();
		caster.kill();
		
		
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
		var p = Cs.game.piece
		
		for( var i=0; i<p.list.length; i++ ){
			var pos = p.list[i]
			var x = Cs.game.getX(pos.x+p.x+p.cx+0.5)
			var y = Cs.game.getY(pos.y+p.y+p.cy+0.5)
			newCloudPart( x, y )
		}
		
	}
	
	function newCloudPart(x,y){

			var a = Math.random()*6.28
			var d = Math.random()*6
			var p = Cs.game.newPart("partLightBall",null)
			p.x = x + Math.cos(a)*d;
			p.y = y + Math.sin(a)*d;
			p.scale = 300+(Math.random()*2-1)*100
			p.alpha = 60
			p.timer = 2+Math.random()*10 
			p.init();
	}
	
	function newCloud(){
		for( var i=0; i<6; i++ ){
			var a = Math.random()*6.28
			var d = Math.random()*14
			var p = Cs.game.newPart("partCloud",null)
			p.x = pos.x + Math.cos(a)*d;
			p.y = pos.y + Math.sin(a)*d;
			p.scale = Math.max(30, 120-d*10);
			p.alpha = 100;
			p.skin.gotoAndPlay(string(Std.random(3)+1))
			p.init();
			
		}
	}
	
	
	function onUpkeep(){
		super.onUpkeep();
		newCloud();
		Cs.game.addImp( pos.x, pos.y, level )
		dispel();		
	}
	
	function emergencyStop(){
		
	}
	
	function getName(){
		return "Fumée troublante "
	}
	
	
//{	
}
