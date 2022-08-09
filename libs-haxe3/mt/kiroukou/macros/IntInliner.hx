package mt.kiroukou.macros;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#end

/**
Permet de déclarer rapidement, et METTRE A JOUR aisément une liste d'entiers successifs.
Utile donc pour la classique définition des layers du depthManager, ou bien d'autres choses

@:build(mt.kiroukou.macros.IntInliner.create([
	DP_BG, //vaudra 0
	DP_SHADE,//vaudra 1
	DP_UFX,// vaudra 2
	DP_SPLINTERS,//vaudra 3
]))

ou encore plusieurs listes en meme temps

@:build(mt.kiroukou.macros.IntInliner.create([
	[
		DP_BG,//vaudra 0
		DP_SHADE,//vaudra 1
		DP_TOP,//vaudra 2
	],
	[
		TEST_1,//vaudra 0
		TEST_2,//vaudra 1
	]
]))
 */
class IntInliner
{
    macro public static function create( e: Expr ) : Array<Field>
	{
        var pos = Context.currentPos();
        var fields = Context.getBuildFields();
		switch(e.expr)
		{
			case EArrayDecl(a): inlineIdentifiers(fields, a);
			default: Context.error('unsupported declaration', pos);
		}
        return fields;
    }
	
	#if macro
	static function inlineIdentifiers( fields : Array<Field>, a : Array<Expr> )
	{
		var pos = Context.currentPos();
		var typeInt = macro : Int;
		var counter = 0;
		for(b in a)
		{
			switch(b.expr)
			{
				case EConst(c):
					switch(c)
					{
						case CIdent(d):
							fields.push( {	name: d, doc: null,
											meta: [],
											access: [AStatic, APublic, AInline],
											kind: FVar(TPath( { pack : [], name : 'Int', params : [], sub : null } ), { expr: EConst(CInt(Std.string(counter))), pos: pos } ), pos: pos }
											);
							counter++;
						default: Context.error('unsupported declaration', pos);
					}
				case EArrayDecl(c): inlineIdentifiers(fields, c);
				default: Context.error('unsupported declaration', pos);
			}
		}
	}
	#end
}
