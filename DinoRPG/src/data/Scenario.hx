package data;

typedef Scenario = {
	var id : String;
	var sid : Int;
	var name : Null<String>;
}

class ScenarioTexts extends haxe.xml.Proxy<"scenarios.xml",String> {
}

class ScenarioXML extends haxe.xml.Proxy<"scenarios.xml",Scenario> {
	
	public static var TEXTS : Hash<String>;
	
	public static function parse() {
		TEXTS = new Hash();
		return new data.Container<Scenario,ScenarioXML>().parse("scenarios.xml",function(id,sid,s) {
			for( t in s.elements )
				TEXTS.set(t.att.id,t.innerHTML);
			return {
				id : id,
				sid : sid,
				name : s.has.name ? s.att.name : null,
			};
		});
	}

}
