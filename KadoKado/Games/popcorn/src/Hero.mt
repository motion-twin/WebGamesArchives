class Hero extends Phys{//}

	static var WALK_FRAME_MAX = 12
	static var FLIGHT_CONTROL = 0.35


	static var RAY = 5
	static var SP_FRICT = 0.7
	static var ACC = 3

	static var CLIMB_MAX = 24
	static var CLIMB_SPEED = 2

	var step:int;
	volatile var comboIndex:int;

	volatile var extraJump:int;

	volatile var speed:float;
	var frame:float;
	var jumpPower:float;
	var jumpAngle:float;
	var jumpCircle:MovieClip;

	var trg:Corn

	var px:int;
	var py:int;


	function new(mc){
		mc= Cs.game.dm.attach("mcPiou",Game.DP_PIOU)
		super(mc)
		initStep(0)

	}

	function initStep(n:int){

		switch(step){
			case 0: // FLY
				weight = 0
				removeBouncer();
				vx = 0;
				vy = 0;
				flOrient = false;
				break;
			case 1:
				y -= RAY
				break;
		}

		step = n

		switch(step){

			case 0: // FLY
				weight = 0.5
				x = Cs.mm( (RAY+3), x, Cs.mcw-(RAY+3) )
				bouncer = new RoundBouncer(this);
				bouncer.onBounceAngle = callback(this,col)
				root.gotoAndStop("2")

				break;

			case 1:	// WALK
				comboIndex = 0
				root.gotoAndStop("1")
				speed = 0
				root._rotation = 0
				y += RAY
				px = int(x)
				py = int(y)
				frame = 0
				break;
		}
	}

	function update(){
		super.update();
		var lim = RAY+4
		switch(step){

			case 0: // FLY

				bouncer.px = int(Cs.mm(lim,bouncer.px,Cs.mcw-lim))
				if(Cs.game.step==1){
					if(trg==null){
						// COL CORN
						for( var i=0; i<Cs.game.cList.length; i++ ){
							var sp = Cs.game.cList[i]
							if(  (sp.bouncer!=null || sp.step== 0 ) && getDist(sp) < 16 ){
								initJump();
								trg = sp
								vx = 0
								vy = 0
								root.gotoAndStop("turn")
								root._rotation = 0
								flOrient = false;

							}
						}

						// COL BOSS
						if( Cs.game.boss.step< 3 && getDist(Cs.game.boss)< 32 ){
							Cs.game.boss.hit();
						}

						// CONTROL FLIGHT
						var sens = 0
						if(Key.isDown(Key.LEFT))sens = -1
						if(Key.isDown(Key.RIGHT))sens = 1
						vx += sens*FLIGHT_CONTROL*Timer.tmod;
					}
					updateJump();
				}

				while( downcast(bouncer).isRoundFree(bouncer.px,bouncer.py) != null ){
					bouncer.py--;
				}
				break;

			case 1:	// WALK
				walk();
				if( Cs.game.step==1){
					updateJump();
					if(Cs.game.cList.length==0 && Cs.game.boss.step==4 ){
						Cs.game.initStep(9);
					}
				}
				x = int(Cs.mm(lim,x,Cs.mcw-lim))
				break;

			case 2: // KICK !

				break;
		}
		if( y > Cs.HEIGHT ){
			Cs.game.initStep(9);
		}

	}

	function col(a,n){
		// LAND
		//var p = Math.min(Math.sqrt(vx*vx+vy*vy)*0.1, 0.8)
		if( Math.abs(Cs.hMod(1.57-n,3.14)) < 1.57 ){
			initStep(1)
		}

	}

	function walk(){
		// CONTROL


		if( Key.isDown(Key.LEFT) ){
			speed -= ACC*Timer.tmod;
			root._xscale = -100
		}
		if( Key.isDown(Key.RIGHT) ){
			speed += ACC*Timer.tmod;
			root._xscale = 100
		}
		speed *= Math.pow(SP_FRICT,Timer.tmod)

		if( jumpPower != null ){
			speed = 0;
		}

		var parc = Math.abs(speed)
		var sens = int(speed/parc)

		if( jumpPower == null ){
			frame = (frame+parc)%WALK_FRAME_MAX
			root.smc.gotoAndStop(string(int(frame)+1))
		}

		while(parc>1){
			var rot = 0
			var cl = null;
			var flJump = false;
			for( var i=0; i<CLIMB_MAX; i++ ){
				if (Cs.game.isFree(px+sens,py-i) ){
					cl= i
					break;
				}
			}
			if(cl==0){
				for( var i=0; i<CLIMB_MAX; i++ ){
					if(Cs.game.isFree(px+sens,py+1-cl) ){
						cl--
					}else{
						break;
					}
				}
				if(cl==-CLIMB_MAX){
					cl = null;
					flJump =true;
				}
			}


			if(cl!=null){
				if( cl <= CLIMB_SPEED && cl >= -CLIMB_SPEED){
					px += sens;
					py -= cl;

				}else{
					py -= int(Cs.mm(-CLIMB_SPEED, cl, CLIMB_SPEED))
				}
			}else{
				if(flJump){
					initStep(0)
					while( downcast(bouncer).isRoundFree(bouncer.px,bouncer.py) != null ){
						bouncer.py--;
					}
					vx = sens*3
					vy = -3
					root.gotoAndStop("fly")
					flOrient = true;
				}else{
					speed *= -1
				}


				break;
			}
			parc--
		}

		// Y RECAL
		while(!Cs.game.isFree(px,py))py--;

		// CORN
		for( var i=0; i<Cs.game.cList.length; i++ ){
			var sp = Cs.game.cList[i]
			if( sp.bouncer!=null && getDist(sp)<16 ){
				/*
				var sc = Cs.COMBO[0]
				Cs.game.setScore(sp.x,sp.y,sc,100)
				var a = getDist(sp)
				var pw = 5
				sp.explode(Math.cos(a)*pw,Math.sin(a)*pw);
				speed = 0
				*/
				sp.vx += 5*sens
				sp.vy -= 2
			}
		}




		x = px
		y = py

	}

	function updateJump(){



		if(jumpPower!=null){

			// CONTROL

			var acc = 0.1//0.15
			if( Key.isDown(Key.LEFT) ){
				jumpAngle -= acc
			}
			if( Key.isDown(Key.RIGHT) ){
				jumpAngle += acc
			}
			//jumpAngle *= 0.9




			// POWEER
			jumpPower += 5*Timer.tmod;
			jumpPower *= Math.pow(0.8,Timer.tmod)


			// TRG
			if(trg!=null){
				var a = jumpAngle - 1.57
				var dx = Math.cos(a)*6
				var dy = Math.sin(a)*6
				bouncer.setPos(trg.x+dx,trg.y+dy)
				root._rotation = a/0.0174 + 90
			}

			// CIRCLE
			jumpCircle._xscale = 1.25*jumpPower*3
			jumpCircle._yscale = jumpCircle._xscale
			jumpCircle._x = x;
			jumpCircle._y = y;
			downcast(jumpCircle).cran._rotation = jumpAngle/0.0174
			downcast(jumpCircle).cran._xscale = 10000/jumpCircle._xscale
			downcast(jumpCircle).cran._yscale = 10000/jumpCircle._yscale




			// AUTO RELEASE
			if(jumpPower>18)releaseJump();


		}


	}

	function action(){
		if(Cs.game.step==1){
			if(step == 0 && trg == null && extraJump>0 ){
				var sens = 0
				if(Key.isDown(Key.LEFT))sens=-1;
				if(Key.isDown(Key.RIGHT))sens=1;
				vy = -10
				vx += sens*3
				extraJump--

				var mc = downcast(Cs.game.dm.attach("mcImpact",Game.DP_PART))
				mc._x = x;
				mc._y = y;
				mc._xscale = 50
				mc._yscale = mc._xscale
				mc.frame = 0
				mc.fs = 9
				Cs.game.animator.push(mc)

			}

			if(jumpPower != null ){
				releaseJump();
			}

			if( jumpPower == null && step == 1 ){
				initJump();
			}
		}
	}

	function releaseJump(){
		if(jumpPower>5){
			initStep(0)

			while( downcast(bouncer).isRoundFree(bouncer.px,bouncer.py) != null ){
				bouncer.py--;
			}

			vx = Math.cos(jumpAngle-1.57)*jumpPower
			vy = Math.sin(jumpAngle-1.57)*jumpPower

			flOrient = true;
			root.gotoAndStop("fly")
			root._xscale = 100

		}
		jumpCircle.removeMovieClip();
		jumpPower = null;



		if(trg!=null){

			var sc = Cs.COMBO[comboIndex]
			Cs.game.setScore(trg.x,trg.y,sc,100)
			comboIndex = int(Math.min(comboIndex+1, 8));

			//
			trg.explode(-vx*0.5,-vy*0.5);
			trg = null;
		}



	}

	function initJump(){
		Cs.game.initGrey();
		if(jumpPower!=null){
			jumpCircle.removeMovieClip();
		}
		extraJump = 1
		jumpPower = 0
		jumpCircle = Cs.game.dm.attach("mcPowerCircle",Game.DP_BG)
		if(trg==null)downcast(jumpCircle).cran._visible = false;
		jumpAngle = 0;
	}






//{
}