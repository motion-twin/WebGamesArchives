import Types;

typedef Tut = {
	id		: String,
	steps	: Array<TutStep>,
}

typedef TutStep = {
	id		: String,
	txt		: String,
	y		: Int,
	fl_auto	: Bool,
}

typedef T_TutoPop = {
	> flash.MovieClip,
	title		: flash.TextField,
	field		: flash.TextField,
	bg			: flash.MovieClip,
}

private class AllData extends haxe.xml.Proxy<"../xml/tutorials.fr.xml",Tut> {
}

class Tutorial {
	static var DEFAULT_TOP = 75;
	static var DEFAULT_MIDDLE = 150;
	static var DEFAULT_BOTTOM = 290;
	public static var ALL = initXml();

	static var term			: UserTerminal = null;
	static var current		: Tut = null;
	static var currentStep	: TutStep = null;
	static var cmc			: MCField = null;
//	static var arrow : flash.MovieClip = null;
	static var indicators	: List<flash.MovieClip> = new List();
//	public static var nextCB : Void->Void = null;
	static var pop			: T_TutoPop;


	public static function init(ut:UserTerminal) {
		term = ut;
		indicators = new List();
	}

	static function initXml() {
		var xml = Xml.parse(haxe.Resource.getString("xml_tutorials_"+Manager.LANG));
		var doc = new haxe.xml.Fast(xml.firstElement());
		var h : Hash<Tut> = new Hash();
		for( node in doc.nodes.t ) {
			var id = node.att.id;
			if( id == null )
				throw "Missing 'id' in tutorials.xml";
			if( h.exists(id) )
				throw "Duplicate id '"+id+"' in tutorials.xml";
			var data : Tut = {
				id		: id,
				steps	: new Array(),
			}
			for (snode in node.nodes.s) {
				var y =
					if ( snode.has.y )
						switch(snode.att.y) {
							case "-1"	: DEFAULT_TOP;
							case "1"	: DEFAULT_BOTTOM;
							default		: DEFAULT_MIDDLE;
						}
					else
						DEFAULT_MIDDLE;
				data.steps.push( {
					id		: snode.att.id,
					txt		: if ( snode.innerData!="-" ) snode.innerData else "",
					y		: y,
					fl_auto	: snode.has.auto,
				} );
			}
			h.set(id,data);
		}

		return h;
	}

	public static var get = new AllData(ALL.get);


	// *** GESTION

	public static function start(t:Tut) {
		end();
		current = t;
		play(current, current.steps[0].id);
	}

	public static function end() {
		cmc.removeMovieClip();
		current = null;
		currentStep = null;
//		nextCB = null;
		for (mc in indicators)
			mc.removeMovieClip();
		indicators = new List();
		print();
	}

	public static function play(t:Tut, s:String) {
		if ( s==null )
			end();
		if ( current==null )
			return false;
		if ( t.id!=current.id )
			return false;

		var sid = getStepId(s);

		if ( current.steps[sid-1]!=null && current.steps[sid-1]!=currentStep )
			return false;

		// ok !
		#if debug
			trace("Tutorial.play t="+t.id+" s="+s+" current="+current.id+" currentStep="+currentStep.id);
		#end
		currentStep = current.steps[sid];
		for (mc in indicators)
			mc.removeMovieClip();
		indicators = new List();
//		nextCB = null;

		if ( cmc._name!=null )
			term.startAnim(A_FadeRemove,cmc);


		// texte
		if ( currentStep.fl_auto ) {
			term.attachMask(onAutoNext, Data.DP_TOPTOP);
			print(currentStep.txt, currentStep.y);
//			nextCB = callback( onAutoNext, callback( );
//			term.popUp(currentStep.txt, callback(play, current, current.steps[sid+1].id));
		}
		else {
			print(currentStep.txt, currentStep.y, true);
//			term.printSide(Lang.get.TutorialTitle, "<div class='tutorial'>"+Data.htmlize(currentStep.txt)+"</div>");
		}
//			var mc : MCField = cast dm.attach("logLine", Data.DP_TOPTOP);
//			mc.field.text = "[TUTORIAL] "+currentStep.txt;
//			mc._x = Data.WID*0.5 - mc.field.textWidth*0.5;
//			mc._y = Data.HEI*0.5 - mc.field.textHeight*0.5;
//			mc._x = Math.floor(mc._x);
//			mc._y = Math.floor(mc._y);
//			term.startAnim(A_Text, mc, mc.field.text).spd*=0.5;
//			cmc = mc;
//		}
		return true;
	}

