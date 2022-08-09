class CustomLoader extends mt.bumdum9.Bouille {
	var hideInventory : Bool;
	var rescale : Bool;
	public function new(hideInventory=false, rescale=false){
		this.hideInventory = hideInventory;
		this.rescale= rescale;
		this.onLoadFinish = callback(this.finalize);
		super();
	}
	function finalize(){
		if (hideInventory && base != null && untyped base.mc_inventory != null)
			untyped base.removeChild(base.mc_inventory);
		if (rescale && base != null){
			var w = flash.Lib.current.stage.stageWidth;
			var h = flash.Lib.current.stage.stageHeight;
			parent.removeChild(this);
			var b = new flash.display.BitmapData(Math.ceil(base.width), Math.ceil(base.height));
			b.draw(this);
			var bmp = new flash.display.Bitmap(b);
			bmp.smoothing = true;
			bmp.scaleX = (w / this.base.width) * this.scaleX;
			bmp.scaleY = (h / this.base.height) * this.scaleY;
			bmp.x = this.x;
			flash.Lib.current.addChild(bmp);
		}
	}
}

class Bouilleur {
	public static function main() : Void {
		var root = flash.Lib.current;
		var url  : String = Reflect.field(root.loaderInfo.parameters, "url");
		var skin : String = Reflect.field(root.loaderInfo.parameters, "skin");
		var swf  : String = Reflect.field(root.loaderInfo.parameters, "data");
		var cars = decodeBytesFace(skin);
		if (cars == null)
			return;
		var face = null;
		var version = cars.shift();
		try {
			face = new CustomLoader(
				Reflect.field(root.loaderInfo.parameters, "hidinv") != null,
				Reflect.field(root.loaderInfo.parameters, "rescale") != null
			);
			face.load(swf);
			face.set(cars);
			if (Reflect.field(root.loaderInfo.parameters, "mirror") == "1"){
				face.scaleX = -1;
				face.x = root.stage.stageWidth;
			}
			root.addChild(face);
			if (url != null){
				flash.ui.Mouse.cursor = flash.ui.MouseCursor.BUTTON;
				root.addEventListener(flash.events.MouseEvent.CLICK, function(_){
					flash.Lib.getURL(new flash.net.URLRequest(url), "_self");
				});
			}
		}
		catch (e:Dynamic){
		}
	}

	static function decodeBytesFace(skin:String){
		if (skin == null)
			return null;
		var bytes = tools.Base64.decodeBytes(skin);
		var n = [];
		for (i in 0...bytes.length){
			n.push(bytes.get(i));
		}
		var chkk = n.pop();
		var sum = 0;
		for (i in 0...n.length){
			n[i] = n[i] ^ chkk;
			sum += n[i];
		}
		var chk = chkk ^ (n[n.length-1] & n[1] ^ (n[2] & n[0]));
		if (chk != sum & 0xFF)
			return null;
		return n;
	}
}