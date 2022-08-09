class de.ComboBox extends de.Field{//}
	
	var pal:Object;	//button, bg, textColor
	
	var variable:String;
	var def:Number;
	var flOpen:Boolean;
	var selectId:Number;
	var heightMax:Number;
	var elementList:Array;
	
	var but:Button;
	var mcList:MovieClip;
	var panel:MovieClip;
	
	function ComboBox(){
		this.init();
	};
	
	function init(){
		if(this.selectId == undefined)this.selectId = Number(this.def);
		if(this.heightMax == undefined)this.heightMax = 100;
		this.initElementList();
		this.flOpen=false;	
		super.init();
		//_root.test+="pal.but("+this.pal.but+")\n"
		
		/*
		_root.test+="[ComboBox] pal : \n"
		for(var elem in this.pal){
			var o = this.pal[elem]
			_root.test+="-"+elem+" = "+o+"\n"
			for(var elem in o)_root.test+=" -"+elem+" = "+o[elem]+"\n"			
		}
		*/
		
	};
	
	function initElementList(){
		//_root.test+="initElementList("+this.text+")\n"
		this.elementList = this.text.split(";");
	};
	
	function display(){
		
		// FIELD	
		super.display()
		this.field.text = this.elementList[this.selectId];
		this.field.textColor = this.pal.bg.darkest
		
		// PANEL
		this.createEmptyMovieClip("panel",5)
		
		// BUTTON
		this.createEmptyMovieClip("but",85)
		var c = this.field.textHeight+3 
		var p = { x:0, y:0 , w:c, h:c };
		var style = {
			outline:0,
			inline:1,	
			curve:0,
			color:{
				main:		this.pal.but.main,
				inline:		this.pal.but.shade
			}		
		};
		FEMC.drawCustomSquare(this.but,p,style);
		this.but._y=1;
		this.but.onRelease = function(){
			this._parent.trigger();
		};
		this.select({id:this.selectId})
	}
	
	function trigger(){
		if(this.flOpen){
			this.closeMenu();
		}else{
			this.openMenu();
		}	
	}
	
	function openMenu(){
		
		//_root.test+="openMenu\n"

		var list = new Array();
		var h = Math.max(this.field.getTextFormat().size,10)+4
		
		for(var i=0; i<this.elementList.length; i++){
			//_root.test+="o"
			var o = new Object();
			o.link = "butText";
			
			var tsg = Standard.getTextStyle();
			o.param.textStyle = tsg.def;
			o.param.textStyle.textPropery.color = this.pal.bg.darkest
			o.param.textStyle.textFormat.leftMargin = 4
			
			o.param = new Object();
			o.param.text = this.elementList[i];
			//o.param.extWidth = this.pos.w; //o.param.width = this.pos.w;
			o.param.width = this.pos.w;
			o.param.height = h;
			
			o.param.behavior ={
				type:"colorBackground",
				color:{
					base:this.pal.bg.darker,
					over:this.pal.bg.dark,
					press:this.pal.bg.main,
					bg:this.pal.bg.lighter
				}	
			}
			o.param.buttonAction = new Object();
			o.param.buttonAction.onRelease = [{obj:this,method:"select",args:{id:i}}]
			list.push(o);
		};
		var struct = Standard.getStruct();
		struct.x.size = this.pos.w;
		struct.y.size = 12;
		
		var param = {
			struct: struct,
			list : list,
			_x:0,
			_y:(this.field.textHeight+3),
			extWidth:this.pos.w,//width:this.pos.w,
			win:this.doc.win,
			scrollInfo:{	link:"sbSquare",	param:{	size:14, color:{fore:this.pal.but, back:this.pal.bg}} }
		}
		if(this.heightMax>0){
			param.flMask = true;
			param.height = this.heightMax
		};
		
		// ATTACHEMENT DE LA LISTE
		this.attachMovie("basicIconList","mcList",60,param)
		this.mcList.updateSize();

		if(this.heightMax>0){
			var h = Math.min( this.mcList.actualHeight+4, this.heightMax )
		}else{
			var h = this.mcList.actualHeight+4
		}	
		// PANEL DRAW
		var p = {
			x:0,
			y:this.mcList._y,
			w:this.pos.w,
			h:h
		};
		var style = {
			outline:0,
			inline:1,	
			color:{
				main:		this.pal.bg.light,
				inline:		this.pal.bg.dark
			}		
		};
		FEMC.drawCustomSquare(this.panel,p,style)
		
		// FLAG UPDATE
		this.flOpen=true;	
	}
	
	function closeMenu(){
		this.mcList.removeMovieClip();
		//this.panel._visible=false;
		this.panel.clear();
		this.flOpen=false;	
	}
	
	function update(){
		super.update();
		this.drawBackground();
		this.but._x = this.pos.w - (this.field.textHeight+3)
	}
	
	function drawBackground(){
		this.clear();
		var c = this.field.textHeight+3
		var p = {
			x:0,
			y:1,
			w:this.pos.w-(c-1),
			h:c
		};
		//var s = this.doc.win.style[this.doc.mainStyleName];
		var style = {
			outline:0,
			inline:1,	
			curve:0,
			color:{
				main:		this.pal.bg.light,//s.color.light,
				inline:		this.pal.bg.dark
			}		
		};
		FEMC.drawCustomSquare(this,p,style);
	}
	
	function select(o){
		//_root.test+="select("+o.id+") this.elementList[this.selectId].text("+this.elementList[this.selectId]+")\n"
		this.doc.setVariable(this.variable,o.id)
	}
	
	function selectValue(val){
		for(var i=0;i<this.elementList.length;i++){
			if(this.elementList[i] == val){
				this.select({id: i});
				return true;
			}
		}
		return false;	
	}
	
	function valSetTo(id){
		this.selectId = id
		this.field.text = this.elementList[this.selectId];
		this.closeMenu();
	}
	
//{	
}
















