import mt.deepnight.RandList;
import mt.deepnight.Tweenie;

class Manager { //}
	public static var WID = Std.int(flash.Lib.current.stage.stageWidth);
	public static var HEI = Std.int(flash.Lib.current.stage.stageHeight);
	public static var ME : Manager;
	static var URL = ""; //#if debug "http://dev.teacherstory.com" #else "http://teacher-story.fr" #end;
	
	var root			: flash.display.MovieClip;
	var docs			: Array<Array<String>>;
	var tw				: Tweenie;
	var lang			: String;
	
	var seed			: Int;
	var rseed			: mt.Rand;
	var words			: Array<String>;
	var doc				: Array<String>;
	var mistakes		: IntHash<Bool>;
	var marks			: Array<{spr:flash.display.Sprite, wid:Int, lid:Int}>;
	var markNotes		: IntHash<flash.text.TextField>;
	var markCont		: flash.display.Sprite;
	var field			: flash.text.TextField;
	var notesDB			: Array<String>;
	var noteId			: Int;
	var studentColor	: Int;
	var teacherColor	: Int;
	var result			: flash.text.TextField;
	var resultLine		: lib.SouligneProf;
	var resultSide		: flash.text.TextField;
	var validateBt		: flash.text.TextField;
	var comment			: flash.text.TextField;
	var commentsDB		: IntHash<String>;
	var started			: Bool;
	var done			: Bool;
	var clicks			: Int;
	
	var friendScore		: Int;
	var friendName		: Null<String>;
	var vips			: Array<{name:String, fname:String, rank:Int}>;
	var locale			: Hash<String>;
	var retry			: Int;
	
