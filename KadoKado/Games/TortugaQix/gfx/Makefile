all:
	swfmill -v -v simple gfx.xml gfx.swf
	xsltproc -o Gfx.hx gfx.xslt gfx.xml

clean:
	-rm gfx.swf
	-rm Gfx.hx
