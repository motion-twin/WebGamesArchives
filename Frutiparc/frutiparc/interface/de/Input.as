class de.Input extends de.Field{//}

	var variable:String;
	var flSingleLine:Boolean;
	
	var colorToUse:String;
	
	function Input(){
		this.init();
	};
	
	function init(){
		//_root.test+="deInput init("+this.variable+")\n"
		if( this.flBackground == undefined ) this.flBackground = true;
		if( this.bgMainStyleName == undefined ) this.bgMainStyleName = "inputColor";
		if( this.textFormat == undefined ) this.textFormat = new Object();
		if( this.flSingleLine == undefined )this.flSingleLine=true;
		
		if( this.colorToUse == undefined ) this.colorToUse = "darker";
		this.textFormat.color = this.doc.docStyle.inputColor[this.colorToUse];
		
		super.init();
		
	};
	
	function display(){
		super.display();
		if(this.flSingleLine){
			this.height=this.size+10;
			this.field.multiline=false;
		}
		this.field.selectable=true;
		this.field.type="input";
		
		/*
		// --> onChanged
		this.field.onKillFocus =function(){
			this.doc.setVariable(this.variable,this.html?this.htmlText:this.text);
		};
		*/
		
		this.doc.setVariable(this.variable,this.field.html?this.field.htmlText:this.field.text);
		
		// MET AUTOMATIQUEMENT LA TAILLE A JOUR EN CAS D'INPUT ET RETAILLE LE FRAMESET SI BESOIN EST
		
		this.field.onChanged = function(){
			var oldth = this._parent.th;
			this._parent.updateTextHeight()
			if(oldth != this._parent.th){
				this._parent.doc.win.frameSet.update();
			}
			
			this._parent.doc.setVariable(this._parent.variable,this.html?this.htmlText:this.text);
		}
		
	
	};
	
	function setText(text){
		if((this.field.html?this.field.htmlText:this.field.text) == text){
			return false;
		}
		
		super.setText(text);
		
		// Pour définir après que flash ait transformé htmlText dans son html pas beau
		// Skool: bum avais mis en commentaire cette ligne, mais je l'ai remis pour la raison indiquée juste au dessus.
		//_global.debug("ça donne: <br/>"+FEString.unHTML(this.field.htmlText));
		this.doc.setVariable(this.variable,this.field.html?this.field.htmlText:this.field.text);
		
	}

	function valSetTo(v){
		this.setText(v);
	}
	
	/*
	function setText(text){
		this.text = FEString.replaceBackSlashN(text);
		this.field.text = this.text;
		var tf = this.field.getTextFormat()
		this.th = this.size+3
		//this.field.text = "coucou";
		//_root.test+="th("+this.th+") tf("+tf+") tf.size("+tf.size+")\n"
		this.setMin(this.th+3+this.style.space);
		//_root.test+="this.min.h:"+this.min.h+"\n"
	}
	*/
//{
}

// LALA TSOIN