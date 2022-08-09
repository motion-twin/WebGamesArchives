/*
$Id: TextField.class.as,v 1.6 2003/08/22 17:31:04  Exp $

Class: TextField
*/
TextField.prototype.onSetFocus = function(){
	this.myBox.activate();
};
ASSetPropFlags(TextField.prototype, "onSetFocus", 1);


TextField.prototype.addToTextFormat = function(o){
	var tf = this.getTextFormat()
	for(var element in o){
		tf[element] = o[element];
	}
	this.setTextFormat(tf);
	this.setNewTextFormat(tf);
};
ASSetPropFlags(TextField.prototype, "addToTextFormat", 1);


TextField.prototype.addProp = function(o){
	for(var element in o){
		this[element] = o[element];
	}
};
ASSetPropFlags(TextField.prototype, "addProp", 1);

TextField.prototype.getLineHeight = function(varname){
	return this.textHeight / (this.maxscroll + (this.bottomScroll - this.scroll));
};
ASSetPropFlags(TextField.prototype, "getLineHeight", 1);


TextField.prototype.getPos = function(varname){
	return -(this.scroll-1) * this.getLineHeight();
};
ASSetPropFlags(TextField.prototype, "getPos", 1);


TextField.prototype.setPos = function(varname,pos){
	this.scroll = Math.round(-pos / this.getLineHeight()) + 1;
};
ASSetPropFlags(TextField.prototype, "setPos", 1);
