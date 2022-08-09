class spell.Swap extends spell.Base{//}


	var step:int;
	var pair:Array<sp.Element>
	
	var timer:float;
	
	var decal:float;
	
	//var e:sp.Element;
	var best:{ x:int, y:int, score:float }  
	
	function new(){
		super();
		cost = 1;
	}
	
	function cast(){
		super.cast();
		//Manager.log("cast swap")
		initStep(0)
	}

	function initStep(n){
		step = n 
		switch(step){
			case 0:
				selectPair()
				if(pair==null){
					Manager.log("Schème de Dimitri abandonné")
					finishAll()
					return
				}

				caster.trg = {
					x:(pair[0].x+pair[1].x)*0.5 + Cs.game.ts*0.5 ,
					y:pair[0].y+Cs.game.ts*0.5
				}
				caster.flForceWay = true;
				timer = 100;
				break;
			
			case 1:
				// FX
				for( var i=0; i<2; i++){
					var sens = i*2-1
					for( var m=0; m<3; m++){
						var sp = Cs.game.newPart("partJet",null)
						sp.x = caster.trg.x
						sp.y = caster.trg.y
						sp.scale = 50+Math.random()*40
						sp.init();
						sp.skin._rotation = 20*(Math.random()*2-1)+sens*90
						sp.skin.gotoAndPlay(string(Std.random(4)+1))
					}
				}
				//
				for( var i=0; i<pair.length; i++)pair[i].isolate();
				caster.flForceWay = false;
				decal = 0;
				
				
				break;
			
		}
	}

	function selectPair(){

		var best = getBestResult();

		// debugResult();
		
		
		if(best!=null){
			pair = [ Cs.game.grid[best.x][best.y], Cs.game.grid[best.x+1][best.y] ]
		}else{
			pair = null
		}
	}
	

	function getResult(){
		var list = new Array();
		var gm = Cs.game.getGridModel();
		var ref = Cs.game.getGroupModelScore( Cs.game.evalGridModel(gm).gList )
		
		for( var x=0; x<Cs.game.xMax; x++ ){
			for( var y=0; y<Cs.game.yMax; y++ ){
				var e0 = gm[x][y]
				if( e0 != null){
					var e1 = gm[x+1][y]
					if( e1 != null && e0.t != e1.t ){
						var gMod = Cs.game.getGridModel();
						///* CODE QUI MARCHE
						var c0 = gMod[x][y]
						var c1 = gMod[x+1][y]
						gMod[x][y] = c1
						gMod[x+1][y] = c0
						/*/
						// CODE QUI MARCHE PAS 
						gMod[x][y] = e1
						gMod[x+1][y] = e0
						
						//*/
						var o = Cs.game.evalGridModel(gMod)
						var score = Cs.game.getGroupModelScore(o.gList) - ref
						list.push( { x:x, y:y, score:score } );
					}
				}
			}			
		}
		/* MANAGER TRACE
		Manager.logClear()
		Manager.log("scheme result:p")
		for( var i=0; i<list.length; i++){
			var o = list[i]
			Manager.log("("+o.x+","+o.y+") --> "+o.score)
		}
		*/
		
		return list;
	}
	
	function getBestResult(){
		var result = getResult();
		var f = fun(a,b){
			if(a.score > b.score ) return -1;
			if(b.score > a.score ) return 1;
			return 0;
		}
		result.sort(f)
		/*
		Manager.log("result:")
		for(var i=0; i<result.length; i++ ){
			var r = result[i]
			Manager.log("- "+r.score)
		}
		//*/		
		
		var index = int((Math.random()*Math.min(16,result.length))/(fi.carac[Cs.INTEL]+0.5))
		return result[index]	
	}
	
	function update(){
		super.update();
	}
	
	function activeUpdate(){
		//Log.print("timer ")
		
		switch(step){
			case 0:
				if( caster.getDist(caster.trg)<20 ){
					initStep(1)
				}
				
				//FX
				caster.starFall(2)
				caster.toward(caster.trg,0.1)
				break;
			
			case 1:
				decal = Math.min(decal+7*Timer.tmod,157)
				var x = pair[0].x
				for( var i=0; i<pair.length; i++ ){
					var e = pair[i]
					var sens = i*2 - 1
					e.skin._x = e.x + Math.sin((decal+314*i)/100)*Cs.game.ts
					if( decal == 157 ){
						e.x -= sens*Cs.game.ts
						e.px -= sens
						Cs.game.insertInGrid(e)
					}
					Mc.setColor( e.skin, 0xFFFFFF )
					Mc.modColor( e.skin, 1, 157-decal )

				}

				if( decal == 157 ){
					endActive();
					dispel();
				}
				
				//FX
				caster.starFall(0.2)

				break;
			
		}
	}
	
	//
	function getRelevance(){
		best = getBestResult()
		//Manager.log("shemeDimResult:("+best.x+","+best.y+","+best.score+")")
		return Math.max(0.001,best.score/100);
	}
	
	//
	function getName(){
		return "Scheme de Dimitri "
	}
	
	function getDesc(){
		return "Echange deux billes adjacentes du niveau."
	}

	
	// DEBUG
	function debugResult(){
		Log.clear();
		Manager.log("analyse du swap: ("+best.score+")")
		
		//getBestResult()
		var x = best.x
		var y = best.y
		var gMod = Cs.game.getGridModel();
		var e0 = gMod[x][y]
		var e1 = gMod[x+1][y]
		gMod[x][y] = e1
		gMod[x+1][y] = e0
		
		var o = Cs.game.evalGridModel(gMod)
		for( var i=0; i<o.gList.length; i++ ){
			var tr = 0;
			for( var n=0; n<o.gList[i].length; n++ ){
				if(o.gList[i][n].s == 0 )tr++;
			}
			if( tr >= Cs.game.groupMax ){
				Manager.log("Should break!!")
				for( var n=0; n<o.gList[i].length; n++ ){
					Manager.log(">"+o.gList[i][n].t)
				}				
			}
	
		}
		
		
	}
		
	
	
	
	
//{	
}