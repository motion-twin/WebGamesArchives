/*
$Id: FPString.as,v 1.3 2003/11/28 05:19:03  Exp $

Class: FPString
	Frutiparc specific usefull functions about strings
*/
class FPString{
	static function toDisplayMail(str:String,f:String):String{
		var arr:Array = FEString.mailParse(str);
		var ret:Array = new Array();
		for(var i=0;i<arr.length;i++){
			var obj = arr[i];

			if(FEString.endsWith(obj.m,"@frutiparc.com")){
				if(f == "text"){
					ret.push(obj.m.substr(0,obj.m.length - 14));
				}else{
					ret.push( Lang.fv("mail.mail_name",{n: obj.m.substr(0,obj.m.length - 14),m: obj.m}) );
				}
			}else if(obj.n != undefined && obj.n.length > 0){
				if(f == "text"){
					ret.push(obj.n);
				}else{
					ret.push( Lang.fv("mail.mail_name", obj ) );
				}
			}else{
				if(f == "text"){
					ret.push(obj.m);
				}else{
					ret.push( Lang.fv("mail.mail_only", obj ) );
				}
			}
		}
		return ret.join(", ");
	}
}
