
XPSQ: Extensible PSICQUIC Server
--------------------------------

Prerequisites 
-------------

 - Recent (eg Ubuntu 16.x, 18.x, Centos 8) linux-based server

 - Java runtime (tested version: OpenJDK11)
 - Apache Solr (tested version: Solr 8.4.1)
     Ubuntu:
       Follow steps 1, 2, 3 & 5 (skip step 4) as described in
         https://tecadmin.net/install-apache-solr-on-ubuntu/ 
       
 - Apache maven (tested version: 3.3.9)
     Ubuntu:
       Follow, eg
         https://linuxize.com/post/how-to-install-apache-maven-on-ubuntu-18-04/

 - Servlet container (tested: Tomcat 9, maven jetty plugin 9.4.26)
     Ubuntu:
       Follow, eg
         https://linuxize.com/post/how-to-install-tomcat-9-on-ubuntu-18-04/ 

Maven dependencies
------------------
  
  - all but psicquic-api artifact are publicly available from maven repositories.
    psicquic-api has to be checked out and compiled/installed (mvn install)
  
Compilation
-----------
  
  - run
      mvn clean install
    to generate server .war file (xpsq.war)

  - run 
      mvn assembly:single 
    to generate a stand-alone index builder (xpsq-index-builder.jar)
  
Testing
-------

  - deploy the server within maven
       mvn jetty:run-war 

    The xpsq server GUI should be accesible at:

       http://127.0.0.1:8080

  - start solr index
       when in xpsq-server directory, run
       <solr_dir>/bin/solr start -s target/xpsq/solr
          
    Solr server with the default two xpsq indices/shards should
    be accessible at:
 
       http://127.0.0.1:8983

   If everything works fine, the xpsq status pages located at, respectively:

      http://127.0.0.1:8080/xpsqmgr?mode=index&op.status=show

   and
   
      http://127.0.0.1:8080/xpsqmgr?mode=store&op.status=show

   respectively, should report properly initialized, but empty index
   and record repositories.

   The record manager action (used to commit records into record store) should 
   appear as mapped to:
   
        http://127.0.0.1:8080/xpsq/recordmgr

  - run the index builder:

         java -jar target/xpsq-index-builder.jar --help

    If compilation worked fine, index builder should return the list of
    available options, eg:

    >  -ctx,--context <file.json>   configuration file
    >  -d,--dir <dir>               input file directory
    >  -f,--file <file>             input file
    >  -fmt,--format <format>       input record format (default: mif25)
    >  -help,--help                 help
    >  -r,--r                       recursively process directory
    >  -z,--zip                     zipped files
 
  - index some example files:

    - mitab25 file foo.txt located in mydir directory:  

       java -jar target/xpsq-index-builder.jar -f mydir/foo.txt -fmt mitab25 

    - zipped mitab25 file foo.zip located in mydir directory:  

       java -jar target/xpsq-index-builder.jar -f mydir/foo.zip -z -fmt mitab25 

    - all mitab27 files located in mydir directory:

       java -jar target/xpsq-index-builder.jar -d mydir -fmt mitab27  

    - all mitab26 files located in mydir directory tree 

       java -jar target/xpsq-index-builder.jar -d mydir -r -fmt mitab26

   After each indexing run xpsql status pages should report matching, non-zero 
   numbers of index and record entries. Index can be cleared by running:

     java -jar target/xpsq-index-builder.jar -clr


