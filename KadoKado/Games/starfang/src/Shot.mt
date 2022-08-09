class Shot extends Phys{//}

	var bList:Array<int>;
	var op:{x:float,y:float}
	var flGood:bool;
	var flPierce:bool;
	var flInvincible:bool;
	var flWarp:bool;

	var ft:int;

	var damage:float;
	var timer:float;
	var a:float;
	var ray:float;
	var decal:float;
	var vr:float;
	var va:float;
	var ca:float;
	var speed:float;


	var trg:{x:float,y:float,flDeath:bool};

	var thruster:{vx:float,vy:float,sleep:float}
	var queue:String;

	function new(mc){
		super(mc)
		root.stop();
		flPierce = false;
		flInvincible = false;
		ray = 4
		damage = 0
		ft=0;
		Cs.game.shotList.push(this)
		bList = new Array();
	}

	function update(){
		super.update();
		if(flWarp)checkWarp();
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
							fxOnde(ray*2+40);
							fxExplode(ray*2+20);
							kill();
							break;
						case 2:
							root.sub.gotoAndPlay("death");

							break;
						default:
							kill();
							break;

					}

				}
			}
		}
		checkCols();
		updateBehaviour();
		if(isOut(100))kill();


		// Cs.game.plasmaDraw(root,0)

		/*
		updateBehaviour();


		*/
	}

	function updatePos(){
		super.updatePos();
		op={x:x,y:y}
	}

	function updateBehaviour(){
		for( var n=0; n<bList.length; n++ ){
			var id = bList[n]

			switch(id){
				case 0: // BOMB
					root._rotation += vr*Timer.tmod;
					break;

				case 3: // HOMING
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
					a+=Math.cos(decal/100)*0.2
					updateVit()
					break;

				case 5: // SWARM
					if( Math.sqrt(vx*vx+vy*vy)<3 || Math.random()/Timer.tmod < 0.1 ){
						a = Std.random(4)*1.57
						vx = Math.cos(a)*speed;
						vy = Math.sin(a)*speed;
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

			var mc = Cs.game.dm.attach("queueRocket",Game.DP_PARTS)
			mc._rotation = 180+getAng(op)/0.0174
			mc._xscale = getDist(op)
			mc._x = x;
			mc._y = y;

			op={x:x,y:y}
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
				if( getDist(b) < ray+b.ray ){
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

							kill();
							return;
						}
					}

				}
			}
		}else{
			var h = Cs.game.hero
			var dist = getDist(h)


			if( dist < Cs.game.hero.ray+ray ){
				Cs.game.hero.hit(this);
				kill();
			}

		}


		// BOUNDS
		if(isOut(ray))this.kill();





	}

	function onHit(bad){
		for( var n=0; n<bList.length; n++ ){
			var id = bList[n]
			switch(id){
				case 0: //BOMB
					var list = Cs.game.badsList
					for( var i=0; i<list.length; i++){
						var b = list[i]
						if(b!=bad){
							if(getDist(b)<b.ray+ray+36){
								b.hit(this);
							}
						}
					}
					var p = new Part(Cs.game.dm.attach("partBombExplosion",Game.DP_PARTS))
					p.x = x
					p.y = y
					p.frict = null
					p.updatePos();
					break;
			}
		}
	}

	function setSkin(n){
		root.gotoAndStop(string(n))
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