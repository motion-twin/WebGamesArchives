package lander;
import mt.bumdum.Phys;
import mt.bumdum.Lib;

private enum Step {
	Fly;
	Land;
}

private typedef Pod = { >flash.MovieClip, p:Phys, sens:Int };

class Pad extends PadSkin{//}

	public static var HR = 8;

	public static var MARGIN = 12;
	public static var WEIGHT = 0.05;

	//var hero:lander.Hero;

	var controlType:Int;
	var drones:Int;


	var angle:Float;
	var acc:Float;
	var step:Step;

	var fuel:Float;

	var droneTimer:Float;
	var landTimer:Float;

	var landAngleMax:Float;
	var landPodLength:Float;
	var droneActionRay:Float;
	var fuelConsume:Float;

	var pods:Array<Pod>;
	public var minList:Array<lander.Mineral>;


	public function new(){
		var mc = lander.Game.me.bdm.attach("mcPad",lander.Game.DP_PAD);

		super(mc);

		setRay(Cs.pi.getRay());
		setType(0);


		weight = WEIGHT*lander.Game.me.pl.g;
		fuel = 100;

		//acc = 0.25;
		//acc = 0.15;
		//acc = 0.15;


		//landSpeedMax = 3;
		landAngleMax = 0.5;
		//if( Cs.pi.shopItems[ShopInfo.LANDER_REACTOR_2] == 1 ) acc += 0.3;


		landPodLength = 0;
		if( Cs.pi.shopItems[ShopInfo.PODS] == 1 ) landPodLength = 14;
		if( Cs.pi.shopItems[ShopInfo.PODS_EXTEND_0] == 1 ) landPodLength += 10;
		if( Cs.pi.shopItems[ShopInfo.PODS_EXTEND_1] == 1 ) landPodLength += 10;
		if( Cs.pi.shopItems[ShopInfo.PODS_EXTEND_2] == 1 ) landPodLength += 10;

		acc = 0.15;
		if( Cs.pi.shopItems[ShopInfo.LANDER_REACTOR_0] == 1 ) acc += 0.15;
		if( Cs.pi.shopItems[ShopInfo.LANDER_REACTOR_1] == 1 ) acc += 0.2;
		if( Cs.pi.shopItems[ShopInfo.LANDER_REACTOR_2] == 1 ) acc += 0.3;



		droneActionRay = 100;
		fuelConsume = 0.3;

		drones = Cs.pi.drone;



		angle = -1.57;
		step = Fly;


		setReactor(true);
		mcReactor.smc._visible = false;


	}

	override public function update(){
		super.update();
		switch(step){
			case Fly:	updateFly();
			case Land:	updateLanding();
		}

		checkCols();


	}
	function checkCols(){

		var rh = 5;
		var sx = x-Math.cos(angle)*rh;
		var sy = y-Math.sin(angle)*rh;

		var a = angle+1.57;
		var ca = Math.cos(a);
		var sa = Math.sin(a);

		var max = 8;
		var mr = ray-7;
		for( i in 0...max ){
			var c = (i/(max-1))*2-1;
			var px = Std.int(sx+ca*c*mr);
			var py = Std.int(sy+sa*c*mr);
			if( !lander.Game.me.isFree( px, py, lander.Game.me.bmpCol ) ){
				explode(null);
				return;
			}
			//lander.Game.me.markPixel(px,py);
		}
	}

	// FLY
	function takeOff(){
		step = Fly;
		weight = WEIGHT*lander.Game.me.pl.g;
		vx = 0 ;
		vy = -2*lander.Game.me.pl.g;
		removePods();


		navi.Map.me.removeMenu(7);

	}
	function updateFly(){



		control();
		checkLanding();

		var rec = 1;
		if( x<0 ){
			vx *= 0.6;
			vx += rec;
		}
		if( x>lander.Game.WIDTH ){
			vx *= 0.6;
			vx -= rec;
		}
		if( y > lander.Game.HEIGHT+30 ){
			explode(null);
		}

	}

	// CONTROL
	function control(){

		// ROTATION
		var ta = getMouseAngle();
		if( y < 150 )ta = -1.57;


		var da = Num.hMod( ta-angle, 3.14 );
		angle += da*0.1;
		skin._rotation = angle/0.0174 +90;

		// THRUST
		var flThrust = lander.Game.me.flPress && fuel>0;
		if( flThrust )thrust();
		mcReactor.smc._visible = flThrust;

		//
		//if( lander.Game.me )
	}

