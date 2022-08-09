/*
$Id: UserListMng.as,v 1.21 2004/07/16 12:23:20  Exp $

Class: UserListMng
*/
class UserListMng{
	/*
	Property: list
		List of UserMng objects
	
	See Also:
		<UserMng>
	*/
	var list:Object;
	/*
	Property: arr
		Array (cache) of username, array already sorted
	*/
	var arr:Array;
	/*
	Property: length
		Number of users in this list
	*/
	var length:Number = 0;
	var listenerList:Array;
	var userMngClass = "UserMng";
	
	
	function UserListMng(userMngClass){
		this.list = new Object();
		this.arr = new Array();
		this.listenerList = new Array();
		
		if(userMngClass != undefined){
			this.userMngClass = userMngClass;
		}
	}

	function addUser(u,infoBasic,flMode,callOnChange){
		u = String(u);

		if(this.list[u] == undefined){
			this.length++;
			var c = eval(this.userMngClass);
			var o = new c(u,infoBasic,flMode);
			this.list[u] = o;
			this.arr.push(o);
		}
		if(callOnChange == undefined || callOnChange == true){
			this.onChange();
		}
	}

	function rmUser(u,callOnChange,autoFlush){
		u = String(u);
		var o = this.list[u];
		if(o != undefined){
			var ret = this.arr.rm(o);
			this.length--;
			o.onDelete();
			delete this.list[u];
		}
		if(callOnChange == undefined || callOnChange == true){
			this.onChange();
		}
		return ret;
	}

	function rmAll(){
		for(var u in this.list){
			this.list[u].onDelete();
			delete this.list[u];
		}
		_global.mainCnx.traceFlush();
		
		this.list = new Object();
		this.arr = new Array();
		this.length = 0;
	}

	/*
	Function: defineMc
		Define a mc for an user of the list
	
	Parameters:
		u - User name
		mc - Mc which will receive onStatusObj & onAction
	*/
	function defineMc(u,mc){
		//_global.debug("["+u+"] defineMc");
		u = String(u);
		if(!u.length) return;
		this.list[u].setMc(mc);
	}

	function undefineMc(u,mc){
		//_global.debug("["+u+"] undefineMc");
		u = String(u);
		if(!u.length) return;
		this.list[u].unsetMc(mc);
	}

	function onChange(){
		_global.mainCnx.traceFlush();
		this.arr.sortOn("sortString");
		this.sendToAllListeners();
	}
	
	function onUserAction(u,act){
		u = String(u);
		if(!u.length) return;
		this.list[u].onAction(act);
	}
	
	/*
	Function: wantList
		Add or modify a listener object.
		Each listener will receive at wantList call, and when the userList changes :
		- a part of the userList, depending on the start/length value given (as an array of usernames)
		- the length of the userList
		
	Parameters:
		obj - Listener object (an object can't define only one method)
		method - Listener method
		start - Index of the first user sended
		length - Number of usernames sended
	*/
	function wantList(obj,method,start,length){
		var list = this.listenerList.getByProperty("obj",obj);
		if(list == undefined){
			var list = {obj: obj,method: method,length: length,start: start};
			this.listenerList.push(list);
		}else{
			list.method = method;
			list.length = length;
			list.start = start;
		}
		
		this.sendToListener(list);
	}
	
	/*
	Function: wantList
		Add or modify a listener object.
		Each listener will receive at wantList call, and when the userList changes :
		- a part of the userList, depending on the start/length value given (as an array of usernames)
		- the length of the userList
		
	Parameters:
		obj - Listener object (an object can't define only one method)
		method - Listener method
		start - Index of the first user sended
		length - Number of usernames sended
	*/
	function noMoreList(obj){
		var i = this.listenerList.getIndexByProperty("obj",obj);
		if(i > -1){
			this.listenerList.splice(i,1);
			return true;
		}
		return false;
	}

	function sendToAllListeners(){
		for(var i=0;i<this.listenerList.length;i++){
			this.sendToListener(this.listenerList[i]);
		}
	}
	
	function sendToListener(list){
		list.obj[list.method](this.arr.getPartAttrib(list.start,list.length,"u"),this.length);
	}
	
	function isInList(user:String):Boolean{
		user = String(user);
		return (this.list[user] != undefined);
	}
	
	function getRealUserName(user:String):String{
		user = String(user);
		var uLower = user.toLowerCase();
		for(var i=0;i<this.arr.length;i++){
			if(uLower == this.arr[i].u.toLowerCase()){
				return this.arr[i].u;
			}
		}
		return user;
	}

  function modePresent(){
    for(var i=0;i<this.arr.length;i++){
      if(this.arr[i].flMode) return true;
    }
    return false;
  }
	
	function isMode(user:String):Boolean{
		user = String(user);
		return (this.list[user].flMode == true);
	}
	
	function getUserArray():Array{
		return this.arr.getPartAttrib(0,this.length,"u");
	}

}
