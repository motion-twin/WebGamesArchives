class cp.Document extends Component{//}
	
	var flDocumentFit:Boolean;
	var flPageReady:Boolean;
	var flResizeButton:Boolean;
	var flNeverEnding:Boolean;
	
	var flTrace:Boolean;
	
	var depth:Number;
	
	var mainStyleName:String;
	var secondStyleName:String;
	var url:String;
	var doc:XML;
	var pageObj:Object;
	var docStyle:Object;
	//var page:de.Page;
	
	var console:Object;		// Regroupe tous les éléments nommés
	var card:Object;		// Regroupe toutes les variables
	
	function Document(){
		this.init();
	}
	
	function init(){
		
		//this.flMarker = true//DEBUG
		//if(this.flTrace)_root.test+="[document] init()\n";
		//_root.test+="[document] init()\n";
		if(this.flNeverEnding==undefined)this.flNeverEnding=true;
		if(this.flResizeButton==undefined)this.flResizeButton = false;		//DEBUG
		if(this.console==undefined)this.console = new Object();
		if(this.card==undefined)this.card = new Object();
		//if( this.mainStyleName == undefined ) this.mainStyleName = this.frame.mainStyleName;
		if( this.docStyle == undefined ){
			//_root.test+="this.win.style("+this.win.style+")\n"
			//_root.test+="this.mainStyleName("+this.mainStyleName+")\n"
			this.docStyle = Standard.getDocStyle(this.win.style[this.mainStyleName]);
		}
		if(this.docStyle.outColor==undefined)this.docStyle.outColor = this.win.style.global.color[0]
		//_root.test+="this.win.style[this.mainStyleName] = "+this.win.style[this.mainStyleName]+" this.mainStyleName("+this.mainStyleName+")\n"
		this.flPageReady=false;
		
		/*
		if(flTrace){
			_root.test += "this.docStyle("+this.docStyle+")\n"
			_root.test += "this.mainStyleName("+this.mainStyleName+")\n"
			_root.test += "this.docStyle.outColor("+this.docStyle.outColor+")\n"
		}
		*/
		
		super.init();
	}
	
	function genContent(){
		super.genContent();
		
		if(this.url!=undefined){		//Charge le doc si celui si est externe
			this.loadDocXML();
		}else{
			if(this.doc!=undefined){	//Parse un document XML envoyé en entrée
				this.parseDoc();
			}
			if(this.pageObj!=undefined){	//Affiche la page passée en entrée ou parsée depuis le XML
				this.attachPage();
			}
		}
	}

	function setDoc(doc){
		//_root.test+="setDoc("+doc+")\n"
		if(this.flPageReady)this.detachPage();
		
		// Skool: Il me semble utile de réinitialiser un peu mieux tout ça...
		this.card = new Object();
		this.console = new Object();
	
		this.doc = doc;
		this.parseDoc()
		this.attachPage();
	}
	
	function setPageObj(pageObj){
		if(this.flPageReady)this.detachPage();
		this.card = new Object();
		this.console = new Object();
		this.pageObj = pageObj
		this.attachPage();
	}
		
	function loadDocXML(){
		this.doc = new XML();
		this.doc.ignoreWhite = true;
		this.doc.load(this.url);
		this.doc.onLoad = function(success){
			if(success){
				//_root.test+="docXMLLoaded:"+arguments.callee.obj+"\n"
				arguments.callee.obj.parseDoc();
				arguments.callee.obj.attachPage();
			}else{
				_root.test+="docXML Load error\n"
			}		
		}
		this.doc.onLoad.obj=this;
	}
		
	function attachPage(){
		//_root.test+="attachPage("+this.pageObj+")\n"
		this.pageObj.doc = this;
		this.pageObj.flNeverEnding = this.flNeverEnding;
		this.content.attachMovie("dePage","page",1,pageObj)
		this.content.page.update();
		this.attachResizeButton();
		this.flPageReady = true;
	}	
		
	function detachPage(){
		this.content.page.removeMovieClip()
		this.flPageReady = false;
	}
	
	/*--------------------------------------------------------------------
		- nodeName
		"l" = ligne
			attributes :
			"h" = height
			content : 
				- nodeName :
				"p" = pageObj
				"t" = textField
				"i" = inputField
				"l" = link
				"m" = loadMovie
				"s" = spacer
	
				- attributes:
				"w" = width
				"b" = big

	--------------------------------------------------------------------*/
	
	function parseDoc(){
		//_root.test = "parseDoc("+this.doc+")\n"
		this.pageObj = parsePage(this.doc);
	}
	
	function parsePage(node){
		if(node.nodeName == undefined) node = node.firstChild;
		
		var p = new Object();						// PAGE(p) ( XML = node )
		
		// CELUI CI A VIRER
		p.pos = {
			x:0,
			y:0
		}
		
		// OU PEUT ETRE BIEN CELUI
		if(node.attributes.w!=undefined)p.width = Number(node.attributes.w); else p.width=0;
		if(node.attributes.b!=undefined){
			p.big = Number(node.attributes.b)
		}else if(p.width==0){
			p.big = 1;
		}
		p.pos.w = p.width
		
		
		var child = node.firstChild;
		if(child!=undefined)p.lineList = new Array();
		
		while (child!=undefined){					// LIGNE(l) ( XML = child )
			//_root.test+="parse a line...\n"
			var l = new Object();
			if( child.attributes.h != undefined ){
				l.height = Number(child.attributes.h);
			}else{
				l.height = 0;
			}
			if(child.attributes.b) l.big  = Number(child.attributes.b);
			
			var elem = child.firstChild;
			if(elem!=undefined)l.list = new Array();
			
			while (elem!=undefined){				// ELEMENT(e) ( XML = elem )
				var e = this.parseElement(elem)
				l.list.push(e)
				elem = elem.nextSibling;
			}
			
			p.lineList.push(l)
			child = child.nextSibling;
		}
		
		return p;
	}
	
	function parseElement(node){
		//if(this.flTrace)_root.test+="[Document] parseElement() node.type:"+node.nodeName+"\n"
		var e = new Object();
		e.param = new Object();
		// Determination du type et des attributs spécifiques
		//var flDefBig = false;
		switch(node.nodeName){
			case "p":						// PAGE
				e = this.parsePage(node);
				e.type = "page"
				break;
			case "t":						// TEXT
				e.type = "text"
				e.param.sid = node.attributes.s
				e.param.marginLeft = node.attributes.m
				e.param.height = node.attributes.h
				break;
			case "u":						// URL
				e.type="url"
				e.param.url = node.attributes.u;
				break;
			case "l":						// LINKAGE
				e.type="link"
				e.link = node.attributes.l;
				break;
			case "s":						// SPACER
				e.type="spacer"
				break;
			case "b":						// BOUTONS STANDARDS
				e.type="button"
				e.param.link = node.attributes.l;
				if(node.attributes.o!=undefined){
					var o = this[node.attributes.o]
					if(o == undefined) o = eval(node.attributes.o);
					if(o == undefined) o = eval(this+"."+node.attributes.o);
				}else{
					var o = this
				}
				var action = {
					obj:o,
					method:node.attributes.m,
					args:node.attributes.a
				}	
				e.param.buttonAction = {onPress:[action]}
				e.param.curve = 8;
				e.param.initObj = {txt:node.attributes.t};
				break;
			case "i":						// INPUTFIELD
				e.type="input"
				e.param.sid = node.attributes.s
				e.param.marginLeft = node.attributes.m
				e.param.height = node.attributes.h
				e.param.variable = node.attributes.v
				e.param.fieldProperty = new Object();
				e.param.fieldProperty.restrict = node.attributes.r
				break;
			case "r":						// RADIO BUTTON
				e.type="radio"
				e.param.sid = node.attributes.s
				e.param.marginLeft = node.attributes.m
				e.param.variable = node.attributes.v
				e.param.def = node.attributes.d
				e.param.val = node.attributes.u
				break;
			case "y":						// CHECK BOX
				e.type="checkBox"
				e.param.sid = node.attributes.s
				e.param.marginLeft = node.attributes.m
				e.param.variable = node.attributes.v
				e.param.def = node.attributes.d
				break;
			case "c":						// COMBO BOX
				e.type="comboBox"
				e.param.sid = node.attributes.s
				e.param.variable = node.attributes.v
				e.param.def = Number(node.attributes.d)
				break;
			case "n":						// LINE
				e.type="line"
				e.param.color = node.attributes.c
				e.param.size = node.attributes.s
				break;				
			default:
				_root.test+="borne d'element de doc XML inconnue("+node.nodeName+")\n"
		}	
		// Attributs généraux des éléments
		e.width = node.attributes.w;
		e.height = node.attributes.h;
		e.big = node.attributes.b;
		e.param.name = node.attributes.n;
		e.dx = node.attributes.dx;		// POUR DES AJUSTEMENTS UN PEU SALES
		e.dy = node.attributes.dy;		// POUR DES AJUSTEMENTS UN PEU SALES
		
		
		// Attribut param		// /!\ ATTENTION /!\ LES ATTRIBUTS NUMBERS DE PARAMS SONT PASSES SOUS FORME DE STRINGS
		var child = node.firstChild;
		while(child!=undefined){
			if(child.nodeName=="p"){
				this.assignAttributes(child,e.param)
			}
			if(child.nodeType==3){
				e.param.text = child.nodeValue;
			}				
			child = child.nextSibling;
		}		
		return e;
	}
	
	function assignAttributes(node, obj){
		//_root.test += "assignAttributes : node("+node.nodeName+")\n"
		for(var a in node.attributes){
			obj[a] = node.attributes[a]
			//_root.test+="> "+a+"="+node.attributes[a]+"\n"
		}
		var child = node.firstChild;
		while(child!=undefined){
			if(child.nodeName=="p"){
				this.assignAttributes(child, obj.param)
			}else if(child.nodeName=="array"){
				obj[child.attributes.name] = new Array();
				//var littleChild = node.firstChild
				this.assignArray(child, obj[child.attributes.name])
			}else{
				obj[child.nodeName] = new Object();
				this.assignAttributes(child, obj[child.nodeName])
			}
			
			child = child.nextSibling;
		}
	}
	
	function assignArray(node, array){
		var child = node.firstChild
		while(child!=undefined){
			if(child.nodeName=="v"){
				array.push(child.attributes.v)
			
			}else if(child.nodeName=="o"){
				var o  = new Object()
				array.push(o);
				this.assignAttributes(child, o);
			}			
			child = child.nextSibling;
		}
	}
			
	function updateSize(){
		//_root.test+="[DOC] updateSize("+this.width+","+this.height+") flDocumentFit("+this.flDocumentFit+")\n"
		super.updateSize();
		this.content.page.pos.w = this.width
		this.content.page.pos.h = this.height
		// DOUBLE UPDATE ( pas tres fin, mais je prendrai la peine de mieux le coder plus tard)
		this.content.page.update();
		this.content.page.update();
		this.checkScrollBar("onTargetUpdate");
		if(this.flDocumentFit){
			//_root.test+="fit !!!!!\n"
			this.min.h = this.content.page.min.h;
			//this.win.frameSet.flRestart = true;
			//_root.test+="this.frame("+this.frame+") this.min.h("+this.min.h+")\n"
			//_root.test+="testFit\n"
			
			if(this.min.h>this.height){			// pas beau
				//_root.test+="tooBig this.win.frameSet("+this.win.frameSet+") this.win("+this.win+")\n"
				this.win.frameSet.flRestart = true;
			}
			
		}
		
	}
	
	function newVariable(str){
		this.card[str] = {value:"", element:new Array(),listener: new Array()}
		return this.card[str];
	}
		
	function attachResizeButton(){	//DEBUG
		this.content.attachMovie("butDocumentResize","resizeButton",2)
		var mc = this.content.resizeButton
		mc._x = this.content.page.pos.x + this.content.page.pos.w;
		mc._y = this.content.page.pos.y + this.content.page.pos.h;
		mc.obj = this
		mc.onPress = function(){
			startDrag("")
		}
		mc.onRelease = function(){
			stopDrag()
			this.obj.width = _x
			this.obj.height = _y
			this.obj.updateSize();
			//_root.test+="this.obj"+this.obj+"\n"
			
		}			
	}

	function setAlpha(n){		//DEBUG
		//_root.test+="setAlpha\n"
		this._alpha = Number(n)
	}
	
	function traceVariable(){	//DEBUG
		_root.test=""
		for(var a in this.card){
			_root.test+=a+"> "+this.card[a].value+"\n"
		}
	}
	
	function toggle(variable){
		var v = !this.getVariable(variable);
		this.setVariable(variable,v);
		
		return v;
	}
	
	function setVariable(variable,value){
		var v = this.card[variable];
		
		// if(v.value == value) return false;
		
		v.value = value;
		for(var i=0; i<v.element.length; i++){
			var e = v.element[i]
			e.valSetTo(v.value)
		}
		for(var i=0;i<v.listener.length;i++){
			var e = v.listener[i];
			e.obj[e.method](e.args);
		}
		return true;
	}
	
	function getVariable(variable){
		return this.card[variable].value;
	}
	
	// listObj = {obj,method,args,uniq}
	function addVariableListener(variable,listObj){
		this.card[variable].listener.push(listObj);
	}
	
	function removeVariableListener(variable,uniq){
		return this.card[variable].listener.rmByProperty("uniq",uniq);
	}
	
	function getHeight(){
		return this.content.page.min.h
	}
	
	function getContentBounds(){
		// priere de ne pas decommenter pour sauvegarder l'equilibre du frunivers
		var o = {
			xMin:0,				//this.content._x,
			yMin:0,				//this.content._y,
			xMax:this.content.page.min.w,	//this.content._x+this.content.page.min.w,
			yMax:this.content.page.min.h	//this.content._y+this.content.page.min.h			
		}
		/*
		_root.test="----------\n"
		for(var e in o)_root.test+="- "+e+" = "+o[e]+"\n";
		*/
		return o//this.content.page.getContentBounds();		// priere de ne pas decommenter pour sauvegarder l'equilibre du frunivers
	}	
	
//{	
}







