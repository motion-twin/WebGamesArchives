package inter.mod;
import Datas;
import mt.bumdum.Lib;

typedef McField = {>flash.MovieClip,field:flash.TextField};
typedef Avatar = {
		>flash.MovieClip,
		gfx:{>flash.MovieClip,bg:flash.MovieClip},
		inter:{>flash.MovieClip,talk:flash.MovieClip,frag:flash.MovieClip},
		cadre:McField,
		dm:mt.DepthManager,
		id:Int,
		loaded:Int,
		flTalk:Bool,
		me:Bool,
		};

class Chat extends inter.Module{//}

	var canal:Int;
	var lastMsgTime:Float;
	var flSend:Bool;
	var flFirstFocus:Bool;
	var flFocus:Bool;
	var avatars:Array<Avatar>;
	var talk:Array<Bool>;
	static var me:inter.mod.Chat;

	var  skin : {
		>flash.MovieClip,
		fieldChat:flash.TextField,
		fieldInput:flash.TextField,
	};

	public function new(){
		super();
		flActive = true;
		flFocus = false;
		root.gotoAndStop(2);
		canal = Param.game.canal;
		flFirstFocus = true;
		flSend = false;
		me = this;
		initSkin();
		skin.fieldInput.text = Lang.ENTER_TEXT;
		Game.fixTextField(skin.fieldInput);
		skin.fieldInput.maxChars = 150;
		skin.fieldInput.onSetFocus = function(_){
			me.flFocus = true;
			if (me.skin.fieldInput.text == Lang.ENTER_TEXT)
				me.skin.fieldInput.text = "";

		}
		skin.fieldInput.onKillFocus = function(_){
			me.flFocus = false;
			if (me.skin.fieldInput.text == "")
				me.skin.fieldInput.text = Lang.ENTER_TEXT;
		}
		display();
		initAvatars();
		//loadCanal();
		displayCanal();
		Inter.me.removeChatWarning();
		if(content==null)lastUpdate = -Cs.AUTO_UPDATE_CHAT_IN;

	}

	function initSkin(){
		var ww = Cs.mcw;
		var hh = Cs.mch;
		var lma = 130;
		var rma = 670;
		var uma = 36;
		var dma = 400;
		var dma2 = 430;

		var ma = 20;
		lma +=ma;
		rma -=ma;


		// FIELDS
		//var field = skin.createTextField("field0",0,lma,uma, rma-lma, dma-uma );
		skin = cast dm.empty(1);
		var mc:McField = cast dm.attach("mcChatField",0);
		mc.field._x = 3+lma;
		mc.field._y = 2+uma;
		mc.field._width = rma-lma;
		mc.field._height = dma-uma;
		skin.fieldChat = mc.field;
		Game.fixTextField(skin.fieldChat);

		var mc:McField = cast dm.attach("mcChatField",0);
		mc.field._x = 4+lma;
		mc.field._y = 6+dma;
		mc.field._width = rma-lma;
		mc.field.type = "input";
		mc.field.multiline = false;
		mc.field.textColor = 0xFF4444;
		skin.fieldInput = mc.field;
		Game.fixTextField(skin.fieldInput);

		var me = this;
		mc.field.onSetFocus = function(o){

			if(me.flFirstFocus){
				mc.field.htmlText="";
				Game.fixTextField(mc.field);
				mc.field.setNewTextFormat(new flash.TextFormat("Verdana",10));
				me.flFirstFocus = false;
			}
		};

		rect(lma,dma,rma,dma2,0x660000);

		// LINES
		line(lma,0,lma,hh);
		line(rma,0,rma,hh);
		line(lma,uma,rma,uma);
		line(lma,dma,rma,dma);
		line(lma,dma2,rma,dma2);
	}

	override function maj(){
		display();
	}

