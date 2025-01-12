## Convert between various ASCII string formats.
## `PascalCase`
## `snake_case`
## `camelCase`
## `kabab-case`
module [
    StringFormat,
    convert,
]

import CamelSplitter exposing [split_camel, split_pascal]

StringFormat : [
    SnakeCase,
    PascalCase,
    KebabCase,
    CamelCase,
]

convert : Str, { from : StringFormat, to : StringFormat } -> Result Str [NotASCII]
convert = \str, config ->

    # confirm Str is ASCII
    if Str.to_utf8(str) |> List.all \b -> b >= 0 && b <= 127 then
        when (config.from, config.to) is
            (SnakeCase, PascalCase) -> Ok (snake_to_pascal str)
            (SnakeCase, KebabCase) -> Ok (snake_to_kebab str)
            (SnakeCase, CamelCase) -> Ok (snake_to_camel str)
            (KebabCase, SnakeCase) -> Ok (kebab_to_snake str)
            (KebabCase, CamelCase) -> Ok (kebab_to_camel str)
            (KebabCase, PascalCase) -> Ok (kebab_to_pascal str)
            (PascalCase, SnakeCase) -> pascal_to_snake str |> Result.map_err \_ -> NotASCII
            (PascalCase, CamelCase) -> pascal_to_camel str |> Result.map_err \_ -> NotASCII
            (PascalCase, KebabCase) -> pascal_to_kebab str |> Result.map_err \_ -> NotASCII
            (CamelCase, SnakeCase) -> camel_to_snake str |> Result.map_err \_ -> NotASCII
            (CamelCase, PascalCase) -> camel_to_pascal str |> Result.map_err \_ -> NotASCII
            (CamelCase, KebabCase) -> camel_to_kebeb str |> Result.map_err \_ -> NotASCII
            _ -> crash "TODO"
    else
        Err NotASCII

expect convert "foo_bar_string" { from: SnakeCase, to: CamelCase } == Ok "fooBarString"
expect convert "foo_bar_string" { from: SnakeCase, to: PascalCase } == Ok "FooBarString"
expect convert "foo_bar_string" { from: SnakeCase, to: KebabCase } == Ok "foo-bar-string"
expect convert "FooBarString" { from: PascalCase, to: SnakeCase } == Ok "foo_bar_string"
expect convert "FooBarString" { from: PascalCase, to: CamelCase } == Ok "fooBarString"
expect convert "FooBarString" { from: PascalCase, to: KebabCase } == Ok "foo-bar-string"
expect convert "fooBarString" { from: CamelCase, to: SnakeCase } == Ok "foo_bar_string"
expect convert "fooBarString" { from: CamelCase, to: PascalCase } == Ok "FooBarString"
expect convert "fooBarString" { from: CamelCase, to: KebabCase } == Ok "foo-bar-string"
expect convert "foo-bar-string" { from: KebabCase, to: SnakeCase } == Ok "foo_bar_string"
expect convert "foo-bar-string" { from: KebabCase, to: CamelCase } == Ok "fooBarString"
expect convert "foo-bar-string" { from: KebabCase, to: PascalCase } == Ok "FooBarString"

expect convert "foo" { from: SnakeCase, to: PascalCase } == Ok "Foo"
expect convert "foo123bar" { from: SnakeCase, to: PascalCase } == Ok "Foo123bar"
expect convert "foo_123_bar" { from: SnakeCase, to: CamelCase } == Ok "foo123Bar"
expect convert "" { from: SnakeCase, to: PascalCase } == Ok ""
expect convert "foo__bar" { from: SnakeCase, to: PascalCase } == Ok "FooBar"
expect convert "straße" { from: SnakeCase, to: PascalCase } == Err NotASCII

expect convert "Foo" { from: PascalCase, to: SnakeCase } == Ok "foo"
expect convert "FOOBarBAZ" { from: PascalCase, to: SnakeCase } == Ok "foo_bar_baz"
expect convert "FOOBarBAZ" { from: PascalCase, to: KebabCase } == Ok "foo-bar-baz"
expect convert "" { from: PascalCase, to: KebabCase } == Ok ""
expect convert "FOOBar" { from: PascalCase, to: KebabCase } == Ok "foo-bar"

