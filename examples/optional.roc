app [main] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br",
    json: "../package/main.roc", # use release URL (ends in tar.br) for local example, see github.com/lukewilliamboswell/roc-json/releases
}

import cli.Stdout
import json.Json
import json.OptionOrNull exposing [OptionOrNull]

Object : { firstName : Str, lastName : OptionOrNull Str }

main =
    noneObj : Object
    noneObj = { firstName: "Luke", lastName: OptionOrNull.none {} }
    nullObj : Object
    nullObj = { firstName: "Luke", lastName: OptionOrNull.null {} }
    someObj : Object
    someObj = { firstName: "Luke", lastName: OptionOrNull.some "Boswell" }

    # noneJson == {"firstName":"Luke",}
    noneJson = Encode.toBytes noneObj (Json.utf8With { emptyEncodeAsNull: Json.encodeAsNullOption { record: Bool.false } })
    Stdout.line! (noneJson |> Str.fromUtf8 |> Result.withDefault "Failed to encode JSON")

    # nullNoneJson == {"firstName":"Luke","lastName":null}
    nullNoneJson = Encode.toBytes noneObj (Json.utf8With { emptyEncodeAsNull: Json.encodeAsNullOption { record: Bool.true } })
    Stdout.line! (nullNoneJson |> Str.fromUtf8 |> Result.withDefault "Failed to encode JSON")

    # nullJson == {"firstName":"Luke","lastName":null}
    nullJson = Encode.toBytes nullObj Json.utf8
    Stdout.line! (nullJson |> Str.fromUtf8 |> Result.withDefault "Failed to encode JSON")

    # someJson == {"firstName":"Luke","lastName":"Boswell"}
    someJson = Encode.toBytes someObj Json.utf8
    Stdout.line (someJson |> Str.fromUtf8 |> Result.withDefault "Failed to encode JSON")

