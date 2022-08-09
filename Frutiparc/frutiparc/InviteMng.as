class InviteMng{
	var currentBoxList:Object;
	
	function InviteMng(){
		this.currentBoxList = new Object();
	}
	
	// {id,text,yesAct,noAct}
	function open(args){
		this.close(args.id);
		
		var o = new Object();
		
		o.yesAct = args.yesAct;
		o.noAct = args.noAct;
		
		o.box = new box.Alert({
			text: args.text,
			butActList: [
				{name: "Oui",action: {obj: this,method: "exec",args: {id: args.id,act: "yes"}}},
				{name: "Non",action: {obj: this,method: "exec",args: {id: args.id,act: "no"}}}
			]
		});
		
		_global.topDesktop.addBox(o.box);
		this.currentBoxList[args.id] = o;
	}
	
	// {id,act}
	function exec(args){
		var o = this.currentBoxList[args.id]
		if(o != undefined){
			if(args.act == "yes"){
				var cb = o.yesAct;
			}else if(args.act == "no"){
				var cb = o.noAct;
			}
			if(cb.args instanceof Array){
				cb.obj[cb.method].apply(cb.obj,cb.args);
			}else{
				cb.obj[cb.method](cb.args);
			}
			delete this.currentBoxList[args.id];
		}
	}
	
	function close(id){
		var o = this.currentBoxList[id];
		if(o != undefined){
			o.box.close();
			delete this.currentBoxList[id];
		}
	}
}