import Fight ;
import flash.Key;
import fx.Env;
import mt.bumdum.Lib;
import mt.bumdum.Bmp;
import mt.bumdum.Phys;
import Fighter.Mode ;

enum Step {
	Load;
	Play;
	Pause;
}

class Main {

	public static var DATA : _Data;
	public var flDisplay:Bool;

	public var root : flash.MovieClip ;
	public static var me : Main ;
	public var data : String ;

	public var current : State ;
	public var states : Array<State>;

	public var step : Step ;
	public var timer : Float ;
	public var waitingTime : Float ;
	public var scene : Scene ;
	public var fighters : Array<Fighter> ;
	public var coming : List<Fighter> ;
	public var side : Array<Array<Fighter>> ;
	public var loaded : Bool ;
	public var initDone : Bool ;
	public var castle:Castle;

	public var mcBarTime:{>flash.MovieClip,max:Int};
	public var elapsedTime:Int;
//	public var timeBase : Int;
	public var photomaton:Photomaton;

	public var check : haxe.Http;
	public var checkDone : Bool;

	//debug
	public var dinoData : String ;

	public function new(mc : flash.MovieClip) {
		
		#if debug
		if( haxe.Firebug.detect())
			haxe.Firebug.redirectTraces() ;
		#end
		
		flDisplay = false;

		root = mc;
		me = this;
		elapsedTime = 0;
//		timeBase = 1;
		loaded = false;
		initDone = false;
		step = Load;

		var data = Reflect.field(flash.Lib._root, "data");
		if( data != null  ) {
			try {
				DATA = haxe.Unserializer.run(data);

				#if tease
				var history = new List();
				debugHistory(history);
				DATA._history = history;
				checkDone = true;
				#else
				checkData();
				#end
				
			} catch ( e : Dynamic ) {
				fatalError(e);
				return;
			}
		} else {
			var history = new List();
			var www = "../../../";
			DATA = {
				_sdino : www+"dev/swf/sdino.swf",
				_smonster : www+"dev/swf/smonster.swf",
				_dino : www+"dev/swf/dino.swf",
				_bg : www + "stable/img/fight/castle_plain.jpg",
				_dojo : null,//www+"stable/img/fight/dojo_arene_best.png",
				_equip : www+"stable/img/objs/::id::.gif",
				_mtop : 140,
				_mbottom : 20,
				_mright : 0,
				//_ground : "water",
				//_ground : "rock",
				_ground : null,//"dirt",
				_history : history,
				_debrief:null,
				_check:null,
				_debug : null,
			};
			debugHistory(history);
			checkDone = true;
		}

		// MARGE MINI
		//DATA._mbottom = Std.int( Math.max(DATA._mbottom,60) );
		Scene.WIDTH -= DATA._mright;
		scene = new Scene(this.root);
		scene.groundType = DATA._ground;
		//
		photomaton = new Photomaton( Scene.me.dm.empty(0) );
		scene.setSkin();
		initFighters();
	}

	function checkData() {
		var me = this;
		check = new haxe.Http(DATA._check);
		check.onError = fatalError;
		check.onData = function(data) {
			if( data != "OK" )
				me.fatalError(data);
			else
				me.checkDone = true;
		};
		check.request(false);
	}
	
	
	function  notifyBug() {
		if( DATA._debug == null ) return;
		var info = FightPrinter.toString(DATA._history);
		var me = this;
		check = new haxe.Http(DATA._debug);
		check.onError = fatalError;
		check.onData = function(data) {};
		check.setParameter("data",haxe.Serializer.run(info));
		check.request(false);
	}
	
