app [main!] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.19.0/Hj-J_zxz7V9YurCSTFcFdu6cQJie4guzsPMUi5kBYUk.tar.br",
    json: "../package/main.roc", # use release URL (ends in tar.br) for local example, see github.com/lukewilliamboswell/roc-json/releases
}

import cli.Stdout
import json.Json
import json.OptionOrNull exposing [OptionOrNull]

Object : { first_name : Str, last_name : OptionOrNull Str }

main! = |_args|

    # Demonstrate encoding an object with an Optional field
    none_obj : Object
    none_obj = { first_name: "Luke", last_name: OptionOrNull.none({}) }

    # none_json == {"first_name":"Luke",}
    none_json = Encode.to_bytes(none_obj, Json.utf8_with({ empty_encode_as_null: Json.encode_as_null_option({ record: Bool.false }) }))
    Stdout.line!(Str.from_utf8(none_json) ?? "Failed to encode JSON")?

    # Demonstrate encoding an object with an Nullable field
    null_obj : Object
    null_obj = { first_name: "Luke", last_name: OptionOrNull.null({}) }

    # null_none_json == {"first_name":"Luke","last_name":null}
    null_none_json = Encode.to_bytes(none_obj, Json.utf8_with({ empty_encode_as_null: Json.encode_as_null_option({ record: Bool.true }) }))
    Stdout.line!(Str.from_utf8(null_none_json) ?? "Failed to encode JSON")?

    # null_json == {"first_name":"Luke","last_name":null}
    null_json = Encode.to_bytes(null_obj, Json.utf8)
    Stdout.line!(Str.from_utf8(null_json) ?? "Failed to encode JSON")?

    # Demonstrate encoding an object with a Some field
    some_obj : Object
    some_obj = { first_name: "Luke", last_name: OptionOrNull.some("Boswell") }

    # some_json == {"first_name":"Luke","last_name":"Boswell"}
    some_json = Encode.to_bytes(some_obj, Json.utf8)
    Stdout.line!(Str.from_utf8(some_json) ?? "Failed to encode JSON")?

    Ok({})
