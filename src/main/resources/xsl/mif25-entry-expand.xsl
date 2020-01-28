<xsl:stylesheet version="1.0" xmlns="http://psi.hupo.org/mi/mif" xmlns:psi="http://psi.hupo.org/mi/mif" 
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
       xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" indent="yes"/>

<xsl:template match="psi:entrySet/psi:entry/psi:interactorList"/>
<xsl:template match="psi:entrySet/psi:entry/psi:experimentList"/>
<xsl:template match="psi:entrySet/psi:entry/psi:availabilityList"/>

<xsl:template match="psi:availabilityRef"  mode="ee">
    <xsl:copy-of select="../../../psi:availabilityList/psi:availability[@id=text()]"/>
</xsl:template>

<xsl:template match="psi:experimentRef"  mode="ee">
  <xsl:copy-of select="../../../../psi:experimentList/psi:experimentDescription[@id=current()/text()]"/>
</xsl:template>

<xsl:template match="psi:interactorRef" mode="ee">
  <xsl:copy-of select="../../../../../psi:interactorList/psi:interactor[@id=current()/text()]"/>
</xsl:template>

<xsl:template match=" @* | node()" mode="ee">
  <xsl:copy>
    <xsl:apply-templates select="@* | node()" mode="ee"/>
  </xsl:copy>
</xsl:template>

<!-- start with entrySet -->

<xsl:template match="/psi:entrySet">
 <xsl:copy>
     <xsl:for-each select='psi:entry/psi:interactionList/psi:interaction'>
       <xsl:variable name="i" select='.'/>
       <xsl:element name="entry">
           <xsl:copy-of select="$i/../../psi:source"/>
           <xsl:element name="interactionList">
             <xsl:apply-templates select="$i" mode="ee"/> 
           </xsl:element>        
       </xsl:element> 
     </xsl:for-each>
 </xsl:copy>
</xsl:template>

</xsl:stylesheet>
