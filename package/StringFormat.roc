## Convert between various ASCII string formats.
## `PascalCase`
## `snake_case`
## `camelCase`
## `kabab-case`
module [
    Format,
    convert_case,
]

Format : [
    SnakeCase,
    PascalCase,
    KebabCase,
    CamelCase,
]

## Convert an ASCII string between various formats, e.g. `camelCase` -> `snake_case` -> `kebab-case` -> `PascalCase`
convert_case : Str, { from : Format, to : Format } -> Result Str [NotASCII]
convert_case = |str, config|

    # confirm Str is ASCII
    if Str.to_utf8(str) |> List.all(|b| b >= 0 and b <= 127) then
        when (config.from, config.to) is
            (CamelCase, CamelCase)
            | (KebabCase, KebabCase)
            | (PascalCase, PascalCase)
            | (SnakeCase, SnakeCase) -> Ok(str)

            (SnakeCase, PascalCase) -> Ok(snake_to_pascal(str))
            (SnakeCase, KebabCase) -> Ok(snake_to_kebab(str))
            (SnakeCase, CamelCase) -> Ok(snake_to_camel(str))
            (KebabCase, SnakeCase) -> Ok(kebab_to_snake(str))
            (KebabCase, CamelCase) -> Ok(kebab_to_camel(str))
            (KebabCase, PascalCase) -> Ok(kebab_to_pascal(str))
            (PascalCase, SnakeCase) -> pascal_to_snake(str) |> Result.map_err(|_| NotASCII)
            (PascalCase, CamelCase) -> pascal_to_camel(str) |> Result.map_err(|_| NotASCII)
            (PascalCase, KebabCase) -> pascal_to_kebab(str) |> Result.map_err(|_| NotASCII)
            (CamelCase, SnakeCase) -> camel_to_snake(str) |> Result.map_err(|_| NotASCII)
            (CamelCase, PascalCase) -> camel_to_pascal(str) |> Result.map_err(|_| NotASCII)
            (CamelCase, KebabCase) -> camel_to_kebeb(str) |> Result.map_err(|_| NotASCII)
    else
        Err(NotASCII)

expect convert_case("foo_bar_string", { from: SnakeCase, to: CamelCase }) == Ok("fooBarString")
expect convert_case("foo_bar_string", { from: SnakeCase, to: PascalCase }) == Ok("FooBarString")
expect convert_case("foo_bar_string", { from: SnakeCase, to: KebabCase }) == Ok("foo-bar-string")
expect convert_case("FooBarString", { from: PascalCase, to: SnakeCase }) == Ok("foo_bar_string")
expect convert_case("FooBarString", { from: PascalCase, to: CamelCase }) == Ok("fooBarString")
expect convert_case("FooBarString", { from: PascalCase, to: KebabCase }) == Ok("foo-bar-string")
expect convert_case("fooBarString", { from: CamelCase, to: SnakeCase }) == Ok("foo_bar_string")
expect convert_case("fooBarString", { from: CamelCase, to: PascalCase }) == Ok("FooBarString")
expect convert_case("fooBarString", { from: CamelCase, to: KebabCase }) == Ok("foo-bar-string")
expect convert_case("foo-bar-string", { from: KebabCase, to: SnakeCase }) == Ok("foo_bar_string")
expect convert_case("foo-bar-string", { from: KebabCase, to: CamelCase }) == Ok("fooBarString")
expect convert_case("foo-bar-string", { from: KebabCase, to: PascalCase }) == Ok("FooBarString")

expect convert_case("foo", { from: SnakeCase, to: PascalCase }) == Ok("Foo")
expect convert_case("foo123bar", { from: SnakeCase, to: PascalCase }) == Ok("Foo123bar")
expect convert_case("foo_123_bar", { from: SnakeCase, to: CamelCase }) == Ok("foo123Bar")
expect convert_case("", { from: SnakeCase, to: PascalCase }) == Ok("")
expect convert_case("foo__bar", { from: SnakeCase, to: PascalCase }) == Ok("FooBar")
expect convert_case("straße", { from: SnakeCase, to: PascalCase }) == Err(NotASCII)

expect convert_case("Foo", { from: PascalCase, to: SnakeCase }) == Ok("foo")
expect convert_case("FOOBarBAZ", { from: PascalCase, to: SnakeCase }) == Ok("foo_bar_baz")
expect convert_case("FOOBarBAZ", { from: PascalCase, to: KebabCase }) == Ok("foo-bar-baz")
expect convert_case("", { from: PascalCase, to: KebabCase }) == Ok("")
expect convert_case("FOOBar", { from: PascalCase, to: KebabCase }) == Ok("foo-bar")

expect convert_case("foo", { from: KebabCase, to: CamelCase }) == Ok("foo")
expect convert_case("foo-123-bar", { from: KebabCase, to: PascalCase }) == Ok("Foo123Bar")
expect convert_case("foo--bar", { from: KebabCase, to: CamelCase }) == Ok("fooBar")

