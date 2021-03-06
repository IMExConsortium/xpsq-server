package org.hupo.psi.mi.psicquic.server.store.solr;
 
/* =============================================================================
 # $Id:: SolrRecordStore.java 1887 2013-04-10 23:56:59Z lukasz99               $
 # Version: $Rev:: 1887                                                        $
 #==============================================================================
 #
 # SolrRecordStore: SolrRecordIndex-backed RecordStore implementation
 #
 #=========================================================================== */

import java.util.*;
import java.util.zip.*;
import java.io.File;
import java.io.InputStream;
import java.io.IOException;
import java.net.MalformedURLException;

import java.util.regex.*;

import org.hupo.psi.mi.psicquic.util.JsonContext;

import org.hupo.psi.mi.psicquic.server.*;
import org.hupo.psi.mi.psicquic.server.store.*;
import org.hupo.psi.mi.psicquic.server.index.solr.*;

import org.apache.solr.common.params.ModifiableSolrParams;
import org.apache.solr.common.SolrDocumentList;

import org.apache.solr.core.*;
import org.apache.solr.common.*;
import org.apache.solr.client.solrj.*;
import org.apache.solr.client.solrj.impl.*;
import org.apache.solr.client.solrj.response.*;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

//------------------------------------------------------------------------------

public class SolrRecordStore implements RecordStore{

    private String baseUrl;
    private List<String> shardUrl;
    private String shardStr= "";

    Map<String,Object> viewMap;
    
    String host = null;
    
    SolrRecordIndex sri = null;

    public SolrRecordStore(){}
    
    public SolrRecordStore( SolrRecordIndex sri ){
        this.sri = sri;
    }
    
    public SolrRecordStore( SolrRecordIndex index, String host ){
        this.sri = index;
        this.host = host;
    }
    
    public void setSolrRecordIndex( SolrRecordIndex index ){
        this.sri = index;
    }

    public void initialize(){
        initialize( false );
    }

    public void initialize( boolean force ){
        
        Log log = LogFactory.getLog( this.getClass() );
        log.info( " initilizing SolrRecordStore: index=" + sri );
        
        if( sri != null 
            && sri.getPsqContext() != null 
            && sri.getPsqContext().getJsonConfig() != null ){
            
            // RECORD VIEWS
            //-------------
            
            Map jSolrCon = (Map)
                ((Map) sri.getPsqContext().getJsonConfig().get("store")).get("solr");            
            
            viewMap =  (Map) jSolrCon.get("view");
            
            /* "psi-mi/tab25":{
                  "config":{
                    "col":["idA_o","idB_o","altidA_o","altidB_o",
                           "aliasA_o","aliasB_o","detmethod_o","pubauth_o",
                           "pubid_o","taxidA_o","taxidB_o","type_o","source_o",
                           "interaction_id_o","confidence_o" ]
                  } }                   
            */           
        }
    }
    
    //--------------------------------------------------------------------------
    // NOTE: dummy operation: records are expected to be handled by the index
    //--------------------------------------------------------------------------

    private void connect(){}
    public void clear(){}
    public void clearLocal(){}
    public void shutdown(){}

    public void delete( List<String> idLst ){}

    public void addRecord( String rid, String record, String format ){}

    public void deleteRecord( String rid, String fmt ){}
    public void deleteRecords( List<String> idList, String format ){}
    public void deleteRecords( List<String> idList ){}

    public void updateRecord( String rid, String record, String fmt ){}


    public void addFile( File file, String fileName, 
                         String format, String compress ){

        addFile( file, fileName, format, compress, null );
    }
    
    public void addFile( File file, String fileName, 
                         String format, String compress,
                         Map<String,String> trpar ){
        
        Log log = LogFactory.getLog( this.getClass() );
        log.info( " SolrRecordStore: addFile(dummy) file=" + fileName );        
    }
    
    //-------------------------------------------------------------------------
    //-------------------------------------------------------------------------

    //private SolrServer solr = null;
    private SolrClient solr = null;

