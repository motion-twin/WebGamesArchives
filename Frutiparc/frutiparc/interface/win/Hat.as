class win.Hat extends win.Advance{//}

	
	var list:Array;
	var index:Number;
	
	var screen:cp.FrutiScreen
	var selector:cp.PageSelector
	
	function Hat(){
		this.init();
	}
	
	function init(){
		this.init();
		this.endInit();
	}
	
	function initFrameSet(){
		super.initFrameSet();
		
		var m = Standard.getMargin();
		var frame = {
			type:"compo",
			name:"screen",
			link:"frutiScreen",
			min:{w:100,h:100},
			win:this,
			margin:m
		};
		this.main.newElement(frame);

		var frame = {
			type:"compo",
			name:"selector",
			link:"cpPageSelector",
			min:{w:100,h:20},
			win:this,
			margin:m
		};
		this.main.newElement(frame);		
	
	}

	function setList(list){
		
		//* ET PAF ! LE GROS HACK DE PORC
		list = [
			{ name:"chapeau 1",	id:"0007060g000b090000"},
			{ name:"chapeau 2",	id:"0006060g000b090000"},
			{ name:"chapeau 3",	id:"0005060g000b090000"},
			{ name:"chapeau 4",	id:"0004060g000b090000"},
			{ name:"chapeau 5",	id:"0007050g000b090000"},
			{ name:"chapeau 6",	id:"0007040g000b090000"},
			{ name:"chapeau 7",	id:"0007030g000b090000"}
		]
		//*/
		
		this.list = list
		this.index = 0;
	}
	
	function inc(n){
		var max = this.list.length
		this.index += n;
		while( this.index > max )	this.index -= max;
		while( this.index < 0 )		this.index += max;
		
		var info = this.list[this.index]
		
		var initObj = {
			id:info.id
			
		}
		this.screen.addContent( "frutibouille", initObj, 1 )
		this.selector.setText(info.name)
	}

	
	function prevPage(){
		this.inc(-1)
	}
	
	function nextPage(){
		this.inc(1)
	}	
	
	
	
	
	
	
//{	
}