package data;

class TextXml {
	static var GROUP_SEP = "/\\";
	static var EXTERNAL_SEP = ":";
	static var VAR_SEP = "::";

	static var VOYEL_LOWERS = "àâäéèëêîïìôöòûüùÿ";
	static var VOYEL_UPPERS = "ÀÂÄÉÈËÊÎÏÌÔÖÒÛÜÙŸ";
	static var CONS_LOWERS = "çñ";
	static var CONS_UPPERS = "ÇÑ";
	static var SPECIAL_LETTERS = VOYEL_LOWERS+VOYEL_UPPERS + CONS_LOWERS+CONS_UPPERS;

	var xmlName				: String; // utilisé pour les msg d'erreur
	public var rseed		: mt.Rand;
	var texts				: Hash<Array<String>>;
	public var tvars		: Hash<String>;
	public var fl_autoCaps	: Bool;
	public var fl_underscoreRep	: Bool;
	var otherTextXml		: List<TextXml>;

	public function new(seed:Int,raw:String,?xname:String,?fl_adult=false) {
		xmlName = xname;
		if ( raw==null || raw=="" )
			throw "no data for "+xmlName;
		rseed = new mt.Rand(0);
		otherTextXml = new List();
		rseed.initSeed(seed);
		texts = new Hash();
		tvars = new Hash();

		fl_autoCaps = false;
		fl_underscoreRep = false;

		var lines = raw.split("\n");
		var key : String = null;
		for (line in lines) {
			var trimmed = trim(line);
			if ( trimmed.length==0 ) continue;
			if ( line.charAt(0)==" " )
				fatal("unexpected leading space around key "+key);
			if ( line.charAt(0)!="\t" )
				key = trimmed.toLowerCase();
			else {
				if ( key==null ) fatal("unexpected : "+line);
				if ( texts.get(key)==null ) texts.set(key,new Array());
				if ( trimmed.indexOf("__adult__")>=0 )
					if ( !fl_adult )
						continue;
					else
						trimmed = StringTools.replace(trimmed,"__adult__","");
				texts.get(key).push( trimmed );
			}
		}
	}

	public function registerOtherXml(tx:TextXml) {
		if ( otherTextXml==null )
			otherTextXml = new List();
		otherTextXml.add(tx);
	}


	public function getOtherXml(xname:String,key:String) {
		for (tx in otherTextXml)
			if ( tx.xmlName.toLowerCase()==xname.toLowerCase() )
				return tx.get(key);
		fatal("external reference ["+key+"] not found in ["+xname+"] (forgot to register ?)");
		return null;
	}


	public function exists(key:String) {
		return texts.get(key)!=null;
	}

	public function get(key:String, ?rs:mt.Rand, ?fl_firstRecurs=true) {
		if ( rs==null )
			rs = rseed;
		key = key.toLowerCase();
		if ( key.indexOf(EXTERNAL_SEP)>=0 ) {
			var a = key.split(EXTERNAL_SEP);
			var str = getOtherXml(a[0],a[1]);
			return str;
		}
		var list = texts.get(key);
		if ( key==null || list==null || list.length==0 )
			fatal("unknown reference "+key+" list="+list+" texts="+texts);
		var str = list[rs.random(list.length)];
		var list = str.split("%");
		if (list.length>1) {
			str = "";
			var i = 1;
			for (v in list) {
				if (i%2==0) {
					var append = get(v,rs,false);
					str += GROUP_SEP+append+GROUP_SEP;
				}
				else {
					str+=v;
				}
				i++;
			}
		}
		// faces
		var list = str.split("¤");
		var str = "";
		for (i in 0...list.length) {
			str+=list[i];
			var fid = rs.random(100)+1;
			if ( i<list.length-1 ) str+="<img src='img_faces/"+fid+".gif' alt='"+fid+"' class='face'/>";
		}
		// numbers
		var list = str.split("#");
		var str = "";
		for (i in 0...list.length) {
			str+=list[i];
			if ( i<list.length-1 ) str+=""+(rs.random(9)+1);
		}
		// letters
		var list = str.split("µ");
		var str = "";
		for (i in 0...list.length) {
			str+=list[i];
			if ( i<list.length-1 ) str+=""+String.fromCharCode("a".charCodeAt(0)+rs.random(26));
		}

		str = StringTools.replace(str,"*"," ");
		str = StringTools.replace(str,"€","");
		str = replaceVars(str);
		if ( fl_firstRecurs ) {
			str = applyLang("fr",str);
			str = StringTools.replace(str,GROUP_SEP,"");
			if ( fl_autoCaps )
				str = capitalize(str);

			str = StringTools.replace(str,",.",".");
			str = StringTools.replace(str,"\"\"","\"");
			str = StringTools.replace(str,", ?","?");
			str = StringTools.replace(str,", !","!");
			if ( fl_underscoreRep )
				str = StringTools.replace(str,"_"," ");
			str = trim(str); // attention, trim efface les \n !
			str = StringTools.replace(str,"| ","|");
			str = StringTools.replace(str,"|","\n");
			str = StringTools.replace(str,"[PCT]","%");
		}
		return str;
	}

