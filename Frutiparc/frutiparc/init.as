/**

$Id: init.as,v 1.207 2005/08/04 16:06:03  Exp $
*/

//_root._alpha = 50;

if(_global.baseDomain == undefined) _global.baseDomain = "www.beta.frutiparc.com";
if(_global.flDebug == undefined) _global.flDebug = true;
if(_global.flDebug) System.security.allowDomain("swf.beta.frutiparc.com");

_global.tmpDebug = new Array();
_global.debug = function(str){
	_global.tmpDebug.push(str);
};

#include "../../frutiparc/openFunctions.as"
#include "../../frutiparc/lang_french.as"
#include "../../frutiengine/MovieClip.class.as"
#include "../../frutiengine/Array.class.as"
#include "../../frutiengine/TextField.class.as"
#include "../global.as"
#include "../../frutiparc/registerSymphony.as"

MovieClip.prototype._focusrect = false;
Button.prototype._focusrect = false;
_focusrect = false;
_global._focusrect = false;

_root.menu = _global.getFileContextMenu();

// SWATCH
_global.ftSwatch = [
	{r:255,	g:255,	b:255	},
	{r:241,	g:241,	b:241	},
	{r:81,	g:81,	b:81	},
	{r:214,	g:247,	b:181	},
	{r:197,	g:242,	b:151	},
	{r:173,	g:231,	b:107	},
	{r:143,	g:206,	b:38	},
	{r:255,	g:227,	b:227	},
	{r:255,	g:199,	b:199	},
	{r:227,	g:117,	b:106	},
	{r:81,	g:81,	b:81	},
	{r:81,	g:81,	b:81	}
];
_global.floodMinDuration = [400,1500,3000,5000];
_global.maxMessageLength = {pub: 200,priv: 350,topic: 100};

// A VIRER ( --> VOIR CALCUL DU TMOD )	
_global.tmod=1;

this.onResize = function(){
	// TODO: �crire �a plus prorement	( avec un "p" suppl�mentaire � proprement par exemple )
	if(Stage.height > 120){
		_global.frameMode = false
		if(main.cornerX == 0){
			main.cornerX = main.lastCornerX;
		}
		//_root.test+="main"+main+"\n"
		//_root.test+="main.frusion "+main.frusion+"\n"
		//_root.test+="sendResize : Stage.width("+Stage.width+")-(main.cornerX("+_global.main.cornerX+")+main.frusion.width("+main.frusion.width+")+main.frusion.margin("+main.frusion.margin+"))\n"
		//main.mainBar.onResize(Stage.width-(main.cornerX+main.frusion.width+main.frusion.margin),Stage.height);
		main.mainBar.update();
		
		main.sideList._visible = true;
		main.sideListFond._visible = true;
		main.sideList.onStageResize()
		slotList.onStageResize();
    wallPaper.onStageResize();
		topDesktop.onStageResize();
		main.dbgTextField._x = main.cornerX
		main.frusion.pos.x = mcw-5
		main.frusion._x = main.frusion.pos.x
		
	}else{
		_global.frameMode = true;
		if(main.cornerX > 0){
			main.lastCornerX = main.cornerX;
			main.cornerX = 0;
		}
		//main.mainBar.onResize(Stage.width-(main.frusion.width+main.frusion.margin));
		main.mainBar.update();
		
		main.sideList._visible = false;
		main.sideListFond._visible = false;
		main.frusion.pos.x = mcw-5
		main.frusion._x = main.frusion.pos.x
		main.frusion.forceCloseSlot();
	}
	//_root.test+="coucou C'est moi\n"
};

_global.swfURL = "http://"+_root.domain;
_global.baseURL = "http://"+_global.baseDomain+"/";

System.security.allowDomain(_global.baseDomain);

_global.main = this;
_global.userPref = new Pref();
_global.fileMng = new FPFileMng();
_global.servTime = new RunDate();
_global.localTime = new RunDate();
_global.me = new MeMng();
_global.myContactListCache = new ContactListCache("contactList");
_global.myBlackListCache = new ContactListCache("blackList");

Key.addListener(listener.key);
Mouse.addListener(listener.mouse);


