//=============================================================================
// create data resources
//=============================================================================
USE ROLE SYSADMIN;

// Databases
CREATE DATABASE FINANCE_WORKSPACE;
//=============================================================================


//=============================================================================
// create warehouses
//=============================================================================
USE ROLE SYSADMIN;

// dev warehouse
CREATE WAREHOUSE FINANCE_WORKSPACE_WH
  COMMENT='Warehouse for powering queries in the FINANCE_WORKSPACE project'
  WAREHOUSE_SIZE=XSMALL
  AUTO_SUSPEND=60
  INITIALLY_SUSPENDED=TRUE;
//=============================================================================


//=============================================================================
// create object access (OA) roles
//=============================================================================
USE ROLE SECURITYADMIN;

// data access
CREATE ROLE FINANCE_WORKSPACE_WRITE;
CREATE ROLE FINANCE_WORKSPACE_READ;

// warehouse access
CREATE ROLE FINANCE_WORKSPACE_WH_USAGE;

// grant all roles to sysadmin (always do this)
GRANT ROLE FINANCE_WORKSPACE_WRITE    TO ROLE SYSADMIN;
GRANT ROLE FINANCE_WORKSPACE_READ     TO ROLE SYSADMIN;
GRANT ROLE FINANCE_WORKSPACE_WH_USAGE TO ROLE SYSADMIN;
//=============================================================================
 

//=============================================================================
// grant privileges to object access roles
//=============================================================================
USE ROLE SECURITYADMIN;

// data access
GRANT USAGE, CREATE SCHEMA ON DATABASE FINANCE_WORKSPACE                TO ROLE FINANCE_WORKSPACE_WRITE;
GRANT ALL PRIVILEGES ON ALL SCHEMAS IN DATABASE FINANCE_WORKSPACE       TO ROLE FINANCE_WORKSPACE_WRITE;
GRANT USAGE ON DATABASE FINANCE_WORKSPACE                               TO ROLE FINANCE_WORKSPACE_READ;
GRANT USAGE ON ALL SCHEMAS IN DATABASE FINANCE_WORKSPACE                TO ROLE FINANCE_WORKSPACE_READ;
GRANT USAGE ON FUTURE SCHEMAS IN DATABASE FINANCE_WORKSPACE             TO ROLE FINANCE_WORKSPACE_READ;
GRANT SELECT ON FUTURE TABLES IN DATABASE FINANCE_WORKSPACE             TO ROLE FINANCE_WORKSPACE_READ;
GRANT SELECT ON FUTURE VIEWS IN DATABASE FINANCE_WORKSPACE              TO ROLE FINANCE_WORKSPACE_READ;
GRANT SELECT ON FUTURE MATERIALIZED VIEWS IN DATABASE FINANCE_WORKSPACE TO ROLE FINANCE_WORKSPACE_READ;

// warehouse access
GRANT USAGE ON WAREHOUSE FINANCE_WORKSPACE_WH TO ROLE FINANCE_WORKSPACE_WH_USAGE;
//=============================================================================


//=============================================================================
// create business function roles and grant access to object access roles
//=============================================================================
USE ROLE SECURITYADMIN;
 
// bf role
CREATE ROLE FINANCE_WORKSPACE_DEVELOPER;
 
// grant all roles to sysadmin (always do this)
GRANT ROLE FINANCE_WORKSPACE_DEVELOPER TO ROLE SYSADMIN;

// grant OA roles to other OA roles
GRANT ROLE FINANCE_WORKSPACE_READ TO ROLE FINANCE_WORKSPACE_WRITE;

// grant OA roles to BF roles
GRANT ROLE FINANCE_WORKSPACE_WRITE    TO ROLE FINANCE_WORKSPACE_DEVELOPER;
GRANT ROLE FINANCE_WORKSPACE_READ     TO ROLE FINANCE_WORKSPACE_DEVELOPER;
GRANT ROLE FINANCE_WORKSPACE_WH_USAGE TO ROLE FINANCE_WORKSPACE_DEVELOPER;

// Grant pre-existing source read roles here
GRANT ROLE FIVETRAN_DB_READ TO ROLE FINANCE_WORKSPACE_DEVELOPER;
//=============================================================================


//=============================================================================
// create structure.rest service account
//=============================================================================
USE ROLE SECURITYADMIN;
 
// create service account
CREATE USER STRUCTURE_FINANCE_WORKSPACE_SERVICE_ACCOUNT_USER
  PASSWORD             = 'A solid passphrase here' // do not commit real passwords to git 
  DEFAULT_WAREHOUSE    = FINANCE_WORKSPACE_WH
  DEFAULT_ROLE         = FINANCE_WORKSPACE_DEVELOPER
  MUST_CHANGE_PASSWORD = FALSE;

// grant permissions to service account
GRANT ROLE FINANCE_WORKSPACE_DEVELOPER TO USER STRUCTURE_FINANCE_WORKSPACE_SERVICE_ACCOUNT_USER;
//=============================================================================