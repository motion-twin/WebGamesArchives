package tools;

class XmlTools {
	public static function contentToString( x:Xml ) : String {
		if (x == null)
			return null;
		var b = new StringBuf();
		for (c in x)
			b.add(c.toString());
		return b.toString();
	}
}