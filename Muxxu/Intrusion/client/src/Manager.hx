import Protocol;
import mt.bumdum.Lib;
import Types;
import MissionGen;

class Manager {
	public static var LANG		 = "fr";
	
	public static var ROOT		: flash.MovieClip;
	public static var ME		: Manager;
	public static var DM		: mt.DepthManager;
	public static var PARAMS	: PInit;
	public static var fc 		: mt.flash.FastCrypt = null;

	static var xmlData			: Hash<String>;
	static var fl_decrypted		: Bool;

	#if debug
		public static var STANDALONE	= false;
	#end

	static var mcLoading	: MCField;
	public var term			: UserTerminal;
	static var timers		: List<haxe.Timer>;


	public function new(mc) {
		ROOT = mc;
		ROOT.tabEnabled = false;
		ROOT.tabChildren = false;
		try {
			var raw = haxe.Resource.getString("soundData");
			fc = new mt.flash.FastCrypt( raw );
		}
		catch(e:String) {
			fatal("FC : "+e);
		}
		ME = this;
		DM = new mt.DepthManager(ROOT);
		timers = new List();
		fl_decrypted = false;
	}

	function onDecrypt() {
		// initialisation des XML cryptés
		data.VirusXml.init();
		data.AntivirusXml.init();
		data.ValuablesXml.init();
		data.ChipsetsXml.init();

		PARAMS = getParams();
		term = new UserTerminal();
		stopLoading();
	}

	static function getStacks() {
		var list = new List();
		list.add("EXCEPTION STACK :");
		list.add( haxe.Stack.toString(haxe.Stack.exceptionStack()) );
		list.add("\n");
		list.add("CALL STACK :");
		list.add( haxe.Stack.toString(haxe.Stack.callStack()) );
		return list.join("\n");
	}

	public static function fatal(str:String) {
		trace("FATAL ["+PARAMS._seed+"] : "+str+"\n"+getStacks());

		var mc : { >MCField, bg:flash.MovieClip } = cast Manager.DM.attach("pop", Data.DP_TOPTOP);
		mc.field.text = Lang.get.Fatal+"\n\n"+str;
		mc.bg._width = mc.field.textWidth+13;
		mc.bg._height = mc.field.textHeight+10;
		mc._x = Data.WID*0.5 - mc.bg._width*0.5;
		mc._y = Data.HEI*0.5 - mc.bg._height*0.5;
		mc.onRelease = function() {
			flash.Lib.getURL(Manager.PARAMS._errorUrl);
		}

		Col.setPercentColor( ROOT, 25, 0xff0000 );
		Reflect.deleteField(ROOT,"onEnterFrame");
		throw str;
	}

	public static function loading(?str:String) {
		if ( mcLoading==null ) {
			mcLoading = cast Manager.DM.attach("loading",Data.DP_TOPTOP);
			mcLoading._x = Math.round(Data.WID*0.5);
			mcLoading._y = Math.round(Data.HEI*0.5);
		}
		if ( str!=mcLoading.field.text ) {
			mcLoading.field.text = str;
			mcLoading.field._visible = str!=null;
		}
	}

	public static function stopLoading() {
		Manager.ME.term.startAnim(A_FadeRemove,mcLoading).spd*=0.5;
		mcLoading.smc._visible = false;
//		Manager.ME.term.startAnim(A_FadeOut,mcLoading.smc).spd*=2;
		mcLoading = null;
	}


	static function getParams() : PInit {
		var p : PInit = null;
		try {
			p = Codec.getData("init");
		}
		catch(e:Dynamic) {
			#if debug
				var stack = haxe.Stack.toString(haxe.Stack.exceptionStack());
				trace("getParams : "+e);
				STANDALONE = true;
				p = {
					_sfxVer		: 1,
					_musicVer	: 2,
					_startUrl	: "",
					_endUrl		: "",
					_errorUrl	: "",
					_iconsUrl	: "dockIcons/",
					_iconsVer	: 1,
					_sfxUrl		: "sfx/",
					_seed		: Std.random(999999)*1000,
					_gl			: 3,
					_m			: null,
					_decks		: new List(),
					_chip		: "unmask",
					_c			: false,
					_bios		: 1,
					_profile	: {
						_uname		: "Haxxor",
						_low		: false,
						_adult		: true,
						_ulevel		: 4,
						_leet		: false,
						_cfg		: "
							alias d=avdmg1
							alias    up = cd ..
						",
						_sfx		: true,
						_ambiant	: true,
						_beat		: true,
					},
				};

				var d = new Array();
				d.push( data.VirusXml.get.dmgm.id );
				d.push( data.VirusXml.get.dmgxl.id );
				d.push( data.VirusXml.get.corrup.id );
				d.push( data.VirusXml.get.shld2.id );
				d.push( data.VirusXml.get.scan3.id );
				d.push( data.VirusXml.get.exploi.id );
				d.push( data.VirusXml.get.dckswi.id );
				d.push( data.VirusXml.get.cchrge.id );
				d.push( data.VirusXml.get.copy.id );
				d.push( data.VirusXml.get.libxpl.id );
				p._decks.add({
					_name	: "superLongNameFuckingBastard",
					_content	: d,
				});

				var d = new Array();
				d.push( data.VirusXml.get.dmgm.id );
				d.push( data.VirusXml.get.dec3.id );
				d.push( data.VirusXml.get.corrup.id );
				d.push( data.VirusXml.get.copy.id );
				d.push( data.VirusXml.get.rconv.id );
				d.push( data.VirusXml.get.mana3.id );
				d.push( data.VirusXml.get.dckswi.id );
				p._decks.add({
					_name		: "toolset",
					_content	: d,
				});

				p._gl = 5;
				p._seed = 617554000;
//				p._profile._sfx = false;
				p._profile._beat = false;
				p._profile._ambiant = false;
			#else
				fatal("init failed");
			#end
		}
		return p;
	}




	public static function delay( cb:Void->Void, d:Float ) {
		timers.add( haxe.Timer.delay(cb,Std.int(d)) );
	}

	public static function stopTimers() {
		for (t in timers ) {
			t.stop();
			t.run = null;
		}
		timers = new List();
	}


	public function decryptXml() {
		if ( fl_decrypted )
			return true;
		fl_decrypted = !fc.run(400+Std.random(800));
		if ( !fl_decrypted )
			loading( Lang.fmt.LoadCounter({_n:fc.getOutput().length*2}) );
		else {
			try {
				var r = fc.getOutput();
				xmlData = haxe.Unserializer.run( r );
			}
			catch(e:String) {
				fatal("Unserializer failed : "+e);
			}
			onDecrypt();
		}
		return fl_decrypted;
	}


	public static function getEncodedXml(key:String) {
		if ( !fl_decrypted ) {
			fatal("reading not complete");
			return null;
		}

		key = "xml/"+key+".xml";

		if ( !xmlData.exists(key) ) {
			fatal("unknown XML "+key);
			return null;
		}
		else
			return xmlData.get(key);
	}


	public function main() {
		mt.Timer.update();
		if ( !decryptXml() || term==null )
			return;
		term.update();
	}
}