	public function check() {
		for(k in texts.keys()) {
			var wlist = texts.get(k);
			for (w in wlist) {
				if ( w.split(VAR_SEP).length%2==0 ) fatal("invalid var : ["+w+"]");
				var keys = w.split("%");
				var i = 1;
				if ( keys.length%2==0 )
					fatal("(CHECK) invalid string ["+w+"] in ["+k+"]");
				for (v in keys) {
					v = v.toLowerCase();
					if ( i%2==0 )
						if ( v.indexOf(EXTERNAL_SEP)>=0 ) {
							var a = v.split(EXTERNAL_SEP);
							if ( getOtherXml(a[0],a[1])==null )
								fatal("(CHECK) unknown external reference ["+v+"] in ["+k+"]");
						}
						else
							if ( texts.get(v)==null )
								fatal("(CHECK) unknown reference ["+v+"] in ["+k+"]");
					i++;
				}
			}
		}
	}


	public function set(key:String, value:String, ?fl_isName=false) {
		if (fl_isName) {
			var words = value.split("_");
			for (i in 0...words.length)
				words[i] = words[i].substr(0,1).toUpperCase() + words[i].substr(1);
			value = words.join(" ");
		}
		tvars.set(key,value);
	}

	public function resetVars() {
		tvars = new Hash();
	}


	public function capitalize(str:String) {
		var chars = str.split("");
		chars[0] = chars[0].toUpperCase();
		str = "";
		var fl_cap = true;
		for (c in chars) {
			if ( isLetter(c) )
				if ( fl_cap ) {
					c = superUpper(c);
					fl_cap = false;
				}
			if ( !Math.isNaN(Std.parseInt(c)) )
				fl_cap = false;
			str+=c;
			if ( c=="." || c=="?" || c=="!" || c=="|" )
				fl_cap = true;
		}
		return str;
	}


	// *** PRIVATE

	function isLetter(c:String) {
		var code = c.charCodeAt(0);
		return
			code>=65 && code<=90 ||
			code>=97 && code<=122 ||
			SPECIAL_LETTERS.indexOf(c)>=0;
	}

	function isVoyel(c:String) {
		c = c.toLowerCase();
		return
			c=="a" || c=="e" || c=="i" || c=="o" || c=="u" || c=="y"||
			VOYEL_LOWERS.indexOf(c)>=0 || VOYEL_UPPERS.indexOf(c)>=0;
	}

	function superUpper(c:String) {
		var up = c.toUpperCase();
		if ( up!=c )
			return up;
		else {
			// caractères spéciaux
			var lowers = VOYEL_LOWERS + CONS_LOWERS;
			var uppers = VOYEL_UPPERS + CONS_UPPERS;
			var idx = lowers.indexOf(c);
			if ( idx>=0 )
				return uppers.substr(idx,1);
			// inconnu
			return c;
		}
	}

	function matchTransition(w1:String,w2:String, v1, v2) {
		if( w2 == null ) return false; // TODO : vérifier la valeur null de w2 qui lance une exception

		if ( w1.indexOf(GROUP_SEP)<0 && w2.indexOf(GROUP_SEP)<0 )
			return false;
		w1 = StringTools.replace(w1.toLowerCase(),GROUP_SEP,"");
		w2 = StringTools.replace(w2.toLowerCase(),GROUP_SEP,"");
		return w1==v1 && w2==v2;
	}

	function matchVoyelTransition(w1:String,w2:String, v1) {
		if( w2 == null ) return false; // TODO : vérifier la valeur null de w2 qui lance une exception

		if ( w1.indexOf(GROUP_SEP)<0 && w2.indexOf(GROUP_SEP)<0 )
			return false;
		w1 = StringTools.replace(w1.toLowerCase(),GROUP_SEP,"");
		w2 = StringTools.replace(w2,GROUP_SEP,"");
		return w1==v1 && isVoyel( w2.substr(0,1) );
	}


	function applyLang(lang:String,str:String) {
		var words = str.split(" ");
		switch (lang) {
			case "fr"	:
				str = "";
				for (i in 0...words.length) {
					var w = words[i].toLowerCase();
					if ( matchVoyelTransition(w,words[i+1],"de") )
						str+="d'";
					else if ( matchVoyelTransition(w,words[i+1],"que") )
						str+="qu'";
					else if ( matchVoyelTransition(w,words[i+1],"du") )
						str+="de l'";
					else if ( matchVoyelTransition(w,words[i+1],"le") )
						str+="l'";
					else if ( matchTransition(w,words[i+1], "de", "le") ) {
						str+="du";
						words[i+1]="";
					}
					else if ( matchTransition(w,words[i+1], "à", "le") ) {
						str+="au";
						words[i+1]="";
					}
					else
						str+=words[i]+" ";
				}
		}
		return str;
	}


	function replaceVars(str:String) {
		var base = str;
		if ( str==null || str.length<=0 ) return str;
		var list = str.split(VAR_SEP);
		if ( list.length==1 ) return str;

		str = "";
		var i=0;
		for (key in list) {
			if (i++%2==0) {
				str+=key;
				continue;
			}
			else {
				if ( tvars.get(key)==null ) fatal("unknown variable '"+key+"' in : "+base);
				str+=tvars.get(key);
			}
		}
		return str;
	}



	function trim(str:String) {
		while (str.charAt(0)==" " || str.charAt(0)=="\t") str = str.substr(1);
		while (str.charAt(str.length-1)==" " || str.charAt(str.length-1)=="\t") str = str.substr(0,str.length-1);
		while ( str.indexOf("  ")>=0 )
			str = StringTools.replace(str,"  "," ");
		str = StringTools.replace(str," ,",",");
		str = StringTools.replace(str,"\n","");
		str = StringTools.replace(str,"\r","");
		return str;
	}

	function fatal(msg:String) {
		throw "["+xmlName+"] "+msg;
	}
}
