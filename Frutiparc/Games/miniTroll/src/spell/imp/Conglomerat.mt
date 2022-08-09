class spell.imp.Conglomerat extends spell.Imp{//}

	var step:int;

	var timer:float;
	var decal:float;
	
	var ball:sp.Part;
	var bdm:DepthManager;
	
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

				timer = 20
				var shape = Cs.game.getBigShape(6+imp.level);
				Cs.game.nextPiece = Cs.base.newPieceList(shape);
				break;
			case 1:
				caster.vity += 4
				ball = Cs.game.newPart("partBlackBall",null);
				ball.x = caster.x
				ball.y = caster.y
				ball.init();
				
				bdm = new DepthManager(ball.skin)
				
				break;
			case 2:
				//caster.trg = null
				caster.flForceWay = false;
				endActive();
				decal = 0
				break;
		}
	}
	
	function activeUpdate(){
		switch(step){
			case 0:
				slowCaster(0.5)
				newBlackPart(caster.x,caster.y)
				timer -= Timer.tmod;
				if( timer < 0 ){
					initStep(1)
				}
				
				break;

			case 1:
				newBlackPart(caster.x,caster.y)
				var trg = { x:Cs.game.width*0.5, y:-30 }
				ball.towardSpeed(trg,0.2,0.3)
				
				var mc = bdm.attach("mcBlackBallSpark",2)
				var a = Math.random()*6.28
				var d = 2+Math.random()*10			
				mc._rotation = Math.random()*360
				mc._x = Math.cos(a)*d
				mc._y = Math.sin(a)*d
				//mc.gotoAndStop(string(Std.random(mc._totalframes)+1))
				if( ball.y < -30 ){
					ball.kill();
					ball = null
					initStep(2)
				}
				
				break;
			
		}
	}
	
	function update(){
		super.update();
		switch(step){
			case 2 :
				decal = (decal+73*Timer.tmod)%628
				if( Cs.game.piece != null ){
					// BLINK
					var prc = 30+Math.cos(decal/100)*30;
					Mc.setPercentColor( Cs.game.piece.base ,0, 0xFF00AA );
					Mc.modColor( Cs.game.piece.base, 1, Math.cos(decal/100)*40-40 )
					
					// PART

					newBlackPart(caster.x,caster.y)

					/*
					var p = Cs.game.piece
					for( var i=0; i<p.list.length; i++ ){
						var pos = p.list[i]
						var x = Cs.game.getX(pos.x+p.x+p.cx+0.5)
						var y = Cs.game.getY(pos.y+p.y+p.cy+0.5)
						newBlackPart( x, y )
					}
					*/
					
				}
				

				
				
				break;
		}
	}
	
	function newBlackPart(x,y){
		var p = Cs.game.newPart("partFader",null)
		var a = Math.random()*6.28
		var d = 2+Math.random()*10
		p.x = x + Math.cos(a)*d
		p.y = y + Math.sin(a)*d
		p.timer = 4+Math.random()*10
		p.fadeTypeList = [0,1,2]
		p.fadeColor = 0x000000
		p.init();
		return p;
		
	}
	
	
	function onUpkeep(){
		super.onUpkeep();
		dispel();		
	}
	/*
	function getShapeFromOuterSpace(){
		
		var list = [{x:0,y:0}]

		do{
			var x = Std.random(5)-2
			var y = Std.random(5)-2	
			
			var flValide = false;
			
			for( var i=0; i<list.length; i++ ){
				var p = list[i]
				var dif = Math.abs(p.x-x) + Math.abs(p.y-y)
				if( dif == 0){
					flValide = false;
					break
				}
				if( dif == 1 )flValide = true;
			}

			if( flValide )list.push({x:x,y:y});
			
		}while( list.length < 6+imp.level )

		
		return list
		
	}
	*/
	function getName(){
		return "Conglomerat "
	}
	
	
//{	
}


















