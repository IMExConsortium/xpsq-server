<xsl:stylesheet version="1.0"
   xmlns:mif="http://psi.hupo.org/mi/mif"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >

<!-- ======================================================================= -->
<!-- XSLT transformation  PUBMED XML to  JSON                                -->
<!--   parameters:                                                           -->
<!--                                                                         -->
<!--  NOTES:                                                                 -->
<!--                                                                         -->
<!--                                                                         -->                          
<!-- ======================================================================= -->
<!--                                                                         -->
<!--                                                                         -->
<!--                                                                         -->  
<!-- ======================================================================= -->

 <xsl:output method="xml" indent="yes"  encoding="UTF-8" />
 <xsl:param name="debug">false</xsl:param>
 <xsl:param name="ind">1</xsl:param>

  <!-- spacer template ===================================================== -->

  <xsl:template name="space">
     <xsl:param name="ind">1</xsl:param>
     <xsl:param name="char" select="'&#032;'"/>
     <xsl:value-of select="$char" />
     <xsl:if test="$ind &gt; 0">
       <xsl:call-template name="space">
           <xsl:with-param name="ind" select="$ind - 1"/>
           </xsl:call-template>
     </xsl:if>
  </xsl:template>


 <!-- TOP TEMPLATE ========================================================= -->

 <xsl:template match="//PubmedArticleSet">    
    <xsl:text>&#xA;</xsl:text>

    <xsl:value-of select="MedlineCitation/PMID/text()"/>
    <xsl:text>&#xA;</xsl:text>

    <xsl:element name="record">
       <xsl:text>&#xA;</xsl:text>
       <xsl:apply-templates mode="j-article" select="PubmedArticle">
          <xsl:with-param name="ind" select="$ind"/>
       </xsl:apply-templates>
    </xsl:element>
    <xsl:text>&#xA;</xsl:text>
 </xsl:template>

 <!-- ====================================================================== -->

 <xsl:template match="*" mode="j-article">
    <xsl:param name="ind">1</xsl:param>

    <xsl:for-each select=".">
         
       <xsl:text>{&#xA;</xsl:text>
 
       <xsl:apply-templates select="MedlineCitation" mode="j-type">
          <xsl:with-param name="fid" select="'type'"/>
          <xsl:with-param name="ind" select="$ind"/>
          <xsl:with-param name="term" select="',&#xA;'"/>
       </xsl:apply-templates>

       <xsl:apply-templates select="PubmedData" mode="j-ident">
          <xsl:with-param name="fid" select="'identifiers'"/>
          <xsl:with-param name="ind" select="$ind"/>   
          <xsl:with-param name="term" select="',&#xA;'"/>   
       </xsl:apply-templates>
         
       <xsl:apply-templates select="MedlineCitation" mode="j-title">
          <xsl:with-param name="fid" select="'title'"/>
          <xsl:with-param name="ind" select="$ind"/>
          <xsl:with-param name="term" select="',&#xA;'"/>      
       </xsl:apply-templates>
   
       <xsl:apply-templates select="MedlineCitation" mode="j-journal">
          <xsl:with-param name="fid" select="'journal'"/>
          <xsl:with-param name="ind" select="$ind"/>
          <xsl:with-param name="term" select="',&#xA;'"/>
       </xsl:apply-templates>
   
       <xsl:apply-templates select="MedlineCitation" mode="j-dates">
          <xsl:with-param name="fid" select="'dates'"/>
          <xsl:with-param name="ind" select="$ind"/> 
          <xsl:with-param name="term" select="',&#xA;'"/>  
       </xsl:apply-templates>
   
       <xsl:apply-templates select="." mode="j-author">
          <xsl:with-param name="fid" select="'authors'"/>
          <xsl:with-param name="ind" select="$ind"/>
          <xsl:with-param name="term" select="',&#xA;'"/>   
       </xsl:apply-templates>

       <xsl:apply-templates select="." mode="j-abstract">
          <xsl:with-param name="fid" select="'abstract'"/>
          <xsl:with-param name="ind" select="$ind"/>
          <xsl:with-param name="term" select="'&#xA;'"/> 
       </xsl:apply-templates>
   
       <xsl:text>}&#xA;</xsl:text>
    </xsl:for-each> 

 </xsl:template>

 <!-- ====================================================================== -->

 <xsl:template match="*" mode="j-ident">
    <xsl:param name="fid"></xsl:param>
    <xsl:param name="ind">1</xsl:param>
    <xsl:param name="term"></xsl:param>

    <xsl:call-template name="space">
       <xsl:with-param name="ind" select="$ind"/>
    </xsl:call-template>
    <xsl:value-of select="concat('&quot;',$fid,'&quot;:[&#xA;')"/> 
   
    <xsl:for-each select="./ArticleIdList/ArticleId">
    <xsl:call-template name="space">
       <xsl:with-param name="ind" select="$ind + 1"/>
    </xsl:call-template>
    <xsl:text>{&#xA;</xsl:text>   

    <xsl:call-template name="space">
       <xsl:with-param name="ind" select="$ind + 2"/>
    </xsl:call-template>
   <xsl:value-of select="'&quot;identifier&quot;:'"/> 
   <xsl:value-of select="concat('&quot;',./text(),'&quot;,&#xA;')"/> 

    <xsl:call-template name="space">
       <xsl:with-param name="ind" select="$ind + 2"/>
    </xsl:call-template>
   <xsl:value-of select="'&quot;identifierSource&quot;:'"/> 
   <xsl:value-of select="concat('&quot;',./@IdType,'&quot;&#xA;')"/> 

    <xsl:call-template name="space">
       <xsl:with-param name="ind" select="$ind + 1"/>
    </xsl:call-template>
    <xsl:text>}</xsl:text>   

    <xsl:if test="not(position()=last())">                                                                                                                                                                 
           <xsl:text>,</xsl:text>                                                                                                                                                                              
         </xsl:if>                                                                                                                                                                                             
    <xsl:text>&#xA;</xsl:text>   

    </xsl:for-each>
  
    <xsl:call-template name="space">
       <xsl:with-param name="ind" select="$ind"/>
    </xsl:call-template>
    <xsl:value-of select="']'"/>

    <xsl:if test="string-length($term) &gt; 0">
       <xsl:value-of select="$term"/>
     </xsl:if>
     
 </xsl:template>
   
 <xsl:template match="*" mode="j-title">
    <xsl:param name="fid"></xsl:param>
    <xsl:param name="ind">1</xsl:param>
    <xsl:param name="term"></xsl:param>

     <xsl:call-template name="space">
        <xsl:with-param name="ind" select="$ind"/>
     </xsl:call-template>
     <xsl:value-of select="concat('&quot;',$fid,'&quot;:&quot;',./Article/ArticleTitle/text())"/> 
     <xsl:value-of select="'&quot;'"/>     

    <xsl:if test="string-length($term) &gt; 0">       
       <xsl:value-of select="$term"/>
     </xsl:if>


 </xsl:template>

 <xsl:template match="*" mode="j-type">
    <xsl:param name="fid"></xsl:param>
    <xsl:param name="ind">1</xsl:param>
    <xsl:param name="term"></xsl:param>

     <xsl:call-template name="space">
        <xsl:with-param name="ind" select="$ind"/>
     </xsl:call-template>
     <xsl:value-of select="concat('&quot;',$fid,'&quot;:')"/>
     <xsl:value-of select="concat('{&quot;value&quot;:','article','&quot;}')"/> 
    <xsl:if test="string-length($term) &gt; 0">
       <xsl:value-of select="$term"/>
     </xsl:if>
     
 </xsl:template>

 <xsl:template match="*" mode="j-dates">
    <xsl:param name="fid"></xsl:param>
    <xsl:param name="ind">1</xsl:param>
    <xsl:param name="term"></xsl:param>


    <xsl:call-template name="space">
       <xsl:with-param name="ind" select="$ind"/>
    </xsl:call-template>
    <xsl:value-of select="concat('&quot;',$fid,'&quot;:[')"/> 
     
    <xsl:value-of select="concat('{&quot;','date','&quot;:')"/>  
    <xsl:value-of select="concat('&quot;',./Article/Journal/JournalIssue/PubDate/Year/text(),'&quot;')"/>  
    <xsl:value-of select="concat(',&quot;type','&quot;:{&quot;value&quot;:&quot;publication date&quot;}')"/>    
    <xsl:value-of select="']'"/>   

    <xsl:if test="string-length($term) &gt; 0">
       <xsl:value-of select="$term"/>
     </xsl:if>

 </xsl:template>

 <xsl:template match="*" mode="j-author">
    <xsl:param name="fid"></xsl:param>
    <xsl:param name="ind">1</xsl:param>
    <xsl:param name="term"></xsl:param>

     <xsl:if test="string-length($fid) &gt; 0">
        <xsl:call-template name="space">
           <xsl:with-param name="ind" select="$ind"/>
        </xsl:call-template>
        <xsl:value-of select="concat('&quot;',$fid,'&quot;:[&#xA;')"/> 
     </xsl:if>

     <xsl:for-each select="./MedlineCitation/Article/AuthorList/Author"> 

        <xsl:call-template name="space">
           <xsl:with-param name="ind" select="$ind + 1"/>
        </xsl:call-template>
         <xsl:value-of select="'{&#xA;'"/>

        <xsl:call-template name="space">
           <xsl:with-param name="ind" select="$ind + 2"/>
        </xsl:call-template>
        <xsl:value-of select="'&quot;firstName&quot;:'"/>
        <xsl:value-of select="concat('&quot;',./ForeName,'&quot;,&#xA;')"/>

        <xsl:call-template name="space">
           <xsl:with-param name="ind" select="$ind + 2"/>
        </xsl:call-template>

         <xsl:value-of select="'&quot;lastName&quot;:'"/>
         <xsl:value-of select="concat('&quot;',./LastName,'&quot;&#xA;')"/>

       <xsl:call-template name="space">
           <xsl:with-param name="ind" select="$ind + 1"/>
        </xsl:call-template>
         <xsl:value-of select="'}'"/>

        <xsl:if test="not(position()=last())">
           <xsl:text>,</xsl:text>
         </xsl:if> 

         <xsl:text>&#xA;</xsl:text>
        
     </xsl:for-each>
    
     <xsl:if test="string-length($fid) &gt; 0">
         <xsl:call-template name="space">
           <xsl:with-param name="ind" select="$ind"/>
        </xsl:call-template>
         <xsl:value-of select="']'"/>
     </xsl:if>

    <xsl:if test="string-length($term) &gt; 0">
       <xsl:value-of select="$term"/>
     </xsl:if>

 </xsl:template>

 <xsl:template match="*" mode="j-abstract">
    <xsl:param name="fid"></xsl:param>
    <xsl:param name="ind">1</xsl:param>
    <xsl:param name="term"></xsl:param>


    <xsl:call-template name="space">
       <xsl:with-param name="ind" select="$ind"/>
    </xsl:call-template>
    <xsl:value-of select="concat('&quot;',$fid,'&quot;:')"/> 
    <xsl:value-of select="concat('&quot;',./MedlineCitation/Article/Abstract/AbstractText,'&quot;')"/> 

    <xsl:if test="string-length($term) &gt; 0">
       <xsl:call-template name="space">
          <xsl:with-param name="ind" select="$ind"/>
       </xsl:call-template>
       <xsl:value-of select="$term"/>
     </xsl:if>
     
 </xsl:template>

 <xsl:template match="*" mode="j-journal">
    <xsl:param name="fid"></xsl:param>
    <xsl:param name="ind">1</xsl:param>
    <xsl:param name="term"></xsl:param>

    <xsl:call-template name="space">
       <xsl:with-param name="ind" select="$ind"/>
    </xsl:call-template>
    <xsl:value-of select="concat('&quot;',$fid,'&quot;:{&#xA;')"/> 
     
    <xsl:call-template name="space">
       <xsl:with-param name="ind" select="$ind + 2"/>
    </xsl:call-template>
     <xsl:value-of select="'&quot;title&quot;:'"/>
     <xsl:value-of select="concat('&quot;',./Article/Journal/Title/text(),'&quot;,&#xA;')"/> 

    <xsl:call-template name="space">
       <xsl:with-param name="ind" select="$ind + 2"/>
    </xsl:call-template>
     <xsl:value-of select="'&quot;volume&quot;:'"/>
     <xsl:value-of select="concat('&quot;',./Article/Journal/JournalIssue/Volume/text(),'&quot;,&#xA;')"/> 

    <xsl:call-template name="space">
       <xsl:with-param name="ind" select="$ind + 2"/>
    </xsl:call-template>
     <xsl:value-of select="'&quot;issue&quot;:'"/>
     <xsl:value-of select="concat('&quot;',./Article/Journal/JournalIssue/Issue/text(),'&quot;,&#xA;')"/> 

    <xsl:call-template name="space">
       <xsl:with-param name="ind" select="$ind + 2"/>
    </xsl:call-template>
     <xsl:value-of select="'&quot;pages&quot;:'"/>
     <xsl:value-of select="concat('&quot;',./Article/Pagination/MedlinePgn/text(),'&quot;,&#xA;')"/> 

    <xsl:call-template name="space">
       <xsl:with-param name="ind" select="$ind + 1"/>
    </xsl:call-template>

    <xsl:value-of select="'}'"/>     

    <xsl:if test="string-length($term) &gt; 0">
       <xsl:value-of select="$term"/>
     </xsl:if>

 </xsl:template>

 <xsl:template match="*" mode="j-blank">
    <xsl:param name="fid"></xsl:param>
    <xsl:param name="ind">1</xsl:param>
    <xsl:param name="term"></xsl:param>

    <xsl:call-template name="space">
       <xsl:with-param name="ind" select="$ind"/>
    </xsl:call-template>
    <xsl:value-of select="concat('&quot;',$fid,'&quot;:[')"/> 
     
    <xsl:value-of select="']&#xA;'"/>     
 </xsl:template>
  
</xsl:stylesheet>
