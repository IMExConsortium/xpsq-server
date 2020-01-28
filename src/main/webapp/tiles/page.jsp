<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="t" %>
<%@ taglib prefix="s" uri="/struts-tags" %>

<html lang="en">
 <head>
   <meta http-equiv="content-type" content="text/html; charset=utf-8">
   <title><s:property value="page.title"/></title>
   <t:insertDefinition name="htmlhead"/>
 </head>
 <body class="yui-skin-sam" onLoad="var nos = document.getElementById('noscript'); if ( nos !== null ) { nos.innerHTML='';}">
  <center>
  <s:if test="big">
   <t:insertTemplate template="/tiles/header.jsp" flush="true"/>
  </s:if>
  <table class="pagebody" width="100%" cellspacing="0" cellpadding="0">   
   <s:if test="source!=null">
     <tr> 
      
      <td width="99%" class="pagettl">
       <s:if test="page.showtitle">
        <h1><s:property value="page.title"/></h1>
       </s:if>
      </td>
      <td class="pagecom">
      
      </td>
      <td align="right">  
         
      </td>
     </tr>
     <tr>
      <td colspan="3" class="page-content">
       <div style="width: 95%; padding:0 0 0 4%;">        
         <s:property value="source" escapeHtml="false" />
       </div>         
       <br/><br/><br/><br/><br/>
      </td>
     </tr> 
   </s:if>
  </table>
  <s:if test="big">
   <t:insertTemplate template="/tiles/footer.jsp" flush="true"/>   
  </s:if>
  </center>
 </body>
</html>
