class de.Line extends DocElement{

	var color:Number;
	var size:Number;
	var margin:Object;
	
	function Line(){
		this.init();
	}
	
	function init(){
		if(this.color==undefined)this.color=this.doc.docStyle.outlineColorNum;//0xFF0000//this.doc.docStyle.outlineColorNum;
		if(this.size==undefined)this.size=2
		if(this.margin==undefined)this.margin = Standard.getMargin();
		super.init();
		
	}
	
	function display(){
		super.display();
	}
	
	function update(){
		//_root.test+=">"+margin.x.ratio+"\n"
		super.update();
		this.clear();
		//this.lineStyle(1,this.color)
		this.beginFill(color)
		var x = this.margin.x.min*this.margin.x.ratio
		var y = this.margin.y.min*this.margin.y.ratio 
		this.moveTo( x,						y 	)
		this.lineTo( this.pos.w-this.margin.x.min/2,		y	)
		this.lineTo( this.pos.w-this.margin.x.min/2,		y+size	)
		this.lineTo( x,						y+size	)
		this.endFill();
	}
	
	
	
	
	
	
}