	public function new(r) {
		ME = this;
		root = r;
		root.addEventListener( flash.events.Event.ENTER_FRAME, main );
		root.buttonMode = true;
		tw = new Tweenie();
		friendScore = -1;
		retry = 2;
		
		lang = root.loaderInfo.parameters.lang;
		if( lang==null )
			lang = "fr";
		lang = lang.toLowerCase();
		#if debug
		trace(lang);
		#end
		
		var key = root.loaderInfo.parameters.key;
		#if debug
		trace("key="+key);
		#end
		
		//if( !useKey("10;1943;d98c0;deepnight") )
		if( !useKey(key) ) {
			#if debug
			if( key!=null && key!="null" )
				trace("invalid key "+key);
			#end
			friendName = null;
			friendScore = -1;
			seed = Std.random(99999);
		}
		
		done = false;
		started = false;
		clicks = 0;
		#if debug
		seed = 9025;
		trace("seed="+seed);
		#end
		rseed = new mt.Rand(0);
		rseed.initSeed(seed);
		mistakes = new IntHash();
		marks = new Array();
		notesDB = new Array();
		markNotes = new IntHash();
		
		var colors = [0x2F4D91, 0x393987, 0x307E91];
		studentColor = colors[rseed.random(colors.length)];
		teacherColor = 0xCC0000;
		
		for( line in rsc("notes").split("\n") ) {
			line = StringTools.trim(line);
			if( line.length==0 )
				continue;
			notesDB.push(line);
		}
		noteId = rseed.random(notesDB.length);
		
		locale = new Hash();
		for( line in rsc("locale").split("\n") ) {
			if( line.indexOf("/")<=0 )
				continue;
			var k = StringTools.trim( line.split("/")[0] ).toLowerCase();
			var v = StringTools.trim( line.split("/")[1] );
			locale.set(k,v);
		}
		
		
		docs = new Array();
		var ndocs = 0;
		var raw = rsc("docs");
		var k = null;
		for(l in raw.split("\n")) {
			if( StringTools.trim(l).length==0 )
				continue;
			if( l.charAt(0)!="\t" ) {
				k = StringTools.trim(l);
				ndocs++;
				docs.push( new Array() );
				docs[docs.length-1].push(k);
			}
			else {
				var s = StringTools.replace( StringTools.trim(l), "\n", "" );
				if( s.length>0 ) {
					docs[docs.length-1].push(s);
					if( s.length>50 )
						trace("WARNING: line too long ('"+s+"')");
					if( docs[docs.length-1].length>13 )
						trace("WARNING: '"+k+"' has too many lines");
				}
			}
		}
		
		for( d in docs ) {
			var chars = 0;
			for(l in d)
				chars+=l.length;
			if( chars<430 )
				trace("WARNING: text too short ("+chars+" chars in "+d[0]+")");
		}
		
		for( d in docs )
			d.push("  "+locale.get("endline")+" ("+d.splice(0,1)[0]+")");
		initRand();
		doc = docs[rseed.random(docs.length)];
		#if debug
		doc = docs[6];
		#end
		
		var cookie = flash.net.SharedObject.getLocal("corrector");
		var plays = Std.parseInt( Reflect.field(cookie.data, "plays") );
		if( plays==null || Math.isNaN(plays) )
			plays = 0;

		
		commentsDB = new IntHash();
		for( line in rsc("globalComments").split("\n") )
			if( line.length!=0 )
				commentsDB.set( Std.parseInt(line.split("/")[0]), StringTools.trim( line.split("/")[1] ) );

				
				
		var vip = null;
		vips = new Array();
		for( line in rsc("vip").split("\n") ) {
			line = StringTools.trim(line);
			if( line.length!=0 )
				vips.push({
					name : line.split("/")[0],
					fname : line.split("/")[1],
					rank: Std.parseInt(line.split("/")[2]),
				});
		}
		if( rseed.random(100)<8 )
			vip = vips[rseed.random(vips.length)];
			

		initRand();
		//if( plays>=4 ) {
			if( vip!=null )
				scramble( Std.int(20 * (1-vip.rank/10)) );
			else
				scramble( 6 + rseed.random(14) );
		//}
		//else
			//scramble(9 + rseed.random(11));
		capitalize();
		for(i in 0...words.length)
			words[i] = StringTools.replace(words[i], ">", "");
		for(i in 0...doc.length)
			doc[i] = StringTools.replace(doc[i], ">", "");
		
		
		var bg = new flash.display.Sprite();
		root.addChild(bg);
		bg.graphics.beginFill(0xF9F5F0, 1);
		bg.graphics.drawRect(0,0,WID,HEI);

		var bg = new lib.Feuille();
		root.addChild(bg);
		bg.gotoAndStop( rseed.random(bg.totalFrames)+1 );
		
		var ct = new flash.geom.ColorTransform();
		ct.color = studentColor;
		var x = Std.random(100)<50 ? 0 : 110;
		var line = new lib.Lignes();
		var l1 = rseed.random(line.totalFrames)+1;
		root.addChild(line);
		line.gotoAndStop( l1 );
		line.x = x + rseed.random(15);
		line.y = 125 + rseed.random(5);
		line.width = WID-x;
		line.transform.colorTransform = ct;
		
		var line = new lib.Lignes();
		var l2 = -1;
		while( l2<0 || l2==l1 )
			l2 = rseed.random(line.totalFrames)+1;
		#if debug
		trace([l1,l2]);
		#end
		root.addChild(line);
		line.gotoAndStop( l2 );
		line.x = x + rseed.random(15);
		line.y = 220 + rseed.random(5);
		line.width = WID-x;
		line.transform.colorTransform = ct;
		
		// ELEVE
		var names = [];
		var fnames = [];
		var list = names;
		for( l in rsc("names").split("\n") ) {
			l = StringTools.trim(l);
			if( l.length==0 )
				continue;
			if( l=="---" )
				list = fnames;
			else
				list.push(l);
		}
		
		
		// NOM
		var x = Std.random(20)+32;
		var tf = createField("student",24,studentColor);
		root.addChild(tf);
		var str = vip!=null ? vip.name : names[ rseed.random(names.length) ];
		tf.text = str;
		tf.x = x;
		tf.y = 70;
		if( str.length>=15 )
			tf.rotation = -3;
		
		// PRENOM
		var tf = createField("student",24,studentColor);
		root.addChild(tf);
		var str = vip!=null ? vip.fname : fnames[ rseed.random(fnames.length) ];
		tf.text = str;
		tf.x = x+Std.random(3);
		tf.y = 94;
		
		// DATE
		var d = Date.now();
		var m = locale.get("months").split(";");
		var tf = createField("student",24,studentColor);
		root.addChild(tf);
		var day = d.getDate();
		tf.text = day+(lang!="en"?"" : (day==1?"st":day==2?"nd":day==3?"rd":"th"))+" "+StringTools.trim(m[d.getMonth()])+" "+d.getFullYear();
		tf.x = WID-tf.textWidth-15;
		tf.y = 74;
		
		// TITRE
		var tf = createField("student",24,studentColor);
		root.addChild(tf);
		tf.text = locale.get("title");
		tf.x = Std.int(WID*0.5-tf.textWidth*0.5);
		tf.y = 77;
		var spr = new lib.SouligneEleve();
		root.addChild(spr);
		spr.x = tf.x + tf.textWidth*0.5;
		spr.y = tf.y+35;
		spr.gotoAndStop( rseed.random(spr.totalFrames)+1 );
		spr.transform.colorTransform = ct;
		
		
		var txt = doc.join("\n");
		field = createField("student", 22, studentColor);
		field.mouseEnabled = true;
		field.x = 115 + rseed.random(20);
		field.y = 234;// + rseed.random(3);
		field.width = WID-field.x;
		field.height = 600;
		field.text = txt;
		root.addChild(field);
		
		// RATURES
		var scratches = new Array();
		var i = 0;
		for(c in txt.split("")) {
			if( c=="*" )
				scratches.push(i);
			i++;
		}
		var letters = ["a","e","k","n","r","s","u","v","x"];
		for(pos in scratches) {
			var r = field.getCharBoundaries(pos);
			var spr = new lib.Ratures();
			spr.x = field.x + r.x+r.width*0.5-2;
			spr.y = field.y + r.y+r.height*0.5;
			spr.scaleX = 0.7;
			spr.gotoAndStop(rseed.random(spr.totalFrames)+1);
			if( spr.currentFrame<=3 )
				spr.rotation = Std.random(360);
			//spr.gotoAndStop(3);
			spr.transform.colorTransform = ct;
			root.addChild(spr);
			field.text = field.text.substr(0,pos) + letters[rseed.random(letters.length)] + field.text.substr(pos+1);
		}
		//trace(scratches);
		
		markCont = new flash.display.Sprite();
		markCont.x = field.x;
		markCont.y = field.y;
		//markCont.filters = [ new flash.filters.GlowFilter(teacherColor,0.7, 4,4, 1) ];
		root.addChild(markCont);
		
		// COMMENTAIRE GLOBAL
		var tf = createField("teacher", 70, teacherColor, 0.1);
		comment = tf;
		markCont.addChild(tf);
		tf.x = 120 + Std.random(50);
		tf.y = -120;
		tf.width = 350;
		tf.height = 250;
		tf.multiline = tf.wordWrap = true;
		tf.rotation = Std.random(8) * (Std.random(2)*2-1);
		//#if !debug
		comment.visible = false;
		//#end
		
		// NOTE FINALE
		result = createField("teacher", 120, teacherColor);
		result.height = 80;
		result.rotation = 5 + Std.random(5)*(Std.random(2)*2-1);
		markCont.addChild(result);
		var tf = createField("teacher", 90, teacherColor);
		resultSide = tf;
		tf.x = 50;
		tf.y = -100;
		tf.text = lang=="es" ? "/10" : "/20";
		tf.rotation = Std.random(3);
		markCont.addChild(tf);
		resultLine = new lib.SouligneProf();
		markCont.addChild(resultLine);
		updateResult();
		
		var tf = createLink(locale.get("finish"), 55, teacherColor);
		validateBt = tf;
		root.addChild(tf);
		tf.x = WID - tf.textWidth - 10;
		tf.y = HEI - tf.textHeight - 35;
		tf.addEventListener( flash.events.MouseEvent.CLICK, onValidate );
	
		// Trous perforés
		if( rseed.random(100)<70 ) {
			var holes = new lib.Perfo();
			root.addChild(holes);
			holes.filters = [
				new flash.filters.GlowFilter(0xCFBA9A,1, 2,2,2, 1,true),
				new flash.filters.GlowFilter(0xCFBA9A,0.8, 8,8,1, 1,true),
			];
		}
				
		root.stage.addEventListener( flash.events.MouseEvent.CLICK, onClick );
		#if debug
		started = true;
		#else
		introScreen();
		#end
		
		plays++;
		Reflect.setField(cookie.data, "plays", plays);
		cookie.flush();
	}
	
