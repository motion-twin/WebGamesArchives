/*
$Id: CBeeLC.as,v 1.3 2003/09/17 11:42:26  Exp $

Class: CBeeLC
*/
class CBeeLC extends LocalConnection{
	var cbee;
	
	function CBeeLC(cbee){
		this.cbee = cbee;
	}

	function send(x){
		this.cbee.send(x);
	}

	function cmd(a,b,c){
		this.cbee.cmd(a,b,c);
	}
}