    public String getRecord( String rid, String format ){

        String record = "";
        Log log = LogFactory.getLog( this.getClass() );

        SolrDocument srec = null;
        Map recordCache = null;
        
        if( sri.getRecordCache() != null ){
            recordCache = sri.getRecordCache();
            synchronized( recordCache ){
                srec = (SolrDocument) recordCache.get( rid );
            }
        }
        
        if( srec == null ){
            log.debug( "   SolrRecordIndex: baseUrl="+ sri.getBaseUrl() );
            log.debug( "RecordCache: miss" );

            if( sri.getBaseUrl() != null ){
 
                if( solr == null ){
                    //solr = new HttpSolrServer( sri.getBaseUrl() );
                    solr = new HttpSolrClient.Builder( sri.getBaseUrl() ).build();
                }
                ModifiableSolrParams params = new ModifiableSolrParams();

                // NOTE: escape special character
                
                params.set( "q", "uuId:" + rid.replace( ":","\\:") ); 
                
                // set shards when needed
                //-----------------------
                
                if( sri.getShardStr() != null ){
                    params.set( "shards", sri.getShardStr() );
                }
                
                try{
                    QueryResponse response = solr.query( params );
                    log.debug( "response = " + response );

                    SolrDocumentList res = response.getResults();
                    srec = res.get(0);
                    
                    String recfld = sri.getPsqContext().getRecId();
                    String rec = (String) srec.get( recfld );
                                       
                    if( recordCache != null ){
                        synchronized( recordCache ){
                            recordCache.put( rec, srec );
                        }
                    }
                    
                } catch( SolrServerException sex ){
                    sex.printStackTrace();
                } catch( IOException iox){
                    iox.printStackTrace();                    
                }                
            }
        }
        
        if( srec !=null ){
            record = convert( srec , format );
        }
        return record;
    }
    
    public List<String> getRecordList( List<String> rid, String format ){
        
        List<String> recordList = new ArrayList<String>();

        // NOTE: not implemented
        return recordList;        
    }
    
    public String toString( ResultSet rset ){

        String rstr = "";
        
        String format = rset.getFormat();
        
        for( Iterator i = rset.getResultList().iterator(); i.hasNext(); ){
            String record = (String) i.next();
            rstr += record + "\n";
        }
        
        return rstr;        
    }

    //--------------------------------------------------------------------------
    //--------------------------------------------------------------------------

    private String convert( SolrDocument sdoc, String format ){

        Log log = LogFactory.getLog( this.getClass() );
        log.info( " SolrRecordStore: convert to format=" + format );

        if( viewMap == null ){
            initialize();
        }
        
        Map vconf = ((Map) ((Map) viewMap.get( format )).get("config"));

        
        StringBuffer res = new StringBuffer();
        List<String> cnl = (List<String>) vconf.get( "col" );
        String sep = (String) vconf.get( "col-sep" );
        String nullSep = "-" + (String) vconf.get( "col-sep" );
        String escSep = "\\" + (String) vconf.get( "col-sep" );
        
        for( Iterator<String> icnl = cnl.iterator(); icnl.hasNext(); ){
            
            String cv = (String) sdoc.getFirstValue( icnl.next() );
            if( cv != null ){
                if( !sep.equals("\t") ){
                    try{
                        cv = cv.replaceAll( sep, escSep ); 
                    } catch( Exception ex){
                        // should not happen
                    }
                }
                res.append( cv ).append( sep ); 
            } else {
                res.append( nullSep );
            }
        }
        return res.substring( 0, res.length() - 1 ) + "\n";
    }

    //--------------------------------------------------------------------------
    //--------------------------------------------------------------------------

    public Map getMeta(){
        
        Log log = LogFactory.getLog( this.getClass() );
        //log.debug( "getMeta: DefSolrParams=" + defSolrParams );

        Map metaMap = new HashMap();
        metaMap.put("resource-class","store");
        metaMap.put("resource-type","solr");

        ModifiableSolrParams params
            = new ModifiableSolrParams(); // defSolrParams );
        
        if( baseUrl == null ){ initialize(); }
        log.debug( "   getMeta: baseUrl=" + baseUrl );
        
        if( baseUrl != null ){
            //SolrServer solr = new HttpSolrServer( baseUrl );

            SolrClient solr  = new HttpSolrClient.Builder( sri.getBaseUrl() ).build();

            // set shards when needed
            //-----------------------

            if( shardStr != null ){
                params.set( "shards", shardStr );
            }

            // Query
            //------

            params.set( "q", "*:*" );
            params.set( "rows", Long.toString( 1 ) );
            
            try{
                QueryResponse response = solr.query( params );
                log.debug( "\n\nresponse:\n\n\n" + response +"\n\n\n");

                SolrDocumentList sdl = response.getResults();

                Map countMap = new HashMap();
                countMap.put( "all", sdl.getNumFound() );
                
                metaMap.put( "counts", countMap );

            }catch( Exception ex ){
                
                log.info( " getMeta: query error");
                ex.printStackTrace();
            }
        }
        return metaMap;
    }
 
}

