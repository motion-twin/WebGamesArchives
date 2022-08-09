/*
$Id: ContactListCache.as,v 1.2 2004/03/13 10:20:23  Exp $

Class: ContactListCache
	Garde une liste plate d'une contactList ou blackList pour acc�s rapide afin de savoir si un utilisateur y est pr�sent ou non
*/
class ContactListCache{
	var arr:Array;
	var t:String;
	
	function ContactListCache(t){
		this.arr = new Array();
		this.t = t;
	}
	
	function addUser(u){
		u = u.toLowerCase();
		
		var o = this.arr.getByProperty("name",u);
		if(o != undefined){
			o.nb++;
		}else{
			this.arr.push({name: u,nb: 1});
			// ajout d'un utilisateur en blackList => supprime la box.Chat en trashSlot si il y en a
			if(this.t == "blackList"){
				_global.chatMng["_"+u].userToBlackList();
			}
		}
	}
	
	function removeUser(u){
		u = u.toLowerCase();
		
		var i = this.arr.getIndexByProperty("name",u);
		if(i >= 0){
			var o = this.arr[i];
			o.nb--;
			if(o.nb <= 0){
				this.arr.splice(i,1);
			}
		}
	}
	
	function isIn(u){
		u = u.toLowerCase();
		
		var i = this.arr.getIndexByProperty("name",u);
		return (i >= 0);
	}
	
}