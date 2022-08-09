class cp.ListField extends Component{//}
	
	// CONSTANTE
	var h:Number = 15;
	
	
	// VARIABLE
	//var infoSupList:Array;
	var info:Array;
	var max:Number;
	var iconList:cp.IconListFile;
	var color:Object;
	var callback:Object;
	// var titleField:TextField;
	// var dateField:TextField;
	//var dateDsp;
	var sortIcon:MovieClip;

	function ListField(){
		this.init();
	}

	function init(){
		super.init();
		//_root.test+="Floutch\n"
		this.attachMovie("icoArrow","sortIcon",42)
	}
	
	function setInfo(info){
		//_root.test+="setInfo("+info+")\n"
		// CLEAN
		for(var i=0;i<this.info.length;i++){
			this["but"+i].removeMovieClip();
		}
		// ASSIGN
		this.info = info;
		// MAX
		this.max = 0
		for(var i=0; i<this.info.length; i++)this.max += this.info[i].min;
		// SET FIELDS
		for(var i=0; i<this.info.length; i++){
			var o = this.info[i]
			var initObj = {
				text:o.displayName,
				width:o.min,
				height:15,
				behavior:{ type:"colorText", color:{ base:this.color.overdark, over:color.darker, press:color.lighter } },
				buttonAction:{onPress:[{ obj:this.callback.obj, method:this.callback.method, args:o.sortName }]},
				_y:1
			}			
			this.content.attachMovie("butText","but"+i,10+i,initObj);
			var mc = this.content["but"+i]
			//_root.test+="o.sort("+o.sort+")\n"
			if(o.sort!=undefined){
				//_root.test+="bloug!\n"
				this.sortIcon.target = mc;
				this.sortIcon.gotoAndStop(o.sort+1)
			}
		}
		//
		
		
	}
	
	function updateSize(){
		super.updateSize();
		//_root.test+="updateSize()\n"
		var x = 2
		for(var i=0; i<this.info.length; i++){
			var o = this.info[i]
			var mc = this.content["but"+i]
			mc._x = x;
			x+= o.min;
			if(o.big)x += (this.width - this.max);
		}
		this.sortIcon._x = this.sortIcon.target._x + this.sortIcon.target.field.textWidth + 10
	};
	
	function toggleId(){
	
	};
	
	
	
//{
}