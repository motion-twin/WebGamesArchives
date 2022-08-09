/*
$Id: MeMng.as,v 1.20 2004/07/30 08:47:39  Exp $

Class: MeMng
*/
class MeMng{


////

	var name:String;
	var status:StatusMng;
	var logged:Boolean;
	var haveBeenLogged:Boolean;
	var pass:String;
	//var fbouille:String;
	var listeners:Object;
	var userLog:Array;
	var siteLog:Array;
	var previousTime:String;
	var digitalScreen:MovieClip;
	var flMode:Boolean;
  var flAnimator:Boolean;
  var bouilleList:Array; // [] = {name: "",bouille: ""}
  var age:Number;
	
	var $xp:Number;
	var $xppos:Number;
	var $kikooz:Number;
	var $fbouille:String;
	
	var itemList:Array;
	
	var flMuted:Boolean;
	var endMute:String;
	
	// Vars for xpFlag
	var xpFlagConditions:Object;
	var xpFlagSended:Object;
	var xpCurrentDate:String;
	
	var fbouilleActionStr:Object;
	
	function MeMng(){
		this.logged = false;
		this.haveBeenLogged = false;
		this.status = new StatusMng();
		this.$kikooz = 0;
		this.userLog = new Array();
		this.siteLog = new Array();
		this.flMuted = false;
		this.flMode = false;
		
		this.listeners = new Object();
		this.listeners.xp = new Array();
		this.listeners.xppos = new Array();
		this.listeners.kikooz = new Array();
		this.listeners.fbouille = new Array();
		this.listeners.userLog = new Array();
		this.listeners.siteLog = new Array();
		this.itemList = new Array();
		
		/*
		this.xpFlagConditions = new Object();
		this.xpFlagSended = new Object();
		*/
	}
	
	function get kikooz():Number{
		return this.$kikooz;
	}
	
	function set kikooz(k:Number):Void{
		this.$kikooz = k;

		this.broadcastMessage("kikooz",k);
	}
	
	function get xp():Number{
		return this.$xp;
	}
	
	function set xp(x:Number):Void{
		this.$xp = x;
		
		this.broadcastMessage("xp",x);
	}
	
	function get xppos():Number{
		return this.$xppos;
	}
	
	function set xppos(x:Number):Void{
		this.$xppos = x;
		
		this.broadcastMessage("xppos",x);
	}
	
	function get fbouille():String{
		return this.$fbouille;
	}
	
	function set fbouille(x:String):Void{
		this.$fbouille = x;
		
		var famId = FEString.decode62(x.substr(0,2));
		
		this.fbouilleActionStr = new Object();
		
		var arr = _global.actionInfo[famId];
		for(var i=0;i<arr.length;i++){
			var o = arr[i];
			if(o.keyTrig != undefined){
				for(var j=0;j<o.keyTrig.length;j++){
					this.fbouilleActionStr[o.keyTrig[j]] = o.id;
				}
			}
		}
		
		this.broadcastMessage("fbouille",x);
	}

  public function useFrutibouille(name){
    for(var i=0;i<this.bouilleList.length;i++){
      if(this.bouilleList[i].name == name){
        _global.mainCnx.cmd("fbouille",{f: this.bouilleList[i].bouille}); 
      }
    }
  }
	
	private function broadcastMessage(varName,val){
		var arr = this.listeners[varName];
		for(var i=0;i<arr.length;i++){
			var o = arr[i];
			o.obj[o.method](val);
		}
	}
	
	/*
	Function: addListener
		Add a listener for a variable of this object
		
	Parameters:
		varName - string - The variable's name (xp | kikooz)
		callBack - object - Listener object, properties obj & method required
		
	See Also:
		<MeMng.removeListener>
	*/
	function addListener(varName,callBack){
		this.removeListener(varName,callBack.obj);
		this.listeners[varName].push(callBack);
	}
	
	/*
	Function: removeListener
		Remove a listener for a variable of this object
		
	Parameters:
		varName - string - The variable's name (xp | kikooz)
		object - object - Object listening (obj properties of the listener object)
		
	See Also:
		<MeMng.addListener>
	*/
	function removeListener(varName,object){
		var arr = this.listeners[varName];
		var i = arr.getIndexByProperty("obj",object);
		if(i >= 0){
			arr.splice(i,1);
			return true;
		}
		return false;
	}
	
	/*
	Function: addUserLog
	
	Parameters:
		obj - object - Object containing properties content and time, flNew is added
	*/
	function addUserLog(obj){
		if(obj.time > this.previousTime){
			obj.flNew = true;
		}else{
			obj.flNew = false;
		}
		if(obj.flNew){
			this.digitalScreen.unSleep(3);
		}
		this.userLog.pushAt(0,obj);
		this.broadcastMessage("userLog",this.userLog);
	}
	
	function onDisplayUserLog(){
		this.digitalScreen.sleep(3);
	}
	
	function emptyUserLog(){
		this.userLog = new Array();
	}
	
	function addSiteLog(obj){
		if(obj.time > this.previousTime){
			obj.flNew = true;
		}else{
			obj.flNew = false;
		}
		if(obj.flNew){
			this.digitalScreen.unSleep(4);
		}
		this.siteLog.pushAt(0,obj);
		this.broadcastMessage("siteLog",this.siteLog);
	}
	
	function onDisplaySiteLog(){
		this.digitalScreen.sleep(4);
	}
	
	function emptySiteLog(){
		this.siteLog = new Array();
	}
	
	
	//// ITEMS ////
	
	function addItem(i){
		i = Number(i);
		if(i == undefined || isNaN(i) || i == 0) return false;
		
		return this.itemList.pushUniq(i);
	}
	
	function hasItem(i){
		if(i == 0) return true;
		return this.itemList.isIn(i);
	}
	
	//// XPFlag ////
	
	
	function xpFlagAdd(cond){
		if(this.xpCurrentDate != _global.servTime.toFormat("prog_dateonly")){
			this.xpCurrentDate = _global.servTime.toFormat("prog_dateonly");
			this.xpFlagConditions = new Object();
			this.xpFlagSended = new Object();
		}
		
		if(this.xpFlagConditions[cond] == undefined) this.xpFlagConditions[cond] = 0;
		this.xpFlagConditions[cond]++;
		
		if(this.xpFlagConditions.boxScoreOpened != undefined && this.xpFlagConditions.boxScoreOpened >= 1) this.sendXPFlag(12);
		if(this.xpFlagConditions.pbChatMsg != undefined && this.xpFlagConditions.pbChatMsg >= 10) this.sendXPFlag(10);
		if(this.xpFlagConditions.pvChatMsg != undefined && this.xpFlagConditions.pvChatMsg >= 10) this.sendXPFlag(11);
	}
	
	function sendXPFlag(flag){
		if(this.xpFlagSended[flag] == undefined){
			_global.mainCnx.cmd("xpflag",{f: flag});
			this.xpFlagSended[flag] = true;
		}
	}
}
