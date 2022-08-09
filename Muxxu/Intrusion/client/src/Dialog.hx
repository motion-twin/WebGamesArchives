import Types;
import UserTerminal;

typedef Phrase = {
	str		: String,
	fnext	: String,
}

enum HPhrase {
	Assert(s:String);
	ShowOrders;
	EndCall;
//	AssertName(s:String,d:Int);
//	Order(s:String,cb:Void->Void,d:Int);
//	GetInfo(s:String,info:String);
}

enum DPart {
	D_Intro;
//	D_Thema;
	D_Assert;
//	D_Failure;
}

class Dialog {
	static var MAX_TRUST	= 6;
	static var CORRECT		= 1;
	static var INCORRECT	= -2;

	var term		: UserTerminal;

	var trust		: Int;
	var name		: String;
	var hname		: String;
	var phone		: String;
	var part		: DPart;
	var round		: Int;

	var rmcList		: List<MCField>;
	var bar			: BarMC;

	var weakness	: List<String>;
	var strength	: List<String>;
	var usedThemas	: Hash<Int>;

	var current		: Phrase;

	public function new(t:UserTerminal, n:String) {
		term = t;
		name = n;
		phone = getPhone(term.mdata._seed, name);
		hname = TD.names.get("firstman")+" "+TD.names.get("lastname");
		trust = Math.floor(MAX_TRUST*0.5);
		rmcList = new List();
		weakness = new List();
		strength = new List();
		usedThemas = new Hash();
		round = 0;

		weakness.add("tech");
		weakness.add("fear");
		strength.add("work");

		TD.dialogs.set("tname",name);
		TD.dialogs.set("hname",hname);
		TD.dialogs.set("commservice","FooCommService");
		TD.dialogs.set("techservice","FooTechService");
		TD.dialogs.set("techitem",TD.texts.get("tech"));

		start();
	}

	public function start() {
		var mask = Manager.DM.attach("mask",Data.DP_FS);
		mask._alpha = 60;
		part = D_Intro;
		var p = getTargetSaying("t_intro");
		targetSay(p);
		addHackerPhrases();
		bar = cast Manager.DM.attach("barTerm", Data.DP_TOP);
		bar._x = 50;
		bar._y = 60;
		bar.flash._alpha = 0;
		update();
	}

	public function end(?p:Phrase) {
		for (mc in rmcList)
			mc.removeMovieClip();
		rmcList = new List();
		bar.removeMovieClip();

		if ( p!=null )
			targetSay(p);
	}

	function addHackerPhrases() {
		var plist = new Array();
		switch(part) {
			case D_Intro :
				plist = [
					Assert( TD.dialogs.get("h_thema") ),
					Assert( TD.dialogs.get("h_thema") ),
					Assert( TD.dialogs.get("h_thema") ),
				];
				part = D_Assert;
			case D_Assert :
				plist = [
					Assert( TD.dialogs.get("h_assert") ),
					Assert( TD.dialogs.get("h_assert") ),
					Assert( TD.dialogs.get("h_assert") ),
					Assert( TD.dialogs.get("h_assert") ),
					Assert( TD.dialogs.get("h_assert") ),
				];
		}

		plist.push( ShowOrders );
		plist.push( EndCall );

		var blist = new Array();
		for (p in plist)
			addButton( getLabelFromPhrase(p), callback(hackerSay,p) );
//			blist.push( { label:next+getLabel(p), cb:callback(reply,next,p) } );
//		blist.push( { label:getLabel(ShowOrders), cb:callback(addOrders) } );
//		term.showCMenu(Manager.DM, 50, 50, blist );
	}

	function addButton(label:String, cb:Void->Void) {
		var mc : MCField = cast Manager.DM.attach("logLine", Data.DP_TOP);
		mc._x = 50;
		mc._y = 80 + rmcList.length*40;
		mc.onRelease = cb;
		term.startAnim(A_Text, mc, "> "+label,-1);
		mc.field.wordWrap = true;
		mc.field._height = 50;
		mc.field._width = 500;
		rmcList.add(mc);
	}

	function targetSay(p:Phrase, ?delta=0) {
		current = p;
		var str = current.str;

		if ( delta>0 )
			str = TD.dialogs.get("t_correct")+" "+str;

		if ( delta<0 )
			str = TD.dialogs.get("t_incorrect")+" "+str;

		if ( str.length>0 )
			str = cleanUp( TD.dialogs.capitalize(str) );

		var mc : MCField = cast Manager.DM.attach("logLine", Data.DP_TOP);
		mc._x = 40;
		mc._y = 80;
		rmcList.add(mc);

		term.startAnim(A_Text, mc, name+" : "+str);

	}

