import mt.deepnight.deprecated.TalentTree;

private class DataGet extends haxe.xml.Proxy<"xml/fr/talents.xml",Talent > { }

class TalentXml {
	public static var MAX_LEVEL = 0;
	public static var ALL : Hash<Talent>;
	public static var get : DataGet = init();

	private static function init() {
		try {
			TalentTree.STEP_REQ = Const.LAB_STEP_REQ;
			var raw = neko.io.File.getContent(Config.TPL+"../../xml/"+Config.LANG+"/talents.xml");

			var h = new Hash();
			var xml = Xml.parse(raw);
			var fast = new haxe.xml.Fast(xml.firstChild());
			
			var lid = 0;
			for (level in fast.nodes.l) {
				for (n in level.nodes.t) {
					var talent : Talent = {
						id		: n.att.id,
						name	: n.att.name,
						desc	: n.innerHTML,
						icon	: if (n.has.icon) n.att.icon else null,
						lvl		: lid,
						max		: if(n.has.max) Std.parseInt(n.att.max) else 3,
						req		: null,
					}
					h.set(n.att.id, talent);
				}
				lid++;
			}
			MAX_LEVEL = lid;
			
			ALL = h;
			return new DataGet(ALL.get);
		}
		catch (e:Dynamic) {
			trace(e);
			throw "FAILED";
		}
	}
}