	override function display(){

		var flDown = lastMsgTime != content[content.length-1]._time;
		lastMsgTime = content[content.length-1]._time;

		//return;
		/*
		var ch = 0;
		for( msg in content )ch += msg._txt.length;
		trace("ch:"+ch);
		return;
		*/


		/*
		var messages = content.copy();
		var ch = 0;
		var id = null;
		var max = messages.length;
		for( n in 0...max ){
			var msg = messages[max-(1+n)];
			ch += msg._txt.length;
			if( ch > 1000 ){
				id= n;
				break;
			}
		}

		if(id!=null)messages = messages.slice(max-(1+id));
		trace(messages.length);
		*/

		var str = "";
		for( msg in content){

			var player = Game.me.getPlayer(msg._from);
			var date = Date.fromTime(msg._time);
			//str+="<font color='"+Col.getWeb( Cs.COLORS[player._color] )+"'><b>["+DateTools.format(date,"%H:%M")+"] "+player._name+"</b>> "+msg._txt+"</font><br/>";
			//str+="<font color='"+Col.getWeb( Cs.COLORS[player._color] )+"'>["+DateTools.format(date,"%H:%M")+"]<b> "+player._name+"</b>> "+msg._txt+"</font><br/>";


			if( Param.is(_ParamFlag.PAR_CHAT_TIME) )
				str+="<font color='"+["#C07700","#00CCDD"][Game.me.raceId]+"'>["+DateTools.format(date,"%H:%M")+"] </font>";

			if( Param.is(_ParamFlag.PAR_CHAT_CANAL) )
				str+=getFrites(msg._canal,player._color);

			str += "<font color='"+Col.getWeb( Cs.COLORS[player._color] )+"'>";

			if( Param.is(_ParamFlag.PAR_CHAT_PSEUDO) )
				str+=" <b>"+player._name+"</b>> ";

			str+=msg._txt+"</font><br/>";


		}
		var oldScroll = skin.fieldChat.scroll;
		skin.fieldChat.htmlText = str;
		Game.fixTextField(skin.fieldChat);
		if(flDown)
			skin.fieldChat.scroll = skin.fieldChat.maxscroll;
		else
			skin.fieldChat.scroll = oldScroll;

		// READ
		Param.readUntil(content[content.length-1]._time);
		/*
		var so = flash.SharedObject.getLocal("chatRead");
		if( so.data.list == null )so.data.list = [];
		var list:Array<{id:Int,last:Float}>;
		for( o in list ){
			if( o.id == Game.me.data._id )
		}
		*/

	}

	override function update(){
		super.update();

		if( skin.fieldInput.text!="" && !flSend && flash.Key.isDown(flash.Key.ENTER) && flFocus){
			flSend = true;
		}

		if( flSend && Inter.me.isReady() )sendText();
	}

	// AVATAR
	function initAvatars(){
		var id = 0;
		avatars = [];
		for( pl in Game.me.world.data._players ){
			var side = id%2;

			var mc:Avatar = cast dm.empty(10);
			mc.dm = new mt.DepthManager(mc);
			mc.gfx = cast mc.dm.empty(0);
			mc.cadre = cast mc.dm.attach("mcAvatarCadre",1);
			mc.cadre.smc._visible = false;

			mc._x = 20+side*(Cs.mcw-140);
			mc._y = 20+Std.int(id/2)*106;

			mc.id = pl._id;
			mc.loaded = 0;
			mc.flTalk = true;
			//if( pl._id!=Game.me.playerId  && pl._status == ALIVE )mc.onPress = callback(toggleAvatar,id);


			// LOAD AVATAR
			var me = this;
			var f = function(o){
				me.avatarLoaded(mc);
			}

			var mcl = new flash.MovieClipLoader();
			mcl.onLoadComplete = f;
			mcl.onLoadInit = f;
			mcl.loadClip(Game.me.pathAvatar,mc.gfx);
			avatars.push(mc);

			// GLOW
			Col.setColor(mc.cadre.smc,Cs.COLORS[pl._color]);
			mc.cadre.field.text = pl._name;
			mc.cadre.field.textColor = Cs.COLORS[pl._color];

			var sens = side*2-1;

			//
			mc.inter = cast mc.dm.attach("mcAvatarInterface",0);
			var ma = 3;
			mc.inter._x = -3*sens ;
			mc.inter.blendMode = "overlay";
			mc.inter.talk.stop();
			mc.me = pl._id ==Game.me.playerId;
			if( !mc.me ){
				mc.inter.talk.onPress = callback(toggleAvatar,id);
			}
			mc.inter.frag.stop();
			mc.inter.frag.gotoAndStop(pl._frags+1);

			// AJUSTEMENT GFX...
			if( side == 0 ){
				mc.inter._x += 100;

			}else{
				mc.inter._xscale *= -1;
			}

			id++;

		}


	}

