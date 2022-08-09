package anim;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import haxe.Json;

/**
 * ...
 * @author 01101101
 */

class FrameManager
{
	
	static private var pairs:Hash<FramePair> = new Hash<FramePair>();
	static private var point:Point = new Point();
	
	/**
	 * @param	_id				spritesheet id
	 * @param	_sheet			bitmap data
	 * @param	_jsonString		json data
	 */
	static public function store (id:String, sheet:BitmapData, js:String) :Void {
		var d:Dynamic = Json.parse(js);
		if (d._frames == null)	return;
		var frames:Array<Frame> = new Array<Frame>();
		var a:Array<Dynamic> = cast(d._frames, Array<Dynamic>);
		if (a.length <= 0)	return;
		var frame:Frame;
		for (f in a) {
			frame = new Frame();
			frame.fromObject(f);
			frame.spritesheet = sheet;
			frames.push(frame);
		}
		var pair:FramePair = { sheet:sheet, frames:frames };
		pairs.set(id, pair);
	}
	
	static public function getFrameInfo (name:String, ?id:String) :Frame {
		if (id != null) {
			// If specified ID doesn't exist
			if (!pairs.exists(id)) {
				return null;
			} else {
				// Look all frames for the specified name
				for (f in pairs.get(id).frames) {
					if (f.name == name) {
						return f;
					}
				}
			}
		}
		// If not found or _id not specified
		for (p in pairs) {
			for (f in p.frames) {
				if (f.name == name) {
					return f;
				}
			}
		}
		return null;
	}
	
	/**
	 * Returns a new BitmapData containing the specified frame.
	 * @param	name
	 * @param	?id
	 * @return
	 */
	static public function getFrame (name:String, ?id:String) :BitmapData {
		var bd:BitmapData = null;
		if (id != null) {
			// If specified ID doesn't exist
			if (!pairs.exists(id)) {
				//trace("frame not found");
				return null;
			} else {
				// Look all frames for the specified name
				for (f in pairs.get(id).frames) {
					if (f.name == name) {
						bd = new BitmapData(f.width, f.height, true, 0x00FF00FF);
						bd.copyPixels(pairs.get(id).sheet, new Rectangle(f.x, f.y, f.width, f.height), point);
						return bd;
					}
				}
			}
		}
		return null;
	}
	
	/**
	 * Copies pixels from the specified frame to an existing BitmapData (beware of size changes which could induce cropping)
	 * @param	bd
	 * @param	name
	 * @param	?id
	 * @return
	 */
	static public function getFrameOpt (bd:BitmapData, name:String, ?id:String) :Bool {
		if (id != null) {
			// If specified ID doesn't exist
			if (!pairs.exists(id)) {
				//trace("frame not found");
				return false;
			} else {
				// Look all frames for the specified name
				for (f in pairs.get(id).frames) {
					if (f.name == name) {
						bd.copyPixels(pairs.get(id).sheet, new Rectangle(f.x, f.y, bd.width, bd.height), point);
						return true;
					}
				}
				return false;
			}
		}
		return false;
	}
	
	/**
	 * 
	 * @param	bd		target bitmap data
	 * @param	name	frame name
	 * @param	?id		spritesheet id
	 * @param	?p		destination point
	 * @param	?center	whether or not to center the frame on destination point
	 * @param	?flip	whether or not to flip the frame
	 */
	
	static var r : Rectangle = new Rectangle();
	static var m : Matrix =  new Matrix();
	
	static public function copyFrame (bd:BitmapData, name:String, ?id:String, ?p:Point = null, ?center:Bool = false, ?flip:Bool = false, ?blend:flash.display.BlendMode = null) :Void {
		if (id != null) {
			// If specified ID doesn't exist
			if (!pairs.exists(id)) {
				return;
			} else {
				// Look all frames for the specified name
				for (f in pairs.get(id).frames) {
					if (f.name == name) {
						if (p == null)	p = point;
						// Center
						if (center) {
							p.x -= f.width / 2;
							p.y -= f.height / 2;
						}
						// Flip
						if (!flip && blend == null) {
							//trace("copyPixels " + flip + " / " + blend);
							r.setTo(f.x, f.y, f.width, f.height);
							bd.copyPixels(pairs.get(id).sheet,r, p);
						}
						else {
							//trace("draw " + flip + " / " + blend);
							var tbd:BitmapData = new BitmapData(f.width, f.height, true, 0x00FF00FF);
							r.setTo(f.x, f.y, f.width, f.height);
							tbd.copyPixels(pairs.get(id).sheet, r, point);
							m.identity();
							if (flip)	m.scale( -1, 1);
							m.translate(p.x, p.y);
							if (blend == null)	blend = flash.display.BlendMode.NORMAL;
							bd.draw(tbd, m, null, blend);
						}
						return;
					}
				}
			}
		}
	}
	
}
typedef FM = FrameManager;
typedef FramePair = {
	var sheet:BitmapData;
	var frames:Array<Frame>;
}