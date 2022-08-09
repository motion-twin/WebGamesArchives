class DocElement extends MovieClip/*Component (Je vais surement le regretter...)*/{//}
	
	// CONSTANTES
	var dp_linkButton:Number = 1258;
	
	// VARIABLES
	var flLink:Boolean;
	var flResizable:Boolean;
	var flDrawBox:Boolean;
	var glAction:Array;		// A REMPLACER PAR UN VRAI BUTTONACTION
	var pos:Object;
	var min:Object;
	
	// REFERENCES
	var parent:de.Page;
	var doc:cp.Document;
	var page:de.Page;
	var mcLinkButton:MovieClip;
	

	function DocElement(){
	
	}
	
	function init(){
		//if(this.glAction!=undefined)_root._alpha = 50;
		if(this.flDrawBox==undefined)this.flDrawBox=false;
		this.checkLink();
		this.initMin();
		this.display();
		
	}
	
	function checkLink(){
		this.flLink = this.glAction != undefined
	}
	
	function display(){
		if( this.flLink ){
			this.attachMovie( "transp", "mcLinkButton", this.dp_linkButton )
			this.mcLinkButton.onPress = function(){
				_parent.triggerGlAction();

			}
		}
	}

	function triggerGlAction(){
		var c = this.glAction;
		var obj = this[c.o]
		if(obj == undefined) obj = eval(c.o);
		if(obj == undefined) obj = eval(this+"."+c.o);
		//_root.test+="push! c.o("+c.o+") obj("+obj+")\n"
		obj[c.m](c.a);	
	}
	
	/*--------------------------------------------------------------------
		function update(e)
	--------------------------------------------------------------------*/
	function update(){
		//_root.test+="test("+this.pos.w+","+this.pos.w+")\n"
		this._x = this.pos.x;
		this._y = this.pos.y;
		if(this.flDrawBox){
			this.clear()
			this.lineStyle(1,0x66AA22)
			this.moveTo(0,0)
			this.lineTo(this.pos.w,0)
			this.lineTo(this.pos.w,this.pos.h)
			this.lineTo(0,this.pos.h)
		}
		if(this.flLink){
			this.mcLinkButton._xscale = this.pos.w;
			this.mcLinkButton._yscale = this.pos.h;
		}
		
		
	}

	function initMin(){
		//_root.test+="initMin\n"
		
		// Skool: j'ajoute un if undefined pour pouvoir définir le min dans un pageObj !
		if(this.min == undefined){
			this.min = {x:0,w:0}
		}else{
			if(this.min.h == undefined) this.min.h = 0;
			if(this.min.w == undefined) this.min.w = 0;
		}		
	}

	function setMin(h){
		//if( this.min.h!= h ) this.page.flAnotherUpdate=true;
		this.min.h = h
	}
	
	
//{	
}