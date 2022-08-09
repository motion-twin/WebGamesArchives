class spell.ShapeSmall extends spell.Base{//}

	var step:int;
	var startPiece:int;
	var nStar:int;
	
	var decal:float;
	var dSpeed:float;
	var timer:float;
	
	var bList:Array<sp.Part>
	
	function new(){
		cost = 2;
		super();
	}
	
	function cast(){
		super.cast();
		startPiece = Cs.game.pieceTimer;
		nStar = fi.carac[Cs.WISDOM]
		initStep(0);
	}

	function update(){
		super.update();
		var dif = Cs.game.pieceTimer - startPiece
		if( dif > fi.carac[Cs.WISDOM]*4 ){
			dispel();
		}
	}
	
	function initStep(n){
		step = n 
		switch(step){
			case 0:
				bList = new Array();
				for( var i=0; i<nStar; i++){
					var p = Cs.game.newPart("partLightStar",null);
					p.x = caster.x;
					p.y = caster.y;
					p.init();
					bList.push(p);
				}
				decal = 0
				dSpeed = 1
				break;
			case 1:
				timer = 0
				break;
			case 2:
				execute();
			
				break;
		}
	}

	function activeUpdate(){
		
		slowCaster(0.5);
	
		
		switch(step){
			case 0:
				decal = ( decal+dSpeed*Timer.tmod )%628
				dSpeed *= 1.1
				var sLim = 40
				for( var i=0; i<bList.length; i++ ){
					var p = bList[i]
					var d = 30
					var a = (decal/100)-(i/bList.length)*6.28
					
					var trg = {
						x: caster.x + Math.cos(a)*d
						y: caster.y + Math.sin(a)*d
					}
					p.toward(trg,0.2)
					
					if( dSpeed > sLim ){
						var sp = 10
						p.vitx += Math.cos(a+1.2)*sp
						p.vity += Math.sin(a+1.2)*sp
					}
				}
			
				if( dSpeed > sLim )initStep(1);
				break;
			case 1:
				timer += Timer.tmod
				for( var i=0; i<bList.length; i++ ){
					
					var p = bList[i]
					for( var n=0; n<2; n++ ){
						var part = Cs.game.newPart("partLightBall",null)
						var a = Math.random()*6.28
						part.x = p.x
						part.y = p.y
						part.vitx = Math.cos(a)*2
						part.vity = Math.sin(a)*2
						part.scale = 30+Math.random()*50
						part.weight = 0.1
						part.flGrav = true;
						part.timer = 10+Math.random()*10
						part.init();
						
					}
					Cs.game.dm.over(p.skin)
					
					if( timer > i*2 ){
						var trg = {
							x: fi.intFace.skin._x+12
							y: 10+(i/bList.length)*64
						}
						p.towardSpeed(trg,0.01,1)
						
						var dist = p.getDist(trg)
						if( dist < 32 ){
							//p.kill();
							p.skin.play();
							p.vitx = 0
							p.vity = 0
							bList.splice(i--,1)
							fi.intFace.flash();
						}
					}
					
					
				}

				if( bList.length == 0 ){
					execute();
					endActive();
				}				
				
				break;
		}		
	}
	
	function dispel(){
		fi.intFace.removePieceSpellEffect(0)
		Cs.game.shapeNumInc++;
		Cs.game.clearNext();		
		super.dispel();
	}
	
	//
	function getRelevance(){
		return Math.random()*fi.carac[Cs.WISDOM]*2;
	}
	
	//
	function execute(){
		Cs.game.shapeNumInc--;
		Cs.game.clearNext();
		fi.intFace.setPieceSpellEffect(0);
			
	}
	
	//
	function getName(){
		return "Dactylo "
	}
		
	function getDesc(){
		return "Les prochaines pieces contiendront une bille de moins."
	}			
	
//{	
}