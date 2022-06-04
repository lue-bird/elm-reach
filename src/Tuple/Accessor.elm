module Tuple.Accessor exposing (first, second)

{-| Accessors for `( , )` tuples.

@docs first, second

-}

import Accessor exposing (Lens, lens)


{-| Lens over the first component of a Tuple.

    import Accessors exposing (view, mapOver)
    import Tuple.Accessor as Tuple

    charging : ( String, Int )
    charging =
        ( "It's over", 1 )

    charging |> view Tuple.first
    --> "It's over"

    charging |> mapOver Tuple.first (\_ -> "It's map")
    --> ( "It's over", 1 )

    charging
        |> mapOver Tuple.first (\m -> (m |> String.toUpper) ++ "!!!")
    --> ( "IT'S OVER!!!", 1 )

-}
first :
    Lens
        ( first, second )
        first
        { first : firstFocusNamed }
        firstFocus
        firstFocusNamed
        firstFocusView
        focusFocusFocusNamed
first =
    lens
        { description = { structure = "Tuple", focus = "first" }
        , view = Tuple.first
        , map = Tuple.mapFirst
        , focusName =
            \focusFocusNamed -> { first = focusFocusNamed }
        }


{-| Lens map the second component of a Tuple.

    import Accessors exposing (view, mapOver)
    import Tuple.Accessor as Tuple

    jo : ( String, Int )
    jo =
        ( "Hi there", 1 )

    jo |> view Tuple.second
    --> 1

    jo |> mapOver Tuple.second (\_ -> 1125)
    --> ( "Hi there", 1125 )

    jo
        |> mapOver Tuple.second (\_ -> 1125)
        |> mapOver Tuple.first (\m -> (m |> String.toUpper) ++ "!!!")
        |> mapOver Tuple.second ((*) 8)
    --> ( "HI THERE!!!", 9000 )

-}
second :
    Lens
        ( first, second )
        second
        { second : secondFocusNamed }
        secondFocus
        secondFocusNamed
        secondFocusView
        focusFocusFocusNamed
second =
    lens
        { description = { structure = "Tuple", focus = "second" }
        , view = Tuple.second
        , map = Tuple.mapSecond
        , focusName =
            \focusFocusNamed -> { second = focusFocusNamed }
        }
