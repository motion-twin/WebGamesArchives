

class kaluga.SoundManager extends MovieClip{//}

	var flActive:Boolean;
	
	var channels:Array;
	var fade_from, fade_to, fade_start, fade_end, fade_pos, fade_len;

	function SoundManager( ) {
		channels = new Array();
		fade_pos = -1;
		flActive = true;
	}	

	function destroy() {
		var i;
		for(i=0;i<channels.length;i++) {
			var c = channels[i];
			for(var s in c.sounds)
				c.sounds[s].stop();
			c.mc.removeMovieClip();
		}
		channels = [];
	}

	private function getChannel( chan : Number ) {
		var c = channels[chan];
		if( c == undefined ) {
			var mc = this.createEmptyMovieClip("chan"+chan,chan);
			c = { mc : mc, sounds : [], vol : 100, vol_ctrl : new Sound(mc), nb : chan, enabled : true };
			channels[chan] = c;
		}
		return c;
	}

	private function getSound( name : String, chan : Number ) : Sound {
		var id : Number = Std.cast(name);
		var c = getChannel(chan);
		var s = c.sounds[id];
		function completed() {
			Std.cast(this).playing = false;
		};
		if( s == undefined ) {
			s = new Sound(c.mc);
			s.attachSound(name);
			s.onSoundComplete = completed;
			Std.cast(s).playing = false;
			c.sounds[id] = s;
		}
		return s;
	}

	function playSound( name : String, chan : Number ) {
		var s = getSound(name,chan);
		s.start(0,1);
		Std.cast(s).playing = true;
		this.enable(chan,this.flActive)
	}

	function play( name : String ) {
		playSound(name,0);
	}

	function loop( name : String, chan : Number ) {
		var s = getSound(name,chan);
		s.start(0,0xFFFF);
		Std.cast(s).playing = true;
		this.enable(chan,this.flActive)
	}

	function stopSound( name : String, chan : Number ) {
		var s = getSound(name,chan);
		s.stop();
		Std.cast(s).playing = false;
	}

	function fade( chan_from : Number, chan_to : Number, length : Number ) {
		if( fade_pos != -1 ) {
			setVolume(fade_to.nb,fade_end);
			this.stop(fade_from.nb);
			setVolume(fade_from.nb,fade_end);			
		}
		fade_from = getChannel(chan_from);
		fade_to = getChannel(chan_to);
		fade_start = fade_to.vol;
		fade_end = fade_from.vol;
		fade_pos = 0;
		fade_len = length;
	}

	function main() {
		if( fade_pos != -1 ) {
			var last_fade = false;
			fade_pos += Std.deltaT / fade_len;
			if( fade_pos >= 1 ) {
				fade_pos = 1;
				last_fade = true;
			}
			var volume = (fade_end - fade_start) * fade_pos + fade_start;
			setVolume(fade_to.nb,volume);
			setVolume(fade_from.nb,fade_end-volume);
			if( last_fade ) {
				fade_pos = -1;
				this.stop(fade_from.nb);
				setVolume(fade_from.nb,fade_end);
			}
		}
	}

	function enable( chan : Number, flag : Boolean ) {
		//_root.test+="[SoundManager] enable("+chan+","+flag+")\n"
		var c = getChannel(chan);
		c.enabled = flag;
		if( c.enabled )
			c.vol_ctrl.setVolume(c.vol);
		else
			c.vol_ctrl.setVolume(0);
	}

	function stop( chan : Number ) {
		var c = getChannel(chan);
		for( var s in c.sounds ) {
			c.sounds[s].stop();
			Std.cast(c.sounds[s]).playing = false;
		}
	}

	function isPlaying( name : String, chan : Number ) {
		var s = getSound(name,chan);
		return Std.cast(s).playing;
	}

	function setVolume( chan : Number, volume : Number ) {
		var c = getChannel(chan);
		c.vol = volume;
		if( c.enabled )
			c.vol_ctrl.setVolume(c.vol);		
	}

	function setActive(flag){
		//_root.test+="setActive("+flag+")\n"
		this.flActive = flag;
		for(var i=0; i<channels.length; i++ ){
			var o  = channels[i]
			if(o!=undefined)this.enable(o.nb,this.flActive)
		}
	}
	
//{
}