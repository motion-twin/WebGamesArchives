package mt.flash;

import flash.ui.GameInput;
import flash.ui.GameInputControl;
import flash.ui.GameInputDevice;
import mt.MLib;

#if !flash11_9
#error "Flash 11.9+ is required to use GamePad"
#end

/* Useful ressource:
 * https://docs.google.com/spreadsheet/ccc?key=0AkkprH0hOE5cdGpmeDVTVFQ5M0syOGdXZ0xjVDJkSnc&usp=sharing#gid=1
 * (also available in MT google drive: /projets/tech )
 */

enum PadKey {
	A;
	B;
	X;
	Y;
	SELECT;
	START;
	LT;
	RT;
	LB;
	RB;
	LSTICK;
	RSTICK;
	DPAD_UP;
	DPAD_DOWN;
	DPAD_LEFT;
	DPAD_RIGHT;
	AXIS_LEFT_X;
	AXIS_LEFT_X_NEG;
	AXIS_LEFT_X_POS;
	AXIS_LEFT_Y;
	AXIS_LEFT_Y_NEG;
	AXIS_LEFT_Y_POS;
	AXIS_RIGHT_X;
	AXIS_RIGHT_Y;
}

class GamePad {
	// Known bindings:  https://docs.google.com/spreadsheets/d/1Q7e-I7vTtTeXWHPO8tHuXfyPCzilAVy4bY7kX8q2Ygo
	static var MAPPINGS = [
		{
			ids : ["xbox","x-box"],
			map : [
				LT => "BUTTON_10",
				RT => "BUTTON_11",
				LB => "BUTTON_8",
				RB => "BUTTON_9",
				SELECT => "BUTTON_12",
				START => "BUTTON_13",
				LSTICK => "BUTTON_14",
				DPAD_UP => "BUTTON_16",
				DPAD_DOWN => "BUTTON_17",
				DPAD_LEFT => "BUTTON_18",
				DPAD_RIGHT => "BUTTON_19",
				RSTICK => "BUTTON_15",
				AXIS_RIGHT_X => "AXIS_2",
				AXIS_RIGHT_Y => "AXIS_3",
			],
			uaInverts : [
				"chrome" => [AXIS_LEFT_Y],
			]
		},
		// TODO: add more support here :)
	];

	public static var ALL : Array<GamePad> = [];

	var device				: Null<GameInputDevice>;
	var ginput				: GameInput;
	var controls			: Map<String,GameInputControl>;
	var controlIds          : haxe.ds.Vector<String>;
	var toggles				: Map<String,Int>;
	var buttonIndexes		: Array<String>;
	var inverts				: Map<String,Bool>;
	public var deadZone		: Float = 0.18;
	public var lastActivity(default,null) : Float;

	var mapping				: Map<Int,String>;

	public function new(?deadZone:Float, ?onEnable:GamePad->Void) {
		ALL.push(this);
		toggles = new Map();
		controls = new Map();
		inverts = new Map();
		mapping = new Map();
		buttonIndexes = [];
		lastActivity = haxe.Timer.stamp();

		if( deadZone!=null )
			this.deadZone = deadZone;

		if( onEnable!=null )
			this.onEnable = onEnable;

		ginput = new flash.ui.GameInput();
		ginput.addEventListener(flash.events.GameInputEvent.DEVICE_ADDED, onDeviceAdded);
		ginput.addEventListener(flash.events.GameInputEvent.DEVICE_REMOVED, onDeviceRemoved);
		ginput.addEventListener(flash.events.GameInputEvent.DEVICE_UNUSABLE, onDeviceUnusable);
		for( i in 0...flash.ui.GameInput.numDevices )
			onDeviceAdded( new flash.events.GameInputEvent(flash.events.GameInputEvent.DEVICE_ADDED,false,false,flash.ui.GameInput.getDeviceAt(i)) );
	}

	public inline function getAllControls() {
		var c = Lambda.array(controls);
		c.sort( function(a,b) return Reflect.compare(a.id, b.id) );
		return c;
	}

