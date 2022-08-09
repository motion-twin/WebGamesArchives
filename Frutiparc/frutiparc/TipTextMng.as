/*
$Id: TipTextMng.as,v 1.1 2004/04/30 15:47:35  Exp $
*/
class TipTextMng{
	
	
	var flActive:Boolean;
	var currentId:String;
	var mc:MovieClip;
	
	function TipTextMng(){
		this.flActive = false;
	}
	
	function display(doc,id){
		if(this.flActive) this.remove(this.currentId);
		
		var obj;
		
		if(typeof(doc) == "string"){
			obj = {doc: new XML(doc)};
		}else if(doc instanceof XMLNode){
			obj = {doc: doc};
		}else{
			obj = {pageObj: doc};
		}
		
		_global.main.attachMovie("tipText","tipTextMc",Depths.tipText,obj);
		
		
		this.currentId = id;		
		this.mc = _global.main.tipTextMc;
		this.flActive = true;
	}
	
	function remove(id){
		//_global.debug("remove: "+id+" [flActive: "+this.flActive+"][currentId: "+this.currentId+"]");
		if(!this.flActive) return;
		if(id != this.currentId) return;
		
		this.mc.removeMovieClip();
		
		this.flActive = false;
		this.currentId = undefined;
	}
	
	function displayBuiltIn(id){
		//_global.debug("displayBuiltIn: "+id);
		var obj = Lang.getTipDoc(id);
		
		//_global.debug("objInLang: "+obj+" [type: "+obj.type+"][text: "+obj.text+"]");

		var doc = this.getDocFromObj(obj);
		
		if(doc != undefined){
			this.display(doc,id);
		}
	}
	
	function displayObj(obj){
		if(obj.id == undefined) return;
		var doc = this.getDocFromObj(obj);
		
		if(doc != undefined){
			this.display(doc,obj.id);
		}		
	}
	
	function displayCallBack(arg){
		var obj = arg.cb.obj[arg.cb.method](arg.cb.args);
		obj.id = arg.id;
		this.displayObj(obj);
	}
	
	function getDocFromObj(obj){
		if(obj == undefined) return undefined;
		
		if(obj.type == "doc") return obj.doc;
		if(obj.type == "text") return "<p><l><t>"+obj.text+"</t></l></p>";
		if(obj.type == "html") return "<p><l><t><p><fieldProperty html=\"1\"/></p>"+FEString.unHTML(obj.html)+"</t></l></p>";
		return undefined;
	}

}