expect convert "foo" { from: KebabCase, to: CamelCase } == Ok "foo"
expect convert "foo-123-bar" { from: KebabCase, to: PascalCase } == Ok "Foo123Bar"
expect convert "foo--bar" { from: KebabCase, to: CamelCase } == Ok "fooBar"

expect convert "föoBar" { from: CamelCase, to: SnakeCase } == Err NotASCII
expect convert "fooBAR" { from: CamelCase, to: SnakeCase } == Ok "foo_bar"

pascal_to_kebab : Str -> Result Str _
pascal_to_kebab = \str ->

    segments : List Str
    segments = split_pascal(str)?

    segments
    |> lowercase_all_str
    |> Str.join_with("-")
    |> Ok

kebab_to_pascal : Str -> Str
kebab_to_pascal = \str ->
    Str.split_on(str, "-")
    |> List.keep_oks uppercase_first_ascii
    |> Str.join_with("")

pascal_to_snake : Str -> Result Str _
pascal_to_snake = \str ->

    segments : List Str
    segments = split_pascal(str)?

    segments
    |> lowercase_all_str
    |> Str.join_with("_")
    |> Ok

snake_to_camel : Str -> Str
snake_to_camel = \str ->
    when Str.split_on(str, "_") is
        [first, .. as rest] ->
            rest
            |> List.keep_oks(uppercase_first_ascii)
            |> List.prepend(first)
            |> Str.join_with("")

        _ -> str

snake_to_kebab : Str -> Str
snake_to_kebab = \str ->
    Str.join_with(Str.split_on(str, "_"), "-")

kebab_to_snake : Str -> Str
kebab_to_snake = \str ->
    Str.join_with(Str.split_on(str, "-"), "_")

snake_to_pascal : Str -> Str
snake_to_pascal = \str ->
    Str.split_on(str, "_")
    |> List.keep_oks(uppercase_first_ascii)
    |> Str.join_with("")

pascal_to_camel : Str -> Result Str _
pascal_to_camel = \str ->
    when Str.to_utf8(str) is
        [first, .. as rest] ->
            rest
            |> List.prepend(to_lowercase(first))
            |> Str.from_utf8

        _ -> Ok str

kebab_to_camel : Str -> Str
kebab_to_camel = \str ->
    when Str.split_on(str, "-") is
        [first, .. as rest] ->
            List.keep_oks(rest, uppercase_first_ascii)
            |> List.prepend(first)
            |> Str.join_with("")

        _ -> str

camel_to_pascal : Str -> Result Str _
camel_to_pascal = \str ->
    when Str.to_utf8(str) is
        [first, .. as rest] ->
            rest
            |> List.prepend(to_uppercase(first))
            |> Str.from_utf8

        _ -> Ok str

camel_to_kebeb : Str -> Result Str _
camel_to_kebeb = \str ->

    segments : List Str
    segments = split_camel(str)?

    segments
    |> lowercase_all_str
    |> Str.join_with("-")
    |> Ok

camel_to_snake : Str -> Result Str _
camel_to_snake = \str ->
    segments : List Str
    segments = split_camel(str)?

    segments
    |> lowercase_all_str
    |> Str.join_with("_")
    |> Ok

uppercase_first_ascii : Str -> Result Str _
uppercase_first_ascii = \str ->
    when Str.to_utf8(str) is
        [first, .. as rest] -> Str.from_utf8 (List.prepend(rest, to_uppercase(first)))
        _ -> Ok str

to_uppercase : U8 -> U8
to_uppercase = \byte ->
    if 'a' <= byte && byte <= 'z' then
        # 32 is the difference to the respecive uppercase letters
        byte - (32)
    else
        byte

lowercase_all_str : List Str -> List Str
lowercase_all_str = \strs ->
    List.keep_oks(
        strs,
        \str ->
            bytes = Str.to_utf8 str
            Str.from_utf8(List.map(bytes, to_lowercase)),
    )

to_lowercase : U8 -> U8
to_lowercase = \byte ->
    if 'A' <= byte && byte <= 'Z' then
        # 32 is the difference to the respecive lowercase letters
        byte + 32
    else
        byte
