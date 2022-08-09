import Data;
import Game;
import mt.bumdum.Lib;

enum FighterStep {
	Wait;
	Lock;
	Dodge;
	Hurt;
}


class Fighter extends Phys {//}

	public var flAnim:Bool;
	public var flDeath:Bool;
	public var flRecal:Bool;
	public var flInter:Bool;

	public var stance:String;

	public var id:Int;
	public var team:Int;
	public var side:Int;
	public var hitFx:Int;

	public var bx:Float;
	public var by:Float;

	public var wp:_Weapons;

	public var loaded:Int;
	public var height:Int;
	public var damage:Int;
	var nextAnim:String;
	public var skin:String;

	public var stunCount:Float;
	public var step:FighterStep;

	public var ig:InterGlad;

	public var status:Array<Bool>;

	public var gladiator:Gladiator;
	public var follower:_Followers;

	public var dm:mt.DepthManager;
	public var box:{>flash.MovieClip,_init:String->Int->Void};

	public function new(id,team,?skin,inter=true) {
		
		Game.me.fighters.push(this);
		var mc = Game.me.dm.empty(Game.DP_FIGHTERS);
		dm = new mt.DepthManager(mc);
		box = cast dm.empty(3);
		flInter = inter;

		super(mc);

		this.skin = skin;
		//
		flRecal = true;
		stance = "normal";
		status = [];

		//
		weight = 1;
		height = 60;
		this.id = id;
		setTeam(team);
		flAnim = false;
		damage = 0;
		step = Wait;
		Filt.glow(root,2,2,0);

		//box = dm.attach("mcFighter",3);

		var mcl = new flash.MovieClipLoader();
		mcl.onLoadComplete = skinLoaded;
		mcl.onLoadInit = skinLoaded;
		mcl.onLoadError = function(mc,str) haxe.Log.trace("File not found",null);
		loaded = 0;
		mcl.loadClip( Game.me.data._mini, box );
		//
		root._visible = false;

	}

	public function setTeam(t){
		team = t;
		side = team*2-1;
	}

	function init(){
		root._visible = true;
		setWeapon(gladiator.defaultWeapon);
		playAnim(stance);
		initSkin();
	}
	function skinLoaded(mc){
		loaded++;
		if(loaded==2)init();
	}

	// UPDATE
	override function update() {


		super.update();

		switch(step){
			case Lock:
			case Dodge:

				vx *= Math.pow(0.85,mt.Timer.tmod);
				if( z==0 ){
					weight = 0;
					z = 0;
					vz = 0;
					vx = 0;
					backToNormal("land");
				}

			case Hurt:

				stunCount *=-0.75;
				box._x = stunCount;
				if(Math.abs(stunCount)<0.25){
					friction = 1;
					stunCount = null;
					vx = 0;
					backToNormal();
				}

			case Wait:

		}


		if(nextAnim!=null){
			box.smc.gotoAndStop(nextAnim);
			box.smc.smc.gotoAndPlay(1);
			nextAnim = null;
			paint();
		}


		// BRUTE
		if(status[0]){
			var p = new part.Shade(this,0xFF0000,0x0000FF);
		}

		// RECAL
		if(flRecal){
			if(x+ray>Cs.mcw)	x = Cs.mcw-ray;
			if(x-ray<0)		x = ray;
		}

	}

	//
	public function lock(){
		step = Lock;
	}
	public function backToNormal(?anim){
		flAnim = false;
		if(flDeath)return;
		if(anim==null)anim = stance;
		playAnim(anim);
		step = null;
	}
	public function setSens(sens){
		box._xscale = -sens*side*100;
	}

	// SKIN
	public function setGladiator(gl){
		ray = 20;
		gladiator = gl;
		stance = "normal";
		if(gladiator.stanceId!=null)stance+=""+gladiator.stanceId;

		// ARMOR
		var a = skin.split(";");
		a[1] = Std.string(gladiator.armorLevel);
		skin = a.join(";");

	}
	public function setSkin(n){
		ray = 20;
		initSkin();

	}
	public function initSkin(){
		
		box._xscale = -side*100;

		if(gladiator.fol == null){
			var fr = ( Std.parseInt(skin.split(";")[0]) )%2  + 1;
			box.gotoAndStop(fr);
		}else{
			box.gotoAndStop(Type.enumIndex(gladiator.fol)+3);
		}
		dropShadow();

		// SHIELD
		Reflect.setField(box.smc,"_sid", gladiator.shieldLevel>0 );

		//
		if( gladiator.fol == null ){
			
			ig = Game.me.addInterGlad(team);
			ig.setFighter(this);
			ig.displayWeapon();
			ig.root._visible = flInter;
			
		
		}
		paint();
	}
	public function setWeapon(wid:_Weapons){
		wp = wid;
		Reflect.setField(box,"_wid", Type.enumIndex(wid) );
	}

