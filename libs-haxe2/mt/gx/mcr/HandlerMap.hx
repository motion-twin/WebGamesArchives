package mt.gx.mcr;

import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * ...
 * @author de
 */

typedef Item = { acl:String,tpl:String};

class HandlerMap 
{
	@macro
	public static function build() 
	{
		//prepare all
		var pos = Context.currentPos();
		var fields :Array<Field>= Context.getBuildFields();
		var typePath = Std.string( Context.getLocalClass() );
		
		//cacher
		var defs : Hash<Item> = new Hash();
		var funcBody : StringBuf = new StringBuf();
		funcBody.add("<h3>handler map of : "+typePath+"</h3>");
		
		var itemize = function(v) return "<p>"+v+"+</p>";
		
		//loop
		for( f in fields )
		{
			var stated = false;
			var elem = { acl:"",tpl:""};
			
			for( m in f.meta )
				switch( m.name )
				{
					case "logged":
						elem.acl=itemize("@logged : "+ f.name ); stated= true;
					case "admin":
						elem.acl=itemize("@admin : "+ f.name ); stated= true;
					case "tpl":
						elem.tpl= "@tpl( "+ Tools.cs(m.params[0]).str +" )";
						if( !stated )
						{
							elem.acl = itemize("@free : "+ f.name );
							stated = true;
						}
				}
				
			if( f.meta.length == 0 && !stated)
			{
				if( StringTools.startsWith( f.name,"do" ))
				{
					elem.acl=itemize("@free : "+ f.name );
					stated = true;
				}
			}
			defs.set( f.name, elem);
		}
		
		//flatten
		for( d in defs)
			funcBody.add( d.tpl + d.acl );
		
		//do lazy build
		var tfuncExpr					 		= Context.parse("neko.Lib.print('"+funcBody.toString()+"')",pos);
		var tfunc : haxe.macro.Function 		= { args:[], params:[], ret:null, expr:tfuncExpr };
		var tmetaAdmin : haxe.macro.Metadata  	= [{name:"admin",params:[],pos:pos}];
		var tfield : haxe.macro.Field = 
			{ name:"doHandlerMap", kind : FFun(tfunc) , pos: pos, meta:tmetaAdmin };
			
		//yeah!
		fields.push( tfield );
		
		return fields;
	}
	
}