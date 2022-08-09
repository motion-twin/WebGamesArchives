package mt.heaps;

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
	public static var ALL : Array<GamePad> = [];
	public static var AVAILABLE_DEVICES : Array<hxd.Pad>;
	
	static var MAPPINGS = [
		{
			ids : ["xbox","x-box"],
			map : [
				AXIS_LEFT_X => 0,
				AXIS_LEFT_X_NEG => 0,
				AXIS_LEFT_X_POS => 0,
				AXIS_LEFT_Y => 1,
				AXIS_LEFT_Y_NEG => 1,
				AXIS_LEFT_Y_POS => 1,
				AXIS_RIGHT_X => 2,
				AXIS_RIGHT_Y => 3,
				A => 4,
				B => 5,
				X => 6,
				Y => 7,
				LB => 8,
				RB => 9,
				LT => 10,
				RT => 11,
				SELECT => 12,
				START => 13,
				LSTICK => 14,
				RSTICK => 15,
				DPAD_UP => 16,
				DPAD_DOWN => 17,
				DPAD_LEFT => 18,
				DPAD_RIGHT => 19,
			],
		}
	];

	var device				: Null<hxd.Pad>;
	var toggles				: Array<Int>;
	var mapping				: haxe.ds.Vector<Int>;
	
	//var inverts				: Map<String,Bool>;
	public var deadZone		: Float = 0.18;
	public var lastActivity(default,null) : Float;

	public function new(?deadZone:Float, ?onEnable:GamePad->Void) {
		ALL.push(this);
		toggles = [];
		mapping = new haxe.ds.Vector( Type.getEnumConstructs(PadKey).length );
		for( i in 0...mapping.length ) mapping[i] = -1;

		if( deadZone!=null )
			this.deadZone = deadZone;

		if( onEnable!=null )
			this.onEnable = onEnable;

		if( AVAILABLE_DEVICES==null ){
			AVAILABLE_DEVICES = [];
			hxd.Pad.wait( onDevice );
		}
		
		lastActivity = haxe.Timer.stamp();
	}

	public dynamic function onEnable(pad:GamePad) {}
	public dynamic function onDisable(pad:GamePad) {}
	public inline function isEnabled() return device!=null;

	public inline function toString() return "GamePad("+getDeviceId()+")";
	public inline function getDeviceName() : Null<String> return device==null ? null : device.name;
	public inline function getDeviceId() : Null<Int> return device==null ? null : device.index;

	function enableDevice( p : hxd.Pad ) {
		if( device==null ) {
			AVAILABLE_DEVICES.remove( p );
			p.onDisconnect = function(){
				disable();
			}
			for( i in 0...mapping.length ) mapping[i] = -1;
			var pname = p.name.toLowerCase();
			for( m in MAPPINGS ){
				for( id in m.ids ){
					if( pname.indexOf(id) > -1 ){
						for( k in m.map.keys() ){
							mapping[ Type.enumIndex(k) ] = m.map[k];
						}
						break;
					}
				}
			}
			device = p;
			onEnable( this );
		}
	}

	function disable() {
		if( device!=null ) {
			device = null;
			onDisable(this);
		}
	}

	function onDevice( p : hxd.Pad ) {
		for( i in ALL ){
			if( i.device == null ){
				i.enableDevice( p );
				return;
			}
		}
		
		AVAILABLE_DEVICES.push( p );
		p.onDisconnect = function() AVAILABLE_DEVICES.remove( p );
	}

	public function dispose() {
		ALL.remove(this);
		if( device != null )
			onDevice( device );
		device = null;
	}
	
	inline function getControlValue(idx:Int, simplified:Bool) : Float {
		var v = idx > -1 && idx<device.values.length ? device.values[idx] : 0;
		//if( inverts.get(cid)==true )
		//	v*=-1;

		if( simplified )
			return v<-deadZone?-1 : (v>deadZone?1 : 0);
		else
			return v>-deadZone && v<deadZone ? 0 : v;
	}

	public inline function getValue(k:PadKey, ?simplified=false) : Float {
		return isEnabled() ? getControlValue( mapping[Type.enumIndex(k)], simplified ) : 0.;
	}

	public inline function isDown(k:PadKey) {
		switch( k ) {
			case AXIS_LEFT_X_NEG, AXIS_LEFT_Y_NEG : return getValue(k,true)<0;
			case AXIS_LEFT_X_POS, AXIS_LEFT_Y_POS : return getValue(k,true)>0;
			default : return getValue(k,true)!=0;
		}
	}

	public /*inline */function isPressed(k:PadKey) {
		var idx = mapping[Type.enumIndex(k)];
		var t = isEnabled() && idx>-1 && idx<device.values.length ? toggles[idx] : 0;
		return (t==1 || t==2) && isDown(k);
	}

	public static function update() {
		for(e in ALL){
			var hasToggle = false;
			if( e.device!=null ){
				for(i in 0...e.device.values.length) {
					if( MLib.fabs( e.device.values[i] ) > e.deadZone ){
						hasToggle = true;
						if ( e.toggles[i] >= 2 )
							e.toggles[i] = 3;
						else
							e.toggles[i] = 2;
					}else{
						e.toggles[i] = 0;
					}
				}
			}
			if( hasToggle )
				e.lastActivity = haxe.Timer.stamp();
		}
	}
}
