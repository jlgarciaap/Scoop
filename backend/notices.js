
var table = module.exports = require('azure-mobile-apps').table();

table.read(function (context) {

	//Si no hay login solo vemos lo publico
    if (!context.user) {

        var query = {
            sql: "select * FROM Notices n where n.ispublic = 'true' order by createdat desc"
        };
        return context.data.execute(query);
    } else {
        query = {

            sql: "select * FROM Notices n where n.ispublic = 'true' or authorid = '"+ context.user.id +"' order by createdat desc"
        };
       
        return context.data.execute(query);
    }
});
