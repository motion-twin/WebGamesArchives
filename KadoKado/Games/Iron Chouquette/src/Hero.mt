class Hero extends Phys{//}

	static var WP_PLASMA =	0;
	static var WP_SIDER =	1;
	static var WP_LASER =	2;
	static var WP_SPEED =	3;
	static var WP_VOID =	4;
	static var WP_MISSILE = 5;

	static var RAY = 8;
	static var INVINCIBLE_RAY = 32;

	var flControl:bool;

	volatile var slotMax:int;
	var speed:float;
	var rollX:float;
	var rollY:float;
	volatile var invincibleTimer:float;


	var dm:DepthManager;

	// LASER
	var laserStartAngle:float;
	var laserTrg:{x:float,y:float,ray:float,damage:float->void,flDeath:bool,shieldLim:float}
	var laserFlip:int;
	var laserList:Array<Array<float>>
	var laserRay:{>MovieClip, t:float,ray:MovieClip,dm:DepthManager,list:Array<{>MovieClip,vr:float,t:float}>}

	// SONIC BOOM
	var onde:{>MovieClip,list:Array<Bads>};
	var blackHole:{>MovieClip,vr:float,step:int,list:Array<{>Part,mask:MovieClip,black:float}>};


	var boxes:PArray<MovieClip>;
	var slots:Array<int>;
	var cslots:Array<int>;
	var weapons:Array<Array<int>>;
	var cweapons:Array<Array<int>>;

	var lastLaser:MovieClip;

	function new(mc){
		super(mc)
		ray = RAY
		speed =3.6
		frict = 0.6

		laserStartAngle = 0;
		laserFlip = 0

		rollX = 0
		rollY = 0

		slots = []
		cslots = []
		weapons = []
		cweapons = []
		boxes = new PArray();
		for(var i=0; i<3; i++)addBox();
		for(var i=0; i<6; i++ ){
			weapons[i] = [(i==0)?1:0,0]
			cweapons[i] = [(i==0)?1:0,0]
		}

		dm = new DepthManager(root)
		flControl = false;
		root.gotoAndStop("10");

		x = Cs.mcw*0.5 - 5;
		y = Cs.mch+ray

	}

	function update(){
		super.update();

		if(flControl){
			control();
			updateShoot();
		}else{
			y-=0.8*Timer.tmod;
		}



		if(onde!=null)updateOnde();
		if(laserRay!=null)updateLaserRay();
		if(blackHole!=null)updateBlackHole();
		if(invincibleTimer!=null)updateInvincible();

		if(!flControl  && Stykades.dif>56 ){
			Game.SCROLL_SPEED+=2.4;
			flControl = true;
		}


		// CHECK CHEAT
		for( var i=0; i<6; i++ ){
			if( weapons[i][0] != cweapons[i][0] )KKApi.flagCheater();
		}
		for( var i=0; i<slots.length; i++ ){
			if( slots[i] != cslots[i] )KKApi.flagCheater();
		}
		if( boxes.getCheat() ) KKApi.flagCheater();

	}

	function updateInvincible(){
		invincibleTimer-=Timer.tmod;

		Cs.setPercentColor(root,70+Math.cos(invincibleTimer*0.5)*20,0xFFFFFF)

		var size = Math.min(invincibleTimer/50,1)
		// PARTS

		var p = new Part(Cs.game.dm.attach("partInvincibility",Game.DP_UNDERPARTS))
		var a = Math.random()*6.28
		var ca = Math.cos(a);
		var sa = Math.sin(a);
		var r = 0//Math.random()*ray
		var sp = 1.5+Math.random()*1.5
		p.x = x
		p.y = y-6
		p.vx  = ca*sp;
		p.vy  = sa*sp + 4
		p.plasmaId = 1;
		p.timer = 10
		p.fadeType = 0
		p.root.blendMode = BlendMode.ADD;
		p.setScale((150+Math.random()*100)*size)

		if(invincibleTimer<0){
			invincibleTimer = null;
			ray=RAY;
			Cs.setPercentColor(root,0,0xFFFFFF)
		}
		var pdm = new DepthManager(p.root)

		//
		if(Math.random()*3<1){
			var mc = pdm.attach("mcLaserLight",0)
			mc._rotation = Math.random()*360
			mc._xscale = 100+Math.random()*100
			mc._yscale = 50+Math.random()*100
		}



	}

	function control(){
		var boost = weapons[3][0]
		var sp = Math.min( speed + boost*1.6, 10)*Timer.tmod

		// MOVE
		var mx = 0
		var my = 0
		var bent = 0.25
		if( Key.isDown(Key.LEFT) ){
			mx -= sp
			laserStartAngle -= bent;
			rollX -= Timer.tmod*5
		}
		if( Key.isDown(Key.RIGHT) ){
			mx += sp
			laserStartAngle += bent;
			rollX += Timer.tmod*5
		}
		if( Key.isDown(Key.UP) ){
			my -= sp
			rollY -= Timer.tmod*3.5
		}
		if( Key.isDown(Key.DOWN) ){
			my += sp
			rollY += Timer.tmod*3.5
		}
		rollX *= 0.6
		rollY *= Math.pow(0.87,Timer.tmod)
		laserStartAngle *= Math.pow(0.94,Timer.tmod)

		// BOOST

		if( boost > 0 ){
			var max = 2
			for( var k=0; k<max; k++ ){
				var coef = k/max
				var mc = Cs.game.dm.attach("mcSpeed",Game.DP_PARTS)
				mc._x = x+mx*coef;
				mc._y = y+(my+Game.SCROLL_SPEED)*coef;
				mc._xscale = (120 + boost*40)*1.7;
				//
				mc._yscale = mc._xscale;
				mc.gotoAndStop(string(boost));
				//mc.blendMode = BlendMode.ADD
				Cs.game.plasmaDraw(mc,0);



				for( var i=0; i<3; i++ ){
					var a = Math.random()*6.28;
					var ray = 20+Math.random()*50;
					mc._x = x + Math.cos(a)*ray;
					mc._y = y + Math.sin(a)*ray;
					mc._xscale = 100+Math.random()*150;
					mc._yscale = mc._xscale;
					Cs.game.plasmaDraw(mc,0);

				}


				mc.removeMovieClip();


			}

			var r = ray*(((60 + boost*40)*1.7)/100)*1.3
			for( var i=0; i<boost; i++ ){
				var p = new Part(Cs.game.dm.attach("partSparkSpeed",Game.DP_UNDERPARTS))
				p.x = x + (Math.random()*2-1)*r
				p.y = y + (Math.random()*2-1)*r
				p.setScale(10+Math.random()*(15+boost*5))
				p.root.gotoAndPlay( string( Std.random(p.root._totalframes)+1 ) )
				downcast(p.root).compt = 100//Std.random(1+boost)
				p.vy = Game.SCROLL_SPEED
				p.timer = 20+Math.random()*10

			}

		}



		x+=mx;
		y+=my;

		//GFX
		var frame = 1+int(Cs.mm(0,10+rollX,20))
		root.gotoAndStop(string(frame))

		// COL
		checkBounds();

	}

	// WEAPON
	function addWeapon(id){


		if(slots.length==boxes.length){
			sacrifice(0);
		}
		weapons[id][0]++;
		cweapons[id][0]++;
		slots.push(id);
		cslots.push(id);
		updateBoxes();


	}

	function addBox(){
		var mc = Cs.game.dm.attach("mcSlot",Game.DP_INTER)
		var m = 8
		mc._x = m
		mc._y = Cs.mch-( m + boxes.length*(m+6) )
		mc.stop();
		boxes.push(mc)
	}

	function updateBoxes(){
		for( var i=0; i<boxes.length; i++ ){
			var id = slots[i]
			if(id==null)id=-1;
			boxes[i].gotoAndStop(string(id+2))
		}
	}

	function sacrifice(n){
		if(slots.length==0)return;
		if(n==null)n=slots.length-1
		var id = slots[n]
		weapons[id][0]--;
		cweapons[id][0]--;
		slots.splice(n,1)
		cslots.splice(n,1)
		updateBoxes();

		Cs.game.stats.$b.push([Stykades.dif,100+id])
		switch(id){
			case WP_PLASMA:
				var shot = newShot(0,14);
				shot.setSkin(18,1)
				shot.ray = 50
				shot.damage = 50
				shot.flPierce = true
				shot.bList.push(11)
				//shot.vr = (Math.random()*2-1)*10
				break;

			case WP_SIDER:
				if(onde!=null)onde.removeMovieClip();
				onde = downcast(Cs.game.dm.attach( "mcSonicBoom", Game.DP_UNDERPARTS ))
				onde.list = new Array()
				onde._x = x;
				onde._y = y;
				onde._xscale = 80
				onde._yscale = onde._xscale
				break;

			case WP_VOID:
				if( blackHole!=null )break
				blackHole = downcast(Cs.game.dm.attach( "mcBlackHole", Game.DP_UNDERPARTS ))
				blackHole.list = new Array()
				blackHole._x = x;
				blackHole._y = y;
				blackHole.step = 0;
				blackHole._xscale = 10;
				blackHole._yscale = 10;
				blackHole.vr = 10;

				var list:Array<Phys> = new Array()
				for( var i=0; i<Cs.game.badsList.length; i++ )list.push(Cs.game.badsList[i])
				for( var i=0; i<Cs.game.shotList.length; i++ )list.push(Cs.game.shotList[i])

				while(list.length>0){
					var b = list.pop();
					if(b.flash!=null){
						b.flash=0
						b.updateFlash();
					}
					var p = downcast(new Part(b.root));
					p.x = b.x
					p.y = b.y
					p.vx = b.vx
					p.vy = b.vy
					p.frict = 0.94
					p.ray = b.ray
					p.black = 0;
					b.root = null
					b.kill();
					blackHole.list.push(p)
				}



				/*
				while( blackHole.list.length<150 ){
					var p =  downcast(new Part(Cs.game.dm.attach("partBlackHole",Game.DP_PARTS)))
					p.x = Math.random()*Cs.mcw
					p.y = Math.random()*Cs.mch
					p.ray2 = 14
					p.frict = 0.94
					blackHole.list.push(p)
				}
				*/
				break;

			case WP_SPEED:
				if( laserRay!=null )break
				laserRay = downcast(Cs.game.dm.attach("mcBigLaser",Game.DP_UNDERPARTS))
				laserRay.blendMode = BlendMode.ADD
				laserRay.ray._xscale = 0
				laserRay.dm = new DepthManager(laserRay)
				laserRay.list = new Array();
				for( var i=0; i<12; i++ ){
					var mc = downcast(laserRay.dm.attach("mcLaserRay",0))
					mc._rotation = Math.random()*360
					mc._xscale = 100+Math.random()*100
					mc._yscale = 100+Math.random()*500
					mc.t = 10+Math.random()*50
					mc.blendMode = BlendMode.ADD
					mc.vr = (Math.random()*2-1)*5
					laserRay.list.push(mc);
				}
				laserRay.t = 80
				break;

			case WP_LASER:
				invincibleTimer = 300;
				ray=INVINCIBLE_RAY;			// ADD

				break;

			case WP_MISSILE:
				var max = 12
				for( var i=0; i<max; i++ ){
					var shot = newMissile(6.28*i/max )
					shot.sleep = 6
					shot.timer = 60
				}
				break;
			case null:
				Cs.game.bt = {trg:0.3,timer:100,val:1}
				break;
		}
		// CLEAN SHOOT
		var list = Cs.game.shotList.duplicate();
		for( var i=0; i<list.length; i++ ){
			var shot = list[i]
			if(shot.flGood!=true)shot.kill()
		}
		//
		Cs.game.flashouille = 100;
		Cs.game.lagTimer = -70
		Stykades.nextWave = 100

	}

	function updateShoot(){
		var flFire = Key.isDown(Key.SPACE) || Key.isDown(18) || Key.isDown(Key.ENTER)

		if(lastLaser._visible)lastLaser.removeMovieClip();

		for( var i=0; i<6; i++ ){
			var a =weapons[i]
			if(a[0]>0){
				if(a[1]>0)a[1] =  a[1]-Timer.tmod;
				while( flFire && a[1]<=0 && blackHole==null && laserRay==null ){
					switch(i){
						case 0: //{ PLASMA
							switch(a[0]){
								case 1:
									var shot = newShot(0,12);
									shot.setSkin(14,1)
									shot.ray = 6
									shot.damage = 1
									break;
								case 2:
									for( var n=0; n<2; n++ ){
										var shot = newShot(0,12);
										shot.setSkin(14,1)
										shot.ray = 6
										shot.x = x+(n*2-1)*5
										shot.damage = 1
									}
									break;
								case 3:
									{
										var shot = newShot(0,15);
										shot.setSkin(14,1)
										shot.ray = 8
										shot.setScale(150)
										shot.damage = 2
										shot.flPierce = true

									}
									for( var n=0; n<2; n++ ){
										var sens = n*2-1
										var shot = newShot(sens*0.15,12);
										shot.setSkin(14,1)
										shot.ray = 8
										shot.x = x+sens*5
										shot.damage = 1
									}
									break;
								default:
									{
										var shot = newShot(0,15);
										shot.setSkin(14,1)
										shot.ray = 4+a[0]
										shot.setScale(100+a[0]*25)
										shot.damage = 1+(a[0]*0.5)
										shot.flPierce = true

									}
									for( var n=0; n<2; n++ ){
										var sens = n*2-1
										for( var k=0; k<a[0]*0.5; k++ ){

											var shot = newShot(sens*(0.15+k*0.15),12-(k*1.5));
											shot.setSkin(14,1)
											shot.ray = 8
											shot.x = x+sens*(5+k*5)
											shot.damage = 1

										}
									}



									break

							}
							a[1] += 8
							break;//}

						case 5: //{ MISSILES
							for( var n=0; n<2; n++){
								var sens = n*2-1
								for( var k=0; k<a[0]; k++ ){

									var c = (k/(a[0]-1))-0.5
									if(a[0]==1)c = 0
									var ec = 0.5+a[0]*0.2

									var shot = newMissile(sens*1.9 + ec*c);



								}

							}
							a[1] += 40;//50
							break;//}

						case 1: //{ SIDER
							for( var n=0; n<2; n++){

								var max = Math.min(a[0],6)
								for( var k=0; k<max; k++ ){

									var sens = n*2-1

									var c = (k/(max-1))-0.5
									if(max==1)c = 0
									var ec = 0.3+a[0]*0.1

									var shot = newShot( sens*(1.57-rollY*0.05) + ec*c, 14 );
									shot.setSkin(16,1);
									shot.damage = 0.85
									//shot.root._xscale = sens*100
									shot.x += sens*14
									shot.y += 16
									shot.orient();
									shot.updatePos();

									if( k>1 && k<max-1 ){
										shot.setScale(150)
										shot.damage = 1.5
										shot.speed = 18
										shot.updateVit();
										shot.x += sens*6
									}

								}
							}
							a[1] += 5//3.5
							break;//}

						case 2: //{ LASER

							// SEEK
							if( laserTrg == null || laserTrg.flDeath ){

								var dist = 1/0
								laserTrg = {x:x,y:-20,ray:10,damage:null, flDeath:true, shieldLim:null};
								for( var n=0; n<Cs.game.badsList.length; n++ ){
									var b = Cs.game.badsList[n]
									var d = getDist(b)
									if(d<dist){
										laserTrg = upcast(b);
										dist = d;
									}
								}
							}



							// CREATE LIST
							var op = [x,y-6]
							var list = [op]
							var angle = -1.57
							if(!laserTrg.flDeath)angle+=laserStartAngle;
							var va = 0.1
							var ca = 0.1
							var sp = 7
							var tr = 0


							while(true){
								var dx = laserTrg.x - op[0]
								var dy = laserTrg.y - op[1]
								var ta = Math.atan2(dy,dx)
								var da = Cs.hMod(ta-angle,3.14)
								angle += Cs.mm( -va, da*ca, va )
								var nx = op[0] + Math.cos(angle)*sp
								var ny = op[1] + Math.sin(angle)*sp
								if(laserTrg.shieldLim!=null){
									var dist = Cs.getDist( laserTrg, {x:nx,y:ny} )
									if(dist<laserTrg.shieldLim){
										angle = Cs.getAng(  {x:nx,y:ny}, laserTrg )+laserStartAngle*0.2
										ca = 0.5;
										va = 10;
									}

								}

								var np = [nx,ny]
								list.push(np)
								op=np;

								if( Math.abs(dx)+Math.abs(dy) < laserTrg.ray*0.5 ){
									break;
								}
								if( tr++>100 )break;

								ca = Math.min(ca+0.01,1)
								va += 0.01

							}

							// DRAW
							//*
							laserFlip = (laserFlip+1)%2
							var s0 = 12+(a[0]+laserFlip*2)*3	//18+laserFlip*20
							var s1 = 1+(a[0]+laserFlip)*2.5
							var mc = Cs.game.dm.empty(Game.DP_PARTS)

							mc.lineStyle( s0, 0xFF0000,30)
							mc.moveTo(list[0][0],list[0][1])
							for( var n=1; n<list.length; n++ ){
								var p = list[n]
								mc.lineTo(p[0],p[1])
							}

							mc.lineStyle(s1,0xFFFFFF,100)
							mc.moveTo(list[0][0],list[0][1])
							for( var n=1; n<list.length; n++ ){
								var p = list[n]
								mc.lineTo(p[0],p[1])
							}
							//*/

							//*
							var ba = 2
							var br = 2
							var ra = 3+s1
							mc.lineStyle(1,0xFFFFFF,100)
							for( var n=0; n<3; n++){
								var k = 0
								var st = Std.random(list.length-3)
								mc.moveTo(list[st][0],list[st][1])
								while( Std.random(k)==0 ){
									k++
									st = int(Math.min( st+ba+Std.random(br),list.length-1))
									var px = list[st][0] + (Math.random()*2-1)*ra
									var py = list[st][1] + (Math.random()*2-1)*ra
									mc.lineTo(px,py)
								}
								st = int(Math.min( st+ba+Std.random(br),list.length-1))
								mc.lineTo(list[st][0],list[st][1])


							}
							//*/


							//*
							if( Cs.game.gfxMode>=1 ){
								mc.blendMode = BlendMode.ADD;
								Cs.game.plasmaDraw(mc,1)
								mc.removeMovieClip();
							}else{
								lastLaser = mc;
							}
							//*/
							laserList = list;

							a[1] = 0.1
							break;//}
						case 4: //{ VOID BALLS


							var shot = newShot( (Math.random()*2-1)*(0.3+a[0]*0.15) , 10 );
							shot.setSkin(17,1);
							shot.damage = 1.2
							shot.orient();
							//shot.plasmaId = 1
							shot.bList.push(4)
							shot.speed = 12
							shot.decal = Math.random()*628

							a[1] +=  18/(a[0]*4)
							break;//}
						case 3:	//{ SPEED UP
							a[1] = 0.1
							break //}
					}
				}
			}
		}

		if(!flFire ){
			laserTrg = null
			laserList = null
		}

	}

	// SPECIAL
	function updateLaserRay(){
		laserRay._x = x;
		laserRay._y = y;
		if( laserRay.t >= 10 ){
			laserRay.ray._xscale += 32*Timer.tmod;
		}else{
			if( laserRay.t<0 && laserRay.ray._currentframe == 1 )laserRay.ray.play();
		}
		laserRay.ray._xscale *= Math.pow(0.9,Timer.tmod)
		laserRay.t -= Timer.tmod;

		for( var i=0; i<laserRay.list.length; i++ ){
			var mc = laserRay.list[i]
			var dr	= Cs.hMod(-90 -mc._rotation,180)

			mc._rotation += mc.vr+dr*0.03*Timer.tmod;
			mc._xscale += 10//(100/1+Math.abs(dr))
			mc.t-=Timer.tmod;

			if( laserRay.t < 10 ){
				mc._yscale *= 0.6
			}

			if(mc.t<10){
				mc._alpha = mc.t*10
				if(mc.t<0){
					mc.removeMovieClip();
					laserRay.list.splice(i--,1)
				}
			}

			/*
			var lim = 100
			mc._rotation +=Cs.mm(-lim,dr*0.2*Timer.tmod,lim);
			mc._xscale *= 1.05
			mc._yscale *= 0.95
			if(Math.abs(dr)<2){
				mc.removeMovieClip();
				laserRay.list.splice(i--,1)
			}
			//*/
		}

		while(laserRay.list.length< Math.min(12,laserRay.t*0.5) ){
			var mc = downcast(laserRay.dm.attach("mcLaserRay",0))
			mc._rotation = Math.random()*360
			mc._xscale = 100+Math.random()*100
			mc._yscale = 100+Math.random()*1000
			mc.t = 10+Math.random()*60
			mc.blendMode = BlendMode.ADD
			mc.vr = (Math.random()*2-1)*5
			laserRay.list.push(mc);
		}
		if(laserRay.t>0){
			for( var i=0; i<Cs.game.badsList.length; i++ ){
				var b = Cs.game.badsList[i]
				if( Math.abs(b.x-x)< (8*laserRay.ray._xscale/100)+b.ray && b.y<y ){
					b.damage(2.5*Timer.tmod)
				}
			}
		}else{
			if(laserRay.t<-10){
				laserRay.removeMovieClip();
				laserRay = null;
			}
		}


	}

	function updateOnde(){
		onde._xscale *= 1.25
		onde._yscale = onde._xscale

		for( var i=0; i<Cs.game.badsList.length; i++ ){
			var b = Cs.game.badsList[i]
			var flStrike = true;
			for( var n=0; n<onde.list.length; n++ ){
				if(b==onde.list[n]){
					flStrike = false;
					break;
				}
			}

			if( flStrike && b.getDist({x:onde._x,y:onde._y}) < onde._xscale*0.5  ){
				b.damage(5)
				onde.list.push(b)
			}
		}

		if(onde._xscale>Cs.mcw*2){
			onde.removeMovieClip();
			onde = null;
		}



	}

	function updateBlackHole(){

		blackHole.vr *= 1.05
		blackHole._rotation +=  12*Timer.tmod

		var acc = 1
		var bh = {x:blackHole._x,y:blackHole._y}
		var flAllMasked = true;

		for( var i=0; i<blackHole.list.length; i++ ){
			var p = blackHole.list[i]

			if(p.mask!=null){
				p.vx *= 1.2
				p.vy *= 1.2

				p.black = Math.min(p.black+8*Timer.tmod,100)
				Cs.setPercentColor(p.root,p.black,0)

				if( p.getDist(bh) > blackHole._xscale*0.5+p.ray ){
					p.mask.removeMovieClip();
					p.kill();
					blackHole.list.splice(i--,1);
				}
			}else{
				flAllMasked = false;

				var a = p.getAng(bh)
				p.vx += Math.cos(a)*acc*Timer.tmod
				p.vy += Math.sin(a)*acc*Timer.tmod

				if( p.getDist(bh) < blackHole._xscale*0.5-p.ray ){
					p.mask = Cs.game.dm.attach("mcRound",Game.DP_BADS)
					p.mask._x = bh.x
					p.mask._y = bh.y
					p.mask._xscale = blackHole._xscale
					p.mask._yscale = blackHole._yscale
					p.root.setMask(p.mask)
				}
			}
		}
		//Log.setColor(0xFF0000)
		//Log.trace(blackHole.step)
		switch(blackHole.step){
			case 0:
			case 2:
				var ts = (blackHole.step==0)?150:0;
				var ds = ts-blackHole._xscale
				blackHole._xscale += ds*0.3
				if( Math.abs(ds) < 1 ){
					blackHole.step++;
					blackHole._xscale = ts
				}
				blackHole._yscale = blackHole._xscale

				for( var i=0; i<blackHole.list.length; i++ ){
					var p = blackHole.list[i];
					if(p.mask!=null){
						p.mask._xscale = blackHole._xscale
						p.mask._yscale = blackHole._yscale
					}
				}
				break;
			case 1:
				if(flAllMasked)blackHole.step=2;
				break;
			case 3:
				if(blackHole.list.length==0){
					blackHole.removeMovieClip();
					blackHole = null;
				}
				break;
		}


	}

	//
	function newShot(a,speed){
		a -= 1.57
		var shot = new Shot(null)
		shot.a = a
		shot.flGood = true;
		shot.x = x;
		shot.y = y-20;
		shot.vx = Math.cos(a)*speed
		shot.vy = Math.sin(a)*speed

		return shot;
	}

	function newMissile(a){
		var shot = newShot(a,4);
		shot.y += 10
		shot.setSkin(15,1)
		shot.ray = 8
		shot.damage = 2
		shot.speed = 4
		shot.accel = {inc:0.5,max:16}
		shot.va = 0.2
		shot.ca = 0.1
		shot.orient();
		shot.queue = "mcQueueStandard"
		shot.bList.push(3);
		shot.timer = 120
		return shot;
	}

	//
	function hit(shot){
		explode();

	}

	function explode(){

		//PARTS
		for( var i=0; i<12; i++ ){
			var p = new Part( Cs.game.dm.attach("mcExploPart",Game.DP_PARTS) )
			p.setScale(20+Math.random()*30)
			var a = Math.random()*6.28
			var ca = Math.cos(a);
			var sa = Math.sin(a);
			var ray = 8;
			var sp = 6+Math.random()*6
			p.x = x + ca*ray;
			p.y = y + sa*ray;
			p.vx = ca*sp
			p.vy = sa*sp
			p.plasmaId = 1
			p.timer = 10+Math.random()*30
			p.frict = 0.96
			p.root.blendMode = BlendMode.ADD
			p.root._rotation = Math.random()*360
		}
		// TRACE
		for( var i=0; i<6; i++ ){
			var mc = Cs.game.dm.attach("mcExploTrace",Game.DP_PARTS)
			mc._x = x+(Math.random()*2-1)*ray;
			mc._y = y+(Math.random()*2-1)*ray;
			mc._xscale = 150+Math.random()*150
			mc._yscale = mc._xscale
			mc._rotation = Math.random()*360
			mc.blendMode = BlendMode.ADD
			downcast(mc).obj = Cs.game
			mc.gotoAndPlay(string(Std.random(3)+1))
		}
		// ONDE
		var mc = Cs.game.dm.attach("mcOnde",Game.DP_UNDERPARTS)
		mc._x = x
		mc._y = y
		mc._xscale = 150
		mc._yscale = 150

		kill();

	}

	function kill(){

		Cs.game.hero = downcast({x:x,y:y})
		KKApi.gameOver(Cs.game.stats);
		downcast(Cs.game.root)._quality  = "$HIGH".substring(1)
		lastLaser.removeMovieClip();
		onde.removeMovieClip();
		laserRay.removeMovieClip();
		super.kill();
	}


	function checkBounds(){
		var c = -0.3
		if( x<ray || x>Cs.mcw-ray ){
			vx *= c;
			x = Cs.mm(ray,x,Cs.mcw-ray);
		}
		if(y<ray || y>Cs.mch-ray ){
			vy *= c;
			y = Cs.mm(ray,y,Cs.mch-ray);
		}
	}



//{
}




// LE RAYON d'INVICIBILITE A ETE CORRIGE

// FREQUENCE DE TIR ORANGE DIMINUE
// DEGAT DU TIR ORANGE AUGMENTE
// FEQUENCE DE TIR BLEU ( MISSILES ) AUGMENTE DE 20%
// AUGMENTATION DE LA ZONE DE L AURA ROSE













