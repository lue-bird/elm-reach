module Map exposing
    ( description
    , over, overLazy
    , onJust
    , onOk, onErr
    , Alter, Map, ToMapped(..), at
    )

{-| map into nested structures to [map](#over) or [`view`](#view) arbitrary content

@docs Part, Possibility, Elements, ViewMap


## mapping to same type

@docs ElementsMappingToSameType, MaybeMappingToSameType, PartMappingToSameType


## create

@docs part, possibility, elements


## scan

@docs view, has
@docs description


## nested map

@docs over, overLazy


## for `Maybe`

@docs onJust


## for `Result`

@docs onOk, onErr

-}


{-| Change elements. Examples

  - each `Array` element
  - e.g. the value of one of many variants
      - [`onJust`](#onJust)
      - [`onOk`](#onOk)
      - [`onErr`](#onErr)
  - [`Tuple.Map.first`](Tuple-map#first)
  - [`SelectList.Map.selected`](SelectList-map#selected)
  - record `.field` value

Intuitively, its type could look like

    type alias Map structure part mapped partMapped =
        { map : (part -> partMapped) -> (structure -> mapped)
        , description : List String
        }

Unfortunately, we then need `Map.toPart`, `Map.toTranslate`, `Map.toMaybe`, ... compose functions.

Defining "Lens" in terms of [`ToMapped`](#ToMapped)s

    ToMapped part partMapped -> ToMapped structure mapped

we're able to make use of `<<`
to [`Map.over`](#over) a nested structure.

Technical note: This is an approximation of [CPS based / Van Laarhoven encoded lenses](https://www.tweag.io/blog/2022-05-05-existential-optics/)

-}
type alias Map structure element mapped elementMapped =
    ToMapped element elementMapped
    -> ToMapped structure mapped


{-| Description on how to `view` or `map` a value

[`Map.Elements`](map#Elements) and its descendants
always expect a [`ViewMap`](#ViewMap) and build a new [`ViewMap`](#ViewMap) with it

-}
type ToMapped value mapped
    = ToMapped
        { toMapped : value -> mapped
        , description : List String
        }



-- mapping to same type


{-| [`Map`](#Map) that will only preserve the element type.

`Alter` can be used to simplify argument and result types

    module List.Map exposing (onHead)

    import Map

    onHead : Alter (List element) element
    onHead =
        Map.at "0"
            (\alter list ->
                case list of
                    [] ->
                        []

                    head :: tail ->
                        (head |> alter) :: tail
            )

-}
type alias Alter structure element =
    Map structure element structure element



--


{-| Each reach has a name.
The `<<` chain gives us a `List` of unique reach [`description`](#description)s.
This is useful when you want type-safe identifiers for a `Dict`
similar to the way you'd use a Sum type's constructors to key a dictionary for a form
but you still want to use the `elm/core` implementation.

    import Map
    import Dict.Map
    import Record

    (Record.email
        << onJust
        << Record.info
        << Dict.Map.valueAtString "subject"
    )
        |> Map.description
        |> String.join ")"
    --> "email)Just)info)value at subject"

-}
description :
    Map structure reach mapped reach
    -> List String
description =
    \map ->
        map
            (ToMapped
                { toMapped = \_ -> Debug.todo ""
                , description = []
                }
            )
            |> (\(ToMapped toMappedInternal) -> toMappedInternal.description)


{-| Create a [`Map`](#Map) from

  - a `String` that uniquely describes the part
  - a function that changes elements inside the structure

```
foo : Alter { record | foo : foo } foo
foo =
    Map.at "foo"
        (\alter record -> { record | foo = record.foo |> alter })

onOk : Map (Result error value) value (Result error valueMapped) valueMapped
onOk =
    Map.at "Ok" Result.Map

each :
    Map
        (List element)
        element
        (List elementMapped)
        elementMapped
each =
    Map.at "each" List.Map
```

-}
at :
    String
    ->
        ((element -> elementMapped)
         -> (structure -> mapped)
        )
    -> Map structure element mapped elementMapped
at focusDescription map =
    \(ToMapped elementToMapped) ->
        ToMapped
            { description =
                focusDescription :: elementToMapped.description
            , toMapped = map elementToMapped.toMapped
            }


{-| Given a reach and a change for each element
`over` transforms the data `structure`'s reached content.

    import Record

    { foo = { qux = 0 } }
        |> Map.over (Record.foo << Record.qux) (\n -> n + 1)
    --> { foo = { qux = 1 } }

-}
over :
    Map structure element mapped elementMapped
    ->
        ((element -> elementMapped)
         -> (structure -> mapped)
        )
over reach change =
    let
        (ToMapped structureViewMap) =
            reach
                (ToMapped
                    { description = []
                    , toMapped = change
                    }
                )
    in
    structureViewMap.toMapped


{-| [`Map.over`](#over) which checks that the old and the new version are different
before giving you the changed/original structure back.

Useful when used together with `Html.lazy`, because it uses reference
equality for complex structures. Therefore, using lazy `map` will
not prevent `Html.lazy` from doing its work.

-}
overLazy :
    Map structure reach structure reach
    ->
        ((reach -> reach)
         -> (structure -> structure)
        )
overLazy reach change =
    \structure ->
        let
            changedStructure =
                structure |> over reach change
        in
        if changedStructure /= structure then
            changedStructure

        else
            structure



-- Maybe


{-| map the value inside `Maybe`

    import Map exposing (onJust)
    import Record

    maybeRecord : { foo : Maybe { bar : Int }, qux : Maybe { bar : Int } }
    maybeRecord =
        { foo = Just { bar = 2 }
        , qux = Nothing
        }

    maybeRecord
        |> Map.view (Record.foo << onJust << Record.bar)
    --> Just 2

    maybeRecord
        |> Map.over (Record.foo << onJust << Record.bar) (\n -> n + 1)
    --> { foo = Just { bar = 3 }, qux = Nothing }

    maybeRecord
        |> Map.over (Record.qux << onJust << Record.bar) (\n -> n + 1)
    --> { foo = Just { bar = 2 }, qux = Nothing }

To view nested [`Map.Possibility`](#Maybe)s flattened, [`Map.flat`](#flat)

-}
onJust : Map (Maybe value) value (Maybe valueMapped) valueMapped
onJust =
    at "Just" Maybe.map



-- Result


{-| map the value inside the `Ok` variant of a `Result`

    import Map exposing (onOk)
    import Record

    maybeRecord : { foo : Result String { bar : Int }, qux : Result String { bar : Int } }
    maybeRecord =
        { foo = Ok { bar = 2 }
        , qux = Err "Not an Int"
        }

    maybeRecord |> Map.view (Record.foo << onOk << Record.bar)
    --> Just 2

    maybeRecord |> Map.view (Record.qux << onOk << Record.bar)
    --> Nothing

    maybeRecord
        |> Map.over
            (Record.foo << onOk << Record.bar)
            (\n -> n + 1)
    --> { foo = Ok { bar = 3 }, qux = Err "Not an Int" }

    maybeRecord
        |> Map.over
            (Record.qux << onOk << Record.bar)
            (\n -> n + 1)
    --> { foo = Ok { bar = 2 }, qux = Err "Not an Int" }

-}
onOk :
    Map
        (Result error value)
        value
        (Result error valueMapped)
        valueMapped
onOk =
    at "Ok" Result.map


{-| map the value inside the `Err` variant of a `Result`

    import Map exposing (onErr)
    import Record

    maybeRecord : { foo : Result String { bar : Int }, qux : Result String { bar : Int } }
    maybeRecord =
        { foo = Ok { bar = 2 }
        , qux = Err "Not an Int"
        }

    maybeRecord |> Map.view (Record.foo << onErr)
    --> Nothing

    maybeRecord |> Map.view (Record.qux << onErr)
    --> Just "Not an Int"

    maybeRecord
        |> Map.over (Record.foo << onErr) String.toUpper
    --> { foo = Ok { bar = 2 }, qux = Err "Not an Int" }

    maybeRecord
        |> Map.over (Record.qux << onErr) String.toUpper
    --> { foo = Ok { bar = 2 }, qux = Err "NOT AN INT" }

-}
onErr :
    Map
        (Result error value)
        error
        (Result errorMapped value)
        errorMapped
onErr =
    at "Err" Result.mapError