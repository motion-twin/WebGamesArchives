class Hero extends Ent{//}

	static var SPEED = 5
	static var JUMP_EXTEND = 3
	static var JUMP_START = 8
	
	static var STAR_SPEED = 14//10
	//static var BLADE_SIZE = 48
	static var QUEUE_SPACE = 5
	

	var flQueue:bool
	
	var flShootReady:bool;
	var flMoving:bool;
	var flCheckGroundSafe:bool;
	var flDoubleJump:bool;
	var flDoubleJumpReady:bool;
	var flUp:bool;
	var flGameOver:bool;
	
	//var flWood:bool;
	var flInvicible:bool;
	var flControl:bool;
	
	var boost:float
	var cooldown:float;
	var jvx:float;
	volatile var woodTimer:float;
	volatile var qTimer:float; 
	volatile var sTimer:float; 
	var blink:float; 
	
	volatile var star:int;
	
	
	function new(mc) {
		super(mc)
		x=int(Game.XMAX*0.5);
		y=1;
		weight = 0.7;
		flMoving = false;
		cooldown=0
		star = 0
		incStar(40)
		jvx  = 0
		sens = 1
		
		//flWood = true;
		flInvicible = false;
		flControl = true;
		flGameOver= false;
		qTimer = 0;
		//initStep(Cs.ST_NORMAL)
		fall();
	}

	function initStep(n){
		step = n
		switch(step){
			case Cs.ST_NORMAL:
				flMoving = false;
				break;
			case Cs.ST_FLY:
				jvx = vx
				flUp = true;
				flGround = false;
				break;
			case Cs.ST_DEATH:
				nextAnim ="death"
				vy = -8
				vx *= 0.5
				flCol = false;
				flInvicible = true;
				flGround = false;
				break
		}
	}
	
	function update() {
		var jvx = vx
		
		if(flQueue)queue();
		
		super.update()
		if(!flGround)vx= jvx; // PATCH pour no friction en l'air
		
		switch(step){
			case Cs.ST_NORMAL:
				control();
				break
			case Cs.ST_FLY:
				control();
				if(flUp && vy>0 && flDoubleJump ){
					flUp=false;
					if(nextAnim==null)nextAnim = "fly_down";
				}
				break			
			case Cs.ST_DEATH:
				
				var yLim =(Cs.mch*2)-18
				if( root._y>yLim){
					vy*=-1.25
					if(!flGameOver){
						Cs.game.stats.$dif = int(Cs.game.dif)
						KKApi.gameOver(Cs.game.stats)
						flGameOver = true;
					}
					root._y = yLim
				}
				
				break;
		}
		
		if(woodTimer!=null){
			woodTimer-=Timer.tmod;
			if(woodTimer<0){
				woodTimer=null
				flControl = true;
				flInvicible = false;
				teleport();
			}
		}else{
			if(root._rotation!=0)root._rotation = 0;
		}
		
		if(boost!=null){
			boost*=Math.pow(0.8,(Timer.tmod*0.5)+0.5);
			if(boost<0.1)boost=null;
		}
		
		if(sTimer!=null)updateSupa();
		
		if(flCol){
			if(!flInvicible){
				checkDeath();
				checkBonus();
			}
		}
		
		
		
		
	}

	function checkDeath(){
		for( var tx=0; tx<3; tx++ ){
			for( var ty=0; ty<3; ty++ ){
				var list = Cs.game.grid[x+tx-1][y+ty-1].list
				for( var i=0; i<list.length; i++ ){
					var m = list[i]
					var dist = getDist(m)
					
					if(dist<24){
						if(sTimer==null){
							if(step==Cs.ST_FLY && !m.flSpike){
								
								var da = Math.abs(1.57-getAng(m));
								if( da < 1.3 ){
									if(vy>0){
										vy=-8
										m.harm(21)
									}
									return
								}
							}
							if(dist<18){
								initStep(Cs.ST_DEATH);
							}
						}else{
							burst(m)
						}						
					}
				}
			}
		}
	}
	
	function checkBonus(){
		for( var i=0; i<Cs.game.bList.length; i++){
			var b = Cs.game.bList[i]
			if(getDist(b)<24){
				b.take();
			}
		}
	}
	
	function control(){
		if(!flControl)return;
		// RUN
		//if(flGround)vx = 0;

		var flMove = false;
		if(Key.isDown(Key.LEFT)){
			setSens(-1)
			flMove = true

			
		}
		if(Key.isDown(Key.RIGHT)){
			setSens(1)
			flMove=true
		}

		if(flMove){
			if(flGround){
				vx = SPEED*sens;
			}else if(flDoubleJump){
				var dvx = SPEED*sens - vx
				var lim = 0.25
				vx += Math.min(Math.max(-lim,dvx*0.1),lim)
				//vx = SPEED*sens;
			}
			if( !flMoving){
				flMoving=true;
				if(flGround){
					nextAnim ="walk";
					for( var i=0; i<3; i++ ){
						if( Cs.game.grid[x-i*sens][y].list.length>0 ){
							nextAnim ="run";
							break;
						}
					}
				}
			}			
		}else{
			if(flMoving){
				flMoving=false;
				if(flGround)nextAnim ="wait"
			}
		}
		
		if(flGround){
			vx*=Math.pow(0.8,Timer.tmod)
		}else{
			//vx = jvx
		}

			

	
		
		
		// JUMP
		//Log.print(flDoubleJump)
		//Log.print(flDoubleJumpReady)
		if(Key.isDown(Key.UP)){
			if(flGround){
				flDoubleJump = true;
				flDoubleJumpReady = false;
				jump();
			}else if(flDoubleJump && flDoubleJumpReady ){
				flDoubleJump = false;
				jump();
				nextAnim ="ball"
				if(flMove)vx = SPEED*sens;
				
			}else{
				if(boost!=null){
					vy -= JUMP_EXTEND*boost*Timer.tmod;
				}
			}
		}else{
			flDoubleJumpReady = true;
		}

		// DOWN
		if(flGround && Key.isDown(Key.DOWN) && y+2<Game.YMAX){
			jump();
			boost=0;
			vy*=0.65;
			flCheckGroundSafe = true;
		}

		// SHOOT
		cooldown-=Timer.tmod;
		if( Key.isDown(Key.SPACE) || Key.isDown(Key.CONTROL)){
			if(cooldown<0 && flShootReady)shoot();
		}else{
			flShootReady = true;
		}
		
	}
	
	function jump(){
		initStep(Cs.ST_FLY)
		boost = 1
		vy = -JUMP_START
		nextAnim ="fly_up"
		
		
	}
	
	function land(){
		
		if(woodTimer!=null){
			if(vy>4){
				vr = (Math.random()*2-1)*Math.abs(vy)*3
				
			}
			vx *= 0.8
			vy*=-1
			return;
		}		
		super.land();

		
		
		initStep(Cs.ST_NORMAL)
		if(nextAnim==null)nextAnim ="land";
		flDoubleJump = true;
		
		for( var i=0; i<3; i++ ){
			var p = Cs.game.newPart("partDust")
			p._x = root._x + (Math.random()*2-1)*14
			p._y = root._y + 12 + Math.random()*24
			p.weight = 0.1+Math.random()*0.3
			p.scale = 50+Math.random()*70
			p._xscale = p.scale
			p._yscale = p.scale
			p.t = 20+Math.random()*10
			p.ft = 0
			if(Cs.game.flNight){
				p.gotoAndStop("2")
			}else{
				p.stop();
			}
		}
		
	}
	
	function checkGround(){
		if(flCheckGroundSafe){
			flCheckGroundSafe = false;
			return false;
		}
		return super.checkGround()
		
	}
	
	function fall(){
		initStep(Cs.ST_FLY)
		super.fall()
		nextAnim ="fall"
		flUp=false
		
	}
	
	function shoot(){
		var list = Cs.game.getClosestMonsters();
		
		flShootReady = false;

		
		// CHECK BLADE
		var trg = list[0].m
		var dx = trg.root._x - root._x
		var dy = (trg.root._y - root._y)*1.5
		var dist = Math.sqrt(dx*dx+dy*dy)
		var flNear = dist<Cs.game.optList[Cs.OPT_KATANA]?72:48//BLADE_SIZE
		if( flNear || star==0 ){
			slash(trg,flNear);
			return;
		}
		
		var max = 1
		if( step==Cs.ST_FLY && !flDoubleJump ){
			max = Math.min(star,list.length)
		}
		
		for( var i=0; i<max; i++ ){
			var o = list[i]
			if(o.d>8)break;
			throwStar(o.m)
		}
	
	}
	
	function slash(trg,flNear){
		cooldown = 10
		downcast(root).bfx.gotoAndPlay("2");
		downcast(root).bfx.blade.gotoAndStop(Cs.game.optList[Cs.OPT_KATANA]?"2":"1");
		if(flNear){
			var a = getAng(trg)
			if( (trg.x-x)*sens < 0 )setSens(-sens);
			trg.cut(21)
			if(trg.hp>0){
				vx = -5*sens
			}
			
		}
	}

	function throwStar(trg){		
		incStar(-1)
		cooldown = 2
		var a = getAng(trg)
		var s = new Star(Cs.game.mdm.attach("mcNinjaShot",Game.DP_SHOOT))
		s.x = x;
		s.y = y;
		s.dx = dx+(cx-1)*Cs.SIZE*0.5
		s.dy = dy+(cy-1)*Cs.SIZE*0.5
		//s.vr = 13
		s.vx = Math.cos(a)*STAR_SPEED
		s.vy = Math.sin(a)*STAR_SPEED
		if(Cs.game.optList[Cs.OPT_FLAMES]){
			s.damage = 8
			s.root.gotoAndStop("2")
		}else{
			s.root.gotoAndStop("1")
		}
		
	}
	
	function incStar(n){
		star = int(Math.min(Math.max(0,star+n),200));
		Cs.game.inter.fieldStar.text = string(star);
	}
	
	function hit(s){
		if(Cs.game.optList[Cs.OPT_SCROLL]){
			Cs.game.optList[Cs.OPT_SCROLL] = false
			Cs.game.updateIcons()
			setSens(1)
			root.gotoAndPlay("tronc")
			downcast(root).kunai._rotation = s.root._rotation//Math.atan2(dy,dx)/0.0174
			smoke();
			flFreezeAnim = true;
			flInvicible = true;
			flControl = false;
			woodTimer = 30
			//
			var vitx = s.vx*0.5
			var vity = s.vy*0.5 - 3
			if(flGround){
				vity = Math.min(0,vity)
				if(vity<0)initStep(Cs.ST_FLY);
			}
			vx+=vitx
			vy+=vity			
			
			
		}else{
			initStep(Cs.ST_DEATH);
		}
	}
	
	function teleport(){
		vr = 0;
		x = int(Game.XMAX*0.5)
		y = 1;
		vx = 0;
		vy = 0;
		flFreezeAnim = false;
		fall();
		smoke();
	}
	
	function smoke(){
		var p = Cs.game.newPart("partSmoke")
		p._x = (x+0.25+(cx*0.5))*Cs.SIZE + dx
		p._y = (y+0.25+(cy*0.5))*Cs.SIZE + dy
	}
	
	//
	function initSupa(){
		sTimer = 500;
		blink = 0;
		SPEED = 9
	}
	
	function updateSupa(){
		sTimer-=Timer.tmod;
		qTimer-=Timer.tmod;
		if(qTimer<0){
			qTimer = QUEUE_SPACE
			var mc = Cs.game.mdm.attach("mcShade",Game.DP_SHADE)
			mc._x = root._x;
			mc._y = root._y;
			mc._xscale = root._xscale
			downcast(mc).shade.gotoAndStop(string(root._currentframe))
		}
		/*
		var max = Math.min(sTimer/100,3)
		for( var i=0; i<max; i++){
			var p = Cs.game.newPart("partLight")
			var a = Math.random()*6.28
			var d = Math.random()*18
			p._x = root._x + Math.cos(a)*d
			p._y = root._y + Math.sin(a)*d
			p.scale = 10+Math.random()*80
			p._xscale = p.scale;
			p._yscale = p.scale;
			p.t = 10 + Math.random()*10
		}
		*/
		
		var blinkSpeed = 67
		if(sTimer<100)blinkSpeed = 127
		blink = (blink+blinkSpeed*Timer.tmod)%628
		
		var prc =(Math.cos(blink/100)+1)*40
		if(sTimer<0){
			sTimer= null
			prc = 0
			SPEED = 5
		}
		Cs.setPercentColor(root,prc,0xFFDDFF)
		
		
	}
	
	function queue(){
		//Log.print("queue");

	}
	
	function burst(m){
		m.harm(100)
		//var a = getAng(m)
		var max = 8
		for( var v=0; v<max; v++ ){
			for( var n=0; n<2; n++ ){
				var p = Cs.game.newPart("partLight")
				p._x = m.root._x
				p._y = m.root._y
				var a = ((v+0.5*n)/max)*6.28
				var speed = (3+n*2)
				p.vx += Math.cos(a)*speed
				p.vy += Math.sin(a)*speed
				p.t = 26+Math.random()*4-n*10
				p.frict = 0.9
			}
			
		}	
	}
	
	// ON
	function enterSquare(){
		super.enterSquare();
		/*ù
		if( y>Game.YMAX ){
			KKApi.gameOver({})
			//KKApi.addScore(pts)
		}
		*/
	}
		
//{
}