	function hackerSay(p:HPhrase) {
		for (mc in rmcList)
			mc.removeMovieClip();
		rmcList = new List();

		switch(p) {
			case Assert(s) :
				var pos = getPositives(current);
				var neg = getNegatives(current);
				var pitch = getPitch(s);
				var delta = 0;
				for (w in pos)
					for (wr in pitch)
						if (w==wr)
							delta+=CORRECT;
				for (w in neg)
					for (wr in pitch)
						if (w==wr)
							delta+=INCORRECT;
				term.log("pitch="+pitch.join(",")+" pos="+pos.join(",")+" neg="+neg.join(",")+" delta="+delta);
				trust+=delta;
				if ( trust<=0 )
					end( getTargetSaying("t_fail") );
				else {
//					if ( round<=1 || Std.random(100)<40 )
//						targetSay( getTargetSaying("t_attack"), delta );
//					else
					if ( round==0 )
						targetSay( getTargetSaying("t_afterIntro"), delta );
					else
						targetSay( getTargetSaying("t_generic"), delta );
					addHackerPhrases();
				}
				update();
			case EndCall :
				end();
			case ShowOrders :
				trace("TODO !");
		}
		round++;
		term.log("round="+round);
	}



	function addOrders() {
		trace("TODO !");
		addHackerPhrases();
	}

	function getLabelFromPhrase(p:HPhrase) : String {
		switch(p) {
			case Assert(s) :
				return TD.dialogs.capitalize( (if(current.fnext!=null) TD.dialogs.get(current.fnext)+" " else "") + cleanUp(s) );
			case ShowOrders :
				return "ShowOrders";
			case EndCall :
				return "[END]";
		}
	}

	function getTrust(p:HPhrase) {
		var delta = 0;
		switch(p) {
			case Assert(s) :
				for (t in getThemas(s)) {
					if ( usedThemas.get(t)==null )
						usedThemas.set(t,1);
					else
						usedThemas.set( t, usedThemas.get(t)+1 );
					for (t2 in weakness)
						if (t==t2)
							delta++;
					for (t2 in strength)
						if (t==t2)
							delta-=2;
				}
			case ShowOrders :
			case EndCall :
		}

		if ( isConfused() )
			delta = -3;

		return delta;
	}

	function isConfused() {
		return false;
		return countThemas()>2;
	}

	function countThemas(?ignoredThemas:List<String>) {
		var n = 0;
		for (used in usedThemas.keys()) {
			var fl_ignored = false;
			if ( ignoredThemas!=null )
				for (t in ignoredThemas)
					if ( t==used ) {
						fl_ignored = true;
						break;
					}
			if ( !fl_ignored )
				n++;
		}
		trace("countThemas = "+n);
		trace(usedThemas);
		return n;
	}

	function getThemas(str:String) {
		var th = new List();
		var list = str.split("+");
		var fl_odd = false;
		var str = "";
		for (s in list) {
			if(fl_odd)
				th.add( s.toLowerCase() );
			else
				str+=s;
			fl_odd=!fl_odd;
		}
		return th;
	}

	function update() {
		bar.smc._xscale = 100 * Math.max(0, Math.min(trust,MAX_TRUST)) / MAX_TRUST;
	}


	// *** TOOLS ***

	static function getSubNumber(ascii:Array<Int>,fact:Float) {
		var res = Data.leadingZeros( ascii[ Math.floor(fact*ascii.length) ] );
		return res.substr(0,2);
	}

	public static function getPhone(seed:Int, n:String) {
		var rseed = new mt.Rand(0);
		rseed.initSeed(seed);
		var ascii = new Array();
		for (c in n.split(""))
			ascii.push( c.charCodeAt(0) );
		return
			"("+(rseed.random(8)+1)+(rseed.random(8)+1)+(rseed.random(8)+1)+") "+
			getSubNumber(ascii,0.2) +
			getSubNumber(ascii,0.4) +" "+
			getSubNumber(ascii,0.6) +
			getSubNumber(ascii,0.8);
	}

	function getTargetSaying(id:String) : Phrase {
		var s = TD.dialogs.get(id);

		// réponses forcées
		var forcedNext :String = null;
		if ( s.indexOf(">")>=0 ) {
			forcedNext = Data.trimSpaces(s.split(">")[1]);
			s = s.split(">")[0];
		}

		return {
			str		: Data.trimSpaces(s),
			fnext	: forcedNext,
		}
	}

	function getBlankPhrase() : Phrase {
		return {
			str		: "",
			fnext	: null,
		}
	}

	function getPositives(p:Phrase) : Array<String> {
		var str = p.str;
		if ( str.indexOf("+")<0 )
			return new Array();
		var words = str.split("+")[1];
		return words.split(",");
	}

	function getNegatives(p:Phrase) : Array<String> {
		var str = p.str;
		if ( str.indexOf("/")<0 )
			return new Array();
		var words = str.split("/")[1];
		return words.split(",");
	}

	function getPitch(str:String) {
		if ( str.indexOf("+")<0 )
			return new Array();
		var words = str.split("+")[1];
		return words.split(",");
	}

	function cleanUp(str:String) {
		var clist = str.split("");
		str = "";
		var fl_ignore = false;
		for (c in clist) {
			if ( c=="+" || c=="/" )
				fl_ignore = !fl_ignore;
			else
				if ( !fl_ignore )
					str+=c;
		}
		return str;

//		var list = str.split("+");
//		var fl_even = true;
//		var str = "";
//		for (s in list) {
//			if(fl_even)
//				str+=s;
//			fl_even=!fl_even;
//		}
//		return str;
	}

}
