class cp.Custom extends Component{

	var link:String;
	
	function Custom(){
		this.init();
	}
	
	function init(){
		super.init();
	}
	
	function genContent(){
		this.attachMovie(this.link,"content",this.dp_content)
	}
	
}