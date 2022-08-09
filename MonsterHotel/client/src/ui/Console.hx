package ui;

import mt.MLib;
import mt.flash.Key;
import com.Protocol;
import h2d.Console;
import mt.deepnight.Lib;

class Console extends h2d.Console {
	var unlocked		: Bool = false;
	var memCounter		: Bool = false;

	public function new() {
		super(Assets.fontTiny, Main.ME.scene);

		h2d.Console.HIDE_LOG_TIMEOUT = 8;
		useMouseWheel = false;

		#if( debug || !prod || dprot )
		unlocked = true;
		#end

		mt.deepnight.Lib.redirectTracesToH2dConsole(this);

		var col = 0x859AD3;

		addCommand("unlock", "Unlock admin commands", [{ name:"code", t:AInt, opt:false }], function(code:Int) {
			if( code==1866 ) {
				log("Admin commands unlocked", col);
				unlocked = true;
			}
		});
		addAlias("u", "unlock");

		#if connected
		addCommand("dprot", "Toggle protocol debug mode", [], function() {
			if( unlocked && Game.ME!=null ) {
				Game.ME.debugProtocol = !Game.ME.debugProtocol;
				log("Protocol debug = "+Game.ME.debugProtocol, col);
			}
		});
		addAlias("dp", "dprot");

		addCommand("pending", "Show pending commands", [], function() {
			if( unlocked && Game.ME!=null ) {
				log("Pending commands ("+Game.ME.pendingCmds.length+"):");
				for(c in Game.ME.pendingCmds)
					log(c.msgId+" ver="+c.c+" c="+c.c, col);
			}
		});
		addAlias("pc", "pending");

		#if dprot
		addCommand("rem", "Remove pending command", [{name:"idx", t:AInt, opt:true}], function(?idx=0) {
			if( unlocked && Game.ME!=null ) {
				log("Removed #"+idx+".", 0xFF0000);
				Game.ME.pendingCmds.splice(idx,1);
			}
		});

		addCommand("dup", "Duplicate pending command", [{name:"idx", t:AInt, opt:false}], function(idx:Int) {
			if( unlocked && Game.ME!=null ) {
				if( idx>=Game.ME.pendingCmds.length )
					log("Index too high!", 0xFF0000);
				else {
					log("Duplicated #"+idx+".", 0xFF0000);
					var c = Game.ME.pendingCmds[idx];
					Game.ME.pendingCmds.insert(idx, {
						v		: c.v,
						msgId	: c.msgId,
						cid		: c.cid,
						c		: c.c,//
					});
					var base = Game.ME.pendingCmds[0].msgId;
					Game.ME.renumberPendingCommands(base);
				}
			}
		});
		#end

		addCommand("req", "Send debug request", [{ name:"p0", t:AString, opt:true },{ name:"p1", t:AString, opt:true }], function(p0:String, p1:String) {
			if( unlocked && Game.ME!=null ) {
				log("Sending request...");
				log("---------------", col);
				Game.ME.sendMiscCommand( MC_DebugCmd(p0,p1) );
				if( StringTools.trim(p0)=="t" ) {
					log("local.now="+Lib.prettyTime(Date.now().getTime()), col);
					log("local.serverTime="+Lib.prettyTime(Game.ME.serverTime), col);
				}
			}
		});
		addAlias("r", "req");
		#end

		addCommand("deffects", "Toggle effects debug mode", [], function() {
			if( unlocked && Game.ME!=null ) {
				Game.ME.debugEffects = !Game.ME.debugEffects;
				log("Effects debug = "+Game.ME.debugEffects, col);
			}
		});
		addAlias("de", "deffects");

		addCommand("quests", "Show quests", [], function() {
			if( unlocked && Game.ME!=null ) {
				log("Quests ("+Game.ME.shotel.curQuests.length+"):");
				for(q in Game.ME.shotel.curQuests)
					log("  "+q.id+" => "+q, 0xFFFF00);

				var t = Game.ME.shotel.getTask(InternalQuestRegen);
				if( t!=null )
					log("regen at "+Lib.prettyTime(t.end));
				else
					log("no regen", 0xFF0000);
			}
		});
		addAlias("q", "quests");

		addCommand("dprofiler", "Toggle DrawProfiler", [], function() {
			dpStart = 0;
			if( dpOld==null )
				showDrawProfiler();
			else {
				dpOld.dispose();
				dpOld = null;
			}
		});
		addAlias("draw", "dprofiler");

		addCommand("cprofiler", "Toggle Cpu Profiler", [], function() {
			if( unlocked ) {
				var s = hxd.Profiler.dump(false).split("\n");
				for( s in s )
					log(s);
			}
		});
		addAlias("cpu", "cprofiler");

		addCommand("frameStats", "show gpu frame stats", [], function() {
			if ( unlocked ) {
				var st = hxd.DrawProfiler.frameStats();
				for( f in Reflect.fields(st))
					log( f+":"+Reflect.field(st,f));
			}
		});
		addAlias("gpu", "frameStats");

		addCommand("memoryCounter", "show frame memory usage", [], function() {
			if ( unlocked ) {
				memCounter = !memCounter;
				if( memCounter ) {
					var t = new h2d.Text( Assets.fontNormal, Main.ME.scene );
					Main.ME.createChildProcess(function(p) {
						var mem = Std.string( h3d.Engine.getCurrent().mem.usedMemory );
						if( t.text != mem)
							t.text = mem;

						if( !memCounter ) {
							p.destroy();
							t.dispose();
						}
					});

					t.x = 20;
					t.y = 20;
				}
			}
		});
		addAlias("mem", "memoryCounter");

		addCommand("clearLog", "clears the log ", [], function() {
			clearLog();
		});
		addAlias("cls", "clearLog");

		addCommand("gc", "Run GC", [], function() {
			if( unlocked )
				Main.ME.forceGC(true);
		});

		#if connected
		addCommand("stime", "Display server time", [], function() {
			if( unlocked && Game.ME!=null ) {
				var t = Assets.createText(24, 0xFFFFFF, "??", Main.ME.scene);
				Main.ME.createChildProcess( function(p) {
					if( Game.ME==null || Game.ME.destroyed ) {
						p.destroy();
						return;
					}
					if( Main.ME.itime%10==0 )
						t.text = Lib.prettyTime(Game.ME.serverTime);
				}, true);
			}
		});
		#end

		addCommand("batch", "Toggle spritebatches", [], function() {
			var v = !Game.ME.tilesSb.visible;
			Game.ME.monstersSb0.visible = v;
			Game.ME.monstersSb1.visible = v;
			Game.ME.monstersSb2.visible = v;
			Game.ME.tilesSb.visible = v;
			Game.ME.tilesFrontSb.visible = v;
			Game.ME.textSbTiny.visible = v;
			Game.ME.textSbHuge.visible = v;
			Game.ME.addSb.visible = v;
			Game.ME.roomsSb.visible = v;
			Game.ME.fx.addSb.visible = v;
			Game.ME.fx.normalSb.visible = v;
			//Game.ME.hotelRender.addSb.visible = v;
			//Game.ME.hotelRender.bgSb.visible = v;

			Main.ME.uiTilesSb.visible = v;
			Main.ME.uiTextSb.visible = v;
		});
		addAlias("b", "batch");

		#if debug
		addCommand("test", "test", [], function() {
		});
		addAlias("t", "test");

		addCommand("day", "--", [{ name:"n", t:AInt, opt:false }], function(n:Int) {
			Game.ME.runSolverCommand( DoCheat(CC_AddDay(n)) );
		});
		addCommand("dmg", "Damage room", [{ name:"x", t:AInt, opt:false },{ name:"y", t:AInt, opt:false }], function(x:Int, y:Int) {
			Game.ME.runSolverCommand( DoCheat(CC_Damage(x,y)) );
		});
		#end


		#if !connected
		addCommand("reset", "Reset local save", [], function() {
			if( Game.ME!=null ) {
				Game.ME.resetSave(true, true);
			}
		});
		#end
	}

	public function showDrawProfiler() {
		var scene = Main.ME.scene;
		hxd.DrawProfiler.TIP_FG_COL = 0x00FF32;
		hxd.DrawProfiler.TIP_SHADOW = false;
		hxd.DrawProfiler.BG = 0x7f000000;
		if ( dpOld != null) dpOld.remove();
		var t = hxd.DrawProfiler.analyse( scene );
		t = t.slice( dpStart );
		dpOld = hxd.DrawProfiler.makeGfx( t );
		scene.addChild( dpOld );
	}

	override public function log(text:Dynamic, ?color) {
		var lines = logTxt.htmlText.split("<br/>");
		while( lines.length>40 )
			lines.shift();
		logTxt.htmlText = lines.join("<br/>");

		super.log(text, color);
	}

	var dpStart = 0;
	var dpOld : h2d.Sprite  = null;
	public function update() {
		if( dpOld!=null ) {
			if ( Key.isToggled(Key.N) ) {
				showDrawProfiler();
				dpStart += 10;
			}
			if ( Key.isToggled(Key.R) ) {
				dpStart = 0;
				showDrawProfiler();
			}
		}
	}
}