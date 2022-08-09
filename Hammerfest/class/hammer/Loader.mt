class Loader {

	static var BASE_SCRIPT_URL =
			null;											// LOCAL

	static var BASE_SCRIPT_URL_ALT =
			"$xNOpZUjm:_wKLIcL3oV1k:fk_8PHGcn"				// http://www.hfest.net/

	static var BASE_SWF_URL =
				null;

	static var BASE_MUSIC_URL = "../sfx/";

	static var TIMEOUT = 8000;
	static var MUSIC_TIMEOUT = 32*10;
	static var MUSIC_NEAR_END = 32*2.5;

	var sendData	: void -> void;

	var fVersion	: int;
	var _gid		: String;
	var _key		: String;
	var _qid		: String;
//	var _sid		: String;
	var _mid		: String;
	var _swf		: String;
	var _musics		: Array<String>;
	var _srv		: String;
	var _families	: String;
	var _options	: String;
	var _mode		: String;

	var retry_id	: int;
	var timeOutId	: int;
	var fullurl		: String;
	var uniqueItems	: int;
	var testPlayer6	: int;
	var lv			: LoadVars;
	var save_score	: LoadVars;
	var exitUrl		: String;
	var exitParams	: String;
	var mcl			: MovieClipLoader;
	var musics		: Array<Sound>;
	var musicId		: int;
	var root_mc		: MovieClip;
	var game		: MovieClip;
	var music_mc	: MovieClip;
	var gameInst	: { main : void -> void };
	var fl_gameOver	: bool;
	var fl_exit		: bool;
	var fl_fade		: bool;
	var fl_flash8	: bool;
	var fl_saveAgain: bool;
	var rawLang		: String;
	var xmlLang		: XmlNode;

	var musicTimeOut: float;
	var nearEndTimer: float;

	var loading : {
		>MovieClip,
		bg				: MovieClip,
		title			: TextField,
		km				: TextField,
		bottom			: TextField,
		subBottom		: TextField,
		currentWeapon	: int,
		sub 	: {
			>MovieClip,
			km				: TextField,
			title			: TextField,
			bar				: MovieClip,
			currentWeapon	: int,
		}
	};

	static var URL_KEY = "$RJrjk05eeJrzp5Pazre7z9an788baz61kBKJ1EZ4";


	function new(mc) {
		Std.setVar(Std.getRoot(),"$mode", "solo");
		Std.setVar(Std.getRoot(),"$options", "");
		Std.setVar(Std.getRoot(),"$lang", "fr");
		Std.setVar(Std.getRoot(),"$shake", "1");
		Std.setVar(Std.getRoot(),"$detail", "1");
		Std.setVar(Std.getRoot(),"$sound", "0");
		Std.setVar(Std.getRoot(),"$music", "0");
		Std.setVar(Std.getRoot(),"$volume", "100");


		root_mc = mc;
		Log.setColor(0xffff00);
		timeOutId = 0;
		musicTimeOut = 0;
		nearEndTimer = 0;

		var strVersion = downcast(Std.getRoot()).$version;
		fVersion = Std.parseInt( strVersion.split(" ")[1].split(",")[0],10 );
		fl_flash8 = (fVersion!=null && !Std.isNaN(fVersion) && fVersion>=8);

		var l = "$"+downcast(root_mc).$lang;
		switch (l) {
			case "$fr"	:
				rawLang = Std.getVar(Std.getRoot(),"xml_lang_fr");
				break;
			case "$es"	:
				rawLang = Std.getVar(Std.getRoot(),"xml_lang_es");
				break;
			case "$en"	:
				rawLang = Std.getVar(Std.getRoot(),"xml_lang_en");
				break;
		}
		xmlLang = new Xml(rawLang).firstChild.firstChild;
		while ( xmlLang!=null && xmlLang.nodeName!="$statics".substring(1) ) {
			xmlLang = xmlLang.nextSibling;
		}


		_options	= downcast(root_mc).$options;
		_mode		= downcast(root_mc).$mode;

		if ( downcast(root_mc).$alt == "1" ) {
			BASE_SCRIPT_URL = BASE_SCRIPT_URL_ALT;
		}

		testPlayer6++;
		if( testPlayer6 == 1 ) {
			error(getLangStr(65)); // "Vous devez installer Flash version 7"
			lv = new LoadVars();
			lv.send("http://www.macromedia.com/shockwave/download/download.cgi?P1_Prod_Version=ShockwaveFlash&Lang=French","_blank","");
			return;
		}
		if( !initBaseUrl() ) {
			error("base init error");
			return;
		}
		var r = downcast(Std.getRoot());
		var red = Std.getVar(r,"$redirect".substring(1));
		if( red != null ) {
			lv = new LoadVars();
			Std.cast(lv)[Std.cast("$mid".substring(1))] = _mid;
			lv.send(red,"_self","POST");
			return;
		}
//		_sid = Std.getVar(Std.getRoot(),"$sid".substring(1));
		_swf = "game.swf"; //Std.getVar(Std.getRoot(),"$swf".substring(1));
		_srv = Std.getVar(Std.getRoot(),"$srv".substring(1));
		_musics	= ["music.mp3","boss.mp3","hurryUp.mp3"];
		musicId	= 0;
		musics	= new Array();

		if ( !fl_flash8 ) {
			error(getLangStr(15)+"\n\nhttp://www.macromedia.com/go/getflash");
		}
		else {
			var cookie = SharedObject.getLocal("$hd");
			fullurl = Std.getVar( downcast(cookie.data), "data");
			if ( fullurl!=null ) {
				saveAgain();
			}
			else {
				initLoader();
			}
		}

	}

	function initLoader() {
		game = Std.createEmptyMC(root_mc,1);
		music_mc = Std.createEmptyMC(root_mc,2);
		attachLoading(1);
		loading.sub.bar._xscale = 0;
		loading.sub.km.text = "";

		var u = downcast(loading)._url;
		if( u.substr(0,BASE_SWF_URL.length) != BASE_SWF_URL ) {
			error(getLangStr(66)); // "Le serveur de fichiers n'a pas �t� trouv�."
			return;
		}


		var me = this;
		mcl = new MovieClipLoader();

		mcl.onLoadError = fun(_,msg) { me.error(me.getLangStr(67)+" : "+msg+"\nURL="+BASE_SWF_URL); }; // Erreur lors du t�l�chargement
		mcl.onLoadInit = fun(_) { me.gameLoadDone() };
		if( !mcl.loadClip(BASE_SWF_URL + _swf,game) ) {
			error(getLangStr(68)+"\n\nURL="+BASE_SWF_URL);

		}
	}

	function loadMusic() {
		attachLoading(7);
		musics[musicId] = new Sound(music_mc);
		musics[musicId].loadSound(BASE_SWF_URL + BASE_MUSIC_URL +_musics[musicId], false);
		musics[musicId].onLoad = callback(this,musicLoadDone);
		musicTimeOut = MUSIC_TIMEOUT;
		nearEndTimer = MUSIC_NEAR_END;
	}

	function gameLoadDone() {
		if ( downcast(root_mc).$music!="0" ) {
			loadMusic();
		}
		else {
			gameReady();
		}
	}

	function musicLoadDone(fl:bool) {
		if ( fl ) {
			musicId++;
			if ( musicId == _musics.length ) {
				gameReady();
			}
			else {
				gameLoadDone();
			}
		}
		else {
			error(getLangStr(69)); // Une erreur a eu lieu lors du t�l�chargement de la musique
		}
	}

	function gameReady() {
		if ( Std.getVar(game,"GameManager").BASE_VOLUME == null ) {
			// invalid manager
			error( getLangStr(70) );
			return;
		}
		else {
			attachLoading(2);
			if( BASE_SCRIPT_URL == "" || _srv==null ) {
				loading.onRelease = callback(this,startGame);
			}
			else {
				loading.onRelease = callback(this,queryStart);
			}
		}
	}

	function menu(url : String) {
		lv = new LoadVars();
		if( url == null )
			url = "";
		var me = this;
		lv.onData = fun(d) {
			me.menu(url);
		};
		lv.send(url,"_self","");
	}

	function makeUrl( url : String, params : Hash<String> ) {
		var has = (url.indexOf("?",0) != -1);
		var delim;
		if( has )
			delim = "&";
		else
			delim = "?";
		params.iter(fun(k,v) {
			url += delim;
			url += k;
			url += "=";
			url += v;
			delim = "&";
		});
		return url;
	}


	function getRunId() {
		// runId
		var id = null;
		var pos = _options.indexOf("$set_".substring(1),0);
		var runId = null;
		if ( pos>=0 ) {
			pos = _options.indexOf("$_".substring(1), pos+4);
			id = Std.parseInt( _options.substr(pos+1,1), 10 );
		}
		return id;
	}

	static var BASE64 = ":_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

	function queryStart() {
		_qid = "";
		var i;
		for(i=0;i<16;i++)
			_qid += BASE64.charAt(1+Std.random(63));
		attachLoading(3);
		Std.deleteField(loading,"onRelease");
		lv = new LoadVars();
		var h = new Hash();
		h.set("$qid".substring(1),_qid);
//		h.set("$sid".substring(1),_sid);
		h.set("$mid".substring(1),_mid);
		h.set("$mode".substring(1), _mode);
		h.set("$options".substring(1), _options);

		var runId = getRunId();
		if ( runId==null ) {
			h.set("$runid",string(runId));
		}

		var url = makeUrl(BASE_SCRIPT_URL+_srv,h);
		lv.onData = callback(this,serverData);
		lv.load(url);
	}

	function serverData(s) {
		if( s == null ) {
			error( getLangStr(64) );  // Une erreur a eu lieu lors du chargement des donn�es
			return;
		}
		while( true ) {
			var c = s.charAt(s.length-1);
			if( c == " " || c == "\n" || c == "\r" || c == "\t" )
				s = s.substr(0,s.length-1);
			else
				break;
		}
		while( true ) {
			var c = s.charAt(0);
			if( c == " " || c == "\n" || c == "\r" || c == "\t" )
				s = s.substring(1);
			else
				break;
		}
		var a = s.split("&");
		var i;
		var params = new Hash();
		for(i=0;i<a.length;i++) {
			var d = a[i].split("=");
			if( d.length == 2 ) {
				params.set("$"+d[0],d[1]);
			}
		}
		_gid		= params.get("$gid");
		_key		= params.get("$key");
		_families	= params.get("$families");
		if( _gid == null || _key == null ) {
			menu(params.get("$url"));
			return;
		}
		startGame();
	}

	function startGame() {
		Std.deleteField(loading,"onRelease");
		Std.setGlobal("gameOver",callback(this,gameOver));
		Std.setGlobal("exitGame",callback(this,exitGame));


		gameInst = downcast(Std).makeNew(
			Std.getVar(game,"GameManager") ,
			game,
			{
				rawLang		: rawLang,
				fl_local	: isLocal(),
				families	: _families,
				options		: _options,
				musics		: musics,
			}
		);
		main = callback(this,mainGame);
		attachLoading(6);
	}


	function countUniques(a) {
		var n=0;
		for (var i=0;i<a.length;i++) {
			if ( a[i]!=null ) {
				n++;
			}
		}
		return n;
	}


	function asc(c) {
		return c.charCodeAt(0);
	}


	function gameOver(score:int,runId:int,stats) {

		if( fl_gameOver )
			return;

		fl_gameOver = true;


		fl_fade = true;
		attachLoading(5);
		loading._alpha = 0;
		save_score = new LoadVars();
		var me = this;
		//var c = new Codec(_key);
		var h;
		var h2;
		uniqueItems = countUniques(Std.cast(stats).$item2);

		h2 = new Hash();
		h2.set("$swfsize".substring(1),mcl.getProgress(game).bytesTotal);
		h2.set("$lsize".substring(1),downcast(Std.getRoot()).getBytesTotal());
		h2.set("$score".substring(1),score);
		if ( runId!=null ) {
			h2.set("$runid", runId);
		}
		h2.set("$p".substring(1),stats);
		h2.set("$gid".substring(1),Std.cast(_gid));
		h2.set("$mid".substring(1),Std.cast(_mid));

		h = new Hash();
		h.set("$gid".substring(1),_gid);
//		h.set("$sid".substring(1),_sid);
		//h.set("$score".substring(1),c.encode(h2));
		fullurl = makeUrl(BASE_SCRIPT_URL+_srv,h);

		if( isLocal() ) {
			error(score+" / "+h.get("$score".substring(1)).length+"b ");
		}
		else {
			sendData = fun() {
				if ( me.timeOutId>0 ) {
					me.loading.subBottom.text = me.getLangStr(60) + (me.timeOutId+1);
					if ( me.timeOutId>=3 ) {
						me.loading.bottom.text		= "";
						me.loading.subBottom.text	= me.getLangStr(72);
						var cookie = SharedObject.getLocal("$hd");
						cookie.clear();
						Std.setVar( downcast(cookie.data), "data", me.fullurl);
						var fl_cookie = cookie.flush();
						if ( fl_cookie ) {
							Log.trace("Suivez les instructions de la page Support technique (en bas du site) pour VIDER VOTRE CACHE.");
							Log.trace("D�connectez-vous puis reconnectez-vous au site, avant de lancer le jeu � nouveau: une nouvelle tentative de sauvegarde sera alors effectu�e.");
						}
						else {
							Log.trace("Sauvegarde impossible.");
							Log.trace("Pour �viter ce genre de probl�me � l'avenir, faites un clic droit sur le jeu, choisissez Param�tres, puis l'icone du Dossier dans la nouvelle fenetre. D�cochez \"Jamais\" et assurez-vous d'autoriser au moins 100ko de donn�es (en d�pla�ant la petite barre).");
						}
						me.root_mc.stop();
						Std.getGlobal("clearInterval")(me.retry_id);
					}
				}
				me.timeOutId++;
				me.save_score.load(me.fullurl+"&retry="+me.timeOutId);
			};
			sendData();
			retry_id = Std.getGlobal("setInterval")(sendData,TIMEOUT);
		}
	}


	function saveAgain() {
		attachLoading(5);
		loading.bottom.text = getLangStr(71);
		save_score = new LoadVars();
		fl_saveAgain = true;
		fl_fade = true;
		retry_id = 0;
		var me = this;
		sendData = fun() {
			if ( me.timeOutId>0 ) {
				me.loading.subBottom.text = me.getLangStr(60) + (me.timeOutId+1);
			}
			if ( me.timeOutId>=3 ) {
				Log.trace("Impossible de terminer cette sauvegarde, cette partie ne pourra pas �tre enregistr�e.");
				var cookie = SharedObject.getLocal("$hd");
				cookie.clear();
				me.root_mc.stop();
				Std.getGlobal("clearInterval")(me.retry_id);
			}
			me.timeOutId++;
			me.save_score.load(me.fullurl+"&retry="+me.timeOutId);
		};
		sendData();
		retry_id = Std.getGlobal("setInterval")(sendData,TIMEOUT);
	}


	function exitGame(url,params) {
		if ( fl_exit ) {
			return;
		}
		fl_fade		= true;
		fl_exit		= true;
		exitUrl		= url;
		exitParams	= params;
		attachLoading(6);
		loading._alpha = 0;
	}

	function replace(str : String,search : String,replace : String) {
		if( str == null )
			return null;
		var slen = search.length;
		if( slen == 1 )
			return str.split(search).join(replace);
		var npos, pos = 0;
		var s = "";
		while(true) {
			npos = str.indexOf(search,pos);
			if( npos == -1 )
				break;
			s += str.substr(pos,npos-pos)+replace;
			pos = npos + slen;
		}
		return s + str.substring(pos);
	}

	function initBaseUrl() {
		if( BASE_SCRIPT_URL == null ) {
			BASE_SCRIPT_URL = "";
			BASE_SWF_URL	= "";
		}
		return (BASE_SCRIPT_URL != null) && (BASE_SWF_URL != null);
	}

	function error(msg) {
		attachLoading(4);
		downcast(loading).error.text = "URL="+BASE_SCRIPT_URL+"\n\n\n"+msg;
		Log.trace("build="+__TIME__);
		Log.trace("msg="+msg);
		loading.onRelease = callback(this,menu,"");
	}

	function isLocal() {
		return BASE_SCRIPT_URL == "";
	}


	function isDev() {
		var fl=
			BASE_SCRIPT_URL=="" ||
			BASE_SCRIPT_URL==null ||
			BASE_SCRIPT_URL.indexOf("$dev".substring(1),0)>=0 ||
			BASE_SWF_URL.indexOf("$dev".substring(1),0)>=0;

//		return false; // hack fjv
		return fl;
	}


	function isMode(modeName) {
		return _mode == modeName.substring(1);
	}


	function getLangStr(id:int) {
		var node = xmlLang.firstChild;
		while ( node != null && node.get("$id".substring(1))!=""+id ) {
			node = node.nextSibling;
		}
		return node.get("$v".substring(1));
	}

	function getStupidTrackName() {
		var prefix = [
			"Battle for ",
			"The great ",
			"Lost ",
			"An almighty ",
			"Spirits of ",
			"Desperate ",
			"Beyond ",
			"Everlasting ",
			"Prepare for ",
			"The legend of ",
			"Blades of ",
			"Hammerfest, quest for ",
			"Wings of ",
			"Song for "
			"Unblessed ",
			"Searching for ",
			"No pain, no ",
		];

		var suffix = [
			"Igor ",
			"Wanda ",
			"hope ",
			"sadness ",
			"death ",
			"souls ",
			"glory ",
			"redemption ",
			"destruction ",
			"flames ",
			"love ",
			"forgiveness ",
			"darkness ",
			"carrot !",
		]

		return
			( (musicId<10)?"0"+(musicId+1):""+(musicId+1) ) + ". �"+
			prefix[Std.random(prefix.length)]+
			suffix[Std.random(suffix.length)]+
			"�";
	}



	function attachLoading(frame:int) {
		loading.removeMovieClip();
		loading = downcast( Std.attachMC(root_mc,"loading",99) );
		loading.gotoAndStop(""+frame);
		if ( isDev() ) {
			loading.bg.gotoAndStop("2");
		}
		else {
			loading.bg.gotoAndStop("1");
		}
		if ( frame==1 ) {
			loading.sub.currentWeapon = 1;
			loading.sub.title.text = getLangStr(50);
		}
		if ( frame==2 || frame==3 ) {
			loading.currentWeapon = 1;
			loading.title.text = getLangStr(50);
			loading.km.text = getLangStr(52);
			if ( frame==2 ) { // click to start
				loading.bottom.text		= getLangStr(53);
				if ( isMode("$tutorial") || isMode("$soccer") ) { // free modes
					loading.subBottom.text	= getLangStr(58);
				}
				else {
					if ( isDev() ) {
						loading.subBottom.text	= getLangStr(59);
					}
					else {
						loading.subBottom.text	= getLangStr(57);
					}
				}
//				var icon = downcast(loading).icon;
//				icon._x = loading.subBottom._x + loading.subBottom._width*0.5 - loading.subBottom.textWidth*0.5 - 25;
//				icon._y = loading.subBottom._y - 3;
			}
			if ( frame==3 ) { // starting...
				loading.bottom.text		= getLangStr(54);
				loading.subBottom.text	= "";
			}
		}
		if ( frame==5 ) { // saving, please wait...
			loading.bottom.text		= getLangStr(55);
			loading.subBottom.text	= getLangStr(56);
		}
		if ( frame==6 ) { // startgame fade in
		}
		if ( frame==7 ) { // loading music...
			loading.currentWeapon = 1;
			loading.sub.title.text = getLangStr(61);
			loading.sub.km.text = getStupidTrackName();
		}
	};


	/*------------------------------------------------------------------------
	REDIRECTION MANUELLE EN FIN DE PARTIE
	------------------------------------------------------------------------*/
	function redirect(url) {
		lv = new LoadVars();
		lv.send(url,"_self","GET");
	}



	/*------------------------------------------------------------------------
	BOUCLE MAIN
	------------------------------------------------------------------------*/
	function main() {
		if ( loading != null ) {
			if ( loading._currentframe==1 ) {
				var p = mcl.getProgress(game);
				if ( p.bytesTotal>0 ) {
					var r = (p.bytesLoaded/p.bytesTotal);
					loading.sub.km.text = Math.round(r*100)+" "+getLangStr(51);
					loading.sub.bar._xscale = r*100;
				}
			}

			if ( loading._currentframe==7 ) {
				var total = musics[musicId].getBytesTotal();
				var loaded = musics[musicId].getBytesLoaded();
				if ( Std.isNaN(loaded) || Std.isNaN(total) ) {
					loading.sub.bar._xscale = 0;
					musicTimeOut--;
					if ( musicTimeOut<=0 ) {
						Log.trace("Impossible de charger la musique. Merci de VIDER VOTRE CACHE INTERNET, comme expliqu� dans la section Support technique. Vous pouvez �galement d�sactiver les musiques depuis les Param�tres du jeu.\n");
						Log.trace("Vous pouvez enfin laisser un message dans le forum en pr�cisant les informations suivantes:");
						Log.trace("\n---------------\n");
						Log.trace("music #"+musicId+" timed out\nLOADED="+loaded+"\nTOTAL="+total+"\nURL="+(BASE_SWF_URL + BASE_MUSIC_URL +_musics[musicId]));
						musicTimeOut = 999999;
					}
				}
				if ( !Std.isNaN(total) && total>0 ) {
					var r = (loaded/total);
					if ( r>=0.99 ) {
						nearEndTimer--;
						if ( nearEndTimer<=0 ) {
							// forced callback
							musics[musicId].onLoad = null;
							musicLoadDone(true);
						}
					}
//					loading.sub.km.text = Math.round(r*100)+" %";
					loading.sub.bar._xscale = r*100;
				}
			}

		}
		if ( fl_saveAgain ) {
			var save_ok = Std.cast(save_score)[Std.cast("$ok").substring(1)];
			if( save_ok != null ) {
				var cookie = SharedObject.getLocal("$hd");
				cookie.clear();
				lv = new LoadVars();
				lv.send(save_ok,"_self","");
				save_score = null;
			}
		}
	}

	function mainGame() {
		if ( fl_fade ) {
			loading._alpha += 5;
			if ( loading._alpha>=100 && game._name!=null ) {
				game.removeMovieClip();
				gameInst = null;
			}
			if ( loading._alpha>=220 ) {
				loading._alpha = 100;
				fl_fade = false;
			}
		}

		if ( fl_exit ) {
			if ( !fl_fade ) {
				var lv = new LoadVars();
				if ( exitParams!=null ) {
					downcast(lv).d = exitParams;
				}
				lv.send(exitUrl,"_self","POST");
				fl_exit = false;
				this.mainGame	= null;
				this.main		= null;
				return;
			}
		}
		if( fl_gameOver ) {
			var save_ok = Std.cast(save_score)[Std.cast("$ok").substring(1)];

			if( save_ok != null && !fl_fade ) {
				var cookie = SharedObject.getLocal("$hd");
				cookie.clear();
				Std.getGlobal("clearInterval")(retry_id);
				loading.bottom.text		= getLangStr(73);
				loading.subBottom.text	= "";

				lv = new LoadVars();
				lv.send(save_ok,"_self","GET");
				save_score = null;
			}
			return;
		}


		if( !fl_fade && !fl_exit && !fl_gameOver ) {
			if ( loading != null ) {
				loading._alpha -= 2;
				if( loading._alpha <= 0 ) {
					loading.removeMovieClip();
					loading = null;
				}
			}
		}

		gameInst.main();
	}

}