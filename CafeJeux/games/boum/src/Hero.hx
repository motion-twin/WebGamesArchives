import mt.bumdum.Lib;
import mt.bumdum.Sprite;
import Msg;

enum Step {
	Ground;
	Fly;
	Shoot;
}


class Hero extends Pix{//}

	static var CLIMB = 6;
	static var FALL = 5;
	
	var step:Step;
	
	//var id:Int;
	var flPlay:Bool;
	var weight:Float;
	var waitTimer:Int;
	var ma:Int;
	var sens:Int;
	var wpid:Int;
	
	var movePoints:Int;
	
	public var log:Array<Array<Int>>;
	var action:Array<Int>;
	var weapons:Array<Array<Int>>;
	var weaponIcons:Array<flash.MovieClip>;
	var wp:flash.MovieClip;
	//
	var inter:{>flash.MovieClip, bar:flash.MovieClip, dm:mt.DepthManager};
	
	var mcCross:flash.MovieClip;
	
	public function new(mc){
		super(mc);
		step = Ground;
		weight = 0.3;
		ma = 0;
		
		weapons =  [ [0,-1], [1,12], [2,0] ];
		
	}
	
	// INIT
	public function init(n){
		id = n;
		var p = Cs.game.map.startPos[id];
		px = Std.int(p[0]);
		py = Std.int(p[1]);
		drop();
		updatePos();
	}
	function initStep(s){
		step = s;
		switch(step){
			case Ground:
			case Fly:
			case Shoot:
		}
	}

	// UPDATE
	public function update(){
		//MMApi.print(log);
		//MMApi.print("joueur["+id+"] x:"+x+" y:"+y );
		super.update();
		switch(step){
			case Ground:
			case Fly:
				vy += weight;
				fly2();
			case Shoot:
				if(Cs.game.shotList.length==0){
					waitTimer = 20;
					step = Ground;
				}
		}	
		
	}
	
	// CONTROL
	public function control(){
		
		if( step ==  Ground ){
			
			if(movePoints==0){
				endTurn();
				return;
			}
			
			
			if(flash.Key.isDown(flash.Key.LEFT)){
				walk(-1);
			}else if(flash.Key.isDown(flash.Key.RIGHT)){
				walk(1);
			}else if(flash.Key.isDown(flash.Key.UP)){
				modAngle(-1);
			}else if(flash.Key.isDown(flash.Key.DOWN)){
				modAngle(1);
			}else if(flash.Key.isDown(flash.Key.SPACE)){
				act();
			}
			
		}	
	}
	function onBounce(a:Float,n:Float){
		var da = Num.hMod(1.57-n,3.14);
		if( Math.abs(da) < 1 ){
			parc = 0;
			vx = 0;
			vy = 0;
			step = Ground;
		}
	}
	function walk(sens){
		removeCross();
		
		px += sens;
		incMovePoints(-1);
		
		var flValid = true;
		
		if( !Cs.game.map.isFree(px,py) ){
			flValid = false;
			for( by in 1...CLIMB ){
				if( Cs.game.map.isFree(px,py-by) ){
					py -= by;
					flValid = true;
					break;
				}
			}
		}else{
			if( Cs.game.map.isFree(px,py+1) ){
				var flFall = true;
				for( by in 1...FALL ){
					if( !Cs.game.map.isFree(px,py+by+1) ){
						py += by;
						flFall  = false;
						break;
					}
				}
				if(flFall){
					step = Fly;
				}
			}
		}

		if(flValid){
			if(Cs.game.step!=3){
				var a = log[log.length-1];
				if( a[0]-1 != sens ){
					a = [sens+1,0];
					log.push(a);
				}
				a[1]++;
			}
			setSens(sens);
			
		}else{
			incMovePoints(1);
			px -= sens;
		}
		
		updatePos();
	}
	function modAngle(sens){
		var lim = 150;
		ma = Std.int(Num.mm(-lim,ma+10*sens,lim));
		updateCross();
		
		if(Cs.game.step!=3){
			var a = log[log.length-1];
			if( a[0] != 1 ){
				a = [1,0];
				log.push(a);
			}
			a[1] = ma;
		}
	}
	function act(){
		switch(wpid){
			case 0:
				jump();
			default:
				shoot();
		}
		
	}
	
