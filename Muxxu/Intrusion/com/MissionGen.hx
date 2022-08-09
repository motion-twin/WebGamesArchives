import data.TextXml;

typedef MissionData = {
	_seed		: Int,
	_corp		: String,
	_color		: Int,
	_short		: String,
	_details	: String,
	_prime		: Int,
	_bonus		: Int,
	_type		: _MissionPattern,
	_xp			: Int,
	_gl			: Int,
	_cards		: List<String>,
}


enum _MissionPattern {
	_MModerate(owner:String);
	_MDelete(owner:String, fname:String);
	_MDeleteAll(owner:String, ext:String);
	_MCopy(fname:String, owner:String);
	_MSteal(fname:String, owner:String);
	_MCrashDB(fname:String);
	_MDeliverFile(parentKey:String, parentName:String, file:String,to:String);

	_MCrashPrinter(name:String);
	_MCrashTerminal(owner:String);
	_MCleanTerminal(owner:String);

	_MCopyMail(owner:String,sender:String);
	_MFindMails(owner:String,n:Int);
	_MPasswords(name:String);
	_MCleanSecurity();
	_MCamRec(fname:String);
	_MCleanCriminal(name:String);

	_MSpy(name:String);
	_MCompromiseMail(owner:String);
	_MFalsifyCam(sector:String);
	_MSpyCam;
//	_MSpyPad(); // TODO
	_MArrest(name:String);
	_MCorruptDisplay(place:String);
	_MOverwriteFiles(owner:String,ext:String);
	_MGameHack(game:String,serv:String,char:String);
	_MInfectNet(v:String);
	_MGetVirus(v:String,ext:String,n:Int);
	_MTutorial;
	_MTutorialDelete(ext:String,n:Int);
	_MTutorialBypass(f:String);
	_MTV(tvFrom:String,tvTo:String);
	_MTVCrash(tv:String);
	_MTVTheft(tv:String, program:String);

//	_MStealATM;
//	_MScanMails; // TODO
//	_MCopyCrypted(owner:String,sender:String);
}


class MissionGen {
	static var XP_LEVELS = [
		0,	// level 1
		1,	// level 2
		2,	// level 3
		3,	// level 4
		10,	// level 5
		30,	// level 6
		90, // level 7
		150,// level 8
		250,// level 9
	];
		//0,	// level 1
		//1,	// level 2
		//2,	// level 3
		//3,	// level 4
		//20,	// level 5
		//60,	// level 6
		//100,// level 7
		//150,// level 8
		//200,// level 9

	static var TRIES_REDUC = [
		0.90,
		0.85,
		0.80,
		0.75,
		0.70,

		0.65,
		0.60,
		0.56,
		0.53,
		0.50,
	];
	static public var CORP_COLORS = [
		"#14341F",
		"#132335",
		"#261B34",
		"#371606",
		"#2F380C",
		"#2E0C17",
	];

	var texts		: TextXml;
	var fsNames		: TextXml;
	var names		: TextXml;


	public function new(t,fs,n) {
		texts = t;
		fsNames = fs;
		names = n;
	}


	public static function getPrimeByLevel(gl:Int, ?rseed:mt.Rand) {
		var total = Math.floor( 400 + Math.pow(gl, 1.45)*400 );

		// -30 % de variation
		if ( rseed!=null )
			total = Math.round(0.7*total + rseed.random(30)/100*total);

		return {
			total	: total,
			prime	: Math.floor(total*0.6/10)*10,
			bonus	: Math.floor(total*0.4),
		};
	}

	public function generate(glevel:Int,seed:Int) : MissionData {
		var rseed = new mt.Rand(0);
		rseed.initSeed(seed);

		var list = getMissionList(rseed,glevel);


		/*** Missions forcées
		#if debug
			list = [
//				_MTutorialDelete("mail",5),
				_MTVTheft(names.get("hotTv"), names.get("hotProgTheft")),
//				_MTutorial,
			];
		#end
		/***/

		var mtype = list[rseed.random(list.length)];
//		var total = Math.floor( 400 + Math.pow(glevel, 1.4)*400 );
//		total = Math.round(0.7*total + rseed.random(30)/100*total); // -30 % de variation

//		var prime = Math.floor(total*0.6/10)*10;
//		var bonus = Math.floor(total*0.4);
		var mprime = getPrimeByLevel(glevel, rseed);
		switch(mtype) {
			case _MTutorial :
				mprime.prime = 500;
				mprime.bonus = 0;
			case _MTutorialDelete(ext,n) :
				mprime.prime = 700;
				mprime.bonus = 0;
			case _MTutorialBypass(f) :
				mprime.prime = 800;
				mprime.bonus = 0;
			default :
		}

		var m : MissionData = {
			_seed	: seed,
			_color	: getCorpColor(rseed),
			_prime	: mprime.prime,
			_bonus	: mprime.bonus,
			_corp	: names.get("corp"),
			_short	: "",
			_details	: "",
			_type	: mtype,
			_xp		: 1,
			_gl		: glevel,
			_cards	: new List(),
		}
		fillObjective(m);
		return m;
	}


