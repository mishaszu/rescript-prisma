type t

@module("@prisma/client") @new external createClient: unit => t = "PrismaClient"

type model<'t>

type select<'m> = {"select": 'm}
type where<'m> = {"where": 'm}
type createData<'m> = {"data": 'm}
type createDataRef<'m> = 'm

type uniqueWhere = {"where": {"id": string}}
type uniqueWhereSelect<'m> = {"where": {"id": string}, "select": 'm}

@send external findMany: model<'t> => promise<array<'m>> = "findMany"
@send external findManyWhere: (model<'t>, where<'m>) => promise<array<'n>> = "findMany"
@send external findManySelect: (model<'t>, select<'m>) => promise<array<'n>> = "findMany"
@send external findUnique: (model<'t>, uniqueWhere) => promise<Js.Null.t<'m>> = "findUnique"
@send
external findUniqueSelect: (model<'t>, uniqueWhereSelect<'m>) => promise<Js.Null.t<'n>> =
  "findUnique"
@send external count: model<'t> => promise<int> = "findMany"

@send external create: (model<'t>, createData<'m>) => promise<'n> = "create"
@send external createWithRef: (model<'t>, createDataRef<'m>) => promise<'n> = "create"

@send external delete: (model<'t>, uniqueWhere) => promise<'m> = "delete"
