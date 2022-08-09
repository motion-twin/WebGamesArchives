package pix;
import Common;
import mt.bumdum.Lib;
import mt.bumdum.Phys;

class Missile extends pix.Phys {//}

	public var flHeal:Bool;
	public var flPoison:Bool;
	public var flBounce:Bool;
	public var flOrient:Bool;
	public var flHole:Bool;
	public var flImpactFocus:Bool;
	public var flTimeExplode:Bool;
	public var flWind:Bool;

	public var ray:Float;
	public var speed:Float;
	public var radiusHole:Float;
	public var radiusDamage:Float;
	public var radiusDamageBase:Float;
	public var damage:Float;
	public var eject:Float;
	public var angle:Float;
	public var vr:Float;
	public var spinMax:Float;

	public var endTimer:Float;
	public var endTimerMax:Float;
	public var timer:Int;
	public var bounceCol:Int;

	public var lineFrom:{x:Int,y:Int};
	public var mcLine:flash.MovieClip;

	public var bhl:Array<Int>;
	public var bhTimer:Float;

	//public var partDrop:{link:String,timer:Int,lim:Int,coef:Float};



	public function new(type) {
		var mc = Game.me.mdm.attach("mcShot",Game.DP_SHOTS);
		mc.gotoAndStop(type+1);
		Game.me.anims.push(this);
		super(mc);

		context = Game.me.misCol;

		// DEFAULT
		endTimerMax = 30;
		ray = 0;
		speed = 30;
		eject = 0;
		weight = 0;
		radiusHole = 10;
		radiusDamage = 10;
		radiusDamageBase = 6;
		damage = 1;


		flOrient = true;

		initMapPos(3);

		Game.me.flFreeCam = true;

		//
		//Game.me.setFocus( cast this );

	}

	public function fire(angle,power){
		if(power==null)power = Math.sqrt(vx*vx+vy*vy);
		if(angle==null)angle = Math.atan2(vy,vx);
		vx = Math.cos(angle)*power*speed;
		vy = Math.sin(angle)*power*speed;
	}

	public function update() {

		if(flWind){
			vx += Game.me.wind;
		}

		if(vr!=null){
			root._rotation += vr;
		}

		if(endTimer==null){
			fly();
			if(flOrient)orient();

			if( y>Game.me.mapHeight+30 ){
				kill();
			}else if( timer!=null ){
				timer--;

				if(timer==30)root.smc.gotoAndPlay("blink");
				if(timer==3)root.smc.gotoAndPlay("explode");

				if(timer==0){



					if(flTimeExplode){
						explode();
					}else{
						kill();
					}
				}
			}
		}else{
			endTimer --;
			if(endTimer<0){
				kill();

			}
		}


		if(lineFrom!=null){
			var dx = x - lineFrom.x;
			var dy = y - lineFrom.y;
			if(mcLine==null){
				mcLine = Game.me.mdm.attach("mcGunShot",Game.DP_BACK_PARTS);
				mcLine._x = lineFrom.x;
				mcLine._y = lineFrom.y;
			}
			mcLine._xscale = Math.sqrt(dx*dx+dy*dy);
			mcLine._rotation = Math.atan2(dy,dx)/0.0174;


		}

		updateBehviours();


	}

	override function onBounce(sx,sy){
		angle = Math.atan2(vy,vx);
		super.onBounce(sx,sy);

		if(flImpactFocus)Game.me.setFocus( cast this );
		if(flBounce){

			if( !Game.me.isGlue(x+sx,y+sy) ){
				setSpin(spinMax);
				spinMax *= colFrict;
				return;
			}else{
				gid = Cs.getDi(sx,sy);
				stick();
				return;
			}
		}
		bounceCol = context.mapBmp.getPixel32(x+sx,y+sy);
		explode();
		parc = 0;



	}

