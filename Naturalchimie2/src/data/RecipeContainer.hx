package data ;

class RecipeContainer extends Container<Recipe,RecipeXML> {
	
	public function new( ?ordered, ?noid ) {
		super(ordered, noid) ;
	}
	
	public function parseRecipes( file : String, f : String -> Int -> haxe.xml.Fast -> Recipe ) : RecipeContainer {
		this.file = file;
		for( e in Data.xml(file).elements() ) {
			var e = new haxe.xml.Fast(e);
			var id = e.att.id;
			var iid = if( i != null ) Tools.makeId(id) else 0;
			if( h.exists(id) )
				throw "Duplicate id in "+file+" : "+id;
			var x = try f(id,iid,e) catch( e : Dynamic ) {
				neko.Lib.rethrow("Error while parsing "+file+"@"+id+" : "+Std.string(e));
			}
			h.set(id,x);
			if( i != null )
				i.set(iid,x);
			if( l != null )
				l.add(x);
		}
		return this;
	}
	
	
	override public function getName( id : String ) {
		var inst = h.get(id);
		if( inst == null )
			throw "No '"+id+"' found in "+file;
		return inst.copy() ;
	}

	override public function getId( id : Int ) {
		var inst = if (i != null) i.get(id)  else h.get(Std.string(id)) ;
		if( inst == null )
			throw "No "+(try Tools.makeName(id) catch( e : Dynamic ) "???")+" (#"+id+") found in "+file;
		return inst.copy() ;
	}


	
}