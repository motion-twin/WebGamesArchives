import Protocol;
import mt.bumdum.Lib;


enum ShipSize{
	Normal;
	Huge;
}

class Bad extends Phys {//}

	var fam:BadFamily;
	var size:ShipSize;

	var flDeath:Bool;
	public var rid:Int;
	public var bsid:Int;
	var px:Int;
	var py:Int;

	var life:Float;
	var flh:Float;
	public var scy:Float;

	var robertDecal:Float;

	//public var vr:Float;

	public var behaviours:Array<Behaviour>;
	public var status:Array<Status>;

	public var seed:mt.Rand;
	public var skin:{>flash.MovieClip,reac:flash.MovieClip};
	public var robs:Array<Robot>;



	public function new(mc,rid){
		super(mc);
		this.rid = rid;
		Game.me.bads.push(this);

		behaviours = [];

		bsid = 0;
		life = 1;
		ray = 10;
		scy = 1;

		x = -100;
		y = 0;
		size = Normal;

	}

	public function addDestiny( d:Array<Command>, ?flMain ){
		if(robs==null)robs = [];
		var rob = new Robot(this);
		rob.flMain = true;
		rob.destiny = d;
		robs.push(rob);
	}


	public function setSeed(n){

		seed = new mt.Rand(n);
		//for(i in 0...10 )seed.rand();
		//trace("seed("+n+")"+(seed.rand()>0.2) );

	}
	public function update(){

		super.update();

		for(rob in robs )rob.update();
		updateGridPos();

		//
		updateBehaviours();
		//
		skin.reac._visible = Math.abs(vx)+Math.abs(vy) > 3;


		if(flh!=null)fxFlash();
	}

	// FAMILY
	public function setFamily(fam){
		this.fam = fam;
		root.gotoAndStop(Type.enumIndex(fam)+1);

		skin = cast root.smc;

		switch(fam){

			case DRONE :
				life = 2;
				ray = 10;

			case SUPER_DRONE :
				life = 4;
				ray = 10;

			case SENTINELLE :
				life = 10;
				ray = 15;

			case ZILA :
				life = 40;
				ray = 20;

			case ASSASSIN :
				life = 15;
				ray = 15;

			case VOLT_BALL :
				life = 50;
				ray = 15;

			case BEHEMOTH :
				life = 100;
				ray = 30;
				scy = 0.7;

			case KOBOLD :
				life = 4;
				ray = 12;

		}

	}

	// BEHAVIOURS
	public function updateBehaviours(){
		for( bh in behaviours)bh.update();
	}

	// GRID
	function updateGridPos(){
		if( flDeath || size!= Normal )return;
		var npx = Cs.getPX(x);
		var npy = Cs.getPY(y);
		if( npx!=px || npy!=py ){
			removeFromGrid();
			px = npx;
			py = npy;
			insertInGrid();
		}
	}
	function insertInGrid(){
		for( x in 0...3 ){
			for( y in 0...3 ){
				var gx = px+x-1;
				var gy = py+y-1;
				Game.me.bgrid[gx][gy].push(this);
			}
		}
	}
	function removeFromGrid(){
		for( x in 0...3 ){
			for( y in 0...3 ){
				var gx = px+x-1;
				var gy = py+y-1;
				Game.me.bgrid[gx][gy].remove(this);
			}
		}
	}

	// DAMAGE
	public function impact(shot:HeroShot){
		if( haveStatus(INVINCIBLE) ){
			shot.fxBounce(this);
			return;
		}

		shot.fxImpact();
		damage(shot.damage);
	}
	function damage(n:Float){
		fxFlash(1);
		life = Math.max(0,life-n);
		if(life==0)explode();
	}
	public function explode(?flSuicide){

		if(flSuicide!=true){
			var sc = Cs.getScore(fam);
			sc = KKApi.cadd( sc, KKApi.const(Game.me.bonus) );
			Game.me.fayot._k[ Type.enumIndex(fam) ]++;
			var col = 0;
			if( rid==Game.me.robertId ){
				col = 0xFF0000;
				sc = Cs.SCORE_ROBERT;
			}
			var n = KKApi.val(sc);
			Game.me.genScore(x,y,n,col);
			KKApi.addScore(sc);
			Game.me.incBonus(1);
		}


		fxExplode();
		kill();
	}

