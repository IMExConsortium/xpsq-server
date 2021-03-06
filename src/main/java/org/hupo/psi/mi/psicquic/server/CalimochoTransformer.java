package org.hupo.psi.mi.psicquic.server;

/* =============================================================================
 # $Id:: CalimochoTransformer.java 1801 2013-02-25 23:11:32Z lukasz99          $
 # Version: $Rev:: 1801                                                        $
 #==============================================================================
 #
 # MitabTransformer: transform the incoming xml file into solr documents
 #
 #=========================================================================== */

import java.util.*;
import java.net.*;
import java.io.*;

import org.hupo.psi.calimocho.model.Row;
import org.hupo.psi.calimocho.tab.io.DefaultRowReader;
import org.hupo.psi.calimocho.tab.model.ColumnBasedDocumentDefinition;
import org.hupo.psi.calimocho.tab.util.MitabDocumentDefinitionFactory;
import psidev.psi.mi.calimocho.solr.converter.Converter;

import org.apache.solr.common.SolrInputDocument;
import org.apache.solr.common.SolrInputField;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


public class CalimochoTransformer implements PsqTransformer{
    
    ColumnBasedDocumentDefinition docDef = null;
    String commentPrefix = null; 
    DefaultRowReader rowReader = null;
    BufferedReader bufferedReader = null;

    Converter solrDocConverter = null;

    String fileName = null;
    String curRowStr = null;
    int curLineNumber = 0;

    String out = "SOLR";

    // mitab2x view
    //-------------

    List<String> col = null;
    String sep = "\t";

    
    public CalimochoTransformer( Map config ){
        
        if( config == null ){

        } else {
            
            // input format
            //-------------
            
            if( config.get( "in" ) != null ){ 
                    
                if( ((String) config.get( "in" ))
                    .equalsIgnoreCase( "MITAB25" ) ){
                    docDef = MitabDocumentDefinitionFactory.mitab25();
                }
                
                if( ((String) config.get( "in" ))
                    .equalsIgnoreCase( "MITAB26" ) ){
                    docDef = MitabDocumentDefinitionFactory.mitab26();
                }
                
                if( ((String) config.get( "in" ))
                    .equalsIgnoreCase( "MITAB27" ) ){
                    docDef = MitabDocumentDefinitionFactory.mitab27();
                }

                if( docDef != null ){
                    commentPrefix = docDef.getCommentPrefix();
                }
            }

            // output format
            //--------------

            if( config.get( "out" ) != null ){
                if( ((String) config.get( "out" ))
                    .equalsIgnoreCase( "SOLR" ) ){
                    solrDocConverter = new Converter();
                    out = "SOLR";
                }

                if( ((String) config.get( "out" ))
                   .equalsIgnoreCase( "VIEW" ) ){
                    solrDocConverter = new Converter();
                    out = "VIEW";

                    col = (List<String>) config.get( "col" );
                    sep = (String) config.get( "col-sep" );
                }    
            }
        }		    
    }

    public void start( String fileName ){

        Log log = LogFactory.getLog( this.getClass() );
        log.info( " starting CalimochoTransformer(fileName): filename(o)=" + this.fileName );
        
        this.fileName = fileName;
        this.curRowStr = null;
        this.curLineNumber = 0;
        
        log.info( " starting CalimochoTransformer(fileName): filename(n)=" + this.fileName );

        try {
            InputStreamReader isr = 
                new InputStreamReader( new FileInputStream( fileName ) );
            this.bufferedReader = new BufferedReader( isr );       
      
            rowReader = new DefaultRowReader( docDef );
            
        }catch( Exception ex ){
            //TODO - do whatever you want to do with this exception
        }
        
    }
    
    public void start( String fileName, InputStream is ){

        Log log = LogFactory.getLog( this.getClass() );
        log.info( " starting CalimochoTransformer(stream): filename(o)=" + this.fileName );


        this.fileName = fileName;
        this.curRowStr = null;
        this.curLineNumber = 0;

        log.info( " starting CalimochoTransformer(stream): filename(n)=" + this.fileName );

        try {
            this.bufferedReader 
                = new BufferedReader( new InputStreamReader( is ) );
            rowReader = new DefaultRowReader( docDef );
            
        }catch( Exception ex ){
            //TODO - do whatever you want to do with this exception
        }
    }

    public String getFileName(){
        return this.fileName;
    }
    
    public boolean hasNext(){
        
        while( curRowStr == null ){
            
            try{
                String curStr = bufferedReader.readLine();
                if( curStr == null ) return false;
                curLineNumber++;
            
                if ( commentPrefix != null 
                     && curStr.trim().startsWith( commentPrefix ) ) {
                
                    // skip comment lines
                    continue;
                }
                curRowStr = curStr;
            } catch( Exception ex ){
                return false; // NOTE: generate native exception ?
            }
        }
       	return true;
    }

    public Map next(){

        Log log = LogFactory.getLog( this.getClass() );
        
        if( curRowStr == null ){
            hasNext();
        }
        
        if( curRowStr == null ) return null; // no rows

        Map resMap = new HashMap();
        
        try{
            
            Row row = rowReader.readLine( curRowStr );
            curRowStr = null;
            
            if( row != null ){
                String recId = fileName + ":" + curLineNumber;
                resMap.put( "recId", recId );

                if( solrDocConverter != null ){
                    SolrInputDocument sid 
                        = solrDocConverter.toSolrDocument( row );

                    sid.setField( "recId", recId );

                    if( out.equals("SOLR") ){
                            resMap.put( "solr", sid );
                    }
                    
                    if( out.equals("VIEW") ){

                        StringBuffer view = new StringBuffer();

                        for( Iterator<String> ci = col.iterator(); 
                             ci.hasNext(); ){

                            String cc = ci.next();
                            String cv ="";
                            SolrInputField sv =  sid.get( cc );
                            if( sv != null ){
                                cv =  sv.getFirstValue().toString();
                                if(cv == null ) cv = "";
                            }

                            view.append(cv);
                            if( ci.hasNext() ){
                                view.append(sep);
                            }
                        }
                                
                        resMap.put( "view", view.toString() );
                        log.debug( "recId=" + recId 
                                   + "  ::" + view.toString().substring(0,64) );
                    }
                }
                // resMap.put( "dom", ??? ); NOTE: DOM representation ? 
            }  
            
        }catch ( Throwable t ) {
            t.printStackTrace();
            log.info( "Problem in line " + curLineNumber + ": " + curRowStr );

            // NOTE: add native exception ?
            //throw new IllegalRowException( "Problem in line: " + curLineNumber 
            //                               + "  /  LINE: " + curRowStr, 
            //                               str, lineNumber, t );
        }
        return resMap;
    }    
}