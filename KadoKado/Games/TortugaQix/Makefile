NAME=TortugaQix
DEBUG=-debug -D debug
DEBUG=

.PHONY: gfx

all: gfx
	@haxe $(DEBUG) --flash-strict -cp ../api -cp src -cp src/common -swf9 game_.swf -swf-lib gfx/sprites.swf -swf-lib gfx/gfx.swf Manager -swf-header 300:300:32:FFFFFF
	@obfu9 -config obfu9.cfg -key Xi1ooQu3 game_.swf -o game.swf
	@rm game_.swf
	@google-chrome http://games.kadokado.com/TortugaQix/index.html

no-obfu: gfx
	@haxe $(DEBUG) --flash-strict -cp ../api -cp src -cp src/common -swf9 game_.swf -swf-lib gfx/sprites.swf -swf-lib gfx/gfx.swf Manager -swf-header 300:300:32:FFFFFF
	@cp game_.swf game.swf
	@google-chrome http://games.kadokado.com/TortugaQix/index.html

gfx:
	make -C gfx

clean:
	-rm *.swf
	-make -C gfx clean