	// ------------------------------------------------ DEBUG ------------------------------------------------------
	function debugHistory( h : List < _History > ) {

    h.add( _HAdd({ _props : [], _dino : true, _life : 73, _name : "camelCase", _side : true, _size : 210, _fid : 0, _gfx : "K9MGXKOsJdSt7000"}, null) );
    h.add( _HAdd({ _props : [], _dino : false, _life : 20, _name : "Goupignon", _side : false, _size : 100, _fid : 1, _gfx : "goupi3"}, null) );
    h.add( _HAdd({ _props : [], _dino : false, _life : 70, _name : "Géant Vert", _side : false, _size : 100, _fid : 2, _gfx : "gvert"}, null) );
    h.add( _HAdd({ _props : [], _dino : false, _life : 20, _name : "Goupignon", _side : false, _size : 100, _fid : 3, _gfx : "goupi"}, null) );
    h.add( _HAdd({ _props : [], _dino : false, _life : 70, _name : "Géant Vert", _side : false, _size : 100, _fid : 4, _gfx : "gvert"}, null) );
    h.add( _HStatus(0, _SFlames) );
    h.add( _HMaxEnergy([0], [100]) );
    h.add( _HEnergy([0], [100]) );
    h.add( _HLog("Energy enabled") );
    h.add( _HDisplay(null) );
    h.add( _HEnergy([1,0,3,2,4], [100,100,100,100,100]) );
    h.add( _HPause(0) );
    h.add( _HGoto(1, 0, _GNormal) );
    h.add( _HDamages(1, 0, 1, _LNormal, null) );
    h.add( _HLost(1, 43, _LFire) );
    h.add( _HEnergy([1], [94]) );
    h.add( _HDead(1) );
    h.add( _HEnergy([0,3,2,4], [100,100,100,100]) );
    h.add( _HPause(2) );
    h.add( _HAnnounce(0, "Météores") );
    h.add( _HDamagesGroup(0, { var l = new List();l.add({ _life : 482, _tid : 2});l.add({ _life : 401, _tid : 3});l.add({ _life : 473, _tid : 4}); l; }, _GrMeteor) );
    h.add( _HEnergy([0], [59]) );
    h.add( _HDead(2) );
    h.add( _HDead(3) );
    h.add( _HDead(4) );
    h.add( _HRegen(0, 1, _LHeal) );
    h.add( _HFinish(_EBEscape, _EBStand) );

	}
	
	// --------------------------------------------------------------------------------------------------------------
	public function fatalError(e : Dynamic) {
		//### TODO
		trace(Std.string(e)) ;
	}

	// UPDATE
	public function update() {
		castle.update();
		scene.update();
		updateStates();
		updateSprites();
		switch(step){
			case Load:
				if( checkLoading() ) {
					setPause(1);
					loaded = true ;
				}
			case Play:
			case Pause:
				waitingTime -= mt.Timer.tmod;
				if( waitingTime < 0 ) {
					waitingTime = null;
					step = Play;
					playNext();
				}
		}
		// WALKER
		if( Math.random() / mt.Timer.tmod < 0.025 ) {
			var a = [];
			for( f in fighters )
				if( f.isReadyToWalk() )
					a.push(f);
			a[Std.random(a.length)].startWalk();
		}
		updateTimeBar();
	}

	// STATES
	function updateStates() {
		var list = states.copy();
		for( s in list )
			s.update();
	}
	