	function drawOne(rseed:mt.Rand, list:Array<Dynamic>) {
		return list[ rseed.random(list.length) ];
	}


	function getMissionList(rseed:mt.Rand,glevel) {
		var list = new Array();
		if ( glevel==1 )
			list = list.concat([
				_MTutorial,
			]);
		if ( glevel==2 )
			list = list.concat([
				_MTutorialDelete("mail",5),
			]);
		if ( glevel==3 )
			list = list.concat([
				_MTutorialBypass(fsNames.get("tutorial_doc")),
			]);
		if ( glevel>=4 && glevel<5 )
			list = list.concat([
				_MDelete(names.get("musername"),fsNames.get("mission_doc")),
//				_MInfectNet(names.get("virusname")),
			]);
		if ( glevel>=4 && glevel<6 )
			list = list.concat([
				_MCleanTerminal(names.get("musername")),
				_MCopy(names.get("musername"),fsNames.get("mission_doc")),
				_MSteal(names.get("musername"),fsNames.get("mission_doc")),
			]);
		if ( glevel>=4 && glevel<7 )
			list = list.concat([
				_MCopyMail(names.get("musername"),names.get("musername")),
			]);

		if ( glevel>=5 ) {
			var parentKey = drawOne(rseed,["/doc","/mail"]);
			list = list.concat([
				_MSpy(names.get("musername")),
				_MDeliverFile(parentKey, fsNames.get(parentKey), fsNames.get("secret.doc"), names.get("musername")),
			]);
		}
		if ( glevel>=5 && glevel<7 )
			list = list.concat([
				_MGetVirus(names.get("virusname"),drawOne(rseed,["lib","prog"]),rseed.random(5)+5),
				_MCrashPrinter(fsNames.get("/sys_printer")),
				_MCrashTerminal(names.get("musername")),
			]);
		if ( glevel>=6 )
			list = list.concat([
				_MCorruptDisplay(texts.get("place").toLowerCase()),
				_MPasswords(fsNames.get("/sys_db")),
				_MDeleteAll(names.get("musername"),"mail"),
//				_MSpyPad(),
			]);
		if ( glevel>=6 && glevel<9 )
			list = list.concat([
				_MDeleteAll(names.get("musername"),"doc"),
				_MModerate(names.get("musername")),
				_MOverwriteFiles(names.get("musername"),"doc"),
				_MOverwriteFiles(names.get("musername"),"mail"),
			]);
		if ( glevel>=7 )
			list = list.concat([
				_MFindMails(names.get("musername"),rseed.random(3)+2),
				_MCompromiseMail(names.get("musername")),
				_MTV(names.get("hotTv"),names.get("badTv")),
				_MTVTheft(names.get("tv"), names.get("tvProgTheft")),
				_MTVTheft(names.get("hotTv"), names.get("hotProgTheft")),
				_MTVCrash(names.get("tv")),
				_MCrashDB(fsNames.get("/sys_db")),
			]);
		if ( glevel>=8 )
			list = list.concat([
				_MSpyCam,
				_MCleanSecurity,
				_MCamRec(fsNames.get("archive.video")),
				_MGameHack(names.get("gameName"), names.get("gameServer"), names.get("gameChar")),
			]);

		if ( glevel>=9 )
			list = list.concat([
				_MCleanCriminal(names.get("musername")),
				_MFalsifyCam(fsNames.get("roomMission")),
				_MArrest(names.get("musername")),
			]);
		return list;
	}

	function getCorpColor(rseed) {
		var cstr = CORP_COLORS[rseed.random(CORP_COLORS.length)];
		return Std.parseInt( StringTools.replace(cstr,"#","0x") );
	}

	public static function getMissionEffectName(mdata:MissionData) : String {
		switch(mdata._type) {
			case _MGetVirus(v,ext,n) :
				return v;
			default :
				return null;
		}
	}