Configuration
-------------

   Both server and index builder can be configured by modifying the default
   configuration file (json format):
        src/main/resources/etc/psq-context-default.json
   By default, it is deployed to:     
        target/work/webapp/WEB-INF/etc/psq-context-default.json
   when running the server within jetty. The index builder can be made to use
   an alternate configuration file by using -ctx option:

     java -jar target/psicquic-index-builder.jar -ctx custom-config.json ...
  
  The file is composed of three sections ("index", "store", "service") that 
  configure, respectively, the index, record store and web service subsystems.

   Index configuration ("index" section)
   -------------------------------------

      active - currently active index. As of now must be set to "solr"
      
      solr - configuration of the solr index, in particular:
         url - location of the 'main' index (it can be set to any of the 
               shards, if more than one shard is used)     
      
         shard - a list of shards used by the index engine; if missing or empty
               only the index coresponding to url parameter will be used.   
      
         NOTE: by default the server starts in a two-core/shard embedded
           configuration; if needed, the embedded solr can be substituted by 
           setting url/shard parameters to point to solr servers deployed   
           independently on the same or remote hosts. Just make sure the
           remote solr servers are visible from the host running the psicquic
           server and that the solr cores there use the proper solr schema.

         param-default - default values of parameters to be passed to solr 
               provided as a name, value/list of values map.  

      transform - transformations used to convert incoming data into index
           document. 
           NOTE: These parameters are used only by the index builder. They are 
             not used by the server and thus can be modified to match incoming 
             data without restarting or otherwise modifying the server provided
             other sections of the configuration file remain unchanged

         Each block within "transform" section defines transformation used to 
         convert files of a given type into a set of index documents.  There is
         one to one corespondence between the names of the blocks ("mif254", 
         "mitab25", etc) and the valuse accepted as the values of  --format
         argument of the index builder. Transformations are defined by 
         specifying:

               type - the type of the transformer. Acceptable values:
                  "xslt" - XSLT-based transformer (handles xml files) 
                  "calimocho" - calimocho (handles mitab files)

               config - configuration parameters for the transformer. 
                  Acceptable values vary depending on the transformer.
                  
                  'xslt' transformer recognizes, at the moment only one parameter,
                  "xslt" which coresponds to the location of the xslt file to
                  be used
                 
                  'calimocho' transformer recognizes, at the moment, only one
                  parameter, "in" which specifies the type of the incoming 
                  document (acceptable values: "mitab25", "mitab26", "mitab27")
                  
      NOTE (for the curious): each transformer is implemented as a subclass
          of org.hupo.psi.mi.psicquic.server.PsqTransformer and conventionally 
          located within org.hupo.psi.mi.psicquic.server package. The classes are
          matched to the names used in the configuration file inside the 
          org.hupo.psi.mi.psicquic.server.index.solr.SolrRecordIndex; 
          ultimately this will be configurable through a spring configuration
          file of some sort (once the builder starts using spring) 
              
  Record Store configuration ("store" section)
  --------------------------------------------

    Record views (ie record representation(s) returned in response to a query) 
    can be, in general, stored outside of the index in a record store (local 
    filesystem, local or remote database; in the simplest case it is also 
    possible to store them in the index. Currently, three implemetations of the 
    record store are available:
    
      "bdb" utilizes embedded Berkeley DB (JE) library: 
             http://www.oracle.com/technetwork/products/berkeleydb/overview

      "derby" utilizes embedded Apache Derby SQL server implementation:
             http://db.apache.org/derby/
             
      "hibernate" utilizes Hibernate (http://www.hibernate.org/) object-
             relational mapping (ORM) library -  supports any RDMB accessible 
             through Hibernate (about a dozen major RDBM systems, including 
             MySQL, PostgreSQL, Oracle, DB2, Microsoft SQL and many more)

      "solr" reuses the data stored within the index to generate mitab2x 
             representiation of the records. 
  
    Parameters:

      active - currently active data store. Valid values: 
                "bdb", "derby", "solr", "hibernate".

      rec-id - index field to use as the data store id. Valid values: 
                "uuId" - to be used with solr data store 
                "recId" - to be used with anything else (preferrd)

      view-default - default record view. Valid values:
                "psi-mi/tab25", "psi-mi/tab26", "psi-mi/tab27" (solr, derby, hibernate) 
                "psi-mi/xml25" (derby only)

      record-mgr - url of the action used to commit/retrieve individual 
               records from the record store; used only by the derby record 
               store;          

      'bdb' store configuration:
           db-home - location of the berkeleydb data directory
           
           view - configuration of the views offered by the derby store. 
                each view ("psi-mi/tab25","psi-mi/tab26","psi-mi/tab27")
                can be customized by adding header footer blocks defined
                by 'header' and 'footer' parameters; 
                
                Parameters:
                   db-name - name of the corresponding bdb database

                   header - block of text preceeding the list of records 
                             returned by the view
                   
                   footer - block of text that follows the list of recored
                             returned by the view

      'derby' store  configration:
           db-home - location of the derby data directory

           view - configuration of the views offered by the derby store. 
                each view ("psi-mi/tab25","psi-mi/tab26","psi-mi/tab27")
                can be customized by adding header footer blocks defined
                by 'header' and 'footer' parameters;

              Parameters:
                   header - block of text preceeding the list of records
                             returned by the view

                   footer - block of text that follows the list of recored
                             returned by the view

   
      'hibernate' store configuration:

           view - configuration of the views offered by the derby store. 
                each view ("psi-mi/tab25","psi-mi/tab26","psi-mi/tab27")
                can be customized by adding header footer blocks defined
                by 'header' and 'footer' parameters;

              Parameters:
                   header - block of text preceeding the list of records
                             returned by the view

                   footer - block of text that follows the list of recored
                             returned by the view

      'solr' store configuration:
           url, shard - same as for solr index; in the simplest case 
               solr index and solr record store should be identical.
               It is possible, though to come up with more elaborate 
               configurations that involve solr index replication 

           view - definitions of the views offered by the solr store.
              each view ("psi-mi/tab25","psi-mi/tab26","psi-mi/tab27")
              is defined by "col" parameter that lists the solr index 
              fields to be concatenated while building the view of 
              a single index record, "col-sep" parameter that defines 
              column separator (typically tab or comma) and "header"/
              "footer" parameters that specify blocks of text that
              preceed/follow retrieved records 


  Service Configuration
  ---------------------

     Parameters to be returned as the meta information about the 
     psicquic server.