	public function getInfos() {
		var parts = Lambda.map(skin.split(";"),Std.parseInt);
		var chk = 0;
		for( x in parts )
			chk = ((chk * 11) ^ x) & 0x1FFFF;
		var fr = parts.first()%2  + 1;
		return { chk : chk, frame : fr };
	}

	public function paint(){
		box._init( skin, getInfos().chk );
	}

	//
	public function dropShield(){
		Reflect.setField(box.smc,"_sid", false );
		var pwp = fxThrow("mcShield");
		pwp.vx *= 0.8+Math.random()*4;
		pwp.vy *= 0.8+Math.random()*4;

	}

	// ANIMS
	public function hurt(n,?type){
		damage += n;
		fxHurt(type);

		//
		
		var mc = Game.me.dm.attach("mcScore",Game.DP_PARTS);
		mc._x = x;
		mc._y = root._y-height;
		cast(mc).score = n;



		var lifeMax = gladiator.getLife();
		if( gladiator.flSurvival && damage >= lifeMax){
			gladiator.flSurvival = false;
			damage = lifeMax-1;
		}

		var prc = (1-damage/lifeMax)*100;
		ig.setLife(prc);



	}
	public function dodge(){
		playAnim("jump");
		step = Dodge;
		bounceFrict = 0;
		vz = -10;
		vx = side*8;
		weight = 1;
		flAnim = true;
	}
	public function parry(){
		playAnim("parry");
		step = Hurt;
		//
		friction = 0.9;
		vx = side*2;
		stunCount = 18;
		flAnim = true;
	}

	public function recal(){
		step = null;
		flAnim = false;
		weight = 0;
		z = 0;
		vz = 0;
		vx = 0;
	}

	//
	public function heal(n){
		damage -= n;


		var mc = Game.me.dm.attach("mcScoreHeal",Game.DP_PARTS);
		mc._x = x;
		mc._y = root._y-height;
		cast(mc).score = n;

		var prc = (1-damage/gladiator.getLife())*100;
		ig.setLife(prc);
	}

	// FX
	public function fxHurt(?type:Int){

		if(type==null)type = 3;
		if(type==-1)type = Std.random(3)+1;

		step = Hurt;
		playAnim("hurt"+type);
		friction = 0.85;
		vx = side*5;
		stunCount = 12;
		flAnim = true;
	}
	public function fxNet(){
		for( i in 0...32 ){
			var p = new Part(Game.me.dm.attach("partNet",Game.DP_FIGHTERS));
			var a = Math.random()*6.28;
			var sp  = 2+Math.random()*2;
			var ca = Math.cos(a)*sp;
			var ra = Math.random()*2-1;
			var sa = Math.sin(a)*sp*2;

			var cr = 5;
			p.x = x+ca*cr;
			p.y = y+ra*cr;
			p.z = sa*cr-height;

			p.vx = ca;
			p.vy = ra;
			p.vz = sa- Math.random()*2;

			p.friction = 0.85;

			p.timer = 10+Math.random()*20;
			p.weight = 0.1+Math.random()*0.1;

			p.root._rotation = a/0.0174;
			p.root._xscale = 50+Math.random()*100;
			p.root._yscale = 50+Math.random()*100;

			p.bounceFrict = 0;
			p.fadeLimit = 5;


		}
	}


	//
	public function addWeapon(wid:_Weapons){
		gladiator.weapons.push(wid);
		ig.displayWeapon();
	}
	public function removeWeapon(?wid:_Weapons){
		if(wid==null)wid = wp;
		gladiator.weapons.remove(wid);
		ig.displayWeapon();

	}

	public function fxThrow(?link,?fr){
		if(link==null)link="mcWeapon";
		if(fr==null) fr = Type.enumIndex(wp)+1;
		var pwp = new Part( Game.me.dm.attach(link,Game.DP_FIGHTERS) );
		pwp.root.gotoAndStop(fr);
		pwp.x = x + side*15;
		pwp.y = y-15;
		pwp.z = -60;
		pwp.vx = side*(2.5+Math.random());
		pwp.vz = -12;
		pwp.weight = 1;
		pwp.ray = 10;
		pwp.vr = (5+Math.random()*10)*side;
		pwp.dropShadow();
		pwp.updatePos();
		pwp.root._xscale = -side * 100;
		pwp.root._rotation += 60*side;
		pwp.timer = 50;
		pwp.groundRay = -1;
		if(link=="mcWeapon")removeWeapon(wp);
		Filt.glow(pwp.root,2,4,0);
		return pwp;
	}

	// TOOLS
	public function getRange(){
		return ray + 7 + Data.WEAPONS[Type.enumIndex(wp)].zone*10 ;
	}
	public function playAnim(str){
		//if(nextAnim=="death")trace("["+str+"]");
		nextAnim = str;

		if(status[1]){
			fxNet();
			status[1] = null;
		}
	}

	override function kill(){
		Game.me.fighters.remove(this);

		super.kill();

	}









//{
}