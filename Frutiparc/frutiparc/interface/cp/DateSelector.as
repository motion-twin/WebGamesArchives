class cp.DateSelector extends Component{//}

	// CONSTANTES
	var arrowWidth:Number = 20
	// VARIABLES
	var date:Date;
	var mode:Number;
	// REFERENCES
	
	// MOVIECLIPS
	/*
	var leftArrow:but.Push;
	var rightArrow:but.Push;
	var mcDate:but.Push
	*/
	
	function DateSelector(){
		this.init();
	}
	
	function init(){
		//_root.test+="[DateSelector] init()\n"
		super.init();
		this.min = {w:60,h:20}
		this.mode = 0;
		this.initButton();
		this.initDate();
	}
	
	function initButton(){
		var initObj = {
			link:"butPushVerySmallPink",
			frame:4,
			outline:2,
			curve:4,
			buttonAction:{ 
				onPress:[{
					obj:this.win.box,
					method:"prevDate"
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
					obj:this.win.box,
					method:"nextDate"
				}]
			}			
		}
		this.content.attachMovie( "butPush", "rightArrow", 32, initObj )
		
	}
	
	function initDate(){
		var ts = Standard.getTextStyle().def;
		ts.textFormat.align = "center"
		
		if(this.date!=undefined){
			var text = Lang.formatDate(this.date,"day_short")
		}else{
			var text = Lang.fv("loading")
		}
		var initObj = {
			text:text,
			textStyle:ts,
			buttonAction:{ 
				onPress:[{
					obj:this,
					method:"initInputMode"
				}]
			}			
		}
		this.content.attachMovie("butText","date",34,initObj)
		this.content.date._x = arrowWidth;
	}
	
	function initInput(){
		var initObj = {
			doc:new XML("<p><l><i b=\"1\" v=\"date\">"+Lang.formatDate(this.date,"prog_dateonly")+"</i><s w=\"6\"/><b t=\"ok\" l=\"butPushStandard\" o=\"dateSelector\" m=\"requestDay\"/></l></p>"),
			mainStyleName:"global",
			secondStyleName:"content",
			win:this.win,
			dateSelector:this,
			width:this.width,
			height:this.height,
			flTrace:true
		};
		this.content.attachMovie( "cpDocument", "date", 30, initObj )
		this.content.date._x = 0;
		
	}
	
	function initInputMode(){
		this.exitArrowMode();
		this.initInput();
		this.mode = 1
		this.updateSize();
	}
	
	function exitInputMode(){
		this.content.date.removeMovieClip();
		this.initButton();
		this.initDate();		
	}
	
	function initArrowMode(){
		this.initButton();
		this.initDate();
		this.mode = 0
		this.updateSize();
	}
	
	function exitArrowMode(){
		this.content.rightArrow.removeMovieClip();
		this.content.leftArrow.removeMovieClip();
		this.content.date.removeMovieClip();	
	}
	
	function updateSize(){
		super.updateSize();
		this.content.rightArrow._x = this.width-this.arrowWidth;
		
		this.content.date.extWidth =  this.width;
		this.content.date.extHeight =  this.height
		if(this.mode==0){
			this.content.date.extWidth -= this.arrowWidth*2
		}
		
		this.content.date.updateSize();
	}
		
	function requestDay(){
		this.win.box.setDate(this.content.date.card.date.value)
		initArrowMode();
	}
	
	function setDay(date){
		//_root.test+="[cpDateSelector] setDay("+date+")\n"
		this.date = date;
		this.content.date.setText(Lang.formatDate(this.date,"day_short"))
	}
	

	
//{	
}