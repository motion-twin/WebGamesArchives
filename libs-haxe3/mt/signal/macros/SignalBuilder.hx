package mt.signal.macros;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;

class SignalBuilder
{
	static function verifyPathInheritance( p : ComplexType, superClassName:String ) : Bool
	{
		switch( p ) 
		{
			case TPath(p) :
				var className = p.pack.join('.') + (p.pack.length > 0?'.':'') + p.name;
				switch(haxe.macro.Context.getType(className) ) 
				{
					case TInst(t, params):
						while ( t != null )
						{
							if( t.toString() == superClassName ) return true;
							if( t.get().superClass == null ) break;
							t = t.get().superClass.t;
						}
					case TType(ref, params):
						var t = ref.get();
						return t.pack.join(".")+"."+t.name == superClassName;
					default :
				}
			default :
		}
		return false;
	}
	
	macro public static function build():Array<Field> 
	{
		var BASE_AS3_EVENT = "flash.events.Event";
		var BASE_AS3_DISPATCHER = "flash.events.EventDispatcher";
		var BASE_SIGNAL = "mt.signal.Signal";
		
        var pos = haxe.macro.Context.currentPos();
		
        var tstring = macro : String;
		var tvoid = macro : Void;
		var thash = macro : Map<String, Array<Dynamic>>;
		var tbond = macro : mt.signal.Signal;
		var inherit : Bool = false;
		
		var fields = haxe.macro.Context.getBuildFields();
		
		var sigFields = [];
		for( field in fields )
		{
			if( field.meta == null ) continue;
			for( meta in field.meta )
			{
				if( meta.name == ":signal" )
				{
					sigFields.push( {field:field, meta:meta, access:field.access} );
				}
				else if( meta.name == ":as3signal" )
				{
					var msg = "as3signal meta should have 2 parameters : (EventName:String , container:"+BASE_AS3_DISPATCHER+")";
					if( meta.params.length != 2 ) haxe.macro.Context.error(msg+" missing argument", pos);
					sigFields.push( {field:field, meta:meta, access:field.access} );
				}
			}
		}

		for( field in sigFields )
		{
			var meta = field.meta;
			var name = field.field.name;
			var prefix = "";
			var id = 0;
			while( !mt.StringEx.isAlpha(name.charAt(id)) ) id++;
			if( id > 0 )
				prefix = name.substr(0, id);
			name = name.charAt(id).toUpperCase() + name.substr(id + 1);
			
			switch( field.field.kind )
			{
			case FFun( f ):
				var as3Signal = meta.name == ":as3signal";
				var ename = { expr : EConst(CString(name)), pos : pos };
				var evname = if( meta.params.length > 0 ) meta.params[0] else macro null;
				var eclip = if( meta.params.length > 1 ) meta.params[1] else macro null;
				var eas3signal = { expr : EConst(CIdent(as3Signal ? "true" : "false")), pos:pos };
				// checks
				ename = { expr : ECheckType(ename, macro : String), pos : ename.pos };
				eclip = { expr : ECheckType(eclip, macro : flash.display.DisplayObject), pos : eclip.pos };
				
				{ // Bind function
					var argTypes = [];
					var fbody;
					if ( as3Signal ) 
					{
						if( eclip == null ) Context.error(":as3signal requires a valid DisplayObject as 2nd argument", pos);
						var callArgs = [];
						var eArgSignal = { expr : EConst( CIdent( "bond") ), pos : pos }
						var eArgEvent = { expr : EConst( CIdent( "e") ), pos : pos }
						for( arg in f.args )
						{
							if ( verifyPathInheritance( arg.type, BASE_SIGNAL) ) 
							{
								argTypes.push( arg.type );
								callArgs.push( eArgSignal );
							}
							else if( verifyPathInheritance( arg.type, BASE_AS3_EVENT ) )
							{
								argTypes.push( arg.type );
								callArgs.push(eArgEvent);
							}
							else
								Context.error("argument is invalid. Muse be of type " + BASE_SIGNAL + " or null", pos);
						}

						var eListener = { expr: EConst(CIdent("listener")), pos:pos };
						var eCall = { expr : ECall( eListener , callArgs ), pos : pos };
						
						fbody = macro  {
							var listenersHash = signaler_getListenersHash();
							var listeners = listenersHash.get($ename);
							if ( listeners == null ) 
							{
								listeners = [];
								listenersHash.set($ename, listeners );
							}
							
							var bond : mt.signal.Signal = cast { autoDispose : false, listener : listener };
							bond.call = function(e) 
							{
								if( bond.autoDispose ) bond.destroy();
								bond.info = e;
								$eCall;
							};
							
							bond.destroy = function():Void 
							{
								for ( b in listeners )
								{
									if ( b == bond ) 
									{
										listeners.remove(b);
										($eclip).removeEventListener( $evname, bond.call );
									}
								}
							}
							
							bond.disposeAfterDispatch = function()
							{
								bond.autoDispose = true;
							};
							
							if ( $eclip.stage != null )
							{
								$eclip.addEventListener( $evname, bond.call );
							} 
							else
							{
								function readyToListen(?e) 
								{
									$eclip.removeEventListener( flash.events.Event.ADDED_TO_STAGE, readyToListen );
									if ( listeners.remove(bond) ) 
									{
										$eclip.addEventListener( $evname, bond.call );
										listeners.push(bond);
									}
									
								}
								$eclip.addEventListener( flash.events.Event.ADDED_TO_STAGE, readyToListen );
							}
							listeners.push(bond);
							
							return bond;
						}
					} 
					else 
					{
						for( arg in f.args )
							argTypes.push( arg.type );
								
						fbody =  macro {
							var listenersHash = signaler_getListenersHash();
							var listeners = listenersHash.get($ename);
							if ( listeners == null ) 
							{
								listeners = [];
								listenersHash.set($ename, listeners );
							}
							var bond = cast 
							{
								autoDispose : false,
								info : null,
								listener : listener,
								call: cast listener,
							};
							bond.destroy = function():Void
							{
								for ( b in listeners ) 
								{
									if ( b == bond )
									{
										listeners.remove(b);
									}
								}
							}
							bond.disposeAfterDispatch = function() { bond.autoDispose = true; }
							listeners.push(bond);
							return bond;
						}
					}
					
					var farg : FunctionArg = { name : "listener", opt : false, type : TFunction( argTypes, tvoid ), value : null };
					fields.push( { name:prefix+"bind" + name, access:field.access, kind:FFun( { args: [farg], ret:tbond, expr:fbody, params:[]} ), pos:pos } );
				}
				
				{ // Dispatch function
					var fargs = [];
					var sbody = "{" +
						"var listenersHash = signaler_getListenersHash();"+
						"if( listenersHash == null ) return;"+
						"var list = listenersHash.get( \"" + name + "\");" +
						"if( list == null ) return;" +
						"for( listener in list ) { " +
						"	listener.call(";
					
					for( i in 0...f.args.length )
					{
						var fa = f.args[i];
						if( verifyPathInheritance( fa.type, BASE_SIGNAL) )
						{
							sbody += "listener";
						}
						else
						{
							sbody += fa.name;
							fargs.push ( { name : fa.name, opt : false, type : fa.type, value : null } );
						}
						sbody += if( i != f.args.length - 1 ) "," else "";
					}
					sbody += " ); " +
							"if( listener.autoDispose ) { listener.destroy(); }" +
							"}}";
					var fbody = Context.parse( sbody, pos );
					fields.push( { name:"dispatch" + name, access:field.access, kind:FFun( { args: fargs, ret:tvoid, expr:fbody, params:[] } ), pos:pos } );
				}
				
				{ // Unbind function
					var argTypes = [];
					for( arg in f.args ) argTypes.push( arg.type );
					var farg : FunctionArg = { name : "listener", opt : false, type : TFunction( argTypes, tvoid ), value : null };
					var fbody = macro {
						if( signaler_listenerHash == null ) return;
						var list = signaler_listenerHash.get($ename);
						if( list == null ) return;
						for( bond in list ) {
							if( bond.listener == listener ) {
								bond.destroy();
							}
						}
					}
					fields.push( { name : prefix + "unbind" + name, access:field.access, kind:FFun( { args : [ farg ], ret : tvoid, expr : fbody, params:[] } ), pos : pos } );
				}
				
				{ // Unbind all signals function
					var fbody = macro {
						if( signaler_listenerHash == null ) return;
						var list = signaler_listenerHash.get($ename);
						if( list == null ) return;
						for( bond in list )
							bond.destroy();
					}
					fields.push( { name : prefix+"unbindAll"+name, access:field.access, kind:FFun( {args : [], ret : tvoid, expr : fbody, params:[]} ), pos : pos } );
				}
			default:
					Context.error("Expression should be a function " + field.field, field.field.pos);
			}
		}

		for( field in sigFields )
			fields.remove(field.field);
		
		var t = Context.getLocalClass().get();
		while ( t.superClass != null && !inherit )
		{
			t = t.superClass.t.get();
			for( f in t.fields.get() )
				if( f.name == "signaler_listenerHash" )
					inherit = true;
		}

		if( !inherit )
		{
			fields.push( { name : "signaler_listenerHash", access:[APrivate], kind:FVar( thash ), pos : pos } );
			{
				var fbody = macro {
					if( signaler_listenerHash == null )
						signaler_listenerHash = new Map<String, Array<Dynamic>>();
					return signaler_listenerHash;
				};
				fields.push( { name : "signaler_getListenersHash", access:[APrivate], kind:FFun( { args : [], ret : thash, expr : fbody, params:[] } ), pos : pos } );
			}
			
			if( sigFields.length > 0 )
			{ // Unbind all functions
				var fbody = macro {
					if ( signaler_listenerHash != null ) 
					{
						for ( signals in signaler_listenerHash )
						{
							for ( s in signals ) 
							{
								s.destroy();
							}
						}
						signaler_listenerHash = null;
					}
				}
				fields.push( { name:"unbindAll", access:[APublic, AInline], kind:FFun( { args : [], ret : tvoid, expr : fbody, params:[] } ), pos : pos } );
			}
		}
		
        return fields;
    }
}
#end