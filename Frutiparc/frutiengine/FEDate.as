/*
$Id: FEDate.as,v 1.7 2004/03/18 16:22:35  Exp $

Class: FEDate
*/
class FEDate{
	/*
	Function: createFromString
		Define a date object from a string YYYY-MM-DD HH:II:SS
	
	Arguments:
		d - Date object
		str - String in format YYYY-MM-DD HH:II:SS
	*/
	static function newFromString(str:String){
		var y = Number(str.substr(0,4));
		var m = Number(str.substr(5,2));
		var d = Number(str.substr(8,2));

		var h = Number(str.substr(11,2));
		var i = Number(str.substr(14,2));
		var s = Number(str.substr(17,2));

		var dObj = new Date();
		dObj.setFullYear(y,m-1,d);
		if(h != undefined && !isNaN(h)) dObj.setHours(h);
		if(i != undefined && !isNaN(i)) dObj.setMinutes(i);
		if(s != undefined && !isNaN(s)) dObj.setSeconds(s);
		
		return dObj;
	}
	
	static function newFromTime(t:Number){
		var dObj = new Date();
		dObj.setTime(t);
		return dObj;
	}
	
	/*
	Function: toObject
		Get some properties from a date object
	
	Arguments:
		d - Date object
		
	Returns:
		An object containing properties :
			y (full year, 2000) ; 
			m (month, 01->12) ; 
			d (date, 01->31) ; 
			h (hour, 00->23) ; 
			i (minutes, 00->59) ; 
			s (seconds, 00->59)
	*/
	static function getObject(d:Date):Object{
		var obj = new Object();

		obj.y = FENumber.toStringL(d.getFullYear(),4);
		obj.m = FENumber.toStringL(d.getMonth()+1,2);
		obj.d = FENumber.toStringL(d.getDate(),2);

		obj.h = FENumber.toStringL(d.getHours(),2);
		obj.i = FENumber.toStringL(d.getMinutes(),2);
		obj.s = FENumber.toStringL(d.getSeconds(),2);

		return obj;
	}
	
/*
y: ann�e courte (99, 03)
Y: ann�e (1999, 2003)
a: jour de la semaine (mercredi)
A: jour de la semaine cours (mer)
d: date du mois (1, 12, 25)
D: date du mois avec z�ro (01, 12, 25)
m: mois (septembre)
M: mois court (sept)
n: num�ro du mois (9)
N: num�ro du mois avec z�ro (09)
h: heure (1, 10, 24)
H: heure avec z�ro (01, 10, 24)
i: minutes (1, 59)
I: minutes avec z�ro (01, 59)
s: secondes (1, 59)
S: secondes (01, 59)
*/
	/*
	Function: toObject
		Get many properties from a date object
	
	Arguments:
		d - Date object
		
	Returns:
		An object containing properties :
			y: ann�e courte (99, 03)
			Y: ann�e (1999, 2003)
		*	a: jour de la semaine (mercredi)
		*	A: jour de la semaine cours (mer)
			b: jour de la semaine (1 � 7)
			d: date du mois (1, 12, 25)
			D: date du mois avec z�ro (01, 12, 25)
		*	m: mois (septembre)
		*	M: mois court (sept)
			n: num�ro du mois (9)
			N: num�ro du mois avec z�ro (09)
			h: heure (1, 10, 24)
			H: heure avec z�ro (01, 10, 24)
			i: minutes (1, 59)
			I: minutes avec z�ro (01, 59)
			s: secondes (1, 59)
			S: secondes (01, 59)
	*/
	static function getCompleteObject(d:Date):Object{
		var obj = new Object();
		
		obj.y = FENumber.toStringL(d.getYear()%100,2);
		obj.Y = FENumber.toStringL(d.getFullYear(),4);
		
			var b = d.getDay();
			if(b == 0) b = 7;
		obj.b = FENumber.toStringL(b,1);
		obj.d = FENumber.toStringL(d.getDate(),1);
		obj.D = FENumber.toStringL(d.getDate(),2);
		
		obj.n = FENumber.toStringL(d.getMonth()+1,1);
		obj.N = FENumber.toStringL(d.getMonth()+1,2);
		obj.h = FENumber.toStringL(d.getHours(),1);
		obj.H = FENumber.toStringL(d.getHours(),2);
		obj.i = FENumber.toStringL(d.getMinutes(),1);
		obj.I = FENumber.toStringL(d.getMinutes(),2);
		obj.s = FENumber.toStringL(d.getSeconds(),1);
		obj.S = FENumber.toStringL(d.getSeconds(),2);
	
		return obj;
	}
}
