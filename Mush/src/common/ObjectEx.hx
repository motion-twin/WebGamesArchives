#if neko
import haxe.CallStack;
import haxe.Json;
import haxe.rtti.Meta;
import mt.Assert;
import mt.net.GraphFields;
import neko.Lib;
import neko.Web;
using Ex;
class ObjectEx
{
	/**
	 * Parses class meta data to extract data ant try to promote data representation to something canonical
	 * @graph
	 * @graphMine
	 * @graphScope("machin")
	 */
	
	private static inline function dbg(str:Dynamic) {
		#if debug
		Web.logMessage(str);
		#end
	}
	
	public static function readMetaGraph<T>( o : T,cl : Class<T>,  viewer : db.User, scopes: Array<String>, fields : mt.net.GraphFields, isMine : Bool){
		if ( fields == null ) fields = [];
		if ( scopes == null ) scopes = [];
		
		function prop(o, str) return Reflect.getProperty(o, str);
		
		dbg( "readMetaGraph" );
		var r : Dynamic = {};
		var oFields = Meta.getFields(cl);
		dbg( "readMetaGraph:getFields" );		
		function makeJson<TT>( obj :TT, fieldName:String) {
			var p = Reflect.getProperty(obj, fieldName);
			dbg( "makeJson:of "+fieldName);
			if (Std.is(p, Date)) {
				dbg( "makeJson:Date "+p);
				return Std.string(p);
			}
			else {
				dbg( "makeJson:regular");
				return Reflect.getProperty(obj, fieldName);
			}
		}
		
		function makeFollow( obj, fieldName, fields) 	
		{
			dbg( "makeFollow:"+Std.string(obj)+' -> $fieldName ');
			if (fields == null) fields = [];
			var ofield = Reflect.getProperty(obj, fieldName);
			var args :Array<Dynamic> = [viewer, scopes, fields];
			if ( Std.is( ofield, Array)) {
				dbg( "following array:" + Std.string(obj) + ' -> $fieldName ' );
				var r = [];
				var ofieldarray :Array<Dynamic> = cast ofield;
				dbg( "array length:" +ofieldarray.length);
				for ( a in ofieldarray) {
					dbg( "fields:"+Reflect.fields( a ) );
					var method = null;
					try {
						var c = Type.getClass( a );
						dbg( "class is "+Type.getClassName(c) );
						var f = Type.getInstanceFields( c );
						if ( f.has("getGraph") ) {
							dbg( "getGraph is present "+Type.getClassName(c) );
							method = Reflect.getProperty( a, "getGraph");
							
							try {
								dbg( "calling getGraph on "+Type.getClassName(c)+" with "+args );
								r.push(Reflect.callMethod( a, method, args ));
							}
							catch (d:Dynamic) {
								//skip
								dbg( "getGraph failed with "+d + CallStack.toString(CallStack.exceptionStack()));
							}
						}
						else {
							dbg( "no method getGraph for "+Type.getClassName(c) );
							r.push( a );
						}
					}
					catch (d:Dynamic) {
						dbg( "failed with "+d );
					}
					
				}
				return r;
			}
			else {
				dbg( "following getGraph:"+Std.string(obj)+' -> $fieldName '+ CallStack.toString(CallStack.callStack()));
				var method = Reflect.getProperty( ofield, "getGraph");
				return Reflect.callMethod( ofield, method, args );
			}
		}
		
		dbg( "readMetaGraph:crawlin fields" );		
		for ( f in fields) {
			dbg("testing field " + f.name);
			var hf = false;
			
			try{
				hf = Reflect.hasField( oFields, f.name);
			}catch (d:Dynamic) {
				dbg("*EXCEPTION* on Reflect.hasField on " + oFields+" -> "+d+" f:"+f.name);
			}
			
			dbg("tested field " + f.name+" on "+o);
			
			if ( hf ) {
				dbg("expanding field " + f.name);
				var cf = Reflect.getProperty( oFields, f.name);
				dbg("retrieved meta " + f.name+ " "+cf);
				var childProperty = Reflect.getProperty(o, f.name);
				
				
				dbg( " type of " + f.name + " "+Std.string( Type.typeof(childProperty))+ " class:"+ Type.getClassName(Type.getClass(childProperty)) );
				var hasGraphMine = Reflect.hasField( cf, "graphMine" );
				var hasGraph = Reflect.hasField( cf, "graph" );
				
				if ( childProperty == null) {
					if ( hasGraph || (hasGraphMine && isMine) ) {
						dbg("property looks null... "+f.name);
						Reflect.setField( r , f.name, null);
					}
					else 
						dbg("no such property "+f.name);
						
					continue;
				}
				
				var follow = mt.gx.StdEx.hasFunction( childProperty, "getGraph") || Std.is(childProperty, Array);
				dbg("evaluating follow of " + f.name+" "+follow);
				var gsList: Array<String> = Reflect.getProperty( cf, "graphScope" );
				var graphScope = gsList != null ? gsList.first() : null;
				
				if ( Reflect.hasField( cf, "graphMineI" )){
					hasGraphMine = true;
				}
				
				if ( graphScope != null && graphScope.length > 0)
					if ( !Lambda.has(scopes, graphScope) ) {
						dbg("invalid scope : "+graphScope+" not among "+scopes);
						continue;
					}
					
				if ( hasGraph || (hasGraphMine && isMine) )
					if ( !follow ){
						dbg("trying to json " + f.name);
						Reflect.setField( r , f.name, makeJson( o, f.name));
					}
					else {
						dbg("trying to expand " + f.name+" with "+f.fields);
						Reflect.setField( r , f.name, makeFollow( o, f.name, f.fields));
					}
			}
			else {
				
			}
			
			//do not remove unknown fields as they can be catched later on
		}
		return r;
	}
	
