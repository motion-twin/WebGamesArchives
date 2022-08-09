class Game {//}

	static var DP_BG = 1
	static var DP_GROUND = 2
	static var DP_SHADOW = 3;
	static var DP_SELECTOR = 4;
	static var DP_BONUS = 5;
	static var DP_UNITS = 6;
	static var DP_PART = 7;
	static var DP_FLY = 8;
	static var DP_DRAW = 9;
	static var DP_INTERFACE = 10;


	static var RENFORT = [300,500,900,1500]

	var flCadre:bool;
	var flShowLife:bool;
	var flCheatReady:bool;
	var flSpaceRelease:bool;

	var step:int;
	var timer:float;
	var scTimer:float;
	var waveTimer:float;
	var dif:float;
	var danger:float;
	var renfort:float;

	var dm:DepthManager;
	var gdm:DepthManager;
	var scp:{x:float,y:float}

	var sList:Array<Sprite>
	var aList:Array<Ally>
	var bList:Array<Alien>
	var bounceList:Array<Phys>
	var bonusList:Array<{sp:Sprite,timer:float,type:int}>


	var bg:MovieClip;
	var draw:MovieClip;
	var map:MovieClip;
	var root:MovieClip;

	var renfortList:Array<MovieClip>


	var stats:{$b:Array<int>,$k:Array<int>,$l:Array<int>,$d:int}


	function new(mc) {
		Cs.init();
		Cs.game = this
		root = mc;
		gdm = new DepthManager(mc)
		map = gdm.empty(1)
		dm = new DepthManager(map);

		bg = dm.attach("mcBg",DP_BG)
		draw = dm.empty(DP_DRAW)

		flCadre = false
		flShowLife = false

		sList = new Array();
		aList = new Array();
		bList = new Array();
		bounceList = new Array();
		renfortList = new Array();
		bonusList = new Array();

		dif = 2
		waveTimer = 800
		danger = 0
		renfort = 0;

		stats = {
			$b:[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
			$l:[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
			$k:[0,0,0,0],
			$d:null
		}

		// ALLY
		var max = 4
		var dist = 30
		for( var i=0; i<max; i++ ){
			var sp = new Marine(null);
			var a = (i/max)*6.28
			sp.x = Cs.mcw*0.5 + Math.cos(a)*dist
			sp.y = Cs.mch*0.5 + Math.sin(a)*dist
			sp.hp = sp.hpMax
		}

		//initKeyListener();
		initStep(0)

		//selectAll();

	}

	function initStep(n){
		step = n
		switch(step){
			case 0:
				bg.onPress = callback(this,startClick)
				bg.onRelease = callback(this,releaseClick)
				//bg.useHandCursor = false;
				break;
			case 1:

				break;
		}
	}

	function main() {
		//for(var i=0;i<300000;i++)var ab = 8.135*5.684;
		var loop = Math.max(Timer.tmod,1);
		var lim = 1;
		if(Timer.tmod>lim)Timer.tmod= lim;

		timer-=Timer.tmod;

		for( var li=0; li<loop; li++ ){
			draw.clear();
			switch(step){
				case 0:
					// CADRE
					if(flCadre){
						drawCadre();
						if(bg._xmouse<0 || bg._xmouse>Cs.mcw || bg._ymouse<0 || bg._ymouse>Cs.mch ){
							releaseClick();
						}

					}else if( scTimer!=null){
						scTimer += Timer.tmod
						var dx = scp.x - bg._xmouse
						var dy = scp.y - bg._ymouse
						var dist = Math.sqrt(dx*dx+dy*dy)
						if(scTimer>2 && dist > 30 ){
							flCadre = true;
						}
					}

					// SHOW LIFE
					if( Key.isDown(Key.ENTER) ){
						if(!flShowLife){
							for( var i=0; i<aList.length; i++){
								var sp = aList[i]
								sp.showLife();
							}
							flShowLife = true;
						}
					}else{
						if(flShowLife){
							for( var i=0; i<aList.length; i++){
								var sp = aList[i]
								sp.hideLife();
							}
							flShowLife = false;
						}
					}

					// RENFORT
					if(Cs.GAME_MODE==0){
						renfort += Timer.tmod;
						if( renfort >= RENFORT[renfortList.length] ){
							updateRenfortTable();
						}
					}

					// BONUS
					checkBonus()


					// CHECK GAME OVER
					if(aList.length==0){
						stats.$d = int(dif)
						KKApi.gameOver(stats)
						step = 1
						renfort = 0
						updateRenfortTable();
					}
					break;
				case 1:

					break;
			}
			// DIF
			dif += Cs.DIF_RATE*Timer.tmod;
			updateWave();

			// SCROLL
			if(Key.isDown(Key.SPACE)){
				if(flSpaceRelease){
					switch(Cs.SPACE_MODE){
						case 0:
							selectAll();
							break;
						case 1:
							inverseAll();
							break;
					}
				}
				flSpaceRelease = false;
			}else{
				flSpaceRelease = true;
			}

			// BOUNCE
			bounce();
			// SPRITES
			var list = sList.duplicate();
			for( var i=0; i<list.length;i++){
				list[i].update();
			}
		}

	}

	function updateWave(){
		if( waveTimer<0 ){
			var pos = Cs.getOutPos(20+dif);


			while( danger < dif ){
				var sp = newAlien();

				if(sp!=null){
					sp.x = pos.x + (Math.random()*2-1)*20;
					sp.y = pos.y + (Math.random()*2-1)*20;
					sp.angle = sp.getAng( {x:Cs.mcw*0.5,y:Cs.mch*0.5} );
					sp.hp = sp.hpMax;
					danger += sp.value;
				}
			}
			waveTimer = 350+Math.random()*150
		}else{
			var multi = 1
			if( bList.length == 0 )multi+=10;
			waveTimer -= multi*Timer.tmod
		}
	}

	function checkBonus(){
		for( var i=0; i<bonusList.length; i++ ){
				var o = bonusList[i]
				o.timer-=Timer.tmod;
				if(o.timer<10){
					o.sp.root._xscale = o.timer*10
					o.sp.root._yscale = o.sp.root._xscale
				}
				if(o.timer<0){
					Cs.game.stats.$l[o.type]++
					o.sp.kill();
					bonusList.splice(i--,1)

				}else{
					for( var n=0; n<aList.length; n++){
						var al = aList[n]
						if( al.getDist(o.sp) < 10+al.ray ){
							//Log.trace("get "+o.type)
							switch(o.type){
								case 0:
									KKApi.addScore(Cs.C500)
									break;
								case 1:
									KKApi.addScore(Cs.C2000)
									break;
								case 2:
									KKApi.addScore(Cs.C5000)
									break;
								case 3:
									renfort += 1000
									break;
								case 4:
									renfort += 5000
									break;
								case 10:
								case 11:
								case 12:
								case 13:
									spawnRenfort(o.type-10,o.sp)
									break;
							}
							Cs.game.stats.$b[o.type]++
							o.sp.kill();
							bonusList.splice(i--,1)
							break;
						}
					}
				}
			}
	}

	function bounce(){
		for( var i=0; i<bounceList.length; i++ ){
			var sp = bounceList[i]
			for( var n=i+1; n<bounceList.length; n++ ){
				var sp2 = bounceList[n]
				var dif = sp.getDist(sp2) - (sp2.ray+sp.ray)
				if( dif < 0 ){
					var a = sp.getAng(sp2);
					var ca = Math.cos(a);
					var sa = Math.sin(a);

					var c = sp.mass/(sp.mass+sp2.mass)
					if(sp.mass+sp2.mass==0)c = 0.5;

					sp.x += ca*dif*c
					sp.y += sa*dif*c
					sp2.x -= ca*dif*(1-c)
					sp2.y -= sa*dif*(1-c)

				}
			}
		}
	}

	function scroll(){
		var cx = 2*(root._xmouse-Cs.mcw*0.5)/Cs.mcw
		var cy = 2*(root._ymouse-Cs.mch*0.5)/Cs.mch
		cx = Math.pow(cx,2)*(cx/Math.abs(cx))
		cy = Math.pow(cy,2)*(cy/Math.abs(cy))

		var tx = -cx*Cs.mcw*0.5 - Cs.mcw*0.5
		var ty = -cy*Cs.mch*0.5 - Cs.mcw*0.5


		var dx = tx - map._x;
		var dy = ty - map._y;
		var c = 0.1
		map._x += dx*c*Timer.tmod;
		map._y += dy*c*Timer.tmod;
	}

	function updateRenfortTable(){
		var m = 4
		while(renfortList.length>0)renfortList.pop().removeMovieClip();
		for( var i=0; i<RENFORT.length; i++ ){
			if( RENFORT[i] > renfort)return;
			var mc = dm.attach( "mcRenfort",DP_INTERFACE)
			mc.gotoAndStop(string(i+1))
			mc._x = m + i*(20+m)
			mc._y = m

			//mc.onPress = callback(this,spawnRenfort,i)
			renfortList.push(mc)
		}
	}

	function spawnRenfort(n,c:{x:float,y:float}){
		var sp:Ally = null
		if(c==null)c = getListCenter(aList);
		switch(n){
			case 0:
				sp = new Marine(null);
				break;
			case 1:
				sp = new Grenadier(null);
				break;
			case 2:
				sp = new Medic(null);
				break;
			case 3:
				sp = new Jeep(null);
				break;
		}
		sp.x = c.x;
		sp.y = c.y;
		sp.hp = sp.hpMax
		sp.light = 100

		if(Ally.sel.length>0){
			sp.addToSel();
		}

		renfort -= RENFORT[n]
		updateRenfortTable();

		// EFFET
		var mc = dm.attach("partOnde",DP_SHADOW)
		mc._x = sp.x;
		mc._y = sp.y;
		mc._xscale = sp.ray*2.5
		mc._yscale = sp.ray*2.5

		var max = 8
		var cc = 0.7
		for( var i=0; i<12; i++ ){
			var a = i/max*6.28 + (Math.random()*2-1)*0.2
			var ca = Math.cos(a)
			var sa = Math.sin(a)
			var speed = 2+Math.random()*1.5
			var p = new Part( dm.attach("partPaillette",DP_PART) )
			p.x = sp.x + ca*sp.ray*cc
			p.y = sp.y + sa*sp.ray*cc
			p.vx = ca*speed
			p.vy = sa*speed
			p.vr = 30*(Math.random()*2-1)
			p.frict = 0.92
			p.timer = 10 +Math.random()*10
			p.fadeType = 0
			p.setScale(80+Math.random()*40)
			p.root._rotation = Math.random()*360
		}



	}

	function getListCenter(list:Array<Ally>){
		/*
		var sx = 0
		var sy = 0
		for( var i=0; i<list.length; i++ ){
			var al = list[i]
			sx += al.x;
			sy += al.y;
		}



		return {
			x : sx/list.length
			y : sy/list.length
		}
		/*/
		var xMin = 1/0
		var xMax = 0
		var yMin = 1/0
		var yMax = 0

		for( var i=0; i<list.length; i++ ){
			var al = list[i]
			xMin = Math.min(xMin,al.x)
			xMax = Math.max(xMax,al.x)
			yMin = Math.min(yMin,al.y)
			yMax = Math.max(yMax,al.y)
		}
		return {
			x : xMin + (xMax-xMin)*0.5
			y : yMin + (yMax-yMin)*0.5
		}

		//*/

	}

	//
	function newAlien():Alien{
		//var sp:Alien = null

		if( Std.random(2)==0 ){
			return new Runner(null);
		}
		if( Std.random(6)==0 && dif > 5 ){
			return new Tanker(null);
		}

		if( Std.random(48)==0 && dif > 24){
			return new Octopus(null);
		}
		if( Std.random(32)==0 && dif > 38){
			return new Executor(null);
		}

		return null;
		// position



	}

	// CONTROL SOURIS
	function startClick(){
		scTimer = 0
		scp = {
			x:bg._xmouse,
			y:bg._ymouse
		}
	}

	function releaseClick(){
		scTimer = null
		if(flCadre){
			selectCadre();
			flCadre = false
			return;
		}

		// CADRE
		var m = 4
		for( var i=0; i<renfortList.length; i++){
			var xMin = m + i*(20+m)
			var yMin = m
			var xMax = m + i*(20+m) +20
			var yMax = m + 20
			if( bg._xmouse>xMin && bg._xmouse<xMax && bg._ymouse>yMin && bg._ymouse<yMax ){
				spawnRenfort(i,null)
				return;
			}
		}

		switch(Cs.SELECT_MODE){
			case 0:

				if( !selectAlly() && Ally.sel.length>0){
					gotoMouse();
					if(!Key.isDown(Key.SPACE))Ally.flushSelect();
				}
				break;
			case 1:
				if( !selectAlly() ){
					gotoMouse();

				};
				break
			case 2:
				if( !selectAlly() ){
					gotoMouse();

				};
				break

		}




	}

	function selectAll(){

		Ally.flushSelect();
		for( var i=0; i< aList.length; i++ ){
			var al = aList[i]
			if(al.flSelectable){
					al.addToSel();
			}
		}
	}

	function inverseAll(){

		var oldSel = Ally.sel.duplicate();
		Ally.flushSelect();

		for( var i=0; i< aList.length; i++ ){
			var al = aList[i]
			var flAdd = true;
			for( var n=0; n< oldSel.length; n++ ){
				if( al == oldSel[n] ){
					flAdd = false;
					oldSel.splice(n--,1)

					break;
				}
			}
			if(flAdd)al.addToSel();
		}
	}

	function selectAlly(){
		for( var i=0; i<aList.length; i++ ){
			var sp = aList[i]
			if( sp.getDist({x:bg._xmouse,y:bg._ymouse}) < sp.ray*Cs.SELECT_TRESHOLD ){
				sp.selectOne();
				return true;
			}
		}
		return false;
	}

	function gotoMouse(){
		var c = getListCenter(Ally.sel);
		var centerCoef = 0.8
		for( var i=0; i<Ally.sel.length; i++ ){
			var al = Ally.sel[i]
			var wp = {
				x:Cs.mm(al.ray,bg._xmouse - (c.x-al.x)*centerCoef,Cs.mcw-al.ray)
				y:Cs.mm(al.ray,bg._ymouse - (c.y-al.y)*centerCoef,Cs.mch-al.ray)
				ray:null
			}
			al.setWaypoint(wp)
		}
	}

	function drawCadre(){
		draw.lineStyle(6,0x00FF00,15)
		draw.moveTo( bg._xmouse,	bg._ymouse	)
		draw.lineTo( bg._xmouse,	scp.y		)
		draw.lineTo( scp.x,		scp.y		)
		draw.lineTo( scp.x,		bg._ymouse	)
		draw.lineTo( bg._xmouse,	bg._ymouse	)
		draw.lineStyle(1,0x99FF99,100)
		draw.moveTo( bg._xmouse,	bg._ymouse	)
		draw.lineTo( bg._xmouse,	scp.y		)
		draw.lineTo( scp.x,		scp.y		)
		draw.lineTo( scp.x,		bg._ymouse	)
		draw.lineTo( bg._xmouse,	bg._ymouse	)
	}

	function selectCadre(){

		Ally.flushSelect();
		for( var i=0; i< aList.length; i++ ){
			var al = aList[i]
			if(al.flSelectable){
				var xMin = Math.min(scp.x,bg._xmouse)
				var xMax = Math.max(scp.x,bg._xmouse)
				var yMin = Math.min(scp.y,bg._ymouse)
				var yMax = Math.max(scp.y,bg._ymouse)

				var m = al.ray*Cs.SELECT_TRESHOLD
				if( al.x+m>xMin && al.x-m<xMax  && al.y+m>yMin && al.y-m<yMax ){
					al.addToSel();
				}
			}
		}
	}

	// CHEAT
	function initKeyListener(){
		var kl = {
			onKeyDown:callback(this,onKeyPress),
			onKeyUp:callback(this,onKeyRelease)
		}
		Key.addListener(kl)
		flCheatReady = true;

	}

	function onKeyPress(){
		if(flCheatReady){
			var n = Key.getCode();
			if(n>=96 && n<107 ){
				var pos = Cs.getOutPos(20+dif);
				var sp:Alien = null
				switch(n){
					case 96:
						sp = new Runner(null)
						break;
					case 97:
						sp = new Tanker(null);
						break;
					case 98:
						sp = new Octopus(null)
						break;
					case 99:
						sp = new Executor(null)
						break;
					case 104:
						dif++
						break
					case 105:

						renfort += 10000
						updateRenfortTable()
						break;
				}
				if(sp!=null){
				sp.x = pos.x + (Math.random()*2-1)*20;
				sp.y = pos.y + (Math.random()*2-1)*20;
				sp.angle = sp.getAng( {x:Cs.mcw*0.5,y:Cs.mch*0.5} );
				sp.hp = sp.hpMax;
				danger += sp.value;
				}
			}

		}
		flCheatReady = false
	}

	function onKeyRelease(){
		flCheatReady = true;
	}

	// clignotye rouge soltdat malade
	//

//{
}









