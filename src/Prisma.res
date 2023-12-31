type model<'t>

type findError = RejectOnNotFound | OtherError
type error = RecordNotFound

module Query = {
  type select<'m> = {"select": 'm}
  type where<'m> = {"where": 'm}
  type whereId = {"where": {"id": string}}
  type selectWhere<'m, 'n> = {"where": 'm, "select": 'n}

  type uniqueWhere = {"where": {"id": string}}
  type uniqueSelectWhere<'m> = {"where": {"id": string}, "select": 'm}

  type createSingle<'m> = {"data": 'm}
  type createMany<'m> = {"data": array<'m>, "skipDuplicates": Js.undefined<bool>}
  type createWhere<'m, 'n> = {"where": 'm, "data": 'n}
  type upsertWhere<'m, 'n, 'o> = {"where": 'm, "create": 'n, "update": 'o}
  type update<'m, 'n> = {"where": 'm, "data": 'n}
  type updateMany<'m, 'n> = {"where": 'm, "data": array<'n>}
}

module Find = {
  @send external many: model<'t> => promise<array<'m>> = "findMany"
  @send external manyWhere: (model<'t>, Query.where<'m>) => promise<array<'n>> = "findMany"
  @send external manySelect: (model<'t>, Query.select<'m>) => promise<array<'n>> = "findMany"
  @send
  external manySelectWhere: (model<'t>, Query.selectWhere<'m, 'n>) => promise<array<'o>> =
    "findMany"

  @send external uniqueById: (model<'t>, Query.uniqueWhere) => promise<Js.Null.t<'m>> = "findUnique"
  @send
  external uniqueByIdSelectWhere: (
    model<'t>,
    Query.uniqueSelectWhere<'m>,
  ) => promise<Js.Null.t<'n>> = "findUnique"

  @send external unique: (model<'t>, Query.where<'m>) => promise<Js.Null.t<'o>> = "findUnique"
  @send
  external uniqueSelectWhere: (model<'t>, Query.selectWhere<'m, 'n>) => promise<'o> = "findUnique"

  @send external count: model<'t> => promise<int> = "findMany"
}

module Create = {
  @send external create: (model<'t>, Query.createSingle<'m>) => promise<'n> = "create"
  @send external createMany: (model<'t>, Query.createMany<'m>) => promise<'n> = "createMany"
  @send external upsert: (model<'t>, Query.upsertWhere<'m, 'n, 'o>) => promise<'p> = "upsert"
}

module Update = {
  @send external update: (model<'t>, Query.update<'m, 'n>) => promise<'o> = "update"
  @send external updateMany: (model<'t>, Query.updateMany<'m, 'n>) => promise<'o> = "updateMany"
}

module Delete = {
  @send external deleteById: (model<'t>, Query.whereId) => promise<'m> = "delete"
  @send external delete: (model<'t>, Query.where<'m>) => promise<'o> = "delete"
  @send external deleteMany: (model<'t>, Query.where<'m>) => promise<'o> = "deleteMany"
}

module Client = {
  type t

  @module("@prisma/client") @new external make: unit => t = "PrismaClient"
  @send external disconnect: t => unit = "$disconnect"
}

module type Schema = {
  type t
  type createModel
  type updateModel
  let client: Client.t
  let extractModel: Client.t => model<t>
}

module Make = (Item: Schema) => {
  type t = Item.t
  type createModel = Item.createModel
  type updateModel = Item.updateModel

  let model = Item.extractModel(Item.client)

  module Create = {
    let create = (data: createModel): promise<Item.t> => Create.create(model, {"data": data})
    let createMany = (~data: array<createModel>, ~skipDuplicates: option<bool>): promise<Item.t> =>
      Create.createMany(
        model,
        {"data": data, "skipDuplicates": Js.Undefined.fromOption(skipDuplicates)},
      )
    let upsert = (where: Query.where<'a>, data: createModel, update: 'b): promise<Item.t> =>
      Create.upsert(model, {"where": where["where"], "create": data, "update": update})
  }

  module Read = {
    let many = (): promise<array<Item.t>> => Find.many(model)
    let manyWhere = (where: Query.where<'a>): promise<array<Item.t>> => Find.manyWhere(model, where)
    let manySelect = (select: Query.select<'a>) => Find.manySelect(model, select)
    let manySelectWhere = (selectWhere: Query.selectWhere<'a, 'b>) =>
      Find.manySelectWhere(model, selectWhere)

    let uniqueById = (id: string): promise<result<Item.t, findError>> =>
      Find.uniqueById(model, {"where": {"id": id}})
      ->Promise.then(async item =>
        switch item->Js.Null.toOption {
        | Some(item) => Ok(item)
        | None => Error(OtherError)
        }
      )
      ->Promise.catch(async _ => Error(RejectOnNotFound))
    let uniqueByIdSelectWhere = (idSelectWhere: Query.uniqueSelectWhere<'a>) =>
      Find.uniqueByIdSelectWhere(model, idSelectWhere)
      ->Promise.then(async item =>
        switch item->Js.Null.toOption {
        | Some(item) => Ok(item)
        | None => Error(OtherError)
        }
      )
      ->Promise.catch(async _ => Error(RejectOnNotFound))

    let unique = (where: Query.where<'a>): promise<result<Item.t, findError>> =>
      Find.unique(model, where)
      ->Promise.then(async item =>
        switch item->Js.Null.toOption {
        | Some(item) => Ok(item)
        | None => Error(OtherError)
        }
      )
      ->Promise.catch(async _ => Error(RejectOnNotFound))
    let uniqueSelectWhere = (selectWhere: Query.selectWhere<'a, 'b>) =>
      Find.uniqueSelectWhere(model, selectWhere)
      ->Promise.then(async item =>
        switch item->Js.Null.toOption {
        | Some(item) => Ok(item)
        | None => Error(OtherError)
        }
      )
      ->Promise.catch(async _ => Error(RejectOnNotFound))

    let count = (): promise<int> => Find.count(model)
  }

  module Update = {
    let update = (where: Query.where<'a>, data: updateModel): promise<result<Item.t, error>> =>
      Update.update(model, {"where": where["where"], "data": data})
      ->Promise.then(async item => Ok(item))
      ->Promise.catch(async _ => Error(RecordNotFound))
    let updateMany = (where: Query.where<'a>, data: array<updateModel>): promise<
      result<Item.t, error>,
    > =>
      Update.updateMany(model, {"where": where["where"], "data": data})
      ->Promise.then(async item => Ok(item))
      ->Promise.catch(async _ => Error(RecordNotFound))
  }

  module Delete = {
    let deleteById = (id: string): promise<result<Item.t, error>> =>
      Delete.deleteById(model, {"where": {"id": id}})
      ->Promise.then(async item => Ok(item))
      ->Promise.catch(async _ => Error(RecordNotFound))
    let delete = (where: Query.where<'a>): promise<result<Item.t, error>> =>
      Delete.delete(model, where)
      ->Promise.then(async item => Ok(item))
      ->Promise.catch(async _ => Error(RecordNotFound))
    let deleteMany = (where: Query.where<'a>): promise<result<Item.t, error>> =>
      Delete.deleteMany(model, where)
      ->Promise.then(async item => Ok(item))
      ->Promise.catch(async _ => Error(RecordNotFound))
  }
}
