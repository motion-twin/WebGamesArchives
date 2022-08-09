package mt;

private class CdInst {
	public var k : String;
	public var frames : Float;
	public var initial : Float;
	public var cb : Null<Void -> Void>;

	public function new(k,f) {
		this.k = k;
		this.frames = f;
		initial = f;
	}
}

class Cooldown {
	//public var cdList				: Array<{k:String, v:Float, initial:Float, cb:Null<Void->Void>}>; // HACK
	public var cdList				: Array<CdInst>;
	var fastCheck					: Map<String, Bool>;
	var baseFps						: Float;

	public function new(fps:Float) {
		reset();
		baseFps = fps;
	}

	public function destroy() {
		cdList = null;
		fastCheck = null;
	}

	public inline function reset() {
		cdList = new Array();
		fastCheck = new Map();
	}


	public inline function getS(k) : Float   return getF(k)/baseFps;
	public inline function getMs(k) : Float  return getS(k)/1000;

	public inline function getF(k) : Float {
		var cd = getCdObject(k);
		return cd == null ? 0 : cd.frames;
	}

	public inline function getInitialValueF(k) : Float {
		var cd = getCdObject(k);
		return cd == null ? 0 : cd.initial;
	}

	public function getRatio(k:String) { // 1->0
		var max = getInitialValueF(k);
		return max<=0 ? 0 : getF(k)/max;
	}

	//public inline function getFloat(k) : Float {
		//var cd = getCdObject(k);
		//return cd == null ? 0 : cd.frames;
	//}

	// only called once when cooldown reaches 0, then CB destroyed
	public inline function onComplete(k, onceCB:Void->Void) {
		var cd = getCdObject(k);
		if( cd == null )
			throw "cannot bind onComplete("+k+"): cooldown "+k+" isn't running";
		cd.cb = onceCB;
	}

	function getCdObject(k:String) : Null<CdInst> {
		for (cd in cdList)
			if( cd.k == k )
				return cd;
		return null;
	}


	inline function msToFrames(ms:Float) return ms / (1000/baseFps);
	inline function secToFrames(s:Float) return msToFrames(s*1000);

	public inline function setMs(k, milliSeconds:Float, ?allowLower, ?onComplete:Void->Void) setF(k, msToFrames(milliSeconds), allowLower, onComplete);
	public inline function setS(k, seconds:Float, ?allowLower, ?onComplete:Void->Void) setF(k, secToFrames(seconds), allowLower, onComplete);

	public inline function setF(k:String, frames:Float, ?allowLower=true, ?onComplete:Void->Void) {
		frames = Std.int(frames*1000)/1000; // neko bug: fix precision variations between platforms
		var cur = getCdObject(k);
		if( cur!=null && frames<cur.frames && !allowLower )
			return;

		if ( frames <= 0 ) {
			if( cur != null )
				unsetObject(cur);
		}
		else {
			fastCheck.set(k, true);
			if( cur != null )
				cur.frames = frames;
			else
				cdList.push( new CdInst(k,frames) );
				//cdList.push({k:k, v:v, initial:v, cb:null});
		}

		if( onComplete!=null )
			if( frames<=0 )
				onComplete();
			else
				this.onComplete(k, onComplete);
	}

	public inline function unset(k:String) {
		for (cd in cdList)
			if ( cd.k == k ) {
				unsetObject(cd);
				break;
			}
	}

	inline function unsetObject(cd:CdInst) {
		cdList.remove(cd);
		cd.frames = 0;
		cd.cb = null;
		fastCheck.set(cd.k, false);
	}

	// supprime tous les cooldowns dont la clé contient "search"
	public inline function unsetAll(search:String) {
		for ( cd in cdList ) {
			if( cd.k.indexOf(search) >= 0 )
				unsetObject(cd);
		}
	}

	public inline function has(k) {
		return fastCheck.get(k)==true;
	}

	public inline function hasSetF(k, frames:Float) {
		if ( has(k) )
			return true;
		else {
			setF(k, frames);
			return false;
		}
	}

	public inline function hasSetS(k, seconds:Float)   return hasSetF(k, secToFrames(seconds));
	public inline function hasSetMs(k, ms:Float)       return hasSetF(k, msToFrames(ms));

	public function update(dt:Float) {
		var i = 0;
		while( i<cdList.length ) {
			var cd = cdList[i];
			cd.frames = Std.int( (cd.frames-dt)*1000 )/1000; // Neko vs Flash precision bug
			if ( cd.frames<=0 ) {
				var cb = cd.cb;
				unsetObject(cd);
				if( cb != null ) cb();
			}
			else
				i++;
		}
	}
}
