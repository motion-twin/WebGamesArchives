class de.Field extends DocElement{//}
	
	// a recevoir
	//var flBackground:Boolean;
	var size:Number;		// IMPOSSIBLE A LIRE avec getTextFormat() Comprend pas pkoi alors je stock dans this.size.
	var th:Number;
	var text:String;
	var bgMargin:Number = 4;
	
	var style:Object;
	var align:Number;
	var field:TextField;
	var fieldProperty:Object;
	var textFormat:Object;
	var marginLeft:Number;
	
	var height:Number;

	
	var bg:MovieClip;
	var flBackground:Boolean;
	var bgMainStyleName:String;
	
	var buttonAction:Object;
	var menu:ContextMenu;
	
	//var textHeight:Number;
	
	function Field(){
		//this.init()
	}
	
	function init(){
		//_root.test+="fieldInit\n"
		/*
		if(this.textFormat!=undefined){

			_root.test+="found TextFormat !\n"
			for( var e in this.textFormat )_root.test+="- "+e+" : "+textFormat[e]+"\n";

		}
		//*/
		if(this.text==undefined)this.text="";
		if(this.height==undefined)this.height=Infinity;
		if(this.flBackground==undefined){
			this.flBackground=false;
		}else{
			if(this.bgMainStyleName==undefined){
				this.bgMainStyleName="bgTextColor";
			}
		}
		
		this.initBut();
		
		super.init();
	};

	/*--------------------------------------------------------------------
		function display()
	--------------------------------------------------------------------*/
	function display(){
		super.display();
		if(this.flBackground)this.createEmptyMovieClip("bg",10);
		if(this.style==undefined){
			this.style = FEObject.recursiveClone(this.doc.docStyle.ts);
		};
		/*
		if(this.doc.flTrace){
			_root.test+="co,ffhucou\n";
			_root.test+=">"+this.doc.docStyle+"\n"
		}
		*/
		if( fieldProperty.wordWrap == undefined )this.style.fieldProperty.wordWrap = true;
		if( fieldProperty.multiline == undefined ) this.style.fieldProperty.multiline = true;
				
		FEObject.addObject(this.style.fieldProperty,this.fieldProperty,true);
		FEObject.addObject(this.style.textFormat,this.textFormat,true);
		
		if(this.marginLeft!=undefined)this.style.textFormat.leftMargin=0;
		var ti:TextInfo = new TextInfo(this.style);
		var x = 0
		if( this.flBackground ) x = this.bgMargin;
		ti.pos = { x:x, y:0, w:this.pos.w ,h:this.pos.h };
		ti.attachField(this,"field",30);

		this.setText(this.text);
		this.size = ti.textFormat.size;
		//this.field.html = true;
		//this.field.text = this.text
		//this.field.variable = "text"
		//this.field.watch( "text", this.changeTextValue)
	};
	
	function update(){
		//_root.test+="updateField pos(x:"+this.pos.x+",y:"+this.pos.y+",w:"+this.pos.w+",h:"+this.pos.h+")\n"
		super.update();
		var w = this.pos.w
		if(this.flBackground){
			this.drawBackground();
			w -= this.bgMargin
		}
		this.field._width = w
		this.field._height = Math.min(this.pos.h,this.height)
		this.setMin(this.field.textHeight+6);		
	}

	function drawBackground(){
		//_root.test+="this.bgMainStyleName("+this.bgMainStyleName+")\n"
		this.bg.clear();
		var p = {
			x:0,
			y:2,
			w:this.pos.w,
			h:Math.min(this.pos.h,this.height)-6//this.size+5
		};
		var info = {
			outline:0,
			inline:1,	
			curve:(this.size+5)/2,
			color:{
				main:	this.doc.docStyle[this.bgMainStyleName].light,
				inline:	this.doc.docStyle[this.bgMainStyleName].dark
			}		
		};
		FEMC.drawCustomSquare(this.bg,p,info);
	};
	
	function addHtmlStyle(str){
		return '<font face="'+this.style.textFormat.font+'" color="#'+this.style.textFormat.color.toString(16)+'" size="'+this.style.textFormat.size+'">'+str+"</font>";
	}
	
	function setText(text){
		//_global.debug("setText("+FEString.unHTML(text)+")");
		
		this.text = text;
		if(this.field.html){
		
			//if(this.text=="Sujet :"){_root.test+="C'est un putain d'HTML\n"}
			//_root.test+=text+">"+this.style.textFormat.color.toString(16)+"\n"
			//"<font face=\""+this.style.textFormat.font+"\" color=\"#"+this.style.textFormat.color.toString(16)+"\">"+
			//+"</font>"
			
			if(this.field.type == "input"){
				this.field.htmlText = this.text;
			}else{
				if(this.field.styleSheet == undefined){
					this.field.styleSheet = new TextField.StyleSheet();
				}
				this.field.styleSheet.setStyle("body",{
					color: "#"+this.style.textFormat.color.toString(16),
					fontFamily: this.style.textFormat.font,
					fontSize: this.style.textFormat.size
				});
				
				// Ouh que c'est pas beau ce que je fais...
				if(this.text.substr(0,6) == "<body>"){
					this.field.htmlText = this.text;
				}else{
					this.field.htmlText = "<body>"+this.text+"</body>";
				}
			}
		}else{
			this.field.text = this.text;
			//this.field.replaceSel(this.text)
		}
		this.updateTextHeight();
		
	}
	
	function updateTextHeight(){
		this.th = this.field.textHeight+3
		this.setMin(this.th+3+this.style.space);
	}
	
	
	/*
	function changeTextValue(prop, oldval, newval){
		_root.test+="changeTextValue\n"
		var oldth = this.th;
		this.setText(newval)
		if(oldth != this.th)this.doc.win.frameSet.update();
		
	}
	*/
	
	
	/*-----------------------------------------------------------------------
		Function: initBut()
	------------------------------------------------------------------------*/
	function initBut(){
		for(var elem in this.buttonAction){
			this[elem] = function(){  
				var arr = this.buttonAction[arguments.callee.event];
				for(var i=0;i<arr.length;i++){  
					if(typeof arr[i].obj == "string"){
						arr[i].obj = this[arr[i].obj];	// POUR LES XML QUI PEUVENT PAS ENVOYER DE PATH ( LES PAUVRES )
					}
					arr[i].obj[arr[i].method](arr[i].args);
				} 
			};
			this[elem].event = elem;
		}
		this._focusrect = false;
	}
	
	/*-----------------------------------------------------------------------
		Function: setButtonMethod(event,obj,method,args)
	------------------------------------------------------------------------*/	
	function setButtonMethod(event,obj,method,args){  
		if(this.buttonAction[event] == undefined){  
			this[event] = function(){  
				var arr = this.buttonAction[arguments.callee.event];
				for(var i=0;i<arr.length;i++){  
					if(typeof arr[i].obj == "string"){
						arr[i].obj = this[arr[i].obj];	// POUR LES XML QUI PEUVENT PAS ENVOYER DE PATH ( LES PAUVRES )
					}
					arr[i].obj[arr[i].method](arr[i].args);
					
				} 
			};
			this[event].event = event;
	  
			if(this.buttonAction == undefined){  
				this.buttonAction = new Object();  
			}
			this.buttonAction[event] = new Array();
		}  
		this.buttonAction[event].push({obj: obj,method: method,args: args});
	}  
	
	/*-----------------------------------------------------------------------
		Function: delButtonEvent(event)
	------------------------------------------------------------------------*/	
	function delButtonEvent(event){  
		delete this.buttonAction[event];
		delete this[event];
	}
	
//{
}


