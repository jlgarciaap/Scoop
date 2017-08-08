var sql = require('mssql');

sql.connect("mssql://user@stylembaas:password@stylembaas.database.windows.net:1433/sqlmbaas?encrypt=true").then(function(){

    new sql.Request().query("UPDATE Notices SET ispublic='true' WHERE id in(SELECT id FROM Notices WHERE markPublic='true')"

    ).then(function(recordset){

        console.log("All Published");


    }).catch(function(err){

        console.log(err);
    });

}).catch(function(err){

    console.log(err);
});