	function avatarLoaded(mc:Avatar){
		mc.loaded++;

		if(mc.loaded==2){
			var bouille = new mt.bumdum.Bouille();
			bouille.firstDecal = 0;
			var player = Game.me.getPlayer(mc.id);
			bouille.parseSkin(Skin.decodeSkin(player._skin));
			bouille.apply(mc.gfx);

			//mc.gfx.blendMode = "overlay";



			var face:flash.MovieClip = cast(mc.gfx)._p0.smc;

			switch(player._status){
				case ALIVE :
				case ABANDON :
					face.gotoAndStop(2);
					grey(mc);
				case DEAD :
					face.gotoAndStop(3);
					grey(mc);
			}



			/*
			trace("---");
			trace(mc.gfx._totalframes);
			trace(mc.gfx.smc._totalframes);
			trace(cast(mc.gfx.smc)._p1._totalframes);
			trace(mc.gfx.bg._totalframes);
			trace(cast(mc.gfx)._p1._totalframes);
			*/

			/*
			if( Std.random(2)==0){

			}
			*/
		}
	}
	function grey(mc:Avatar){
		Filt.grey(mc.gfx);
		mc.gfx.blendMode = "overlay";
		Col.setColor(mc,0,50);
	}

	function toggleAvatar(id){

		var mc = avatars[id];
		mc.flTalk = !mc.flTalk;
		if( flash.Key.isDown(flash.Key.CONTROL) ){
			mc.flTalk = true;
			var flTalkAll = true;
			for( i in 0...Game.me.playerMax ){
				var mc = avatars[i];
				if( i!=id && !mc.me && mc.flTalk ){
					flTalkAll = false;
					break;
				}
			}

			for( i in 0...Game.me.playerMax ){
				var mc = avatars[i];
				if( i!=id && !mc.me )mc.flTalk = flTalkAll;
			}
		}


		mc.inter.talk.gotoAndStop(mc.flTalk?1:2);

		var newCanal = 0;
		for( i in 0...Game.me.playerMax ){
			var mc = avatars[i];
			if( mc.flTalk || mc == null ) newCanal += Std.int(Math.pow(2,i));
		}
		canal = newCanal;
		Param.setCanal(canal);
		displayCanal();
		display();
	}

	// CANAL
	/*
	function loadCanal(){

		var a = [];
		var newCanal = 0;
		for( i in 0...8 ){
			var pl = Game.me.world.data._players[i];
			if(( canal & Std.int(Math.pow(2,i)) ) != 0  && pl._status == ALIVE ){
				newCanal += Std.int(Math.pow(2,i));
			}

		}
		canal = newCanal;

	}
	*/
	function displayCanal(){
		talk = getTalk(canal);
		for( i in 0...Game.me.playerMax ){
			var mc = avatars[i];
			mc.flTalk = talk[i];
			mc.inter.talk.gotoAndStop(mc.flTalk?1:2);
			if( avatars[i].id == Game.me.playerId ){
				mc.inter.talk.gotoAndStop(1);
				mc.inter.talk._alpha = 30;
			}

		}
	}
	function getFrites(n,pid){

		var str = "<b>";
		var talk = getTalk(n);
		for( i in 0...Game.me.playerMax ){
			if( talk[i] && i!=pid){
				str += "<font color='"+Col.getWeb( Cs.COLORS[i] )+"'>l</font>";
			}
		}
		return str+"</b>";
	}
	function getTalk(n){
		var a  = [];
		for( i in 0...Game.me.playerMax )a[i] = ( n & Std.int(Math.pow(2,i)) ) != 0;
		return a;
	}

	// TEXT
	public function sendText(){
		flSend = false;
		var str = skin.fieldInput.text;
		if(str.length==0)return;
		skin.fieldInput.text = "";
		Api.writeChat(str, canal, display);
	}

	// REMOVE
	override function remove(){
		flActive = false;
		super.remove();
	}

	// LOGIC
	static public var content:Array<DataMsg>;
	static public var lastUpdate:Float;
	static public var lastRead:Float;
	static public var flActive = false;

	public static function updateLogic(){
		if( lastUpdate == null )return;
		//var limit = flActive?5000:90000;
		var limit = flActive?Cs.AUTO_UPDATE_CHAT_IN:Cs.AUTO_UPDATE_CHAT_OUT;
		if( (Inter.me.isReady() && Game.me.now()-lastUpdate > limit)  ){
			lastUpdate = Game.me.now();
			Api.getChat(if (flActive) me.display else Inter.me.checkChatWarning);
		}
	}

	public static function load(data:Array<DataMsg>){
		content = data;
		lastUpdate = Game.me.now();
	}

	public static function haveNewMessage(){
		return Param.lastRead() < content[content.length-1]._time;
	}
}