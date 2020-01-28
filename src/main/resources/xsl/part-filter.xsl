<xsl:stylesheet version="1.0" xmlns="http://psi.hupo.org/mi/mif" 
       xmlns:dxf="http://dip.doe-mbi.ucla.edu/services/dxf14"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
       xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" indent="yes"/>

<xsl:template match="/dxf:dataset">
   <xsl:apply-templates select="dxf:node/dxf:partList/*" mode="x"/>
</xsl:template>

<xsl:template match="*" mode="x" >
  <xsl:value-of select="./dxf:node/dxf:type/@name"/><xsl:text>&#x9;</xsl:text>
  <xsl:value-of select="./dxf:node/dxf:xrefList/dxf:xref[@type='instance-of']/@ns"/><xsl:text>&#xA;</xsl:text>
</xsl:template>
</xsl:stylesheet>
