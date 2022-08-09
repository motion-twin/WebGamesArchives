import Datas;
import mt.bumdum.Lib;
import mt.bumdum.Bouille;

typedef McCounter = {>flash.MovieClip, butMin:flash.MovieClip, butMaj:flash.MovieClip, field:flash.TextField };

class Game {//}

	static var mcw = 800;
	static var mch = 500;


	static var CAR_MAX = 9;

	var cars:Array<Int>;
	var counters:Array<McCounter>;

	var loaded:Int;
	var bouille:Bouille;
	var dm:mt.DepthManager;
	var root:flash.MovieClip;
	var avatar:flash.MovieClip;
	public static var me:Game;
	var so:flash.SharedObject;



	public function new( mc:flash.MovieClip ){
		me = this;
		root = mc;
		dm = new mt.DepthManager(mc);
		var bg = dm.attach("mcBg",0);


		so = flash.SharedObject.getLocal("bouille");
		if( so.data.cars == null ){
			var a = [];
			for( i in 0...CAR_MAX )a[i] = Std.random(100);
			so.data.cars = a;
			so.flush();
		}
		cars = so.data.cars;


		initInter();
		loadBouille();
	}

	// BOUILLE
	function loadBouille(){

		avatar = dm.empty(1);

		var me = this;
		var f = function (mc){
			me.loaded++;
			if(me.loaded==2)me.applyBouille();
		}
		loaded = 0;

		var mcl = new flash.MovieClipLoader();
		mcl.loadClip("../../../web/www/swf/avatar.swf",avatar);
		mcl.onLoadInit = f;
		mcl.onLoadComplete = f;

	}
	function applyBouille(){
		var str = "";
		for( n in cars)str+=n+",";

		bouille = new Bouille(str);
		bouille.firstDecal = 0;
		bouille.apply(avatar);
		so.data.cars = cars;
		so.flush();
	}

	// INTER
	function initInter(){
		counters = [];
		var mod = 3;
		for( i in 0...CAR_MAX ){
			var mc:McCounter = cast dm.attach("mcCounter",2);
			mc._x = 160 + Std.int(i/mod)*100;
			mc._y = 20 + (i%mod)*30;
			mc.field.text = Std.string(cars[i]);
			mc.butMin.onPress = callback(carInc,i,-1);
			mc.butMaj.onPress = callback(carInc,i,1);
			counters.push(mc);
		}
	}
	function carInc(id,inc){
		cars[id] = cars[id]+inc;
		if(cars[id]<0)cars[id]=0;
		//root._rotation = cars[id];
		counters[id].field.text = Std.string(cars[id]);
		applyBouille();
	}

	// UPDATE
	public function update(){
		if(flash.Key.isDown(flash.Key.SPACE)){
			for( i in 1...CAR_MAX )cars[i] = Std.random(100);
			applyBouille();
		}
	}




//{
}













