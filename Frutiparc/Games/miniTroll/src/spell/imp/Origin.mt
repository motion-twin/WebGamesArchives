class spell.imp.Origin extends spell.Imp{//}

	var step:int;
	var timer:float;

	var color:int;
	var cv:int;
	
	var pList:Array<sp.Part>;

	var fp:sp.Part;
	var tok:sp.el.Token
	
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
				if( !Cs.game.isFree( int(Cs.game.xMax*0.5), 0 ) ){
					Manager.log("Origine avorté !! ( pas de place ) ")
					finishAll();
					return;
				}
			
				color = 0
				var list = Cs.game.colorList;
				while(true){
					var flBreak = true;
					for( var i=0; i<list.length; i++ ){
						if( color == list[i] ){
							flBreak = false;
							color++
							break;
						}
					}
					if(flBreak)break;
				}
				cv = Cs.colorList[color]
				centerCaster();
				break;
			case 1:
				pList = new Array();
				timer = 80;
				fp = Cs.game.newPart("partFlipGlow",Game.DP_PART2);
				fp.x = caster.x;
				fp.y = caster.y;
				fp.scale = 0;
				fp.init();
				break;
			case 2:

				Cs.game.colorList.push(color)
				tok = downcast(Cs.game.genElement( Cs.E_TOKEN, int(Cs.game.xMax*0.5), 0, 0 ))
				tok.setType(color)

				for( var i=0; i<pList.length; i++ ){
					var p = pList[i]
					Mc.setPercentColor( p.skin, 0, cv )
					
					var dist = p.getDist(caster);
					var a = p.getAng(caster)
					var sp = dist*0.2
					p.vitx = -Math.cos(a)*sp
					p.vity = -Math.sin(a)*sp
					p.timer = 12+Math.random()*15
				}
				
				fp.timer = 10
				timer = 20
				
				break;
				
		}
	}
	
	function activeUpdate(){
		switch(step){
			case 0:
				
				caster.toward( caster.trg, 0.1 );
				
				if( isCasterReady(20) ){
					initStep(1);
				};
				break;
			case 1 :
				slowCaster(0.5);
				
				// NEW PART
				newColorPart();

				
				// MOVE PART
	
				for( var i=0; i<pList.length; i++ ){
					var p = pList[i]
					p.towardSpeed( caster, 0.1, 0.2 )
					//*
					
					var dist = p.getDist(caster);
					var prc = Math.max(0,100-dist*3)
					Mc.setPercentColor( p.skin, prc, cv )
					
					var scale = Math.max(0,160-dist*3)
					p.skin._xscale = scale;
					p.skin._yscale = scale;
					
					
					if( dist < 6 ){
						p.kill();
					}
					//*/
				}
				
				// GLOW
				fp.x = caster.x;
				fp.y = caster.y;
				var sc = Math.max( 0, 100-timer*1.5 )
				fp.skin._xscale = sc;
				fp.skin._yscale = sc;
				Cs.game.dm.over(fp.skin);
				
				//
				timer -= Timer.tmod;
				if( timer <0 )initStep(2)
				break;
				
			case 2:
				for( var i=0; i<int(timer*0.5);i++)newVertiLight();
				
				
				timer -= Timer.tmod;
				if( timer <0 )finishAll();
				
				break;
			
		}
	}
	
	function newColorPart(){
				
		var p = Cs.game.newPart("partLightBallFlip",Game.DP_PART2)
		var a = Math.random()*6.28
		var d = 30+Math.random()*30
		p.x = caster.x + Math.cos(a)*d
		p.y = caster.y + Math.sin(a)*d
		p.scale = 50;
		p.alpha = 50;
		//p.friction = 1.1
		p.addToList(pList)
		p.init();
		//pList.push(p)	
	}

	function newVertiLight(){
				
		var p = Cs.game.newPart("partVertiLight",Game.DP_PART2)
		var x  = Cs.game.getX( int(Cs.game.xMax*0.5)+Math.random() )
		p.x = x
		var c = Math.random()
		p.y = caster.y*c + tok.y*(1-c)
		p.vity = - (2+Math.random()*12)
		p.timer = 8+Math.random()*10
		p.init();
		p.skin._yscale = 100+Math.random()*200
		//pList.push(p)	
	}

	
	function getName(){
		return "Origine "
	}
	
	
//{	
}














