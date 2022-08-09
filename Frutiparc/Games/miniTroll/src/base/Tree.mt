class base.Tree extends base.Aventure{//}

	static var TIME_LIMIT = 1000
	static var SPEED_LIMIT = [ 0.15, 0.35, 0.5 ]
	static var VALUE_LIMIT = [ 1, 5, 7, 8, 9, 10 ]
	
	var timer:float;
	
	var score:int;
	var multi:int;
	
	var panScore:{>MovieClip,field:TextField}
	
	var fruitList:Array<sp.Part>
	
	var esc:MovieClip;
	
	function new(){
		super();
		Cm.card.$stat.$game[4]++
	}
	
	function init(){
		super.init();
		fruitList = new Array();
		initNextPiece()
		initScore();
		initEscargot();
		multi = 1;
		launch();
		
		
		
		
	}
	
	
	function initGame(){
		
		super.initGame()
		game.marginLeft  = 48
		game.width = 196
		game.height = 240
		game.flAutoRaiseSpeed = false;
		game.pSpeed = 0.03
		
		timer = 0
		

	}
	
	function initNextPiece(){
		intFace = new inter.Face(this);
		intFace.init();
		intFace.mx = 68;
		intFace.my = 4;
		intFace.supaMorph();
		intFace.setSkin(4);	
	}
	
	function initScore(){
		panScore = downcast(dm.attach("panScore",Base.DP_INTER))
		panScore._x = 2
		panScore._y = 2
		score = 0;
	}
	
	function initEscargot(){
		esc = dm.attach("mcEscargot",Base.DP_SKIN_MIDDLE)
		esc._x = 38
		esc._y = 240
	}
	
	function initSkin(){
		super.initSkin();
		intUp = dm.attach("interfaceTree",Base.DP_SKIN_UP)
		intMiddle = dm.attach("interfaceTree",Base.DP_SKIN_MIDDLE)
		intDown = dm.attach("interfaceTree",Base.DP_SKIN_DOWN)
		intUp.gotoAndStop("1")
		intMiddle.gotoAndStop("2")
		intDown.gotoAndStop("3")	
	}
	//
	function incScore(n){
		score += n;
		panScore.field.text = string(score) ;
	}
	
	//
	function update(){
		super.update();
		if(game.step==2){
			//Log.print("timer:"+int(timer))
			//Log.print("pSpeed:"+(int(game.pSpeed*100)/100))
			timer+=Timer.tmod
			if( timer > TIME_LIMIT ){
				timer -= TIME_LIMIT
				game.pSpeed += 0.05
				if( game.pSpeed > SPEED_LIMIT[game.colorList.length-3] && game.colorList.length<6 ){
					multiUp();
					game.colorList.push(game.colorList.length)
					game.pSpeed = game.colorList.length*0.01
					game.clearNext()
				}
			}
		}
		
		//ESC
		var ty = 240-(timer/TIME_LIMIT)*220
		if( esc._y+5 < ty ){
			esc.play();
			esc._y += 3*Timer.tmod
		}else{
			esc._y = ty
		}
		
		/// MOULIN
		downcast(intDown).windMill.w.w._rotation += Cm.card.$wind*2
		
		//if(multi==1)multiUp();
		moveFruit();
		
		
	}
	
	function moveFruit(){
		
		for( var i=0; i<fruitList.length; i++ ){
			var p = fruitList[i]
			// ELASTIQUE
			var at = {x:22,y:-60}
			if(i<fruitList.length-1){
				at = {x:22,y:-240}
			}
			
			var dist = p.getDist(at)
			var max = 40
			if( dist > max ){
				var c = (dist-max)/max
				var a = p.getAng(at)
				var sp = c*0.1
				p.vitx += Math.cos(a)*c
				p.vity += Math.sin(a)*c
			} 
			// ROT
			var lim = 0.5
			p.vitr -= Cs.mm(-lim,p.skin._rotation*0.05,lim)*Timer.tmod
			
			
			
			p.update();
		}
	}
	
	function multiUp(){
		multi++;
		var p = newPart("mcMultiFruit",Base.DP_INTER)
		p.x = 20+Math.random()*10
		p.y = -60
		p.flGrav = true
		p.weight =  1
		p.vitr = 0
		p.skin._rotation = (Math.random()*2-1)*90 
		p.init();
		p.skin.gotoAndStop(string(multi))
		dm.under(p.skin)
		fruitList.push(p)
	}
	
	function newPieceListElement():ElementInfo{
		var ei  = super.newPieceListElement()
		switch(ei.e.et){
			case 0:
				var e = downcast(ei.e)
				if(e.special == 0 ){
					if(Std.random(8)==0)e.special = 2;
				}
				break;
		}
		return ei
	}

	// ON
	//
	function onFallStats(fs){
		super.onFallStats(fs)
		var sum = 0
		for( var i=0; i<fs.list.length; i++ ){
			sum += fs.list[i]*VALUE_LIMIT[int(Math.min(i,5))]*multi;
		}
		incScore(sum);
	}
	
	function kill(){
		super.kill()
	}
	
	function gameOver(){
		if( score > Cm.card.$stat.$treeMax ){
			Cm.card.$stat.$treeMax = score
			Manager.fadeSlot("news",120,120);
			downcast(Manager.slot).score = score
			downcast(Manager.slot).setNews(0)
			
		}else{
			super.gameOver();
		}
	}
//{	
} 



/*
a
b

var dx  = a.x - b.x
var dy  = a.y - b.y

Math.sqrt(dx*dx+dy*dy)

*/
















