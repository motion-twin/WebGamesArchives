<?xml version="1.0"?>

<xsl:transform version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output indent="no" omit-xml-declaration="yes"
                method="text" encoding="UTF-8" />

<xsl:template match="/">
import flash.display.Bitmap;
    <xsl:for-each select="//bitmap">
class <xsl:value-of select="@id"/> extends Bitmap
     { public function new() { super(); } }
    </xsl:for-each>

    <xsl:for-each select="//clip">
class <xsl:value-of select="@id"/> extends MovieClip
     { public function new() { super(); } }
    </xsl:for-each>

    <xsl:for-each select="//sound">
class <xsl:value-of select="@id"/> extends MovieClip
     { public function new() { super(); } }
    </xsl:for-each>
</xsl:template>

</xsl:transform>