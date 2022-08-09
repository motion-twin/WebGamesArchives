
@:bind
class Debussy extends flash.text.Font {
	public function new(){ super(); }
}

class Text extends flash.text.TextField {
	public var fmt : flash.text.TextFormat;

	public function new( bla:String, size:Int, ?color:UInt=0xFF444444, ?shadow:UInt=0xFF777777 ){
		super();
		var font = new Debussy();
		autoSize = flash.text.TextFieldAutoSize.LEFT;
		selectable = false;
		embedFonts = true;
		fmt = new flash.text.TextFormat();
		fmt.font = font.fontName;
		fmt.size = size;
		fmt.bold = true;
		fmt.color = color;
		fmt.italic = true;
		fmt.align = flash.text.TextFormatAlign.CENTER;
		setText(bla);
		var glowFilter = (size > 20) ?
			new flash.filters.GradientGlowFilter(
				2/3 * size, // distance
				90, // angle
				[0xFFFFFFFF, 0xFF99AA00, 0xFFFFFF00], // colors
				// [0xFFFFFFFF, 0xFFAAAA00, 0xFFFFFF00], // colors
				[1, 1, 1], // alphas
				[0, 0.50 * size, 0.66 * size], // ratios
				5/6 * size, // blurX
				5/6 * size, // blurY
				1, // strength
				2, // quality
				flash.filters.BitmapFilterType.INNER, // type
				true // knockout
			)
			:
			new flash.filters.GradientGlowFilter(
				2/3 * size, // distance
				90, // angle
				[0xFFDDDDAA, 0xFF99AA00, 0xFFCCEE00], // colors
				[1, 1, 1], // alphas
				[0, 0.25 * size, 0.99 * size], // ratios
				5/6 * size, // blurX
				5/6 * size, // blurY
				1, // strength
				2, // quality
				flash.filters.BitmapFilterType.INNER, // type
				true // knockout
			)
			;

		filters = [
			glowFilter,
			new flash.filters.DropShadowFilter(0, Math.PI/4, shadow, 6, 6),
		];
	}

	public function setText( txt:String ){
		text = txt;
		setTextFormat(fmt);
	}
}