	function rsc(id:String) {
		return haxe.Resource.getString(id+"."+lang);
	}
	
	function createField(font:String, size:Int, col:Int, ?leading=1.0) {
		var f = new flash.text.TextFormat();
		f.font = font;
		f.size = size;
		if( font=="teacher" )
			f.leading = -30;
		else
			f.leading = 7*leading;
		
		var tf = new flash.text.TextField();
		tf.defaultTextFormat = f;
		tf.embedFonts = true;
		tf.textColor = col;
		tf.mouseWheelEnabled = false;
		tf.mouseEnabled = tf.selectable = false;
		tf.width = 450;
		tf.height = 100;
		tf.mouseEnabled = true;
		return tf;
	}
	
	function createLink(text:String, size,col) {
		if( text==null ) text = "!missing text!";
		var tf = createField("teacher", size, col);
		var f = tf.getTextFormat();
		f.underline = true;
		tf.defaultTextFormat = f;
		tf.height = 200;
		tf.text = text;
		tf.width = tf.textWidth+10;
		tf.height = tf.textHeight+50;
		tf.addEventListener( flash.events.MouseEvent.MOUSE_OVER, function(_) {
			tf.filters = [ new flash.filters.GlowFilter(col, 0.7, 16,4,1) ];
		});
		tf.addEventListener( flash.events.MouseEvent.MOUSE_OUT, function(_) {
			tf.filters = [];
		});
		return tf;
	}
	
	inline function initRand() {
		rseed.initSeed(seed);
	}
	
