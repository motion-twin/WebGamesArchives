class Game {//}

	
	
	
	static var DP_BALL = 2;
	static var DP_PART = 3;
	
	static var BLAST_TIME = 6
	static var FALL_WAIT = 20
	static var HAND_SPEED_COEF = 0.3
	

	var dm:DepthManager;
	var gdm:DepthManager;
	
	var pList:Array<MovieClip>
	var sList:Array<Sprite>
	var nList:Array<Ball>
	var bList:Array<Ball>
	var exploList:Array<Ball>

	var deathList:Array<Ball>
	
	var hand:Ball;
	var center:Ball;
	var oxm:float;
	var oym:float;
	var oa:float;
	
	var grid:Array<Array<Ball>>
	var bg:{>MovieClip};
	var map:MovieClip
	var mcMulti:MovieClip
	var msg:MovieClip

	volatile var colorMax:int;
	volatile var turn:int;
	volatile var combo:int;
	var toScore:{n:KKConst};

	var flRelease:bool;
	var step:int;
	volatile var timer:float;
	var angle:float;
	var speedAngle:float;
	
	var endBonus:KKConst;


	var generator:{ ray:int, dir:int, dist:int }
	
	var stats:{$sp:int,$sc:Array<{$c:int,$s:int,$t:int}>}
	
	
	function new(mc) {
		Cs.init();
		Cs.game = this
		
		gdm = new DepthManager(mc);
		map = gdm.attach("mcWheel",1)
		map._x = Cs.mcw*0.5
		map._y = Cs.mch*0.5
		
		dm = new DepthManager(map);
		
		bg = gdm.attach("mcBg",0)
		
		sList = new Array();
		bList = new Array();
		pList = new Array();
	
		
		
		grid = new Array();
		for( var x=0; x<2*Cs.GRID_RAY*2; x++ ){
			grid[x] = new Array();
		}
		colorMax = Cs.COLOR_START;
		turn = 0;
		combo = 0;

		genCenter();
		initNextList();
		initStep(Cs.STEP_SPAWN_CENTER)
		
		//initStep(Cs.STEP_CONTROL)
		angle = 0;
		oxm = 0;
		oym = 0;
		oa = 0;
		speedAngle = 0;
		
		endBonus = Cs.C2000
	}

	function initNextList(){
		nList = new Array();
		nList = new Array();
		for( var i=0; i<3; i++ ){
			
			var b = newBall();
			nList.push(b);
		}
	
	}
	
	function newBall(){
		var b = new Ball(gdm.attach("mcBall",5));
		b.x = -Cs.RAY
		b.y = Cs.mch+Cs.RAY
		if( turn > Cs.ICE_TURN_MIN ){
			var proba = Cs.ICE_MIN+Cs.mm(0,(turn-Cs.ICE_TURN_MIN)/Cs.ICE_PROGRESSION,Cs.ICE_MAX-Cs.ICE_MIN)
			if( Math.random()<proba){
				b.flIce = true;
				b.updateSkin();
			}
		}
		if( turn > Cs.MU_TURN_MIN ){
			var proba = Cs.MU_MIN+Cs.mm(0,(turn-Cs.MU_TURN_MIN)/Cs.MU_PROGRESSION,Cs.MU_MAX-Cs.MU_MIN)
			if( Math.random()<proba){
				b.color = 20
				b.flIce = false;
				b.root.gotoAndStop("21")
			}
		}
		
		
		bList.remove(b)
		return b
	}
	
	function initStep(s:int){
		step = s;

		switch(step){
			case 0: // 
				break;
			
			case Cs.STEP_CONTROL:	// CONTROL
				bg.onPress = callback(this,launchBall)
				break;
			
			case Cs.STEP_FLY: // FLY
				bg.onPress = null;
				bg.useHandCursor = false;
				break;
			
			case Cs.STEP_BLAST:
				genExploList();
				timer = BLAST_TIME
				if( exploList.length == 0 ){
					newTurn();
				}else{
					if( combo>1 ){
						if(mcMulti._visible)mcMulti.removeMovieClip();
						mcMulti = gdm.attach("mcMulti",20);
						downcast(mcMulti).txt = " x"+combo+" "
					}				
				}
				break;
			case Cs.STEP_FALL:
				timer = FALL_WAIT
				if( !genFallList() ){
					initStep(Cs.STEP_BLAST);
				}				
				break;
			case Cs.STEP_SPAWN_CENTER:
				generator = {
					ray:1,
					dir:0,
					dist:0,
				}
				timer = 0;
				break;
			case Cs.STEP_DEATH:
				timer = 25
				for( var i=1; i<bList.length; i++ ){
					var b = bList[i]
					b.deathTimer = b.getDist({x:0,y:0})*0.2
				}
				break;
		}
		
	}
	
	function newTurn(){
		//* TRACE GAMEPLY VALUES
		/*
		Log.clear();
		Log.trace("turn:"+turn)
		var proba = Cs.ICE_MIN+Cs.mm(0,(turn-Cs.ICE_TURN_MIN)/Cs.ICE_PROGRESSION,Cs.ICE_MAX-Cs.ICE_MIN)
		var proba2 = Cs.MU_MIN+Cs.mm(0,(turn-Cs.MU_TURN_MIN)/Cs.MU_PROGRESSION,Cs.MU_MAX-Cs.MU_MIN)
		Log.trace("ice:"+Math.round(proba*100)+"%" )
		Log.trace("mu:"+Math.round(proba2*100)+"%" )
		//*/
		//Log.trace((turn-Cs.ICE_TURN_MIN)/Cs.ICE_PROGRESSION)
		//*/
		//
		if( bList.length == 1 ){
			
			initStep(Cs.STEP_SPAWN_CENTER);
			KKApi.addScore(endBonus);
			setMsg("+"+KKApi.val(endBonus));
			endBonus = KKApi.cadd(endBonus,Cs.C2000);
			stats.$sp++;
			return;
		}

		turn++;
		combo = 0;
		if( turn > Cs.COLOR_RYTHM[colorMax-Cs.COLOR_START] )colorMax++;		
		if( hand.root._visible && hand.getDist({x:0,y:0}) > Cs.WHEEL_RAY-20  ){
			initStep(Cs.STEP_DEATH)
		}else{
			initStep(Cs.STEP_CONTROL);
		}
	}
	
	function main() {
		
		
		timer-=Timer.tmod;
		switch(step){
			case 0:
				break;
			case Cs.STEP_CONTROL:
				updateWheel();
				if(Key.isDown(Key.SPACE)){
					if(flRelease)launchBall();
					flRelease = false
				}else{
					flRelease = true;
				}
				break;
			case Cs.STEP_FLY: 
				Timer.tmod = 1;
				break;
			case Cs.STEP_BLAST:
				var c = timer/BLAST_TIME
				for( var i=0; i<exploList.length; i++ ){
					var b = exploList[i]
					Cs.setPercentColor(b.root,(1-c)*100,0xFFFFFF)
					b.root._xscale = 100 + (1-c)*30
					b.root._yscale = b.root._xscale
					if(c<0){
						b.explode();
					}		
				}
				if(c<0){
					KKApi.addScore(toScore.n)
					initStep(Cs.STEP_FALL)
				}
				break;
			case Cs.STEP_FALL:
				if(timer<0){
					initStep(Cs.STEP_BLAST);
				}
				break;
			case Cs.STEP_SPAWN_CENTER:
				if(timer<0){
					timer = 1;
					
					var d = Cs.DIR[generator.dir] 
					var d2 = Cs.DIR[ (generator.dir+2)%Cs.DIR.length  ] 
					
					
					var x = d[0]*generator.ray + d2[0]*generator.dist
					var y = d[1]*generator.ray + d2[1]*generator.dist

					generator.dist++
					
					if(generator.dist>=generator.ray){
						generator.dist = 0;
						generator.dir++;
						if(generator.dir < Cs.DIR.length ){
							generator.dist = 0
						}else{
							generator.dir = 0;
							generator.ray ++
							if(generator.ray > 2 ){
								initStep(Cs.STEP_CONTROL)
							}
							
						}
					}
					
					
					var b = new Ball(dm.attach("mcBall",DP_BALL))
					b.setPos(x,y)
					b.color = int(Math.abs(x-y)%colorMax)
					b.updateSkin();
					b.vs = 0
					b.root._xscale = 0
					b.root._yscale = 0
				}
				
				
				break;
			case Cs.STEP_DEATH:
				if(timer<0){
					KKApi.gameOver({});
					initStep(99)
					
				}
				break;			
		}
		//
		updateNextList();
		
		// SPRITES
		var list = sList.duplicate();
		for( var i=0; i<list.length;i++){
			list[i].update();
		}
		
	}
	
	function updateWheel(){
		var dx = Cs.mcw*0.5 - Manager.root_mc._xmouse
		var dy = Cs.mch*0.5 - Manager.root_mc._ymouse
		var na = Math.atan2(dy,dx)
		var da = Cs.hMod( oa-na, 3.14 )
		var lim = 0.3
		speedAngle += Cs.mm(-lim,da*0.4,lim)*Timer.tmod
		oa = na
		
		if(Key.isDown(Key.LEFT)){
			speedAngle += 0.1*Timer.tmod;
		}
		if(Key.isDown(Key.RIGHT)){
			speedAngle -= 0.1*Timer.tmod;
		}
		
		speedAngle*=Math.pow(0.5,Timer.tmod)
		angle+= speedAngle*Timer.tmod
		angle = Cs.hMod(angle,Math.PI)
		map._rotation = - angle/(Math.PI/180)
		
		for( var i=0; i<bList.length; i++ ){
			var b = bList[i]
			downcast(b.root).light._rotation = -(map._rotation+b.root._rotation)
			
		}	
		
		
		/* FX SPARK 
			var max = int(Math.abs(speedAngle)/0.12)
			for( var n=0; n<max; n++ ){
				var sens  = Math.abs(speedAngle)/speedAngle
				var p = new Part(gdm.attach("partWheelSpark",0));
				var a = Math.random()*6.28
				var r = Cs.WHEEL_RAY - 10
				p.x = Cs.mcw*0.5+Math.cos(a)*r
				p.y = Cs.mch*0.5+Math.sin(a)*r
				var sp = 100*speedAngle
				var a2 = a-1.57//*sens
				//p.vx = Math.cos(a2)*sp
				//p.vy = Math.sin(a2)*sp
				//p.timer = 10+Math.random()*10
				//p.root._xscale = 500+Math.random()*500
				p.root._rotation = a2/0.0174
				p.root._xscale = 1000*speedAngle
			}
		//*/
		
	}
	
	function updateNextList(){
		for( var i=0; i<nList.length; i++ ){
			var b = nList[i]
			var r = Cs.LAUNCH_RAY + i*(Cs.RAY+2.5)*2
			var pa = Math.PI*0.75
			var pos = {
				
				x:Cs.mcw*0.5+Math.cos(pa)*r
				y:Cs.mch*0.5+Math.sin(pa)*r
			}
			b.toward(pos,0.2,10)

		}
	}
	
	function launchBall(){
		var b = nList.shift();
		hand = new Ball(dm.attach("mcBall",DP_BALL))
		hand.color = b.color
		hand.flIce = b.flIce
		hand.updateSkin();

		b.kill();
		
		var sp = 18
		var ca =Math.cos(angle-0.775)
		var sa = Math.sin(angle-0.775)
		hand.x = -ca*Cs.LAUNCH_RAY
		hand.y = -sa*Cs.LAUNCH_RAY
		hand.vx = ca*sp
		hand.vy = sa*sp
		hand.flFly = true;
		hand.updatePos();
		hand.root._rotation = -map._rotation
		initStep(Cs.STEP_FLY)
		
		nList.push(newBall())
		
	}
	
	function getHandPos(){
		var x = -Math.cos(angle-0.775)*Cs.LAUNCH_RAY
		var y = -Math.sin(angle-0.775)*Cs.LAUNCH_RAY
		return {x:x,y:y}
	}
	
	function genExploList(){
		
		cleanGid();
		toScore = {n:KKApi.const(0)};
		// 
		var gList = new Array();
		for( var x=0; x<Cs.GRID_RAY*2; x++ ){
			for( var y=0; y<Cs.GRID_RAY*2; y++ ){
				var b = grid[x][y]
				if(b!=null && !b.flIce && b.color!=20){
					if( b.gid == null ){
						b.gid = gList.length;
						gList.push([b])
					}
					for( var n=0; n<3; n++ ){
						var nx = x + Cs.DIR[n][0]
						var ny = y + Cs.DIR[n][1]
						var b2 = grid[nx][ny]
						
 						if( b.color == b2.color && b2!=null && !b2.flIce && b2.color!=20){
							if(b2.gid==null){
								b2.gid = b.gid
								gList[b.gid].push(b2)
							}else if(b2.gid==b.gid){
								
							}else{
								var kgid = b2.gid
								var list = gList[kgid]//.duplicate();
								for( var g=0; g<list.length; g++){
									var b3 = list[g]
									b3.gid = b.gid
									gList[b.gid].push(b3)
								}
								gList[kgid] = null
							}
						}
					}
				}			
			}
		}
		
		//
		exploList = new Array();
		for( var i=0; i<gList.length; i++ ){
			var g = gList[i];
			if(g.length > Cs.COMBO_LIMIT-1){
				toScore.n = 
					KKApi.const(
						KKApi.val(Cs.SCORE_COMBO_BASE) + (g.length-Cs.COMBO_LIMIT) * KKApi.val(Cs.SCORE_COMBO_BONUS) * (combo+1)
					);
				while(g.length>0){
					var b = g.pop()
					exploList.push(b);
					dm.over(b.root)
				}
			}
		}
		if(exploList.length>0)stats.$sc.push({$c:combo,$s:KKApi.val(toScore.n),$t:turn})
		combo++;
	}
	
	function genFallList(){
		cleanGid();
		
		stick(center)
		var flFall = false
		var list = bList.duplicate();
		for( var i=0; i<list.length; i++ ){
			var b = list[i]
			if(b.gid == null){
				b.fall();
				flFall = true;
			}
		}
		return flFall;
	}
		
	function cleanGid(){
		for( var i=0; i<bList.length; i++ ){
			var b = bList[i]
			b.gid = null;
			//Cs.setPercentColor(b.root,0,0xFFFFFF)
		}
	}
	
	function stick(b:Ball){
		b.gid = 0
		//Cs.setPercentColor(b.root,50,0xFFFFFF)
		for( var n=0; n<Cs.DIR.length; n++ ){
			var d = Cs.DIR[n];
			var nx = b.px + d[0] + Cs.GRID_RAY;
			var ny = b.py + d[1] + Cs.GRID_RAY;
			var b2 = grid[nx][ny]
			if( b2!=null && b2.gid == null )stick(b2);
		}
		
	}
	
	function genCenter(){
		center = new Ball(dm.attach("mcBall",DP_BALL))
		center.setPos(0,0)
		center.color = 100
		center.wg = 1 
		center.root.gotoAndStop("20")	
	}
	
	function setMsg(txt){
		if(msg._visible)msg.removeMovieClip()
		msg = gdm.attach("mcCombo",20)
		msg._x = Cs.mcw
		downcast(msg).txt = txt
	}
	
	
	
//{
}









