class Bads extends Phys{//}


	static var scoreDisplayLimit = 100



	var flDeath:bool;
	var flInvicible:bool;
	var flSide:bool;
	var flOrient:bool;
	var hp:float;
	var score:KKConst;
	var score2:KKConst;
	var mid:int;

	var dif:float;
	var spawnDist:float;

	var a:float;
	var va:float;
	var speed:float;
	var speedCoef:float;
	var trg:{x:float,y:float}
	var acc:{c:float,lim:float}

	var turnCoef:float;

	var wave:Wave;
	var pathIndex:int;
	var waveIndex:int;
	var bounceId:int;

	var way:float;
	var level:float;
	var turnSpeed:float;
	var shieldLim:float;

	var waitTimer:float;
	var shootTimer:float;
	var flameTimer:float;
	var outSafeTimer:float;



	var shootRate:int;
	var cooldown:float;


	var weapons:Array<Rafale>
	var rafale:Rafale;

	var fire:MovieClip;
	var follow:MovieClip;
	var turn:MovieClip;

	var bList:Array<int>;
	var partList:Array<{b:Bads,dx:float,dy:float}>

	var ond:{ decal:float,  speed:float, amp:float, by:float, vx:float, sens:float, svy:float }
	var rect:{rw:float,rh:float}

	var beeRange:Array< { w:int, xMin:float, xMax:float, yMin:float, yMax:float } >
	var seekerLimit:float;

	function new(mc){
		if(mc==null)mc = Cs.game.dm.attach("mcBads",Game.DP_BADS);
		Cs.game.badsList.push(this)
		super(mc)

		bList =new Array();

		a = 1.57
		va = 0.1
		turnCoef = 0.1
		speed = 3;

		hp = 2


		dif = 1;
		mid = 0;
		ray = 16
		level = 0;

		shootRate = 30
		shootTimer = 0

		speedCoef = 1;

		ond = {
			decal:314,
			speed:16,
			amp:0.1,
			by:50,
			vx:3,
			sens:1,
			svy:0
		}

		waitTimer = 200


	}

	function setLevel(lvl){
		if(level!=null)Stykades.monsterLevel -= level;
		level = lvl
		Stykades.monsterLevel += level
	}
	function setRect(w,h){
		rect = {rw:w,rh:h}
		ray = Math.min(h,w)
	}
	function setScore(sc){
		score = sc
	}

	function update(){


		updateBehaviour()
		updateFlash()
		checkCols();
		updateShoot();
		updateParts();
		if(bounceId!=null)bounceFamily();

		// ORIENT
		if(flOrient)root._rotation = Math.atan2(vy,vx)/0.0174

		// TURRET
		if(follow!=null){
			var dx = Cs.game.hero.x - x;
			var dy = Cs.game.hero.y - y;
			follow._rotation = Math.atan2(dy,dx)/0.0174 - root._rotation
		}

		// TURN
		if(turn!=null){

			turn._rotation += vy*8*Timer.tmod;
		}


		// CHECK OUT;
		if(outSafeTimer>0){
			outSafeTimer -= Timer.tmod;
		}else{
			var lim = 10;
			if(ray!=null)lim+=ray;
			if(rect!=null)lim+=Math.max(rect.rw,rect.rh);
			if(isOut(lim))kill();
		}




		//

		super.update();
	}
	function dropBonus(){
		var b = new Bonus(null)
		b.x = x;
		b.y = y;
	}

