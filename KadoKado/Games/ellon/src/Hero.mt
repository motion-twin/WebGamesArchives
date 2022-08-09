class Hero extends Phys{//}

	static var DP_UNDER = 3
	static var DP_UNDER2 = 4
	static var DP_BODY = 5
	static var DP_SHIELD = 2
	static var FIRE_ANGLE = -0.1

	static var SHOT_COLOR = [0xFFDD66,0xDD44FF,0x44DDFF]
	static var GROUND_DECAL = 7


	//

	volatile var flBuild:bool;
	volatile var flSpeedUp:bool;
	volatile var flShield:bool;


	var speed:float;

	var step:int;

	volatile var shotType:int;
	volatile var shotPower:int;

	volatile var sideType:int;
	volatile var sidePower:int;
	volatile var sideCooldown:float;


	//var tentacule:int;

	volatile var fa:float;
	volatile var cooldown:float;

	var runFrame:float;
	var lastAngle:float;
	var vr:float;
	volatile var build:float;
	volatile var rage:float;
	volatile var shieldTimer:float;

	var dm:DepthManager;

	var aura:MovieClip;
	var sList:Array<MovieClip>
	var rList:Array<{>MovieClip,vr:float,t:float,ys:float}>
	var tList:PArray<{phase:float,trg:{x:float,y:float},timer:float}>
	var body:{>MovieClip, sub:{>MovieClip, torse:MovieClip}, bid:int, balais:MovieClip}

	var shield:MovieClip;


	function new(mc){
		super(mc)

		dm = new DepthManager(root)
		body = downcast(dm.attach("mcHero",DP_BODY))

		sList = new Array();
		tList = new PArray();
		rList = new Array();

		flBuild = false
		flSpeedUp = false
		flShield = false

		speed = 6//8
		ray = 11//4

		shotType = 0
		shotPower = 0
		sideType = null
		sidePower = 0
		sideCooldown = 0;

		frict = 0.6


		cooldown = 0
		build = 0;
		x=0
		y=0

		initAir();

//initShield();
		/*
		newTentacule();
		newTentacule();
		newTentacule();
		newTentacule();
		newTentacule();

		//*/

		updateCards();
		body.bid = 1

	}

	function update(){
		super.update();

		cooldown-=Timer.tmod;
		sideCooldown-=Timer.tmod;

		switch(step){
			case 0:
				control();
				recal();
				if(tList.length>0)updateTentacule();
				if(rage>0)updateRage();

				var dr = vy*2 - body._rotation
				body._rotation += dr*0.1*Timer.tmod;
				if(y==Cs.GL-(ray+GROUND_DECAL)){
					initGround();
				}
				break;
			case 1:
				control();
				runFrame = ( runFrame+(1+vx*0.1)*(Cs.SCROLL_SPEED/5)*Timer.tmod )%20
				var mc = body.sub
				var fr = int(runFrame)+1
				mc.gotoAndStop(string(fr))

				if( Key.isDown(Key.SPACE) || Key.isDown(Key.CONTROL) ){
					mc.torse.gotoAndStop(string(int(30-(fa/3.14)*20)+1))
				}else{
					mc.torse.gotoAndStop(string(fr));

				}

				x = Cs.mm(ray,x,Cs.mcw-ray)

				break;
			case 9:
				if(x<-100){
					Cs.game.stats.$d = Cs.game.dif
					KKApi.gameOver(Cs.game.stats);
					step  =10
				}
				if(y+ray>Cs.GL){
					y = Cs.GL-ray
					vy*=-0.7
					vx -= Cs.SCROLL_SPEED//16
					vr *= 1.5
					for(var i=0; i<3;i++)genGroundSmoke();
				}
				body._rotation += vr*Timer.tmod;
				break;
		}

		if(flShield)updateShield();

	}

	function updateRage(){
		var list = Cs.game.badsList
		var ec = 8

		for( var n=0; n<3; n++ ){
			var b = list[Std.random(list.length)]
			var dx = b.x - x;
			var dy = b.y - y;
			var dist = Math.sqrt(dx*dx+dy*dy)
			var max = 2+int(dist/10)

			var p = Cs.game.draw;
			var a = new Array();
			for( var i=0; i<max; i++ ){
				var c = i/(max-1)
				var pos = [
					x+dx*c+(Math.random()*2-1)*ec,
					y+dy*c+(Math.random()*2-1)*ec
				]
				a.push(pos)
			}
			p.lineStyle(8,0x00FFFF,20)
			p.moveTo(x,y)
			for( var i=0; i<a.length; i++){
				var pos = a[i]
				p.lineTo(pos[0],pos[1])
			}
			p.lineStyle(1,0xFFFFFF,100)
			p.moveTo(x,y)
			for( var i=0; i<a.length; i++){
				var pos = a[i]
				p.lineTo(pos[0],pos[1])
			}

			b.damage(0.2*Timer.tmod)

		}

		rage -= 2*Timer.tmod
		if(rage<0)rage=null;

	}

	function updateShield(){
		shieldTimer-=Timer.tmod;
		if(shieldTimer<75){
			shield._visible = !shield._visible
			if(shieldTimer<0){
				flShield = false;
				shield.removeMovieClip();
			}
		}
		var mc = downcast(shield).shield
		mc._xscale = 100 + (Math.random()*2-1)*3
		mc._yscale = mc._xscale
	}

	function initAir(){
		body.gotoAndStop("1")
		fa = FIRE_ANGLE
		step = 0;
	}

	function initGround(){
		body._rotation = 0
		body.gotoAndStop("2")
		step = 1;
		runFrame = 0;
		lastAngle = 0;
		cancelBuild();
	}

	function control(){
		var sp = speed;
		if(flSpeedUp)sp*=1.5
		if(Key.isDown(Key.UP)){
			if(step==1)initAir();
			vy = -sp*Timer.tmod;
		}
		if(Key.isDown(Key.DOWN) && step == 0 ){
			vy = sp*Timer.tmod;
		}
		if(Key.isDown(Key.LEFT)){
			vx = -sp*Timer.tmod;
		}
		if(Key.isDown(Key.RIGHT)){
			vx = sp*Timer.tmod;
		}

		if(Key.isDown(Key.SPACE) || Key.isDown(Key.CONTROL)){
			shoot();
		}else{
			if(step==0 && flBuild)buildUp();
		}

	}

	function buildUp(){
		build=Math.min(build+Timer.tmod,100);
		if(build>0){
			if( Math.random()*100 < build ){
				var mc = downcast(dm.attach("partRay",DP_UNDER))
				mc._rotation = Math.random()*360
				mc.vr = (Math.random()*2-1)*3
				mc.ys = 50+Math.random()*100
				mc._xscale = (60+(Math.random()*2-1)*40)*(build/100)
				mc._yscale = mc.ys
				mc.t = 12+Math.random()*20
				mc.gotoAndStop(string(shotType+1))
				rList.push(mc)
			}

			for( var i=0; i<rList.length; i++ ){
				var mc = rList[i]
				mc._rotation += mc.vr*Timer.tmod;
				mc.t-=Timer.tmod;
				if(mc.t<10){
					mc._yscale = mc.ys*mc.t/10
					if(mc.t<0){
						mc.removeMovieClip();
						rList.splice(i--,1)
					}
				}
			}

			// STAR
			if(Std.random(2)==0){
				var star = dm.attach("partBuild",DP_UNDER)
				star._rotation = Math.random()*360
				star._xscale = aura._xscale*1.3
				star._yscale = star._xscale
				downcast(star).list = sList;
				sList.push(star);
				Cs.setPercentColor(star,100,SHOT_COLOR[shotType])
			}

		}

	}

	function recal(){
		if( x<ray || x>Cs.mcw-ray ){
			x = Cs.mm(ray,x,Cs.mcw-ray)
			vx = 0
		}
		if( y<ray || y>(Cs.GL-(ray+GROUND_DECAL)) ){
			y = Cs.mm(ray,y,Cs.GL-(ray+GROUND_DECAL))
			vy = 0
		}
	}

	function shoot(){
		// MAINSHOT
		if(cooldown<0){

			if(step==1){
				var m = getNearestMonster(0,0);

				if(m!=null){
					var d = getDist(m);
					var c = d/16
					var tx = (m.x + m.vx*c) - x
					var ty = (m.y + m.vy*c) - y
					fa = Math.atan2(ty,tx)
					if(fa>0 && fa<1.57){
						fa = 0
					}
					if(fa>1.57){
						fa = -3.14
					}



				}else{
					fa = 0;
				}
			}


			switch(shotType){
				case 0:
					if(build<10){
						{
							var shot = newShot(16,0);
							shot.damage = Cs.DAMAGE_FIREBALL
						}
						var max = Std.random(shotPower*3)
						for( var i=0; i<max; i++ ){
							var speed = 6+Math.random()*8
							var shot = newShot(speed,(Math.random()*2-1)*0.25);
							var scale = 60
							shot.root._xscale = scale;
							shot.root._yscale = scale;
							shot.damage = Cs.DAMAGE_FIREBALL*0.5
						}
					}else{
						var power = build*0.5
						var shot = newShot(16,0);
						shot.damage = 1+power*0.5
						var scale = 150+power*5
						shot.root._xscale = scale;
						shot.root._yscale = scale;
						shot.flPierce = true;
						shot.ray = 6*(scale/100)
						shot.bList.push(1)
					}
					cooldown = 4
					break;
				case 1:

					var max = Cs.mm( 2, int(build/4), 25 ) + shotPower*2
					var ecart = max*0.07
					for( var i=0; i<max; i++ ){
						var c = (i/(max-1))*2-1
						var shot = newShot(16,c*ecart);
						shot.setSkin(5)
						shot.damage = Cs.DAMAGE_SPARK
					}

					cooldown = 6
					break
				case 2:
					var shot = newShot(16,0);
					shot.setSkin(6)
					shot.damage = Cs.DAMAGE_LASER*Timer.tmod*(shotPower+1);
					shot.root._yscale = 60+shotPower*50
					shot.root._xscale = 100+shotPower*20
					shot.flInvincible = true;
					cooldown = 3
					if(build>30){
						rage = build-30;
					}
					break;
			}

		}

		// END BUILD
		cancelBuild();



		// SIDE
		if(sideCooldown<0 && step==0 ){
			switch(sideType){
				case 0:	// BOMB
					sideCooldown = 30/(sidePower+1)
					var s = newShot(0,0);
					s.setSkin(3)
					s.weight = 0.4+Math.random()*0.2
					s.x -= 10
					s.vy = -3
					s.vx = 2+Math.random()*2
					s.frict = 0.98
					s.vr = (Math.random()*2-1)*20
					s.bList.push(0);
					s.damage = Cs.DAMAGE_BOMB
					break;
				case 1: // TENTACULE
					break;
				case 2: // HOMING;
					var max = sidePower+1

					for( var i=0; i<max; i++ ){
						var c = (i/(max-1))*2-1
						if(max==1)c=0
						var s = newShot(5,c*max*0.4)
						s.trg = getNearestMonster(Math.cos(s.a)*20,Math.sin(s.a)*20)
						s.va = 0.5
						s.ca = 0.1
						s.bList = [2,3]
						s.speed = 8
						s.damage = Cs.DAMAGE_HOMING
						s.setSkin(7)
						s.timer = 120
					}
					sideCooldown = 30
					break;
			}

		}


	}

	function cancelBuild(){
		while(sList.length>0)sList.pop().removeMovieClip();
		while(rList.length>0)rList.pop().removeMovieClip();
		build = 0;
		if(aura!=null){
			aura.removeMovieClip();
			aura = null;
		}
	}

	function hit(shot){
		if(shot.ray>15)	body.gotoAndStop("gum");
		death();
	}

	function death(){
		step = 9
		weight = 1
		frict = 0.98
		vr = 18
		cancelBuild();
	}

	//
	function newTentacule(){
		if(tList.length>4)return;
		tList.push(
			{
				phase:0,
				timer:100,
				trg:{x:x,y:y}
			}
		)
	}

	function updateTentacule(){



		//phaseTent = (phaseTent+57)%628

		for( var n=0; n<tList.length; n++ ){
			var info = tList[n]
			info.phase = (info.phase+37)%628






			var c = (n/(tList.length-1))*2-1;
			if(tList.length==1)c=0;
			var list = new Array();
			var pa = -3.14 + c*1.3
			var px = x;
			var py = y;
			var lim = 0.6//0.3
			var turnCoef = 1//0.2
			var speed = 10//5
			var sleep = 0
			var phase = info.phase

			var sbx = -Math.cos(pa)*100
			var sby = -Math.sin(pa)*100
			var m = getNearestMonster(sbx,sby);
			if(m!=null){
				var ddx = m.x-info.trg.x;
				var ddy = m.y-info.trg.y;
				var coef = 0.15;
				info.trg.x += ddx*coef*Timer.tmod;
				info.trg.y += ddy*coef*Timer.tmod;

			}



			// TRACE PATH
			for( var i=0; i<18; i++){
				sleep = Math.min(sleep+0.1,1)
				phase = (phase+66)%628
				var dx = info.trg.x - px;
				var dy = info.trg.y - py;
				var da = Math.atan2(dy,dx) - pa;
				while(da>3.14)da-=6.28;
				while(da<-3.14)da+=6.28;
				var ma = Math.cos(phase/100)*0.5//*0.5

				pa += Cs.mm(-lim,da*turnCoef,lim)*sleep
				px += Math.cos(pa+ma)*speed
				py += Math.sin(pa+ma)*speed
				py = Math.min(py,Cs.GL-5)
				if( m.getDist({x:px,y:py}) < m.ray ){
					m.damage(Cs.DAMAGE_TENTACULE*Timer.tmod)
					KKApi.addScore(Cs.C1)
					info.phase = (info.phase+57)%628
					break;
				}
				list.push([px,py])
			}

			// DRAW
			var bs = 6
			var p = Cs.game.draw;

			p.lineStyle(6,0xFF00FF,30)
			p.moveTo(x,y)
			for( var i=0; i<list.length; i++){
				var co = 1 -(i/list.length)
				p.lineStyle(5+co*bs,0xFF00FF,100)
				var pos = list[i]
				p.lineTo(pos[0],pos[1])
			}
			p.lineStyle(1.5,0xFFFFFF,100)
			p.moveTo(x,y)
			for( var i=0; i<list.length; i++){
				var co = 1 -(i/list.length)
				p.lineStyle(1.5+co*bs,0xFFFFFF,100)
				var pos = list[i]
				p.lineTo(pos[0],pos[1])
			}
		}


	}

	function removeAllTentacule(){
		tList = new PArray()
	}

	//
	function takeSide(id){
		if( sideType == id ){
			if(sideType == 1 && sidePower<2)newTentacule();
			sidePower = int(Math.min(sidePower+1,2));
		}else{
			if(sideType == 1 ){
				removeAllTentacule();
			}
			if(id == 1){
				for( var i=0; i<sidePower+1; i++)newTentacule();
			}
			sideType = id;
		}
	}

	function initShield(){
		if(shield==null){
			flShield = true;
			shield = dm.attach("mcShield",DP_SHIELD)
			shieldTimer = 1000
		}
	}

	function initSpeedUp(){
		flSpeedUp = true;
		body.bid = 2
		body.balais.gotoAndStop("2")
	}

	//
	function updateCards(){
		return;
		while(Cs.game.cardsList.length>0)Cs.game.cardsList.pop().removeMovieClip();
		var a = new Array();
		if( shotType!=null ){
			a.push(shotType+1)
		}
		if( sideType!=null ){
			a.push(sideType+11)
		}
		if(flBuild)a.push(31);
		if(flSpeedUp)a.push(32);
		if(flShield)a.push(33);


		for( var i=0; i<a.length; i++ ){
			var mc = Cs.game.dm.attach("mcCard",Game.DP_INTER)
			mc.gotoAndStop(string(a[i]))
			mc._x = 16 + 27*i
			mc._y = Cs.mch-20
			Cs.game.cardsList.push(mc)
		}
	}

	//
	function newShot(sp,ma){
		var shot = new Shot(null)
		shot.a = fa+(body._rotation*0.0174)+ma
		var ca = Math.cos(shot.a)
		var sa = Math.sin(shot.a)
		shot.x = x+ca*26
		shot.y = y+sa*26
		shot.vx = ca*sp
		shot.vy = sa*sp
		shot.frict = null;
		shot.orient();
		shot.flGood = true;
		//vx-=ca*3
		//vy-=sa*3

		return shot;
	}

	function getNearestMonster(dx,dy){
		var dist = 1/0
		var monster = null;
		for( var i=0; i<Cs.game.badsList.length; i++ ){
			var m = Cs.game.badsList[i]
			var d = getDist({x:m.x+dx,y:m.y+dy})
			if(d<dist){
				dist = d;
				monster = m;
			}
		}
		return monster;
	}



//{
}














