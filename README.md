Extensible PSicQuic Server (xpsq-server)
----------------------------------------

XPSQ server implements the key festures of the PSICQUIC 1.3 server as specified in del-Toro et al. A new reference implementation of the PSICQUIC web service. *NAR* **41**:W601-6 (2013) [doi:10.1093/nar/gkt392](https://academic.oup.com/nar/article/41/W1/W601/1100276). In particular:

 * A full set of SOAP methods for retrieving records and service meta-data 
 * A full set of RESTful services
 * MIQL query language

In the default configuration XPSQ is backed by Apache Solr-based index with Apache Derby DB used to store individual interaction records. Apart from Derby DB, XPSQ can be configured to utilize Berkeley DB, any RDBM system accessible through Hibernate (MySQL, PostgreSQL, Oracle, DB2, Microsoft SQL and many more). In the simplest case, the locally stored solr data can be used to generate mitab2x record views. In more complex use cases both index and record stores can be deployed across multiple servers in order to ensure eficient indexing and search performance. 

In order to ensure efficient indexing, XPSQ index builder supports multi-threading and can distibute records between multiple solr shards. 

