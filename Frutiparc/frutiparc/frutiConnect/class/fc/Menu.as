class fc.Menu extends MovieClip{//}
	
	//CONSTANTES
	var slotWidth:Number = 260;
	var slotHeight:Number = 50;
	var slotMargin:Number = 4;
	
	
	// VARIABLES
	var roomList:Array;
	
	// REFERENCES
	var root:FrutiConnect;
	var fcBarre:MovieClip;
	var logo:MovieClip;
	var field:TextField;
	
	function Menu(){
		this.init();
	}
	
	function init(){
		//_root.test+="[Fruticonnect.menu] init()\n"

		this.initBar();
		
		this.roomList = new Array();
		/*
		var a =  [
			{ name:"challenge",	players:12,	games:4,	id:0,	flActive:true	},
			{ name:"super mode",	players:94,	games:42,	id:1,	flActive:false	},
			{ name:"entrainement",	players:8,	games:1,	id:2,	flActive:false	}
		]
		this.setRoomList(a)
		*/
	}
	
	function initBar(){
		_root.test += ">initBar\n"
		//
		this.attachMovie("fcBarre","fcBarre",120)
		//
		//this.fcBarre.name = this.root.gameName;
		//
		this.createEmptyMovieClip("logo",124);
		this.logo._y = 76
		var mcl = new FEMCLoader();
		var listener = new Object();
		listener.obj = this;

		listener.onLoadComplete = function(mc){
			_root.test += ">logo label("+this.obj.root.gameName+")\n"
			mc.gotoAndStop(this.obj.root.gameName);
		}
		mcl.addListener(listener);
		mcl.loadClip(Path.fcLogo,this.logo);
		//
		/*
		var ti = new TextInfo();
		ti.textFormat.color = 0xEEEEEEz;
		ti.textFormat.font ="Alien Encounters Solid";
		ti.fieldProperty.selectable =false;
		ti.fieldProperty.embedFonts = true;
		ti.pos = { x:-22, y:this.root.mch+11, w:200, h:100 };
		ti.attachField(this,"field",128);
		this.field.text = this.root.gameName;
		var ratio = 100/this.field.textHeight;
		this.field._yscale = ratio*100;
		var ratio = (this.root.mch - (160 + 4) )/this.field.textWidth;
		this.field._xscale = ratio*100;
		this.field._rotation -= 90;
		var b = this.field.getBounds()
		_root.test+="b("+b+")\n"
		*/

	}
	
	function setRoomList(list){
		this.cleanSlot();
		var x = 112+((this.root.mcw-112)/2) - (this.slotWidth/2)
		var y = (this.root.mch/2) - (list.length*(this.slotHeight+this.slotMargin))/2
		for(var i=0; i<list.length; i++ ){
			var info = list[i]
			var initObj = {
				root:this.root,
				name:info.name,
				players:info.players,
				id:info.id,
				flActive:info.flActive,
				games:info.games,
				width:slotWidth,
				height:slotHeight
			}
			this.attachMovie("fcMenuSlot","slot"+i,i,initObj);
			var mc = this["slot"+i];
			mc._x = x;
			mc._y = y + i*(this.slotHeight+this.slotMargin);
		}
	}
		
	function cleanSlot(){
		while( this.roomList.length>0 ){
			this.roomList[0].kill();
		}
	}
	
	function joinRoom(id){
		//_root.test+="[Fruticonnect.menu] joinRoom("+id+")\n"
		this.root.manager.joinRoom(id)
		this.root.manager.joinRoomSpecialeDedicaceFrancois(id)
	}
	
	
	
	
//{
}