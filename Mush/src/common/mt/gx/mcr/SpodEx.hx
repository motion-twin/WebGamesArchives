package mt.gx.mcr;
/**
 * ...
 * @author de
 */

import haxe.macro.Context;
import haxe.macro.Expr;

using mt.gx.Ex;
import sys.db.Types.SNekoSerialized;


/**
Example Usage

@:build(mt.gx.cmn.mcr.SpodEx.decorateClass())
class A extends sys.db.Object
{
	public var id : SId;
	
	@neko_serialized
	public var charList : Array<Int>;
	
	@neko_serialized
	public var eventList : Array<Int>;
	
	public function new() 
	{
		super();
		charList = [];
		eventList = [];
	}
	
	public static var manager = new AManager(A);
}

@:build(mt.gx.cmn.mcr.SpodEx.decorateMan())
class ExpeditionManager  extends sys.db.Manager<Expedition>
{	
	override function make(o : A)
	{
		if( o.charList == null ) o.charList = [];
		if( o.eventList == null ) o.eventList = [];
		maker(o);
	}
	
	override function unmake(o : A)
	{
		unmaker(o);
	}
}
*/

class SpodEx 
{
	public static function decorateClass() 
	{
		//prepare all
		var pos 					= Context.currentPos();
		var fields :Array<Field>	= Context.getBuildFields();
		var typePath 				= Std.string( Context.getLocalClass() );
		
		var nekoSers = Lambda.filter( 	fields, 
										function(f) 
										return Lambda.exists( 	f.meta,
																function(m) 
																return m.name=="neko_serialized") );
																
		var indexSers = Lambda.filter( 	fields, 
										function(f) 
										return Lambda.exists( 	f.meta,
																function(m) 
																return m.name=="index_serialized") );
		
		var mkField = function(tp) 
		return function(f)
		{
			var tvar : {t:Null<ComplexType>} = {t:tp };
			var tfield : haxe.macro.Field = { name:"ser_" + f.name, kind : FVar(tvar.t, null) , pos: pos, access:[APublic] };
			f.meta.push( { name : ":skip", params : [], pos : pos } );
			return tfield;
		}
																
		var makeNekoSerDual = mkField(TPath( { pack:["sys", "db"], name:"Types", params:[], sub : "SNekoSerialized" } ));
		var makeIndexSerDual = mkField(TPath( { pack:[], name:"Int", params:[] } ));
		
		Lambda.iter(	nekoSers,
						function(f)
							fields.push( makeNekoSerDual(f) )
					);
					
					
		return fields;
	}

	public static function decorateMan( e : Expr ) 
	{
		//prepare all
		var pos = Context.currentPos();
		var fields :Array<Field>= Context.getBuildFields();
		var typePath = Std.string( Context.getLocalClass() );
		
		var tmpName = "maker";
		var i = 0;
		
		var maker : Field = mt.gx.ArrayEx.findAndRemove( fields,function(f) return f.meta.test(function(m)return m.name=="maker" ));
		if( maker!=null)
		{
			var o = maker.meta.find( function(m) return m.name == "fields" );
			if( o != null)
			{
				var pendingMakes = o.params;
				
				for(x in pendingMakes)
				{
					var acF :Function = Tools.ffunc( maker );
					var argName = acF.args[0].name;
					var name = tmpName+"_"+i++;
					var fieldName = Tools.cs(x).str;
					var declPrevious : Expr = {expr: EFunction(name,acF),pos:pos};
					var callPrevious :Expr 	= Context.parse(name+"("+argName+")",pos);
					
					var ser_Field = argName+".ser_"+ fieldName;
					
					var newCall : Expr 		= Context.parse( 
					"try{"
					+argName+"."+fieldName+" = ("+ser_Field+" == null ) ? null : neko.Lib.localUnserialize( "+ser_Field+" );"
					+"} catch (d:Dynamic) {"
					+"throw 'unable to unserialize ser_"+fieldName+" / "+ser_Field+" [='+Std.string("+ser_Field+")+'] '+d;" 
					+"}"
					,pos);
					var glue :Expr 			= {expr:EBlock([declPrevious,callPrevious,newCall]), pos:pos};
					
					//trace(ser_Field);
					var nf : Function = { 	args:acF.args,
											ret:acF.ret,
											expr:glue,
											params:acF.params};
					//trace(nf);
					maker.kind = FFun( nf );
				}
			}
			//trace( new haxe.macro.Printer("\t").printField( maker) );
			fields.push( maker );
		}
		
		var unmaker : Field= fields.findAndRemove( function(f) return f.meta.test(function(m)return m.name=="unmaker" ));
		if(unmaker != null)
		{
			var o = unmaker.meta.find( function(m) return m.name == "fields" );
			if( o !=null)
			{	
				var pendingUnmakes = o.params;
				for(x in pendingUnmakes)
				{
					var acF :Function = Tools.ffunc( unmaker );
					var argName = acF.args[0].name;
					var name = tmpName+"_"+i++;
					var fieldName = Tools.cs(x).str;
					var deser_Field = argName+"."+ fieldName;
					
					var declPrevious : Expr = {expr: EFunction(name,acF),pos:pos};
					var callPrevious :Expr 	= Context.parse(name+"("+argName+")",pos);
					var newCall : Expr 		= Context.parse( argName+".ser_"+ fieldName +" = neko.Lib.serialize( "+deser_Field+" )",pos);
					var glue :Expr 			= {expr:EBlock([declPrevious,callPrevious,newCall]), pos:pos};
					
					var nf : Function = { 	args:acF.args,
											ret:acF.ret,
											expr:glue,
											params:acF.params};
					//trace(deser_Field);
					unmaker.kind = FFun( nf );
				}
			}
			
			//trace( new haxe.macro.Printer("\t").printField( unmaker ) );
			fields.push( unmaker );
		}
		
		return fields;
	}
	
}

@:autoBuild(mt.gx.cmn.mcr.SpodEx.decorateClass())
interface SpodClassDeco
{

}
