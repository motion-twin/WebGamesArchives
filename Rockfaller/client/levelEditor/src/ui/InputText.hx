package ui;

import h2d.Bitmap;

/**
 * ...
 * @author Tipyx
 */

class InputText extends h2d.Sprite
{
	var bgInput				: Bitmap;
	var textInput			: mt.device.TextField;
	
	public var wid			: Int;
	public var hei			: Int;
	
	public var value		: String;
	
	var xInput				: Int;
	var yInput				: Int;
	
	public function new(wid:Int, hei:Int, ?color:Int = 0xFF000000) {
		super();
		
		this.hei = hei;
		this.wid = wid;
		
		xInput = 0;
		yInput = 0;
		
		value = "";
		
		show();
		
		bgInput = new h2d.Bitmap(h2d.Tile.fromColor(color, wid, hei));
		this.addChild(bgInput);
	}
	
	public function getText():String {
		return textInput.text;
	}
	
	public function setText(str:String) {
		textInput.text = value = str;
	}
	
	public function setPosInput(newX:Int, newY:Int) {
		if (textInput != null) {
			textInput.x = xInput = newX;
			textInput.y = yInput = newY;			
		}
	}
	
	public function hide() {
		if (textInput != null)
			textInput.destroy();
		textInput = null;
		
		this.visible = false;
	}
	
	public function show() {
		if (textInput == null)
			textInput = new mt.device.TextField();
		textInput.textSize = 20;
		textInput.width = wid;
		textInput.height = hei;
		textInput.type = mt.device.TextField.TextFieldType.TF_Number;
		textInput.text = value;
		textInput.onTextChanged = function (str) {
			value = str;
		};
		setPosInput(xInput, yInput);
		
		this.visible = true;
	}
	
	public function destroy() {
		if (textInput != null)
			textInput.destroy();
		textInput = null;
		
		bgInput.dispose();
		bgInput = null;
	}
}