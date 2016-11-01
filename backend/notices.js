
var table = module.exports = require('azure-mobile-apps').table();

table.read(function (context) {

    if (!context.user) {

        var query = {
            sql: "select * FROM Notices n where n.ispublic = 'true' order by createdat desc"
        };
        return context.data.execute(query);
    } else {
        query = {

            sql: "select * FROM Notices n where n.ispublic = 'true' or authorid = '"+ context.user.id +"' order by createdat desc"
        };
        //sql: "update Notices set markPublic='false' where id in (select id from Notices where markPublic is null)"
        return context.data.execute(query);
    }
});