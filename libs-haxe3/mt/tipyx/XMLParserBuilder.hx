package tipyx;

import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * ...
 * @author Tipyx
 */

/*
 * Put this class somewhere in your code and change the path of your asset directory
 * @:build(tipyx.XMLParserBuilder.build("assets/test.xml"))
 * class XMLParser {
 * 
 * }
 */

class XMLParserBuilder
{
	
/*
 * TODO :
 * Handle Bool
 */

	public static function build(path:String):Array<Field> {
	// BUILD XML
		var xml:Xml = Xml.parse(sys.io.File.getContent(path));
		
	// CONSTRUCT FIELDS
        var fields = Context.getBuildFields();
		
		for (f in xml.firstElement().elements()) {
			var name = f.nodeName.split("-").join("_").split(".").join("__");
			
			if (f.firstElement() != null) {
				fields.push({
					name:name,
					access:[Access.APublic, Access.AStatic],
					pos:Context.currentPos(),
					kind:FieldType.FVar(null, {pos: Context.currentPos(), expr: EObjectDecl( buildRec(f) ) })
				});
			}
			else {
				var strV = f.firstChild().toString();
				var intV = Std.parseInt(strV);
				var floatV = Std.parseFloat(strV);
				
				var kind = FieldType.FVar(macro:String, macro $v { f.firstChild().toString() } );
				
				if (intV != null) {
					if (intV == floatV)
						kind = FieldType.FVar(macro:Int, macro $v { intV } );
					else
						kind = FieldType.FVar(macro:Float, macro $v { floatV } );
				}
				
				fields.push({
					name:name,
					access:[Access.APublic, Access.AStatic, Access.AInline],
					pos:Context.currentPos(),
					kind:kind
				});
			}
		}
		
        return fields;
	}
	
	#if macro
	static function buildRec(xml:Xml) : Array<{field: String, expr: Expr}> {
		var arr = [];
		
		for ( f in xml.elements()) {
			var name = f.nodeName.split("-").join("_").split(".").join("__");
			
			if (f.firstElement() != null) {
				arr.push( {
					field: name,
					expr: {pos:Context.currentPos(), expr:EObjectDecl(buildRec(f.firstElement()))}
				});
			}else {
				arr.push( {
					field: name,
					expr: macro $v{f.firstChild().toString()}
				});
			}
		}
		return arr;
	}
	#end
}