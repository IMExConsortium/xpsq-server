<xsl:stylesheet version="1.0" xmlns="http://psi.hupo.org/mi/mif" xmlns:psi="http://psi.hupo.org/mi/mif" 
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
       xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" indent="yes"/>

<!-- We delete the interactorList, experimentList and availabilityList in the output file. -->
<xsl:template match="psi:entrySet/psi:entry/psi:interactorList"/>
<xsl:template match="psi:entrySet/psi:entry/psi:experimentList"/>
<xsl:template match="psi:entrySet/psi:entry/psi:availabilityList"/>

<!-- We replace an availabilityRef node by an availabilityDescription -->
<!-- node with the same contents as the availabilityList/availability -->
<!-- node whose id attribute is the same as the ref attribute here.   -->
<xsl:template match="psi:availabilityRef">
    <xsl:copy-of select="../../../psi:availabilityList/psi:availability[@id=text()]"/>
</xsl:template>

<!-- We replace an experimentRef node by the experimentDescription  -->
<!-- node whose id attribute is the same as the ref attribute here. -->
<xsl:template match="psi:experimentRef">
  <xsl:copy-of select="../../../../psi:experimentList/psi:experimentDescription[@id=current()/text()]"/>
</xsl:template>

<!-- We replace an interactorRef node by the interactorDescription  -->
<!-- node whose id attribute is the same as the ref attribute here. -->
<xsl:template match="psi:interactorRef">
  <xsl:copy-of select="../../../../../psi:interactorList/psi:interactor[@id=current()/text()]"/>
</xsl:template>

<!-- For all of the nodes and their attributes... -->
<xsl:template match="/ | @* | node()">
  <!-- we make a shallow copy... -->
  <xsl:copy>
    <!-- and continue -->
    <xsl:apply-templates select="@* | node()"/>
  </xsl:copy>
</xsl:template>
</xsl:stylesheet>
