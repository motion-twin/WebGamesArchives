class game.Brochette extends Game{//}
	
	
	
	// CONSTANTES
	static var SPEED = 24
	static var MAX = 7
	static var SY = 46
	static var DY = 26
	static var FH = 20
	
	// VARIABLES
	var nid:int;
	var emax:int;
	var decal:float;
	var bList:Array<Array<int>>
	var fList:Array<MovieClip>
	var cList:Array<MovieClip>
	
	// MOVIECLIPS
	var pic:MovieClip;
	var cache:MovieClip;
	var ex:MovieClip;

	function new(){
		super();
	}

	function init(){
		gameTime = 240
		super.init();
		emax = 3+Math.floor(dif*0.08)
		bList = new Array();
		for( var i=0; i<MAX; i++){
			bList[i]=[Std.random(emax)]
		}
		
		fList = new Array();
		attachElements();
	};
	
	function attachElements(){
		
		// EXEMPLE
		ex = dm.empty(Game.DP_SPRITE2)
		ex._x = 204
		ex._y = 157
		var edm = new DepthManager(ex)
		edm.attach("mcBrochette",1)
		for( var i=0; i<bList.length; i++ ){
			var mc = edm.attach("mcBrochetteFood",Game.DP_SPRITE)
			mc._y = -(DY+FH*i)
			mc.gotoAndStop(string(bList[bList.length-(1+i)][0]+1))
			downcast(mc).p._visible = bList.length-1	
			
		}
		ex._xscale = 70
		ex._yscale = 70
		ex._rotation = -30
		
		Mc.setPercentColor( ex, 50, 0xFDF2D0 )
		
		// PIC
		pic = dm.attach("mcBrochette",Game.DP_SPRITE2)
		pic._x = Cs.mcw*0.25
		pic._y = Cs.mch-SY
		
		// CACHE
		cache = dm.attach("mcBrochetteCache",Game.DP_SPRITE)
		cache._y = Cs.mch
		
		// FOOD
		
		var ec = Cs.mcw/(emax+0.5)
		for( var i=0; i<emax; i++ ){
			var mc = dm.attach("mcBrochetteFood",Game.DP_SPRITE)
			mc._x = (i+0.75)*ec;
			mc._y = 222;
			mc._xscale = 80;
			mc._yscale = 80;
			downcast(mc).p._visible = false;
			mc.gotoAndStop(string(i+1));
			mc.onPress = callback(this,select,i);
			
		}
		
		
		
		
	}
	
	function update(){
		
		switch(step){
			case 1:
				
				break;
			case 2:
				var speed  = SPEED*Timer.tmod;
				
			
				var cy = Cs.mm( 0, ((Cs.mch+DY)-pic._y)/speed, 1 )
				moveFoods(speed*cy)
				
				pic._y += speed
				

				if( pic._y > Cs.mch+DY+FH ){
					pic._y = Cs.mch+DY+FH
					step = 3
					var mc = dm.attach("mcBrochetteFood",Game.DP_SPRITE2)
					mc._x = pic._x
					mc._y = Cs.mch+FH
					mc.gotoAndStop(string(nid+1))
					downcast(mc).p._visible = fList.length==0
					fList.push(mc);
					dm.under(mc)
					dm.under(pic)
				}
				break;
			case 3:
				var speed  = -SPEED*Timer.tmod;
				pic._y += speed
				moveFoods(speed)
				if( pic._y < Cs.mch-SY ){
					var dy = (Cs.mch-SY)-pic._y
					moveFoods(dy)
					pic._y += dy
					step = 1;
					
					if(fList.length==MAX){
						var fl = true
						cList = new Array();
						for( var i=0; i<bList.length; i++ ){
							var o = bList[i]
							if(o[0]!=o[1]){
								fl=false;
								cList.push(fList[i])
							}
						}
						setWin(fl)
						step = 4
						decal = 0
					}
					
				}
				break
			case 4:
				decal = (decal+75*Timer.tmod)%628
				for( var i=0; i< cList.length; i++ ){
					var mc = cList[i]
					Mc.setPercentColor(mc,60+Math.cos(decal/100)*40,0xFF0000 )
				}
				
				
				
				break;
		}
		super.update();
	}
	
	function select(id){
		if(step == 1 ){
			bList[fList.length].push(id)
			if(step==1){
				nid = id;
				step = 2
			}
		}
	}
	
	function moveFoods(vy){
		for( var i=0; i<fList.length; i++ ){
			var mc = fList[i]
			mc._y += vy
		}
	}
	
	

//{	
}