	function makeTextData(m:MissionData) {
		switch(m._type) {
			case _MModerate(str) :
				texts.set("owner",str,true);
			case _MDelete(owner,fname)	:
				texts.set("owner",owner,true);
				texts.set("file",fname);
			case _MDeleteAll(owner,ext) :
				texts.set("owner",owner,true);
				texts.set("ext",ext);
			case _MCopy(owner,fname) :
				texts.set("owner",owner,true);
				texts.set("file",fname);
			case _MSteal(owner,fname) :
				texts.set("owner",owner,true);
				texts.set("file",fname);
			case _MCrashPrinter(str) :
				texts.set("target",str);
			case _MCrashTerminal(owner)	:
				texts.set("owner",owner,true);
			case _MCrashDB(str) :
				texts.set("target",str);
			case _MCleanTerminal(owner) :
				texts.set("owner",owner,true);
			case _MCopyMail(owner,sender) :
				texts.set("owner",owner,true);
				texts.set("sender",sender,true);
			case _MFindMails(owner,n) :
				texts.set("owner",owner,true);
			case _MPasswords(str) :
				texts.set("target",str);
			case _MCleanSecurity :
			case _MCamRec(fname) :
				texts.set("file",fname);
			case _MCleanCriminal(name) :
				texts.set("name",name,true);
			case _MSpy(name) :
				texts.set("name",name,true);
			case _MCompromiseMail(name) :
				texts.set("name",name,true);
			case _MFalsifyCam(sector) :
				texts.set("sector",sector,true);
			case _MSpyCam :
			case _MArrest(name) :
				texts.set("name",name);
			case _MCorruptDisplay(place) :
				texts.set("place",place);
			case _MDeliverFile(pk,pname,file,to) :
				texts.set("folder", pname);
				texts.set("file",file);
				texts.set("name",to);
			case _MOverwriteFiles(owner,ext) :
				texts.set("name",owner);
				texts.set("ext",ext.toUpperCase());
			case _MGameHack(game,server,char) :
				texts.set("game",game);
				texts.set("server",server);
				texts.set("char",char);
			case _MInfectNet(v) :
				texts.set("vname",v);
			case _MGetVirus(v,ext,n) :
				texts.set("vname",v);
				texts.set("ext",ext.toUpperCase());
			case _MTutorial :
			case _MTutorialDelete(ext,n) :
				texts.set("ext",ext.toUpperCase());
				texts.set("n",Std.string(n));
			case _MTutorialBypass(f) :
				texts.set("file",f);
			case _MTV(tf,tt) :
				texts.set("tvFrom",tf);
				texts.set("tvTo",tt);
			case _MTVTheft(tv,program) :
				texts.set("tv",tv);
				texts.set("program",program);
			case _MTVCrash(tv) :
				texts.set("tv",tv);

		}
		texts.set("corp",m._corp);
	}

	function fillObjective(m:MissionData) {
		makeTextData(m);
		var tkey = Std.string(m._type).substr(1).split("(")[0];
		m._short = texts.get(tkey);
		var details = texts.get(tkey+"_details");
		switch(m._type) {
			case _MTutorialDelete(ext,n) :
				m._details = details;
			default :
				texts.set("briefing", details);
				if ( isTutorial(m) )
					m._details = texts.get("briefing");
				else
					m._details = texts.get("missionDetails");
		}
	}

	public static function getTime(mdata:MissionData, leetMode:Bool) {
		var t = 999 + switch(mdata._type) {
			case _MTutorialDelete(ext,n) :
				DateTools.hours(24);
			default :
				DateTools.minutes(2+mdata._gl*0.5);
		}
		if ( mdata._gl==4 )
			t += DateTools.minutes(10);

		if ( mdata._gl==5 )
			t += DateTools.minutes(1);

		#if debug
//			t+=DateTools.minutes(20);
		#end
		if (leetMode)
			t+=DateTools.seconds(40);
		return t;
	}

	public static function hasTimer(mdata:MissionData) {
		return !isTutorial(mdata);
//		return switch(mdata._type) {
//			case _MTutorial :
//				false;
//			case _MTutorialDelete(ext,n) :
//				false;
//			default :
//				true;
//		}
	}

	public static function getGameLevel( xp : Int ) {
		var gl = 0;
		for (lxp in XP_LEVELS)
			if ( xp>=lxp )
				gl++;
		return gl;
	}

	public static function getXp( gl:Int ) {
		if ( gl<=0 )
			return 0;
		if ( gl>XP_LEVELS.length )
			return 9999;
		else
			return XP_LEVELS[gl-1];
	}

	public static function getPrime(base:Int,tries:Int) {
		if ( tries<=0 )
			return base;
//		tries = Std.int( Math.min( TRIES_REDUC.length-1, tries ) );
		if ( tries>=getMaxTries() )
			return 0;
		else
			return Math.ceil(base*TRIES_REDUC[tries-1]);
	}

	public static function getMaxTries() {
		return TRIES_REDUC.length;
	}

	public static function getTutorial(mdata:MissionData) {
		#if flash
		switch (mdata._type) {
			case _MTutorial :
				return Tutorial.get.first;
			case _MTutorialDelete(ext,n) :
				return Tutorial.get.second;
			case _MTutorialBypass(f) :
				return Tutorial.get.third;
			default :
				return null;
		}
		#end
	}

	public static function isType(mdata:MissionData, mtype:_MissionPattern) {
		return Type.enumIndex(mdata._type) == Type.enumIndex(mtype);
	}

	public static function isTutorial(mdata:MissionData) {
		return mdata._gl<=3;
	}

}