	function stick(){

		// PARTS GLUE
		var ga = getNormal();
		var vit = Math.sqrt(vx*vx+vy*vy);
		var max = Std.int( Math.min(vit,8) );
		var spm =  Math.min(vit*0.2,2) ;
		for( i in 0...max ){
			var p = getGlue(ga);
			var a = ga+(Math.random()*2-1)*1.57;
			var speed = 0.2+Math.random()*spm;
			p.vx = Math.cos(a)*speed;
			p.vy = Math.sin(a)*speed;
			p.weight *= 1.2;
			p.timer += 3;
		}

		//
		vx = 0;
		vy = 0;
		weight = 0;
		vr = 0;
		parc = 0;

	}

	/*
	function onEnterPix(){
		for( c in Game.me.cosmos ){
			var dx = (c.x+c.head.x) - x;
			var dy = (c.y+c.head.y) - y;
			var lim = c.ray+ray;
			if( Math.abs(dx)<lim && Math.abs(dy)<lim){
				trace("!");
				if( Math.sqrt(dx*dx+dy*dy) < lim){
					trace("bam!");
					explode();
					parc = 0;
				}

			}
		}
	}
	*/

	function explode(){
		// HOLE
		var list = Game.me.rayDamage( x , y, damage, radiusDamage, radiusDamageBase, eject, flHeal );
		var flFx= true;
		if(flPoison)for( c in list )c.setPoison(true);

		for( n in bhl ){
			switch(n){
				case 2: // SPHERE GROW
					var max = 60;
					if(MMApi.isReconnecting())max = 0;
					for( n in 0...max ){
						var a = (n/max)*6.28;
						//var ray = (max*2)%radiusDamage;
						var ray = Math.random()*radiusDamage;
						var p = new Phys(Game.me.mdm.attach("partHeal",Game.DP_PARTS));
						p.x = x+Math.cos(a)*ray;
						p.y = y+Math.sin(a)*ray;
						p.weight = 0.01 + Math.random()*0.05;
						p.root.gotoAndPlay(Std.random(p.root._totalframes)+1);
						p.timer = 10+Math.random()*10;
						p.fadeType = 0;
						p.updatePos();
						//trace("p");
					}
					Game.me.fxSphere(x,y,radiusDamage*2,"mcSphereGrow");

				case 3: // GAZ
					var max = 15;
					if(MMApi.isReconnecting())max = 0;
					for( n in 0...max ){
						var a = (n/max)*6.28;
						var coef =  (1-((n+Math.random())*6/max)%1);
						var ray = coef*(radiusDamage-30);
						var sp = coef*5;
						var ca = Math.cos(a);
						var sa = Math.sin(a);
						var p = new Phys(Game.me.mdm.attach("partGaz",Game.DP_PARTS));
						p.x = x+ca*ray;
						p.y = y+sa*ray;
						p.vx = ca*sp;
						p.vy = sa*sp;
						p.vr = (Math.random()*2-1)*2;
						p.weight = 0.01 + Math.random()*0.05;
						//p.root.gotoAndPlay(Std.int((1-coef)*10)+1);

						p.setScale(80+(1-coef)*40);
						p.frict = 0.9;
						//p.root.blendMode = ";
						p.fadeType = 0;

						p.sleep  = coef*12 - 3;
						p.root._visible = false;
						p.root.stop();

						//Filt.blur(p.root,4,4);

						p.updatePos();
					}

				 case 4: // MINI-IMPACT FX


					// MINI IMPACT
					var mc = Game.me.mdm.attach("mcMiniImpact",Game.DP_PARTS);
					mc._x = x;
					mc._y = y;
					mc.blendMode = "add";

					// IMPACT
					var max = 15;
					var cr = 3;
					if(MMApi.isReconnecting())max = 0;
					for( n in 0...max ){
						var a = (n/max)*6.28;
						var sp = Math.random()*2;
						var ca = Math.cos(a);
						var sa = Math.sin(a);
						var p = new Phys(Game.me.mdm.attach("partPix",Game.DP_PARTS));
						p.x = x+ca*sp*cr;
						p.y = y+sa*sp*cr;
						p.vx = ca*sp;
						p.vy = sa*sp;
						p.timer = 10+Math.random()*20;
						p.weight = 0.03+Math.random()*0.03;
						p.updatePos();
						p.frict = 0.9;
						//p.setScale(200);
						Col.setColor( p.root, bounceCol);
					}
				case 5: // LASER IMPACT
					if(!MMApi.isReconnecting()){
						var mc = Game.me.mdm.attach("mcGunShot2",Game.DP_PARTS);
						mc._x = x;
						mc._y = y;
						mc._rotation = angle/0.0174;
						flFx =  false;
					}

			}
		}

		if(flHole)Game.me.makeHole(x,y,radiusHole,flFx);

		//trace("explode at "+x+";"+y);
		/*
		var brush = Game.me.dm.attach("mcHole",0);
		var m = new flash.geom.Matrix();
		var sc = radiusHole*2/100;
		m.scale(sc,sc);
		m.translate(x,y);
		Game.me.mapBmp.draw(brush,m,null,"erase");
		brush.removeMovieClip();
		*/
		// DAMAGE





		//
		remove();


	}
	public function orient(){
		angle = Math.atan2(vy,vx);
		root._rotation = angle/0.0174;

	}

