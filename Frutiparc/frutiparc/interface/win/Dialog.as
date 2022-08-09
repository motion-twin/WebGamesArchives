class win.Dialog extends win.Advance{//}

	var mainField:Frame;
	var inputField:Frame;

	/*-----------------------------------------------------------------------
		Function: init()
	 ------------------------------------------------------------------------*/	
	function init(){
		super.init();

		this.initMainField()
		this.initInputField();
		
		
	};

	/*-----------------------------------------------------------------------
		Function: initMainField()
	 ------------------------------------------------------------------------*/	
	function initMainField(){
		
		var margin = Standard.getMargin()
		margin.x.min = 8;
		margin.y.min = 8;		
		var frame = {
			name:"fieldFrame",
			link:"multiTextField",
			marginInt:margin,
			type:"compo",
			
			min:{w:100,h:100},
			flBackground:true,
			args:{
				flMask:true,
				flGravity:true,
				win:this,
				dropBox:this.box
				//mainStyleName:"content"
			}
		}
		this.mainField = this.main.newElement(frame);
		this.main.bigFrame = this.main.fieldFrame;
	}

	/*-----------------------------------------------------------------------
		Function: initInputField()
	 ------------------------------------------------------------------------*/	
	function initInputField(){

		var margin = Standard.getMargin();
		margin.y.min = 6;
		margin.y.ratio = 1;
		
		var frame = {
			name:"inputFrame",
			link:"inputField",
			type:"compo",
			//min:{w:0,h:12},
			margin:margin 
		}
		
		this.inputField = this.main.newElement(frame)
		this.inputField.setBox(box);
	};
	
	/*-----------------------------------------------------------------------
		Function: getInput()
	 ------------------------------------------------------------------------*/	
	function getInput(){
		return this.inputField.getInput();
	}
	
	/*-----------------------------------------------------------------------
		Function: setInput()
	 ------------------------------------------------------------------------*/	
	function setInput(str){
		this.inputField.setInput(str);
	}
	
	function scrollText(delta){
		this.mainField.mask.y.path.pixelScroll(delta);
	}
	
//{	
}

