package ui;

import flash.display.MovieClip;
import flash.text.TextField;
import flash.display.Sprite;
import flash.events.MouseEvent;
import fx.RedSeq;
import mt.Rand;

import Protocol;

using Ex;

/**
 * ...
 * @author de
 */

class BlueRedSeq  extends mt.fx.Fx
{
	var colTrans : flash.geom.ColorTransform;
	static var dummy : flash.geom.ColorTransform = new flash.geom.ColorTransform();
	
	var mc : MovieClip;
	var delay  : Int;
	var tot : Int;
	var step : Int;
	
	public function new( mc )
	{
		super();
		
		colTrans = new flash.geom.ColorTransform();
		colTrans.blueMultiplier = -1;
		colTrans.redOffset = 255;
						
		this.mc = mc;
		
		mc.cacheAsBitmap = true;
		
		delay = 3;
		tot = 80;
		step = 0;
	}
	
	public function blueTick()
	{
		mc.transform.colorTransform = dummy;
	}
	
	public function redTick()
	{
		mc.transform.colorTransform = colTrans;
	}
	
	public override function update()
	{
		super.update();
		tot--;
		if (delay-- <= 0)
		{
			nextStep();
			delay = 3;
		}
		if ( tot-- <= 0 )
			kill();
	}
	
	public function nextStep()
	{
		step++;
		
		if ( (step & 1) == 0)
			blueTick();
		else
			redTick();
	}
}

@:publicFields
class SpaceBattle extends MovieClip
{
	var items : MovieClip;
	var showOnTop : Bool;
	var fade : Bool;
	
	var target : {mc:MovieClip,data:FlashView_Hunter};
	
	static var guid = 0;
	public function new(showOnTop, fade)
	{
		super();
		this.showOnTop = showOnTop;
		this.fade = fade;
		
		hunters = new IntHash();
		patrols = new EnumHash( RoomId );
		turrets = new EnumHash( RoomId );
		if ( IsoConst.EDITOR)
			addRdHunters();
		else
			addHunters();
			
		
		//Debug.MSG("new battle " + (guid++));
	}
	
	function getData() : _RoomsClientData
		return Main.actServerData;
	
		
	/**
	 *
	 * -----\
	 * |	|
	 * *----*
	 */
	
	public static inline var FRAME_COL_INNER = 0x122170;
	public static inline var FRAME_COL_OUTER =  0x1077d5;
	
	public static inline var FRAME_COL_INNER_SELF = 0x47a30a;
	public static inline var FRAME_COL_OUTER_SELF =  0xdbf11e;
	
	public static var HUNT_FRAME = { w:40, h:40 };
	public static var TURRET_FRAME = { w:67, h:49 };
	public static var OFS_TOP = 24;
	public static var OFS_SIDE = 10;
	
	/*
	typedef FlashView_Hunter 		= { id : Int, kind : Int, state : HunterState, hp:Int }
	typedef FlashView_PatrolShip 	= { id : RoomId, hp : Int, pilot : HeroId, charges : Int, state : Int }
	typedef FlashView_Turret 		= { id : RoomId, pilot: HeroId , charges:Int, ok:Bool  }
	*/

	public var hunters :IntHash <
	{
		data:FlashView_Hunter,
		mc:Sprite,
	}>;
	
	public var patrols :EnumHash<RoomId,
	{
		data:FlashView_PatrolShip,
		mc:Sprite,
	}>;
	
	public var turrets :EnumHash <RoomId,
	{
		data:FlashView_Turret,
		mc:Sprite,
	}>;
	
	public function rdHunter() : FlashView_Hunter
	{
		var data = {life:Std.random(40)};
		return { id:Dice.roll(1, 3), type: [HUNTER,SPIDER,DICE,TRAX,ASTEROID,TRANSPORT].random().index(),  state:Move, hp:data.life,charges:Std.random(4),subtype:Dice.roll(0,3)};
	}
	
	public function rdPatrol() : FlashView_PatrolShip
	{
		var data = { charge:8, life:10 };
		return { id: RoomId.createI(RoomId.PATROL_SHIP_A_0.index() +Dice.roll(0,6)), charges:data.charge, hp:data.life,pilot:HeroId.random(),state:1};
	}
	