	function playNext() {
		var h = Main.DATA._history.pop();
		var current:State = null;
		try {
			switch(h) {

				case _HEnergy(fids,energies) :	for( i in 0...fids.length ) {
													getFighter(fids[i]).slot.setEnergy(energies[i]);
												}
												playNext();
				
				case _HMaxEnergy(fids,energies):for( i in 0...fids.length ) {
													getFighter(fids[i]).slot.setMaxEnergy(energies[i]);
												}
												playNext();
				
				case _HPause(time) :			setPause(time);

				case _HAnnounce(fid, skill) :		current = new ac.Announce( getFighter(fid), skill ) ;

				case _HGoto(fid, tid, fxt) :		current = new ac.GotoFighter( getFighter(fid), getFighter(tid), fxt) ;

				case _HDamages(fid, tid, life, lfxt, fxt ) :		current = new ac.Damages( getFighter(fid), getFighter(tid), life, lfxt, fxt ) ;

				case _HReturn(fid) :			current =  new ac.Return( getFighter(fid) ) ;

				case _HDead(fid) :			current = new ac.Dead( getFighter(fid) ) ;

				case _HLost(fid, life, fxt) :		current = new ac.Lost( getFighter(fid), life, fxt ) ;

				case _HFinish( bh0, bh1 ) :		current = new ac.Finish(bh0, bh1) ;

				case _HRegen(fid, life, fxt) :		current = new ac.Regen( getFighter(fid), life, fxt ) ;

				case _HObject( fid, name, oid) :	current = new ac.Object( getFighter(fid), name, oid ) ;

				case _HStatus(fid, s) :			current = new ac.Status( getFighter(fid), s ) ;

				case _HNoStatus(fid, s) :		current = new ac.NoStatus( getFighter(fid), s ) ;

				case _HDamagesGroup( fid, tids, fx) :
					var f = getFighter(fid) ;
					var t = new List() ;
					for (tid in tids)t.add({ t : getFighter(tid._tid), life : tid._life}) ;
					switch(fx) {
						case _GrDeluge :	current = getEffect( _SFCloud(fid, 1, null), t);
						default :			current = new ac.DamagesGroup(f, t, fx) ;
					}

				case _HAdd(f,fxt) :
					var ft = new Fighter(f) ;
					getSide(ft.side).push(ft) ;
					current = new ac.AddFighter(ft,fxt);

				case _HFx(fxt) :	{ current = getEffect(fxt); if( current == null ) playNext(); }//todo kill previous current if set ?

				case _HAddCastle(c) :
					castle = new Castle(c);
					playNext();

				case _HCastleAttack(fid,life,fx) : current = new ac.AttackCastle( getFighter(fid), life, fx ) ;

				case _HDisplay(fxt) : current = new ac.Start(fxt);
				
				case _HTimeLimit(max):
					initTimeBar(max);
					playNext();

				case _HTalk( fid, str ) :		current = new ac.Talk( getFighter(fid),str);

				case _HText( str ) :			current = new ac.Text(str);

				case _HEscape( fid ) :			current = new ac.Escape( getFighter(fid) );

				case _HMoveTo(fid,x,y) :		current = new ac.MoveTo( getFighter(fid), x, y  );
				
				case _HFlip(fid) :			current = new ac.Flip( getFighter(fid) );
				
				case _SpawnToy(tid,x,y,z,vx,vy,vz) :	current = new ac.SpawnToy(tid,x,y,z,vx,vy,vz);
				
				case _DestroyToy(tid) :			current = new ac.DestroyToy(tid);
				
				case _HWait(ms) :			current = new ac.Wait(ms);
				
				case _HLog(log) : playNext();
				
				case _HNotify(lid, n):	new ac.Notification( lid.map( function(id) return getFighter(id) ), n );
										playNext();
				default :
					if( h != null ) {
						haxe.Log.trace("UNSUPPORTED "+Std.string(h),null);
						playNext();
					}
			}
		} catch( e : Dynamic ) {
			trace(e);
			trace("AN ERROR OCCURED.  FIGHT INFORMATION HAS BEEN SENT TO OUR TEAM FOR DEBUG PURPOSE");
			notifyBug();
			flash.Lib._root.onEnterFrame = null;
			return;
		}
		current.endCall = playNext;
	}

	static var currentEnv:Env;
	function getEffect( fxt:_SuperEffect, ?tids ) {
		var ac:State = null;
		switch(fxt) {
			case _SFEnv7( frame, remove ) :			if( currentEnv != null ) currentEnv.dispose();
													if( remove == false ) ac = currentEnv = new fx.Env(frame);
			case _SFAura( fid, color, id ) :		ac = new fx.Aura( getFighter(fid), color, id, null  );
			case _SFAura2( fid, color, id, type ) :	ac = new fx.Aura( getFighter(fid), color, id, type  );
			case _SFSnow( fid,  id, gc, rp ) :		ac = new fx.Snow( getFighter(fid), id, gc, rp );
			case _SFSwamp( fid ) :					ac = new fx.Swamp( getFighter(fid) );
			case _SFCloud( fid, id, col ) :			ac = new fx.Cloud( getFighter(fid), id, col );
			case _SFFocus( fid, color ) :			ac = new fx.Focus( getFighter(fid), color );
			case _SFDefault( fid ) :				ac = new fx.Default( getFighter(fid) );
			case _SFAttach( fid, link ) :			ac = new fx.Attach( getFighter(fid), link );
			case _SFAttachAnim( fid, link, frame ) :ac = new fx.AttachAnim( getFighter(fid), link, frame );
			case _SFAnim( fid, link ) :				ac = new fx.Anim( getFighter(fid), link );
			case _SFHypnose( fid, tid) :			ac = new fx.Hypnose( getFighter(fid), getFighter(tid) );
			case _SFRay(fid):						ac = new part.TwistingRay(getFighter(fid));
			case _SFSpeed( fid, a ) :				var n = [];
													for( fid in a ) n.push( getFighter(fid) );
													ac = new fx.Speed( getFighter(fid), n );
			case _STired( fid )://??
			case _SFRandom( fid, frame, ok ) : 		ac = new fx.RandomState( getFighter(fid), frame, ok );
			case _SFLeaf(fid, link)			:		ac = new fx.Leaf( getFighter(fid), link );
			case _SFMudWall(fid, remove )	: 		ac = new fx.MudWall( getFighter(fid), remove );
			case _SFBlink(fid, color, alpha):		ac = new fx.Blink( getFighter(fid), color, alpha );
			case _SFGenerate( fid, color, strength, radius ) :		ac = new fx.Generate( getFighter(fid), color, strength, radius );
			//TODO !
		}
		if( ac != null )
			ac.tids = tids;
		return ac;
	}
	
