import mt.bumdum9.Lib;

typedef EBMonster = {>Phys, type:Int, angle:Float, wp:{x:Float,y:Float}, eat:Null<Int> };

class EscapeBug extends Game{//}

	var monsterMax:Int;
	var startCoef:Float;
	var bug:{>Phys, wp:{x:Float,y:Float}};
	var monsters:Array<EBMonster>;
	var sortList:Array<flash.display.MovieClip>;
	var waypoints:Array<flash.display.MovieClip>;

	override function init(dif:Float) {
	
		gameTime =  320;
		timeProof = true;
		sortList = [];
		startCoef = 0;
		monsterMax = 2+Std.int(dif*11);
		super.init(dif);
		attachElements();
	}

	function attachElements(){

		
		
		bg = dm.attach("escapeBug_bg",0);

		// BUG
		bug = cast newPhys("escapeBug_bug");
		bug.x = Cs.mcw*0.5;
		bug.y = Cs.mch*0.5;
		bug.updatePos();
		bug.root.stop();
		bug.setScale(0.8);
		sortList.push(bug.root);
		Filt.glow(bug.root,2,1,0x4B2601);

		// WAYPOINTS
		waypoints = [];
		for( i in 0...10 ){
			var mc = dm.attach("escapeBug_wp",0);
			var to = 0;
			while(true){
				var ma = 30;
				var x = ma+Math.random()*(Cs.mcw-2*ma);
				var y = ma+Math.random()*(Cs.mch-2*ma);
				var flOk = true;
				for( wp in waypoints ){
					var dx = x - wp.x;
					var dy = y - wp.y;
					var dist = Math.sqrt(dx*dx+dy*dy);
					if( dist < 50 ){
						flOk = false;
						break;
					}
				}
				if( flOk || to++ > 100 ){
					mc.x = x;
					mc.y = y;
					waypoints.push(mc);
					break;
				}

			}
			//mc.onPress = callback(gotoWaypoint,mc);
			//var me = this;
			//mc.addEventListener(flash.events.MouseEvent.CLICK, function(e) { me.gotoWaypoint(mc); } );
		}

		// MONSTERS
		monsters = [];
		for( i in 0...monsterMax ){
			var sp:EBMonster = cast newPhys("escapeBug_barbapapa");
			var a = Math.random()*6.28;
			var dist = 200 + Math.random()*200;
			var x = Cs.mcw*0.5 + Math.cos(a)*dist;
			var y = Cs.mch*0.5 + Math.sin(a)*dist;
			var ma = 30;
			sp.x = Num.mm(ma,x,Cs.mcw-ma);
			sp.y = Num.mm(ma,y,Cs.mcw-ma);
			sp.type = 0;
			sp.angle = a+3.14;
			sp.setScale(1.2);
			sp.updatePos();
			sp.root.gotoAndPlay(Std.random(10));
			
			sortList.push(sp.root);
			monsters.push(sp);
		}


	}
	
	override function onClick() {
		super.onClick();
		var mp = getMousePos();
		for( mc in waypoints ) {
			var dx = mc.x - mp.x;
			var dy = mc.y - mp.y;
			if( Math.sqrt(dx * dx + dy * dy) < 30 ) {
				gotoWaypoint(mc);
				return;
			}
		}
	}
	
	

	function gotoWaypoint(mc:flash.display.MovieClip) {
		if(bug == null) return;
		bug.wp = {
			x:mc.x,
			y:mc.y,
		}



		for( i in 0...8 ){
			var p = newPhys("fxSpark");
			p.x = mc.x + (Math.random()*2-1)*20;
			p.y = mc.y + (Math.random()*2-1)*20;
			p.weight = -(0.05+Math.random()*0.3);
			p.timer = 15+Std.random(15);
			p.root.gotoAndPlay(Std.random(9)+1);

		}

		mc.parent.removeChild(mc);
		waypoints.remove(mc);
		
	}