expect convert_case("föoBar", { from: CamelCase, to: SnakeCase }) == Err(NotASCII)
expect convert_case("fooBAR", { from: CamelCase, to: SnakeCase }) == Ok("foo_bar")

pascal_to_kebab : Str -> Result Str _
pascal_to_kebab = |str|

    segments : List Str
    segments = split_pascal(str)?

    segments
    |> lowercase_all_str
    |> Str.join_with("-")
    |> Ok

kebab_to_pascal : Str -> Str
kebab_to_pascal = |str|
    Str.split_on(str, "-")
    |> List.keep_oks(uppercase_first_ascii)
    |> Str.join_with("")

pascal_to_snake : Str -> Result Str _
pascal_to_snake = |str|

    segments : List Str
    segments = split_pascal(str)?

    segments
    |> lowercase_all_str
    |> Str.join_with("_")
    |> Ok

snake_to_camel : Str -> Str
snake_to_camel = |str|
    when Str.split_on(str, "_") is
        [first, .. as rest] ->
            rest
            |> List.keep_oks(uppercase_first_ascii)
            |> List.prepend(first)
            |> Str.join_with("")

        _ -> str

snake_to_kebab : Str -> Str
snake_to_kebab = |str|
    Str.join_with(Str.split_on(str, "_"), "-")

kebab_to_snake : Str -> Str
kebab_to_snake = |str|
    Str.join_with(Str.split_on(str, "-"), "_")

snake_to_pascal : Str -> Str
snake_to_pascal = |str|
    Str.split_on(str, "_")
    |> List.keep_oks(uppercase_first_ascii)
    |> Str.join_with("")

pascal_to_camel : Str -> Result Str _
pascal_to_camel = |str|
    when Str.to_utf8(str) is
        [first, .. as rest] ->
            rest
            |> List.prepend(to_lowercase(first))
            |> Str.from_utf8

        _ -> Ok(str)

kebab_to_camel : Str -> Str
kebab_to_camel = |str|
    when Str.split_on(str, "-") is
        [first, .. as rest] ->
            List.keep_oks(rest, uppercase_first_ascii)
            |> List.prepend(first)
            |> Str.join_with("")

        _ -> str

camel_to_pascal : Str -> Result Str _
camel_to_pascal = |str|
    when Str.to_utf8(str) is
        [first, .. as rest] ->
            rest
            |> List.prepend(to_uppercase(first))
            |> Str.from_utf8

        _ -> Ok(str)

camel_to_kebeb : Str -> Result Str _
camel_to_kebeb = |str|

    segments : List Str
    segments = split_camel(str)?

    segments
    |> lowercase_all_str
    |> Str.join_with("-")
    |> Ok

camel_to_snake : Str -> Result Str _
camel_to_snake = |str|
    segments : List Str
    segments = split_camel(str)?

    segments
    |> lowercase_all_str
    |> Str.join_with("_")
    |> Ok

uppercase_first_ascii : Str -> Result Str _
uppercase_first_ascii = |str|
    when Str.to_utf8(str) is
        [first, .. as rest] -> Str.from_utf8(List.prepend(rest, to_uppercase(first)))
        _ -> Ok(str)

to_uppercase : U8 -> U8
to_uppercase = |byte|
    if 'a' <= byte and byte <= 'z' then
        # 32 is the difference to the respecive uppercase letters
        byte - (32)
    else
        byte

lowercase_all_str : List Str -> List Str
lowercase_all_str = |strs|
    List.keep_oks(
        strs,
        |str|
            bytes = Str.to_utf8(str)
            Str.from_utf8(List.map(bytes, to_lowercase)),
    )

to_lowercase : U8 -> U8
to_lowercase = |byte|
    if 'A' <= byte and byte <= 'Z' then
        # 32 is the difference to the respecive lowercase letters
        byte + 32
    else
        byte

is_lower_case : U8 -> Bool
is_lower_case = |byte|
    'a' <= byte and byte <= 'z'

is_digit : U8 -> Bool
is_digit = |byte|
    '0' <= byte and byte <= '9'

is_upper_case : U8 -> Bool
is_upper_case = |byte|
    'A' <= byte and byte <= 'Z'

# CamelCase is also known as "Lower" CamelCase
# Input must be ASCII -- not checked here as this is an internal helper
split_camel : Str -> Result (List Str) [InvalidCamel]
split_camel = |str|
    ascii_bytes = Str.to_utf8(str)
    ascii_bytes_len = List.len(ascii_bytes)

    segment_indexes : Result (List _) _
    segment_indexes =
        when List.walk_with_index(ascii_bytes, StartCamel, split_camel_help) is
            Invalid -> Err(InvalidCamel)
            StartCamel | StartPascal -> Ok([]) # an empty string was passed in
            Upper(start, indexes) -> Ok(List.append(indexes, { start, len: ascii_bytes_len }))
            Number(start, indexes) -> Ok(List.append(indexes, { start, len: ascii_bytes_len }))
            Lower(start, indexes) -> Ok(List.append(indexes, { start, len: ascii_bytes_len }))

    slices =
        segment_indexes?
        |> List.map(
            |{ start, len }|
                List.sublist(ascii_bytes, { start, len }),
        )
        |> List.keep_oks(Str.from_utf8)

    Ok(slices)

