import mt.bumdum.Lib;
import mt.bumdum.Sprite;
import Msg;





class Game implements MMGame<Msg> {//}
	
	public static var DP_BG = 1;
	public static var DP_MAP = 2;
	public static var DP_CACHE = 20;
	
	public static var DP_HERO = 1;
	public static var DP_SHOT = 2;
	public static var DP_CROSS = 7;
	public static var DP_INTERFACE = 8;
	
	public var mdm : mt.DepthManager;
	public var dm : mt.DepthManager;
	
	public var step:Int;
	var gid:Int;
	
	public var heroList:Array<Hero>;
	public var shotList:Array<Shot>;
	var butMapList:Array<flash.MovieClip>;
	
	var hero:Hero;
	var player:Hero;
	
	public var root : flash.MovieClip;
	var bg : flash.MovieClip;
	public var map:Map;
	
	
	
	function new( mc : flash.MovieClip ) {
		trace("!");
		Cs.game = this;
		root = mc.createEmptyMovieClip("e",0);
		mdm = new mt.DepthManager(mc);
		
		bg = mdm.attach("bg",DP_BG);
		MMApi.lockMessages(false);
		
		map = new Map();
		dm = new mt.DepthManager(map.root);
		
		var mask = mdm.attach("bg",DP_MAP);
		map.root.setMask(mask);
		
		shotList = [];
	}
	public function initialize() {
		//var g = 8;
		step = 0;
		
		//
		map.load(0);
		
		
		// CONTROL
		for( i in 0...2 ){
			var mc:{ >flash.MovieClip, but:flash.MovieClip } = cast mdm.attach("mcMapBut",DP_INTERFACE);
			mc._x = Cs.mcw*0.5 + (i*2-1)*30;
			mc._y = Cs.mch*0.5;
			mc.gotoAndStop(i+1);
			mc.but.onPress = switch(i){
				case 0:	nextMap;
				case 1:	validateMap;
				default: null;
			}
		}
		
		return Init(g);

		/*
		// sent it
		MMApi.sendMessage(Init(g));
		// we're done with initializing
		MMApi.endTurn();
		*/
	}
	
	// CHOOSE MAP
	function nextMap(){
		map.load( (map.id+1)%Map.MAX );
	}
	function validateMap(){
		mdm.clear(DP_INTERFACE);
		MMApi.sendMessage(Init(map.id));
		MMApi.endTurn();
	}

	// MAIN
	public function main() {
		
		//MMApi.print("phase:"+step);
		switch(step){
			case 0 : // CHOOSE PMAP
				map.mouseScroll();
				
			case 1 : // PASSIF
				
			case 2 : // ACTIF
				hero.control();
				map.scroll();
			case 3 : // VIEWER
				player.playLog();
				map.scroll();
			
		}
		
		for( sp in Sprite.spriteList){
			sp.update();
		}
		
	}

	
	public function autoPlay() {
		// skip turn
		MMApi.endTurn();
	}
	public function turnDone() {
		//lock = !MMApi.isMyTurn();
	}
	public function checkVictory() {

	}

	//
	public function initPlay(){
		step = 2;
		hero.initTurn();
	}

	// MESSAGE
	public function message( mine : Bool, msg : Msg ) {
		switch( msg ) {
			case Init(g):
				gid = 0;
				step = 1;
				if(!mine){
					map.load(g);
					gid = 1;
					step = 2;
				}
				
				heroList = [];
				for(i in 0...2) {
					var hero = new Hero(dm.attach("mcHero",DP_HERO));
					hero.init(i);
					heroList.push(hero);
					
				}
				hero = heroList[gid];
				if(step==2)hero.initTurn();
				
			case SendTurn(pid,log):
				if(mine){
					step = 1;
				}else{
					player = heroList[pid];
					player.log = log;
					map.focus = cast player;
					step = 3;
				}
			case Victory:
			
		}
	}

	
	
	
//{
}












