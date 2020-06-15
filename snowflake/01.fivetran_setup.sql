//=============================================================================
// create databases
//=============================================================================
USE ROLE SYSADMIN;

CREATE DATABASE FIVETRAN_DB 
  COMMENT='Database for FIVETRAN ingestion.';
//=============================================================================


//=============================================================================
// create warehouses
//=============================================================================
USE ROLE SYSADMIN;
  
CREATE WAREHOUSE FIVETRAN_INGESTION_WH
  COMMENT='Warehouse for data ingestion from FIVETRAN'
  WAREHOUSE_SIZE=XSMALL
  AUTO_SUSPEND=60
  INITIALLY_SUSPENDED=TRUE;
//=============================================================================


//=============================================================================
// create object access roles for warehouses
//=============================================================================
USE ROLE SECURITYADMIN;

// data access
CREATE ROLE FIVETRAN_DB_READ;
CREATE ROLE FIVETRAN_DB_OWNER;

// warehouse access
CREATE ROLE FIVETRAN_INGESTION_WH_ALL_PRIVILEGES;

// grant all roles to sysadmin (always do this)
GRANT ROLE FIVETRAN_DB_READ                     TO ROLE SYSADMIN;
GRANT ROLE FIVETRAN_DB_OWNER                    TO ROLE SYSADMIN;
GRANT ROLE FIVETRAN_INGESTION_WH_ALL_PRIVILEGES TO ROLE SYSADMIN;
//=============================================================================


//=============================================================================
// grant privileges to object access roles
//=============================================================================
USE ROLE SECURITYADMIN;

// data permissions
GRANT OWNERSHIP ON DATABASE FIVETRAN_DB                           TO ROLE FIVETRAN_DB_OWNER;
GRANT USAGE ON DATABASE FIVETRAN_DB                               TO ROLE FIVETRAN_DB_READ;
GRANT USAGE ON FUTURE SCHEMAS IN DATABASE FIVETRAN_DB             TO ROLE FIVETRAN_DB_READ;
GRANT SELECT ON FUTURE TABLES IN DATABASE FIVETRAN_DB             TO ROLE FIVETRAN_DB_READ;
GRANT SELECT ON FUTURE VIEWS IN DATABASE FIVETRAN_DB              TO ROLE FIVETRAN_DB_READ;
GRANT SELECT ON FUTURE MATERIALIZED VIEWS IN DATABASE FIVETRAN_DB TO ROLE FIVETRAN_DB_READ;

// warehouse permissions
GRANT ALL PRIVILEGES ON WAREHOUSE FIVETRAN_INGESTION_WH TO ROLE FIVETRAN_INGESTION_WH_ALL_PRIVILEGES;
//=============================================================================


//=============================================================================
// create business function roles and grant access to object access roles
//=============================================================================
USE ROLE SECURITYADMIN;
 
CREATE ROLE FIVETRAN_SERVICE_ACCOUNT_ROLE;
 
// grant all roles to sysadmin (always do this)
GRANT ROLE FIVETRAN_SERVICE_ACCOUNT_ROLE TO ROLE SYSADMIN;

// OA role assignment
GRANT ROLE FIVETRAN_DB_OWNER                    TO ROLE FIVETRAN_SERVICE_ACCOUNT_ROLE;
GRANT ROLE FIVETRAN_INGESTION_WH_ALL_PRIVILEGES TO ROLE FIVETRAN_SERVICE_ACCOUNT_ROLE;
//=============================================================================


//=============================================================================
// create service account
//=============================================================================
USE ROLE SECURITYADMIN;
 
// create service account
CREATE USER FIVETRAN_SERVICE_ACCOUNT_USER
  PASSWORD = 'my cool password here' // use your own password 
  COMMENT = 'Service account for FIVETRAN.'
  DEFAULT_WAREHOUSE = FIVETRAN_INGESTION_WH
  DEFAULT_ROLE = FIVETRAN_SERVICE_ACCOUNT_ROLE
  MUST_CHANGE_PASSWORD = FALSE;

// grant permissions to service account
GRANT ROLE FIVETRAN_SERVICE_ACCOUNT_ROLE TO USER FIVETRAN_SERVICE_ACCOUNT_USER;
//=============================================================================