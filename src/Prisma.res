type t

@module("@prisma/client") @new external createClient: unit => t = "PrismaClient"

type model<'t>

module Query = {
  type select<'m> = {"select": 'm}
  type where<'m> = {"where": 'm}

  type uniqueWhere = {"where": {"id": string}}
  type uniqueSelectWhere<'m> = {"where": {"id": string}, "select": 'm}

  type createData<'m> = {"data": 'm}
  type createDataRef<'m> = 'm
  type createWhere<'m, 'n> = {"where": 'm, "create": 'n}
  type updateWhere<'m, 'n> = {"where": 'm, "update": 'n}
}

module Find = {
  @send external many: model<'t> => promise<array<'m>> = "findMany"
  @send external manyWhere: (model<'t>, Query.where<'m>) => promise<array<'n>> = "findMany"
  @send external manySelect: (model<'t>, Query.select<'m>) => promise<array<'n>> = "findMany"
  @send external unique: (model<'t>, Query.uniqueWhere) => promise<Js.Null.t<'m>> = "findUnique"
  @send
  external uniqueSelectWhere: (model<'t>, Query.uniqueSelectWhere<'m>) => promise<Js.Null.t<'n>> =
    "findUnique"

  @send external count: model<'t> => promise<int> = "findMany"
}

module Create = {
  @send external create: (model<'t>, Query.createData<'m>) => promise<'n> = "create"
  @send external createWithRef: (model<'t>, Query.createDataRef<'m>) => promise<'n> = "create"
  @send external upsert: (model<'t>, Query.createWhere<'m, 'n>) => promise<'o> = "upsert"
}

module Delete = {
  @send external delete: (model<'t>, Query.uniqueWhere) => promise<'m> = "delete"
}

module Client = {
  type t

  @module("@prisma/client") @new external make: unit => t = "PrismaClient"
  @module("@prisma/client") external disconnect: t => unit = "$disconnect"
}
