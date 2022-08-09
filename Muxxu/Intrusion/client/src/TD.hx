class TD {
	public static var fsNames			: data.TextXml = null;
	public static var patterns			: data.PatternXml = null;
	public static var texts				: data.TextXml = null;
	public static var names				: data.TextXml = null;
//	public static var dialogs			: data.TextXml = null;


	public static function init() {
		var fl_adult = Manager.PARAMS._profile._adult;
		patterns = new data.PatternXml( 0, haxe.Resource.getString("xml_sysPatterns") ); // TODO
		fsNames = new data.TextXml(0, haxe.Resource.getString("xml_fsNames_"+Manager.LANG), "xml_fsNames", fl_adult);
		fsNames.fl_underscoreRep = true;
		texts = new data.TextXml(0, haxe.Resource.getString("xml_texts_"+Manager.LANG), "xml_texts", fl_adult);
		texts.fl_autoCaps = true;
		names = new data.TextXml(0, haxe.Resource.getString("xml_names_"+Manager.LANG), "xml_names", fl_adult);
		names.fl_autoCaps = true;
//		dialogs= new data.TextXml(0, haxe.Resource.getString("xml_dialogs"), "xml_dialogs");
//		dialogs.fl_autoCaps = true;

		texts.registerOtherXml( names );
		fsNames.registerOtherXml( names );
//		dialogs.registerOtherXml( texts );

		try {
			patterns.check(fsNames);
			fsNames.check();
			texts.check();
			names.check();
//			dialogs.check();
		}
		catch(e:String) {
			Manager.fatal("CHECK FAILURE : "+e);
		}
	}

	private static inline function newRandSeed(s) {
		var rseed = new mt.Rand(0);
		rseed.initSeed(s);
		return rseed;
	}

	public static function setSeed(s:Int) {
		patterns.rseed = newRandSeed(s);
		fsNames.rseed = newRandSeed(s);
		texts.rseed = newRandSeed(s);
		names.rseed = newRandSeed(s);
//		dialogs.rseed = newRandSeed(s);
	}

}