	public function rdTurret() : FlashView_Turret
	{
		var data =  { charge:4 };
		return { id: RoomId.createI(RoomId.LASER_TURRET_A_0.index() +Dice.roll(0, 2)),
		charges:data.charge,
		pilot:null,
		ok : RandomEx.randB()};
	}
	
	public function resetAll(){
		while ( numChildren != 0 ) removeChildAt( 0 );
		hunters = new IntHash();
		patrols.clear();
		turrets.clear();
		
		addHunters();
	}
	
	public function updateData()
	{
		var data = Main.actServerData;
		
		//trace("updateing sb hunters " + data.hunters.length);
		
		for (x in data.hunters)
		{
			var ht = hunters.get( x.id );
			if ( ht == null ){
				resetAll();
				return;
			}
			else{
				if( ht.data.hp != x.hp )
				{
					var lmc = ht.mc.getChildAt( 2 );
					if ( Std.is( lmc , TextField ) ){
						var tf : TextField = cast lmc;
						tf.text = Std.string(x.hp);
						
						var f = new flash.filters.GlowFilter();
						f.color = 0xFF0000;
						f.blurX = 2;
						f.blurY = 2;
						f.strength = 16;
						
						if( target != null && ht != null)
							if (target.mc == ht.mc)
								ht.mc.filters = [f,getTargetGlow()];
							else
								ht.mc.filters = [f];
						
						var vfx = new mt.fx.Shake(ht.mc, 3, 3);
						var tgt = cast ht.mc.getChildAt(0);
						
						var vfx2 = new BlueRedSeq(tgt);
						
						vfx.onFinish = function()
						{
							if( target!=null && ht != null)
								if (target.mc == ht.mc)
									ht.mc.filters = [getTargetGlow()];
								else
									ht.mc.filters = [];
						}
						
						vfx2.onFinish = function()
						{
							tgt.transform.colorTransform = new flash.geom.ColorTransform();
						}
						
						//ht.mc.
					}
					else
						Debug.MSG("not a rightful tf");
				}
			}
		}
		
		var resetScheduled = false;
		
		for ( h in hunters) {
			
			var fdData = data.hunters.find( function(datah) return datah.id == h.data.id );
			if ( fdData == null ){
				var tgt = h.mc.getChildAt(0);
				var colTrans = new flash.geom.ColorTransform();
				colTrans.blueMultiplier = -1;
				colTrans.redOffset = 255;
		
				var vfx = new mt.fx.Shake(h.mc, 6, 6);
				tgt.transform.colorTransform = colTrans;
				var vfx = new TweenEx.VanishEx(h.mc, 25, 25, true);
				
				var oe = function()
				{
					fade = false;
					resetAll();
				};
				vfx.onFinish = oe;
				
			}
			else
				h.data = fdData;
		}
		
		for (x in data.turrets )
		{
			var t = turrets.get( x.id );
			var tf : flash.text.TextField = cast t.mc.getChildByName( "turret" );
			
			var tch = Std.string(x.charges);
			if ( tch != tf.text ) {
				new RedSeq( tf );
			}
			tf.text = tch;
		}
		
		for (x in data.patrolShips )
		{
			var t = patrols.get( x.id );
			var tf : flash.text.TextField = cast t.mc.getChildByName( "patrol" );
			
			var tch = Std.string(x.charges);
			if ( tch != tf.text ) {
				new RedSeq( tf );
			}
			tf.text = tch;
		}
	}
	
