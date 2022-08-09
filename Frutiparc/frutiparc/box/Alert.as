/*
$Id: Alert.as,v 1.8 2003/11/20 00:01:35  Exp $

Class: box.Alert
	_global.desktop.addBox(new box.Alert({text: "Blah!"}));
	ou
	_global.desktop.addBox(new box.Alert({
		text: "Blah!",
		butActList:[
			{
				name: "Oui",
				action:	{
					obj: truc,
					method: "machin",
					args: a
				}
			},
			{
				name: "Non",
				action:	{
					obj: truc,
					method: "machin",
					args: a
				}
			}
		]
	}));
*/
class box.Alert extends box.FP{
	var text:String;
	var butActList:Array;
	
	function Alert(obj){
		for(var n in obj){
			this[n] = obj[n];
		}
		this.winType = "winAlert";
		if(this.title == undefined) this.title = Lang.fv("alert");
		if(this.butActList == undefined){
			this.butActList = [
				{name: Lang.fv("ok"),action: {}}
			];
		}
	}
	
	function preInit(){
		this.desktopable = true;
		this.tabable = false;
		super.preInit();
	}

	function init(slot,depth){
		var obj = {
			text: this.text,
			butList: new Array()
		};
		for(var i=0;i<this.butActList.length;i++){
			obj.butList.push({name: this.butActList[i].name,action: {obj: this, method: "execButAct", args: i}});
		}
		
		if(this.winOpt == undefined) this.winOpt = new Object();
		this.winOpt.info = obj;

		var rs = super.init(slot,depth);

		if(rs){
			this.window.setTitle(this.title);
		}
		return rs;
	}
	
	function execButAct(id){
		var o = this.butActList[id].action;
		if(o.args instanceof Array){
			o.obj[o.method].apply(o.obj,o.args);
		}else{
			o.obj[o.method](o.args);
		}
		this.tryToClose();
	}
	
}
