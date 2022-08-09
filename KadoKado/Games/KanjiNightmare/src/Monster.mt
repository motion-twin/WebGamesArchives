class Monster extends Phys{//}

	static var WEIGHT = 1;

	var flSpike:bool;
	var flCol:bool;

	var hp:float;
	var waitTimer:float;
	var flash:float;
	var speed:float;

	var step:int;
	var sens:int;
	var stLevel:int;
	var score:KKConst;

	var stDrop:Array<{w:int,id:int}>
	var plat:Plat;


	function new(mc) {
		super(mc);
		Cs.game.mList.push(this)

		ray = 10;

		flSpike = false;
		hp = 10;
		score = Cs.C0;
		speed = 3
		stDrop = [
			{ w:100,id:1 }
			{ w:20,	id:2 }
			{ w:1,	id:3 }
		]

		flCol = true;

		initStep(0);
		setSens(-1);
	}

	function initStep(n){
		step = n
		switch(step){
			case 0: // GROUND
				root.gotoAndPlay("walk");
				weight = 0;
				vx = 0;
				vy = 0;
				break;

			case 1:	// FLY
				weight = WEIGHT
				plat = null;
				break;

			case 2:	// FALL
				weight = WEIGHT;
				plat = null;
				vy = -(4+Math.random()*5);
				vr = (Math.random()*2-1)*18;
				break;
		}
	}

	function knockOut(){
		initStep(2)
	}

	//
	function update() {
		super.update();
		switch(step){
			case 0: // GROUND

				if(plat.root._visible!=true  ){
					initStep(2);
					break;
				}


				if( plat.isOut(x)){
					x = Cs.mm(plat.x,x,plat.x+plat.w);
					setSens(-sens);
				}
				vx = speed*sens;
				break;

			case 1:// FLY
				checkPlatCol();
				break;
		}
		updateFlash();



		if( (y>600 && Cs.game.hero.y<Hero.DL) ){
			kill();
		}


	}

	//
	function setSkin(n){
		stLevel = n;
		switch(stLevel){
				case 0:
					hp =  10
					score = Cs.C30;
					speed = 2
					noSpikes();
					stDrop.push({w:70,id:4})
					stDrop.push({w:4,id:6})
					stDrop.push({w:1,id:8})
					//stDrop.push({w:1000,id:25})
					//stDrop.push({w:1000,id:8})

					break;
				case 1:
					hp = 30
					score = Cs.C100
					speed = 3;
					noSpikes();
					stDrop.push({w:40,id:4})
					stDrop.push({w:30,id:5})
					stDrop.push({w:15,id:6})
					stDrop.push({w:15,id:8})
					stDrop.push({w:10,id:24})
					stDrop.push({w:10,id:25})
					stDrop.push({w:3,id:20})
					stDrop.push({w:3,id:21})
					stDrop.push({w:1,id:23})


					break;
				case 2:
					hp = 60
					score = Cs.C200
					speed=4
					flSpike = true;
					stDrop.push({w:40,id:5})
					stDrop.push({w:20,id:20})
					stDrop.push({w:20,id:21})
					stDrop.push({w:20,id:25})
					stDrop.push({w:10,id:7})
					stDrop.push({w:5,id:23})

					break;
		}
		downcast(root).b1.gotoAndStop(string(stLevel+1))

	}
	function noSpikes(){
		var mc = downcast(root)
		/*
		mc.b3._visible = false;
		mc.b4._visible = false;
		mc.b5._visible = false;
		/*/
		mc.b3.gotoAndStop("2")
		mc.b4.gotoAndStop("2")
		mc.b5.gotoAndStop("2")
		//*/
	}

	//
	function land(pl){
		plat = pl;
		initStep(0);
	}
	function updateFlash(){
		if(flash!=null){
			var prc= flash
			flash*=0.7
			if(flash<1){
				flash = null
				prc = 0
			}
			Cs.setPercentColor(root,prc,0xFFFFFF)
		}
	}

	//
	function hit(shot:Star){
		KKApi.addScore(Cs.C10)
		harm(shot.damage,false)
		throw(Math.atan2(shot.vy,shot.vx),2)
	}
	function cut(n){
		KKApi.addScore(Cs.C50)
		harm(n,true)
		throw(1.57-(1.57*Cs.game.hero.sens),10)
	}
	function harm(n,flSlash){

		hp-=n
		if(hp<0){

			death(flSlash);
		}else{
			flash=100
		}
	}
	function death(flSlash){

		Cs.game.spawnBonus(root._x,root._y,getDrop())
		Cs.setPercentColor(root,0,0xFFFFFF)
		if(flSlash){
			var a = [Game.DP_MONS,Game.DP_PARTS]
			for( var i=0; i<2; i++ ){
				var p = new Part(Cs.game.mdm.attach("partMonster"a[i]));
				p.x = x;
				p.y = y;
				p.vx = vx-(i*2-1)*2;
				p.vy = vy-(2.5+Math.random()*2);
				p.vr = (Math.random()*2-1)*2
				p.timer = 40+Math.random()*10
				p.weight = 0.3
				p.root.gotoAndStop(string(2-i))
				p.root.smc.gotoAndStop(string(stLevel+1))
				p.flPlatCol = true;
				p.ray = 6
				p.root._xscale = 100*sens
			}
		}else{
			Cs.game.registerMc(root);
			root.gotoAndPlay("death");
			root = null;
		}

		Cs.game.stats.$bads[stLevel]++;
		KKApi.addScore(score)


		kill();

	}
	function throw(a,p){
		var vitx = Math.cos(a)*p
		var vity = Math.sin(a)*p - 3
		if(step==0){
			vity = Math.min(0,vity)
			if(vity<-2){
				initStep(1);
			}else{
				return;
			}
		}
		vx+=vitx
		vy+=vity
	}

	function setSens(n){
		sens = n;
		root._xscale = n*100;
	}

	//
	function getDrop(){
		var sum = 0
		for( var i=0; i<stDrop.length; i++ )sum+=stDrop[i].w;
		var rnd = Std.random(sum)
		sum = 0
		for( var i=0; i<stDrop.length; i++ ){
			sum+=stDrop[i].w;
			if(sum>rnd)return stDrop[i].id;
		}
		return 0;
	}

	//
	function kill(){
		Cs.game.mList.remove(this)
		super.kill();
	}

//{
}