	// SPRITES
	function updateSprites(){
		var list = mt.bumdum.Sprite.spriteList.copy();
		for( sp in list )
			sp.update();
	}

	// ACTION
	// PAUSE
	function initTimeBar(n){
		mcBarTime = cast Scene.me.dm.attach("mcBarTime", Scene.DP_INTER);
		mcBarTime._x = 8;
		mcBarTime._y = 4;
		mcBarTime.max = n;
	}
	
	function updateTimeBar(){
		if( mcBarTime == null )
			return;
		var c = (mcBarTime.max - elapsedTime) / mcBarTime.max;
		var dx = mcBarTime.smc._xscale - c * 100 ;
		if( dx > 0 ) mcBarTime.smc._xscale -= 0.08;
		var lim = 5;
		if( dx > lim ) mcBarTime.smc._xscale -= dx*(dx-lim) * 0.01;

		if( mcBarTime.smc._xscale <= 0 ) {
			mcBarTime.smc._xscale = 0;
			mcBarTime._y += mcBarTime._y - 4.5;
			if( mcBarTime._y < -20 ) {
				mcBarTime.removeMovieClip();
				mcBarTime = null;
			}
		}
	}
	
	public function setPause(p:Int) {
		step = Pause;
		waitingTime = p;
		elapsedTime += p;
	}

	function checkLoading() : Bool {
		if( scene.loaded < 2 || photomaton.loaded < 2 )
			return false ;
		if( !checkDone )
			return false;
		return true ;
	}

	function initFighters() {
		fighters = new Array() ;
		coming = new List() ;
		side = new Array() ;
		states = new Array();
		for(i in 0...2)
			side[i] = new Array() ;
	}
	
	public function getSide(s : Bool) {
		return side[if(s) 0 else 1] ;
	}
	
	public function getFighter(id : Int) {
		if( fighters == null)
			throw "unknown requested fighter" ;
		for(f in fighters) {
			if( f.fid == id)
				return f ;
		}
		throw "unknown requested fighter" ;
	}

	function waitToQuit() {
		root.onEnterFrame = null ;
		//### TODO
	}

	//### KEY LISTENER
	/*
	function initKeyListener() {
		var kl = {
			onKeyDown:callback(onKeyDown),
			onKeyUp:callback(onKeyUp)
		}
		Key.addListener(kl) ;
	}
	function onKeyDown(){
		var n = Key.getCode() ;
		switch(n){
			case Key.CONTROL:
				switch (step) {
					case Pause : step = Play ;
					case Play : step = Pause ;
					default:
				}
			case Key.SPACE:
				showAllInfos() ;
		}
	}
	function onKeyUp(){
		var n = Key.getCode() ;
		switch(n){
			case Key.SPACE:
				hideAllInfos() ;
		}
	}

	function showAllInfos() {
		for (s in side) {
			for (f in s) {
				f.showLife() ;
			}
		}
	}
	
	function hideAllInfos() {
		for (s in side) {
			for (f in s) {
				f.hideLife() ;
			}
		}
	}
	*/

	function tracePerf(){
		haxe.Log.clear();
		trace( "FPS:"+Std.int(40/mt.Timer.tmod));
		trace( "3D Sprites:"+Sprite.spriteList.length );
		trace( "2D Sprites:"+mt.bumdum.Sprite.spriteList.length );
	}
}

//- textes qui sortent de la box pendant que ça augmente
//- mode théatre (sans box, avec rideaux, avec les noms tout le temps)