	function scramble(need:Int) {
		initRand();
		if( need<1 )
			need = 1;
		#if debug
		trace("mistakes = "+need);
		#end
		words = new Array();
		for(l in doc) {
			l = l.toLowerCase();
			words = words.concat( splitWords(l) );
			words.push("\n");
		}
		while( words.remove("") ) {};
		
		var swaps : Hash<Array<String>> = new Hash();
		for(line in rsc("swaps").split("\n")) {
			line = StringTools.trim(line);
			if( line.length==0 )
				continue;
			var w1 = line.split(" ")[0];
			var w2 = line.split(" ")[1];
			if( swaps.exists(w1) )
				swaps.get(w1).push(w2);
			else
				swaps.set(w1, [w2]);
			if( swaps.exists(w2) )
				swaps.get(w2).push(w1);
			else
				swaps.set(w2, [w1]);
		}
		

		var rlist : Array<String->String> = new Array();
		
		switch(lang) {
			case "fr" :
				// S final
				rlist.push( function(w) {
					if( w.length>3 && isVoyel( w.charAt(w.length-1) ) )
						return w+"s";
					else
						return null;
				});
				
				// E final
				rlist.push( function(w) {
					if( w.length>3 && (endsWith(w,"i") || endsWith(w,"é")) )
						return w+"e";
					else
						return null;
				});
				
				// Double lettres oubliées
				rlist.push( function(w:String) {
					if( w.indexOf("ll")>=0 )
						return StringTools.replace(w,"ll","l");
					else if( w.indexOf("pp")>=0 )
						return StringTools.replace(w,"pp","p");
					else if( w.indexOf("ss")>=0 )
						return StringTools.replace(w,"ss","s");
					else
						return null;
				});

				// Double L inutile
				rlist.push( function(w) {
					return doubleLetter(w,"l");
				});
				
				// Double M inutile
				rlist.push( function(w) {
					return doubleLetter(w,"m");
				});
				
				// Double P inutile
				rlist.push( function(w) {
					return doubleLetter(w,"p");
				});

				// Terminaisons
				rlist.push( function(w) {
					if( endsWith(w, "ez") )
						return w.substr(0, w.length-1)+"r";
					else if( endsWith(w, "er") )
						return w.substr(0, w.length-1)+"z";
					else if( endsWith(w, "ait") )
						return w.substr(0, w.length-3)+"er";
					else if( endsWith(w, "ais") )
						return w.substr(0, w.length-3)+"er";
					else return null;
				});
				
			case "en" :
				// S final
				rlist.push( function(w) {
					if( w.length>3 && isVoyel( w.charAt(w.length-1) ) )
						return w+"s";
					else
						return null;
				});
				
			case "es" :
				// transformations diverses
				rlist.push( function(w) {
					return
						if( w.indexOf("ll")>=0 )
							StringTools.replace(w,"ll","y");
						else if( w.indexOf("y")>=0 )
							StringTools.replace(w,"y","i");
						else if( w.indexOf("v")>=0 )
							StringTools.replace(w,"v","b");
						else if( w.indexOf("b")>=0 )
							StringTools.replace(w,"b","v");
						else if( w.indexOf("rr")>=0 )
							StringTools.replace(w,"rr","r");
						else if( w.indexOf("ch")>=0 )
							StringTools.replace(w,"ch","sh");
						else null;
				});
				
				// H en début de mot
				rlist.push( function(w) {
					return if( w.length>2 && isVoyel(w.charAt(0)) ) "h"+w else null;
				});
				
				// transformation QU -> K
				rlist.push( function(w) {
					return if( contains(w, "qu", true, false) )
						StringTools.replace(w,"qu", "k");
					else
						null;
				});
				
		}

		
		// swaps
		rlist.push( function(w) {
			if( swaps.exists(w) )
				return StringTools.replace( swaps.get(w)[rseed.random(swaps.get(w).length)], "_", " " ); // ATTENTION : caractère 255 !
			else return null;
		});
				
		var tries = 1000;
		while( tries>0 && need>0 ) {
			var idx = rseed.random(words.length);
			if( mistakes.exists(idx) )
				continue;
			var w = words[idx];
			if( w.length>1 ) {
				rlist.sort( function(a,b) {
					return rseed.random(2)*2-1;
				});
				
				for( fn in rlist ) {
					var res = fn(w);
					if( res!=null ) {
						mistakes.set(idx,true);
						#if debug
						trace(res);
						#end
						words[idx] = res;
						need--;
						break;
					}
				}
				tries--;
			}
		}

		// Ratures
		//for(i in 0...words.length) {
			//var w = words[i];
			//if( rseed.random(100)<10 && w.length>2 ) {
				//var j = rseed.random(w.length);
				//w = w.substr(0,j)+"*"+w.substr(j);
				//words[i] = w;
			//}
		//}
		
		var text = "";
		var i = 0;
		for( w in words ) {
			if( w=="i" && lang=="en" )
				w = "I";
			//#if debug
			//if( hasMistake(i) )
				//text+="<font color='#ff0000'>"+w+"</font>";
			//else
			//#end
				text+=w;
			i++;
		}
		if( tries<=0 ) {
			trace(text);
			throw "failed";
		}
		doc = text.split("\n");
	}
	
	
	
	
	function capitalize() {
		var cap = true;
		for(y in 0...doc.length) {
			var l = doc[y];
			for(x in 0...l.length) {
				var c = l.charAt(x);
				if( c=="." || c=="!" || c=="?" || c==">" )
					cap = true;
				if( cap && isLetter( removeAccent(c) ) ) {
					cap = false;
					l = l.substr(0,x) + removeAccent(c).toUpperCase() + l.substr(x+1);
				}
			}
			doc[y] = l;
		}
	}
	
