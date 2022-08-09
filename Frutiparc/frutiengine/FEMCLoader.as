class FEMCLoader extends MovieClipLoader{//}
	static var urlList:Object = new Object();
	
	var url:Object;
	var wasFirst:Boolean;
	
	function FEMCLoader(){
		super();
	}
	
	function loadClip(url,target,force){
		if(force != undefined){
			//_global.debug("loadClip: "+url+" ["+target+"]"+"[force]\n");
			return super.loadClip(url,target);
		}
				
		if(urlList[url] == undefined){
			this.wasFirst = true;
			urlList[url] = {loaded: false,objList: []};
			this.url = url;
			
			//_global.debug("loadClip: "+url+" ["+target+"]"+"[first]\n");
			return super.loadClip(url,target);
		}else{
			this.wasFirst = false;
			var o = urlList[url];
			if(o.loaded){
				//_global.debug("loadClip: "+url+" ["+target+"]"+"[loaded]\n");
				return super.loadClip(url,target);
			}else{
				//_global.debug("loadClip: "+url+" ["+target+"]"+"[push]\n");
				o.objList.push({obj: this,mc: target});
			}
		}
	}
	
	function onLoadComplete(mc){
		//_global.debug("onLoadComplete "+mc);
		if(this.wasFirst){
			var o = urlList[this.url];
			o.loaded = true;
			for(var i=0;i<o.objList.length;i++){
				o.objList[i].obj.loadClip(this.url,o.objList[i].mc,true);
			}
			o.objList = new Array();
		}
		super.onLoadComplete(mc);
	}
//{
}
