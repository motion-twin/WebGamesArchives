package ;

/**
 * ...
 * @author de
 */

#if flash
import haxe.CallStack;
import haxe.Unserializer;
import IsoProtocol;
import org.ascrypt.ARC4;
import org.ascrypt.encoding.UTF8;
import Protocol;
import haxe.remoting.ExternalConnection;
import CrossConsts;
using Ex;
#end

@:native("Js2Swf_ISO_MODULE")
@:keep
class Js2Swf_ISO_MODULE
{
	public function new()
	{
		
	}
	
	public function _echo()
	{
		//Debug.MSG("js2swf ISO_MODULE echo");
	}
	

	public function _event(str:String) {
		#if flash
		try{
		var  e = Unserializer.run( str );
		if ( e != null) {
			Main.onEvent(e);
		}
		}catch (d:Dynamic) {
			Debug.MSG("err deserializing : " + d+" >"+str);
		}
		#end
	}
	
	public function _forceData( str:String)
	{
		#if flash
		var i = 0;
		haxe.Timer.delay(
		function()
		{
			try
			{
				Profiler.min_limit = 0;
				Profiler.get().enable = true;
				
				//Profiler.get().begin("deser");
				i++;
				//Profiler.get().begin("rev");
				var strDecRev =   StringEx.reverse(str);
				//Profiler.get().end("rev");
				
				//Profiler.get().begin("dec");
				var strDecInput = StringTools.urlDecode( strDecRev );
				//Profiler.get().end("dec");
				i++;
				//Profiler.get().begin("rawDeser");
				i++;
				var ser : _RoomsClientData = new tools.Codec().unserialize( strDecInput );
				i++;
				//Profiler.get().end("rawDeser");
				i++;
				
				//Profiler.get().end("deser");
				
				//if ( Utils.Bit_is(ser.flags, 1 << CrossFlags.IsA.index()))
				//	trace( Profiler.get().dump() );
				
				//Profiler.get().clean();
				haxe.Timer.delay( function()
				{
					i++;
					var t = Date.now().getTime();
					#if !debug
					try
					#end
					{
						i++;
						//Profiler.get().begin("setcall");
						Main.resetServerData( ser );
						//Profiler.get().end("setcall");
						i++;
					}
					#if !debug
					catch (d:Dynamic)
					{
						
						var msg = "ALARM ALARM "
						+ "<br/> state: " + Main.state
						+ "<br/> info:" + Main.getInfos()
						+ "<br/> delay: " + ( Date.now().getTime() - t)
						+ "<br/> stack:" + Std.string(haxe.CallStack.exceptionStack())
						+ "<br/> err: "+ d + " "+ haxe.Serializer.run( d );
						ServerProcess.sendError(msg);
						throw d;
					}
					#end
					//trace(Date.now().getTime()-t);
				},1
				);
			}
			catch(d:Dynamic)
			{
				if ( d == "FCHK") {
					
				}
				else if ( d == "Error #1502") {
					
				}
				else{
					var msg = "force data error >" + d + "<> " + str.length;
					msg += "<br/> i:" + i;
					msg += "<br/> hr:"+str;
					msg += "<br/> es:"+haxe.CallStack.exceptionStack().join(",")+" // ";
					msg += "<br/> cs:"+haxe.CallStack.callStack().join(",") +" // ";
					var s = StringTools.urlEncode( msg );
					Debug.MSG( msg);
					ServerProcess.sendError(msg);
				}
			}
			Debug.MSG("proxy bridge done!");
		}
		,1);
		
		#end
	}
	
	public function _cancelSelection()
	{
		#if flash
			Select.cancelAllSelection();
		#end
	}
	
	public function _setBaseLine( v:  Int )
	{
		#if flash
			Main.gui.baseLine = v;
			Main.gui.update();
		#end
	}
	
	
	
	public function _gatherUp( a:Int,b:Int,r:Int )
	{
		#if flash
			var np0 = Main.allHumanNPC.find( function(npc) return npc.hid.index() == a );
			var np1 = Main.allHumanNPC.find( function(npc) return npc.hid.index() == b );
			
			var gr = np0.getGrid();
			var rr = gr.getRid().index();
			if ( rr == r )
			{
				var p = gr.randomFree();
				
				if ( p == null)
					p = gr.get(0, 0);
					
				np0.setPos( p.getGridPos().x, p.getGridPos().y);
				np1.circa( np0.getTile() );
				np1.lookBusy();
			}
		#end
	}
}