class Game {//}


	static var DP_INTER = 3
	static var DP_PLAN = 1

	//

	static var DP_PARTS = 10
	static var DP_SHOT= 7
	static var DP_HERO = 6
	static var DP_DRAW = 5
	static var DP_MONSTER = 4
	static var DP_BONUS = 3
	static var DP_UNDERPARTS = 2

	//
	static var FORCE_BONUS = [1000,6000,12000]

	//
	var stats:{
		$k:Array<int>
		$b:Array<int>
		$d:float
	}

	var flCheatReady:bool;

	volatile var dif:float
	volatile var monsterLevel:float
	volatile var phaseTimer:float

	var planList:Array<{mc:MovieClip,c:float,flScroll:bool}>;
	var sList:Array<Sprite>;
	var pList:Array<Part>;
	var badsList:Array<Bads>;
	var cardsList:Array<MovieClip>;


	var dm:DepthManager;
	var mdm:DepthManager;

	var hero:Hero;

	var root:MovieClip;
	var map:MovieClip;
	var draw:MovieClip;



	function new(mc) {

		Cs.game = this
		dm = new DepthManager(mc);
		root = mc;

		sList = new Array();
		badsList = new Array();
		cardsList = new Array();


		initPlans();

		hero = new Hero(mdm.empty(DP_HERO))
		hero.x = 150;
		hero.y = 150;

		draw = mdm.empty(DP_DRAW)

		dif = 0;
		phaseTimer = 0;
		monsterLevel = 0;
		/*
		initKeyListener();
		flCheatReady = true;
		//*/
		//
		stats = {
			$k:[0,0,0,0,0,0,0,0,0,0,0,0]
			$b:[]
			$d:null
		}
		//newWave();

	}

	function initKeyListener(){
		var kl = {
			onKeyDown:callback(this,onKeyPress),
			onKeyUp:callback(this,onKeyRelease)
		}
		Key.addListener(kl)

	}
	function onKeyPress(){
		if(flCheatReady){
			var n = Key.getCode();
			if(n>=96 && n<107 ){
				genWave(n-96)
			}
			if(n>=49 && n<52 ){
				hero.shotType = n-49
			}
			if(n>=52 && n<55 ){
				hero.takeSide(n-52)
			}
		}
		flCheatReady = false
	}
	function onKeyRelease(){
		flCheatReady = true;
	}

	function initPlans(){
		planList = new Array();
		for( var i=0; i<12; i++ ){
			var mc = dm.attach("mcPlan",DP_PLAN);
			mc.gotoAndStop(string(i+1))
			var c = (mc._height-Cs.mch)/Cs.MY
			if(c>1 && map == null){
				map = dm.empty(DP_PLAN)
				mdm = new DepthManager(map)
				planList.push({mc:map,c:1,flScroll:false});
				dm.over(mc);
			}
			//downcast(mc).init();
			if(i>0)mc._x = -1500;
			planList.push({mc:mc,c:c,flScroll:true});
			if(mc._totalframes-1==i)break;
		}
	}


	function main() {
		draw.clear();
		updateScroll();

		// SPRITE
		var list = sList.duplicate();
		for( var i=0; i<list.length; i++ ){
			list[i].update();
		}


		// DIF
		dif+=Timer.tmod*6
		var lim = Math.pow(dif*0.005, 0.65 )
		while( monsterLevel < lim ){
			newWave();
		}


		if( hero.tList.getCheat() ){
			KKApi.flagCheater();
		}

	}

	function updateScroll(){


		for( var i=0; i<planList.length; i++ ){
			var info = planList[i]
			var m = 30
			var y = -((hero.ray+hero.y)/(Cs.GL-2*hero.ray))*(Cs.MY*info.c)//-(root._ymouse/Cs.mch)*(Cs.MY*info.c)
			var ty = Math.min( Math.max( -Cs.MY*info.c, y ), 0 );
			if(info.flScroll){
				info.mc._x -= info.c*Cs.SCROLL_SPEED*Timer.tmod;
				if(info.mc._x<-Cs.mcw*2){
					info.mc._x+=Cs.mcw*2;
					downcast(info.mc).init();
				}
			}
			info.mc._y = ty;
		}


	}



