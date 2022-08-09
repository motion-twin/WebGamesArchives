/*
$Id: FPCBeeManager.as,v 1.3 2003/10/13 23:28:24  Exp $

Class: FPCBeeManager
*/
class FPCBeeManager extends CBeeManager{
	function FPCBeeManager(o){
		super(o);
	}

	function addCnx(port,force,obj){
		if(_global.me.name != undefined && _global.me.pass != undefined){
			var obj = {login: _global.me.name,pass: _global.me.pass};
		}else{
			var obj = {};
		}
		return super.addCnx(port,force,obj);
	}

}
