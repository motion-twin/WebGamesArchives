package data;

typedef Virus = {
	id			: String,
	name		: String,
	desc		: String,
	target		: String,
	size		: Int,
	power		: Int,
	info		: Int,
	cc			: Int,
	uses		: Int,

	price		: Int,
	cat			: String,
	catName		: String,
	date		: Date,
	level		: Int,

	recom		: Bool,
	start		: Bool,
}


private class AllData extends haxe.xml.Proxy<"../xml/virus.xml",Virus> {
}

class VirusXml {
	static var HIDDEN = ["hidden","specials"];

	public static var ALL : Hash<Virus> = new Hash();
	public static var get : AllData = null;

	#if neko
		static var autoRun = init();
	#end

	public static function init() {
		#if flash
			var raw = Manager.getEncodedXml("virus");
		#end
		#if neko
			var raw = neko.io.File.getContent( neko.Web.getCwd() + Const.get.XML + "virus.xml" );
		#end

		var xml = Xml.parse(raw);
		var doc = new haxe.xml.Fast( xml.firstElement() );
		var h : Hash<Virus> = new Hash();
		for (catnode in doc.nodes.cat)
			for (vnode in catnode.nodes.v)
				getFromNode(h, vnode, catnode.att.id, catnode.att.name);

		// non triés dans une catégorie ?
		for (vnode in doc.nodes.v)
			throw "found uncategorized virus : "+vnode.att.id;
		ALL = h;
		get = new AllData(ALL.get);
	}


	public static function getDesc(v:Virus, ?combo:Int) {
		var str = v.desc;
		if ( combo==null ) {
			// on vire les blocs optionnels "[ ]" si on ne fourni pas l'infos des pts de combo
			str = StringTools.replace(str,"]","[");
			var list = str.split("[");
			str = "";
			var i = 0;
			while(i<list.length) {
				if (i%2==0)
					str+=list[i];
				i++;
			}
			combo = 1;
		}
		else {
			str = StringTools.replace(str,"[","");
			str = StringTools.replace(str,"]","");
		}

		return replaceVars(str, {_p:v.power, _s:v.size, _cc:v.cc, _info:v.info, _pcombo:v.power*combo});
	}

	public static function getCategorized(gl:Int, ?fl_alsoHidden=false) : Hash<List<Virus>> {
		var h = new Hash();
		for (v in ALL) {
			if ( !fl_alsoHidden && isHidden(v) )
				continue;
			if ( !isUnlocked(v,gl) )
				continue;
			if ( !h.exists(v.cat) )
				h.set(v.cat, new List());
			h.get(v.cat).add(v);
		}
		return h;
	}

	public static function getCategory(cat:String, gl:Int, ?fl_alsoHidden=false) {
		return getCategorized(gl, fl_alsoHidden).get(cat);
	}

	public static function getCategories(gl:Int) {
		var h = new Hash();
		for (v in ALL)
			if ( !isHidden(v) && isUnlocked(v,gl) )
				h.set(v.cat, v.catName);
		return h;
	}


	// virus reçus à la création d'un nouveau compte User
	public static function getStartingViruses() {
		var list = Lambda.filter(ALL, function(v) { return v.start; });
		return list;
	}

	public static function isHidden(v:Virus) {
		for (s in HIDDEN)
			if (s==v.cat)
				return true;
		return false;
	}

	public static function isUnlocked(v:Virus,gl:Int) {
		return
			( v.level<=gl ) &&
//			( v.price>0 && v.price<20000 ) &&
			( v.price>0 ) &&
			( v.date==null || v.date.getTime() <= Date.now().getTime() );
	}

	public static function createInstance(vkey:String) {
		var v = ALL.get(vkey);
		if ( v==null )
			#if flash
				Manager.fatal("createInstance : unknown virus "+vkey);
			#else
				throw "createInstance : unknown virus "+vkey;
			#end
		return Reflect.copy(v);
	}


	// *** PRIVATES

	static function getFromNode(h:Hash<Virus>,vnode:haxe.xml.Fast, catId:String, catName:String) {
		var id = vnode.att.id;
		if( id == null )
			throw "Missing 'id' in virus.xml : "+vnode;
		if( h.exists(id) )
			throw "Duplicate '"+id+"' in virus.xml : "+vnode;
		var desc = trim(vnode.innerData);
		var data : Virus = {
			id			: id,
			name		: if(vnode.has.name) vnode.att.name else id,
			desc		: desc,
			target		: if(vnode.has.t) vnode.att.t else "_file",
			size		: Std.parseInt(vnode.att.size),
			power		: if(vnode.has.p) Std.parseInt(vnode.att.p) else 0,
			info		: if(vnode.has.info) Std.parseInt(vnode.att.info) else 0,
			cc			: if(vnode.has.cc) Std.parseInt(vnode.att.cc) else 0,
			uses		: if(vnode.has.use) Std.parseInt(vnode.att.use) else null,
			price		: if(vnode.has.pr) Std.parseInt(vnode.att.pr) else 9999,
			cat			: catId,
			catName		: catName,
			date		: if(vnode.has.date) Date.fromString( StringTools.replace(vnode.att.date,"/","-")+" 06:00:00" ) else null,
			level		: if(vnode.has.l) Std.parseInt( vnode.att.l ) else 1,
			recom		: vnode.has.recom,
			start		: vnode.has.start,
		}
		h.set(id,data);
	}

	static function replaceVars(str:String, data:Dynamic) {
		for (field in Reflect.fields(data))
			str = StringTools.replace(str, "::"+field.substr(1)+"::", Std.string(Reflect.field(data, field)));
		return str;
	}

	static function trim(str:String) {
		str = StringTools.replace(str,"\n","");
		while (str.charAt(0)==" " || str.charAt(0)=="\t" ) str = str.substr(1);
		while (str.charAt(str.length-1)==" " || str.charAt(str.length-1)=="\t") str = str.substr(0,str.length-1);
		return str;
	}

}