	// GEN
	function newWave(){
		//genWave(8)
		//return;
		/*
		wave = new Wave(0)
		for( var i=0; i<8; i++ ){
			var b = new Drone( mdm.attach("mcBat",DP_MONSTER) );
			wave.addBads(b)
		}
		return
		//*/

		// if(true){//




		// CARRIER
		if( Std.random(16)==0 || dif>FORCE_BONUS[0] ){
			genWave(7)
			return;
		}
		// MEDUSA
		if( dif > 24000 && Std.random(3)==0 ){
			genWave(9)
			return;
		}

		// GOLGOTH
		if( dif > 16000 && Std.random(5)==0 ){
			genWave(6)
			return;
		}

		// FROG
		if( dif > 12000 && Std.random(7)==0 ){
			genWave(5)
			return;
		}

		// DRAGON
		if( dif > 10000 && Std.random(10)==0 ){
			genWave(4)
			return;
		}

		// BACTERY
		if( dif > 10000 && Std.random(5)==0 ){
			genWave(8)
			return;
		}

		// RUNNER
		if( dif > 8000 && Std.random(4)==0 ){
			genWave(3)
			return;
		}

		// ONDULATORS
		if( dif > 6000 && Std.random(4)==0 ){
			genWave(2)
			return;
		}

		// LEADER WAVE
		if( dif > 4000 && Std.random(4)==0 ){
			genWave(1);
			return;
		}
		// BASE WAVE
		genWave(0)





	}

	function genWave(id){

		var wave = null;
		switch(id){
			case 0:
				wave = new Wave(null)
				for( var i=0; i<8; i++ ){
					var b = new Drone( mdm.attach("mcBat",DP_MONSTER) );
					wave.addBads(b)
					downcast(b.root).sub.gotoAndPlay(string(i+1))

				}
				break;
			case 1:
				wave = new Wave(null)
				for( var i=0; i<8; i++ ){
					var b = new Drone( mdm.attach("mcBat",DP_MONSTER) );
					if(i==0)b.setLeader();
					wave.addBads(b)
				}
				break;
			case 2:
				var m = 30
				var trg  = {x:0,y:m+Math.random()*(Cs.mch-2*m)}
				for( var i=0; i<8; i++ ){
					var b = new Drone( mdm.attach("mcOndulator",DP_MONSTER) );
					b.trg = trg
					b.decal = i*50
					b.x = Cs.mcw+40 + i*(b.ray+20)
					b.vx = -1.5
					b.setSens(-1)
					b.bList.push(2)
					b.setOndulator();
				}
				break;
			case 3:
				var b = new Runner( mdm.attach("mcRunner",DP_MONSTER) );
				break;
			case 4:
				var leader = null;
				for( var i=0; i<12; i++ ){
					var b = new Dragon( mdm.attach("mcDragon",DP_MONSTER) );
					if(i==0){
						b.x = Cs.mcw+20
						b.y = Math.random()*Cs.GL
						b.setLeader();
						leader = b;
					}else{
						b.leader = leader;
						b.x = leader.x;
						b.y = leader.y;
						leader.qList.push(b)
					}
				}
				mdm.over(leader.root)
				break;
			case 5:
				var b = new Frog( mdm.attach("mcFrog",DP_MONSTER) );
				break;
			case 6:
				var b = new Golgoth( mdm.attach("mcGolgoth",DP_MONSTER) );
				break;
			case 7:
				if( dif>FORCE_BONUS[0] )FORCE_BONUS.shift();
				var b = new Carrier( mdm.attach("mcCarrier",DP_MONSTER) );
				break;
			case 8:
				var b = new Bactery( mdm.attach("mcBactery",DP_MONSTER) );
				break;
			case 9:
				var b = new Medusa( mdm.attach("mcMedusa",DP_MONSTER) );
				break;
		}


	};

	//

	function spawnScore(x,y,score : int){
		var mc =mdm.attach("mcScore",DP_PARTS)

		mc._x = x;
		mc._y = y
		downcast(mc).field.field.text = score
	}




//{
}