	function splitWords(str:String) {
		var words = new Array();
		var start = 0;
		for(i in 0...str.length) {
			var c = str.charAt(i);
			if( c==" " || c=="." || c==";" || c=="," || c=="!" || c=="?" || c==":"  || c=="'" || c==">" ) {
				words.push( str.substr(start, i-start) );
				words.push(c);
				start = i+1;
			}
		}
		words.push(str.substr(start));
		return words;
	}
	
	inline function isVoyel(cc:String) {
		var c = removeAccent(cc);
		return c=="a" || c=="e" || c=="i" || c=="o" || c=="u" || c=="y";
	}
	
	static var ACCENTS = [
		["âäà","a"],
		["éèêë","e"],
		["îïìí","i"],
		["ôöòó","o"],
		["ûüùú","u"],
		["ç","c"],
		["ñ","n"],
	];
	function removeAccent(c:String) {
		for( acc in ACCENTS )
			if( acc[0].indexOf(c)>=0 )
				return acc[1];
		return c;

	}
	inline function isLetter(c:String) {
		var c = removeAccent(c).charCodeAt(0);
		return
			c=="*".code ||
			c>="a".code && c<="z".code ||
			c>="A".code && c<="Z".code ; // TODO accents
	}
	inline function isNumber(c:String) {
		var c = c.charCodeAt(0);
		return
			c>="0".code && c<="9".code;
	}
	
	inline function lastLetter(s:String) {
		return s.charAt(s.length-1);
	}
	
	inline function endsWith(s:String, end:String) {
		return s.length>end.length && s.indexOf(end) == s.length-end.length;
	}
	
	inline function contains(s:String, sub:String, ?voyBefore=false, ?voyAfter=false) {
		if( !voyAfter && !voyBefore )
			return s.indexOf(sub)>=0;
		else {
			var i = s.indexOf(sub);
			return
				i>=0
				&& ( voyBefore ? ( i==0 ? false : isVoyel(s.charAt(i-1)) ) : true )
				&& ( voyAfter ? ( i+sub.length>=s.length ? false : isVoyel(s.charAt(i+sub.length)) ) : true );
		}
	}
	
	inline function containsSingleton(str:String, c:String) {
		var i = str.indexOf(c);
		return i>0 && i<=str.length-2 && str.indexOf(c+c)!=i;
	}
	
	function doubleLetter(str:String, c:String) : String{
		if( containsSingleton(str, c) ) {
			var i = str.indexOf(c);
			if( !isVoyel(str.charAt(i-1)) || !isVoyel(str.charAt(i+1)) )
				return null;
			str = str.substr(0,i+1) + c + str.substr(i+1);
			return str;
		}
		else
			return null;
	}
	
	inline function hasMistake(idx) {
		return mistakes.exists(idx) && mistakes.get(idx);
	}
	
	function getWordAt(x:Float,y:Float) {
		x-=field.x;
		y-=field.y;
		var cid = field.getCharIndexAtPoint(x,y);
		if( cid<0 )
			return null;
		var c = field.text.charAt(cid);
		if( !isLetter(c) && !isNumber(c) )
			return null;
		var r = field.getCharBoundaries(cid);
		
		var idx = 0;
		var wid = 0;
		var lid = 0;
		var start = -1;
		var end = -1;
		var word = null;
		for(w in words) {
			idx+=w.length;
			if( w=="\n" )
				lid++;
			if( idx>cid ) {
				word = w;
				start = idx-w.length;
				if( w.length>1 )
					end = idx-1;
				else
					end = idx;
				break;
			}
			wid++;
		}
		return {
			word	: word,
			wid		: wid,
			lid		: lid,
			start	: field.getCharBoundaries(start),
			end		: field.getCharBoundaries(end),
		}
	}
	
