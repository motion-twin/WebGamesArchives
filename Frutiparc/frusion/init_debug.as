#include "../frutiengine/MovieClip.class.as"
#include "../frutiengine/Array.class.as"

#include "lang_french.as"


import Toto;


_global.swfURL = "http://www.beta.frutiparc.com/swf/";
_global.baseURL = "http://www.beta.frutiparc.com/";
System.security.allowDomain("www.beta.frutiparc.com");

if(_root.sid == undefined){
	_root.sid="debug";
}
if(_root.disc_type == undefined){
	_root.disc_type = 0;
}
_global.swfURL = "";


if(_root.debugOn != undefined){
	_root.createTextField("dbgTextField",5000,0,0,Stage.width,Stage.height);
	_root.dbgTextField.variable = "_root.test";
	_root.dbgTextField.selectable = false;
	_root.dbgTextField.wordWrap = true;
	_root.dbgTextField.html = true;

	_root.test = "";
	_global.debug = function(str){
		_root.test += str+"\n";
	}
}


Object.registerClass("frusionSlot",FrusionSlot);

function force_mx2004_load_class(){
	var arbuste = new CBeeLocal();
	var bermuda = new FPCBee();
}

_global.HTTPDefaultParams = {
	sid: _root.sid
};

_global.cbeeHost = "www.beta.frutiparc.com";
var cbeeMng:FPCBeeManager = new FPCBeeManager({className: "FPCBee"});
 _global.cbeeMng = cbeeMng;


_global.servTime = new RunDate();
_global.localTime = new RunDate();

// Fake FPFrusionSlot
frusion = new Object();
frusion.getFile = function(n){
	var infos = this.swf[n];
	if(infos == undefined){
		return null;
	}else{
		var r:FileLoader = new FileLoader(_global.swfURL+infos.u,infos.s);
		return r;
	}
};

// Modify FrusionManagerClass
FrusionManager.prototype.open = function(obj){
	if(this.flOpen) return false;
	this.flOpen = true;
	
	for(var n in obj){
		_root.frusion[n] = obj[n];
	}
	
	_root.attachMovie("frusionSlot","frusionSlot",5,{frusion: _root.frusion,width: Number(_root.frusion.prop.w),height: Number(_root.frusion.prop.h)});
};

if(_root.cbeeDebug != undefined){
	FPCBee.prototype.debug = function(str){
		_global.debug("[CBEE] "+str);
	};
}

FPCBee.prototype.login = _root.login;
FPCBee.prototype.pass = _root.pass;

var frusionMng:FrusionManager = new FrusionManager();
_global.frusionMng = frusionMng;

_root.frusion.prop = {w: Stage.width,h: Stage.height};
_root.frusion.disc_type = Number(_root.disc_type);
_root.frusion.swf = {
	index: {u: _root.swf,s: undefined}
};

_root.attachMovie("frusionSlot","frusionSlot",5,{frusion: _root.frusion,width: Number(_root.frusion.prop.w),height: Number(_root.frusion.prop.h)});

sResize = new Object();
sResize.onResize = function(){
	_root._x = -(Stage.width - 350) / 2;
	_root._y = -(Stage.height - 350) / 2;
	_root._xscale = 100;
	_root._yscale = 100;
}
Stage.addListener(sResize);
sResize.onResize();

