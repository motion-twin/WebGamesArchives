class It{//}

	var flEquip:bool;
	var flGeneral:bool;
	var flUse:bool;
	
	var type:int;
	var link:String;
	
	var fi:FaerieInfo
	
	
	function new(){
		
	}
	
	function setType(t){
		type = t	
	}
	
	function init(){
		
	}
	
	function grab(){
		
	}
	
	function use(fi:FaerieInfo){
		
	}
	
	function faerieEffect(){
		return false;
	}
	
	function groupEffect(fi:FaerieInfo ){
		return false;
	}
	
	function faerieGroupEffect(){
	
	}
	
	function getPic(dm,dp):MovieClip{
		return dm.attach(link,dp)
	}

	function getInfoMsg(){
		var msg = new Msg(getDesc())
		msg.type = 1
		msg.title = getName()+":"
		return msg
	}
	
	function updatePic(pic){
		
	}
	
	function getName(){
		return "noName ";
	}
	
	function getQt(){
		return "noQt ";
	}
	
	function getDesc(){
		return "noDesc ";
	}	

	
//{	
}