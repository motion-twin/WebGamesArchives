/*----------------------------------------------

	FRUTIPARC 2 FPPlugin.class.as

----------------------------------------------*/


// -------- PluginList ------------------

_global.pluginListClass = function (){
	this.init();
}
pluginListClass.prototype = new Object();

pluginListClass.prototype.init = function(){
	
	//this.dp_plugin = 10
	
	//_root.test+="newPluginListClass\n"
	
	this.list = new Array()
	this.slot = {
		left:false,
		right:false,
		top:false,
		bottom:false
	}
	
	//chemin
//	this.box = box
// 	this.win = this.box.window;
	

}

pluginListClass.addPlugin = function(o){

	//_root.test += "addPlugin:"+o.name+"\n"

	//_root.test+="voila le putain d'objet qui me les brise : "+o+"\n"
	//_root.test+="addPlugin "+o.link.mc+" at "+o.side+" (box.window: "+this.box.window+")\n"

	// CREE LE PLUGIN SI IL N EXISTE PAS DEJA;
	var oldPlugin = this.getPlugin(o.name)
	if(oldPlugin){
		//_root.test+=" plugin en mémoire...\n"
		var plugin = oldPlugin;
	}else{
		//_root.test+=" création d'une nouvelle pluginBox\n"
		var plugin = new _global[o.link.box]({name:o.name,plgList:this, box:this.box, link:o.link.mc})
		this.list.push(plugin);
		if(this.slot[o.side]){
			//_root.test+="Eh mais y'en avait déjà un là --> "+o.side+"\n"
			this.slot[o.side].hidePlugin();
			//_root.test+="Bon ok je le vire, bouge pas...\n"
		}
	}
	
	// ATTACHE LE PLUGIN SI IL N'EST PAS DEJA ATTACHE;
	//_root.test+="Et voilà, maintenant je vais attacher le movie du plugin ("+plugin.side+")\n"
	if(plugin.side==false){
		plugin.setSide(o.side);
		plugin.attach()
				
	}else{
		//_root.test+="Ah ben finalement il était déjà attaché ici : "+plugin.side+"\n"
		//_root.test+="Bon, vu la situation, il me semble judicieux de considerer la dernière action comme une intention manifeste de supprimer le plugin désigné.\n"
		plugin.detach();
	}
	
	
	//_root.test+="pluginList addPlugin at "+o.side+" ----->"+this.slot[o.side]+"\n"
	//_root.test+="addPlugin in BoxList slot :"+this.slot+"\n"
}

pluginListClass.prototype.removePlugin = function(plugin){
	//
	this[plugin.side]=false;
	//
	if(plugin.flAttached){
		plugin.detach();
		for(var i=0; i<this.list.length; i++){
			if(this.list[i]==plugin){
				this.list.splice(i,1)
			}
		}
	}
}
pluginListClass.prototype.hidePlugin = function(plugin){
	this.win.pluginManager.remove(plugin.side)
	plugin.setSide(false);
}

pluginListClass.prototype.applyAll = function(method){
	this.left.path[method]();
	this.right.path[method]();
	this.top.path[method]();
	this.bottom.path[method]();
}
pluginListClass.prototype.updateAll = function(method){
	this.applyAll("remove");
	/*
	for(var i=0; i<this.dirList.length; i++){
		var side = this[this.dirList[i]];
		if(side){
			this.addPlugin(side);
		}
	}
	*/
}

pluginListClass.prototype.getPlugin = function(name){
	for(var i=0; i<this.list.length; i++){
		var plugin = this.list[i];
		if(plugin.name==name)return plugin;
	}
	return false;
}



// -------- PluginBoxClass (ABSTRAIT) ------
_global.pluginBoxClass = function (){
	//this.init();
}
pluginBoxClass.prototype = new Object();
pluginBoxClass.prototype.init = function(o){
	FEObject.addObject(this,o);
	this.side=false;
}

pluginBoxClass.prototype.attach = function(){
	//_root.test+="pluginBox : attachement du plugin en cours...\n"
	this.box.window.pluginManager.addPlugin(this);
	this.box.window.update();
	if(this.box.mode=="desktop"){
		this.path.initStartMove();
	}
	
}
pluginBoxClass.prototype.detach = function(){
	this.box.window.pluginManager.removePlugin(this.side)
	this.side=false;
}
pluginBoxClass.prototype.setSide = function(side){
	this.plgList.slot[side]=this;
	this.side=side;
}

// --------- plgBoxUserListClass ----------
_global.plgBoxUserListClass = function (o){
	this.init(o);
}
plgBoxUserListClass.prototype = new pluginBoxClass();
plgBoxUserListClass.prototype.init = function(o){
	super.init(o)
	//_root.test+="et voici le plgBoxUserListClass\n"
}


// --------- plgBoxEmoteActionClass ----------
_global.plgBoxEmoteActionClass = function (o){
	this.init(o);
}
plgBoxEmoteActionClass.prototype = new pluginBoxClass();
plgBoxEmoteActionClass.prototype.init = function(o){
	super.init(o)
	//_root.test+="et voici le plgBoxEmoteActionClass\n"
	
	this.genList();

	
}
plgBoxEmoteActionClass.prototype.genList = function(){
	this.list = [
		{link:"butGroup", param:{
				frame:1,
				link:"EmoteAction",
				buttonAction:{ 
					onPress:[{
						obj:"niabia",
						method:"addPlugin",
						args:{
							name:"EmoteAction",
							link:{box:"plgBoxEmoteActionClass",mc:"plgEmoteAction"},
							side:"top"
						}
					}]
				}
			}
		}
	]

	for(var i=2; i<20; i++)this.list.push({link:"butGroup", param:{frame:i, link:"EmoteAction"} });
}


// --------- plgBoxTestClass ----------
_global.plgBoxTestClass = function (o){
	this.init(o);
}
plgBoxTestClass.prototype = new pluginBoxClass();
plgBoxTestClass.prototype.init = function(o){
	super.init(o)
	//_root.test+="et voici le plgBoxTestClass\n"
}
