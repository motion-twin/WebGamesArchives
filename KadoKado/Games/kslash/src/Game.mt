class Game {//}

	static var DP_BG = 1
	static var DP_BACK = 2
	static var DP_MAP = 3
	static var DP_FRONT = 4
	static var DP_INTER = 5
	
	//
	static var DP_MAPBG = 	1
	static var DP_DECOR = 	2
	static var DP_SHADE = 	3
	static var DP_BONUS = 	4
	static var DP_MONSTER = 5	
	static var DP_HERO = 	7
	static var DP_SHOOT = 	10
	static var DP_PARTS = 	12
	
	static var XMAX = 25
	static var YMAX = 25
	
	static var NIGHT_CODE = [78,73,71,72,84]
	
	var flNight:bool;
	var nightIndex:int;
	
	volatile var monsterLevel:int;
	volatile var monsterLevelMax:float;
	
	volatile var dif:float;
	volatile var cheatTimer:float;
	
	var pList:Array<{>MovieClip,vx:float,vy:float,vs:float,vr:float,ft:int,weight:float,frict:float,t:float,scale:float,flQueue:bool,wt:float}>
	var platList:Array<{x:int,y:int,w:int, mc:{>MovieClip,mask:MovieClip,corner:MovieClip}}>
	var mList:Array<Monster>
	var sList:Array<Shoot>
	var nsList:Array<Shoot>
	var bList:Array<Bonus>
	var iconList:Array<MovieClip>
	var planList:Array<{mc:MovieClip,c:float}>
	var optList:Array<bool>
	
	var stats:{ $opt:Array<int>, $bads:Array<int>, $dif:int }
	
	var dm:DepthManager;
	var mdm:DepthManager;
	
	var hero:Hero;
	
	var root:MovieClip;
	var bg:MovieClip;
	var map:MovieClip;
	var inter:{>MovieClip,fieldStar:TextField};

	var grid:Array<Array<{block:bool,list:Array<Monster>}>>
	
	function new(mc) {
		Cs.game = this
		dm = new DepthManager(mc);
		root = mc;
		bg = downcast(dm.attach("bg",DP_BG))
		bg.stop();
		inter = downcast(dm.attach("inter",DP_INTER))
		
		
		mList = new Array();
		sList = new Array();
		bList = new Array();
		pList = new Array();
		nsList = new Array();
		iconList = new Array();
		planList = new Array();

		stats = {$opt:[0,0,0,0,0,0,0,0,0,0],$bads:[0,0,0,0,0],$dif:null}
		
		initMap();
		planList.push({mc:bg,c:0.13})
		planList.push({mc:map,c:1})

		
		for( var n=0; n<2; n++ ){
			for( var i=0; i<10;i++){
				var m = null
				if(n==0){
					m = dm.attach( "bgFront", DP_FRONT )
				}else{
					m = dm.attach( "bgBack", DP_BACK )
				}
				m.gotoAndStop(string(i+1))
				var c = (m._width-300)/300
				planList.push({mc:m,c:c})
				if(i+1==m._totalframes)break;
			}
		}
		
		
		
		hero = new Hero(mdm.attach("mcHero",DP_HERO));
			
		initGrid();
		initPlat();
		
		monsterLevelMax = 2;
		monsterLevel = 0;
		
		dif=0;
		
		optList = [false,false,false]
		updateIcons();
		
		flNight = false;
		if(Math.random()*500<1)setNight();
		
		
		cheatTimer = 0
		
		var kl = {
			onKeyDown:callback(this,pushKey)
			onKeyUp:null
		}
		Key.addListener(kl)
		nightIndex = 0
	}

	function pushKey(){
		var n = Key.getCode();
		if(n==NIGHT_CODE[nightIndex]){
			nightIndex++
			if(nightIndex==NIGHT_CODE.length)setNight();
		}else{
			nightIndex = 0;
		}
		
	}
	
	function initMap(){
		map = dm.empty(DP_MAP)
		mdm = new DepthManager(map);
		//mdm.attach("mapBg",DP_MAPBG)
	}
	
	function initGrid(){
		grid = new Array();
		for( var x=0; x<XMAX; x++ ){
			grid[x] = new Array();
			for( var y=0; y<YMAX; y++ ){
				grid[x][y] = {block:false,list:[]}
			}
		}
	
	}
	
	function initPlat(){
		
		platList = [
			{ x:0,y:YMAX-1,w:XMAX,mc:null}
		]
		var y = YMAX-1
		
		while(y>8){
			y-=Cs.PLAT_ECART
			var x=Std.random(4)
			while(x<XMAX){
				var w = 2+Std.random(8)
				platList.push({ x:x, y:y, w:w, mc:null})
				x+= w+2+int(Std.random(8)*(1-(y/YMAX)))
			}
		}
		
		for( var i=0; i<platList.length; i++ ){
			var o = platList[i]
			var mc = downcast(mdm.attach("mcPlat",DP_DECOR));
			o.mc = mc;
	
			setPlat(o)

		}
	
	}
	
	function setPlat(o){
		var c = 19
		var mc = o.mc

		mc.gotoAndStop(flNight?"2":"1")
		mc._x = Cs.SIZE*o.x;
		mc._y = Cs.SIZE*o.y;
		mc.mask._xscale = (o.w*Cs.SIZE)-2*c
		mc.corner._x = mc.mask._xscale + c 

		for( var n=0; n<o.w; n++ ){
			grid[o.x+n][o.y].block = true;
		}
	}
	
	
	function main() {
		/*
		Log.print(int(monsterLevel))
		Log.print("-")
		Log.print(int(monsterLevelMax))
		*/
		hero.update();
		for( var i=0; i<mList.length; i++ ){
			mList[i].update();
		}
		for( var i=0; i<sList.length; i++ ){
			sList[i].update();
		}
		for( var i=0; i<bList.length; i++ ){
			bList[i].update();
		}		
		updateScroll();
		updateParts();
		
		if(monsterLevel<monsterLevelMax){
			addMonster();
		}
		
		monsterLevelMax += 0.0025*Timer.tmod
		dif+=1.5*Timer.tmod;;
		//monsterLevelMax += 0.025*Timer.tmod;
		//dif+=15*Timer.tmod;
		
		//cheat();
		
	}

	function updateScroll(){

		
		for( var i=0; i<planList.length; i++ ){
			var info = planList[i]
			var mx = 0//Cs.SIZE*info.c*0.25
			var tx = Math.min( Math.max( 2*mx-(XMAX)*Cs.SIZE*0.5, (Cs.mcw*0.5-hero.root._x) ), -mx )
			var ty = Math.min( Math.max( -YMAX*Cs.SIZE*0.5, (Cs.mch*0.5-hero.root._y) ), 0 )			
			info.mc._x = tx*info.c
			info.mc._y = ty*info.c
		}

		
	}
		
//
	function addMonster(){
		//newMonster(4)
		//return;
		
		
		//*
		// TANKER
		if( dif>4000 && Std.random(4)==0 ){
			newMonster(4)
		}
		// FLIER
		if( dif>1800 && Std.random(4)==0 ){
			newMonster(3)
		}
		//*/
		// RUNNER
		newMonster( Std.random( int(Math.min(Math.ceil(dif/1300),3)) ) )
	}
	
	function newMonster(id){
		Cs.game.stats.$bads[id]++
		var sens = (hero.x<XMAX*0.5)?1:0
		var m = null
		switch(id){
			case 0:
			case 1:
			case 2:
				m = downcast(new Soldier(mdm.attach("mcMonster",DP_MONSTER)));
				m.x = sens*XMAX
				m.y = YMAX-(2+(Std.random(6))*Cs.PLAT_ECART)
				m.dx = Math.random()*10
				m.setSens(-(sens*2-1))
				m.setLevel(id+1)

			
				break;
			case 3: 
				m = downcast(new Flyer(mdm.attach("mcFlyer",DP_MONSTER)));
				m.x = Std.random(XMAX);
				m.y = 0;
				break;
			case 4: 
				m = downcast(new Tanker(mdm.attach("mcTanker",DP_MONSTER));)
				m.x = sens*XMAX 
				m.y = YMAX-(2+(Std.random(6))*Cs.PLAT_ECART)
				break;			
		}
		
		monsterLevel+=m.stLevel;
		return m;
	}
		
	function spawnBonus(x,y,id){
		if(id==0)return;
		if( id>=6 && id<9){
			if(optList[id-6])id=1;
		}
		var b = new Bonus(mdm.attach("bonus",DP_BONUS))
		b.root._x = x//(x+0.5)*Cs.SIZE;
		b.root._y = y//(y+0.5)*Cs.SIZE;
		b.setId(id);
		bList.push(b);		
	}
	
	//
	function updateIcons(){
		while(iconList.length>0)iconList.pop().removeMovieClip()
		var x = Cs.mcw
		for( var i=0; i<optList.length; i++ ){
			if(optList[i]){
				var mc = dm.attach("mcIcon",DP_INTER);
				mc.gotoAndStop(string(i+1));
				mc._x = x;
				x-=20;
				iconList.push(mc)
			}
		}
	}
		
	
	//
	function checkFree(x,y){
		return !grid[x][y].block
	}
	
	function getClosestMonsters():Array<{m:Monster,d:float}>{
		var list = new Array();
		
		for( var i=0; i<mList.length; i++ ){
			var m = mList[i]
			var d = Math.max(Math.abs(m.x-hero.x),Math.abs(m.y-hero.y))
			var n = 0
			do{
				if(list[n].d>d)break;
				n++
			}while(n<list.length)
			list.insert(n,{m:m,d:d})
			//list[n]={m:m,d:d}
			/*
			if( d<min ){
				cur = m
				min = d;
			}
			*/
		}
		/*
		var min = 1/0
		var cur = null
		for( var i=0; i<mList.length; i++ ){
			var m = mList[i]
			var d = Math.max(Math.abs(m.x-hero.x),Math.abs(m.y-hero.y))
			if( d<min ){
				cur = m
				min = d;
			}
		}
		if( min < 8 )return cur
		*/
		return list;
		
		
	}

	function setNight(){
		if(!flNight){
			flNight = true;
			var c = 19
			for( var i=0; i<platList.length; i++)setPlat(platList[i]);
			bg.gotoAndStop("2")
			
			for( var i=0; i<planList.length; i++ ){
				var o = planList[i]
				if(o.c!=1 && o.c>0.5)Cs.setPercentColor(o.mc,40,0x000044);
			}
			
		}
	}
	
	// PARTS
	function updateParts(){
		for( var i=0; i<pList.length; i++ ){
			var p = pList[i]
			if(p.wt>0){
				p.wt-=Timer.tmod
				if(p.wt<=0)p._visible = true;
			}else{
				
				
				if( p.weight != null ){
					p.vy += p.weight*Timer.tmod;
				}
				if( p.frict != null ){
					p.vx *= p.frict
					p.vy *= p.frict
				}
				if( p.vs != null ){
					p._xscale += p.vs*Timer.tmod;
					p._yscale += p.vs*Timer.tmod;
				}
				if( p.vr != null ){
					p._rotation += p.vr*Timer.tmod;
				}
				
				var ox = p._x
				var oy = p._y
				
				p._x += p.vx*Timer.tmod;
				p._y += p.vy*Timer.tmod;
				
				if(p.flQueue){
					var dx = ox - p._x
					var dy = oy - p._y
					var a = Math.atan2(dy,dx)
					var d = Math.sqrt(dx*dx+dy*dy)
					var q = newPart("partQueue")
					q._x = p._x;
					q._y = p._y;
					q._rotation = a/0.0174
					q._xscale = d;
				}
				
				
				if(p.t!=null){
					p.t-=Timer.tmod;
					if(p.t<0){
						p.removeMovieClip();
						pList.splice(i--,1)
					}else if(p.t<10){
						switch(p.ft){
							case 0:
								p._xscale = p.scale*(p.t/10);
								p._yscale = p._xscale;
								break;
							default:
								p._alpha = p.t*10
								break;
						}
					}
				}
				
				
				
				
			}
			
			
		}
	}
	
	function newPart(link){
		var p = downcast(mdm.attach(link,DP_PARTS))
		p.vx = 0
		p.vy = 0
		p.frict=0.95
		p.scale = 100
		pList.push(p)
		return p;
	}
	
	/*/ DEBUG
	function logGrid(){
		var str = ""
		var max = 18
		for( var y=0; y<max; y++ ){
			for( var x=0; x<max; x++ ){
				var o = grid[x][y]
				str +=o.list.length
			}
			str+="\n"
		}
		Log.print(str)
	}
	
	function cheat(){
		if(cheatTimer>0){
			cheatTimer-=Timer.tmod

		}else{
			if(Key.isDown(Key.ENTER) && !hero.flInvicible ){
				hero.flInvicible = true
				
			}
			for(var i=0; i<10; i++ ){
				if( Key.isDown(96+i) ){
					newMonster(i)
					cheatTimer = 10
				}
			}
		}
	}
	//*/
	
	
	
//{
}