	public function addHunters()
	{
		var data = Main.actServerData;
		if (data == null) return;
		
		var ah = [];
		var ht = 0;
		var finHunter = function(mc:Sprite, coo, data:FlashView_Hunter)
		{
			mc.x = coo.x; mc.y = coo.y;
			
			if ( fade)
			{
				haxe.Timer.delay( function()
				{
					mc.alpha = 1;
					new mt.fx.Spawn( mc, 0.05 );
				}, ht * 100);
				
				mc.alpha = 0;
			}
			
			var d = { data:data, mc:mc };
			hunters.set( data.id,d);
			addChild( d.mc );
			ht++;
		}
		
		var tot = 0;
		var finGood = function(mc:Sprite, coo, ?dataTur:FlashView_Turret,?dataPat:FlashView_PatrolShip)
		{
			mc.x = coo.x; mc.y = coo.y;
			if ( fade)
			{
				haxe.Timer.delay( function()
				{
					mc.alpha = 1;
					new mt.fx.Spawn( mc, 0.05 );
				}, tot * 100);
				
				mc.alpha = 0;
			}
			if ( dataTur != null)
				turrets.set( dataTur.id, { data:dataTur, mc:mc } );
			if ( dataPat != null)
				patrols.set( dataPat.id, { data:dataPat, mc:mc } );
				
			
			addChild( mc );
			
			tot++;
		}
		
		
		var h = 0;
		var dh = [];
		var odh = data.hunters.list();
		for ( t in Protocol.shipStatsList) {
			for( d in odh){
				if ( t.id.index() == d.type ) {
					dh.pushBack( d );
					odh.remove( d );
					break;
				}
			}
		}
		for (d in odh ) dh.pushBack( d );
		
		for (x in dh)
		{
			if ( h > HUNT_PER_COL * 2 ) break;
			finHunter( createHunterFrame( x ), getHunterCoords( ht ), x );
			h++;
		}
		
		for ( t in Protocol.shipStatsList ){
			for ( h in ah ){
				if ( h.data.type == t.id.index() ) {
					addChild( h.mc );
					ah.remove( h );
					break;
				}
			}
			
		}
		
		
		for ( h in ah)
			addChild( h.mc );
		
		for (x in data.turrets)
			finGood( createTurretFrame( x, x.pilot == data.me.id ), getGoodItemsCoords( tot ),x );
		
		for (x in data.patrolShips)
			finGood( createPatrolFrame( x, x.pilot == data.me.id ), getGoodItemsCoords( tot ),x );
	}
	
	
	public function addRdHunters()
	{
		for ( i in 0...10)
		{
			var mc = createHunterFrame( rdHunter() );
			var coo = getHunterCoords( i );
			
			mc.x = coo.x; mc.y = coo.y;
			
			haxe.Timer.delay( function()
			{
				mc.alpha = 1;
				new mt.fx.Spawn( mc, 0.05 );
			}, i * 100);
			
			mc.alpha = 0;
			addChild( mc );
		}
		
		var tot = 0;
		for ( i in 0...6)
		{
			var mc = createTurretFrame( rdTurret(),false );
			var coo = getGoodItemsCoords( tot );
			
			mc.x = coo.x; mc.y = coo.y;
			
			haxe.Timer.delay( function()
			{
				mc.alpha = 1;
				new mt.fx.Spawn( mc, 0.05 );
			}, tot * 100);
			
			mc.alpha = 0;
			addChild( mc );
			tot++;
		}
		
		for ( i in 0...8)
		{
			var mc = createPatrolFrame( rdPatrol(),false);
			var coo = getGoodItemsCoords( tot );
			
			mc.x = coo.x; mc.y = coo.y;
			
			haxe.Timer.delay( function()
			{
				mc.alpha = 1;
				new mt.fx.Spawn( mc, 0.05 );
			}, tot * 100);
			
			mc.alpha = 0;
			addChild( mc );
			tot++;
		}
	}
	
	public static var HUNT_PER_COL = 8;
	public static var GOOD_PER_COL = 6;
	public function getHunterCoords(i) : V2D
	{
		var h, w;
		
		
		var row = i % HUNT_PER_COL;
		var col = Std.int( 1 + i / HUNT_PER_COL);
		
		h = row *  HUNT_FRAME.h + 2 * row;
		w = Std.int( Window.W() - ( col * HUNT_FRAME.w) - 2 * col);
		
		return new V2D(w, h + OFS_TOP);
	}
	
