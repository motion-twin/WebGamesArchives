class Shot extends Phys{//}

	
	
	
	var flGood:bool;
	var flPierce:bool;
	var flInvincible:bool;
	var flWarp:bool;

	var ft:int;
	
	
	var sleep:float;
	var damage:float;
	var timer:float;
	var a:float;
	var ray:float;
	var decal:float;
	var vr:float;
	var va:float;
	var ca:float;
	var speed:float;
	var accel:{inc:float,max:float};
	
	var bList:Array<int>;
	
	var op:{x:float,y:float}
	var trg:{x:float,y:float,flDeath:bool};
	var thruster:{vx:float,vy:float,sleep:float}
	var queue:String;
	
	function new(mc){
		
		super(mc) 
		
		va = 0.1
		ca = 0.1
		
		decal = 0;
		speed = 2
		
		flPierce = false;
		flInvincible = false;
		ray = 3
		damage = 0
		ft=0;
		Cs.game.shotList.push(this)
		bList = new Array();

		
		
	}
	
	function update(){
		
		
		if(accel!=null){
			speed = Math.min(speed+accel.inc*Timer.tmod, accel.max)
		}


		checkCols();
		updateBehaviour();
		super.update();
		if(timer!=null){
			timer-=Timer.tmod;
			if(timer<10){
				switch(ft){
					case 0:
						root._alpha =10*timer;
						break;
					case 3:
						root._xscale = 10*timer;
						root._yscale = 10*timer;
						break;
				}
				if(timer<0){
					timer = null
					switch(ft){
						case 1:
							kill();
							break;
						case 2:
							root.smc.gotoAndPlay("death");
							break;
						default:
							kill();
							break;
						
					}
					
				}
			}
		}		
		
		if(isOut(50))kill();
	
		/*
		updateBehaviour();
		*/
		
		
	}

	function updateBehaviour(){
		for( var n=0; n<bList.length; n++ ){
			var id = bList[n]
			
			switch(id){
				case 0: // BOMB
					root._rotation += vr*Timer.tmod;
					break;

				case 3: // HOMING
					if(sleep>0){
						sleep-=Timer.tmod;
						break;
					}
					getNewBadTrg();
					if(trg==null)break;
					var da = getAng(trg) - a
					while(da>3.14)da-=6.28;
					while(da<-3.14)da+=6.28;
					a += Cs.mm(-va,da*ca,va)*Timer.tmod;
					updateVit()
					break
				case 4: // ONDULE
					decal = (decal+43*Timer.tmod)%628
					a+=Math.cos(decal/100)*0.2*Timer.tmod;
					updateVit()
					break;
				
				case 5: // SWARM
					if( Math.sqrt(vx*vx+vy*vy)<3 || Math.random()/Timer.tmod < 0.1 ){
						a = Std.random(4)*1.57
						vx = Math.cos(a)*speed;
						vy = Math.sin(a)*speed;
					}
					break;
				case 6: // PLASMA DRAW
					Cs.game.plasmaDraw(root,0)
					break;
				case 7: // ACCEL
					speed += 0.05*Timer.tmod;
					break;
				case 11:
					var max = 2*Game.PM
					for( var i=0; i<max; i++ ){
						var p = new Part( Cs.game.dm.attach("partPlasmaBolt",Game.DP_PARTS) )
						var a = Math.random()*6.28;
						var r = Math.random()*40
						p.x = x + Math.cos(a)*r;
						p.y = y + Math.sin(a)*r;
						p.vy = - (1+Math.random()+6);
						//p.timer = 20+Math.random()*10;
						p.root._xscale = 150//+Math.random()*100
						p.root._yscale = p.root._xscale
						p.root.blendMode = BlendMode.ADD;
						p.fadeType = 0
					}
					break;

			}
		}
		
		if(thruster!=null){
			if(thruster.sleep==null){
				vx+=thruster.vx*Timer.tmod;
				vy+=thruster.vy*Timer.tmod;
			}else{
				thruster.sleep-=Timer.tmod;
				if(thruster.sleep<0)thruster.sleep=null;
			}
		}
		
		if(queue!=null){
			if(op!=null){
				var mc = Cs.game.dm.attach(queue,Game.DP_PARTS)
				mc._rotation = 180+getAng(op)/0.0174
				mc._xscale = getDist(op)
				mc._x = x;
				mc._y = y;
				//mc.blendMode = BlendMode.ADD
				if(timer!=null)mc._alpha = Cs.mm(0,10*timer,100)
				Cs.game.plasmaDraw(mc,0);
				
				mc.removeMovieClip();
			}
			op={x:x,y:y+Game.SCROLL_SPEED*3}
			/*
			var mc = Cs.game.dm.attach("queueRocket",Game.DP_PARTS)
			mc._rotation = 180+getAng(op)/0.0174
			mc._xscale = getDist(op)
			mc._x = x;
			mc._y = y;
			op={x:x,y:y}
			*/
		}
		
	}
	
	function updateVit(){
		vx = Math.cos(a)*speed;
		vy = Math.sin(a)*speed;
		orient();
	}
	
	function getNewBadTrg(){
		
		var list = Cs.game.badsList
		var dist = 1/0
		trg = null;
		for( var i=0; i<list.length; i++ ){
			var b = list[i]
			var d = getDist(b) 
			if(d<dist){
				trg = upcast(b);
				dist = d;
			}
		}
		
		
		if( list.length>0 ){
			trg = upcast(list[Std.random(list.length)])
		}else{
			trg = null;
		}
	}
	
	function checkCols(){
		
		if(flGood){
			var list = Cs.game.badsList
			for( var i=0; i<list.length; i++ ){
				var b = list[i]
				if(b.rect!=null){
					if( Math.abs(x-b.x)<(b.rect.rw+ray) && Math.abs(y-b.y)<(b.rect.rh+ray) ){
						hit(b);
					}
				}else{
					if( getDist(b) < ray+b.ray ){
						hit(b)
					}
						
				}
			}			
		}else{
			
			var h = Cs.game.hero
			if(h.invincibleTimer!=null)return;
			var dist = getDist(h)
			if( dist < Cs.game.hero.ray+ray ){
				Cs.game.hero.hit(this);
				kill();
			}
	
		}
	}
	
	function hit(b){
		onHit(b);
		var hp = b.hp;
		b.hit(this)
		
		if(!flInvincible){
			if(flPierce && hp<damage){
				damage-=hp
			}else{
				var mc = Cs.game.dm.attach("partImpact",Game.DP_PARTS)
				mc._x = x;
				mc._y = y;
				mc._xscale = 50 + damage * 100
				mc._yscale = mc._xscale
				mc._rotation = Math.random()*360
				mc.blendMode = BlendMode.ADD
				kill();
				return;
			}
		}
	}
	
	function onHit(bad){
		
	}
		
	function setSkin(n,d){
		root = downcast(Cs.game.shots.layer[d].dm.attach("mcShot",0))
		root.gotoAndStop(string(n))
		root.obj = this;
		updatePos();
	}
	
	function orient(){
		root._rotation = Math.atan2(vy,vx)/0.0174
	}

	function kill(){
		Cs.game.shotList.remove(this)
		super.kill();
	}
	
	
	
//{
}