	function thrust(){


		var ca = Math.cos(angle);
		var sa = Math.sin(angle);
		vx += ca*acc;
		vy += sa*acc;

		incFuel(-fuelConsume*mt.Timer.tmod);

		// PARTS
		var ec = 16;
		var sp = 2+Math.random()*8;
		var p = new Phys( lander.Game.me.bdm.attach("partReactorSpark",lander.Game.DP_UNDERPARTS) );
		var a = Math.random()*6.28;
		var d = 2+Math.random()*16;
		p.x = (x-ca*ec) - Math.cos(a)*d;
		p.y = (y-sa*ec) - Math.sin(a)*d;
		p.vx = vx-ca*sp ;
		p.vy = vy-sa*sp;
		p.root.smc._x = d;
		p.root._rotation = a/0.0174;
		p.vr = (Math.random()*2-1)*20;
		p.fr = 0.95;
		p.fadeType = 0;
		p.timer = 10+Math.random()*10;
		p.setScale(50+Math.random()*100);

		Filt.glow(p.root,16,6,0xFFFF44);
		p.root.blendMode = "add";


	}
	function incFuel(inc){
		fuel = Num.mm(0,fuel+inc,100);
		lander.Game.me.mcInter.fuel.smc._yscale = fuel;
	}

	// LANDING
	function checkLanding(){
		if( landPodLength==0 )return;

		var da = Num.hMod(angle+1.57,3.14);
		if( da > landAngleMax )return;
		//if( Math.sqrt(vx*vx+vy*vy) > landSpeedMax  )return;

		var r = ray-MARGIN;
		var a = [];

		var bx = x - Math.cos(angle)*HR;
		var by = y - Math.sin(angle)*HR;

		for( i in 0...2 ){
			var sens = i*2-1;
			var an = angle-1.57*sens;
			var px = bx + Math.cos(an)*r;
			var py = by + Math.sin(an)*r;
			a.push([px,py]);
		}

		var ga = [];
		for( p in a ){
			var n = getPodPos(p);
			if(n==null)return;
			ga.push( [p[0],p[1]+n] );
		}

		// INIT LANDING
		pods = [];
		var sens = -1;
		for( id in 0...2 ){
			var mc:Pod = cast lander.Game.me.bdm.attach( "mcLandPod", lander.Game.DP_PAD);
			mc._x = ga[id][0];
			mc._y = ga[id][1];
			mc.p = new Phys( lander.Game.me.dm.empty(lander.Game.DP_PAD) );
			mc.p.x = a[id][0];
			mc.p.y = a[id][1];
			mc.p.vx = vx;
			mc.p.vy = vy;
			mc.p.frict = 0.95;
			mc.sens = sens;
			pods.push(mc);
			Filt.glow(mc,2,4,0xA8780B);
			//
			sens += 2;
		}
		lander.Game.me.bdm.over(root);
		initLanding();





	}
	function initLanding(){
		step = Land;
		weight = 0;
		mcReactor.smc._visible = false;
		landTimer = 10;

		initLandingControl();

		// BUILD MINERAL LIST
		minList = [];
		for( min in lander.Game.me.minerals ){
			var dx = Math.max( Math.abs(x-min.root._x)-ray,0 );
			var dy = y-min.root._y;
			if( Math.sqrt(dx*dx+dy*dy) < droneActionRay ){
				minList.push(min);
			}
		}

	}

	function initLandingControl(){
		lander.Game.me.focus = this;
		controlType = 0;

		if( lander.Game.me.pl.type==1 || Cs.pi.gotItem(MissionInfo.COMBINAISON) ){
			navi.Map.me.newMenu(7,dropHero);
		}
	}

	function updateLanding(){
		updatePods();

		// DRONES
		if( minList.length>0 && drones>0 ){
			if(droneTimer==null)droneTimer = 0;
			droneTimer -= mt.Timer.tmod;
			if(droneTimer<0){
				droneTimer = 10;
				drones--;
				var drone = new lander.Drone();
				drone.initModeSeeker();
			}
		}

		checkTakeOff();


	}
	function checkTakeOff(){
		// CHECK TAKEOF

		if( controlType!=0 )return;

		if( landTimer == null ){

			var da = Num.hMod( getMouseAngle()+1.57, 3.14 );
			if(Math.abs(da)<0.77  ){
				if( lander.Game.me.flClick )takeOff();
			}else{

			}


		}else{
			landTimer -= mt.Timer.tmod;
			if( landTimer < 0 ) landTimer = null;
		}
	}