	public function getGoodItemsCoords(i) : V2D
	{
		var h, w;
		
		var row = i % GOOD_PER_COL;
		var col = Std.int( i / GOOD_PER_COL);
		
		h = row *  TURRET_FRAME.h + 2 * row;
		w = ( col * TURRET_FRAME.w) + 2 * col;
		
		return new V2D(w + OFS_SIDE, h + OFS_TOP);
	}

	
	public function getTargetGlow()
	{
		var gl = new flash.filters.GlowFilter(0xFF0000);
		gl.blurX = gl.blurY = 10.0;
		return gl;
	}
	public function createHunterFrame( data : FlashView_Hunter , inner_col:Int=FRAME_COL_INNER, outer_col:Int=FRAME_COL_OUTER ) : MovieClip
	{
		var mc = new MovieClip();
		var stdata = Protocol.shipStatsDb(ShipStatsId.createI(data.type));
		
		function mover(_)
		{
			var actData = hunters.get( data.id );
			Main.gui.showTip( stdata.name +"\r\n" + stdata.footnotes
			.split("$c").join(Std.string(data.charges))
			.split("$dmg").join(Std.string((actData!=null ?actData.data:data).hp)),true );
		}
		
		function mocl(_)
		{
			if (target != null) target.mc.filters = [];

			target = {mc:mc, data:data};
			
			mc.filters = [getTargetGlow()];
			mc.toFront();
			
			if( !IsoConst.EDITOR)
				tools.Codec.load( "/st", data.id, function(_) { } );
		}
		
		function mout(_)
		{
			Main.gui.hideTip();
		}
		
		mc.addEventListener( MouseEvent.MOUSE_OVER, mover);
		mc.addEventListener( MouseEvent.MOUSE_OUT, mout);
		mc.addEventListener( MouseEvent.MOUSE_DOWN, mocl);
		
		var corner = 5;
		
		var ns = new flash.display.MovieClip();
		ns.graphics.beginFill( inner_col );
		ns.graphics.lineStyle( 0.5, outer_col );
		
		ns.graphics.moveTo( 0, corner);
		ns.graphics.lineTo( corner, 0);
		ns.graphics.lineTo( HUNT_FRAME.w, 0);
		ns.graphics.lineTo( HUNT_FRAME.w, HUNT_FRAME.h);
		ns.graphics.lineTo( 0, HUNT_FRAME.h);
		ns.graphics.lineTo( 0, corner);
		ns.graphics.endFill();
		
		mc.addChild( ns );
		
		var eid = ShipStatsId.createI(data.type);
		
		//GYHYM HERE
		var s = 1.0;
		var fr =
		switch( eid )
		{
			case HUNTER: 		"FX_SPC_SMALL_HUNTER";
			case SPIDER: 		"FX_SPC_SMALL_SPIDER";
			case ASTEROID: 	 	"FX_SPC_SMALL_ASTEROID";
			case DICE: 			"FX_SPC_SMALL_DICE";
			case TRAX: 			"FX_SPC_SMALL_TRAX";
			case TRANSPORT:		"FX_TRANSPORT_SMALL_"+data.subtype %4;
			
			default: throw "unsupported hunter";
		};
		
		var te = Data.fromScratch( Data.mkSetup( fr ) );
		mc.addChild( te.el );
		
		te.el.scaleX = te.el.scaleY = s;
		te.el.x = 20;
		te.el.y = 16;
		
		var tf = As3Tools.tf( Std.string( data.hp ), 0xFFffFF, "nokia");
		mc.addChild( tf );
		
		tf.x = 12;
		tf.y = 28;
		if (data.hp > 10)
			tf.x -= 4;
		
		var te = Data.fromScratch( Data.mkSetup( "FX_SPC_SHIELD" ) );
		mc.addChild( te.el );
		
		mc.mouseEnabled = false;
		
		te.el.x = 28;
		te.el.y = 34;
		return mc;
	}
	
