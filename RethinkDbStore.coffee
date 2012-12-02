_ = require("underscore")

logDebug = false

# Datastore

set = (Backbone) ->
  Backbone.RethinkStorage = () ->

  _.extend(Backbone.RethinkStorage.prototype, {
    create: (model, callback) ->
      console.log("create") if logDebug
      console.log(model) if logDebug
      cur = model.tableCur().insert(model.attributes).run()
      cur.next (insertData) ->
        console.log("inserted") if logDebug
        console.log(insertData) if logDebug
        model.set("id", insertData.generated_keys[0])
        callback(model.toJSON())

    update: (model, callback) ->
      console.log("update") if logDebug
      cur = model.tableCur().get(model.id).update(model.attributes).run()
      cur.next (updateData) ->
        callback(model.toJSON())

    findAll: (model, callback) ->
      cur = model.tableCur().run()
      cur.collect (docs) ->
        callback(docs)

    find: (model, callback) ->
      console.log("find") if logDebug
      cur = model.tableCur().get(model.id).run()
      cur.collect (docs) ->
        doc = docs[0]
        console.log("found doc") if logDebug
        console.log(doc) if logDebug
        callback(doc)

    "delete": (model, callback) ->
      cur = model.tableCur().get(model.id).del().run()
      cur.collect (deleteResponse) ->
        callback(deleteResponse)
  })

  Backbone.sync = (method, model, options, error) ->
    console.log("backbone sync" + method) if logDebug
    store = model.localStorage

    code = (resp) ->
      console.log("code") if logDebug
      console.log(resp) if logDebug
      if (resp)
        console.log("success") if logDebug
        options.success(resp);
      else
        console.log("error") if logDebug
        options.error(resp);

    switch method
      when "create"
        store.create model, code
      when "update"
        store.update model, code
      when "read"
        if model.id?
          store.find model, code
        else
          store.findAll model, code
      when "delete"
        store.delete model, code

exports.set = set
