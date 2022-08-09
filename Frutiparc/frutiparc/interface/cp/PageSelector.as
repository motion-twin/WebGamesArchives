class cp.PageSelector extends Component{//}

	// CONSTANTES
	var arrowWidth:Number = 20
	
	
	
	// PARAMETRE
	// var index:Number;
	// var pageMax:Number;
	// var mode:Number;
	
	// REFERENCES
	
	// MOVIECLIPS
	
	/*
	var leftArrow:but.Push;
	var rightArrow:but.Push;
	var mcDate:but.Push
	*/
	
	function PageSelector(){
		this.init();
	}
	
	function init(){
		_root.test+="[PageSelector] init()\n"
		super.init();
		this.min = {w:60,h:20}
		this.initButton();
		//this.initText();
	}
	
	function initButton(){
		var initObj = {
			link:"butPushVerySmallPink",
			frame:4,
			outline:2,
			curve:4,
			buttonAction:{ 
				onPress:[{
					obj:this.win,
					method:"prevPage"
				}]
			}			
		}
		this.content.attachMovie( "butPush", "leftArrow", 30, initObj )
		var initObj = {
			link:"butPushVerySmallPink",
			frame:3,
			outline:2,
			curve:4,
			buttonAction:{ 
				onPress:[{
					obj:this.win,
					method:"nextPage"
				}]
			}			
		}
		this.content.attachMovie( "butPush", "rightArrow", 32, initObj )
		
	}
	
	function setText(text){
		var ts = Standard.getTextStyle().def;
		ts.textFormat.align = "center"
		
		var initObj = {
			text:text,
			textStyle:ts,
			buttonAction:{ 
				onPress:[{
					obj:this,
					method:"gloups"//"initInputMode"
				}]
			}			
		}
		this.content.attachMovie("butText","text",34,initObj)
		this.content.text._x = arrowWidth;
	}
	
	function updateSize(){
		super.updateSize();
		this.content.rightArrow._x = this.width-this.arrowWidth;
		
		this.content.text.extWidth =  this.width - this.arrowWidth*2;
		this.content.text.extHeight =  this.height
	
		this.content.text.updateSize();
	}
	
//{	
}