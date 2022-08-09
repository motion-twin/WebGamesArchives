import levels.ScriptEngine;

class mode.ScriptEditor extends Mode
{
	static var INDENT_STR = "    ";

	var setName: String;

	var menuC : gui.Container;
	var styleC : gui.Container;

	var cursor : MovieClip;
	var cx : int;
	var cy : int;

	var field : TextField;
	var field_path : String;
	var original : String;

	var caretPos : int;
	var fl_focus : bool;
	var fl_lockPrev : bool;
	var fl_lockNext : bool;

	var attributes : Array<String>; // for iterator



	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(m,script:String) {
		super(m);
		_name = "$scriptEd";
		xOffset = 10;
		lock();
		fl_focus = false;
		caretPos = 0;

		var mc : { > MovieClip, field: TextField };
		mc = downcast( depthMan.attach("hammer_editor_script", Data.DP_INTERF) );
		mc._x = 7;
		mc._y = 30;
		original = script;
		field = mc.field;
		field.text = original;


		field_path = Std.cast(field);

		focus(caretPos);
	}


	/*------------------------------------------------------------------------
	PLACE LE FOCUS SUR LE FIELD
	------------------------------------------------------------------------*/
	function focus(pos) {
		Selection.setFocus( field_path; );
		Selection.setSelection( pos,pos );
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init() {
		super.init();

		unlock();

		// Interface
		var b;
		menuC = new gui.Container(this, 5,10, Data.DOC_WIDTH-10);
		gui.SimpleButton.attach( menuC, " X ", Key.ESCAPE, callback(this,endMode) );
		b = gui.SimpleButton.attach( menuC, " Reindent ", Key.ENTER, callback(this,onReIndent) );
		b.setToggleKey(Key.SHIFT);
		b = gui.SimpleButton.attach( menuC, " Clear ", null, callback(this,onClear) );
		b = gui.SimpleButton.attach( menuC, " Reload ", null, callback(this,onReload) );

		styleC = new gui.Container(this, 5,390, Data.DOC_WIDTH-10);
		gui.Label.attach( styleC, " Triggers ");
		gui.SimpleButton.attach( styleC, " tim ", null, callback(this,onTriggerTimer) );
		gui.SimpleButton.attach( styleC, " pos ", null, callback(this,onTriggerPos) );
		gui.SimpleButton.attach( styleC, " do ", null, callback(this,onTriggerDo) );
		gui.SimpleButton.attach( styleC, " end ", null, callback(this,onTriggerEnd) );
		gui.SimpleButton.attach( styleC, " birth ", null, callback(this,onTriggerBirth) );
		gui.SimpleButton.attach( styleC, " exp ", null, callback(this,onTriggerExp) );
		gui.SimpleButton.attach( styleC, " att ", null, callback(this,onTriggerAttach) );
		gui.SimpleButton.attach( styleC, " ent ", null, callback(this,onTriggerEnter) );
		gui.SimpleButton.attach( styleC, " nightm ", null, callback(this,onTriggerNightmare) );
		gui.SimpleButton.attach( styleC, " mirr ", null, callback(this,onTriggerMirror) );
		gui.SimpleButton.attach( styleC, " multi ", null, callback(this,onTriggerMulti) );
		gui.SimpleButton.attach( styleC, " ninja ", null, callback(this,onTriggerNinja) );
		styleC.endLine();
		gui.Label.attach( styleC, " Actions ");
		gui.SimpleButton.attach( styleC, " bad ", null, callback(this,onEventBad) );
		gui.SimpleButton.attach( styleC, " score ", null, callback(this,onEventScoreItem) );
		gui.SimpleButton.attach( styleC, " spec ", null, callback(this,onEventSpecItem) );
		gui.SimpleButton.attach( styleC, " kill ", null, callback(this,onEventKill) );
		gui.SimpleButton.attach( styleC, " msg ", null, callback(this,onEventMsg) );
		gui.SimpleButton.attach( styleC, " tuto ", null, callback(this,onEventTuto) );
		gui.SimpleButton.attach( styleC, " killMsg ", null, callback(this,onEventKillMsg) );
		gui.SimpleButton.attach( styleC, " ptr ", null, callback(this,onEventPointer) );
		gui.SimpleButton.attach( styleC, " killPt", null, callback(this,onEventKillPointer) );
		gui.SimpleButton.attach( styleC, " mc ", null, callback(this,onEventDecoration) );
		gui.SimpleButton.attach( styleC, " music ", null, callback(this,onEventMusic) );
		gui.SimpleButton.attach( styleC, " +tile ", null, callback(this,onEventAddTile) );
		gui.SimpleButton.attach( styleC, " -tile ", null, callback(this,onEventRemoveTile) );
		gui.SimpleButton.attach( styleC, " hide ", null, callback(this,onEventHide) );
		gui.SimpleButton.attach( styleC, " ctrig ", null, callback(this,onEventCodeTrigger) );
		gui.SimpleButton.attach( styleC, " goLvl ", null, callback(this,onEventGoto) );
		gui.SimpleButton.attach( styleC, " portal ", null, callback(this,onEventPortal) );
		gui.SimpleButton.attach( styleC, " itemLine ", null, callback(this,onEventItemLine) );
		gui.SimpleButton.attach( styleC, " set ", null, callback(this,onEventSetVar) );
		gui.SimpleButton.attach( styleC, " open ", null, callback(this,onEventOpenPortal) );
		gui.SimpleButton.attach( styleC, " dark ", null, callback(this,onEventDarkness) );
		gui.SimpleButton.attach( styleC, " fakeLID ", null, callback(this,onEventFakeLID) );
	}


	/*------------------------------------------------------------------------
	SAISIE DES CONTROLES CLAVIER
	------------------------------------------------------------------------*/
	function getControls() {

		// Attribut précédent
		if ( !Key.isDown(Key.LEFT) ) {
			fl_lockPrev = false;
		}
		if ( Key.isDown(Key.LEFT) && Key.isDown(Key.CONTROL) && !fl_lockPrev) {
			fl_lockPrev = true;
			var pos = field.text.lastIndexOf('="',caretPos-3);
			if ( pos>=0 ) {
				focus(pos+2);
			}
			else {
				focus(caretPos);
			}
		}

		// Attribut suivant
		if ( !Key.isDown(Key.RIGHT) ) {
			fl_lockNext = false;
		}
		if ( Key.isDown(Key.RIGHT) && Key.isDown(Key.CONTROL) && !fl_lockNext) {
			fl_lockNext = true;
			var pos = field.text.indexOf('="',caretPos);
			if ( pos>=0 ) {
				focus(pos+2);
			}
			else {
				focus(caretPos);
			}
		}

	}


	/*------------------------------------------------------------------------
	VIRE LES ESPACES INUTILES DU XML
	------------------------------------------------------------------------*/
	function cleanXml(s) {
		var i=0;
		var fl_trace = false;
		var fl_inString = false;
		var fl_inNode = false;
		var strChar = "";
		var pos = 0;

		s = Tools.replace(s, "/>"," />");
		while (i<s.length) {
			var c = s.substr(i,1);

			// Détection début/fin de node
			if ( c=="<" && !fl_inString ) {
				fl_inNode = true;
			}
			if ( c==">" && !fl_inString ) {
				fl_inNode = false;
			}

			if ( fl_inString ) {
				// Fin de chaine
				if ( strChar==c ) {
					fl_inString = false;
				}
			}
			else {
				// Debut de chaine
				if ( fl_inNode && (c=='"' || c=="'" ) ) {
					fl_inString = true;
					strChar = c;
				}

				// Remplacement apostrophes / guillemets
				if ( !fl_inNode && c=="'" ) {
					s = s.substr(0,i-1) +"&apos;"+ s.substr(i+1,999999);
				}
				if ( !fl_inNode && c=='"' ) {
					s = s.substr(0,i-1) +"&quot;"+ s.substr(i+1,999999);
				}

				// Detection longs espaces
				if ( !fl_trace && c==" " ) {
					fl_trace = true;
					pos = i;
				}
				if ( fl_trace && c!=" " ) {
					fl_trace = false;
					if ( i-pos>1 ) {
						s = s.substr(0,pos) +" "+ s.substr(i,999999);
						i -= (i-pos)-1;
					}
				}
			}
			i++;
		}
		return s;
	}


	/*------------------------------------------------------------------------
	RENVOIE TRUE SI LE XML A UN FORMAT VALIDE
	------------------------------------------------------------------------*/
	function isValid(raw) {
		var s = cleanXml(raw);
		var doc = new Xml(s);

		if ( doc.toString().length - s.length != 0 ) {
			return false;
		}
		else {
			return true;
		}
	}


	/*------------------------------------------------------------------------
	RENVOIE LES ATTRIBUTS D'UNE NODE
	------------------------------------------------------------------------*/
	function getAttributes(node:XmlNode) {
		var me = this;
		attributes = new Array();
		node.attributesIter(
			fun(k,v) {
				me.attributes.push(k+"=\""+v+"\"");
			}
		);

		if ( attributes.length==0 ) {
			return "";
		}
		else {
			return attributes.join(" ");
		}
	}


	/*------------------------------------------------------------------------
	RENVOIE DES ESPACES D'INDENTATION
	------------------------------------------------------------------------*/
	function getIndent(level) {
		var s="";
		for (var i=0;i<level;i++) {
			s+=INDENT_STR;
		}
		return s;
	}

	/*------------------------------------------------------------------------
	RÉINDENTATION AUTO DU XML
	------------------------------------------------------------------------*/
	function reIndent(node:XmlNode, level:int):String {
		var s = "";

		while (node!=null) {

			if ( node.nodeName!=null ) {
				if ( node.firstChild==null ) {
					// fin de branche
					s += getIndent(level)+"<"+node.nodeName+" "+getAttributes(node)+"/>\n";
				}
				else {
					// node avec enfants
					var att = getAttributes(node);
					if ( att!="" ) {
						s += getIndent(level)+"<"+node.nodeName+" "+att+">\n";
					}
					else {
						s += getIndent(level)+"<"+node.nodeName+">\n";
					}
					s += reIndent(node.firstChild, level+1);
					s += getIndent(level)+"</"+node.nodeName+">\n";
					if ( level==0 ) {
						s+="\n";
					}
				}
			}
			else {
				// texte
				var tmp = Data.cleanLeading( node.toString() );
				if ( tmp.length>1 ) {
					s +=  tmp+"\n";
				}
			}

			node = node.nextSibling;
		}
		return s;
	}


	/*------------------------------------------------------------------------
	AJOUTE DU CODE AU SCRIPT
	------------------------------------------------------------------------*/
	function append(s) {
		var before = field.text.substr(0,caretPos);
		var after = field.text.substr(caretPos,99999);
		field.text = before+"\n"+s+after;

		var pos = field.text.indexOf("#c#",0);
		field.text = Tools.replace( field.text, "#c#","" );
		focus(pos);
	}



	/*------------------------------------------------------------------------
	FERMETURE
	------------------------------------------------------------------------*/
	function endMode() {
		manager.stopChild( Tools.replace(field.text, String.fromCharCode(27),"") );
	}



	/*------------------------------------------------------------------------
	EVENTS
	------------------------------------------------------------------------*/
	function onClear() {
		field.text = "";
	}

	function onReIndent() {
		if ( isValid(field.text) ) {
			field.text = Tools.replace( field.text, String.fromCharCode(13), " ");
			var doc = new Xml( field.text );
			field.text = reIndent(doc.firstChild,0);
		}
		else {
			GameManager.warning("invalid XML");
		}
	}

	function onReload() {
		field.text = original;
	}


	function onTriggerTimer() {
		append('<'+ScriptEngine.T_TIMER+' $t="#c#">\n\n</'+ScriptEngine.T_TIMER+'>');
	}

	function onTriggerPos() {
		append('<'+ScriptEngine.T_POS+' $x="#c#" $y="" $d="">\n\n</'+ScriptEngine.T_POS+'>');
	}

	function onTriggerDo() {
		append('<'+ScriptEngine.T_DO+'>\n#c#\n</'+ScriptEngine.T_DO+'>');
	}

	function onTriggerEnd() {
		append('<'+ScriptEngine.T_END+'>\n#c#\n</'+ScriptEngine.T_END+'>');
	}

	function onTriggerBirth() {
		append('<'+ScriptEngine.T_BIRTH+' $repeat="-1">\n#c#\n</'+ScriptEngine.T_BIRTH+'>');
	}

	function onTriggerExp() {
		append('<'+ScriptEngine.T_EXPLODE+' $x="#c#" $y="">\n\n</'+ScriptEngine.T_EXPLODE+'>');
	}

	function onTriggerAttach() {
		append('<'+ScriptEngine.T_ATTACH+' $repeat="-1">\n#c#\n</'+ScriptEngine.T_ATTACH+'>');
	}

	function onTriggerEnter() {
		append('<'+ScriptEngine.T_ENTER+' $x="#c#" $y="">\n\n</'+ScriptEngine.T_ENTER+'>');
	}

	function onTriggerNightmare() {
		append('<'+ScriptEngine.T_NIGHTMARE+'>\n#c#\n</'+ScriptEngine.T_NIGHTMARE+'>');
	}

	function onTriggerMirror() {
		append('<'+ScriptEngine.T_MIRROR+'>\n#c#\n</'+ScriptEngine.T_MIRROR+'>');
	}

	function onTriggerMulti() {
		append('<'+ScriptEngine.T_MULTI+'>\n#c#\n</'+ScriptEngine.T_MULTI+'>');
	}

	function onTriggerNinja() {
		append('<'+ScriptEngine.T_NINJA+'>\n#c#\n</'+ScriptEngine.T_NINJA+'>');
	}

	function onEventBad() {
		append('<'+ScriptEngine.E_BAD+' $i="#c#" $x="" $y="" />');
	}

	function onEventScoreItem() {
		append('<'+ScriptEngine.E_SCORE+' $i="#c#" $si="" $x="" $y="" $inf="1"/>');
	}

	function onEventSpecItem() {
		append('<'+ScriptEngine.E_SPECIAL+' $i="#c#" $si="" $x="" $y="" $inf="1"/>');
	}

	function onEventMsg() {
		append('<'+ScriptEngine.E_MESSAGE+' $id="#c#" />');
	}

	function onEventTuto() {
		append('<'+ScriptEngine.E_TUTORIAL+' $id="#c#" />');
	}

	function onEventKillMsg() {
		append('<'+ScriptEngine.E_KILLMSG+'/>\n#c#');
	}

	function onEventPointer() {
		append('<'+ScriptEngine.E_POINTER+' $x="#c#" $y=""/>');
	}

	function onEventKillPointer() {
		append('<'+ScriptEngine.E_KILLPTR+'/>\n#c#');
	}

	function onEventDecoration() {
		append('<'+ScriptEngine.E_MC+' $n="#c#" $x="" $y="" $p="0" />');
	}

	function onEventMusic() {
		append('<'+ScriptEngine.E_MUSIC+' $id="#c#"/>');
	}

	function onEventKill() {
		append('<'+ScriptEngine.E_KILL+' $sid="#c#" />');
	}

	function onEventAddTile() {
		append('<'+ScriptEngine.E_ADDTILE+' $x1="#c#" $y1="" $x2="" $y2="" $type="0" />');
	}

	function onEventRemoveTile() {
		append('<'+ScriptEngine.E_REMTILE+' $x1="#c#" $y1="" $x2="" $y2="" />');
	}

	function onEventGoto() {
		append('<'+ScriptEngine.E_GOTO+' $id="#c#"/>');
	}

	function onEventHide() {
		append('<'+ScriptEngine.E_HIDE+' $borders="1#c#" $tiles="1" />');
	}

	function onEventCodeTrigger() {
		append('<'+ScriptEngine.E_CODETRIGGER+' $id="#c#" />');
	}

	function onEventPortal() {
		append('<'+ScriptEngine.E_PORTAL+' $pid="0#c#" />');
	}

	function onEventItemLine() {
		append('<'+ScriptEngine.E_ITEMLINE+' $i="#c#" $si="" $x1="" $y="" $x2="" $t="10" />');
	}

	function onEventSetVar() {
		append('<'+ScriptEngine.E_SETVAR+' $var="#c#" $value="1" />');
	}

	function onEventOpenPortal() {
		append('<'+ScriptEngine.E_OPENPORTAL+' $x="#c#" $y="" $pid="0" />');
	}

	function onEventDarkness() {
		append('<'+ScriptEngine.E_DARKNESS+' $v="#c#" />');
	}

	function onEventFakeLID() {
		append('<'+ScriptEngine.E_FAKELID+' $lid="#c#" />');
	}




	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function main() {
		super.main();

		if ( Selection.getCaretIndex()>=0 ) {
			caretPos = Selection.getCaretIndex();
		}

		if ( fl_lock ) {
			return;
		}

		getControls();
		menuC.update();
	}

}
