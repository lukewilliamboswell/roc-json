app [main!] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.19.0/Hj-J_zxz7V9YurCSTFcFdu6cQJie4guzsPMUi5kBYUk.tar.br",
    json: "../package/main.roc", # use release URL (ends in tar.br) for local example, see github.com/lukewilliamboswell/roc-json/releases
}

import cli.Stdout
import json.Json
import "data.json" as request_body : List U8

main! = |_args|

    list : List DataRequest
    list = Decode.from_bytes(request_body, Json.utf8)?

    Stdout.line!("Successfully decoded list")?

    when List.get(list, 0) is
        Ok(rec) -> Stdout.line!("Name of first person is: ${rec.lastname}")
        Err(_) -> Stdout.line!("Error occurred in List.get")

DataRequest : {
    id : I64,
    firstname : Str,
    lastname : Str,
    email : Str,
    gender : Str,
    ipaddress : Str,
}
