class DepthList{

	var list:Array;
	
	function DepthList(max){
		this.init(max);
	}
	
	function init(max){
		this.list = new Array();
		for(var i=0; i<max; i++){
			this.list.push(i);
		}
	}
	
	function insertDepth(num){
		this.list.push(num);
	}
	
	function removeDepth(num){
		for(var i=0; i<this.list.length; i++){
			if(this.list[i] == num)this.list.splice(i-1);
		}
	}

	function giveDepth(){
		return this.list.pop();
	}
	
	function returnDepth(mc){
		this.insertDepth(mc.getDepth())
	}
	
}