// DEBUG
if(_global.flDebug && Key.isDown(Key.ENTER)){
	main.createTextField("dbgTextField",Depths.dbgTextField,0,0,800,800);
	main.dbgTextField._y = 200;
	main.dbgTextField.variable = "_root.test";
	main.dbgTextField.selectable = false;
	//main.dbgTextField.mouseWheelEnabled = true;
	main.dbgTextField.wordWrap = false;
	_root.test=_global.baseDomain+"\n"

}


// SIDELIST
main.attachMovie("sideList","sideList",Depths.sideList);

//_root.test+="listener("+listener+")\n"
//_root.test+="frusion("+frusion+")\n"
//for(var elem in frusion)_root.test+="frusion."+elem+" = "+frusion[elem]+"\n";
// FRUSION
main.attachMovie("frusion","frusion",Depths.frusion,{_x:mcw})
main.sideList.bg.onPress = function (){
	_root.test=""
}
//_root.test+="frusion("+this.frusion+")\n"
// MAINBAR
main.attachMovie("mainBar","mainBar",Depths.mainBar);
main.attachMovie("laGrosseBoucle","timer",Depths.timer);


//_global.frusionMng = new frusion.FrusionManager();

_global.frusionMng = new _global.frusion.FrusionManager()

// SLOTLIST
_global.slotList = new FPSlotList();
slotList.init();


// TrashSlot
_global.trashSlot = new FPTrashSlot();
_global.trashSlot.init(slotList,Depths.trashSlot,false);

// DESKTOP
_global.desktop = new FPDesktop();
_global.desktop.title = Lang.fv("desktop");
_global.slotList.addSlot(desktop,true);

_global.wallPaper = new WallPaperMng(main);

_global.tip = new TipTextMng();
_global.channelInvite = new InviteMng();
_global.chatInvite = new InviteMng();


// AlwaysOnTopDesktop
_global.topDesktop = new FPTopDesktop();


this.onResize();


// DebugBox
_global.stdDebugBox = new box.Debug()
if(_global.flDebug){
	_global.desktop.addBox(_global.stdDebugBox);
}else{
	_global.trashSlot.addBox(_global.stdDebugBox);
}

_global.debug = function(str){
	_global.stdDebugBox.addText(str);
};
for(var i=0;i<_global.tmpDebug.length;i++){
	_global.debug(_global.tmpDebug[i]);
}

_global.watchDebug = function(prop,oldVal,newVal,uData){
	_global.debug(uData+"."+prop+" = "+newVal+" [was: "+oldVal+"]");
	return newVal;
}

_global.debugLC = new LocalConnection();
_global.debugLC.addText = function(src,str){
	_global.debug("["+src+"] "+str);
};

//*
if(_global.flDebug){
	_global.httpDebugBox = new box.Debug()
	_global.httpDebugBox.setTitle("Debug HTTP");
	if(false){
	//if(true){
		_global.desktop.addBox(_global.httpDebugBox);
	}else{
		_global.trashSlot.addBox(_global.httpDebugBox);
	}
}
//*/

// CBeeManager
_global.cbeeHost = _global.baseDomain;
_global.cbeeMng = new FPCBeeManager({className: "FPCBee"});
_global.cbeePort = new Object();

_global.cnxAlertBox = new box.Alert({title: Lang.fv("please_wait"),text: Lang.fv("connecting"),butActList: []});
_global.topDesktop.addBox(_global.cnxAlertBox);

// Get some lang contents
langInit = new HTTP("xml/lang_french.xml",obj,{type: "xml",obj: listener.main, method: "onLang"});

// Get CBee services' ports
servicesInit = new HTTP("xml/services.xml",{r: random(65536).toString(16)},{type: "xml",obj: listener.main, method: "onCBeeService"});

// Init session

if( _root.sid == undefined ){
	var obj = {ignore_cookie: 1,r: random(65536).toString(16)};
	if(_root.ref != undefined){
		obj.ref = _root.ref;
	}
	sessInit = new HTTP("do/init",obj,{type: "loadvars",obj: listener.main, method: "onSessInit"});
	_global.sidAutoInit = false;
}else{
	_global.debug("Mode via sid");
	HTTP.defaultParams.sid = _root.sid;
	_global.sidAutoInit = true;
}

// Lalatsouin je fais mes tests ou je veux
//this.attachMovie("tipText","tip",12345);





















