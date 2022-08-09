/*
$Id: StatusMng.as,v 1.8 2004/07/08 15:49:51  Exp $

Class: StatusMng
*/
class StatusMng{
	static var externalList:Array = [undefined,"eat","work","zzz","phone","away"];
	static var internalList:Array = [undefined,"forum","bkiwi","mb2","swapou2","snake3","bandas","grapiz","kaluga","miniwave"];
	
	static function analyseStr(str){
		var iExt = FEString.decode62(str.substr(0,1));
		iExt = (iExt == undefined)?0:iExt;
		var iInt = FEString.decode62(str.substr(1,2));
		iInt = (iInt == undefined)?0:iInt;
		var iEmote = FEString.decode62(str.substr(3,1));
		iEmote = (iEmote == undefined)?0:iEmote;

		return {external: externalList[iExt],internal: internalList[iInt],emote: iEmote};
	}

	///
	
	var external:Number = 0;
	var internal:Number = 0;
	var emote:Number = 0;
	var cnx;
	var last:String;
	
	function StatusMng(){
	
	}

	function setExternal(name){
		this.external = 0;
		for(var i=0;i<externalList.length;i++){
			if(externalList[i] == name){
				this.external = i;
				break;
			}
		}
		this.send();
	}

	function setInternal(name){
		this.internal = internalList.indexOf(name);
		if(this.internal < 0) this.internal = 0;
		
		this.send();
	}
	
	function unsetInternal(name){
		var i = internalList.indexOf(name);
		
		if(this.internal == i){
			this.internal = 0;
			this.send();
		}
	}
	
	function setEmote(eId){
		var eId = Number(eId);
		if(isNaN(eId) || eId == undefined) return;
		
		this.emote = eId;
		this.send();
	}
	
	function setCnx(cnx){
		this.cnx = cnx;
	}

	function send(){
		var str = FENumber.encode62(this.external,1) + FENumber.encode62(this.internal,2) + FENumber.encode62(this.emote,0);
		if(str == this.last) return false;
		this.cnx.cmd("status",{s: str});
		this.last = str;
	}
}