	override function update(){

		switch(step){
			case 1 :
				updateBug();
				if(gameTime == 0 )setWin(true,20);
			case 2 :



		}

		updateMonsters();

		sortList.sort(Cs.ySort);
		for(mc in sortList)	dm.over(mc);

		super.update();

	}


	function updateBug(){

		if( bug.wp == null ){

			// ROTATION
			var mp = getMousePos();
			var dx = mp.x - bug.x;
			var dy = mp.y - bug.y;
			var a = Math.atan2(dy,dx);
			face(a);

		}else{
			var dx = bug.wp.x - bug.x;
			var dy = bug.wp.y - bug.y;
			var a = Math.atan2(dy,dx);
			face(a);

			var dist = Math.sqrt(dx*dx+dy*dy);
			var speed = 10;
			var d = Num.mm(-speed,dist*0.5,speed);

			bug.x += Math.cos(a)*d;
			bug.y += Math.sin(a)*d;

			if( dist < 1 )bug.wp = null;
			

		}
	}

	function updateMonsters(){

		startCoef += 0.05;


		for( i in 0...monsters.length ){
			var sp = monsters[i];
			if(sp.eat!=null){
				sp.eat -- ;
				if(sp.eat==0){
					sp.eat = null;
					sp.root.play();
				}
			}else{
				moveMonster(sp);
			}

			var ray = 14;
			for( n in (i+1)...monsters.length ){
				var sp2 = monsters[n];
				var dx = sp2.x - sp.x;
				var dy = sp2.y - sp.y;
				var dist = Math.sqrt(dx*dx+dy*dy);
				if( dist < 2*ray ){

					var rec = (2*ray-dist)*0.5;
					var a = Math.atan2(dy,dx);
					var ca = Math.cos(a)*rec;
					var sa = Math.sin(a)*rec;

					sp2.x += ca;
					sp2.y += sa;
					sp.x -= ca;
					sp.y -= sa;
				}
			}



		}

	}
	function moveMonster(sp:EBMonster){
		if( sp.wp == null ){
			var to = 0;
			while(true){
				var ma = 20;
				var x = ma+Math.random()*(Cs.mcw-2*ma);
				var y = ma+Math.random()*(Cs.mch-2*ma);
				var flOk = true;
				for( sp2 in monsters ){
					if( sp2.wp !=null ){
						var dx = x - sp2.wp.x;
						var dy = y - sp2.wp.y;
						if( Math.sqrt(dx*dx+dy*dy) < 100 ){
							flOk = false;
							break;
						}
					}
				}
				if( flOk || to++> 50 ){
					sp.wp = { x:x, y:y };
					break;
				}
			}
			if( bug != null && Math.random() * 3 < dif ) {
				sp.wp = { x:bug.x, y:bug.y };
			}
			
			
		}
		var dx = sp.wp.x - sp.x;
		var dy = sp.wp.y - sp.y;
		var da = Num.hMod(Math.atan2(dy,dx) - sp.angle, 3.14);

		var lim = 0.1;
		sp.angle += Num.mm(-lim,da*0.2,lim);

		var speed = 2.0;
		if(startCoef<1)speed*=startCoef;
		sp.x += Math.cos(sp.angle)*speed;
		sp.y += Math.sin(sp.angle)*speed;
		var c = Num.sMod(sp.angle, 6.28) / 6.28;
		var smc = getSmc(sp.root);
		if(smc!=null) smc.gotoAndStop(1+Std.int(24*c));

		if( Math.sqrt(dx*dx+dy*dy) < 25 || Std.random(100) == 0 ) sp.wp = null;

		if( bug!=null && sp.getDist(bug) < 17 && win == null ){
			step = 2;
			sp.eat = 13;
			bug.kill();
			sortList.remove(bug.root);
			setWin(false,30);
			sp.root.gotoAndStop(1);
			var smc = getSmc(sp.root);
			if(smc!=null) smc.gotoAndPlay("eat");
			bug = null;
		}

	}


	function face(a:Float){
		var c = Num.sMod(a,6.28)/6.28;
		bug.root.gotoAndStop(1+Std.int(20*c));
	}


//{
}

























