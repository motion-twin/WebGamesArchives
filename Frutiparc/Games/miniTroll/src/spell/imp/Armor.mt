class spell.imp.Armor extends spell.Imp{//}

	var step:int;
	
	var max:int;
	var timer:float;
	var eList:Array<sp.el.Token>
	//var pList:Array<{ p:sp.Part, color:int, tx:float }>
	
	
	function new(){
		super();
	}
	
	function cast(){
		super.cast();
		initStep(0)
	}
	
	function initStep(n){
		step = n 
		switch(step){
			case 0:
				casterGoTo( Cs.game.width*0.5, 20 )
				break;
			case 1:
				eList = new Array();
				var list =  Std.cast(Tools.shuffle)( Cs.game.eList.duplicate() );
				var max = Math.pow( imp.level, 2 )
				while(eList.length<max){
					if( list.length == 0 )break;
					var e = list.pop();
					if( e.et == Cs.E_TOKEN ){
						var token:sp.el.Token = downcast(e);
						if( token.special == 0 ){
							eList.push(token)
						}
					}
				}
				timer = 0;
				break;
			case 2:
	
				break;
		}
	}
	
	function activeUpdate(){
		switch(step){
			case 0:
				caster.toward( caster.trg, 0.1)
				if(isCasterReady(20))initStep(1);
			
				break;
			case 1 :
			
				timer-=Timer.tmod;
				if(timer < 0 ){
					timer = 8;
					var e = eList.pop();
					e.isolate();
					e.setSpecial(2)

					var trg = {
						x:Cs.game.getX( e.px+0.5 )
						y:Cs.game.getY( e.py+0.5 )
					}					
					
					var a = caster.getAng(trg)
					var dist = caster.getDist(trg);
					var ca = Math.cos(a)
					var sa = Math.sin(a)					
					
					// BIG RAY

					var p = Cs.game.newPart( "partFullRay", null );
					p.x = caster.x;
					p.y = caster.y;
					p.timer = 12;
					p.fadeTypeList = [4];
					p.init();
					p.skin._xscale = dist
					p.skin._rotation = a/0.0174;
						
					// SMALL RAY
					for( var i=0; i<3; i++ ){
						var sr = Cs.game.newPart("partHoriLight", null)
						var d = Math.random()*0.8*dist
						var sp = 1+Math.random()*5 
						sr.x = caster.x + ca*d
						sr.y = caster.y + sa*d
						sr.vitx = ca*sp;
						sr.vity = sa*sp;
						sr.timer = 16+Math.random()*10
						sr.fadeTypeList = [1];
						sr.init();
						sr.skin._rotation = a/0.0174
						sr.skin._xscale = 100+Math.random()*50
						
					}
					
					
					// GLOW
					var lb = Cs.game.newPart( "partLightBall", null );
					lb.x = trg.x;
					lb.y = trg.y;
					lb.timer = 24
					lb.fadeTypeList = [1]
					lb.scale = 150
					lb.init()

					
				};
				if(eList.length == 0)finishAll();
				
				break;
			case 2:
								
				break;
			
		}
	}
	
	function getName(){
		return "Cuirasse "
	}
	
	
//{	
}