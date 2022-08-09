class Bads extends Phys{//}

	
	var bList:Array<int>;
	
	var flDeath:bool;
	
	var hp:float;
	
	var level:float;
	var score:KKConst;
	var gid:int;
	
	var flash:float;
	
	var a:float;
	var va:float;
	var speed:float;
	var decal:float;
	var trg:{x:float,y:float}
	
	var cooldown:float;
	var shootRate:float;
	var turnCoef:float;
	
	var wave:Wave;
	var pathIndex:int;
	var waveIndex:int;
	var way:float;
	
	function new(mc){
		super(mc)
		score = KKApi.const(0);
		bList = new Array();
		Cs.game.badsList.push(this)
		Cs.game.monsterLevel += level;
		flDeath = false;
		gid = 1
		cooldown = 100
	}
	
	function update(){
		
		super.update();
		updateBehaviour();
		checkCols();
		
		//SHOOT
		if( cooldown>0 ){
			cooldown-=Timer.tmod;
		}else{
			if(Math.random()*shootRate<1){
				shoot();
			}
		}
		
		// FLASH
		if(flash!=null){
			var prc = Math.min(flash,100)
			flash *= 0.6
			if( flash < 2 ){
				flash = null
				prc = 0
			}
			Cs.setPercentColor(root,prc,0xFFFFFF)
		}
		
		
		
		
	}
	
	function checkCols(){
		if(getDist(Cs.game.hero)<ray+Cs.game.hero.ray){
			Cs.game.hero.death();
			
		}
	}
	
	function updateBehaviour(){
		for( var i=0; i<bList.length; i++ ){
			var n = bList[i]
			switch(n){
				case 0:	// PATH
					
					var sp = wave.speed*Timer.tmod;
					way += sp
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
						var c = ( way - op ) / ( wave.pl[pathIndex]-op );
						var ca = Math.cos(a);
						var sa = Math.sin(a);
						
						x = p0[0] + ca*c*sp;
						y = p0[1] + sa*c*sp;
						
						vx = ca*wave.speed;
						vy = sa*wave.speed;
						
						setSens(vx/Math.abs(vx));
					}
					break;
					
				case 1: // WANDERING
					va += (Math.random()*2-1)*0.06
					va *= Math.pow(0.8,Timer.tmod)
					a += va
					vx = Math.cos(a)*wave.speed
					vy = Math.sin(a)*wave.speed
					checkGround()
					if(isOut(ray+20))kill();
					break;
					
				case 2: // ONDULE
					decal = (decal+16*Timer.tmod)%628
					var ca = 
					y = trg.y + Math.cos(decal/100)*20
					root._rotation = Math.sin(decal/100)*40
					if(x<-40)kill();
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

			}
		}
	}

	function shoot(){

	}
	
	function newShot(){
		var shot = new Shot(null)
		shot.x = x
		shot.y = y
		shot.frict = null;
		shot.flGood = false;
		return shot;
	}
	
	function newAimedShot(speed,sharp){
		if(sharp==null)sharp = 0;
		var shot = newShot();
		var a = getAng(Cs.game.hero)+(Math.random()*2-1)*sharp
		var ca = Math.cos(a);
		var sa = Math.sin(a);
		shot.x = x+ca*ray;
		shot.y = y+sa*ray;		
		shot.vx = ca*speed;
		shot.vy = sa*speed;
		shot.orient();
		return shot;
	}
	
	
	function hit(shot:Shot){
		damage(shot.damage)
		
	}
	
	function damage(n){
		flash = 100
		hp-=n
		if(hp<=0){
			if(!flDeath)explode();
		}
	}
	
	function explode(){
		
		// ONDE
		{
			var p = Cs.game.mdm.attach("partOnde",Game.DP_UNDERPARTS)
			p._x = x;
			p._y = y;
			var sc = ray*2 + 30
			p._xscale = sc;
			p._yscale = sc;
		}
		
		// PAILLETES
		{
			var p = new Part(Cs.game.mdm.attach("partExplosion",Game.DP_UNDERPARTS))
			p.x = x;
			p.y = y;
			p.updatePos();
			p.root._rotation = Math.random()*360
			var sc = 20+ray*6
			p.root._xscale = sc;
			p.root._yscale = sc;
		}
		// DEBRIS
		var fr = 0
		while(true){
			fr++
			var p = new Part(Cs.game.mdm.attach("partDebris",Game.DP_PARTS))
			p.root.gotoAndStop(string(gid))
			var mc = downcast(p.root).sub
			mc.gotoAndStop(string(fr))
			
			var flBreak = (fr+1) > mc._totalframes
			var a = Math.random()*6.28
			var ca = Math.cos(a)
			var sa = Math.sin(a)
			var c = Math.random()
			var sp = 3
			
			p.x = x + ca*c*ray;
			p.y = y + sa*c*ray;
			p.vx = vx + ca*c*sp;
			p.vy = vy + sa*c*sp;
			p.vr = (Math.random()*2-1)*15
			p.timer = 10+Math.random()*10
			p.fadeType = 0
			p.root._rotation = Math.random()*360
			if(flBreak)break;

		}
		

		// WAVE BONUS
		if(wave.bList.length==1){
			var m = 20
			Cs.game.spawnScore( Cs.mm(m,x,Cs.mcw-m), y, KKApi.val(wave.score) )
			KKApi.addScore( wave.score )
		}
		
		// SCORE
		KKApi.addScore(score)
		//
		Cs.game.stats.$k[gid]++
			
		
		kill();
	}
	
	function setSens(n){
		root._xscale = n*100
	}
	
	function kill(){
		flDeath = true;
		Cs.game.monsterLevel -= level;
		Cs.game.badsList.remove(this);
		if(wave!=null)wave.bList.remove(this);
		super.kill();
	}
	
	function bounceFamily(){
		var list = Cs.game.badsList;
		for( var i=0; i<list.length; i++ ){
			var b = list[i]
			if(b.level==level && b!=this){
				var dist = getDist(b)
				if(dist<ray*2){
					
					var a = getAng(b)
					var ca = Math.cos(a)
					var sa = Math.sin(a)
					var d = (ray*2-dist)*0.5
					x -= ca*d 
					y -= sa*d
					b.x  += ca*d;					
					b.y  += sa*d;					
					
				}
			}
		}	
	}
	
	function checkGround(){

		if(y+ray>Cs.GL){
			y = Cs.GL-ray
			vy*=-0.8
			genGroundSmoke();
			if(a!=null){
				a = Math.atan2(vy,vx)
			}
		}		
	}
	
	// ON
	function onTargetReach(){
	
	}
	
	
	// UTILS
	function isOut(m){
		return ( x<-m || x>Cs.mcw+m || y<-m || y>Cs.GL+m )
	}
	
	

//{
}
