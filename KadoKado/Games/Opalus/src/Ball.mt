class Ball extends Phys{//}

	

	static var TENSE_LIMIT = 0.2
	static var TENSE_POWER = 0.1
	static var RECAL_SPEED = 0.4
	
	var flFly:bool;
	var flIce:bool;
	
	var px:int;
	var py:int;
	var gid:int;
	
	var link:Array<Ball>;
	var wg:float
	var vs:float
	var deathTimer:float

	var color:int;
	var trg:{x:float,y:float}
	
	
	function new(mc){
		super(mc)
		link = new Array();
		downcast(root).obj = this;
		Cs.game.bList.push(this)
		//ray = 8;
		ray = Cs.RAY;
		frict = 1
		wg = 0.5
		
		flFly = false;
		flIce = false;
		
		color = Std.random(Cs.game.colorMax)
		updateSkin();
		
		root._xscale = (Cs.RAY/12)*100
		root._yscale = root._xscale
		
		
	}
	
	function update(){
		super.update();
		/*
		if(Key.isDown(Key.SPACE)){
			for( var i=0; i<18000; i++ ){
				var t = 8
			}
		}
		//*/
		if(flFly){
			if(checkCol(0))freeze();
			if( getDist({x:0,y:0}) > Cs.mcw*0.8 ){
				kill()
				Cs.game.initStep(Cs.STEP_BLAST)
			}
		}
		
		if(deathTimer!=null){
			deathTimer-=Timer.tmod;
			var lim = 5
			if(deathTimer<lim){
				var c = 1-deathTimer/lim
				//root._x += Math.random()*c*4
				//root._y += Math.random()*c*4
				//if( Math.random()*(1-c) < 0.1 )genDust();
				root._xscale = 100+c*10//60+(1-c)*40
				root._yscale = root._xscale 
			}
			
			if(deathTimer<0){
				//for( var i=0; i<15 ; i++ )genDust();
				var mc = Cs.game.dm.attach("partImpact",Game.DP_PART)
				mc._x = x;
				mc._y = y;
				mc._xscale = 300
				mc._yscale = mc._xscale
				mc._rotation = Math.random()*360
				/*
				var p = new Part(Cs.game.dm.attach("partOnde",Game.DP_PART))
				p.x = x;
				p.y = y;
				p.setScale(30)
				*/
				kill();
			}
			
		}
		
		if(trg!=null){
			toward(trg,RECAL_SPEED,20)
			if(getDist(trg)<0.5)trg=null;
		}
		
		if(vs!=null){
			var ds = 100-root._xscale
			vs += ds*0.2*Timer.tmod;
			vs *= Math.pow(0.7,Timer.tmod)
			root._xscale += vs*Timer.tmod;
			root._yscale = root._xscale
			
			if( Math.abs(ds)<0.5 &&  Math.abs(vs)<0.5 ){
				vs = null
				root._xscale = 100
				root._yscale = root._xscale
			}
			
		}
		
		
	}
	
	function checkCol(n){
		for( var i=0; i<Cs.game.bList.length; i++ ){
			var b = Cs.game.bList[i]
			if(b!=this){
				var dist = getDist(b)
				if( dist<ray*2+n ){
					return true;
				}
			}
		}
		return false
	}

	function freeze(){

		flFly = false;
		var p = 0.02
		do{
			x -= vx*p;
			y -= vy*p;
			var pos = Cs.getPos(x,y)
			px = pos.x;
			py = pos.y;			
			
		}while( checkCol(0) || checkPos() ) //
		
		if(checkAlone(px,py))stickNearest();
		
		vx=0;
		vy=0;
		var ox = x
		var oy = y	
		refreshPos();
		trg = {x:x,y:y}
		x = ox;
		y = oy;
		
		Cs.game.initStep(Cs.STEP_BLAST)
		

		
		
	
	}

	function checkAlone(cx,cy){
		for( var i=0; i<Cs.DIR.length; i++ ){
			var d = Cs.DIR[i]
			var nx = cx+d[0]
			var ny = cy+d[1]
			var b = Cs.game.grid[nx+Cs.GRID_RAY][ny+Cs.GRID_RAY];
			if(b!=null)return false;
		}
		return true;
	}
	
	function stickNearest(){
		for( var r=1; r<10; r++ ){
			for( var i=0; i<Cs.DIR.length; i++ ){
				var d = Cs.DIR[i]
				var bx = px + d[0]*r
				var by = py + d[1]*r
				for( var n=0; n<r; n++ ){
					var d2 = Cs.DIR[(i+2)%Cs.DIR.length]
					var nx = bx + d2[0]*n
					var ny = by + d2[1]*n
					var b = Cs.game.grid[nx+Cs.GRID_RAY][ny+Cs.GRID_RAY];
					if( b==null && !checkAlone(nx,ny) ){
						px = nx;
						py = ny;
						return;
					}
				}
			}
		}
	}
	
	function setPos(nx,ny){
		px = nx;
		py = ny;
		refreshPos();
	}
	
	function checkPos(){
		return Cs.game.grid[px+Cs.GRID_RAY][py+Cs.GRID_RAY] !=null
	}
	
	function refreshPos(){
		x = (px+py)*Cs.WW;
		y = (px-py)*Cs.HH;
		Cs.game.grid[px+Cs.GRID_RAY][py+Cs.GRID_RAY] = this;
	}
	
	function fall(){
		var star = new Part( Cs.game.gdm.attach("partStar",10) )
		star.root.gotoAndStop(string(1+color));
		var pos = getWorldPos(x,y)
		star.x = pos.x
		star.y = pos.y
		//star.vr = (Math.random()*2-1)*10
		star.weight =0.2+Math.random()*0.5 //1 + (Math.random()*2-1)*0.7
		//star.vy = -Math.random()*5
		star.fadeType = 0
		star.timer = 18+Math.random()*10
		var baseScore = Cs.SCORE_STAR[color]
		if(color==20)baseScore = Cs.C1000;
		
		star.deathScore = KKApi.const( KKApi.val(baseScore)*(Cs.game.combo+1) );
		kill();
		
	}
	
	function explode(){
		for( var i=0; i<20; i++ ){
			genSpark();
		}	
		for( var i=0; i<Cs.DIR.length; i++ ){
			var nx = px+Cs.DIR[i][0]
			var ny = py+Cs.DIR[i][1]
			var b2 = Cs.game.grid[nx+Cs.GRID_RAY][ny+Cs.GRID_RAY]
			if(b2.flIce){
				b2.unIce();
			}
		}
		
		kill();
	}
	
	function genSpark(){
		var p = new Part(Cs.game.gdm.attach("partSpark",10))
		var a = Math.random()*6.28
		var ca = Math.cos(a)
		var sa = Math.sin(a)
		var sp = 1+Math.random()*3
		var pos = getWorldPos(x,y)
		p.x = pos.x+ca*ray
		p.y = pos.y+sa*ray
		p.vx = ca*sp;
		p.vy = sa*sp;
		p.timer = 10+Math.random()*12
		var mc = downcast(p.root).sub
		var na = a+(Std.random(2)*2-1)*1.57
		var dec = 1+Math.random()*10
		mc._x = Math.cos(na)*dec
		mc._y = Math.cos(na)*dec
		p.x -= mc._x;
		p.y -= mc._y;
		p.vr = (Math.random()*2-1)*20
		mc.gotoAndPlay(string(Std.random(2)+1))
		p.fadeType = 0;
	}
	
	function genDust(){
		var p = new Part(Cs.game.dm.attach("partStar",Game.DP_PART))
		p.root.gotoAndStop(string(1+color));
		var a = Math.random()*6.28;
		var ca = Math.cos(a);
		var sa = Math.sin(a);
		var r = Math.random()*ray*2*root._xscale/100;
		p.x = x+ca*r;
		p.y = y+sa*r;
		p.weight = 0.5+(Math.random()*2-1)*0.3;
		p.timer = 10+Math.random()*10;
		p.setScale(10+Math.random()*20)
	}
	
	function unIce(){
		flIce = false;
		updateSkin();
		//
		var max = 10
		for( var i=0; i<max; i++){
			var p = new Part( Cs.game.gdm.attach("partIce",10));
			var a = Math.random()*6.28
			var ca = Math.cos(a);
			var sa = Math.sin(a);
			var sp = 0.5+Math.random()*3
			var pos = getWorldPos(x,y)
			var r = ray+2
			p.x = pos.x+ca*r
			p.y = pos.y+sa*r	
			p.vx = ca*sp
			p.vy = sa*sp
			p.vr = (Math.random()*2-1)*16
			p.weight = 0.1+Math.random()*0.2
			p.root._rotation = a/0.0157 + 90 //Math.random()*360
			p.root.gotoAndPlay(string(Std.random(20)+1));
			p.timer = 10+Math.random()*50
			p.scale = 20+Math.random()*100
			p.fadeType = 1
			p.root._xscale = p.scale;
			p.root._yscale = p.scale;
		}		
		/*
		for( var i=0; i<max; i++ ){
			var p = new Part(Cs.game.dm.attach("partIce",10));
			var a = (i/max)*6.28 //Math.random()*6.28
			var ca = Math.cos(a);
			var sa = Math.sin(a);
			var sp = 2//0.5+Math.random()*2
			//var ray = 6
			var pos = getWorldPos(x,y)
			p.x = pos.x + ca*ray
			p.y = pos.y + ca*ray
			p.vx = ca*sp
			p.vy = sa*sp
			//p.weight = 0.3*Math.random()*0.2
			p.timer = 20+Math.random()*5
			p.root.gotoAndStop( string(Std.random(p.root._totalframes)+1) )
			p.root._rotation = a/0.0157
			p.fadeType = 0
		}
		*/		
		
	}
	
	function updateSkin(){
		var frame = color+1;
		if(flIce)frame+=10;
		root.gotoAndStop(string(frame));
	}
	
	function kill(){
		if(Cs.game.center==this)Cs.game.center = null;
		removeFromGrid();
		Cs.game.bList.remove(this)
		super.kill();
	}
	
	function removeFromGrid(){
		Cs.game.grid[px+Cs.GRID_RAY][py+Cs.GRID_RAY] = null;	
	}

	function getWorldPos(x,y){
		
		var a = Math.atan2(y,x)
		var dist = Math.sqrt(x*x+y*y)
		var na = a-Cs.game.angle
		
		var nx = Cs.mcw*0.5+Math.cos(na)*dist;
		var ny = Cs.mch*0.5+Math.sin(na)*dist;
		return {x:nx,y:ny}
	}
	
	
//{
}










