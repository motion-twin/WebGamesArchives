class Paillette extends Arrow{//}


	var trg:Sprite
	var dec:{x:float,y:float}
	
	var bList:Array<Array<int>>
	var speedMax:float;
	var sleep:float;
	
	function new(mc){
		mc = Cs.game.mcPaillette.dm.attach("partStandard",0)
		super(mc)
		bList = new Array();
	}
	
	function setSkin(fr){
		root.gotoAndStop(string(fr))
	}

	function update(){
		
		
		if(sleep>0)sleep-=Timer.tmod;
		for( var i=0; i<bList.length; i++ ){
			var a = bList[i];
			switch(a[0]){
				case 0: // GO GO GO
					if(sleep==null || sleep>0 )break;
					towardAngle(getAng(trg),angleCoef,angleSpeed);
					var ds = speedMax-speed;
					speed += ds*0.1*Timer.tmod;
					setVit(speed);
					angleCoef *= 1.04
					angleSpeed *= 1.04
					break;
				case 1: // EXPLO STANDARD
					if(getDist(trg)<20){
						kill();
					}
					break;
			}
		}
		
		super.update();
	}
	

	// TOOLS
	function setTrg(card){
		trg=card
		dec = {
			x:Math.random()*Card.WW - Card.WW*0.5,
			y:Math.random()*Card.HH - Card.HH*0.5
		}
	}
	function setStartPos(card){
		x = card.x + (Math.random()*Card.WW-Card.WW*0.5)*card.scale/100
		y = card.y + (Math.random()*Card.HH-Card.HH*0.5)*card.scale/100
	}
	
	// MORPH
	function morphToPart(){
		var p = new Part(root)
		p.scale = scale
		p.x = x;
		p.y = y;
		p.vx = vx;
		p.vy = vy;
		p.vr = vr;
		p.timer = 10+Math.random()*10
		p.fadeType = 0
		root = null;
		kill();	
		return p
	}
	
	
	//
	function kill(){
		super.kill();
	}
//{
}