package tools;

class Namer {
	var data : Hash<Array<String>>;

	public function new( content:String ){
		data = new Hash();
		var currentSection = null;
		for (line in content.split("\n")){
			var comment = line.indexOf("#");
			if (comment != -1)
				line = line.substr(0,comment-1);
			if (StringTools.trim(line).length == 0)
				continue;
			if (~/^\s*?#/.match(line))
				continue;
			if (~/^\{[\-_a-zA-Z0-9]*?\}/.match(line)){
				currentSection = new Array();
				data.set(StringTools.trim(line), currentSection);
			}
			else if (currentSection == null){
				throw "Expecting section '"+line+"'";
			}
			else {
				currentSection.push(StringTools.trim(line));
			}
		}
		checkIntegrity();
	}

	function checkIntegrity(){
		for (section in data){
			for (line in section){
				var end = 0;
				do {
					var start = line.indexOf("{", end);
					if (start == -1)
						break;
					end = line.indexOf("}", start);
					if (end == -1)
						throw "Malformed line "+line;
					var sect = line.substr(start, end+1-start);
					sect = StringTools.replace(sect, "{UF:", "{");
					if (!~/(::[a-zA-Z0-9-]+::)/.match(sect) && !data.exists(sect))
						throw "Unknown section "+sect+" in line "+line+" (char "+start+"..."+end+")";
				}
				while (end != -1);
			}
		}
	}

	public function name( ?randomizer ) : String {
		return random("{}", randomizer);
	}

	public function random( sectionName:String, ?randomizer ) : String {
		var section = data.get(sectionName);
		if (section == null)
			throw "Unknown section "+sectionName;
		var choice = section[ randomizer == null ? Std.random(section.length) : randomizer.random(section.length) ];
		return explore(choice, randomizer);
	}

	function explore(choice, randomizer){
		var reg = ~/(\{(UF:)?[-a-z0-9A-Z]+\})/;
		while (reg.match(choice)){
			var part = reg.matched(1);
			part = part.substr(1);
			part = part.substr(0, -1);
			var up = false;
			if (StringTools.startsWith(part, "UF:")){
				up = true;
				part = part.substr(3);
			}
			var result = random("{"+part+"}", randomizer);
			if (up)
				result = result.charAt(0).toUpperCase() + result.substr(1);
			var pos = choice.indexOf(reg.matched(1));
			choice
				= ((pos > 0) ? choice.substr(0, pos) : "")
				+ result
				+ choice.substr(pos + reg.matched(1).length);
		}
		return choice;
	}

	public function template( sectionName:String, data:Dynamic, ?randomizer ){
		if (data == null)
			data = {};
		var base = random(sectionName, randomizer);
		var modified = true;
		while (modified){
			modified = false;
			var reg = ~/(::\s*?[-a-z0-9A-Z]+\s*?::)/;
			while (reg.match(base)){
				modified = true;
				var k = reg.matched(1).substr(2);
				k = k.substr(0, -2);
				k = StringTools.trim(k);
				base = StringTools.replace(base, reg.matched(1), Std.string(Reflect.field(data, k)));
			}
			if (modified){
				var tmp = base;
				base = explore(base, randomizer);
				modified = (tmp != base);
			}
		}
		return base;
	}

#if unittests
	public static function setupTestCases(r) : Void {
		r.add(new TestNamer());
	}
#end
}

#if unittests

class TestNamer extends haxe.unit.TestCase {
	static var data = "
# this is a comment
{} # and a comment
    abc
    {first} {last}
    {first}{last}
    {UF:first} {UF:last}

{first}
    youpla

#comment this also #
{last}
    boum # and a comment
{nearly-last}
    Use the force {real-last} and {UF:real-last} !
{real-last}
    the end
";
	function testParse(){
		var namer = new Namer(data);
		var data : Hash<Array<String>> = untyped namer.data;
		assertEquals(5, Lambda.count(data));
		assertEquals(4, data.get("{}").length);
		assertEquals(1, data.get("{first}").length);
		assertEquals(1, data.get("{last}").length);
	}

	function testRandom(){
		var namer = new Namer(data);
        assertEquals("abc", namer.name(new TestRandomizer([0])));
        assertEquals("youpla boum", namer.name(new TestRandomizer([1, 0, 0])));
        assertEquals("youplaboum", namer.name(new TestRandomizer([2, 0, 0])));
        assertEquals("Youpla Boum", namer.name(new TestRandomizer([3, 0, 0])));
        assertEquals("Use the force the end and The end !", namer.random("{nearly-last}"));
	}

	static var data2 = "
# this is a comment
{} # and a comment
    abc

{dummy}
    dummy::z::

{with-param}
    Test {::x::-last} Test

{force-last}
    Use the force {::y::} !

{real-last}
    the end
";
    function testTemplate(){
        var namer = new Namer(data2);
        assertEquals("Test the end Test", namer.template("{with-param}", {x:"real"}));
        assertEquals("Test Use the force dummy1 ! Test", namer.template("{with-param}", {x:"force", y:"dummy", z:1}));
    }
}

class TestRandomizer {
	var values : Array<Int>;
	var index : Int;
	public function new( v:Array<Int> ){
		values = v;
		index = 0;
	}
	public function random( v:Int ) : Int {
        if (index >= values.length)
            throw "TestRandomizer out of bounds";
		return values[index++] % v;
	}
}

#end