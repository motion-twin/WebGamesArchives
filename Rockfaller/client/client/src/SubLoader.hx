import data.LevelDesign;
import data.Settings;

import mt.deepnight.slb.*;
import mt.deepnight.slb.assets.TexturePacker;

class SubLoader {

	public static function prepareLevels(numLevel:Int, onComplete : Void -> Void ){
		return new SubLoader([
			function(loader) {
				var maxLevel = LevelDesign.AR_LEVEL.length;
				trace(maxLevel);
				if (numLevel >= LevelDesign.MAX_LEVEL_CLIENT)
					numLevel = LevelDesign.MAX_LEVEL_CLIENT;
				
				if (numLevel <= 120) {
					if( Settings.SLB_LEVELS1 == null ){
						TexturePacker.importXmlMtDeferred("levels.xml",Main.getWorker(),function(l){
							Settings.SLB_LEVELS1 = l;
							ui.ButtonLevel.SET_POS(0, maxLevel <= 120 ? maxLevel : 121, Settings.SLB_LEVELS1);
							Settings.SLB_LEVELS1.texture.pixels = null;
							loader.done();
						},false,null,true);
					}
					else{
						tryRealloc(loader,Settings.SLB_LEVELS1.texture);
					}
				}
				else if (numLevel <= 240) {
					if( Settings.SLB_LEVELS2 == null ){
						TexturePacker.importXmlMtDeferred("levels2.xml",Main.getWorker(),function(l){
							Settings.SLB_LEVELS2 = l;
							ui.ButtonLevel.SET_POS(120, maxLevel <= 240 ? maxLevel : 241, Settings.SLB_LEVELS2);
							Settings.SLB_LEVELS2.texture.pixels = null;
							loader.done();
						},false,null,true);
					}
					else{
						tryRealloc(loader,Settings.SLB_LEVELS2.texture);
					}
				}
			}
		],onComplete);
	}

	public static function disposeLevels(){
		#if mBase
		if( Settings.SLB_LEVELS1 != null ) Settings.SLB_LEVELS1.texture.dispose();
		if( Settings.SLB_LEVELS2 != null ) Settings.SLB_LEVELS2.texture.dispose();
		#end
	}

	public static function prepareGame( level:Int, onComplete : Void -> Void ){
		return new SubLoader([
			function(loader){
				switch( data.LevelDesign.GET_LEVEL_UNIVERS(level) ){
				case 0:
					if( Settings.SLB_UNIVERS1 == null ){
						TexturePacker.importXmlMtDeferred("universCIM.xml",Main.getWorker(), function(l){ Settings.SLB_UNIVERS1 = l; loader.done(); });
					}else{
						tryRealloc(loader,Settings.SLB_UNIVERS1.texture);
					}
				case 1:
					if( Settings.SLB_UNIVERS2 == null ){
						TexturePacker.importXmlMtDeferred("universWCC.xml",Main.getWorker(), function(l){ Settings.SLB_UNIVERS2 = l; loader.done(); });
					}else{
						tryRealloc(loader,Settings.SLB_UNIVERS2.texture);
					}
				case 2:
					if( Settings.SLB_UNIVERS3 == null ){
						TexturePacker.importXmlMtDeferred("universNL.xml",Main.getWorker(), function(l){ Settings.SLB_UNIVERS3 = l; loader.done(); });
					}else{
						tryRealloc(loader,Settings.SLB_UNIVERS3.texture);
					}
				}
			},
			function(loader){
				if( Settings.SLB_TAUPI == null ){
					TexturePacker.importXmlMtDeferred("taupinotron.xml",Main.getWorker(),function(l){
						Settings.SLB_TAUPI = l;
						prepareFlumpTaupi();
						loader.done(); 
					},true);
				}else{
					tryRealloc(loader,Settings.SLB_TAUPI.texture);
					prepareFlumpTaupi();
				}
			},
			function(loader){
				tryRealloc(loader,Settings.SLB_GRID.texture);
			}
		],onComplete);
	}

	static function prepareFlumpTaupi(){
		mt.motion.FlumpTP.CREATE(	"taupi",
			"taupiFlump/library.json",
			Settings.SLB_TAUPI
		);
	}

	public static function disposeGame(){
		#if mBase
		if( Settings.SLB_GRID != null ) Settings.SLB_GRID.texture.dispose();
		if( Settings.SLB_UNIVERS1 != null ) Settings.SLB_UNIVERS1.texture.dispose();
		if( Settings.SLB_UNIVERS2 != null ) Settings.SLB_UNIVERS2.texture.dispose();
		if( Settings.SLB_UNIVERS3 != null ) Settings.SLB_UNIVERS3.texture.dispose();
		if( Settings.SLB_TAUPI != null ) Settings.SLB_TAUPI.texture.dispose();
		#end
	}

	static function tryRealloc( loader:SubLoader, t:h3d.mat.Texture){
		if( t.isDisposed() ){
			if( Std.is(t,mt.Assets.PVRTexture) ){
				var t : mt.Assets.PVRTexture = cast t;
				var f;
				var task = new mt.Worker.WorkerTask(function(){
					f = t.reallocMT();
				});
				task.onComplete = loader.done;
				Main.getWorker().enqueue( task );
			}else{
				t.realloc();
				loader.done();
			}
		}else{
			loader.done();
		}
	}
	
	var wait : Int;
	var onComplete : Null<Void->Void>;

	function new( arr:Array<SubLoader->Void>, onComplete:Void->Void ){
		wait = arr.length;
		this.onComplete = onComplete;
			
		haxe.Timer.delay(run.bind(arr),1);
	}

	function run( arr:Array<SubLoader->Void> ){
		for( f in arr )
			f(this);
	}

	function done(){
		wait--;
		if( wait == 0 )
			onAllDone();
	}

	function onAllDone(){
		if( onComplete != null )
			onComplete();
	}
}
