cbee = new CBeeLocal({port: 2000});

myList = new Object();

myList.onConnect = function(success){
	_global.debug("Success: "+success);
}

myList.onIdent = function(node){
	_global.debug("Ident: "+node.attributes.k);
	
	this.cbee.cmd("ping");

};

myList.onClose = function(){
	_global.debug("Close");
}

myList.cbee = cbee;

cbee.addListener("onConnect",myList,"onConnect");
cbee.addListener("ident",myList,"onIdent");
cbee.addListener("onClose",myList,"onClose");

cbee.init();