	function addMark(x:Float,y:Float) {
		var inf = getWordAt(x,y);
		if( inf==null )
			return;
			
		clicks++;
		
		// suppression
		for(m in marks) {
			if( m.wid==inf.wid ) {
				m.spr.parent.removeChild(m.spr);
				marks.remove(m);
				updateNotes();
				updateResult();
				return;
			}
		}
		
		var spr = new flash.display.Sprite();
		markCont.addChild(spr);
		spr.mouseChildren = spr.mouseEnabled = false;
		spr.x = inf.start.x - Std.random(7) + 5;
		spr.y = inf.start.y+22;
		
		if( Std.random(100)<50 ) {
			// Entouré
			var m = new lib.Entoure();
			m.gotoAndStop( Std.random(m.totalFrames)+1 );
			m.x = (inf.end.x - inf.start.x)*0.5 + 4;
			m.width = inf.end.x - inf.start.x + 10;
			m.height = 25 + Std.random(10);
			spr.addChild(m);
		}
		else {
			// Souligné
			spr.graphics.lineStyle(1, teacherColor, 0.8);
			var y = 5+Std.random(3);
			spr.graphics.moveTo(0, y);
			spr.graphics.lineTo(inf.end.x-inf.start.x + 6, y);
			if( Std.random(100)<30 ) {
				spr.graphics.moveTo(Std.random(3), y+Std.random(2)+3);
				spr.graphics.lineTo(inf.end.x-inf.start.x + 7 + Std.random(4), y+3-Std.random(3)-1);
			}
			spr.rotation = -Std.random(3);
		}

		tw.create(root, "y", 3, TShakeBoth, 200);
		
		marks.push({spr:spr, wid:inf.wid, lid:inf.lid});
		updateResult();
		updateNotes();
	}
	
	function updateNotes() {
		// ajout
		for(m in marks) {
			if( !markNotes.exists(m.lid) ) {
				var tf = createField("teacher", 50, teacherColor);
				tf.text = notesDB[noteId];
				tf.x = -tf.textWidth-5 - Math.random()*Math.max(0, 80-tf.textWidth);
				//tf.x = -130 + Math.max(0, 60-tf.textWidth);
				tf.y = m.spr.y - Std.random(20)-10;
				//tf.x = m.spr.x + Std.random(20);
				//tf.y = m.spr.y ;
				tf.rotation = -Std.random(5);
				markNotes.set(m.lid, tf);
				markCont.addChild(tf);
				noteId+=Std.random(3)+1;
				//#if !debug
				tf.alpha = 0;
				var x = tf.x;
				var y = tf.y;
				var d = 200;
				tf.x-=tf.textWidth;
				tf.y-=tf.textHeight+50;
				tf.scaleX = tf.scaleY = 2;
				tw.create(tf,"x", x, TBurnOut, d);
				tw.create(tf,"y", y, TBurnOut, d);
				tw.create(tf, "alpha", 1, TEaseOut, d).onEnd = function() {
					//tw.create(root, "y", 3, TShakeBoth, 200);
				}
				tw.create(tf, "scaleX", 1, TBurnOut, d).onUpdate = function() {
					tf.scaleY = tf.scaleX;
				}
				//#end
				if( noteId>=notesDB.length )
					noteId-=notesDB.length;
			}
		}
		
		// suppression
		for(lid in markNotes.keys()) {
			var n = 0;
			for(m in marks)
				if( m.lid==lid )
					n++;
			if( n==0 ) {
				var tf = markNotes.get(lid);
				tw.terminate(tf);
				tf.parent.removeChild(tf);
				markNotes.remove(lid);
			}
		}
	}

	
	function updateResult() {
		var note = 20-marks.length;
		//#if debug note -= 10; #end
		if( note<0 )
			note = 0;
		result.text = Std.string( lang=="es" ? note*0.5 : note );
		result.scaleX = result.scaleY = 1 + 1-note/20;
		result.x = 50 - result.textWidth*result.scaleX;
		result.y = -90 - 40*result.scaleX;
		tw.create(result,"y", result.y-5, TLoop, 400);
		result.alpha = 0.2;
		tw.create(result, "alpha", 1, TEaseOut, 500);
		
		resultLine.gotoAndStop(note>=8 ? 1 : note>=4 ? 2 : note>=2 ? 3 : 4);
		resultLine.x = result.x+50;
		resultLine.y = result.y+120 + (note<=9 ? 20 : 0 );
		resultLine.visible = false;
		
		result.visible = resultSide.visible = clicks>0;
		
		if( commentsDB.exists(note) ){
			comment.text = commentsDB.get(note);
			comment.y = Std.int(-60 - comment.textHeight*0.5);
		}
	}
	
	function onClick(_) {
		if( done || !started )
			return;
		var mx = root.mouseX;
		var my = root.mouseY;
		addMark( mx,my );
	}
	
