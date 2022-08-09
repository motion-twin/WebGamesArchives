import Protocole;


class WorldViewerMain {//}
	

	static function main() {
		Gfx.init();
		
		haxe.Serializer.USE_ENUM_INDEX = true;
		Data.init();
				
		new WorldViewer();
	}

	


	
//{
}