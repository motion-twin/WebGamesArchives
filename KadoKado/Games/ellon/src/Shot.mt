class Shot extends Phys{//}

	var bList:Array<int>;
	var op:{x:float,y:float}
	var flGood:bool;
	var flPierce:bool;
	var flInvincible:bool;

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

	function new(mc){
		super(Cs.game.mdm.attach("mcShot",Game.DP_SHOT));
		root.stop();
		flPierce = false;
		flInvincible = false;
		ray = 4
		damage = 0
		bList = new Array();
	}


	function update(){
		super.update();
		updateBehaviour();
		checkCols();

		//
		if(timer!=null){
			timer-=Timer.tmod;
			if(timer<10){
				root._alpha =10*timer;
				if(timer<0){
					kill();
				}
			}
		}
		// REBOND EXCEPTION
		if( ray>15 && y>Cs.GL-ray ){
			vy*=-1
			y = Cs.GL-ray
		}

	}

	function updateBehaviour(){
		for( var n=0; n<bList.length; n++ ){
			var id = bList[n]

			switch(id){
				case 0: // BOMB
					root._rotation += vr*Timer.tmod;
					if(y>Cs.GL){
						onHit(null);
						kill();
					}

					break;
				case 1: // PAILLETTES

					for( var i=0; i<2; i++){
						var p = new Part(Cs.game.mdm.attach("partBurn",Game.DP_PARTS))
						var a = Math.random()*6.28
						var d  = Math.random()*ray
						p.x = x + Math.cos(a)*d
						p.y = y + Math.sin(a)*d
						p.frict = 0.92
						p.vx = vx*(0.5*Math.random()*0.3);
						p.vy = vy*(0.5*Math.random()*0.3);
						p.timer = 10+Math.random()*10
						p.scale = 50+Math.random()*100
						p.root._xscale = p.scale;
						p.root._yscale = p.scale;
					}

					break;

				case 2: // QUEUE
					if(op!=null){
						var mc = Cs.game.mdm.attach("partQueue",Game.DP_PARTS)
						mc._rotation = getAng(op)/0.0174
						mc._xscale = getDist(op)
						mc._x = x;
						mc._y = y;
					}
					op={x:x,y:y}

					break;

				case 3: // HOMING
					if( trg.flDeath || trg==null )getNewBadTrg();
					if(trg==null)break;
					var da = getAng(trg) - a
					while(da>3.14)da-=6.28;
					while(da<-3.14)da+=6.28;
					a += Cs.mm(-va,da*ca,va)*Timer.tmod;
					updateVit()
					if( x > Cs.GL-ray ){
						x = Cs.GL-ray
						vx *=-1
					}

					break
				case 4: // ONDULE
					decal = (decal+43*Timer.tmod)%628
					a+=Math.cos(decal/100)*0.2
					updateVit()
					break;

			}
		}
	}

	function updateVit(){
		vx = Math.cos(a)*speed;
		vy = Math.sin(a)*speed;
		orient();
	}

	function getNewBadTrg(){
		var list = Cs.game.badsList
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
							//Log.trace("hit("+hp+") reste("+damage+")")
						}else{
							kill();
							return;
						}
					}

				}
			}
		}else{
			var h = Cs.game.hero
			var dist = getDist(h)
			if(h.flShield){
				var max = ray+30
				if(dist<max){
					var d = (max-dist)
					var a = getAng(h)
					x -= Math.cos(a)*d
					y -= Math.sin(a)*d
				}

			}else{

				if( dist < Cs.game.hero.ray+ray ){
					Cs.game.hero.hit(this);
					kill();
				}
			}
		}


		// BOUNDS
		var m = 30+ray
		if(x<-m || x>Cs.mcw+m || y<-m || y>Cs.GL+m){
			this.kill();
		}




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
					var p = new Part(Cs.game.mdm.attach("partBombExplosion",Game.DP_PARTS))
					p.x = x
					p.y = y
					p.vx = -Cs.SCROLL_SPEED
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
		super.kill();
	}



//{
}