package data;

typedef Background = {
	var id : String;
	var gfx : String;
	var mtop : Int;
	var mbottom : Int;
	var mright : Int;
	var ground : String;
}

class BackgroundXML extends haxe.xml.Proxy<"background.xml",Background> {

	public static function parse() {
		return new data.Container<Background,BackgroundXML>(false,true).parse("background.xml",function(id,iid,b) {
			return {
				id : id,
				gfx : if( b.has.gfx ) b.att.gfx else id,
				mtop : if( b.has.mtop ) Std.parseInt(b.att.mtop) else 120,
				mbottom : if( b.has.mbottom ) Std.parseInt(b.att.mbottom) else 20,
				mright : if( b.has.mright ) Std.parseInt(b.att.mright) else 0,
				ground : if( b.has.ground ) b.att.ground else null,
			};
		});
	}

}

