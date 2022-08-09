package mt.data;

class XmlTools {
	
	static var replaceMap :Map<String,Int> = {
		var m = new Map();
		function f(s, i) m.set( s, i);
		
		f("quot",		34		);
		f("amp",		38      );
		f("apos",		39      );
		f("lt",			60      );
		f("gt",			62      );
		f("nbsp",		160     );
		f("iexcl",		161     );
		f("cent",		162     );
		f("pound",		163     );
		f("curren",		164     );
		f("yen",		165     );
		f("brvbar",		166     );
		f("sect",		167     );
		f("uml",		168     );
		f("copy",		169     );
		f("ordf",		170     );
		f("laquo",		171     );
		f("not",		172     );
		f("shy",		173     );
		f("reg",		174     );
		f("macr",		175     );
		f("deg",		176     );
		f("plusmn",		177     );
		f("sup2",		178     );
		f("sup3",		179     );
		f("acute",		180     );
		f("micro",		181     );
		f("para",		182     );
		f("middot",		183	    );
		f("cedil",		184     );
		f("sup1",		185     );
		f("ordm",		186     );
		f("raquo",		187     );
		f("frac14",		188     );
		f("frac12",		189     );
		f("frac34",		190     );
		f("iquest",		191     );
		f("Agrave",		192     );
		f("Aacute",		193     );
		f("Acirc",		194     );
		f("Atilde",		195     );
		f("Auml",		196     );
		f("Aring",		197     );
		f("AElig",		198     );
		f("Ccedil",		199     );
		f("Egrave",		200     );
		f("Eacute",		201     );
		f("Ecirc",		202     );
		f("Euml",		203     );
		f("Igrave",		204     );
		f("Iacute",		205     );
		f("Icirc",		206     );
		f("Iuml",		207     );
		f("ETH",		208     );
		f("Ntilde",		209     );
		f("Ograve",		210     );
		f("Oacute",		211     );
		f("Ocirc",		212     );
		f("Otilde",		213     );
		f("Ouml",		214     );
		f("times",		215     );
		f("Oslash",		216     );
		f("Ugrave",		217     );
		f("Uacute",		218     );
		f("Ucirc",		219     );
		f("Uuml",		220     );
		f("Yacute",		221     );
		f("THORN",		222     );
		f("szlig",		223     );
		f("agrave",		224     );
		f("aacute",		225     );
		f("acirc",		226     );
		f("atilde",		227     );
		f("auml",		228     );
		f("aring",		229     );
		f("aelig",		230     );
		f("ccedil",		231     );
		f("egrave",		232     );
		f("eacute",		233     );
		f("ecirc",		234     );
		f("euml",		235     );
		f("igrave",		236     );
		f("iacute",		237     );
		f("icirc",		238     );
		f("iuml",		239     );
		f("eth",		240     );
		f("ntilde",		241     );
		f("ograve",		242     );
		f("oacute",		243     );
		f("ocirc",		244     );
		f("otilde",		245     );
		f("ouml",		246     );
		f("divide",		247     );
		f("oslash",		248     );
		f("ugrave",		249     );
		f("uacute",		250     );
		f("ucirc",		251     );
		f("uuml",		252     );
		f("yacute",		253     );
		f("thorn",		254     );
		f("yuml",		255     );
		f("OElig",		338     );
		f("oelig",		339     );
		f("Scaron",		352     );
		f("scaron",		353     );
		f("Yuml",		376     );
		f("fnof",		402     );
		f("circ",		710     );
		f("tilde˜",		732     );
		f("Alpha",		913     );
		f("Beta",		914     );
		f("Gamma",		915     );
		f("Delta",		916     );
		f("Epsilon",	917     );
		f("Zeta",		918     );
		f("Eta",		919     );
		f("Theta",		920     );
		f("Iota",		921     );
		f("Kappa",		922     );
		f("Lambda",		923     );
		f("Mu",			924     );
		f("Nu",			925     );
		f("Xi",			926     );
		f("Omicron",	927     );
		f("Pi",			928     );
		f("Rho",		929     );
		f("Sigma",		931     );
		f("Tau",		932     );
		f("Upsilon",	933     );
		f("Phi",		934     );
		f("Chi",		935     );
		f("Psi",		936     );
		f("Omega",		937     );
		f("alpha",		945     );
		f("beta",		946     );
		f("gamma",		947     );
		f("delta",		948     );
		f("epsilon",	949     );
		f("zeta",		950     );
		f("eta",		951     );
		f("theta",		952     );
		f("iota",		953     );
		f("kappa",		954     );
		f("lambda",		955     );
		f("mu",			956     );
		f("nu",			957     );
		f("xi",			958     );
		f("omicron",	959     );
		f("pi",			960     );
		f("rho",		961     );
		f("sigmaf",		962     );
		f("sigma",		963     );
		f("tau",		964     );
		f("upsilon",	965     );
		f("phi",		966     );
		f("chi",		967     );
		f("psi",		968     );
		f("omega",		969     );
		f("thetasym",	977     );
		f("upsih",		978     );
		f("piv",		982     );
		f("ensp",		8194    );
		f("emsp",		8195    );
		f("thinsp",		8201    );
		f("zwnj",		8204    );
		f("zwj",		8205    );
		f("lrm",		8206    );
		f("rlm",		8207    );
		f("ndash",		8211    );
		f("mdash",		8212    );
		f("lsquo",		8216    );
		f("rsquo",		8217    );
		f("sbquo",		8218    );
		f("ldquo",		8220    );
		f("rdquo",		8221    );
		f("bdquo",		8222    );
		f("dagger",		8224    );
		f("Dagger",		8225    );
		f("bull",		8226    );
		f("hellip",		8230    );
		f("permil",		8240    );
		f("prime",		8242    );
		f("Prime",		8243    );
		f("lsaquo",		8249    );
		f("rsaquo",		8250    );
		f("oline",		8254    );
		f("frasl",		8260    );
		f("euro",		8364    );
		f("image",		8465    );
		f("weierp",		8472    );
		f("real",		8476    );
		f("trade",		8482    );
		f("alefsym",	8501    );
		f("larr",		8592    );
		f("uarr",		8593    );
		f("rarr",		8594    );
		f("darr",		8595    );
		f("harr",		8596    );
		f("crarr",		8629    );
		f("lArr",		8656    );
		f("uArr",		8657    );
		f("rArr",		8658    );
		f("dArr",		8659    );
		f("hArr",		8660    );
		f("forall",		8704    );
		f("part	",		8706    );
		f("exist",		8707    );
		f("empty",		8709    );
		f("nabla",		8711    );
		f("isin",		8712    );
		f("notin",		8713    );
		f("ni",			8715    );
		f("prod",		8719    );
		f("sum",		8721    );
		f("minus",		8722    );
		f("lowast",		8727    );
		f("radic",		8730    );
		f("prop",		8733    );
		f("infin",		8734    );
		f("ang",		8736    );
		f("and",		8743    );
		f("or",			8744    );
		f("cap",		8745    );
		f("cup",		8746    );
		f("int",		8747    );
		f("there4",		8756    );
		f("sim",		8764    );
		f("cong",		8773    );
		f("asymp˜",		8776    );
		f("ne",			8800    );
		f("equiv",		8801    );
		f("le",			8804    );
		f("ge",			8805    );
		f("sub",		8834    );
		f("sup",		8835    );
		f("nsub",		8836    );
		f("sube",		8838    );
		f("supe",		8839    );
		f("oplus",		8853    );
		f("otimes",		8855    );
		f("perp",		8869    );
		f("sdot",		8901    );
		f("vellip",		8942    );
		f("lceil",		8968    );
		f("rceil",		8969    );
		f("lfloor",		8970    );
		f("rfloor",		8971    );
		f("lang",		9001    );
		f("rang",		9002    );
		f("loz",		9674    );
		f("spades",		9824    );
		f("clubs",		9827    );
		f("hearts",		9829    );
		f("diams",		9830    );
		m;
	}
	
	static function reach(str:String, pos:Int, token : Int) {
		for ( i in pos...str.length) {
			var c = StringTools.fastCodeAt( str, i );
			if ( c == token )	
				return i;
		}
		return -1;
	}
	/**
	 * Warning costs an arm and eats your soul.
	 * @param	str
	 */
	public static function xmlUnescape(str:String) {
		var s = new StringBuf();
		var i = 0;
		while (true) {
			if ( i >= str.length ) break;
			
			var c = StringTools.fastCodeAt( str, i );
			if( StringTools.isEof( c  )) break;
		
			if ( c == "&".code ) {
				i++; c = StringTools.fastCodeAt( str, i );
				var endPos = reach(str, i, ";".code);
				if ( endPos == -1) return s.toString();
				
				if ( c == "#".code ) {
					var lit = str.substring( i+1, endPos );
					s.add( String.fromCharCode(Std.parseInt("0" + lit) ));
				}
				else {
					var lit = str.substring( i, endPos );
					s.addChar( replaceMap.get(lit) );
				}
						
				i=endPos+1;
				continue;
			}
			s.addChar(c);
			i++;
		}
		
		return s.toString();
	}
}