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
data "HMEQ_1" (caslib="Public" promote="no");


    /* Set the input                                                                set */
    set "HMEQ" (caslib="Public"  );

    /* BEGIN statement 4093b46f_3c42_417d_bbf0_dae694d89ca3                      casing */
    "REASON"n = kupcase("REASON"n);
    /* END statement 4093b46f_3c42_417d_bbf0_dae694d89ca3                        casing */

/* END data step                                                                    run */
run;
';
if rc.statusCode != 0 then do;
  print "Error executing datastep";
  exit 2;
end;

dropTableIfExists("Public", "a2a80ed9-fa60-4819-87c2-ba0662bf8d8f");

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
