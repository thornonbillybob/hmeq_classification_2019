session server;

/* Start checking for existence of each input table */
exists0=doesTableExist("Public", "HMEQ");
if exists0 == 0 then do;
  print "Table "||"Public"||"."||"HMEQ" || " does not exist.";
  print "UserErrorCode: 100";
  exit 1;
end;
print "Input table: "||"Public"||"."||"HMEQ"||" found.";
/* End checking for existence of each input table */


dataStep.runCode result=r status=rc / code='/* BEGIN data step with the output table                                           data */
data "ef557d39-5f95-40cd-b347-41bb384e68bd" (caslib="Public" promote="no");

    length
       "REASON_MATCH"n varchar(256)
    ;

    /* Set the input                                                                set */
    set "HMEQ" (caslib="Public"  );

    /* BEGIN statement 4093b46f_3c42_417d_bbf0_dae694d89ca3                      casing */
    "REASON"n = kupcase("REASON"n);
    /* END statement 4093b46f_3c42_417d_bbf0_dae694d89ca3                        casing */

    /* BEGIN statement 1860e0c9_0597_4b71_8d5a_07174aba9eff                     dqmatch */
    "REASON_MATCH"n = dqmatch ("REASON"n, "Organization", 85, "ENUSA");
    /* END statement 1860e0c9_0597_4b71_8d5a_07174aba9eff                       dqmatch */

/* END data step                                                                    run */
run;
';
if rc.statusCode != 0 then do;
  print "Error executing datastep";
  exit 2;
end;
/* BEGIN statement 16c9cd7f-a6c1-4854-a06a-80907db8d062                     dqcluster */

entityRes.match  result=r status=rc /
     clusterId="Cluster ID"
     inTable={caslib="Public",name="ef557d39-5f95-40cd-b347-41bb384e68bd"}
     matchRules={
      { rule = {
        {columns = { "REASON_MATCH"}}
      }}
     }
     nullValuesMatch=false
     emptyStringIsNull=true
     outTable={caslib="Public",name="HMEQ_1", replace=true};

if rc.statusCode != 0 then do;
   return rc.statusCode;
end;

/* END statement 16c9cd7f-a6c1-4854-a06a-80907db8d062                       dqcluster */

dropTableIfExists("Public", "ef557d39-5f95-40cd-b347-41bb384e68bd");

function doesTableExist(casLib, casTable);
  table.tableExists result=r status=rc / caslib=casLib table=casTable;
  tableExists = dictionary(r, "exists");
  return tableExists;
end func;

function dropTableIfExists(casLib,casTable);
  tableExists = doesTableExist(casLib, casTable);
  if tableExists != 0 then do;
    print "Dropping table: "||casLib||"."||casTable;
    table.dropTable result=r status=rc/ caslib=casLib table=casTable quiet=0;
    if rc.statusCode != 0 then do;
      exit();
    end;
  end;
end func;
