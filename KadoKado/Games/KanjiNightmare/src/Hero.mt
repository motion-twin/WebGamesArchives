class Hero extends Phys{//}

	static var FLY = 0;
	static var GROUND = 1;
	static var DEATH = 2;
	static var KICK = 3;

	static var DL = 560;
	static var CEIL = 30;
	static var WEIGHT = 0.5;



	static var SPEED = 6
	static var JUMP_EXTEND = 3
	static var JUMP_START = 6
	static var GSPEED = 40;//30;

	static var GP_DIST = 30;
	static var GP_POWER = 0.6;

	static var FL_MOUSE_CONTROL = false;
	static var FL_EXTRA_JUMP = false;



	var plat:Plat;

	var optList:Array<bool>;

	volatile var kunaiMax:int;
	volatile var kunaiLeft:int;

	volatile var auraTimer:float;

	volatile var starMax:int;
	volatile var starLeft:int;
	volatile var hp:int;

	var wframe:float;
	var noColTimer:float;
	var flShootReady:bool;
	var flFlyUp:bool;
	var flWalk:bool;
	var flBall:bool;
	var flDeath:bool;
	var flEat:bool;
	var flDownReady:bool;
	var flExtraJumpReady:bool;
	var sens:int;
	var pitch:int;
	volatile var extraJump:int;
	volatile var boost:float;
	var checkGroundSafe:float;
	var noControlTimer:float;

	var cooldown:float;

	var gp:Grap;
	var step:int;
	var nextAnim:String;

	var kickBmp:flash.display.BitmapData;

	var auraColId:int;
	var auraColSens:int;
	volatile var auraLoopTimer:float;
	var auraCol:Array<int>

	var mcStarCount:{>MovieClip,field:TextField};
	var kList:Array<MovieClip>;
	var iconList:Array<MovieClip>

	function new(mc){
		super(mc);

		frict = 0.99;
		x = Cs.mcw*0.5;
		y = Cs.mch*0.5;

		flBall = false;
		flDeath = false;
		flEat = false;

		ray = 12;
		cooldown = 0;
		kunaiMax = 3
		kunaiLeft = kunaiMax
		hp = 1

		starMax = 200;
		starLeft = 30;

		optList = [false,false,false,false,false];
		iconList = [];

		initStep(FLY);
		setSens(1);
		if(FL_MOUSE_CONTROL){
			var o = {
				onMouseDown:callback(this,onAction),
				onMouseUp:null,
				onMouseWheel:null
				onMouseMove:null
			}
			Mouse.addListener(o);
		}

		initInterface();

		/*
		Cs.glow(root,2,4,0xFFFFFF)
		Cs.glow(root,12,1,0xFFAAAA)
		*/
	}

	function initStep(n){
		step = n;
		switch(step){
			case FLY :

				if(vy<0){
					nextAnim="fly_up";
					flFlyUp = true;
				}else{
					nextAnim="fly_down";
					flFlyUp = false;
				}

				weight = WEIGHT;
				flBall = false;
				break;
			case GROUND :
				fillKunai();
				vx = 0;
				vy = 0;
				weight = 0;
				if(nextAnim==null)nextAnim="land";
				//root.gotoAndPlay("land");
				if(gp!=null){
					releaseGrap();
				}
				flWalk = false;

				break;
			case DEATH:
				weight = WEIGHT;
				flDeath = true;
				KKApi.gameOver(Cs.game.stats);
				nextAnim="death";
				break;
			}
	}

	function update(){

		//updateKick()

		super.update();
		// CHECK CEIL
		if( y<CEIL ){
			y = CEIL;
			vy *= 0.5;
		}
		//
		if(flDeath)return;
		if(step!=KICK)root._rotation = 0

		updateNoCol();

		// CONTROL
		if(!flEat )control();

		// BOOST
		if(boost!=null){
			boost*=Math.pow(0.7,Timer.tmod);
			if(boost<0.1)boost=null;
		}

		// CHECK
		checkDeath()
		checkBonus()

		// AURA
		if(auraTimer!=null)updateAura();

		switch(step){
			case FLY :

				// DEATH CUT
				if(flDeath)return;

				// CHECK DEATH
				if(y>DL){
					flDeath = true;
					KKApi.gameOver(Cs.game.stats);
					releaseGrap();
					onAction = null;
					nextAnim = "fly_down"
				}

				// GP
				if(gp!=null ){

					if(!gp.flFly){
						var dist = getDist(gp);
						var a = getAng(gp);
						if(dist>GP_DIST){
							var c = (dist-GP_DIST)/GP_DIST;

							vx += Math.cos(a)*c*GP_POWER*1.5;
							vy += Math.sin(a)*c*GP_POWER;

						}
						var st = [ [4,0x7E2301], [2,0xFEAA8B] ]
						for( var i=0; i<2; i++ ){
							Cs.game.mcLine.lineStyle(st[i][0],st[i][1],100)
							Cs.game.mcLine.moveTo(x,y-15);//traceLine();
							Cs.game.mcLine.lineTo(gp.x,gp.y);//traceLine();
						}
						//root._rotation = (a/0.0174 + 90 )*0.3;

						// ROPE ARM
						var dx = gp.x-x;
						var dy = gp.y-y;
						var angle = Math.atan2(dy,dx*sens);

						root._rotation = vx*0.5;

						var mc = downcast(root)

						mc.arm._rotation = angle/0.0174 - root._rotation;
						var lim = 30
						mc.head._rotation =Cs.mm(-lim,vy,lim)
						lim = 50
						mc.leg0._rotation = Cs.mm(-lim,vx*4*sens,lim)
						mc.leg1._rotation =  Cs.mm(-lim,vx*4*sens,lim)


					}

					// ANIMS



					/*
					if( flFlyUp && vy>0){
						root.gotoAndPlay("fly_down");
						flFlyUp = false;
					}
					if( !flFlyUp && vy<0){
						root.gotoAndPlay("fly_up");
						flFlyUp = true;
					}
					*/
				}

				// PLAT
				checkPlatCol();

				//Log.print(flFlyUp);
				if( flFlyUp && vy>0 ){
					if(nextAnim==null)nextAnim="fly_down";
					flFlyUp = false;
				}



				break;

			case GROUND :
				if(x<plat.x || x>plat.x+plat.w ){
					initStep(FLY);
					vy = -2;
					plat = null;
				}

				break;
			case KICK:
				checkPlatCol();
				updateKick();
				break;
		}



		//RECAL
		if(x<13-Cs.game.scrollMin){
			x = 13-Cs.game.scrollMin;
		}
		// ANIM
		if(nextAnim!=null){
			root.gotoAndPlay(nextAnim);
			nextAnim = null;
		}
	}

	function control(){


		// COOLDOWN
		if(cooldown>0)cooldown-=Timer.tmod;

		if(noControlTimer!=null){
			noControlTimer-=Timer.tmod;
			if(noControlTimer<0)noControlTimer=null;
			return;
		}

		// PITCH
		pitch = 0;
		if( Key.isDown(Key.LEFT) ) pitch=-1;
		if( Key.isDown(Key.RIGHT) ) pitch=1;
		//if(noControlTimer!=null) pitch = 0;
		if(pitch!=0 && pitch!= sens && step!=KICK)setSens(pitch);

		var flDown = false;
		if( Key.isDown(Key.DOWN) ){
			if(flDownReady){
				flDown = true;
			}

		}else{
			flDownReady = true;
		}

		switch(step){
			case FLY :
				if(!flBall){
					var dvx = SPEED*pitch - vx;
					var lim = 0.5;//0.25
					var coef = 0.1;
					vx += Math.min(Math.max(-lim,dvx*coef),lim)
				}
				if(Key.isDown(Key.UP) ){
					if( flExtraJumpReady){
						if(  extraJump>0 ){
							jump();
							vx = SPEED*pitch;
							flBall = true;
							nextAnim="ball";
							extraJump--;
						}else {

							rope();
						}
						flExtraJumpReady = false;
					}else{
						if(boost!=null){
							vy -= JUMP_EXTEND*boost*Timer.tmod;
						}
					}

					/*
					vy = -8;
					vx = vx*0.5 + 8*pitch;
					root.gotoAndPlay("ball");
					flBall = true;
					extraJump--;
					*/
				}else{
					flExtraJumpReady = true;
					/*
					if(gp!=null){
						gp.drop();
						gp = null;
					}
					*/
				}


				if(flDown){
					if( gp!=null ){
						rope();
					}else{
						kick();

					}
				}
				break;

			case GROUND :
				if(pitch!=0){
					if(sens!=pitch)setSens(pitch);
					vx = SPEED*pitch;
					if(!flWalk){
						nextAnim="walk";
						wframe = 0
						flWalk=true;
					}
				}else{
					vx = 0;
					if(flWalk){
						nextAnim="wait";
						flWalk = false;
					}
				}

				if(flWalk){
					wframe = (wframe+(SPEED/7)*Timer.tmod)%11
					nextAnim = string(128+int(wframe))
				}


				if( Key.isDown(Key.UP) ){
					if(FL_EXTRA_JUMP)extraJump = 1;
					jump();
				}
				if( flDown ){
					jump();
					vy = -2.5;
					boost = 0;
					checkGroundSafe = 16;
				}
				break;
		}

		// TIR
		if( Key.isDown(Key.SPACE) || Key.isDown(Key.CONTROL) ){
			if( flShootReady && cooldown<=0 ){
				shoot();
			}
			flShootReady = false;
		}else{
			flShootReady = true;
		}
	}

	//
	function updateNoCol(){
		if(noColTimer==null)return;
		noColTimer -= Timer.tmod;

		var prc = 50+Math.cos(((noColTimer*100)%628)*0.01)*50
		if( noColTimer<0 ){
			noColTimer = null
			prc = 0
		}
		Cs.setPercentColor(root,prc,0xFFFFFF)
	}
	//
	function checkDeath(){

		for( var i=0; i<Cs.game.mList.length; i++ ){
			var m = Cs.game.mList[i]
			var dist = getDist(m)

			if(m.flCol && dist<26){


				if(auraTimer!=null){
					m.knockOut();
					m.vx = vx*2;
					m.vy = -(7+Math.random()*4);
					m.flCol = false;
					Cs.game.genScore(m.x,m.y,Cs.C200);
					return;
				}

				if( !m.flSpike){

						//var da  = Math.abs(getAng(m)-1.57)

						if(vy>0 ){
							vy=-7
							y = m.y-20
							m.harm(21,false)
							fillKunai();
							if(step==KICK){
								vx*=0.4
								step = FLY
								nextAnim = "fly_up"
								setSens(int(vx/Math.abs(vx)));
							}
							return
						}


				}
				if(noColTimer==null && dist<18){
					harm();


				}

			}


		}

	}
	function checkBonus(){
		for( var i=0; i<Cs.game.bonusList.length; i++ ){
			var sp = Cs.game.bonusList[i];
			if(getDist(sp)<20){
				sp.take();
				i--;
			}
		}
	}

	//
	function checkPlatCol(){
		if(checkGroundSafe!=null){
			checkGroundSafe -= Timer.tmod;
			if(checkGroundSafe<0 )checkGroundSafe=null;
			return;
		}
		//
		super.checkPlatCol();
	}
	function land(pl){
		initStep(GROUND);
		plat = pl;

		for( var i=0; i<3; i++ ){
			var p = Cs.game.newPart("partDust")
			p.x = x + (Math.random()*2-1)*14
			p.y = y + 12 + Math.random()*24
			p.weight = 0.1+Math.random()*0.3
			p.setScale(50+Math.random()*70)
			p.timer = 20+Math.random()*10

		}
	}

	function onAction(){
		return;
		shoot();
		return;
		switch(step){
			case FLY :
				if(gp!=null){
					releaseGrap();
					if(vy<0)nextAnim="ball";
				}else{
					var a = -1.57 + pitch*0.7;
					if(FL_MOUSE_CONTROL)a = getMouseAngle(0.3);
					gp = downcast(new Grap(Cs.game.mdm.attach("mcKunai",Game.DP_HERO)));
					gp.x = x;
					gp.y = y;
					gp.vx = Math.cos(a)+(vx*0.05);
					gp.vy = Math.sin(a);
					gp.speed = GSPEED;
					gp.flFly = true;
					gp.orient();
				}

				break;
			case GROUND :



				/*
				var mons = getNextMonster()
				if( mons != null){

				}else{

					var a = getMouseAngle(0.5);
					vx += Math.cos(a)*JUMP_POWER;
					vy += Math.sin(a)*JUMP_POWER - 3;
					initStep(FLY);
				}
				*/

				break;
		}

	}
	//
	function jump(){

		boost = 1;

		vy = -JUMP_START;
		flExtraJumpReady = false;
		initStep(FLY);
		nextAnim="fly_up";
	}
	function rope(){
		if(gp!=null){
			releaseGrap();
			if(vy<0)nextAnim="ball";
		}else{
			if(kunaiLeft>0){
				kunaiLeft--;
				var a = -1.57 + pitch*0.7;
				if(FL_MOUSE_CONTROL)a = getMouseAngle(0.3);
				gp = downcast(new Grap(Cs.game.mdm.attach("mcKunai",Game.DP_HERO)));
				gp.x = x;
				gp.y = y;
				gp.vx = Math.cos(a)+(vx*0.05);
				gp.vy = Math.sin(a);
				gp.speed = GSPEED;
				gp.flFly = true;
				gp.orient();
			}
			updateInterface();
		}
	}
	function grap(){
		nextAnim="rope";
	}
	function shoot(){
		var o = getNextMonster()
		var speed = 16;

		var a = sens*1.57 - 1.57;

		if(o!=null){
			var trg = {x:o.mons.x,y:o.mons.y}
			if(o.mons.vx!=null){
				var d = getDist(trg);
				var coef = d/speed;
				trg.x += o.mons.vx*coef;
				trg.y += o.mons.vy*coef;
			}
			a = getAng(trg);



		}

		var dsLim = 60
		if( step == GROUND && o.dist<dsLim){
			var list = getMonsterList();
			var dx = o.mons.x - x;
			var sens = Math.abs(dx)/dx
			for( var i=0; i<list.length; i++ ){
				var o2 = list[i]
				if( (o2.m.x-x)*sens < 0 && o2.d<dsLim ){
					doubleStrike([o.mons,o2.m])
					return;
				}
			}
		}

		var flNear = o.dist<optList[0]?76:52;
		if( flNear || starLeft == 0 ){
			slash(o.mons,flNear)
			return;
		}

		incStar(-1);
		updateInterfaceField();
		var shot = new Star(Cs.game.mdm.attach("mcNinjaShot",Game.DP_SHOT));


		shot.x = x;
		shot.y = y;
		shot.vx = Math.cos(a)*speed;
		shot.vy = Math.sin(a)*speed;
		if(optList[1]){
			shot.damage*=2;
			shot.root.gotoAndStop("2")
		}else{
			shot.root.stop();
		}
		shot.frict = 1;
		cooldown = 2
	}
	function slash(trg,flNear){
		cooldown = 8;
		downcast(root).bfx.gotoAndPlay("2");
		var bf = "1"
		if(optList[0])bf="2";
		downcast(root).bfx.blade.gotoAndStop(bf);
		if(flNear){
			var a = getAng(trg)
			if( (trg.x-x)*sens < 0 )setSens(-sens);
			trg.cut(21)
			if(trg.hp>0){
				vx = -5*sens
			}

		}
	}
	function kick(){
		if(!optList[5])return;
		flDownReady = false;
		var distMin = 9999
		var mons = null;
		for( var i=0; i<Cs.game.mList.length; i++ ){
			var m = Cs.game.mList[i]

			var dx = m.x - x
			var dy = m.y - y

			if( dy > 20 && dy<220 && Math.abs(dx)<80 ){
				var dist = Math.abs(dx)+Math.abs(dy)
				if(dist<distMin){
					mons = m;
					distMin = dist;
				}

			}


		}

		if(mons!=null){
			var trg = {x:mons.x,y:mons.y}
			var sp = 16


			var dy = mons.y - y
			var c = dy/sp

			var npx = mons.x+mons.vx*c;
			var dx = npx - x;

			vx =  dx/c;
			vy = sp;


			/*
			var dist = getDist(trg)
			var c = dist/sp;
			trg.x += mons.vx*c;
			trg.y += mons.vy*c;

			var a = getAng(trg);
			vx = Math.cos(a)*sp;
			vy = Math.sin(a)*sp;
			*/

			//Log.trace("kick!!!")

			step = KICK;
			root.gotoAndPlay("kick")
			nextAnim = "kick";

			setSens(1)
			root._rotation = Math.atan2(vy,vx)/0.0174 + (sens==-1)?180:0;

			if(kickBmp!=null)kickBmp.dispose();
			kickBmp = getSnapshot(60)

		}



	}
	function doubleStrike(a:Array<Monster>){
		for( var i=0; i<a.length; i++ ){
			var mons = a[i]
			mons.harm(100,false);
			nextAnim = "doubleStrike"
			root.gotoAndPlay("doubleStrike")
		}
		noControlTimer  = 5
		vx = 0;
		var mc = Cs.game.mdm.attach("mcOnde",Game.DP_ROPE);
		mc._x = x;
		mc._y = y;
		Cs.game.registerMc(mc)
		Cs.game.genScore(x,y-25,Cs.C1000)
	}

	//
	function releaseGrap(){

		if( flFlyUp && vy>0){
			if(nextAnim==null)nextAnim="fly_down";
			flFlyUp = false;
		}
		if( !flFlyUp && vy<0){
			if(nextAnim==null)nextAnim="fly_up";
			flFlyUp = true;
		}
		gp.drop();
		gp = null;
	}
	function initAura(){
		auraTimer = 500
		auraCol = [255,0,0]
		auraColId = 1
		auraColSens = 1
		auraLoopTimer = 0
	}
	function updateAura(){
		auraTimer-=Timer.tmod;
		if(auraTimer<0)auraTimer = null;
		if(auraTimer>20 ){
			if(auraLoopTimer>0){
				auraLoopTimer-= Timer.tmod;//Math.sqrt(vy*vy + vx*vx)*Timer.tmod;
				return;
			}
			//auraLoopTimer = 2.5//10


			var bmp = getSnapshot(70);

			var mc = Cs.game.mdm.empty(Game.DP_ROPE)
			mc.attachBitmap(bmp,0)
			var p = new Part(mc)
			p.x = x-bmp.width*0.5;
			p.y = y-bmp.height*0.5;
			p.timer = 1500;
			p.bmp = bmp;
			p.updatePos();
			p.timer = 15


			// auracol
			auraCol[auraColId] = Cs.mm(0,auraCol[auraColId]+auraColSens*50,255)
			if( auraCol[auraColId] == 255 ){
				auraColId = Cs.sMod(auraColId-1,2);
				auraColSens = -1;
			}else if( auraCol[auraColId] == 0 ){
				auraColId = Cs.sMod(auraColId+2,2);
				auraColSens = 1;
			}
			var col = {r:auraCol[0],g:auraCol[1],b:auraCol[2]}
			Cs.setPercentColor(p.root,30,Cs.objToCol(col));

			Cs.glow(p.root,4,4,0xFFFFFF)
			Cs.glow(p.root,20,1,Cs.objToCol(col))

		}



	}

	//
	function getSnapshot(size){
		var bmp = new flash.display.BitmapData(size,size,true,0x00000000);
		var m = new flash.geom.Matrix();
		m.scale(root._xscale/100,root._yscale/100)
		m.rotate(root._rotation*0.0174)
		m.translate(size*0.5,size*0.5);
		bmp.draw(root,m,null,null,null,null);
		return bmp;
	}
	function updateKick(){
		setSens(1)
		var bmp = kickBmp;
		var mc = Cs.game.mdm.empty(Game.DP_MONS)
		mc.attachBitmap(bmp,0)
		var p = new Part(mc)
		p.x = x-bmp.width*0.5;
		p.y = y-bmp.height*0.5;
		p.timer = 10;
		p.fadeLimit = 6
		p.updatePos();
		Cs.setPercentColor(p.root,100,0xFF00FF);

	}

	//
	function harm(){
		if(hp>0){
			hp--;
			releaseGrap();

			root.removeMovieClip();
			root = Cs.game.mdm.attach("mcHeroSlip",Game.DP_HERO);
			updatePos();
			setSens(sens);
			Cs.glow(root,3,2,0x662200);

			noColTimer = 70;

			initStep(FLY);
			for( var i=0; i<50; i++ ){
				var p = Cs.game.newPart("mcCombi")
				p.x = x+(Math.random()*2-1)*4;
				p.y = y+10 -i*4;
				p.vx = vx*(1.2+Math.random()*0.8)
				p.vy = vy*(1.2+Math.random()*0.8) - (2+Math.random()*7)
				p.timer = 50+Math.random()*10
				p.weight = 0.1+Math.random()*0.2
				p.vr = (Math.random()*2-1)*6


				p.root.gotoAndStop(string(i+1))
				if(i+1==p.root._totalframes){
					p.flPlatCol = true;
					p.ray = 10
					p.vr *= 3
					break;
				}

			}


		}else{
			initStep(DEATH);
		}
		vy-=5;
		vx-=3;
	}
	function hpUp(){
		hp=1;
		var fr = root._currentframe;
		root.removeMovieClip();
		root = Cs.game.mdm.attach("mcHero",Game.DP_HERO);
		root.gotoAndStop(string(fr))
		updatePos();
		setSens(sens);

	}

	// INTERFACE
	function initInterface(){
		kList =[]
		mcStarCount = downcast(Cs.game.dm.attach("mcStarCount",Game.DP_INTER));
		Cs.glow(mcStarCount.field,2,2,0)
		updateInterface();
	}
	function updateInterface(){
		for( var i=0; i<kunaiMax; i++ ){
			var mc = kList[i]
			if(mc==null){
				kList[i] = Cs.game.dm.attach("mcInterKunai",Game.DP_INTER);
				mc = kList[i];
				mc._x = i*12
			}
			mc.smc._alpha = (kunaiLeft>i)?100:10;
		}
		mcStarCount._x = kunaiMax*12 + 2;
		updateInterfaceField();

	}
	function updateInterfaceField(){
		mcStarCount.field.text = string(starLeft);
	}
	function updateIcons(){
		while(iconList.length>0)iconList.pop().removeMovieClip()
		var x = Cs.mcw
		for( var i=0; i<optList.length; i++ ){

			if(optList[i]){
					var mc = Cs.game.dm.attach("mcIcon",Game.DP_INTER);
				mc.gotoAndStop(string(i+1));
				mc._x = x;
				x-=20;
				iconList.push(mc)
			}
		}
	}
	function fillKunai(){
		kunaiLeft = kunaiMax;
		updateInterface();
	}
	function incStar(n){
		starLeft = int(Cs.mm(0,starLeft+n,starMax));
		updateInterfaceField();
	}
	function incKunai(n){
		kunaiMax+=n;
		fillKunai();
	}
	//
	function setSens(n){
		sens = n;
		root._xscale = n*100;
	}
	function getNextMonster(){

		var distMin = 250;
		var mons = null;
		for( var i=0; i<Cs.game.mList.length; i++ ){
			var m = Cs.game.mList[i];
			var d = Math.abs(m.x-x)+Math.abs(m.y-y);
			if( d<distMin){
				distMin = d;
				mons = m;
			}
		}
		if(mons!=null)return {mons:mons,dist:distMin};



		if(!Cs.game.flMouseDead && mons==null){
			var mp = {x:Cs.game.map._xmouse+7,y:Cs.game.map._ymouse+7}
			var dist = getDist(mp)
			if(dist<140 && dist>50)return {mons:mp,dist:dist};
		}
		return null;
	}

	function getMonsterList():Array<{d:float,m:Monster}>{
		var list = []

		for( var i=0; i<Cs.game.mList.length; i++ ){
			var m = Cs.game.mList[i]
			var d =Math.abs(m.x-x)+Math.abs(m.y-y);
			var n = 0
			do{
				if(list[n].d>d)break;
				n++
			}while(n<list.length)
			list.insert(n,{m:m,d:d})
		}
		return list;
	}

	function getMouseAngle(ma){
		var mp = {x:Cs.game.map._xmouse,y:Cs.game.map._ymouse};
		return Cs.mm(-3.14+ma,getAng(mp),-ma);
	}


//{
}








