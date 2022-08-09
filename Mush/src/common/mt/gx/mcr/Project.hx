package mt.gx.mcr;

import haxe.macro.Context;
import haxe.macro.Expr;

@:autoBuild(mt.gx.mcr.Project.manage())
interface Managed
{

}


/**
 * ...
 * @author de
 */
class Project 
{
	@macro
	public static function manage() 
	{
		if ( Context.defined( "display" ) )
			return null;
			
		var fields = Context.getBuildFields();
		for( f in fields )
			for( m in f.meta )
				switch( m.name )
				{
					case "todo","_todo":
						if( m.params.length == 1 )
						{
							var p = Tools.cs( m.params[0] );
							Context.warning("TODO: "+p.str ,p.pos);
						}
						
					case "fixme","_fixme":
						if( m.params.length == 1 )
						{
							var p = Tools.cs( m.params[0] );
							Context.warning("FIXME: "+p.str ,p.pos);
						}
						
					case "msg","_msg":
						if( m.params.length == 1 )
						{
							var p = Tools.cs( m.params[0] );
							Context.warning("MESSAGE: "+p.str ,p.pos);
						}
				}
		
		return null;
	}
	
}