	static function getStepId(s:String) {
		var sid = 0;
		for (step in current.steps)
			if ( step.id==s )
				break
			else
				sid++;
		if ( sid>=current.steps.length )
			Manager.fatal("tutorial : unknown step "+s);
		return sid;
	}

	public static function onAutoNext() {
		term.detachMask();
		var next = getStepId(currentStep.id)+1;
		if ( next>=current.steps.length )
			end();
		else
			play( current, current.steps[next].id );
	}

	public static function point(dm:mt.DepthManager, x:Float,y:Float, rotat=0) {
		for (mc in indicators)
			if ( Math.abs(mc._x-x)<=16 && Math.abs(mc._y-y)<=16 )
				return;
		var mc = dm.attach("arrow",Data.DP_TOPTOP);
		mc._x = x;
		mc._y = y;
		mc._rotation = rotat;

		// on bouge la pop up si elle gêne
		if ( pop._name!=null ) {
			var yAvg = mc._y;
			var n = 1;
			for (ind in indicators)
				if ( ind._name!=mc._name ) {
					yAvg+=ind._y;
					n++;
				}
			yAvg = Math.round(yAvg/n);

			var global = Data.localToGlobal(mc._parent, 0, yAvg);
			if ( Math.abs((pop._y+pop._height*0.5)-global.y)<=150 )
				pop._y = DEFAULT_TOP;
			if ( Math.abs((pop._y+pop._height*0.5)-global.y)<=150 )
				pop._y = DEFAULT_BOTTOM;
		}
		indicators.add(mc);
	}

	public static function focus(dm:mt.DepthManager, x:Float,y:Float) {
		for (mc in indicators)
			if ( Math.abs(mc._x-x)<=16 && Math.abs(mc._y-y)<=16 )
				return;
		var mc = dm.attach("mapBleep",Data.DP_TOPTOP);
		mc._x = x;
		mc._y = y;
		indicators.add(mc);
	}


	public static function at(t:Tut,step:String) {
		if ( current==null || current!=t ) return false;
		return step==currentStep.id;
	}

	public static function reached(t:Tut,step:String) {
		if ( current==null || current!=t ) return true;
		for (s in current.steps) {
			if (s.id==step)
				return true;
			if (s==currentStep )
				return false;
		}
		return false;
	}

	public static function print(?str:String, ?y:Int, ?fl_blockClick=false) {
		if ( str==null || str=="" )
//			UserTerminal.CNX.JsMain.clearTutorial.call([]);
			pop.removeMovieClip();
		else {
			str = StringTools.replace(str,"::name::",term.username);

			// affichage pop-up
			var list = str.split("*");
			str = "";
			for (i in 0...list.length)
				if(i%2!=0)
					str+="<font color='#FFFF00'>"+list[i]+"</font>";
				else
					str+=list[i];
			term.startAnim(A_FadeRemove, pop);
			pop = cast Manager.DM.attach("tutoPop", Data.DP_TOPTOP);
			pop._y = y;
			pop.title.text = Lang.get.TutorialTitle;
			pop.field.htmlText = str;
			pop.field._height = pop.field.textHeight+10;
			pop.bg._height = Math.max( 81, pop.field._y + pop.field.textHeight + 10 );
			if ( fl_blockClick )
				pop.bg.onRelease = function() {};
			term.startAnim(A_FadeIn, pop).spd*=2;
			term.startAnim(A_HtmlText, pop, str);
//			UserTerminal.CNX.JsMain.printTutorial.call([
//				Lang.get.TutorialTitle, Data.htmlize(str) + if(fl_nextButton) getNextButton() else ""
//			]);
		}
	}

	static function getNextButton() {
		return "<a href='#' onClick='JsMain.nextTutoStep();return false;' class='button'>"+Lang.get.TutorialContinue+"...</a>";
	}
}
