app [main!] { 
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.19.0/Hj-J_zxz7V9YurCSTFcFdu6cQJie4guzsPMUi5kBYUk.tar.br",
    json: "../package/main.roc", # use release URL (ends in tar.br) for local example, see github.com/lukewilliamboswell/roc-json/releases
}

import cli.Stdout
import json.Json

main! = |_args|
    dict = 
        Decode.from_bytes(json_dict, Json.utf8)
        |> Result.map_ok(Dict.from_list)
        |> Result.with_default(Dict.empty({}))
    when Dict.get(dict, "key_2") is
        Ok(val) -> Stdout.line!("key_2: ${val}")
        Err(_) -> Stdout.line!("key_2: not found")

json_dict =
    """
    {
        "key_1": "value_1",
        "key_2": "value_2",
    }
    """
    |> Str.to_utf8
