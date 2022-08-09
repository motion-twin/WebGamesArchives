import GameData._ArtefactId ;
import GameData._Artefact ;
import GameData.GameLog ;
import GameData._GameData ;
import Const.Art ;

class Log {
	
	public var specialReward : Array<{with : Art, obj : Art, ct : mt.flash.Volatile<Int>}> ;
	public var counters : Array<{obj : Art, ct : mt.flash.Volatile<Int>}> ;
	var used : Array<Art> ;
	public var grid : Array<Array<_ArtefactId>> ;
	
	
	public function new() {
		specialReward = new Array() ;
		used = new Array() ; 
		counters = new Array() ;
	}
	
	
	public function getInfos() : _GameData {
		return {
			_mode : Game.me.data._mode,
			_chain : Lambda.array(Lambda.map(Game.me.mode.chain, function(x : Art) { return Const.fromArt(x) ; })),
			_chWeight : Game.me.mode.chWeight,
			_chainknown : Game.me.mode.chainKnown,
			_object : Game.me.mode.useBonus,
			_artefacts : Game.me.mode.getUsedArtefacts(),
			_userobjects : Lambda.array(Lambda.map(used, function(x : Art) { return Const.fromArt(x) ; })),
			_grid : null,
			_bg : null,
			_texture : null,
			_spirit : null,
			_pnj_url : null,
			_object_url : null,
			_helps : null,
			_quest : null,
			_qmin : Game.me.mode.qmin,
			_playCount : Game.me.playCount,
			_sound : Game.me.sound.getStringConfig(),
			_music : null,
			_worldMod : Game.me.data._worldMod,
			_mod : false
		} ;
	}
	
	public function count(o : _ArtefactId, ?nb = 1) {
		
		
		for (c in counters) {
			if (!Type.enumEq(o, Const.fromArt(c.obj)))
				continue ;
			c.ct += nb ;
			return ;
		}

		var nc : {obj : Art, ct : mt.flash.Volatile<Int>} = {obj : Const.getArt(o), ct : null} ;
		var v : mt.flash.Volatile<Int> = nb ;
		nc.ct = v ;
		
		counters.push(nc) ;
	}
	
	
	public function getGrid() : Array<Array<_ArtefactId>> {
		var g = new Array() ;
		for (y in 0...Stage.HEIGHT) {
			var l = new Array() ;
			var foundOne = false ;
			for (x in 0...Stage.WIDTH) {
				var o = Game.me.stage.grid[x][y] ;
				if (o != null) {
					foundOne = true ;
					l.push(o.getArtId()) ;
				} else
					l.push(null) ;
			}
			if (foundOne)
				g.push(l) ;
			else 
				break  ;
		}
		
		return g ;
	}
	
	
	public function addReward(b : _ArtefactId, g : _ArtefactId) {
		return if (Type.enumEq(b, g))
					addSpecial(null, g) ;
				else
					addSpecial(b, g) ;
	}
	
	
	function addSpecial(b : _ArtefactId, g : _ArtefactId) : Int { 
		if (g == null)
			trace("#Error : reward undefined") ;
		
		for (s in specialReward) {
			if (!Type.enumEq(g, Const.fromArt(s.obj)))
				continue ;
			if ((b == null && s.with == null) || Type.enumEq(b, Const.fromArt(s.with))) {
				s.ct++ ;
				return s.ct ;
			}
		}

		var nr : {with : Art, obj : Art, ct : mt.flash.Volatile<Int>} = {with : Const.getArt(b), obj : Const.getArt(g), ct : null} ;
		var v : mt.flash.Volatile<Int> = 1 ;
		nr.ct = v ;

		specialReward.push(nr) ;

		return 1 ;
	}
	
	
	public function use(a : _ArtefactId) {
		used.push(Const.getArt(a)) ;
	}
	
	
	public function getFinalLog() : GameLog {
		return {
			_id : Game.me.id,
			_infos : getInfos(),
			_score : Game.me.score,
			_level : Game.me.mode.getFinalLevel(),
			_grid : grid,
			_counters : Lambda.array(Lambda.map(counters, function(x) { return {_o : Const.fromArt(x.obj), _nb : x.ct} ;})),
			_srewards : Lambda.array(Lambda.map(specialReward, function(x) { return {_by : Const.fromArt(x.with), _got : Const.fromArt(x.obj), _nb : x.ct} ;})),
			_v : secure.Codec.VERSION
		} ;
	}
	
	
	
	
	
	
	
	
}