	function onValidate(_) {
		var d = 300;
		
		done = true;
		result.visible = true;
		resultSide.visible = true;
		
		validateBt.visible = false;
		
		resultLine.visible = true;
		resultLine.alpha = 0;
		tw.create(resultLine, "alpha", 1, d);
		
		comment.visible = true;
		comment.alpha = 0;
		comment.scaleX = comment.scaleY = 3;
		var x = comment.x;
		var y = comment.y;
		comment.x-=100;
		comment.y-=100;
		tw.create(comment,"alpha",1, TLinear, d);
		tw.create(comment,"x",x, TBurnOut, d);
		tw.create(comment,"y",y, TBurnOut, d);
		var a = tw.create(comment,"scaleX",1, TBurnOut, d);
		a.onUpdate = function() {
			comment.scaleY = comment.scaleX;
		}
		a.onEnd = function() {
			tw.create(root, "y", 5, TShakeBoth, 700);
		}
		haxe.Timer.delay( finalScreen, #if debug 0 #else 1500 #end );
	}
	
	function introScreen() {
		var intro = new flash.display.Sprite();
		root.addChild(intro);
		intro.y = 0;
		//intro.alpha = 0;
		//tw.create( intro,"alpha", 1, 1000);
		
		var bg = new flash.display.Sprite();
		intro.addChild(bg);
		bg.alpha = 0.92;
		bg.graphics.beginFill(0xffffff,1);
		bg.graphics.drawRect(0,0,WID,HEI);
		bg.filters = [
			new flash.filters.GlowFilter(0x0,0.4, 4,4,1),
			new flash.filters.DropShadowFilter(8,90, 0x0,0.3, 16,16 )
		];
		
		if( friendScore>=0 ) {
			var tf = createField("teacher", 80, studentColor);
			intro.addChild(tf);
			if( friendName==null )
				tf.text = locale.get("defy");
			else
				tf.text = StringTools.replace( locale.get("defyname"), "%1", friendName );
			tf.x = WID*0.5 - tf.textWidth*0.5;
			tf.y = 150;
		}
		
		var tf = createField("teacher", 80, teacherColor);
		intro.addChild(tf);
		tf.text = locale.get("goal");
		tf.x = WID*0.5 - tf.textWidth*0.5;
		tf.y = 200;
		
		//var tf = createField("teacher", 80, teacherColor);
		//intro.addChild(tf);
		//tf.text = "maintenant, c'est vous le prof !";
		//tf.x = WID*0.5 - tf.textWidth*0.5;
		//tf.y = 250;
		
		var tf = createLink(locale.get("clickstart"), 80, studentColor);
		intro.addChild(tf);
		tf.x = WID*0.5 - tf.textWidth*0.5;
		tf.y = 350;
		
		intro.addEventListener( flash.events.MouseEvent.CLICK, function(_) {
			intro.mouseEnabled = intro.mouseChildren = false;
			tw.create(intro,"alpha", 0, TLinear, 500).onEnd = function() {
				intro.parent.removeChild(intro);
				started = true;
			}
		});
	}
		
	function finalScreen() {
		var ok = 0;
		var err = 0;
		for(m in marks)
			if( mistakes.exists(m.wid) )
				ok++;
			else
				err++;
		var total = Lambda.count(mistakes);
		var ratio = ok/total;
		var miss = total-ok;

		var final = new flash.display.Sprite();
		root.addChild(final);
		final.alpha = 0;
		final.y = 300;
		tw.create( final,"alpha", 1, 1000);
		
		var bg = new flash.display.Sprite();
		final.addChild(bg);
		bg.alpha = 0.92;
		bg.graphics.beginFill(0xffffff,1);
		bg.graphics.drawRect(0,0,WID,350);
		bg.filters = [
			new flash.filters.GlowFilter(0x0,0.5, 32,32,1),
			new flash.filters.DropShadowFilter(8,90, 0x0,0.3, 16,16 )
		];
		
		//var bg = new lib.Inspect();
		//final.addChild(bg);

		var base = 60;
		
		if( friendScore>=0 ) {
			var tf = createField("teacher", 60, studentColor);
			final.addChild(tf);
			tf.width = WID;
			if( friendScore>0 )
				if( friendScore<=1 )
					tf.text = locale.get("friendscore1");
				else
					tf.text = StringTools.replace(locale.get("friendscoremany"), "%1", Std.string(friendScore));
			else
				tf.text = locale.get("friendscore0");
			tf.x = WID*0.5 - tf.textWidth*0.5;
			tf.y = base-40;
		}

		var tf = createField("teacher", 80, miss>0 ? teacherColor : 0x0);
		var bilan1 = tf;
		final.addChild(tf);
		tf.width = WID;
		if( ok<=1 )
			tf.text = StringTools.replace( StringTools.replace(locale.get("score1"), "%1", ""+ok), "%2", ""+total );
		else
			tf.text = StringTools.replace( StringTools.replace(locale.get("scoremany"), "%1", ""+ok), "%2", ""+total );
		tf.x = WID*0.5 - tf.textWidth*0.5;
		tf.y = base+60;
		tf.visible = ok==0;
		//if( miss>0 ) {
			//var tf = createField("teacher", 45, 0x0);
			//final.addChild(tf);
			//tf.width = WID;
			//tf.text = "Mais qui s'en soucie, franchement ?";
			//tf.x = WID*0.5 - tf.textWidth*0.5;
			//tf.y = base+45;
		//}
		
		var bilan2 = null;
		if( marks.length>0 && err>0 ) {
			var tf = createField("teacher", 60, teacherColor);
			bilan2 = tf;
			final.addChild(tf);
			tf.width = WID;
			if( err==0 )
				tf.text = locale.get("err0");
			else
				if( err==1 )
					tf.text = locale.get("err1");
				else
					tf.text = StringTools.replace(locale.get("errmany"), "%1", ""+err);
			tf.x = WID*0.5 - tf.textWidth*0.5;
			tf.y = base+130;
			tf.visible = ok==0;
		}
		
		var bar = new lib.Bar();
		bar.x = WID*0.5 - bar.width*0.5;
		bar.y = base+15;
		bar.masque.scaleX = 0.02;
		final.addChild(bar);
		bar.barre.scaleX = bar.masque.scaleX;
		var a = tw.create(bar.masque, "scaleX", Math.max(0.02, ratio), TEase, 2500);
		a.onUpdate = function() {
			bar.barre.scaleX = bar.masque.scaleX;
		}
		a.onEnd = function() {
			bilan1.visible = true;
			if( bilan2!=null )
				bilan2.visible = true;
		}
		
		var key = makeKey(ok);
		
		var tf = createLink(locale.get("send"), 70, studentColor);
		final.addChild(tf);
		tf.x = WID*0.20 - tf.textWidth*0.5;
		tf.y = base+170;
		tf.addEventListener(flash.events.MouseEvent.CLICK, function(_) {
			var url = new flash.net.URLRequest(URL+"/marked/"+key);
			flash.Lib.getURL(url, "_self");
		});
		
		//if( ok!=total ) {
			//var tf = createLink("Ré-essayer", 60, studentColor);
			//final.addChild(tf);
			//tf.x = WID*0.55 - tf.textWidth*0.5;
			//tf.y = base+180;
			//tf.addEventListener(flash.events.MouseEvent.CLICK, function(_) {
				//var url = new flash.net.URLRequest(URL+"/mark/"+key);
				//flash.Lib.getURL(url, "_self");
			//});
		//}
		
		if( retry>0 ) {
			var tf = createLink(locale.get("retry")+" ("+retry+")", 50, studentColor);
			final.addChild(tf);
			tf.x = WID*0.50 - tf.textWidth*0.5;
			tf.y = base+180;
			tf.addEventListener(flash.events.MouseEvent.CLICK, function(_) {
				final.mouseEnabled = final.mouseChildren = false;
				tw.create(final, "alpha", 0).onEnd = function() {
					final.parent.removeChild(final);
					comment.visible = false;
					resultLine.visible = false;
					validateBt.visible = true;
					retry--;
					done = false;
				}
			});
		}

		var tf = createLink(locale.get("newgame"), 50, studentColor);
		final.addChild(tf);
		tf.x = WID*0.80 - tf.textWidth*0.5;
		tf.y = base+180;
		tf.addEventListener(flash.events.MouseEvent.CLICK, function(_) {
			var url = new flash.net.URLRequest(URL+"/mark");
			flash.Lib.getURL(url, "_self");
		});
	}
	
	function useKey(k:String) {
		if( k==null )
			return false;
		try {
			friendScore = Std.parseInt(k.split(";")[0]);
			seed = Std.parseInt(k.split(";")[1]);
			friendName = k.split(";")[3];
			var chk = k.split(";")[2];
			var chk2 = makeKey(friendScore).split(";")[2];
			return chk == chk2;
		}
		catch(e:Dynamic) {
			trace("ERR: "+e);
			return false;
		}
	}
	
	function makeKey(score:Int) {
		var chk = haxe.Md5.encode("supakey"+seed+"-"+score).substr(0,5);
		return score+";"+seed+";"+chk;
	}
	
	function main(_) {
		tw.update();
		
		var g = markCont.graphics;
		g.clear();
		var inf = getWordAt(root.mouseX, root.mouseY);
		if( started && !done && inf!=null && inf.start!=null && inf.end!=null ) {
			root.useHandCursor = root.buttonMode = true;
			g.beginFill(teacherColor, 0.05);
			g.drawRect(inf.start.x, inf.start.y, inf.end.right-inf.start.x, inf.end.bottom-inf.start.y);
		}
		else
			root.useHandCursor = root.buttonMode = false;
	}
}



