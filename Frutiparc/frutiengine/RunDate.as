/*
$Id: RunDate.as,v 1.11 2004/03/11 21:37:25  Exp $

Class: RunDate
*/
class RunDate{
	var ref:Date;
	var refLocal:Date;
	var diff:Number;

	function RunDate(){
	}

	function setFromString(str){
		this.refLocal = new Date();
		this.ref = FEDate.newFromString(str);
		this.diff = this.ref.getTime() - this.refLocal.getTime();
	}

	function getTime(){
		var d = new Date();
		if(this.ref != undefined){
			return d.getTime() + this.diff;
		}else{
			return d.getTime();
		}
	}
	
	function getDateObject(){
		var d = new Date();
		if(this.ref != undefined){
			d.setTime(d.getTime() + this.diff);
		}
		return d;
	}

	function getObject(){
		var d = new Date();
		if(this.ref != undefined){
			d.setTime(d.getTime() + this.diff);
		}
		return FEDate.getObject(d);
	}
	
	function getCompleteObject(){
		var d = new Date();
		if(this.ref != undefined){
			d.setTime(d.getTime() + this.diff);
		}
		return FEDate.getCompleteObject(d);
	}	

	function toString(){
		var d = new Date();
		if(this.ref != undefined){
			d.setTime(d.getTime() + this.diff);
		}
		return d.toString();
	}
	
	function toFormat(format:String){
		return Lang.formatDateObject(this.getCompleteObject(),format);
	}
	
	function getCurrentFSign(){
		var t = this.getTime() / 1000;
		return {
			sign: Math.floor(((t - 345600) / 604800)  % 10), // ((t - 4day) / 1week) % sign_nb
			signb: Math.floor((t / 3600)  % 10), // (t / 1hour) % sign_nb
			signCompletion: ((t - 345600) / 604800)  % 1,
			signbCompletion: (t / 3600)  % 1
		}
	}
}