	// COLS
	function checkCols(){
		// HERO
		{
			var h = Cs.game.hero
			var flHit = getDist(h)<ray+h.ray
			if(rect!=null) flHit = Math.abs(h.x-x) < rect.rw+h.ray && Math.abs(h.y-y) <rect.rh+h.ray
			if( flHit  ){
				heroCollide();
			}
		}
		// LASER
		var power = Cs.game.hero.weapons[Hero.WP_LASER][0]
		var rl = 2+Cs.game.hero.weapons[Hero.WP_LASER][1]*2.5
		if( power>0 ){
			for( var i=0; i<Cs.game.hero.laserList.length; i++ ){
				var pos = Cs.game.hero.laserList[i]
				var flHit = Math.abs(pos[0]-x)+Math.abs(pos[1]-y) < ray+rl
				if(rect!=null) flHit = Math.abs(pos[0]-x) < rect.rw+rl && Math.abs(pos[1]-y) <rect.rh+rl
				if( flHit ){
					if(Std.random(int((3/Timer.tmod)/Game.PM))==0){
						var p = new Part(Cs.game.dm.attach("partLaser",Game.DP_PARTS))
						var a = Math.random()*6.28
						var ca = Math.cos(a)
						var sa = Math.sin(a)
						var sp = 3+Math.random()*3
						p.x = x + ca*ray
						p.y = y + sa*ray
						p.vx = ca*sp + vx
						p.vy = sa*sp + vy
						p.setScale( 100+ power*10 +Math.random()*50 )
						p.timer = 10+Math.random()*10
						p.fadeType = 0
						p.root.blendMode = BlendMode.ADD
						//p.plasmaId = 1

					}
					damage( (0.02+power*0.05)*Timer.tmod )
					break;
				}
			}

		}

		// SPEED COLOR
		if( Cs.game.hero.weapons[Hero.WP_SPEED][0]>0 ){

			var col = Cs.game.plasma.layer[0].bmp.getPixel32(int(root._x*Cs.game.pq),int((root._y+Game.PLASMA_CACHE)*Cs.game.pq))
			var o = Cs.colToObj32(col)
			var lim = 50
			var score = o.r*1.2
			if( o.g==0 && score > lim ){
				//Log.print("!"+true);
				var c = (score-lim)/(255-lim)
				damage((0.07+1*c)*Timer.tmod)
				var mc = Cs.game.dm.attach("partStatic",Game.DP_PARTS)
				mc._x = x+(Math.random()*2-1)*ray
				mc._y = y+(Math.random()*2-1)*ray
				mc._xscale = 100+c*100
				mc._yscale = mc._xscale
				mc._rotation = Math.random()*360
				mc.blendMode = BlendMode.ADD

			}
		}

	}
	function heroCollide(){
		var h = Cs.game.hero
		if( h.invincibleTimer==null ){
			h.explode();
		}
		score = null;
		damage(10);
	}
	function bounceFamily(){
		for( var i=0; i<Cs.game.badsList.length; i++ ){
			var b = Cs.game.badsList[i]
			if(b!=this && b.bounceId==bounceId){
				var dist = getDist(b)
				var dif = (ray+b.ray)-dist
				if(dif>0){
					var a = getAng(b);
					var ca = Math.cos(a)
					var sa = Math.sin(a)
					x -= ca*dif*0.5;
					y -= sa*dif*0.5;
					b.x += ca*dif*0.5;
					b.y += sa*dif*0.5;
				}
			}
		}
	}