	public static function dumpMetaGraph<T>( cl : Class<T> )  : {head:String,fields:Array<String>,bottom:String} {
		var str = "";
		
		var r : Dynamic = {};
		var oFields = Meta.getFields(cl);
		var res = { head:"", fields:[], bottom:"" };
		var ocl = Type.createEmptyInstance(cl);
		res.head = "<h3>" + Type.getClassName(cl) + "</h3> {<div>";
		for ( f in Reflect.fields(oFields)) {
			var cf = Reflect.getProperty( oFields, f);
			
			var hasGraphMine = Reflect.hasField( cf, "graphMine" );
			var hasGraph = Reflect.hasField( cf, "graph" );
			var graphValue  = Reflect.getProperty(cf, "graph");
			var graphMineValue  = Reflect.getProperty(cf, "graphMine");
			
			if ( Reflect.hasField( cf, "graphMineI" )){
				hasGraphMine = true;
				graphMineValue = ["Int"];
			}
			
			var graphScope : String = Reflect.getProperty( cf, "graphScope" );
			var graphDoc : String = Reflect.getProperty( cf, "graphDoc" );
			
			if ( !hasGraph && !hasGraphMine ) continue;
			
			str = f;
			if( graphValue!=null && graphValue.length > 0 )
				str += " : " + (cast graphValue)[0];
			else if( graphMineValue!=null && graphMineValue.length > 0 )
				str += " : " + (cast graphMineValue)[0];
			
			var typelit = "";
			if ( hasGraphMine) typelit += " mine only";
			
			if ( graphScope != null && graphScope.length > 0 ) 	typelit += (typelit.length==0)?"":"," + " need scope " + graphScope+" ";
			if ( graphDoc != null && graphDoc.length > 0 ) 		typelit += (typelit.length==0)?"":"," + graphDoc;
			if ( typelit.length > 0) str += "// "+typelit;
			str += " ;<br/>";
			
			res.fields.push(str);
		}
		res.bottom  += "</div>}<br/>";
		return res;
	}
	
}
#end