	// KILL
	public function warp(){
		/*
		var mc = Game.me.dm.attach("mcWarpMask",Game.DP_FX);
		var size = Math.max(root._width,root._height);
		mc._width = mc._height = size;
		Reflect.setField(mc,"_trg",root);
		root.setMask(mc);
		mc._x = root._x;
		mc._y = root._y;
		mc._rotation = Math.random()*360;
		Filt.glow(root,2,4,0xFFFFFF);
		root = null;
		*/

		var max = Std.int(ray*0.3);
		var bs = 200;

		var dx = x - Game.me.htrg.x;
		var dy = y - Game.me.htrg.y;
		var dist = Math.sqrt(dx*dx+dy*dy);

		for( i in 0...max ){

			var p = new mt.bumdum.Phys(Game.me.dm.attach("partLight",Game.DP_FX));
			p.x = x + (Math.random()*2-1)*ray*2;
			p.y = y + (Math.random()*2-1)*ray*2;

			var dx = p.x - Game.me.htrg.x;
			var dy = p.y - Game.me.htrg.y;
			var a = Math.atan2(dy,dx);
			var sp = Math.max(70-Math.pow(dist,0.4)*8,5) * 0.8+Math.random()*0.4;

			p.vx = Math.cos(a)*sp;
			p.vy = Math.sin(a)*sp;
			p.frict = 0.95;
			p.timer = 10+Math.random()*10;
			p.setScale(50+Math.random()*100);
			p.fadeType = 0;
			p.updatePos();

		}



		kill();
	}
	public function vanish(){
		if(Game.me.bonus>5)Game.me.fayot._m.push(Game.me.bonus);
		Game.me.setBonus(0);
		kill();
	}
	public function kill(){
		mcLabel.removeMovieClip();
		flDeath = true;
		removeFromGrid();
		Game.me.bads.remove(this);
		super.kill();
	}

	// FX
	function fxExplode(){

		var max =1+ Std.int(ray/5);

		for( i in 0...max ){
			var p = new mt.bumdum.Phys( Game.me.dm.attach("mcExplosion",Game.DP_UNDER_FX) );
			p.x = x + (Math.random()*2-1)*ray;
			p.y = y + (Math.random()*2-1)*ray;
			p.root._rotation = Math.random()*360;
			//p.timer = 20;
			p.weight = 3+Math.random();
			p.vx = (Math.random()*2-1)*3;
			p.vy = - (8+Math.random()*6);
			Filt.blur(p.root,12,12);
			p.updatePos();
			p.sleep = i;
			p.root.stop();
			p.setScale(ray*5);
			p.updatePos();

		}



	}
	function fxFlash(?n){
		if(n!=null)flh = n;
		var inc = Std.int(flh*255);
		flh *= 0.5;
		if(flh<0.1){
			flh = null;
			inc = 0;
		}

		Col.setColor(root,0,inc);

	}

	// STATUS
	public function addStatus(st){
		if(status==null)status = [];
		status.push(st);
	}
	public function removeStatus(st){
		status.remove(st);
	}
	public function haveStatus(st){
		for( sta in status )if(sta==st)return true;
		return false;
	}
	public function updateStatus(){

	}

	// TOOLS
	public function isOut(n:Float){
		return x<-n || x>Cs.mcw+n ||  y<-n || y>Cs.mch+n;
	}

//{
}

/*

Vous dirigez l'escadron de choc **TwinSpirit** composé des pilote **Wallis** et **Futuna**.
Lors d'une mission de routine, l'appareil de **Wallis** est abattu par **Robert**. Grâce à son moteur temporelle, **Futuna** parvient a remonter le temps pour prêter main forte a son coéquipier.
Parviendrez vous intercepter et détruire **Robert** a temps ?


*/


























