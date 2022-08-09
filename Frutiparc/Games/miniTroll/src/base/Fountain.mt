class base.Fountain extends base.Aventure{//}

	var flEnd:bool;
	
	var fireBallTimer:int;
	//var endTimer:float;
	
	var bubble:sp.part.Bubble
	
	function new(){
		
		super();
		Cm.card.$stat.$game[1]++
		fireBallTimer = 0
		elementColor = {prc:16,col:0x0000FF}
	}
	
	function init(){
		super.init();
		launch();
	}
	
	function initGame(){
		super.initGame()
		
		
		
		game.width = 240
		game.height = 240
		game.nextLimit = 1;
		
		//initFaerie();
		game.setPieceSpeed( 0.03 + level*0.001 )
		
		//
		initBubbleFaerie();
		
	}
	
	function initSkin(){
		super.initSkin();
		intUp = dm.attach("interfaceFountain",Base.DP_SKIN_UP)
		intMiddle = dm.attach("interfaceFountain",Base.DP_SKIN_MIDDLE)
		intDown = dm.attach("interfaceFountain",Base.DP_SKIN_DOWN)
		intUp.gotoAndStop("1")
		intMiddle.gotoAndStop("2")	
		intDown.gotoAndStop("3")
		
		var nc  = Cm.getNightCoef();
		downcast(intDown).sub.bg.gotoAndStop(string(int(nc*100)+1));
	}
	
	function update(){
		super.update()
		

		var limit = getColorLimit(game.colorList.length)
		
		
		if( game.mainTimer > limit && game.colorList.length < Cs.colorList.length ){
			game.colorList.push(game.colorList.length)
			game.clearNext();
		}
		
		if( bubble != null )bubble.update();
		
			
		if(mf!=null && mf.y < -20){
			mf.kill();
			mf = null;
			Manager.fadeSlot("menu",120,120);
		}

		switch( game.step  ){
			case 1:	// FALL
				for( var i=0; i<game.fList.length; i++ ){
					var e = game.fList[i]
					if(Std.random(3)==0){
						var r = game.ts*0.5
						var b = newBubble(e.x+r,e.y+r,r)
						b.scale = 25+Math.random()*50
						b.init();
					}
					
				}
				break;
				
			case 2:	// GAME
				var p = game.piece
				if(p!=null){
					var rnd = 80
					if( p.speeder > 0 || p.da > 8 ) rnd = 3;				
					
					for( var i=0; i<p.list.length; i++ ){
						var pos = p.list[i]

						if( Std.random(rnd)==0 ){
							var r = game.ts*0.5
							var x = game.getX(pos.x+p.x+p.cx+0.5)
							var y = game.getY(pos.y+p.y+p.cy+0.5)
							var b = newBubble(x,y,r)
							b.scale = 25+Math.random()*50
							b.init();
						}
						
					}
				}
				
				break;			
			
		}
		
		
		
	}
	
	function getColorLimit(n){
		return Math.pow( n, 4)*16
	}


	function newPieceList( shape:Array<{x:int,y:int}> ):Array<ElementInfo>{ // ICI
		
		if(fireBallTimer>0){
			fireBallTimer --;
			return super.newPieceList(shape);
		}else{
			fireBallTimer = 10
			var list = new Array();
			for( var x=0; x<3; x++ ){
				for( var y=0; y<3; y++ ){
					var ei = new ElementInfo();
					if( x==1 && y==1){
						var e = new sp.el.FireBall();
						ei.e = upcast(e);
					}else{
						var e = new sp.el.Token();
						e.type = game.getColor();
						e.special = 2
						ei.e = upcast(e);
						
					}
					ei.x = x-1;
					ei.y = y-1;
					
					
					list.push(ei)
				}
			}
			return list;
			
		}
	}
	
	// END
	function freeFaerie(){
		//Manager.log(freeFaerie)
		
		// CARD
		Cm.freeFaerie();

		
		// FAERIE
		var fi = Cm.getCurrentFaerie()
		mf = new sp.pe.Faerie();
		mf.setInfo(fi)
		mf.x = bubble.x;
		mf.y = bubble.y;
		mf.init();
		mf.birth( game.dm.empty( Game.DP_PEOPLE ) );
		mf.vitx = bubble.vitx*0.8
		mf.vity = bubble.vity*0.8
		mf.trg = {x:mf.x,y:-20}
		mf.flForceWay = true;
		
		// BUBBLE
		for( var i=0; i<10; i++ ){
			var b = newBubble(bubble.x,bubble.y,16)
			b.init();
		}

		//
		bubble.kill();
		flEnd = true;
		
		//
		
		
	}
	
	function onNewTurn(){
		super.onNewTurn();
		if(flEnd){
			game.initStep(10);
			//endTimer = 20
		}
	}
	

		
	// BUBBLE
	function initBubbleFaerie(){
		var fs = Cm.card.$pond.$fs
		if( fs != null ){
			
			var fi = Cm.getFaerie(fs)
			bubble = new sp.part.Bubble();
			bubble.setSkin( game.dm.empty( Game.DP_PEOPLE ) )
			bubble.setFaerieInfo(fi);
			bubble.x = Cs.mcw*0.5
			bubble.y = Cs.mcw*0.5
			bubble.life = 5+Cm.card.$pond.$q*3
			bubble.init();
			
						
			
		}
	}
	
			
	// ON
	function onFireBall(fb){
		super.onFireBall(fb)
		fb.trgList.push(Std.cast(bubble))
		fb.initHoming( 4, 0.2, 0.25, 0 )
		fb.damage = 80
		fb.vLim = -150
		
		fb.angle = bubble.getAng(fb)
		//fb.vitx += Math.cos(a)*4
		//fb.vity += Math.sin(a)*4
		
		
	}

	function onDestroyElement(list){
		for( var i=0; i<list.length; i++ ){
			var e = list[i]
			var x = e.x+Cs.game.ts*0.5
			var y = e.y+Cs.game.ts*0.5
			var b = newBubble(x,y,5)
			b.sleep = 5+Math.random()*4
			b.skin._visible = false;
			b.init();
			
		}
	}
	
	
	// FX
	function newBubble(x,y,r){
		var b = Cs.game.newPart("partBubble",Game.DP_PART2);
		b.x = x
		b.y = y
		if(r!=null){
			var a = Math.random()*6.28
			var d = Math.random()*r
			b.x += Math.cos(a)*d
			b.y += Math.sin(a)*d
		}
		b.friction = 1.06
		b.vity = -(0.5+Math.random()*2)
		b.timer = 14+Math.random()*10
		b.scale = 50+Math.random()*50
		return b;
	}
	
	
//{	
} 


// PFM 05 56 49 78 00




















