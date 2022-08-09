/*
$Id: AdvancedTextInput.as,v 1.3 2004/04/16 08:46:36  Exp $
*/
class AdvancedTextInput{

	static var cbSizeEqui = [18,16,14,12,10,8,6];
	
	static function normalizeSize(s:Number):Number{
		var t = Math.max(Math.min(Math.round(s/2),9),3);
		return t*2;
	}
	
	static function getCbSize(s){
		s = normalizeSize(s);
		for(var i=0;i<cbSizeEqui.length;i++){
			if(cbSizeEqui[i] == s) return i;
		}
	}
	
	// El�ments utilis�s (textfield, panel, etc...)
	
	var docPanel:cp.Document;
	
	var field:de.Field;
	var fieldPath:String;
	
	var btBold:String;
	var btItalic:String;
	var btUnderline:String;
	var cbColor:String;
	var cbSize:String;
	
	// Valeurs
	
	var tFormat;
	
	// variables internes diverses
	
	var lastSel:Object;
	
	// default (text selected), cursor (only a cursor in text), new (cursor at end)
	var selMode:String;
	var selStart:Number;
	var selEnd:Number;
	
	var txtLength:Number;
	
	var intervalId:Number;
	
	function AdvancedTextInput(o){
		for(var n in o){
			this[n] = o[n];
		}
		
		this.lastSel = {s: -1,e: -1};
		this.fieldPath = String(this.field.field);
		
		this.setDefaultNewTextFormat();

		
		this.init();
	}
	
	function init(){
		this.intervalId = setInterval(this,"interval",50);
		
		this.docPanel.addVariableListener(this.btBold,{obj: this,method: "onBold",uniq: "atiBold"});
		this.docPanel.addVariableListener(this.btItalic,{obj: this,method: "onItalic",uniq: "atiItalic"});
		this.docPanel.addVariableListener(this.btUnderline,{obj: this,method: "onUnderline",uniq: "atiUnderline"});
		this.docPanel.addVariableListener(this.cbSize,{obj: this,method: "onSize",uniq: "atiSize"});
		
		
	}
	
	function onKill(){
		clearInterval(this.intervalId);
		this.docPanel.removeVariableListener(this.btBold,"atiBold");
		this.docPanel.removeVariableListener(this.btItalic,"atiItalic");
		this.docPanel.removeVariableListener(this.btUnderline,"atiUnderline");
		this.docPanel.removeVariableListener(this.cbSize,"atiSize");
	}
	
	
	//// MISE A JOUR DU PANEL A PARTIR DU TEXTE
	
	private function getFromText(){
		if(Selection.getFocus() != this.fieldPath){
			return false;
		}
		
		var s = Selection.getBeginIndex();
		var e = Selection.getEndIndex();
		if(s == this.lastSel.s && e == this.lastSel.e) return false;
		this.lastSel = {s: s,e: e};
		
		this.txtLength = this.field.field.length;
		
		if(s != e){
			this.selMode = "default";
			this.selStart = s;
			this.selEnd = e;
		}else{
			if(s == this.txtLength){
				this.selMode = "new";
				this.selStart = s;
				this.selEnd = undefined;
			}else{
				this.selMode = "cursor";
				this.selStart = s;
				this.selEnd = s+1;
			}
		}
		
		var tFormat;
		if(this.selMode == "new"){
			tFormat = this.field.field.getNewTextFormat();
		}else{
			tFormat = this.field.field.getTextFormat(this.selStart,this.selEnd);
		}
		
		this.tFormat = tFormat;
		
		return true;
	}
	
	private function updatePanel(){
		this.docPanel.setVariable(this.btBold,this.tFormat.bold);
		this.docPanel.setVariable(this.btItalic,this.tFormat.italic);
		this.docPanel.setVariable(this.btUnderline,this.tFormat.underline);
		this.docPanel.setVariable(this.cbSize,getCbSize(this.tFormat.size));
	}
	
	// callbacks & listeners
	
	function interval(){
		if(this.getFromText()){
			this.updatePanel();
		}
	}
	
	//// MISE A JOUR DU TEXTE A PARTIR DU PANEL
	
	private function setBold(fl){
		this.tFormat.bold = fl;
		this.applyFormat();
	}
	
	private function setItalic(fl){
		this.tFormat.italic = fl;
		this.applyFormat();
	}
	
	private function setUnderline(fl){
		this.tFormat.underline = fl;
		this.applyFormat();
	}
	
	private function setSize(s){
		this.tFormat.size = s;
		this.applyFormat();
	}
	
	private function applyFormat(){
		//_global.debug("----- APPLY THIS FORMAT -----\nBold: "+this.tFormat.bold+"\nItalic: "+this.tFormat.italic+"\nUnderline: "+this.tFormat.underline+"\nSize: "+this.tFormat.size+"\n----- ***************** -----");
		if(this.selMode == "default"){
			this.field.field.setTextFormat(this.selStart,this.selEnd,this.tFormat);
			Selection.setFocus(this.field.field);
			Selection.setSelection(this.selStart,this.selEnd);
		}else{
			this.field.field.setNewTextFormat(this.tFormat);
		}
	}
	
	// callbacks & listeners
	function onBold(){
		var v = this.docPanel.getVariable(this.btBold);
		if(v == undefined) return;
		if(v != this.tFormat.bold){
			this.setBold(v);
		}
	}
	
	function onItalic(){
		var v = this.docPanel.getVariable(this.btItalic);
		if(v == undefined) return;
		if(v != this.tFormat.italic){
			this.setItalic(v);
		}
	}
	
	function onUnderline(){
		var v = this.docPanel.getVariable(this.btUnderline);
		if(v == undefined) return;
		if(v != this.tFormat.underline){
			this.setUnderline(v);
		}
	}
	
	function onSize(){
		var v = cbSizeEqui[this.docPanel.getVariable(this.cbSize)];
		if(v == undefined) return;
		if(v != this.tFormat.size){
			//_global.debug("onChange size : "+v+", was: "+this.tFormat.size);
			this.setSize(v);
		}
		
	}
	
	
	public function setDefaultNewTextFormat(){
		this.tFormat = new TextFormat();
		this.tFormat.font = "Verdana";
		this.tFormat.bold = false;
		this.tFormat.italic = false;
		this.tFormat.underline = false;
		this.tFormat.size = 12;
		this.tFormat.color = 0x335511;
		this.field.field.setNewTextFormat(this.tFormat);
	}
}