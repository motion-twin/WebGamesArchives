class Stykades{//}

	static var BADS_LIMIT = 4//14
	static var FL_CREATE_LOCK = false;

	static var PATH = [
		[[-14,16],[217,17],[256,24],[279,48],[286,82],[273,121],[240,144],[187,146],[141,122],[89,65],[-1,-36]],
		[[89,-20],[91,45],[114,92],[149,115],[168,139],[165,163],[145,179],[113,180],[72,163],[39,132],[22,96],[19,60],[35,28],[70,12],[141,16],[211,46],[270,94],[344,197]],
		[[114,-14],[57,8],[28,29],[15,56],[11,84],[14,111],[30,140],[59,167],[96,190],[143,206],[194,207],[248,192],[284,162],[302,130],[313,79],[299,45],[259,28],[209,31],[156,54],[111,84],[77,120],[30,160],[-5,178],[-50,174]],
		[[9,-16],[12,21],[27,49],[58,82],[97,98],[150,104],[203,96],[243,74],[273,43],[288,16],[300,-19]],
		[[315,45],[271,32],[232,33],[192,48],[166,78],[152,107],[156,151],[174,173],[209,187],[248,176],[269,147],[268,107],[238,79],[190,66],[134,62],[87,77],[49,104],[26,143],[22,177],[34,209],[70,231],[119,230],[159,205],[181,155],[182,109],[148,41],[106,16],[43,3],[-39,4]],

		[[92,-24],[95,17],[108,44],[149,78],[187,110],[193,143],[181,174],[151,198],[110,197],[78,179],[65,148],[76,112],[105,83],[236,-30]],
		[[177,-14],[178,39],[192,91],[210,113],[245,120],[276,105],[290,68],[274,33],[240,17],[204,33],[-15,238]],
		[[324,160],[291,113],[256,82],[212,72],[166,74],[123,93],[95,126],[88,172],[102,213],[131,236],[175,249],[218,240],[257,212],[275,169],[284,86],[285,-12]],

		[[-14,22],[274,22],[274,150],[88,150],[88,88],[221,88],[220,213],[322,213]],
		[[-31,110],[55,110],[55,197],[220,197],[220,27],[108,27],[108,112],[268,112],[268,329]],
		[[117,-13],[116,82],[197,82],[197,178],[114,178],[113,216],[266,216],[266,29],[-29,28]],
		[[280,-22],[279,33],[54,32],[54,67],[150,68],[149,205],[53,205],[53,134],[328,134]],

		[[318,20],[33,21],[17,29],[11,44],[18,59],[32,69],[267,68],[283,75],[288,92],[286,328]],
		[[30,-20],[29,90],[36,110],[54,117],[259,120],[275,133],[275,153],[263,173],[47,172],[26,182],[27,205],[42,215],[259,215],[270,232],[269,320]],
		[[320,76],[32,77],[14,67],[6,46],[15,24],[33,16],[259,17],[275,24],[287,40],[286,57],[286,313]],

		[[-22,3],[46,19],[87,39],[119,57],[207,90],[243,81],[257,49],[230,31],[182,44],[140,75],[73,114],[36,119],[6,95],[15,71],[42,66],[77,79],[102,94],[133,108],[163,127],[205,154],[250,154],[264,136],[242,114],[205,117],[165,133],[131,151],[38,190],[13,183],[15,158],[42,151],[65,159],[203,217],[247,215],[260,183],[225,175],[179,182],[32,248],[-35,282]],

		[[13,308],[14,261],[25,234],[45,217],[74,202],[93,180],[102,152],[93,124],[72,108],[47,96],[28,80],[19,58],[23,34],[43,19],[76,15],[336,15]],
		[[18,324],[21,49],[33,25],[59,16],[89,29],[110,53],[193,147],[219,162],[250,169],[322,169]],
		[[45,324],[45,165],[33,147],[16,132],[8,113],[9,40],[17,26],[32,16],[50,12],[239,12],[264,22],[280,48],[277,77],[259,98],[-7,317]],
		[[-18,280],[30,282],[65,278],[93,254],[112,217],[115,156],[124,124],[142,106],[172,99],[193,88],[214,68],[228,31],[229,-32]],
		[[-28,185],[7,244],[28,270],[69,276],[108,262],[132,233],[144,181],[138,124],[114,94],[69,85],[23,97],[7,127],[13,159],[35,179],[64,191],[116,189],[183,140],[233,92],[287,58],[341,57]],

		[[-44,71],[278,72],[278,180],[187,180],[187,19],[120,19],[120,97],[247,97],[247,135],[36,135],[36,55],[150,55],[150,153],[83,153],[83,18],[251,18],[251,54],[169,54],[169,153],[248,153],[248,72],[59,72],[59,176],[160,178],[160,30],[19,30],[19,188],[274,188],[274,112],[-44,112]],

		[[292,-18],[282,85],[263,127],[239,142],[216,142],[188,121],[162,80],[136,33],[112,7],[87,3],[61,13],[38,46],[15,115],[-13,255]],
		[[330,270],[205,270],[205,193,0],[281,192],[280,114],[-20,115]],
		[[330,27],[35,25],[19,32],[11,46],[23,60],[268,131],[288,145],[287,161],[276,172],[-24,172]],
		[[330,17],[291,134],[249,205],[204,251],[135,275],[64,249],[23,187],[22,109],[68,43],[142,26],[206,49],[248,95],[289,172],[326,292]],
		[[333,149],[197,148],[95,70],[96,41],[116,21],[141,22],[157,41],[156,330]],
		[[306,9],[229,73],[171,91],[132,84],[107,51],[118,22],[151,7],[191,20],[202,55],[202,102],[187,140],[149,173],[79,181],[42,157],[36,122],[60,95],[95,95],[121,118],[120,154],[117,202],[120,245],[145,277],[178,291],[221,277],[277,202],[322,163]],
		[[351,188],[215,187],[142,171],[113,134],[114,90],[142,71],[175,79],[196,112],[227,133],[260,119],[268,84],[258,52],[227,33],[172,26],[114,39],[72,74],[54,132],[64,183],[94,231],[143,261],[208,273],[355,274]],
		[[-23,17],[21,17],[62,25],[97,50],[119,88],[152,109],[194,109],[243,108],[277,121],[284,143],[275,168],[243,184],[-16,185]]
	]

	static var PROB = [
		[ 1,	0	],
		[ 3,	300	],
		[ 2,	400	],
		[ 30,	700	],	// MINES
		[ 9,	1000	],	// BRIAROS

		[ 7,	1200	],	// BLOCK
		[ 4,	1300	],	// FURIA

		[ 5,	1500	],	// GROMPH
		[ 10,	1700	],	// STORM NIV 1

		[ 20,	2000	],	// ORB
		[ 17,	2000	],	// 5xCUTTY
		[ 31,	2200	],	// 5x MINES
		[ 33,	2400	],	// SHIELD
		[ 16,	2600	],	// BRIAROS RAVE

		[ 11,	2800	],

		[ 22,	3000	],	// GERGIN
		[ 6,	3200	],	// BACK GROMPH
		[ 8,	3800	],	// SURGROMPH
		[ 18,	4000	],	//[ 18,	4000	],	// NES
		[ 12,	5000	],
		[ 32,	6000	],	// 10x MINES
		[ 34,	7000	]	// 8x KILLER BRIAROS
	]

	static var monsterLevel = 0;
	static var waveTimer = 150;
	static var nextWave = 300;
	static var dif = 0

	static var nextBonus = 300


	static function update(){

		/*
		if(Key.isDown(Key.ENTER)){
			Log.print("difficulté: "+int(dif))
			Log.print("monsterLevel: "+monsterLevel+"/"+int(4+dif*0.01))
		}
		*/
		dif += Cs.CDIF*Timer.tmod;

		waveTimer += Timer.tmod
		if(waveTimer>nextWave){
			waveTimer = 0
			nextWave = 10+Math.random()*20
			checkWave();
		}
	}

	static function checkWave(){

		// BONUS
		if( dif>nextBonus ){
			genMonster(21)
			nextBonus += 80+Math.random()*(200+dif)
		}
		/*
		if( Math.random()*Math.pow(10, (1+Bonus.NB*0.5) ) < 1 ){
			genMonster(21)
			Log.trace("bonus!")
		}
		*/


		// MONSTER
		var tr = 0
		if( monsterLevel < dif*0.01 ){
			var list = new Array();
			for( var i=0; i<PROB.length; i++ ){
				var a = PROB[i]
				var min = Math.min(dif-2000, 2500)

				if(   dif > a[1] && ( a[1]> min || i>PROB.length-8 ) ){
					list.push(a[0])
				}
			}

			genMonster( list[Std.random(list.length)] )
			if(tr++>20)return;
		}





	}


	static function genMonster(n){
		switch(n){
			case 10:
			case 11:
			case 12:
				var b = newStorm(n-10);
				break;

			case 1: // OMEGA WAVE
				var wave = new Wave(Std.random(5),3,true)
				if(Std.random(2)==0)wave.flipPath(0);
				wave.addBads( newOmega ,5 )
				break;

			case 2:	// DOUBLE OMEGA WAVE
				var wid = 5+Std.random(3)
				for( var k=0; k<2; k++ ){
					var wave = new Wave(wid,3,true)
					if(k==0)wave.flipPath(0);
					wave.addBads( newOmega ,5 )
				}
				break;
			case 3:	// BLACKRON

				var wid = 8+Std.random(4)
				var wave = new Wave(wid,4,true)
				if(Std.random(2)==0)wave.flipPath(0);
				wave.addBads( newBlackron ,4 )
				break;

			case 4:	// FURIA
				var wid = 12+Std.random(3)
				var wave = new Wave(wid,6,true)
				if(Std.random(2)==0)wave.flipPath(0);
				wave.addBads( newFuria , 8 )
				break;
			case 5:	// GROMPH
				var wid = 15
				var wave = new Wave(wid,5.5,true)
				if(Std.random(2)==0)wave.flipPath(0);
				wave.addBads( newGromph , 1 )
				break;

			case 6:	// BACK GROMPH
				var wid = 16+Std.random(5)
				var wave = new Wave(wid,5.5,true)
				if(Std.random(2)==0)wave.flipPath(0);
				wave.addBads( newGromph , 1 )
				break;

			case 7:	// BLOCK
				var b = newBlock()
				b.vy = 2
				break;

			case 8:	// SURGROMPH
				var wid = 15+Std.random(6)
				var wave = new Wave(wid,5.5,true)
				if(Std.random(2)==0)wave.flipPath(0);
				wave.addBads( newSurGromph , 1 )
				break;
			case 9: // BRIAROS
				var b = newBriaros();
				break;
			case 16: // BRIAROS RAVE
				for( var i=0; i<6; i++){
					var b = newBriaros();
				}
				break;
			case 17: // CUTTY
				var m = 80
				var x = m+Math.random()*(Cs.mcw-2*m)
				var max = 5
				for( var i=0; i<max; i++){
					var c = (i/(max-1))*2-1;
					var b = newCutty();
					b.x = x+c*40;
					b.vy = 4-Math.abs(c)*1;
					b.seekerLimit = (Cs.mch*0.5) + 10*c ;
				}
				break;
			case 18: // NES
				var wid = 21
				var wave = new Wave(wid,4,true)
				if(Std.random(2)==0)wave.flipPath(0);
				wave.addBads( newNes , 1 )
				break;

			case 20: // ORB
				var b = newOrb();
				break;

			case 21: // CARRIER
				var b = newCarrier();
				break;

			case 22: // GERGIN
				var b = newGergin();
				break;

			case 30: // MINE
				var b = newMine();
				break;

			case 31: // 5x MINE
				for( var i=0; i<5; i++ )var b = newMine();
				break;

			case 32: // 5x MINE
				for( var i=0; i<10; i++ )var b = newMine();
				break;

			case 33: // SHIELD
				var b = newShield();
				break;

			case 34: // KILLER BRIAROS
				for( var i=0; i<8; i++ ){
					var b = newBriaros();
					var m = -15
					b.x = m+Std.random(2)*(Cs.mcw-2*m)
					b.y = Cs.mch*0.5 + 20
					b.beeRange[0].w = 0
					b.beeRange[1].yMax += 20

					b.hp =  120
					var raf = b.newRafale();
					raf.addShot( 1, [3,0.6], 10, 1 )
					b.cooldown = 10
					b.shootTimer = 5+Math.random()*10
				}
				break;
		}
	}


	// WAVE
	// var wave = new Wave(id,speed,flagLinear)


	// BADS

	// b.setSkin( frame du monstre )
	// b.ray = 16		> rayon du monstre
	// b.x ou b.y = 	> position initiale du monstre
	// b.vx ou b.vy = 	> vitessse initiale du monstre
	// b.speed = 3, 	> dans le cas d'un montre d'un monstre autonome
	// b.va = 0.1		> capacite de virage max
	// b.turnCoef = 0.1	> coeffient de virage max
	// b.a = 1.57		> engle de depart du monstre ( EAST, SOUTH, WEST, NORTH ) = (0, 1.57, 3.14, -1.57 )

	// BEHAVIOUR
		// b.bList.push( BEHAVIOUR NUMBER )

	// 1 Ballade

	// 2 Ondule
		// b.ond.amp = 0.1	> amplitude de l'ondulation
		// b.ond.speed = 16	> vitesse de l'ondulation
		// b.ond.decal = 314	> depart de l'ondultation


	// 3 Follow
		// b.trg une cible a suivre ( Cs.game.hero ou un autre monstre )


	// 4 Shooter
		// b.cooldown = 20	> temps de refroidissement de l'arme
		// b.shootRate = 30 	> 1/40 chance de tirer a chaque frame
		// b.shootType = 0	> type de tir
		// b.shootAcc = 0.5	> Precision du tir ( 0 = parfait )
		// setRafale(max,ecart) > tir max d'affilé - ecart entre les tirs




	var rafale:{ index:float, max:float, ecart:float };


	static function newBad(){
		if(!FL_CREATE_LOCK && Cs.game.badsList.length>BADS_LIMIT )return null;
		var b = new Bads(null);
		var m = 15
		b.x = m+Math.random()*(Cs.mcw-2*m)
		//b.y = -20
		b.vy = 3
		b.outSafeTimer = 100

		return b;
	}

	// OMEGA
	static function newOmega(){
		var b = newBad();
		b.setLevel(1.6)
		b.setScore(Cs.C_OMEGA)

		b.hp = 1;
		b.setSkin(1)
		var raf = b.newRafale();
		raf.addShot( 1, [3,0.6], 100, 1 )
		b.shootTimer =  150+Math.random()*500

		b.turn = downcast(b.root.smc).turn
		b.turnSpeed = 2+Math.random()*6

		return b;
	}

	// BLACKRON
	static function newBlackron(){
		var b = newBad();
		b.setLevel(2.5)
		b.setScore(Cs.C_BLACKRON)

		b.hp = 2;
		b.setSkin(2)
		return b;
	}

	// FURIA
	static function newFuria(){
		var b = newBad();
		b.setLevel(2)
		b.setScore(Cs.C_FURIA)
		b.hp = 1;
		b.setSkin(3)
		var raf = b.newRafale();
		raf.addShot( 0, [4.5,13], 0, 1 )
		b.shootTimer =  70+Math.random()*30

		return b;
	}

	// GROMPH
	static function newGromph(){
		var b = newBad();
		b.setLevel(7)
		b.setScore(Cs.C_GROMPH)
		b.hp = 5;
		b.setSkin(4)

		var raf = b.newRafale();
		raf.addShot( 2, [6,21], 4, 3 )
		raf.dy = 0
		raf.orientRay = 26


		b.fire = b.root.smc;
		b.follow = b.root.smc;
		b.shootTimer =  80

		return b;
	}

	// SURGROMPH
	static function newSurGromph(){
		var b = newBad();
		b.setLevel(20)
		b.setScore(Cs.C_SURGROMPH)
		b.hp = 16;
		b.setSkin(5)

		var raf = b.newRafale();
		raf.addShot( 2, [6,21], 4, 3 )
		raf.cooldown = 60
		raf.dy = 0
		raf.orientRay = 26


		b.fire = b.root.smc;
		b.follow = b.root.smc;

		b.shootTimer =  40

		return b;
	}

	// BLOCK
	static function newBlock(){
		var b = newBad();
		b.setLevel(6)
		b.setScore(Cs.C_BLOCK)
		b.hp = 30;
		//b.rect = {rw:45,rh:66}
		b.setRect(45,66)
		b.setSkin(20)
		b.y = -b.rect.rh
		Cs.game.dm.under(b.root)
		return b;
	}

	// BRIAROS
	static function newBriaros(){
		var b = newBad();
		b.setLevel(6)
		b.setScore(Cs.C_BRIAROS)

		b.hp = 6;
		b.setSkin(6)

		b.vy = -Math.random()*5

		var raf = b.newRafale();
		raf.addShot( 1, [3,0.6], 100, 1 )
		b.shootTimer =  150+Math.random()*15

		b.bList = [6,7]
		b.frict = 0.9

		var m  = 20
		b.beeRange = [
			{w:6,	xMin:m,		xMax:Cs.mcw-m,		yMin:m, 	 yMax:120	}
			{w:1,	xMin:m,		xMax:Cs.mcw-m,		yMin:Cs.mch*0.5, yMax:Cs.mch-76	}
		]
		b.acc = { c:0.1, lim:1 }

		return b;
	}

	// CUTTY
	static function newCutty(){
		var b = newBad();
		b.setLevel(7)
		b.setScore(Cs.C_CUTTY_CLOSE)
		b.score2 = Cs.C_CUTTY_OPEN

		b.vr = (Std.random(2)*2-1)*(5+Math.random()*10)
		b.hp = 14;
		b.setSkin(8)
		b.va = 0.07
		b.turnCoef = 0.1
		b.bounceId = 0
		b.speed = 4.5
		b.bList = [8]

		return b;
	}

	// NES
	static function newNes(){
		var b = newBad();
		b.setLevel(40)
		b.setScore(Cs.C_NES)
		b.hp = 60

		b.setSkin(9)
		var raf = b.newRafale();
		raf.addShot( 0, [10,23,16], 150, 1 )
		raf.cooldown = 40
		raf.dx = -5
		raf.dy = 20

		raf = b.newRafale();
		raf.addShot( 0, [10,23,16], 6, 3 )
		raf.cooldown = 100
		raf.dx = -5
		raf.dy = 24//20

		b.shootTimer =  50+Math.random()*50
		b.rect = {rw:30,rh:25}
		b.fire = b.root.smc.smc.smc

		return b;
	}

	// ORB
	static function newOrb(){
		var b = newBad();
		b.setLevel(18);
		b.setScore(Cs.C_ORB);
		b.setSkin(10);
		b.ray = 25;
		b.y = -(b.ray+5)
		b.hp = 16;
		b.bounceId = 1;
		b.bList = [9]
		b.trg  = {x:0,y:70+Math.random()*30}
		b.waitTimer = 100

		var raf = b.newRafale();
		for( var i=0; i<2; i++ ){
			raf.addShot( 3, [3,13,4,0.7], 14, 1 )
			raf.addShot( 3, [3,13,3,0.5], 14, 1 )
		}
		raf.cooldown = 800
		b.shootTimer = 2000

	}

	// CARRIER
	static function newCarrier(){
		var b = newBad();
		b.setLevel(10);
		b.setScore(Cs.C0);
		b.setSkin(17);
		b.hp = 3;
		b.ray = 20
		b.waitTimer = 300

		b.speed = 6
		b.a = 1.57
		b.va = 0.5
		b.turnCoef = 0.15
		b.flOrient = true;
		b.bList = [3]
		b.onTargetReach = callback(b,chooseNewTarget,20,Cs.mcw-20,30,190);
		b.onTargetReach();

		b.onDeath = callback(b,dropBonus)

		//
		Bonus.NB++

	}

	// GERGIN
	static function newGergin(){
		FL_CREATE_LOCK = true;
		var last = null;
		for( var i=0; i<2; i++ ){
			var b = newBad();
			b.setLevel(22)
			b.setScore( Cs.C_GERGIN )
			b.setSkin(14+i*2)
			b.hp = 30
			b.rect ={rw:20,rh:26}
			if(last==null){
				last = b
				downcast(b.root).react._visible = false;
				b.follow = b.root.smc
				b.bList = [6]
				b.acc = { c:0.1, lim:1 }
				b.frict = 0.9
				var m  = 40
				b.beeRange = [
					{w:6,	xMin:m,		xMax:Cs.mcw-m*2,	yMin:m, 	 yMax:90	}
				]

			}else{
				last.setPart(b,40,0)
				var raf = b.newRafale();
				raf.addShot( 1, [3,0.15], 7, 12 )
				raf.cooldown = 48;
				raf.dy = 25

				var f = fun(){
					last.bList = [3]
					last.turnCoef = 0.1
					last.va = 0.1
					last.trg = upcast(Cs.game.hero)
					last.flOrient = true;
					downcast(last.root).react._visible = true;
				}
				b.onDeath = f;

				var f2 = fun(){
					b.bList = [3]
					b.turnCoef = 0.2
					b.va = 1
					b.trg = {x:Cs.mcw*0.5, y:40}
					b.weapons = []
					var r = b.newRafale();
					r.addShot( 4, [3,0.9], 5, 12 )
					r.cooldown = 48;
					r.dy = 25

				}

				last.onDeath = f2;
			}
		}

		FL_CREATE_LOCK = false;



	}

	// MINE
	static function newMine(){
		var b = newBad();
		b.setLevel(4)
		b.setScore( Cs.C_MINE )
		b.setSkin(18)
		b.hp = 3
		b.ray = 16
		b.vy = 1+Math.random()*1;
		b.bounceId = 2
		b.turn = b.root.smc
		b.onDeath = fun(){
			var raf = b.newRafale();
			raf.shot(3, [3, 13, 12, 3.14] );
		}
	}

	// SHIELD
	static function newShield(){
		var b = newBad();
		b.setLevel(13)
		b.setScore( Cs.C_SHIELD )
		b.setSkin(19)
		b.hp = 10
		b.ray = 27
		b.shieldLim = 120

		var m = 20
		b.bList = [6,10]
		b.acc = { c:0.1, lim:1 }
		b.frict = 0.92
		b.beeRange = [
			{w:6,	xMin:m,		xMax:Cs.mcw-m,	yMin:m, yMax:170 }
		]
	}


	// STORM
	static function newStorm(lvl){ // 0 - 1 - 2
		FL_CREATE_LOCK = true;
		// BASE
		var b = newBad();
		b.setLevel((lvl+1)*32)
		b.setScore( Cs.C_STORM[lvl] )

		b.setSkin(11)
		b.setSubSkin(lvl+1)
		b.hp = 28+lvl*20
		b.ray = 25
		b.bList.push(5)
		b.waitTimer = 500+lvl*150



		for( var i=0; i<2; i++ ){
			var side = newBad();
			var sens = i*2-1
			side.setLevel(2+lvl)
			side.flSide = true;
			side.setSkin(12);
			side.setSubSkin(lvl+1)
			side.root._xscale = sens*100;
			side.hp = 8+lvl*6
			side.ray = 20
			b.setPart(side,25*sens,0)

			//
			var raf = side.newRafale();
			raf.addShot( 0, [12,19], 12, 1+lvl )
			raf.cooldown = 150
			side.shootTimer = 150
		}

		// SHOTS
		var raf = b.newRafale();
		raf.addShot( 1, [3,0.4], 5, 5+4*lvl )
		b.shootTimer = 10



		return b;
		FL_CREATE_LOCK = false;
	}





}