	public function createTurretFrame(  data : FlashView_Turret , isSelf : Bool ) : MovieClip
	{
		var mc = new MovieClip();
		
		mc.graphics.beginFill( !isSelf?FRAME_COL_INNER:FRAME_COL_INNER_SELF );
		mc.graphics.lineStyle( 0.5, !isSelf?FRAME_COL_OUTER:FRAME_COL_OUTER_SELF );
		
		//mc.graphics.drawRect( 0, 0, TURRET_FRAME.w, TURRET_FRAME.h );
		var corner = 5;
		mc.graphics.lineTo( TURRET_FRAME.w - corner, 0 );
		mc.graphics.lineTo( TURRET_FRAME.w , corner );
		mc.graphics.lineTo( TURRET_FRAME.w , TURRET_FRAME.h );
		mc.graphics.lineTo( 0 , TURRET_FRAME.h );
		mc.graphics.lineTo( 0 , 0 );
		
		mc.graphics.endFill();
			
		var te = Data.fromScratch( Data.mkSetup( "FX_SPC_SMALL_TURRET" ) );
		mc.addChild( te.el );
		
		te.el.x = 44;
		te.el.y = 20;
		
		var tf = As3Tools.tf( Std.string( data.charges ), 0xFFffFF, "nokia");
		
		tf.assert("tf error");
		tf.name = "turret";
		mc.addChild( tf );
		
		tf.x = 32;
		tf.y = 32;
		
		var te = Data.fromScratch( Data.mkSetup( "FX_SPC_CHARGE" ) );
		mc.addChild( te.el );
		mc.mouseEnabled = false;
		te.el.x = 48;
		te.el.y = 38;
		
		var hData = Main.serverHeroData(data.pilot);
		
		if( data.pilot == null ) addAnonPilot( mc );
		else addPilot( mc, data.pilot );
		
		return mc;
	}
	
	public function addAnonPilot(mc : Sprite)
	{
		var sub = Data.fromScratch( Data.mkSetup( "FX_ANON_CHAR" ) );
		sub.el.x = 13;
		sub.el.y = 24;
		mc.addChild( sub.el );
	}
	
	public function addPilot(mc : Sprite, hid : HeroId )
	{
		var sub = Data.fromScratch( Data.mkSetup( HumanNPC.getFrame( hid )) );
		sub.el.x = 14;
		sub.el.y = 25;
		mc.addChild( sub.el );
	}
	
	public function createPatrolFrame( data: FlashView_PatrolShip , isSelf : Bool ) : Sprite
	{
		var mc = new Sprite();
		
		mc.graphics.beginFill( FRAME_COL_INNER );
		mc.graphics.lineStyle( 0.5, FRAME_COL_OUTER );
		var corner = 5;
		mc.graphics.lineTo( TURRET_FRAME.w - corner, 0 );
		mc.graphics.lineTo( TURRET_FRAME.w , corner );
		mc.graphics.lineTo( TURRET_FRAME.w , TURRET_FRAME.h );
		mc.graphics.lineTo( 0 , TURRET_FRAME.h );
		mc.graphics.lineTo( 0 , 0 );
		mc.graphics.endFill();
		
		mc.mouseEnabled = false;
			
		var te = Data.fromScratch( Data.mkSetup( "FX_SPC_SMALL_PATROL" ) );
		mc.addChild( te.el );
		
		te.el.x = 43;
		te.el.y = 18;
		
		var tf = As3Tools.tf( Std.string(  data.hp ), 0xFFffFF, "nokia");
		mc.addChild( tf );
		
		tf.x = 25;
		tf.y = 32;
		
		var te = Data.fromScratch( Data.mkSetup( "FX_SPC_SHIELD" ) );
		mc.addChild( te.el );
		
		te.el.x = 41;
		te.el.y = 38;
		
		var tf = As3Tools.tf( Std.string( data.charges ), 0xFFffFF, "nokia");
		tf.name = "patrol";
		mc.addChild( tf );
		
		tf.x = 46;
		tf.y = 32;
		
		var te = Data.fromScratch( Data.mkSetup( "FX_SPC_CHARGE" ) );
		mc.addChild( te.el );
		
		te.el.x = 62;
		te.el.y = 38;
	
		var hData = Main.serverHeroData(data.pilot);
		
		if( data.pilot == null ) addAnonPilot( mc );
		else addPilot( mc, data.pilot);
		
		return mc;
	}
		
	public function update()
	{
		
	}
}