	// BEHAVIOUR
	function updateBehaviour(){
		if(shootTimer>0)shootTimer-=Timer.tmod;
		if(waitTimer>0)waitTimer -=Timer.tmod
		for( var i=0; i<bList.length; i++ ){
			var n = bList[i]
			switch(n){
				case 0:	// PATH

					var sp = wave.speed*Timer.tmod;
					way += sp*speedCoef
					if( way > wave.pl[pathIndex] ){

						pathIndex++;
						if( pathIndex == wave.pl.length ){
							kill();
							break;
						}
						var p0 = wave.path[pathIndex-1];
						var p1 = wave.path[pathIndex];
						var dx = p1[0] - p0[0];
						var dy = p1[1] - p0[1];
						var a = Math.atan2(dy,dx);
						var dist = Math.sqrt(dx*dx+dy*dy);
						var op = wave.pl[pathIndex-1];
						var ecart = wave.pl[pathIndex]-op
						var c = ( way - op ) / ecart;
						var ca = Math.cos(a);
						var sa = Math.sin(a);

						x = p0[0] + ca*c*sp;
						y = p0[1] + sa*c*sp;

						if(!wave.flLinear){
							speedCoef = (ecart/5)/wave.speed;
						}

						vx = ca*wave.speed*speedCoef;
						vy = sa*wave.speed*speedCoef;

						// SHOT
						switch(p0[2]){
							case 0: // EACH SHOT
								initShot();
								break;
							case 1: // ALL SHOT
								for( var k=0; k<wave.bList.length; k++){
									wave.bList[k].initShot();
								}
								p0.splice(2,1)
								break;
						}

					}
					break;

				case 1: // WANDERING
					va += (Math.random()*2-1)*0.06
					va *= Math.pow(0.8,Timer.tmod)
					a += va
					updateVit();


					break;

				case 2: // ONDULE
					ond.decal = (ond.decal+ond.speed*Timer.tmod)%628
					a += Math.cos(ond.decal/100)*ond.amp
					updateVit();


					break;

				case 3: // FOLLOW TARGET ANGLE
					var da = getAng(trg)-a
					while(da>3.14)da-=6.28;
					while(da<-3.14)da+=6.28;
					a += Cs.mm( -va, da*turnCoef, va )*Timer.tmod;

					vx = Math.cos(a)*speed;
					vy = Math.sin(a)*speed;
					if( getDist(trg) < 50 ){
						onTargetReach();
					}

					break;

				case 4: // SHOOTER
					if(shootTimer<=0){
						if( Std.random(int(shootRate/Timer.tmod))==0 ){
							initShot();
						}
					}
					break;

				case 5: // ONDULEUR HORIZONTAL
					if(vy>0){
						if( y>=ond.by ){
							ond.svy = vy
							vy = 0;
							y = ond.by
							ond.decal = 0
						}
					}else if(vy<0){

					}else{

						ond.decal = (ond.decal+ond.speed*Timer.tmod)%628
						y = ond.by + Math.sin(ond.decal/100)*(ond.amp*100)
						x += ond.vx*ond.sens*Timer.tmod;
						var m  =10
						if( x<(ray+m) || x>Cs.mcw-(ray+m) ){
							ond.sens*=-1
							x = Cs.mm( ray+m, x , Cs.mcw-(ray+m) )
						}

						if(waitTimer<=0){
							vy = -ond.svy
						}
					}
					break;

				case 6: // BEE
					if(trg==null)chooseBeeTrg();

					//speedToward(trg,0.1,1)
					speedToward(trg,acc.c,acc.lim)

					var dx = trg.x - x;
					var dy = trg.y - y;
					if( Math.abs(dx)+Math.abs(dy) < 20+ray ){
						trg = null
					}
					break;

				case 7: // FLAMER

					var pa = 0.3
					var da = Cs.hMod(getAng(Cs.game.hero) - 1.57, 3.14)

					if( Math.abs(da) < pa && getDist(Cs.game.hero)<100 ){
						flameTimer = 8
					}
					if(flameTimer>0){
						flameTimer-=Timer.tmod;
						var shot = new Shot(null)
						shot.setSkin(22,1)
						var a = 1.57 + (Math.random()*2-1)*pa
						var ca = Math.cos(a)
						var sa = Math.sin(a)
						var sp = 5+Math.random()*3
						shot.x = x +ca*ray
						shot.y = y +sa*ray
						shot.vx = ca*sp;
						shot.vy = sa*sp;
						shot.ray = 8
						shot.timer = 10+Math.random()*10
						shot.vr = (Math.random()*2-1)*20
						shot.root.blendMode = BlendMode.ADD
						shot.plasmaId = 1
						shot.updatePos();
					}
					break;

				case 8: // SEEKER
					if(y>seekerLimit){
						vy = 0;
						bList.splice(i--,1);
						bList.push(3);
						trg = upcast(Cs.game.hero)
						hp = 2
						root.smc.play();
						score =  score2
						flOrient = true;
					}
					break;

				case 9: // STAGNE
					if(waitTimer>0){
						if(y>trg.y){
							if(vy>0)shootTimer = 0
							vy = 0
						}
					}else{
						vy -= 0.3
						shootTimer = 200
					}
					break;

				case 10: // SHIELD

					for( var k=0; k<Cs.game.shotList.length; k++ ){
						var shot = Cs.game.shotList[k]
						if( shot.flGood && shot.root._currentframe!=14 ){
							var dist = getDist(shot);
							if(dist<shieldLim){
								var d = shieldLim-dist
								shot.x += Math.cos(a)*d
								shot.y += Math.sin(a)*d
							}

						}
					}
					break;
			}
		}



		//

	}
	function updateVit(){
		vx = Math.cos(a)*speed
		vy = Math.sin(a)*speed
	}

	// SHOT
	function initShot(){
		var max = 0
		for( var i=0; i<weapons.length; i++ )max += weapons[i].w;
		var rid = Std.random(max);
		var sum = 0
		for( var i=0; i<weapons.length; i++ ){
			var raf = weapons[i];
			sum += raf.w
			if(sum>rid){
				raf.init();
				break;
			}
		}



		/*
		shootTimer = cooldown;
		shot();
		if( rafale.index == null ){
			rafale.index = 0
		}
		*/
	}
	function updateShoot(){
		if(shootTimer==null)return;
		if(rafale==null){
			shootTimer -= Timer.tmod;
			if(shootTimer<=0)initShot();
		}else{
			rafale.update();
		}

		/*

		if(shootTimer<=0){
			if(weaponIndex!=null){
				var raf = weapons[weaponIndex]
				var si = raf.list[rafaleIndex]

				shootTimer = si.cooldown;
				raf.shot(si.type,si.params)

				rafaleIndex++
				if(rafaleIndex==raf.list.length){
					weaponIndex = null
					rafaleIndex = null
				}
			}else{
				initShot();
			}

		}else{
			shootTimer-=Timer.tmod;
		}
		*/
	}
	function newRafale(){
		if(weapons==null)weapons = new Array();
		var raf = new Rafale(this);
		weapons.push(raf);
		return raf
	}