	function dropHero(){
		controlType = 1;
		var h = lander.Game.me.newHero();
		h.x = Std.int(x);
		h.y = Std.int(y);

		navi.Map.me.removeMenu(7);


	}

	// PODS
	function getPodPos( p ){
		var n = 1;
		while(true){
			var px = Std.int(p[0]);
			var py = Std.int(p[1]+n);
			if( !lander.Game.me.isLandingFree(px,py) ){
				return n;
			};
			if(n++>=landPodLength)return null;

		}
		return null;
	}
	function removePods(){
		while( pods.length>0 )pods.pop().removeMovieClip();
	}
	function updatePods(){

		// STRING
		for( mc in pods ){
			var tx = mc._x;
			var ty = mc._y-(landPodLength+3);

			var dx = tx-mc.p.x;
			var dy = ty-mc.p.y;

			var c = 0.1;
			mc.p.vx += dx*c;
			mc.p.vy += dy*c;
		}

		// CONTRAINTE
		var dx = pods[0].p.x - pods[1].p.x;
		var dy = pods[0].p.y - pods[1].p.y;

		var dist = Math.sqrt(dx*dx+dy*dy);
		var a = Math.atan2(dy,dx);
		var ca = Math.cos(a);
		var sa = Math.sin(a);
		var dd = (dist-(ray-MARGIN)*2)*0.5;
		for( id in 0...2 ){
			var sens = id*2-1;
			var mc = pods[id];
			mc.p.x += ca*dd*sens;
			mc.p.y += sa*dd*sens;
		}

		// POSITION
		angle = a -1.57;
		root._rotation = angle/0.0174 +90;

		x = (pods[0].p.x+pods[1].p.x)*0.5 + Math.cos(angle)*HR ;
		y = (pods[0].p.y+pods[1].p.y)*0.5 + Math.sin(angle)*HR ;
		updatePos();

		// FOOT DRAW
		var h = landPodLength+10;
		for( mc in pods ){
			mc.clear();
			//mc.lineStyle(3,0xF9DB8B,100);
			mc.lineStyle(3,0xE9B849,100);
			var dx = mc.p.x - mc._x;
			var dy = mc.p.y - mc._y;
			var d = Math.sqrt(dx*dx+dy*dy)*0.5;
			var leg = h*0.5;
			var ray = Math.sqrt(leg*leg-d*d);

			if(!(ray>0))ray = 0;

			var a = Math.atan2(dy,dx)+1.57;
			var cx = dx*0.5 - Math.cos(a)*ray*mc.sens;
			var cy = dy*0.5 - Math.sin(a)*ray*mc.sens;

			mc.lineTo(cx,cy);
			mc.lineTo(dx,dy);

			mc.smc._x = cx;
			mc.smc._y = cy;


		}

	}

	// RECEIVE
	public function receiveDrone(drone:lander.Drone){

		if( drone.minVal!=null ){
			showMinerai(drone.minVal.get());
			lander.Game.me.incMinerai(drone.minVal);
		}

		droneTimer = 10;
		drones++;
		for( mc in pods ) mc.p.vy = 1.5;
	}
	public function receiveHero(){
		var hero = lander.Game.me.hero;

		initLandingControl();

		if( hero.min.get()>0 ){
			showMinerai(hero.min.get());
			lander.Game.me.incMinerai( hero.min );
		}
		for( mc in pods ){
			mc.p.vx = hero.vx*0.33;
			mc.p.vy = hero.vy*0.33;
		}

		hero.kill();



	}
	function showMinerai(n){
		var p = new Phys( lander.Game.me.bdm.attach("mcMinCounter", lander.Game.DP_INTER) );
		p.x = x;
		p.y = y-40;
		p.timer = 15;
		p.fadeLimit = 6;
		p.weight = -0.1;
		Filt.glow(p.root,2,4,0);
		var field:flash.TextField = (cast p.root).field;
		field.text = Std.string(n);

		p.x += (16+field.textWidth)*0.5;

	}

	//TOOLS
	function getMouseAngle(){
		var dx = lander.Game.me.base._xmouse - x;
		var dy = lander.Game.me.base._ymouse - y;
		return Math.atan2(dy,dx);
	}

	// KILL
	override public function explode(dm){
		if(dm==null)dm = lander.Game.me.bdm.empty(lander.Game.DP_UNDERPARTS);
		super.explode(dm);
		lander.Game.me.initEnding(false);
	}
	override public function kill(){
		removePods();
		navi.Map.me.removeMenu(7);

		super.kill();
	}


//{
}