	// FX
	function updateBehviours(){	// FX ONLY !!
		if(MMApi.isReconnecting())return;

		for(bh in bhl){

			switch(bh){
				case 0:
					/*
					var a = angle+3.14;
					var dist = ray+6;
					if(bhTimer==null)bhTimer=0;
					if(bhTimer++==1){
						bhTimer = 0;
						var p = new Phys(Game.me.mdm.attach("partSmoke2",Game.DP_BACK));
						p.x = x + Math.cos(a)*dist ;
						p.y = y + Math.sin(a)*dist ;
						p.vr = (Math.random()*2-1)*1.5;
						p.root._rotation = Std.random(360);
						p.setScale(100);
						p.updatePos();
						p.root.blendMode = "add";
						p.fadeLimit = 20;
						p.timer = 20;
						p.root._rotation = Std.random(360);
					}
					*/
					var p  = getPart("partSmoke2", 1 ,ray+6);
					if(p!=null){
						p.vr = (Math.random()*2-1)*1.5;
						p.updatePos();
						p.root.blendMode = "add";
						p.fadeLimit = 20;
						p.timer = 20;
						p.root._rotation = Std.random(360);
					}

				case 1:
					var p  = getPart("partBurn", 1 ,ray+6);
					if(p!=null){
						p.vr = (Math.random()*2-1)*1.5;
						p.updatePos();
						p.timer = 20;
						p.root._rotation = Std.random(360);
					}


				case 6:
					var mc = Game.me.mdm.attach("queueGrenade",Game.DP_BACK_PARTS);
					mc._x = x;
					mc._y = y;

			}

		}


	}
	public function getPart(link,?freq,?dist:Float){
			var a = angle+3.14;
			if(freq==null)freq = 1;
			if(dist==null)dist = 0;
			if(bhTimer==null)bhTimer=0;
			if(bhTimer++==freq){
				bhTimer = 0;
				var p = new Phys(Game.me.mdm.attach(link,Game.DP_BACK));
				p.x = x + Math.cos(a)*dist ;
				p.y = y + Math.sin(a)*dist ;
				return p;
			}
			return null;
	}

	public function setSpin(n){
		spinMax = n;
		vr = (Math.random()*2-1)*n;
	}

	//
	function remove(){
		endTimer = endTimerMax;
		bhl = [];
		root.removeMovieClip();
		mapPoint.removeMovieClip();
		mapPoint = null;
	}
	override public function kill(){
		Game.me.flFreeCam = false;
		Game.me.anims.remove(this);
		super.kill();
	}


//{
}