	// HIT
	function hit(shot:Shot){
		damage(shot.damage)

	}
	function damage(n){
		flash = 100
		hp-=n
		if(hp<=0){
			if(!flDeath)die();
		}
	}
	function die(){
		onDeath();
		var v  = KKApi.val(score)
		if(score!=null ){
			KKApi.addScore(score)
			if(v > scoreDisplayLimit){
				var p = new Part(Cs.game.dm.attach("partScore",Game.DP_PARTS))
				p.x = x;
				p.y = y;
				downcast(p.root).compt = 10;
				downcast(p.root).score = v;
				Cs.glow( p.root, 6, 5, 0x0000FF)
			}

			//STATS
			var a:Array<int> = null
			for( var i=0; i<Cs.game.stats.$k.length; i++ ){
				if( Cs.game.stats.$k[i][0] == v ){
					a = Cs.game.stats.$k[i]
					break;
				}
			}
			if(a==null){
				a = [int(v),0]
				 Cs.game.stats.$k.push(a)
			}
			a[1]++



		}
		explode();
		kill();
	}
	function explode(){

		var max = 5*Game.PM
		for( var i=0; i<max; i++ ){
			var p = new Part( Cs.game.dm.attach("mcExploPart",Game.DP_PARTS) )
			p.setScale(20+Math.random()*30)
			var a = Math.random()*6.28
			var ca = Math.cos(a);
			var sa = Math.sin(a);
			var ray = 8;
			var sp = 3+Math.random()*5
			p.x = x + ca*ray;
			p.y = y + sa*ray;
			p.vx = ca*sp
			p.vy = sa*sp + Game.SCROLL_SPEED*(0.6+Math.random()*0.4)
			p.plasmaId = 1
			p.timer = 10+Math.random()*10
			p.root.blendMode = BlendMode.ADD
			p.root._rotation = Math.random()*360
		}

		var mc = Cs.game.dm.attach("mcExploTrace",Game.DP_PARTS);
		mc.gotoAndStop("3");
		for( var i=0; i<3; i++ ){

			mc._x = x+(Math.random()*2-1)*ray;
			mc._y = y+(Math.random()*2-1)*ray;
			mc._xscale = 100+Math.random()*100
			mc._yscale = mc._xscale
			mc._rotation = Math.random()*360
			mc.blendMode = BlendMode.ADD


			Cs.game.plasmaDraw(mc,1);

			/*
			downcast(mc).obj = Cs.game
			mc.gotoAndPlay("3")
			*/
		}
		mc.removeMovieClip();

	}

	// PARTS
	function setPart(b,dx,dy){
		if(partList==null)partList = new Array();
		partList.push({b:b,dx:dx,dy:dy})
	}
	function updateParts(){
		for( var i=0; i<partList.length; i++ ){
			var o = partList[i]
			o.b.x = x+o.dx
			o.b.y = y+o.dy
		}
	}


	// GFX
	function setSkin(n){
		root.gotoAndStop(string(n))
	}
	function setSubSkin(fr){
		Cs.allGoto(root,"$sub",fr)
	}

	// SPECIFIC
	function chooseBeeTrg(){
		var max = 0
		for( var i=0; i<beeRange.length; i++ ) max += beeRange[i].w;
		var rid = Std.random(max)
		var cur = 0
		for( var i=0; i<beeRange.length; i++ ){
			var o = beeRange[i]
			cur+=o.w
			if(cur>rid){
				trg = {
					x: o.xMin + Math.random()*(o.xMax-o.xMin),
					y: o.yMin + Math.random()*(o.yMax-o.yMin),
				}
				break;
			}
		}
	}
	function chooseNewTarget(xMin,xMax,yMin,yMax){

		if(waitTimer<=0){
			trg = { x:x, y:-200 }
			return;
		}

		trg = {
			x: xMin + Math.random()*(xMax-xMin),
			y: yMin + Math.random()*(yMax-yMin),
		}
	}

	// ON
	function onTargetReach(){

	}
	function onDeath(){

	}

	function kill(){
		for( var i=0; i<partList.length; i++ ){
			var b = partList[i].b
			if( b.flDeath!=true &&  b.flSide ){
				b.die();
			}
			partList.splice(i--,1)
		}

		flDeath = true;
		if(level!=null)Stykades.monsterLevel -= level;
		if(wave!=null)wave.bList.remove(this);
		Cs.game.badsList.remove(this);
		super.kill();
	}

//{
}