	public function controlIdToPadKey(id:String) : Null<PadKey> {
		for(k in mapping.keys())
			if( mapping.get(k)==id )
				return Type.createEnumIndex(PadKey, k);
		return null;
	}

	public dynamic function onEnable(pad:GamePad) {}
	public dynamic function onDisable(pad:GamePad) {}
	public dynamic function onAnyControl() {}
	public inline function isEnabled() return device!=null;

	public inline function toString() return "GamePad("+getDeviceId()+")";
	public inline function getDeviceName() : Null<String> return device==null ? null : device.name;
	public inline function getDeviceId() : Null<String> return device==null ? null : device.id;

	function enable(id:String) {
		if( device==null ) {
			for(i in 0...GameInput.numDevices)
				if( GameInput.getDeviceAt(i).id==id ) {
					device = GameInput.getDeviceAt(i);
					break;
				}
			if( device!=null ) {
				device.enabled = true;
				init();
				#if debug
				trace(this+" ready!");
				#end
				onEnable(this);
			}
		}
	}

	function disable() {
		if( device!=null ) {
			for(c in controls)
				c.removeEventListener(flash.events.Event.CHANGE, onControlChange);
			toggles = new Map();
			controls = new Map();
			device = null;
			#if debug
			trace(this+" has been disabled.");
			#end
			onDisable(this);
		}
	}


	function onControlChange(e:flash.events.Event) {
		var cid : String = e.target;
		if( isControlDown(cid) && !toggles.exists(cid) )
			toggles.set(cid, 1);

		onAnyControl();
	}


	public function listControls() : Array<String> {
		var all = [];
		for(i in 0...device.numControls)
			all.push( device.getControlAt(i).id );
		return all;
	}

	inline function setMapping(k:PadKey, id:String) mapping.set(k.getIndex(), id);
	inline function getMapping(k:PadKey) return mapping.get(k.getIndex());
	inline function hasMapping(k:PadKey) return mapping.exists(k.getIndex());

	function init() {
		for(c in controls)
			c.removeEventListener(flash.events.Event.CHANGE, onControlChange);

		toggles = new Map();
		controls = new Map();
		inverts = new Map();
		mapping = new Map();
		buttonIndexes = [];
		controlIds = new haxe.ds.Vector(device.numControls);
		for(i in 0...device.numControls) {
			var c = device.getControlAt(i);
			controlIds[i] = c.id;
			controls.set(c.id, c);
			c.addEventListener(flash.events.Event.CHANGE, onControlChange);
			if( c.id.indexOf("BUTTON_")>=0 )
				buttonIndexes.push(c.id);
		}
		buttonIndexes.sort( function(a,b) {
			return Reflect.compare(Std.parseInt(a.split("_")[1]), Std.parseInt(b.split("_")[1]));
		});

		setMapping(A, buttonIndexes[0]);
		setMapping(B, buttonIndexes[1]);
		setMapping(X, buttonIndexes[2]);
		setMapping(Y, buttonIndexes[3]);

		setMapping(AXIS_LEFT_X,     "AXIS_0");
		setMapping(AXIS_LEFT_X_NEG, "AXIS_0");
		setMapping(AXIS_LEFT_X_POS, "AXIS_0");

		setMapping(AXIS_LEFT_Y,     "AXIS_1");
		setMapping(AXIS_LEFT_Y_NEG, "AXIS_1");
		setMapping(AXIS_LEFT_Y_POS, "AXIS_1");

		var n = device.name.toLowerCase();
		var ua = mt.deepnight.Lib.getUserAgent();
		function is(s:String) return n.indexOf(s)>=0;

		for(m in MAPPINGS) {
			for( id in m.ids )
				if( n.indexOf(id)>=0 ) {
					for( k in m.map.keys() )
						setMapping(k, m.map.get(k));

					for( k in m.uaInverts.keys() )
						if( ua==k )
							for( k in m.uaInverts.get(k) )
								enableInvert(k);
					break;
				}
		}
	}

	public function enableInvert(k:PadKey)   inverts.set(getMapping(k), true);
	public function disableInvert(k:PadKey)  inverts.remove(getMapping(k));
	public function toggleInvert(k:PadKey) {
		if( inverts.exists(getMapping(k)) ) {
			disableInvert(k);
			return false;
		}
		else {
			enableInvert(k);
			return true;
		}
	}

