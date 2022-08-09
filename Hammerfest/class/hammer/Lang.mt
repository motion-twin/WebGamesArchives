class Lang {

	static var strList		= [];
	static var itemNames	= [];
	static var familyNames	= [];
	static var questNames	= [];
	static var questDesc	= [];
	static var levelNames	= [];
	static var keyNames		= [];
	static var lang			= "ERR ";
	static var fl_debug		= false;
	static var doc			: XmlNode;

	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	static function init(raw:String) {
		var docXml = new Xml(raw);
//		doc = new Xml( raw ).firstChild;
		docXml.ignoreWhite = true;
		docXml.parseXML( raw );
		doc = docXml.firstChild;

		lang		= doc.get("$id".substring(1));
		fl_debug	= doc.get("$debug".substring(1))=="1";
		strList		= new Array();


		strList		= _getStringData("$statics","$v");
		itemNames	= _getStringData("$items","$name");
		familyNames	= _getStringData("$families","$name");
		questNames	= _getStringData("$quests","$title");
		keyNames	= _getStringData("$keys","$name");
//		levelNames	= _getStringData("$levels","$name");

		// Quest descriptions
		var node = _find( doc, "$quests".substring(1) );
		while ( node!=null ) {
			var id	= Std.parseInt( node.get("$id".substring(1)), 10 );
			questDesc[id] = Data.cleanString( node.firstChild.nodeValue );
			node = node.nextSibling;
		}

		// Level names
		node = _find( doc, "$dimensions".substring(1) );
		while ( node!=null ) {
			var did	= Std.parseInt( node.get("$id".substring(1)), 10 );
			levelNames[did] = new Array();
			var child = node.firstChild;
			while (child!=null) {
				var lid = Std.parseInt( child.get("$id".substring(1)), 10 );
				levelNames[did][lid] = child.get("$name".substring(1));
				child = child.nextSibling;
			}
			node = node.nextSibling;
		}

	}


	/*------------------------------------------------------------------------
	RENVOIE LA LISTE DE STRINGS DEMAND�E DEPUIS LE XML LANG
	------------------------------------------------------------------------*/
	static function _getStringData( parentNode:String, attrName:String ) {
		var tab = new Array();
		var node = _find( doc, parentNode.substring(1) );
		while ( node!=null ) {
			var id	= Std.parseInt( node.get("$id".substring(1)), 10 );
			var txt	= node.get(attrName.substring(1));
			if ( fl_debug ) {
				txt= "["+lang.toLowerCase()+"]"+txt;
			}
			tab[id] = txt;
			node = node.nextSibling;
		}
		return tab;
	}


	/*------------------------------------------------------------------------
	RENVOIE LE CONTENU D'UNE NODE INDIQU�E
	------------------------------------------------------------------------*/
	static private function _find(doc:XmlNode, name:String) : XmlNode {
		var node = doc.firstChild;
		while ( node.nodeName!=name ) {
			node = node.nextSibling;
			if ( node==null ) {
				GameManager.fatal("node '"+name+"' not found !");
				return null;
			}
		}
		return node.firstChild;
	}



	/*------------------------------------------------------------------------
	RENVOIE UNE STRING LOCALIS�E
	------------------------------------------------------------------------*/
	static function get(id) {
		if ( fl_debug ) {
			return "["+lang.toLowerCase()+"]"+strList[id];
		}
		else {
			return strList[id];
		}

	}

	/*------------------------------------------------------------------------
	RENVOIE UN NOM D'ITEM
	------------------------------------------------------------------------*/
	static function getItemName(id) {
		if ( itemNames[id]==null ) {
//			GameManager.warning("name not found for item #"+id);
		}
		if ( fl_debug ) {
			return "["+lang.toLowerCase()+"]"+itemNames[id];
		}
		else {
			return itemNames[id];
		}
	}


	/*------------------------------------------------------------------------
	GETTERS
	------------------------------------------------------------------------*/
	static function getFamilyName(id) {
		return familyNames[id];
	}

	static function getQuestName(id) {
		return questNames[id];
	}

	static function getQuestDesc(id) {
		return questDesc[id];
	}

	static function getLevelName(did,lid) {
		return levelNames[did][lid];
	}


	static function getSectorName(did,lid) {
		var n = getLevelName(did,lid);
		while (lid>0 && n==null) {
			lid--;
			n = getLevelName(did,lid);
		}
		if ( n==null ) {
			n = "";
		}
		return n;
	}

	static function getKeyName(kid) {
		return keyNames[kid];
	}
}
