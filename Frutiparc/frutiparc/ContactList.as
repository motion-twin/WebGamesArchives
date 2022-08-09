/*
$Id: ContactList.as,v 1.6 2004/04/16 08:46:36  Exp $

Class: ContactList
*/
class ContactList extends IconFileBox{
	var list:Array;
	var listener:Object;
	var globalListener:Object;
	var open:Boolean;
	
	function ContactList(obj,listener,globalListener){
		super(obj);
		this.listener = listener;
		this.globalListener = globalListener;
		this.open = _global.userPref.getPref("cl_open");
		
		for(var i=0;i<this.list.length;i++){
			var elem = this.list[i];
			if(elem.type == "folder"){
				this.list[i] = new ContactList(elem,listener,globalListener);
			}else{
				this.list[i] = new IconFileBox(elem);
				if(this.globalListener != undefined && elem.type == "contact" && FEString.endsWith(elem.desc[0],"@frutiparc.com")){
					this.globalListener.obj[this.globalListener.methodAdd](elem.desc[0].substr(0,elem.desc[0].length - 14));
				}
			}
		}
	}
	
	function onKill(){
		for(var i=0;i<this.list.length;i++){
			this.list[i].onKill();
		}
	}
	
	function onDrop(o){
		// TODO
	}
	
	function addFile(o){
		if(o.type == "folder"){
			_global.fileMng.refreshContact();
		}else{
			this.list.push(new IconFileBox(o));
			if(this.globalListener != undefined && o.type == "contact" && FEString.endsWith(o.desc[0],"@frutiparc.com")){
				this.globalListener.obj[this.globalListener.methodAdd](o.desc[0].substr(0,o.desc[0].length - 14));
			}
			//_global.mainCnx.traceFlush();
			if(this.listener != undefined){
				this.listener.obj[this.listener.method]();
			}
		}
	}
	
	function rmUid(u){
		var i = this.list.getIndexByProperty("uid",u);
		if(i < 0) return;
		
		var elem = this.list[i];

		if(this.globalListener != undefined && elem.type == "contact" && FEString.endsWith(elem.desc[0],"@frutiparc.com")){
			this.globalListener.obj[this.globalListener.methodRemove](elem.desc[0].substr(0,elem.desc[0].length - 14));
		}
		
		elem.onKill();
		//_global.mainCnx.traceFlush();
		this.list.splice(i,1);
		if(this.listener != undefined){
			this.listener.obj[this.listener.method]();
		}
	}
}