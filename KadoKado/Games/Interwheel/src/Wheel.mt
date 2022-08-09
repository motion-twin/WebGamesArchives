class Wheel extends Element{//}

	static var MINE_SPACE = 36
	
	var flDestroy:bool;
	
	var fr:int
	var speed:float;
	var a:float;
	var aBoom:float;
	var mList:Array<{mc:MovieClip,a:float}>
	var wh:MovieClip;
	var sh:MovieClip;
	var light:MovieClip;

	function new(){
		super();
		a = 0
		speed = (Std.random(2)*2-1)*(0.1+Math.random()*0.1)
		skin = "mcWheel"
		fr = Std.random(5)+1
		mList = new Array();
		
	}
	
	function update(){
		super.update();
		a += speed*Timer.tmod;
		wh._rotation = a/0.0174
		sh._rotation = wh._rotation
		if( Cs.game.blob.step == 1 ){
			if( Cs.game.blob.getDist(this) < ray+Blob.RAY ){
					
				for(var i=0; i<mList.length; i++ ){
					var o = mList[i]
					var ba = Cs.game.blob.getAng(this)+3.14
					var da = Cs.hMod((o.a+a)-ba,3.14)
					if( Math.abs(da)*ray < MINE_SPACE ){
						Cs.game.blob.explode(ba);
						//
						Cs.game.stats.$pl++
						//
						var x = x+Math.cos(a+o.a)*ray
						var y = y+Math.sin(a+o.a)*ray
						var mcExp = Cs.game.dm.attach( "mcExplosion", Game.DP_PART )
						mcExp._x = x;
						mcExp._y = y;
						mcExp._xscale = 50
						mcExp._yscale = 50
						
						// PART MINE
						for( var n=0; n<5; n++ ){
							var p = new Part(Cs.game.dm.attach("partMine",Game.DP_PART))
							var a = ba + (Math.random()*2-1)*1.57//Math.random()*6.28
							var ray = 4
							var sp = 1+Math.random()*4
							var ca = Math.cos(a)
							var sa = Math.sin(a)
							p.x = x+ca*ray;
							p.y = y+sa*ray;
							p.vx = ca*sp
							p.vy = sa*sp
							p.setScale(80+Math.random()*40)
							p.weight = 0.1+Math.random()*0.2
							p.fadeType= 0
							p.timer = 10+Math.random()*30
							p.vr = (Math.random()*2-1)*20
							p.root._rotation = Math.random()*360
							p.root.gotoAndStop(string(Std.random(p.root._totalframes)+1))
							
						}
						// SMOKE
						for( var n=0; n<6; n++ ){
							var p = new Part(Cs.game.dm.attach("partSmoke",Game.DP_PART))
							var a = Math.random()*6.28
							var sp = 0.5+Math.random()*2
							p.x = x
							p.y = y
							p.vx = Math.cos(a)*sp
							p.vy = Math.sin(a)*sp
							p.frict = 0.95
							p.setScale(80+Math.random()*60)
							p.weight = -(0.1+Math.random()*0.3)
							p.timer = 10+Math.random()*20
							p.vr = (Math.random()*2-1)*12
							p.root._rotation = Math.random()*360
							p.updatePos();
						}
						// TACHE MUR
						for( var n=0; n<4; n++ ){
							var p = new Part(Cs.game.dm.attach("partWallTache",Game.DP_BG))
							var a = ba +(Math.random()*2-1)*1.57
							var sp = Math.random()*36
							p.x = x + Math.cos(a)*sp
							p.y = y + Math.sin(a)*sp
							p.weight = Math.random()*0.01
							p.setScale(50+Math.random()*50)
							p.root._rotation = Math.random()*360
							p.root.gotoAndStop(string(Std.random(p.root._totalframes)+1))
							p.updatePos();
						}
						// GROSSE TACHE
						{
							var p = new Part(Cs.game.dm.attach("mcStarTache",Game.DP_BG))
							p.x = x;
							p.y = y;
							p.vs = 30
							p.sFrict = 0.65
							p.root._rotation = Math.random()*360
							p.setScale(40)
							p.updatePos();
						}
						
						// TACHE SUR ROUE
						var ldm = new DepthManager(wh)
						var base = ldm.empty(4)
						var mask = ldm.attach("mcMask",4)
						mask.gotoAndStop(string(fr))
						base.setMask(mask)
						var bdm = new DepthManager(base)
						var bx = Math.cos(o.a)*50
						var by = Math.sin(o.a)*50
						var scm = 100/(ray*2)
						for( var n=0; n<4; n++ ){
							var p = new Part(bdm.attach("partWallTache",0))
							var a = o.a+3.14+(Math.random()*2-1)*1.57
							var sp = (Math.random()*10)*scm
							p.x = bx+Math.cos(a)*sp
							p.y = by+Math.sin(a)*sp
							p.setScale((50+Math.random()*60)*scm)
							p.root._rotation = Math.random()*360
							p.root.gotoAndStop(string(Std.random(p.root._totalframes)+1))
						}
						
						// YEUX
						{
							var mc = Cs.game.dm.attach("mcEyes",Game.DP_BG)
							mc._x = x;
							mc._y = y;
							mc._rotation = ba/0.0174
						}
						o.mc.removeMovieClip();
						flDestroy = true;
						aBoom = o.a
						return;
					}
				}
				Cs.game.blob.cw = this
				Cs.game.blob.initStep(2);				

			};
			
		}
		
		if(flDestroy){
			speed*=Math.pow(0.97,Timer.tmod);
			// tit'gouttes
			var ca = Math.cos(a+aBoom)
			var sa = Math.sin(a+aBoom)
			if( Math.random()/Timer.tmod<speed*5 ){
				var p = new Part(Cs.game.dm.attach("partOil",Game.DP_PART))
				var dist = ray-(5+Math.random()*5)
				p.x = x + ca*dist;
				p.y = y + sa*dist;
				p.weight = 0.1+Math.random()*0.1
				p.setScale(80+Math.random()*80)
				p.fadeType = 0
				p.timer = 10+Math.random()*20
				p.updatePos();
			}
			
		}
		
	}
	
	function attach(){
		super.attach();
		var dm = new DepthManager(root)
	
		sh = Cs.game.dm.attach("mcMask",Game.DP_SHADE)
		sh._x = x;
		sh._y = y+6;
		sh._alpha = 20
		sh.gotoAndStop(string(fr))
	
		
		var dust = dm.attach("mcDust",0)
		
		wh = dm.empty(0)
		
		
		light = dm.attach("mcWheelLight",0)
		light.gotoAndStop(string(fr))
		
		wh._xscale = ray*2
		wh._yscale = ray*2
		sh._xscale = ray*2
		sh._yscale = ray*2
		dust._xscale = ray*2
		dust._yscale = ray*2
		if(fr==2){
			light._xscale = ray*2
			light._yscale = ray*2
		}
		
		var wdm  =new DepthManager(wh)
		for( var i=0; i< mList.length; i++ ){
			var o = mList[i]
			var c = 100/wh._xscale
			o.mc = wdm.attach("mcMine",0)// Std.attachMC(root,"mcMine"+i,i)//
			o.mc._x = Math.cos(o.a)*ray*c
			o.mc._y = Math.sin(o.a)*ray*c
			o.mc._xscale = c*100
			o.mc._yscale = c*100
			o.mc._rotation = o.a/0.0174
		}			
		var skin = wdm.attach("mcWheelBase",0)
		skin.gotoAndStop(string(fr))
		
	}
	
	function detach(){
		super.detach();
		sh.removeMovieClip();
	}
	
	function addMine(){
		
		var perim = 6.28*ray
		if( mList.length>0 && perim/mList.length < MINE_SPACE*2 )return;
		
		var tr = 0
		var a = 0
		while(true){
			var flBreak = true;
			a = Math.random()*6.28
			for( var i=0; i<mList.length; i++ ){
				var da = Math.abs(Cs.hMod(mList[i].a-a,3.14))
				if(  da*ray < MINE_SPACE ){
					flBreak = false
					break;
				}
			}
			if(tr++>20)return;
			if(flBreak)break;
		}
		mList.push({a:a,mc:null})
		/*
		var max = int((2*ray*Math.PI)/MINE_SPACE)
		if(mList.length==max-1)return;
		
		*/
		
		
				
		
	}

//{
}