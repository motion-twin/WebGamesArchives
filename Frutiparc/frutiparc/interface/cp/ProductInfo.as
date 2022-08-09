class cp.ProductInfo extends Component{//}

	
	// Constante
	//var bgDecal:Number = 113;
	
	//
	var item:Object;
	
	function ProductInfo(){
		this.init();
	}	

	function init(){
		//_root.test+="cp.ProductInfo init\n"
		super.init();
	}
	/*		
	function drawBackground(){
		if(this.win.flMenu){
			this.background.clear();
			var pos = {x:-bgDecal,y:0,w:this.width+bgDecal,h:this.height};
			var style = this.win.style[this.mainStyleName];
			this.background.drawCustomSquare(pos,style);	
		}else{
			super.drawBackground()
		}
	}
	*/
	function setItem(item){
		this.item = item
		//this.attachMovie()
	}
//{
}