	function onDeviceAdded(e:flash.events.GameInputEvent) {
		if( device==null || e.device.id==device.id ) {
			for(c in ALL)
				if( c.device!=null && c.device.id==e.device.id )
					return;

			enable(e.device.id);
		}
	}

	function onDeviceRemoved(e:flash.events.GameInputEvent) {
		if( device!=null && e.device.id==device.id )
			disable();
	}

	function onDeviceUnusable(e:flash.events.GameInputEvent) {
		if( device.id==e.device.id ) {
			#if debug
			trace(this+" unusable: "+e.type);
			#end
			disable();
		}
	}

	public static inline function countAllocated() return ALL.length;
	public static inline function countTotal() return GameInput.numDevices;

	public function dispose() {
		for(c in controls)
			c.removeEventListener(flash.events.Event.CHANGE, onControlChange);
		controls = null;

		ginput.removeEventListener(flash.events.GameInputEvent.DEVICE_ADDED, onDeviceAdded);
		ginput.removeEventListener(flash.events.GameInputEvent.DEVICE_REMOVED, onDeviceRemoved);
		ginput.removeEventListener(flash.events.GameInputEvent.DEVICE_UNUSABLE, onDeviceUnusable);
		ginput = null;
		device = null;

		toggles = null;
		buttonIndexes = null;

		ALL.remove(this);
	}

	inline function hasControl(cid:String) return controls.exists(cid);
	inline function getControl(cid:String) return controls.get(cid);

	inline function getControlValue(cid:String, simplified:Bool) : Float {
		var v = isEnabled() && hasControl(cid) ? getControl(cid).value : 0;
		if( inverts.get(cid)==true )
			v*=-1;

		if( simplified )
			return v<-deadZone?-1 : (v>deadZone?1 : 0);
		else
			return v>-deadZone && v<deadZone ? 0 : v;
	}

	inline function isControlDown(cid:String) {
		return MLib.fabs( getControlValue(cid,true) ) > deadZone;
	}

	inline function isControlPressed(cid:String) {
		return toggles.get(cid)==1 || toggles.get(cid)==2;
	}


	public inline function getValue(k:PadKey, ?simplified=false) : Float {
		return hasMapping(k) ? getControlValue( getMapping(k), simplified ) : 0;
	}

	public inline function isDown(k:PadKey) {
		switch( k ) {
			case AXIS_LEFT_X_NEG, AXIS_LEFT_Y_NEG :
				return hasMapping(k) ? getValue(k,true)<0 : false;

			case AXIS_LEFT_X_POS, AXIS_LEFT_Y_POS :
				return hasMapping(k) ? getValue(k,true)>0 : false;

			default :
				return hasMapping(k) ? isControlDown( getMapping(k) ) : false;
		}
	}

	public inline function isPressed(k:PadKey) {
		switch( k ) {
			case AXIS_LEFT_X_NEG, AXIS_LEFT_Y_NEG :
				return hasMapping(k) ? getValue(k,true)<0 && isControlPressed(getMapping(k)) : false;

			case AXIS_LEFT_X_POS, AXIS_LEFT_Y_POS :
				return hasMapping(k) ? getValue(k,true)>0 && isControlPressed(getMapping(k)) : false;

			default :
				return hasMapping(k) ? isControlPressed( getMapping(k) ) : false;
		}
	}

	public static function update() {
		for(e in ALL){
			var hasToggle = false;
			if( e.device!=null ){
				for(i in 0...e.device.numControls) {
					var c = e.device.getControlAt(i);
					var cid = e.controlIds[i];
					if( MLib.fabs( c.value ) > e.deadZone ){
						hasToggle = true;
						if ( e.toggles.get(cid) >= 2 )
							e.toggles.set(cid,3);
						else
							e.toggles.set(cid,2);
					}else{
						e.toggles.remove(cid);
					}
				}
			}
			if( hasToggle )
				e.lastActivity = haxe.Timer.stamp();
		}


	}
}
