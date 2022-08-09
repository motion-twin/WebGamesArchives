import mb2.Const;
import mb2.Manager;

class mb2.Loader {

	static var data_stream = null;
	static var last_data = null;
	
	var load_mc;
	var cur_data;
	var loaded;
	var ready;

	function Loader( mc : MovieClip, data ) {
		if( data_stream == null )
			data_stream = new LoadVars();
		
		var me = this;
		data_stream.onLoad = function(flag) {
			me.onLoad(flag);
		};
		cur_data = data;
		if( data_stream[data] == null ) {
			var file = Manager.client.getFileInfos(data).name;
			data_stream.load(file);
			loaded = false;
		} else {
			data_stream.ddata = data_stream[data];
			loaded = true;
		}
		ready = false;

		load_mc = Std.attachMC(mc,"loading",0);
		load_mc.loadReady = function() { me.ready = true };
		load_mc.loadFinish = function() { me.finish(); }
	}

	function main() {
		var btot = data_stream.getBytesTotal();
		var bload= data_stream.getBytesLoaded();
		var progress;
		if( btot < 10 || bload < 10 )
			progress = 0+" %";
		else {
			if( loaded && ready ) {
				ready = false;
				load_mc.play();
			}
			progress = Math.min(100,int(bload * 100/btot))+" %";
		}
		load_mc.progress = progress;
	}

	function setText(txt) {
		loaded = false;
		load_mc.gotoAndPlay(1);
		load_mc.chargement.txt = txt;		
	}

	function onLoad(flag) {
		if( !flag )
			Manager.error();
		else
			loaded = true;
	}

	function finish() {
		load_mc.stop();
		load_mc.progress = "";
		last_data = data_stream.ddata;
		data_stream[cur_data] = last_data;
		Manager.loadDone();
	}

	function destroy() {
		load_mc.removeMovieClip();
	}
}
