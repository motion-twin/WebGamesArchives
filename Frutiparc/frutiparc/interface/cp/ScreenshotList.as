class ScreenshotList extends Component {

	
	var flEmpty:Boolean;
	var mcList:Array;
	
	function ScreenshotList(){
		this.init();
	}
	
	
	function init(){
		super.init();
		this.flEmpty = true;
	}
	
	function setList(info){
		//* HACK INFO
		var info = {
			size:{ w:100, h:80 },
			flTitle:true;
			flComment:false;
			list = [
				{urlSmall:"",urlBig:"",title,comment:""},
				{urlSmall:"",urlBig:"",title,comment:""},
				{urlSmall:"",urlBig:"",title,comment:""}
			]		
			
		}		
		//*/
			
		if(!this.flEmpty)this.cleanList();
			
		
		
		
		
		
		
		
	}	
	
	function cleanList(){
		while(this.mcList.length>0){
			this.mcList.pop().removeMovieClip();
		}
	}
	
	
	
}