class spell.Destruction extends spell.Base{//}


	var tList:Array<sp.el.Token>;
	var step:int;
	var timer:float;

	function new(){
		super();
		cost = 7;
	}
	
	function cast(){
		super.cast();
		initStep(0);
	}

	function initStep(n){
		step = n 
		switch(step){
			case 0:
				timer = 50
				break;
			case 1:
				var p = newOnde();
				p.timer = 12
				p.vits = 40;
			
				for( var i=0; i<tList.length; i++ ){
					var t = tList[i]
					t.isolate();
				}
			
				timer = 100
	
				break;
			case 2:
				for( var i=0; i<tList.length; i++ ){
					var t = tList[i]
					var p = Cs.game.newPart("partMiniExplosion",Game.DP_PART2)
					p.x = t.x+0.5*Cs.game.ts
					p.y = t.y+0.5*Cs.game.ts
					p.scale = 150 + Math.random()*100
					p.init();
					p.skin.gotoAndPlay( string( Std.random(3)+1 ) )
					p.skin._rotation = Math.random()*360
					t.kill();
				}
				
				timer = 8
				break;
		}
	}

	function activeUpdate(){

		switch(step){
			case 0:
				slowCaster(0.3);
				for( var i=0; i<2; i++ ){
					var p = Cs.game.newPart("partConcentrationRay",Game.DP_PART2);
					p.x = caster.x
					p.y = caster.y
					//p.vitr = (Math.random()*2-1)*10
					p.init();
					p.skin._xscale = 50+Math.random()*100
					p.skin._rotation = Math.random()*360
				}
				
				timer -= Timer.tmod
				if( timer <= 0 )initStep(1)
				
			
				break;
			case 1:
				for( var i=0; i<tList.length; i++ ){
					var t = tList[i]
					
					// PART
					if( Std.random(int(timer*0.5))==0 ){
						var p = Cs.game.newPart("partMiniExplosion",Game.DP_PART2)
						p.x = t.x+Math.random()*Cs.game.ts
						p.y = t.y+Math.random()*Cs.game.ts
						p.init();
						p.skin._rotation = Math.random()*360
					}
					//
					Mc.setPercentColor( t.skin, (100-timer), 0xFFFFFF )
					
				}
				
				timer -= Timer.tmod*1.5
				if( timer <= 0 )initStep(2)
				
				break;
			case 2 :
				timer -= Timer.tmod
				if( timer <= 0 )finishAll();

				break;
		}	

		
	}
	

	//
	function getRelevance(){			// *1.0 sinon int
	
		tList = Std.cast(Cs.game.eList.duplicate())
		//Manager.log( "1>"+tList.length )
		for( var i=0; i<tList.length; i++ ){
			var e = tList[i]
			if( e.et != Cs.E_TOKEN )tList.splice(i--,1);
		}
		var score = 0
		//Manager.log( "2>"+tList.length )
		for( var i=0; i<tList.length; i++ ){
			var t = tList[i]
			if( Std.random(2) == 0 ){
				score+=getRemoveValue(upcast(t))
			}else{
				tList.splice(i--,1);
			}
		}
		//Manager.log( "3>"+tList.length )
		
		return score
	}
	
	function getName(){
		return "Tremblement de terre"
	}

	function getDesc(){
		return "Détruit une partie des billes colorées du niveau."
	}
	
//{
}
	
	
	






















	
	