class cp.WinTopBar extends Component{//}

	// CONSTANTES
	var dp_icon = 		8;
	var dp_titleField = 	11;
	var dp_topIcon = 	12;
	var dp_butDrag =	13;	
	
	//var min:Object;
	var topIconWidth:Number;

	
	/*-----------------------------------------------------------------------
		Function: WinTopBar()
		constructeur;
	 ------------------------------------------------------------------------*/	
	function WinTopBar(){
		this.init();
	}
	
	/*-----------------------------------------------------------------------
		Function: init()
	 ------------------------------------------------------------------------*/	
	function init(){
		super.init();
		this.min={w:200,h:20}
		this.initIcon();
		this.initTitle();
		this.initTopIconList();
		this.initButDrag();
	}
	
	/*-----------------------------------------------------------------------
		Function: initIcon()
	 ------------------------------------------------------------------------*/	
	function initIcon(){
		this.content.attachMovie("iconWindow","icon",dp_icon,{_x:4});
		this.content.icon.stop();	// Pour les labels non existant frame 1 = default
		this.content.icon.gotoAndStop(this.win.box.getIconLabel());
	}	
	
	/*-----------------------------------------------------------------------
		Function: initTitle()
	 ------------------------------------------------------------------------*/	
	function initTitle(){
		var ti = new TextInfo()
		ti.pos = {x:20,y:0,w:100,h:20}
		ti.textFormat.bold = true;
		ti.textFormat.color = 0x444444;
		ti.attachField(this.content,"titleField",this.dp_titleField)
		this.content.titleField.variable = "_parent._parent.title"
	}

	/*-----------------------------------------------------------------------
		Function: initTopIconList()
	 ------------------------------------------------------------------------*/	
	function initTopIconList(){
		var struct = Standard.getStruct()
		struct.x.size = 21;
		struct.y.size = 21;
		struct.x.sens = -1;
		struct.x.align = "end"
		var param = {
			list:this.win.topIconList,
			struct:struct,
			width:200,
			height:20,
			_y:-1,
			_x:1,
			flMask:true,
			mask:{flScrollable:false}
		};
		
		//_root.test+="wintopIcon list:"+this._parent.topIconList+"\n"
		
		this.content.attachMovie("basicIconList","mcTopIconList",this.dp_topIcon,param);
	}
	
	/*-----------------------------------------------------------------------
		Function: initButDrag()
	 ------------------------------------------------------------------------*/	
	function initButDrag(){
		this.content.attachMovie("transp","butDrag",this.dp_butDrag);
		var mc = this.content.butDrag;
		
		mc.onPress = function(){
			this._parent._parent._parent.initDrag()
			this._parent._parent._parent.box.activate();
		}	
		mc.onReleaseOutside = function(){
			this._parent._parent._parent.endDrag();
		}
		mc.onRelease = function(){
			this._parent._parent._parent.endDrag();
		}
		mc.useHandCursor = false;
	}
		
	/*-----------------------------------------------------------------------
		Function: updateSize()
	 ------------------------------------------------------------------------*/	
	function updateSize(){
		super.updateSize();
		
		this.topIconWidth = this.content.mcTopIconList.list.length*this.content.mcTopIconList.struct.x.size
		
		var w = this.width-this.topIconWidth
		this.content.mcTopIconList.extWidth = this.width;
		this.content.mcTopIconList.updateSize();
		
		this.content.titleField._width = w;
		
		// BUTDRAG
		this.content.butDrag._xscale = w;
		this.content.butDrag._yscale = this.height;
	};

//{
}


