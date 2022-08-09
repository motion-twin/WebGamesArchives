class win.Pref extends win.Advance{//}
	
	var flMenu:Boolean;
	var menuTree:cp.Tree;
	var cpInfo:cp.Document;
	var cpTool:cp.Document;
	
	/*-----------------------------------------------------------------------
		Function: Pref()
	 ------------------------------------------------------------------------*/	
	function Pref(){
		this.init();	
	}

	/*-----------------------------------------------------------------------
		Function: init()
	 ------------------------------------------------------------------------*/	
	function init(){
		super.init();
		this.endInit();
		this.flMenu = false
	}

	/*-----------------------------------------------------------------------
		Function: initFrameSet()
	 ------------------------------------------------------------------------*/	
	function initFrameSet(){
		
		super.initFrameSet();

		// initialise la frame menu
		// var list = this.getSpecimenList();
		var args = {
			width:140,
			flMask:true
		}
		var margin = Standard.getMargin();
		margin.x.min = 8;
		margin.x.ratio = 1;
		var frame = {
			name:"menuFrame",
			link:"cpTree",
			type:"compo",
			min:{w:140,h:60},
			margin:margin,
			flBackground:true,
			mainStyleName:"frSystem",			
			args:args
		}
		this.menuTree = this.margin.left.newElement( frame )
		this.margin.left.bigFrame = this.margin.left.menuFrame;
		
		// initialise la frame show
		var margin = Standard.getMargin();
		margin.x.min = 8;
		margin.x.ratio = 1;
		this.main.newElement({ name:"showFrame", type:"h", min:{w:200,h:200}, flBackground:true, margin:margin})
		this.main.bigFrame = this.main.showFrame;
			
			// initialise la frame productInfo
			var args = {
				//mainStyleName:"content",
				flMask:true			
			}
			//var margin = Standard.getMargin();
			var frame = {
				name:"menuInfoFrame",
				link:"cpDocument",
				type:"compo",
				min:{w:200,h:200},
				mainStyleName:"frSheet",
				args:args
			}			
			this.cpInfo = this.main.showFrame.newElement(frame)
			this.main.showFrame.bigFrame = this.main.showFrame.menuInfoFrame;
		
		// Initialise la frame button
		
		var doc = "<p><l>";
		doc += "<s w=\"4\"/><b t=\""+Lang.fv("pref.use_default")+"\" l=\"butPushStandard\" o=\"win\" m=\"useDefault\"/><s w=\"10\"/>";
		doc += "<b t=\""+Lang.fv("pref.save")+"\" l=\"butPushStandard\" o=\"win\" m=\"save\"/><s w=\"4\"/>";
		doc += "</l></p>";
		
		var margin = Standard.getMargin();
		margin.x.min = 4;
		margin.x.ratio = 0;
		margin.y.min = 6;
		margin.y.ratio = 0.66;
				
		var args={
			flDocumentFit:true,
			doc:new XML(doc)
		};
		var frame = {
			type:"compo",
			name:"frameCreate",
			link:"cpDocument",
			mainStyleName:"frSystem",
			min:{w:260,h:18},
			margin:margin,
			args:args
		};
		this.cpTool = this.margin.bottom.newElement(frame);
	}
		
	/*-----------------------------------------------------------------------
		Function:  setTree()
	 ------------------------------------------------------------------------*/	
	function setTree(a){	
		this.menuTree.setList(a)
	}
	
	/*-----------------------------------------------------------------------
		Function:  displayPref(pref)
			{  
			  id: 2,  
			  name: "Burning Kiwi",  
			}
	------------------------------------------------------------------------*/	
	function displayPref(pref){	
		if(pref == undefined){
			this.cpInfo.setDoc();
			this.main.update();
			return;
		}
		
		if(pref.form == undefined){
			pref.form = Standard.getPrefForm(pref.type);
		}
		
		var f = new XML();
		f.nodeName = "p";
		
		// First line: fname
		var l = new XML();
		l.nodeName = "l";
		var t = new XML();
		t.nodeName = "t";
		t.attributes.s = 4;
		t.appendChild(t.createTextNode(pref.fName));
		l.appendChild(t);
		f.appendChild(l);
		
		// Second line: description
		var l = new XML();
		l.nodeName = "l";
		var t = new XML();
		t.nodeName = "t";
		t.appendChild(t.createTextNode(pref.desc));
		l.appendChild(t);
		f.appendChild(l);

		// Third line: form		
		if(pref.form.nodeName == "l"){
			var l = pref.form;
		}else{
			var l = pref.form.firstChild;
		}
		for(;l.nodeType>0;l=l.nextSibling){
			f.appendChild(new XML(l.toString()).firstChild);
		}
		
		//_global.debug("PrefDoc: "+FEString.unHTML(f.toString()));
		
		this.cpInfo.setDoc(f);
		
		this.cpInfo.setVariable("value",pref.formValue);
		
		this.main.update();
	}
	
	function getCurrentValue(){
		return this.cpInfo.card.value.value;
	}
	
	function useDefault(){
		this.box.useDefault();
	}
	
	function save(){
		this.box.save();
	}
	
//{	
}