# PascalCase is also known as "Upper" CamelCase
# Input must be ASCII -- not checked here as this is an internal helper
split_pascal : Str -> Result (List Str) [InvalidPascal]
split_pascal = |str|
    ascii_bytes = Str.to_utf8(str)
    ascii_bytes_len = List.len(ascii_bytes)

    segment_indexes : Result (List _) _
    segment_indexes =
        when List.walk_with_index(ascii_bytes, StartPascal, split_camel_help) is
            Invalid -> Err(InvalidPascal)
            StartCamel | StartPascal -> Ok([]) # an empty string was passed in
            Upper(start, indexes) -> Ok(List.append(indexes, { start, len: ascii_bytes_len }))
            Number(start, indexes) -> Ok(List.append(indexes, { start, len: ascii_bytes_len }))
            Lower(start, indexes) -> Ok(List.append(indexes, { start, len: ascii_bytes_len }))

    slices =
        segment_indexes?
        |> List.map(
            |{ start, len }|
                List.sublist(ascii_bytes, { start, len }),
        )
        |> List.keep_oks(Str.from_utf8)

    Ok(slices)

SplitCaseState : [
    StartCamel,
    StartPascal,
    Upper U64 (List { start : U64, len : U64 }),
    Number U64 (List { start : U64, len : U64 }),
    Lower U64 (List { start : U64, len : U64 }),
    Invalid,
]

split_camel_help : SplitCaseState, U8, U64 -> SplitCaseState
split_camel_help = |state, byte, index|
    when state is
        Invalid -> Invalid
        StartCamel if is_lower_case(byte) -> Lower(index, [])
        StartPascal if is_upper_case(byte) -> Upper(index, [])
        StartCamel | StartPascal -> Invalid # must start with an Uppercase letter
        Upper(start, indexes) if is_upper_case(byte) -> Upper(start, indexes)
        Upper(start, indexes) if is_digit(byte) -> Number(start, indexes)
        Upper(start, indexes) if is_lower_case(byte) ->
            if (index - start) > 1 then
                Lower(index - 1, List.append(indexes, { start, len: index - start - 1 }))
            else
                Lower(start, indexes)

        Number(start, indexes) if is_digit(byte) -> Number(start, indexes)
        Number(start, indexes) if is_lower_case(byte) -> Lower(start, indexes)
        Number(start, indexes) if is_upper_case(byte) -> Upper(index, List.append(indexes, { start, len: index - start }))
        Lower(start, indexes) if is_lower_case(byte) -> Lower(start, indexes)
        Lower(start, indexes) if is_digit(byte) -> Number(start, indexes)
        Lower(start, indexes) if is_upper_case(byte) -> Upper(index, List.append(indexes, { start, len: index - start }))
        _ -> Invalid

expect split_pascal("FooBar") == Ok(["Foo", "Bar"])
expect split_camel("fooBar") == Ok(["foo", "Bar"])

expect split_pascal("abc") == Err(InvalidPascal)
expect split_pascal("123Foo") == Err(InvalidPascal)
expect split_pascal("Foo_Bar") == Err(InvalidPascal)
expect split_pascal("FööBar") == Err(InvalidPascal)

expect split_camel("FooBar") == Err(InvalidCamel)
expect split_camel("123foo") == Err(InvalidCamel)
expect split_camel("foo_bar") == Err(InvalidCamel)
expect split_camel("fööBar") == Err(InvalidCamel)

expect split_pascal("FOOBar") == Ok(["FOO", "Bar"])
expect split_pascal("FOOBarBAZ") == Ok(["FOO", "Bar", "BAZ"])
expect split_pascal("ABC") == Ok(["ABC"])
expect split_pascal("Foo123Bar") == Ok(["Foo123", "Bar"])
expect split_pascal("") == Ok([])
expect split_pascal("Foo123Bar456Baz") == Ok(["Foo123", "Bar456", "Baz"])
expect split_pascal("XMLHttpRequest") == Ok(["XML", "Http", "Request"])
expect split_pascal("A") == Ok(["A"])
expect split_pascal("FooBAR123baz") == Ok(["Foo", "BAR123baz"])
expect split_pascal("Foo1Bar") == Ok(["Foo1", "Bar"])

expect split_camel("fooBarBAZ") == Ok(["foo", "Bar", "BAZ"])
expect split_camel("fOOBarBAZ") == Ok(["f", "OO", "Bar", "BAZ"])
expect split_camel("foo123Bar456Baz") == Ok(["foo123", "Bar456", "Baz"])
expect split_camel("parseXMLHttpRequest") == Ok(["parse", "XML", "Http", "Request"])
expect split_camel("a") == Ok(["a"])
expect split_camel("fooBAR123baz") == Ok(["foo", "BAR123baz"])
expect split_camel("foo1Bar") == Ok(["foo1", "Bar"])
