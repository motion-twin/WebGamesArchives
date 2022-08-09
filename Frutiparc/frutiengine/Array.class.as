/*
$Id: Array.class.as,v 1.18 2004/04/23 15:20:57  Exp $

Class: Array
*/
/*
Function: indexOf
	Find the first occurence of an element in the array

Parameters:
	value - The element to find

Returns:
	Index of the first occurence found, -1 if nothing was found
*/
Array.prototype.indexOf = function(value){
	for(var i=0;i<this.length;i++){
		if(this[i] == value){
			return i;
		}
	}
	return -1;
};
ASSetPropFlags(Array.prototype, "indexOf", 1);

/*
Function: isIn
	Check if an element is in the array

Parameters:
	value - The element to find

Returns:
	True if the element was found

See Also:
	<Array.indexOf>
*/
Array.prototype.isIn = function(value){
	return (this.indexOf(value) >= 0);
};
ASSetPropFlags(Array.prototype, "isIn", 1);

/*
Function: pushUniq
	If this element is not in the array, push it

Parameters:
	value - The element to push

Returns:
	True if the element was pushed

See Also:
	<Array.isIn>
*/
Array.prototype.pushUniq = function(value){
	if(!this.isIn(value)){
		this.push(value);
		return true;
	}else{
		return false;
	}
};
ASSetPropFlags(Array.prototype, "pushUniq", 1);

/*
Function: pushAt
	Push an element in the array at a specifc index

Parameters:
	i - Index
	obj - The element to push
*/
Array.prototype.pushAt = function(i,value){
	this.splice(i,0,value);
};
ASSetPropFlags(Array.prototype, "pushAt", 1);

/*
Function: rm
	Remove the first occurence of an element in the array

Parameters:
	value - The element to remove

Returns:
	True if the element was found (and removed)

See Also:
	<Array.indexOf>
	<Array.isIn>
*/
Array.prototype.rm = function(value){
	var id = this.indexOf(value);
	if(id >= 0){
		this.splice(id,1);
		return true;
	}else{
		return false;
	}
};
ASSetPropFlags(Array.prototype, "rm", 1);

/*
Function: getMax
	Find the maximum value in the array

Returns:
	The maximum value, undefined if the array is empty

See Also:
	<Array.getMin>
*/
Array.prototype.getMax = function(){
	if(this.length < 1) return undefined;
	var t = this[0];
	for(var i=1;i<this.length;i++){
		if(this[i] > t){
			t = this[i];
		}
	}
	return t;
};
ASSetPropFlags(Array.prototype, "getMax", 1);

/*
Function: getMin
	Find the minimum value in the array

Returns:
	The minimum value, undefined if the array is empty

See Also:
	<Array.getMax>
*/
Array.prototype.getMin = function(){
	if(this.length < 1) return undefined;
	var t = this[0];
	for(var i=1;i<this.length;i++){
		if(this[i] < t){
			t = this[i];
		}
	}
	return t;
};
ASSetPropFlags(Array.prototype, "getMin", 1);

/*
Function: getPart
	Get a part of the array

Parameters:
	start - The index of the first element to get
	length - The maximum number of element to get 

Returns:
	An array containing some elements of the original array
*/
Array.prototype.getPart = function(start,length){
	var end = Math.min(this.length,start+length);
	var ret = new Array();
	for(var i=start;i<end;i++){
		ret.push(this[i]);
	}
	return ret;
};
ASSetPropFlags(Array.prototype, "getPart", 1);

Array.prototype.getPartAttrib = function(start,length,attrib){
	var end = Math.min(this.length,start+length);
	var ret = new Array();
	for(var i=start;i<end;i++){
		ret.push(this[i][attrib]);
	}
	return ret;
};
ASSetPropFlags(Array.prototype, "getPartAttrib", 1);


/*
Function: getIndexByProperty
	Return index of the first elem of the array having the property prop equals to value.

Parameters:
	prop - The property name
	value - The property value

Returns:
	The elem index, -1 if value is not found
	
See Also:
	<Array.getByProperty>
*/
Array.prototype.getIndexByProperty = function(prop,value){
	for(var i=0;i<this.length;i++){
		if(this[i][prop] == value){
			return i;
		}
	}
	return -1;
};
ASSetPropFlags(Array.prototype, "getIndexByProperty", 1);


/*
Function: getByProperty
	Return the first elem of the array having the property prop equals to value.

Parameters:
	prop - The property name
	value - The property value

Returns:
	The first elem found or undefined
	
See Also:
	<Array.getIndexByProperty>
*/
Array.prototype.getByProperty = function(prop,value){
	var i = this.getIndexByProperty(prop,value);
	if(i < 0) return undefined;
	return this[i];
};
ASSetPropFlags(Array.prototype, "getByProperty", 1);


Array.prototype.rmByProperty = function(prop,value){
	var i = this.getIndexByProperty(prop,value);
	if(i < 0) return false;
	

	this.splice(i,1);
	return true;
};
ASSetPropFlags(Array.prototype, "rmByProperty", 1);


Array.prototype.toString = function(l){
	if(l > 2) return ;
	var r = "[";
	for(var i=0;i<this.length;i++){
		if(i > 0)  r += ",\n";
		else r += "\n";
		if(typeof(this[i]) == "object"){
			r += FEString.repeat(" ",l+1)+this[i].toString(l+1);
		}else{
			r += FEString.repeat(" ",l+1)+this[i].toString(l+1);
		}
	}
	r += "\n"+FEString.repeat(" ",l)+"]";
	return r;
};
ASSetPropFlags(Array.prototype, "toString", 1);
