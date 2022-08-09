class Manager {

	static var _main : Game;

	static function initParams() {
		var params = flash.external.ExternalInterface.call("getExternalParams");
		if( params == null ) return;
		var h : Hash<String> = haxe.Unserializer.run(params);
		for( p in h.keys() )
			Reflect.setField(flash.Lib._root,p,h.get(p));
	}

	public static function main(){
		initParams();

		/*
		if( Reflect.field(flash.Lib._root,"_path") == null  ){
			Reflect.setField( flash.Lib._root, "_path", "swf/" );
		}
		*/


		Reflect.setField( flash.Lib._root, "trace", haxe.Log.trace );

		_main = new Game(flash.Lib._root);
		flash.Lib._root.onEnterFrame = function(){ _main.update(); }
	}

}
