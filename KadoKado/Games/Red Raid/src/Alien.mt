class Alien extends Arrow{//}

	var range:float
	var view:float
	var damage:float
	var rate:float
	var cd:float

	var score: KKConst;
	var value:float;
	var ma:float;


	function new(mc){
		Cs.game.bList.push(this)
		Cs.game.bounceList.push(this)
		mc = Cs.game.dm.attach("mcAlien",Game.DP_UNITS)
		super(mc)

		range = 5
		damage = 0
		rate = 1
		view = 50

		va = 1
		ca = 0.3
		ray = 10
		tol = 10

		score = Cs.C1;
		value = 0

		//
		cd = 0;
		frame = 0;

		//
		//ma = 0.5


	};

	function initSkin(){
		super.initSkin();
		shadow = Cs.game.dm.attach("mcAlienShadow",Game.DP_SHADOW)
		shadow.gotoAndStop(string(type+1))

	}

	function update(){
		super.update();
		if(cd>=0)cd-=Timer.tmod;

		if(wp!=null){

			if(cd<0){
				var dist = getDist(wp)

				if(dist>ray+wp.ray+range*Timer.tmod){
					if( Math.random()/Timer.tmod < 0.02 )chooseTarget();
					follow()

				}else{
					var ta = getAng(wp)
					towardAngle(ta)
					if( ma==null || Cs.hMod(angle-ta,3.14) < ma*Timer.tmod )attack();
				}
			}


		}else{
			if(cd<0)chooseTarget();
		}

	};

	function attack(){
		frame = null;
		cd = rate
		skin.gotoAndPlay("attack");
		downcast(wp).hit(damage)
	}

	function chooseTarget(){

		var first = 1/0
		for( var i=0; i<Cs.game.aList.length; i++ ){
			var al = Cs.game.aList[i]
			var dist = getDist(al)
			if(dist<first){
				first = dist
				setWaypoint(al)
			}
		}
	}

	function kill(){
		Cs.game.bList.remove(this)
		Cs.game.bounceList.remove(this)
		Cs.game.danger -= value
		super.kill();
	}

	function die(ba){
		var cc = 0.8
		KKApi.addScore(score)
		var max = ray

		for( var i=0; i<max; i++ ){
			var p = new Part(Cs.game.dm.attach("partBlood",Game.DP_GROUND))
			var a = Math.random()*6.28
			if(ba!=null){
				a = ba+(Math.random()*2-1)
			}
			var ca = Math.cos(a)
			var sa = Math.sin(a)
			p.x = x + ca*ray*cc
			p.y = y + sa*ray*cc
			if(i<max*0.4){
				p.vx = ca*3
				p.vy = sa*3
				p.frict = 0.5
				p.timer = 40+Math.random()*10
				p.setScale( (100+Math.random()*100)*ray*0.08)
			}else{
				var sp = 1+Math.random()*5
				p.vx = ca*sp
				p.vy = sa*sp
				p.timer = 6+Math.random()*10
				p.setScale(20+Math.random()*60)
				p.fadeType = 0;
			}
			p.root.gotoAndStop(string(Std.random(p.root._totalframes)+1))
			p.root._rotation = Math.random()*360
		}

		Cs.game.stats.$k[type]++

		super.die(ba);
	}

	function throwGibs(size,ba){

		var a = ba + (Math.random()*2-1)*0.8 //Math.random()*6.28
		var ca = Math.cos(a)
		var sa = Math.sin(a)
		var dist = Math.random()*ray
		var speed = (dist/ray)*8
		var sp = new Gibs(null);
		sp.x = x+ca*dist
		sp.y = y+sa*dist
		sp.z = 8-(dist/ray)*6
		sp.vx = ca*speed
		sp.vy = sa*speed
		sp.vz = sp.z
		sp.setScale(size*0.5+Math.random()*size)
		sp.timer = 30+Math.random()*20
		sp.wz = 0.2+Math.random()*0.4
		sp.vr = (Math.random()*2-1)*16
		sp.frict = 0.94
		sp.root._rotation = Math.random()*360
		sp.root.gotoAndStop(string(Std.random(sp.root._totalframes)+1))




	}

	function spawnBonus(){
		var sp  = new Sprite(Cs.game.dm.attach("mcBonus",Game.DP_BONUS))
		sp.x = x;
		sp.y = y;

		var type = 0
		var rnd = Math.random();
		switch(Cs.GAME_MODE){
			case 0:
				if(rnd<0.01){
					type = 4
				}else if(rnd<0.05){
					type = 2
				}else if(rnd<0.15){
					type = 3
				}else if(rnd<0.35){
					type = 1
				}
				break;
			case 1:
				if(rnd<0.05){
					type = 2
				}else if(rnd<0.25){
					type = 1
				}
				break;
		}

		sp.root.gotoAndStop(string(type+1))
		Cs.game.bonusList.push({sp:sp,timer:300,type:type})
	}

	function spawnTroup(){
		var sp  = new Sprite(Cs.game.dm.attach("mcBonus",Game.DP_BONUS))
		sp.x = x;
		sp.y = y;

		var type = 10
		var rnd = Math.random();
		if(rnd<0.08){
			type = 13
		}else if(rnd<0.25){
			type = 12
		}else if(rnd<0.5){
			type = 11
		}
		sp.root.gotoAndStop(string(type+1))
		Cs.game.bonusList.push({sp:sp,timer:300,type:type})
	}


//{
}

