	//
	function jump(){
		removeCross();
		var a = getAngle();
		vx = Math.cos(a)*7;
		vy = Math.sin(a)*7;
		step = Fly;
		incMovePoints(-20);
		if(Cs.game.step!=3){
			log.push([3]);
		}
		trace("joueur["+id+"] saute en "+a);
	}
	function shoot(){
		var wp = weapons[wpid];
		if( wp[1] == 0 )return;
		if( wp[1] > 0 )wp[1]--;
		switch(wpid){
			case 1:
				var shot:Shot = newShot();
				shot.setSpeed(14);
				shot.weight = 0.5;
				shot.shockId = 0;
				shot.rayExplosion = 40;
				Cs.game.map.focus = cast shot;
		}
		step = Shoot;
	}
	function newShot(){
		var shot = new Shot();
		shot.flOrient = true;
		shot.setPos(Std.int(x), Std.int(y-5));
		shot.angle = getAngle();
		shot.updatePos();
		
		return shot;
	}
	
	// CROSS
	function getAngle(){
		return (1.57-sens*1.57) + ma*0.01*sens;	
	}
	function updateCross(){
		if(mcCross==null)mcCross = Cs.game.dm.attach( "mcCross", Game.DP_CROSS );
		var ray = 30;
		var a = getAngle();
		mcCross._x = x + Math.cos(a)*ray;
		mcCross._y = y + Math.sin(a)*ray;
	}
	function removeCross(){
		if(mcCross!=null){
			mcCross.removeMovieClip();
			mcCross = null;
		}
	}
	
	// SENS
	function setSens(n){
		sens = n;
		root._xscale = n*100;
	}
	
	// PLAYER
	public function playLog(){
		//MMApi.print("action"+log.length);
		//MMApi.print(action);
		if(action==null){
			if(log.length==0){
				Cs.game.initPlay();
			}else{
				action = log.shift();
			}
		}else{
			var n = action[0];
			switch(n){
				case 0:
					playWalk();
				case 1:
					playAngle();
				case 2:
					playWalk();
				case 3:
					playJump();
			}
		}		
	}
	function playWalk(){
		walk(action[0]-1);
		action[1]--;
		if(action[1]==0)action = null;	
	}
	function playAngle(){
		if(action.length==2){
			var max = 20;
			var ta = action[1];
			var da = Num.hMod(ma-ta,314);
			for( i in 0...max+1 ){
				var c = i/max;
				action.push( Std.int(ta+c*da) ) ;
			}
		}else{
			ma = action.pop();
			modAngle(0);
			if(action.length==2)action = null;
		}
	}
	function playJump(){
		if(action[1]==null){
			jump();
			action[1] = 1;
		}else{
			if(step==Ground)action = null;
		}
			
	}
	
	
	// TURN
	public function initTurn(){
		initInterface();
		log = [];
		movePoints = 100;
		incMovePoints(0);
		Cs.game.map.focus = cast this;
		selectWeapon(0);
	}
	function endTurn(){
		MMApi.sendMessage(SendTurn(id,log));
		Cs.game.step = 1;
		removeInterface();
	}
	
	function incMovePoints(inc){
		movePoints = Std.int(Math.max(0,movePoints+inc));
		inter.bar._xscale = movePoints;
	}
	
	// INTERFACE
	public function initInterface(){
		inter = cast Cs.game.mdm.attach("mcInterface",Game.DP_INTERFACE);
		inter._y = Cs.mch;
		inter.dm = new mt.DepthManager(inter);
		updateWeapon();
		

	}
	function updateWeapon(){
		inter.dm.empty(0);
		weaponIcons = [];
		for( i in 0...weapons.length ){
			var w = weapons[i];
			var icon = inter.dm.attach("mcWeaponIcon",0);
			
			icon._x = 109+14*i;
			icon._y = -15;
			icon.gotoAndStop(w[i]+1);
			if( w[1]==0 ){
				icon._alpha = 20;
			}else{
				var me = this;
				var n = i;
				icon.onPress = function(){ me.selectWeapon(n);};
			};
			weaponIcons.push(icon);

		}
	}
	function selectWeapon(id){
		
		weaponIcons[wpid].filters = [];
		wpid = id;
		var mc = weaponIcons[id];
		mc.filters = [];
		//*
		Filt.glow(mc,10,1,0xFFFFFF);
		/*/
		mc.filters = [];
		var fl = new flash.filters.GlowFilter();
		fl.blurX = 10;
		fl.blurY = 10;
		fl.strength = 5;
		fl.color = 0xFFFFFF;
		var a  = mc.filters ;
		a.push(fl);
		mc.filters = a;		
		//*/

		
	}
	
	public function removeInterface(){
		inter.removeMovieClip();
	}
	
	
//{	
}


