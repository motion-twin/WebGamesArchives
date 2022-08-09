import ext.util.Callback;

class fc.pan.UserList extends fc.Panel{//}

	// CONSTANTE
	var slotHeight:Number = 20;
	var pageHeight:Number = 8;
	var marginBottom:Number = 20;
	//
	var dp_input:Number = 26;
	var dp_arrow:Number = 29;
	var dp_flagButton:Number = 40;
	var dp_page:Number = 43;
	
	// VARIABLES
	var slotMax:Number;
	var pageMax:Number;
	var pageIndex:Number;
	var flagButtonList:Array;
	var slotList:Array;
	var list:Array;

	
	// MOVIECLIPS
	var inputArrow:MovieClip;
	var mcPage:MovieClip;
	var mcFlagButton:MovieClip;
	var inputField:MovieClip;
	
	function UserList(){
		this.init();
	}
	
	function init(){
		this.slotList = new Array();
		this.pageIndex = 0;
		this.pageMax = 1;
		if(this.flagButtonList==undefined){
			this.flagButtonList=[
				{targetString:" les parties en construction",	value:true},
				{targetString:" les joueurs seuls",		value:true},
				{targetString:" les parties en cours",		value:true}
			]
		}
		this.title = "liste des joueurs"
		super.init();
		this.slotMax = this.size.h/this.slotHeight;

	
		
	}
		
	function display(){
		super.display();
		// FLAGS
		this.createEmptyMovieClip("mcFlagButton",this.dp_flagButton)
		var s = this.marginBottom
		var h = this.lineHeight
		for(var i=0; i<3; i++){
			this.mcFlagButton.createEmptyMovieClip("flagButton"+i,i)
			var mc = this.mcFlagButton["flagButton"+i]
			mc._x = -s*(i+1)
			mc._y = -s
			// BLANC
			var pos = {x:0, y:0, w:s, h:s }
			FEMC.drawSquare(mc,pos,0xFFFFFF)
			// COLOR
			var pos = {x:h, y:h, w:s-h, h:s-h }
			FEMC.drawSquare(mc,pos,this.root.colorSet[i].main)
			// FLAG MASK
			if(!this.flagButtonList[i].value){
				this.maskFlagButton();
			}
			// ACTION
			mc.slList = this;
			mc.id = i;
			mc.onPress = function(){
				this.slList.toggleFlagButton(this.id);
			}
			this.flagButtonList[i].path = mc;
		}
		//INPUT
		var tf = new TextInfo();
		tf.textFormat.color = 0xFFFFFF
		tf.textFormat.size = 11;
		tf.fieldProperty.selectable = true;
		tf.fieldProperty.type = "input"
		tf.attachField(this,"inputField",this.dp_input)
		this.inputField._height = this.marginBottom
		this.inputField._x = 18		
		// INPUTARROW
		this.attachMovie("inputArrow","inputArrow",this.dp_arrow)

		// MANAGER
		this.root.manager.requestList(this.slotMax,new Callback(this,setList));			
		
	}
	
	function initFlagButton(){

	}
	
	function updatePage(){
		this.mcPage.removeMovieClip();
		this.createEmptyMovieClip("mcPage",this.dp_page)
		var toFill = (this.size.w-(this.pageMax-1)*this.lineHeight)
		for(var i=0; i<this.pageMax; i++){
			this.mcPage.createEmptyMovieClip("page"+i,i)
			var mc = this.mcPage["page"+i];
			var w = toFill/this.pageMax
			var x = i*(w+this.lineHeight)
			var h = this.lineHeight
			//BLANC
			var pos = {x:x-h, y:0, w:w+2*h, h:this.pageHeight+h }
			FEMC.drawSquare(mc,pos,0xFFFFFF)
			//CASE
			var pos = {x:x, y:h, w:w, h:this.pageHeight-h };
			var color;
			if(i==pageIndex){
				color = this.col.main
			}else{
				color = 0xDDDDDD
			}
			FEMC.drawSquare(mc,pos,color);
			// ACTION
			mc.id = i;
			mc.slList = this;
			mc.onPress = function(){
				this.slList.goToPage(this.id);
			}
		}
		this.mcPage._y = this.marginUp//this.size.h - (this.marginBottom+this.pageHeight)
		
	}
	
	function setList(list,index,max){
		//_root.test=" --- SetList ---\n"
		this.pageIndex = index
		this.pageMax = max
		this.list = list;
		this.adjustSlotList();
		for(var i=0; i<list.length;i++){
			var info =  this.list[i] 
			//for(var elem in info) _root.test+="-"+elem+" = "+info[elem]+"\n";
			//for(var elem in info.user) _root.test+="  -"+elem+" = "+info.user[elem]+"\n";
			this.slotList[i].updateUser( this.list[i] );
		}
		this.updatePage();
	}
	
	function update(){
		super.update();
		this.drawLine(this.size.h - this.marginBottom);	
		this.slotMax = this.size.h/this.slotHeight;
		// FLAGBUTTON
		this.mcFlagButton._x = this.size.w;
		this.mcFlagButton._y = this.size.h;
		// LINE
		this.drawLine(this.size.h - this.marginBottom);
		// PAGE
		this.updatePage();
		// INPUT
		this.inputField._width = this.size.w-18;
		this.inputField._y = this.size.h+2 - this.marginBottom;
		// INPUTARROW
		this.inputArrow._y = this.size.h			

	}
	
	function adjustSlotList(){
		var a = this.slotList.length
		var b = this.list.length
		if(a<b){
			while(this.slotList.length<b){
				this.addSlot();
			};
		}else if(b<a){
			while(this.slotList.length>b){
				this.removeSlot();
			};		
		};
	};
	
	function addSlot(){
		var n = this.slotList.length
		var initObj = {
			panel:this,
			emptyName:"rejoindre"
		};
		this.attachMovie("fcUserSlot","userSlot"+n,this.dp_main+100-n,initObj)
		var mc = this["userSlot"+n];
		mc._y = this.marginUp + this.pageHeight + this.lineHeight + this.slotHeight*n ;
		this.slotList.push(mc);
	}
	
	function removeSlot(){
		var n = this.slotList.length-1
		var mc = this.slotList.pop();
		mc.kill();
	}	
	
	function toggleFlagButton(id){
		var flag = this.flagButtonList[id].value = !this.flagButtonList[id].value
		if(this.flagButtonList[id].value){
			this.showFlagButton(id);
		}else{
			this.maskFlagButton(id);
		};
		switch(id){
			case 0:
				this.root.manager.listGreen(flag);	
				break;
			case 1:
				//_root.test+="listYellow("+flag+")\n"
				this.root.manager.listYellow(flag);
				break;
			case 2:
				this.root.manager.listRed(flag);
				break;
		}
	}
	
	function maskFlagButton(id){
		var mc = this.flagButtonList[id].path
		mc.attachMovie("maskFlagButton","maskFlagButton",1)
		mc.maskFlagButton._x = this.lineHeight;
		mc.maskFlagButton._y = this.lineHeight;
	}
	
	function showFlagButton(id){
		var mc = this.flagButtonList[id].path
		mc.maskFlagButton.removeMovieClip();
	}	
	
	function goToPage(index){
		//_root.test+="[fc.pan.UserList] goToPage("+index+")\n"
		this.root.manager.requestList(this.slotMax,new Callback(this,setList),index);
	}
	
//{	
}

