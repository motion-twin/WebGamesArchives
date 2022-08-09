/*
$Id: BlackList.as,v 1.2 2004/03/13 10:20:23  Exp $

Class: BlackList
*/
class BlackList{
	var uid:String;
	var type:String;
	var list:Array;
	var globalListener:Object;
	
	function BlackList(obj,globalListener){
		this.list = new Array();
		this.globalListener = globalListener;
		
		var l = obj.list;
		for(var i=0;i<l.length;i++){
			var elem = l[i];
			if(elem.type == "contact" && FEString.endsWith(elem.desc[0],"@frutiparc.com")){
				var n = elem.desc[0].substr(0,elem.desc[0].length - 14);
				this.list.push({uid: elem.uid,name: n});
				if(this.globalListener != undefined){
					this.globalListener.obj[this.globalListener.methodAdd](n);
				}
			}
		}
		
		_global.fileMng.addListener("blacklist",this);
	}
	
	function addFile(elem){
		if(elem.type == "contact" && FEString.endsWith(elem.desc[0],"@frutiparc.com")){
			var n = elem.desc[0].substr(0,elem.desc[0].length - 14);
			this.list.push({uid: elem.uid,name: n});
			if(this.globalListener != undefined){
				this.globalListener.obj[this.globalListener.methodAdd](n);
			}
		}
	}
	
	function rmUid(u){
		var i = this.list.getIndexByProperty("uid",u);
		if(i >= 0){
			var o = this.list[i];
			
			if(this.globalListener != undefined){
				this.globalListener.obj[this.globalListener.methodRemove](o.name);
			}
			
			this.list.splice(i,1);
		}
	}
	
	function getUidOfUser(n){
		var i = this.list.getIndexByProperty("name",n);
		if(i >= 0){
			return this.list[i].uid;
		}
	}
}