@:build(mt.data.Texts.build("texts.fr.xml"))
class Text
{
	static var _ =  {
		var lg = #if ide "fr" #else api.AKApi.getLang() #end;
		
		var raw = haxe.Resource.getString("texts."+ lg +".xml");
		if( raw == null ) raw = haxe.Resource.getString("texts.en.xml");
		Text.init( raw );
		null;
	}
}