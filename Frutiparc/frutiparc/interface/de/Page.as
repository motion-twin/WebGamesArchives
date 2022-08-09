class de.Page extends DocElement{//}

	//var flAnotherUpdate:Boolean;
	var flNeverEnding:Boolean;
	var lineList:Array;
	var cur:Object;
	var depth:Number;
	var doc:cp.Document;
	
	//var actualHeight:Number;
	
	/*--------------------------------------------------------------------
		function Page()
	--------------------------------------------------------------------*/
	function Page(){

		this.init()
	}
	
	/*--------------------------------------------------------------------
		function init()
	--------------------------------------------------------------------*/	
	function init(){
		if(this.flNeverEnding==undefined)this.flNeverEnding=false;
		super.init();
		//this.display();
	}

	/*--------------------------------------------------------------------
		function display()
	--------------------------------------------------------------------*/
	function display(){
		this.depth = 0;

		for(var i=0; i<this.lineList.length;  i++){
			this.newLine(this.lineList[i]);
		}
	}	
	
	/*--------------------------------------------------------------------
		function newLine()
	--------------------------------------------------------------------*/
	function newLine(line){

		for( var i=0; i<line.list.length; i++ ){
			this.newElement(line.list[i]);
			if(line.height == undefined )line.height = 0;
		}		
	}
	
	/*--------------------------------------------------------------------
		function newElement(e)
	--------------------------------------------------------------------*/
	function newElement(e){
		//return;
		// ATTRIBUTION DES PARAMETRES PAR DEFAUT
		if(e.param==undefined)e.param = new Object();
		e.param.doc = this.doc;
		e.param.win = this.doc.win;
		e.param.page = this;
		
		var flDefBig = false

		
		switch(e.type){
			case "page":
				e.link = "dePage";
				e.param.flNeverEnding = false;
				e.param.lineList = e.lineList;
				//e.param.pos = e.pos;			
				break;
			case "text":
				if( e.param.sid == undefined ){
					e.link = "deText";
				}else{
					e.link = "deStyledText";
				}
				flDefBig=true;
				break;
			case "url":
				e.link = "deUrl";
				break;
			case "link":
				e.param.win = this.doc.win;
				break;
			case "spacer":
				flDefBig=true;
				break;			
			case "button":
				e.link = "butPush"
				if(e.param.link==undefined)e.param.link="butPushStandard";
				if(e.param.color==undefined){
					//_root.test+="color Undefined ("+this.doc.docStyle+")\n"
					e.param.color=this.doc.docStyle.outlineColorNum;
					/*
					var ds = this.doc.docStyle
					for( var elem in ds){
						_root.test += " - "+elem+" : "+ds[elem]+"\n";
					}
					*/
				}
				if(e.param.flTrace!=undefined)_root.test+="-->"+e.param.buttonAction+"\n"
				break;
			case "input":
				e.link = "deInput"
				//e.param.fieldProperty = {type:"input", selectable:true}
				//e.param.flBackground = true;
				e.param.def = e.param.text;
				flDefBig=true;
				break;
			case "radio":
				e.link = "deRadio";
				break;
			case "checkBox":
				e.link = "deCheckBox";
				if(e.param.def==undefined)e.param.def=0;
				break;
			case "comboBox":
				e.link = "deComboBox";
				e.param.pal = {
					but:this.doc.docStyle.outColor,
					bg:this.doc.docStyle.inputColor
				}
				break;
			case "line":
				e.link = "deLine";
			
		}
		//LARGEUR
		if(e.width!=undefined) e.width = Number(e.width); else e.width=0;
		if(e.height!=undefined) e.height = Number(e.height); else e.height=0;
		if(e.big!=undefined){
			e.big = Number(e.big);
		}else if(e.width==0 and flDefBig){
			e.big = 1;
		}
		// ATTACHEMENT
		if(e.type != "spacer"){
			var d = 10000-this.depth++
			this.attachMovie( e.link, "element"+d, d, e.param );

			var mc = this["element"+d];
			/*
			if(this.doc.flTrace){
				_root.test += "e.link("+e.link+")\n"
				_root.test += "mc("+mc+")\n"
			}
			*/
			e.path = mc;
		}else{
			e.path = new Object();
		}

		// AJOUT A LA CONSOLE
		if(e.param.name){
			this.doc.console[e.param.name]=e.path
		}
		
		// AJOUT A LA TABLE DES VARIABLES
		if(e.param.variable){
			if(this.doc.card[e.param.variable]==undefined){
				var v = this.doc.newVariable(e.param.variable);
			}else{
				var v = this.doc.card[e.param.variable];
			}
			v.element.push(e.path);
			if(e.param.def!=undefined)v.value = e.param.def;
			
		}		
		
	}

	/*--------------------------------------------------------------------
		function update(e)
	--------------------------------------------------------------------*/
	function update(){
		super.update();
		this.cur = { x:0, y:0}
		var height = 0
		
		var displayLineList = this.getDisplayLineList();
		
		
		var lHList = new Array();
		//var bigList = new Array();
		var min = 0;					//Sert a calculer la hauteur minimal des élément a afficher
		var totalBig = 0;				//Sert a calculer la valeur total du "big denominateur"
		for(var i=0; i<displayLineList.length; i++){
			var line = displayLineList[i];
			var h = this.getLineHeight(line)
			
			if(line.big>0){
				totalBig+=line.big;
			}else{
				min += h
			}
			lHList.push(h)
		}
		
		var extraLineSpace = this.pos.h-min	// REC
		
		for(var i=0; i<displayLineList.length; i++){
			var line = displayLineList[i];
			var  h = lHList[i]
			if(line.big!=undefined && extraLineSpace>0 && totalBig!=0){	// alloue de l'espace supplémentaire a une "big" line
				h  = Math.max(h,(line.big/totalBig)*extraLineSpace)
			}			
			this.updateLine(line,h);
			this.cur.y += h;
			height += h;
			
		};
		/*
		for(var i=0; i<lHList.length; i++){
			_root.test+="..."+lHList[i]+"\n"
		}
		*/
		
		
		//
		
		this.setMin(height)
	}

	/*--------------------------------------------------------------------
		function updateLine(line)
	--------------------------------------------------------------------*/
	function updateLine(line,lineHeight){
		this.cur.x = 0;
		var min = 0;					//Sert a calculer la largeur minimal des élément a afficher
		var totalBig = 0;				//Sert a calculer la valeur total du "big denominateur"
		
		for( var i=0; i<line.list.length; i++ ){
			var e = line.list[i]
			if(e.path.min.w!=undefined){				// Recalcul la largeur de l'element si celui-ci possede intranscequement une largeur minimal
				var w = Math.max(e.width,e.path.min.w)		
			}else{
				var w = e.width
			}
			min += w;						// MAJ de min
			if(e.big!=undefined){					// MAJ de totalBig 
				totalBig += e.big;
			}
		}
		
		var space = this.pos.w - min					// determine l'espace a allouer aux "big" elements
		var width = this.pos.w						// initialise un compteur de longueur qui sera decrementé au court de l'affichage
		
		for( var i=0; i<line.list.length; i++ ){
			var e = line.list[i]
			var mc = e.path;

			var w = Math.min(e.width, width)			// retaille la largeur de l'element si il n'y a plus assez de place en width
			if(e.path.min.w!=undefined){				// Retaille la largeur de l'element si celui-ci possede intranscequement une largeur minimal
				var w = Math.max(w,e.path.min.w)
			}
			if(e.big!=undefined and space>0 and totalBig!=0){	// alloue de l'espace supplémentaire a un "big" élement
				w  += (e.big/totalBig)*space
			}
			
			var h =lineHeight
			mc.pos = {
				x:this.cur.x,
				y:this.cur.y,
				w:w,
				h:h
			}
			if(e.dx)mc.pos.x+=Number(e.dx);					// POUR DES AJUSTEMENTS UN PEU SALES
			if(e.dy)mc.pos.y+=Number(e.dy);					// POUR DES AJUSTEMENTS UN PEU SALES

			mc.update();
			this.cur.x += mc.pos.w
			width -= mc.pos.w
		}	
	}
	
	function getLineHeight(line){
		
		//return line.height;
		
		if(line.height>0){
			return line.height;
		/*
		}else if(line.big>0){
			return 0;
		*/
		}else{
			var h=0;
			for( var i=0; i<line.list.length; i++ ){
				var e = line.list[i]
				h = Math.max( h, e.height )
				if(e.path.min.h!=undefined){
					h = Math.max(h,e.path.min.h)
				}
			}
			return h;
		}
	}
	
	function getDisplayLineList(){
		
		var list = new Array();
		for( var i=0; i<this.lineList.length; i++ ){
			var line = this.lineList[i];

			if(line.big==undefined && line.height==0 ){	// RAJOUTER UN TAG DE LIGNE NORETURN
				var w = this.pos.w;
				var first = 0;
	
				for( var n=0; n<line.list.length; n++ ){
					var e = line.list[n];
					w-= e.width;
					if(w<0){
						list.push( { list:line.list.slice(first,n) } );
						first = n;
						w = this.pos.w-e.width;
					}
				};
				list.push( { list:line.list.slice(first,line.list.length) } );
			}else{
				list.push(line)
			}
		}
		return list;
	}
	
	
	
//{	
}













