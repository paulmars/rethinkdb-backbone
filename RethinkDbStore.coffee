Backbone = require 'backbone'
_ = require("underscore")

Backbone.RethinkStorage = () ->

_.extend(Backbone.RethinkStorage.prototype, {
  create: (model, callback) ->
    cur = usersTable().insert(model.attributes).run()
    cur.next (insertData) ->
      model.set("id", insertData.generated_keys[0])
      callback(model.toJSON())

  update: (model, callback) ->
    cur = usersTable().get(model.id).update(model.attributes).run()
    cur.next (updateData) ->
      callback(model.toJSON())

  findAll: (model, callback) ->
    cur = usersTable().run()
    cur.collect (docs) ->
      callback(docs)

  find: (model, callback) ->
    cur = usersTable().get(model.id).run()
    cur.collect (docs) ->
      callback(docs)

  "delete": (model, callback) ->
    cur = usersTable().get(model.id).del().run()
    cur.collect (deleteResponse) ->
      callback(deleteResponse)
})

Backbone.sync = (method, model, options, error) ->
  store = model.localStorage

  code = (resp) ->
    if (resp)
      options.success(resp);
    else
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
