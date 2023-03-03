class Quotes
{
	static var CONTENT : Xml;
	static var quotes  : Array<String>;

	public static function init() {
		var raw = neko.io.File.getContent(Config.XML_PATH+"quotes.xml");
		raw = StringTools.replace(raw,"::ignore::","");
		CONTENT = Xml.parse(raw).firstChild();
		quotes = new Array();

		for( quote in CONTENT.elements() )
			quotes.push( quote.firstChild().nodeValue );
	}

	public static function getRandomQuote() : String{
		if( quotes == null )
			return "";

		return quotes[ Std.random( quotes.length ) ];
	}

	public static function getRandomQuoteFromSeed( seed : Int )  : String {
		return quotes[ seed ];
	}
}
