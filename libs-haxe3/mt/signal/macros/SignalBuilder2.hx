package mt.signal.macros;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.Tools;

/**
 * TODO:
	gérer les types du genre  Null<Int> etc...
 */
class SignalBuilder2
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
	
	static function resolveComplexType(t:ComplexType) { 
		function expr(e:ExprDef):Expr return { expr:e, pos: Context.currentPos() }; 
		return Context.typeof( 
			expr(EBlock([ 
					expr(EVars([ { name:'_', type: t, expr: null } ])), 
					expr(EConst(CIdent('_'))) 
			])) 
		); 
	} 
	
	macro public static function build():Array<Field> 
	{
		var printer = new haxe.macro.Printer();
		var pos = haxe.macro.Context.currentPos();
		var classFields = haxe.macro.Context.getBuildFields();
		var localClass = Context.getLocalClass().get();
		
		var sigFields = [];
		for( field in classFields )
		{
			if( field.meta == null ) continue;
			for( meta in field.meta )
			{
				if( meta.name == ":signal" )
				{
					sigFields.push( {field:field, meta:meta, access:field.access} );
				}
			}
		}
		
		for( field in sigFields )
			classFields.remove(field.field);
		
		for( field in sigFields )
		{
			var meta = field.meta;
			var fieldName = field.field.name;
			var prefix = "";
			var id = 0;
			while( !mt.StringEx.isAlpha(fieldName.charAt(id)) ) id++;
			if( id > 0 )
				prefix = fieldName.substr(0, id);
			fieldName = fieldName.charAt(id).toUpperCase() + fieldName.substr(id + 1);
			
			var tvoid = macro : Void;
			switch( field.field.kind )
			{
				case FVar( TFunction(types, retType), expr ):
					var listenerType = TFunction(types, retType);
					var fields = [];
					var args = [];
					for(i in 0...types.length) 
						args.push( macro $i{'p_arg${i}'} );
					//on remap les types pour avoir les path complets et éviter le soucis d'import
					for(i in 0...types.length) 
					{
						var t = resolveComplexType(types[i]);
						switch( t ) {
							case TType(path, params):
								var p = path.get(); 
								var path = p.name; 
								if ( p.pack.length > 0 ) 
									path = p.pack.join('.') + '.' + path; 
								types[i] = Context.toComplexType(Context.getType(path));
							case TEnum(path, params):
								var p = path.get();
								var path = p.name; 
								if ( p.pack.length > 0 ) 
									path = p.pack.join('.') + '.' + path; 
								types[i] = Context.toComplexType(Context.getType(path));
							default:
						}
					}
					
					var noArgs = false;
					if( types[0] != null ) {
						switch( types[0] ) {
							case TPath(p): noArgs = p.name == "Void";
							default:
						}
					}
					
					var dispatchExpr;
					if( noArgs ) {
						dispatchExpr = macro { 
							if( listeners == null ) return;
							for( listener in listeners) 
								listener();
						}
					} else {
						dispatchExpr = macro { 
							if ( listeners == null ) return;
							for ( listener in listeners) 
								listener($a { args } ); 
						}
					}
					var dispatchFun = FFun({ 
						params: [], 
						args: if( noArgs ) [] else [for (i in 0...types.length) { 
							opt: false, 
							name: 'p_arg${i}', 
							type: types[i], 
							value: null 
						}], 
						expr: dispatchExpr, 
						ret: macro:Void,
					}); 
					
					var dispatchDef = { 
						meta: [], 
						access: [APublic], 
						kind: dispatchFun, 
						name: "dispatch", 
						pos: Context.currentPos(),
						doc:null,
					};
					fields.push(dispatchDef);
					
					var bindFun = FFun({ 
						params: [],
						args: [{
							opt: false, 
							name: 'p_listener', 
							type: TFunction(types, retType), 
							value: null 
						}], 
						expr: macro { 
							if ( listeners == null ) listeners = [];
							listeners.push( p_listener );
						}, 
						ret: macro:Void,
					}); 
					
					var bindDef = { 
						meta: [], 
						access: [APublic], 
						kind: bindFun, 
						name: "bind", 
						pos: Context.currentPos(),
						doc:null,
					};
					fields.push(bindDef);
					
					var unbindFun = FFun({ 
						params: [],
						args: [{
							opt: false, 
							name: 'p_listener', 
							type: TFunction(types, retType), 
							value: null 
						}], 
						expr: macro { 
							if ( listeners != null ) {
								for( l in listeners )  {
									if ( Reflect.compareMethods(l, p_listener) ) { 
										listeners.remove(l); 
										return true; 
									}
								} 
							} 
							return false;
						}, 
						ret: macro:Bool,
					}); 
					
					var unbindDef = { 
						meta: [], 
						access: [APublic], 
						kind: unbindFun, 
						name: "unbind", 
						pos: Context.currentPos(),
						doc:null,
					};
					fields.push(unbindDef);
					
					var disposeFun = FFun({ 
						params: [],
						args: [], 
						expr: macro { listeners = []; }, 
						ret: macro:Void,
					}); 
					
					var disposeDef = { 
						meta: [], 
						access: [APublic], 
						kind: disposeFun, 
						name: "dispose", 
						pos: Context.currentPos(),
						doc:null,
					};
					fields.push(disposeDef);
					
					var constructorFun = FFun({ 
						params: [],
						args: [], 
						expr: macro { listeners = []; 	}, 
						ret: macro:Void,
					}); 
					
					var constructorDef = { 
						meta: [], 
						access: [APublic], 
						kind: constructorFun, 
						name: "new", 
						pos: Context.currentPos(),
						doc:null,
					};
					fields.push(constructorDef);
					
					var typeListenerArray = macro : Array < $listenerType > ;
					var listenerField = FVar( typeListenerArray, null);
					var listenerDef = { 
						meta: [], 
						access: [], 
						kind: listenerField, 
						name: "listeners", 
						pos: Context.currentPos(),
						doc:null,
					};
					
					fields.push(listenerDef);
					// PARTIE CHIANTE, ON PARTE LES TYPES POUR RETROUVER LES EVENTUELS PARAMETRES DE TYPE...
					
					var classParams: Array<haxe.macro.TypeParamDecl> = [];
					
					function checkTypePath( t:TypePath ) {
						if( t.params != null && t.params.length > 0 ) 
						{
							for(param in t.params )
							{
								switch(param) {
									case TPType( TPath(p) ):
										//WARNING : HACK!!!!!!
										if ( p.name.length == 1 )
											classParams.push( { name:p.name, params:[], constraints:[] } ); 
										checkTypePath(p);
									default:
								}
							}
						}
						else
						{
							//WARNING : HACK!!!!!!
							if( t.name.length == 1 )
								classParams.push({name:t.name, params:[], constraints:[]});
						}
					}
					
					for( t in types ) {
						if( t == null ) continue;
						switch(t) {
							case TPath( path ):
								checkTypePath(path);
							default:
						}
					}
					
					//on créé le type
					var signalTypeDef:haxe.macro.TypeDefinition = {
						pos:pos,
						params:classParams,
						pack: localClass.pack,
						name: localClass.name+"Signal" + fieldName,
						meta:null,
						kind:TDClass(null, [], false),
						isExtern:false,
						fields:fields,
					};
					//trace(printer.printTypeDefinition( signalTypeDef));
					Context.defineType(signalTypeDef);
					
					var signalClassName = signalTypeDef.name;
					var signalFullClassName = signalClassName;
					if( signalTypeDef.pack.length > 0 )
						signalFullClassName = signalTypeDef.pack.join('.') + '.'+ signalClassName;
					
					var signalerType = Context.getModule(signalFullClassName)[0];
					var complexSignalType = Context.toComplexType(signalerType);
					
					var exprGetSignal = macro { if ( $i { field.field.name } == null ) { $i { field.field.name } = Type.createEmptyInstance($i { signalClassName } ); } return $i { field.field.name }; };					
					var signalGetFun =  FFun({ 
						params: [],
						args: [], 
						expr:exprGetSignal , 
						ret: complexSignalType,
					});
					
					var signalGetDef = { 
						meta: [], 
						access: field.access, 
						kind: signalGetFun, 
						name: "get_"+field.field.name, 
						pos: Context.currentPos(),
						doc:null,
					};
					classFields.push( signalGetDef );
					
					var signalFieldDef = { name:field.field.name, access:field.access, kind:FProp("get", "null", complexSignalType, null ), pos : pos };
					classFields.push( signalFieldDef );
					
				default: Context.fatalError( "Invalid @:signal position " + field.field.kind, Context.currentPos() );
			}
		}
		
		//for( f in classFields )
		//	trace(printer.printField(f));
        return classFields;
    }
}
#end
