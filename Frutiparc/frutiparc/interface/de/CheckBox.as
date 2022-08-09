class de.CheckBox extends de.Field{//}

	//var val:String;
	var def:Boolean;
	var variable:String;
	var gfx:MovieClip;
	var but:Button;
	var flActive:Boolean;
		
	function CheckBox(){
		this.init();
	}
	
	function init(){
		//_root.test+="Radio Init("+this.val+")\n";
		this.marginLeft = 0;
		this.flActive=this.def;
		super.init();
	};

	function display(){
		super.display();
		this.field._x += this.th;
		this.createEmptyMovieClip("gfx",5)
		// GFX
		this.drawGfx();
		// BUTTON
		this.attachMovie("transp","but",80)
		this.onPress = function(){
			this.toggle();
		}
		
	};
	
	function update(){
		super.update();
		this.field.width-= this.th;
		//this.setMin(this.field.textHeight+6);
		this.but._xscale = this.pos.w
		this.but._yscale = this.pos.h
	};
	
	function drawGfx(){
		//_root.test+="drawGfx\n"
		this.gfx.clear();
		var c = this.doc.docStyle.inputColor;
		var style = {
			outline:0,
			inline:1,	
			curve:0,
			color:{
				main:		c.light,
				inline:		c.dark
			}		
		};
		var p = {
			x:1,
			y:2.5,
			w:this.th-3,
			h:this.th-3
		};
		FEMC.drawCustomSquare(this.gfx,p,style);
		
		if(this.flActive){
			//_root.test+="drawRound\n"
			var style = {
				outline:0,
				inline:0,	
				curve:0,
				color:{
					main:		c.darker
				}		
			};
			var p = {
				x:3.5,
				y:5,
				w:this.th-8,
				h:this.th-8
			};

			FEMC.drawCustomSquare(this.gfx,p,style);
		}
	};

	function toggle(){
		//_root.test+="CheckBox toggle\n"
		//this.doc.toggle(this.variable);
		this.doc.setVariable(this.variable,!this.flActive)
		this.drawGfx()
	}
	
	function valSetTo(v){
		_root.test+="chk valSetTo("+v+")= this.flActive("+this.flActive+")\n"
		this.flActive = v;
		this.drawGfx()
	}	
	
//{
}


