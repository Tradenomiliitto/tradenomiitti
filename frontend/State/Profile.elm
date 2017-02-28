module State.Profile exposing (..)

import Skill
import User

type alias Model =
  { user : Maybe User.User
  , editing : Bool
  , positions : List Skill.Model
  , domains : List Skill.Model
  , positionOptions : List String
  , domainOptions : List String
  }

init : Model
init =
  { user = Nothing
  , editing = False
  -- TODO
  , positions = [ Skill.Model "Kirjanpito" Skill.Experienced
                , Skill.Model "Ohjelmointi" Skill.Beginner]
  , domains = [ Skill.Model "Teollisuus" Skill.Pro
              , Skill.Model "IT" Skill.Interested ]
  , positionOptions = []
  , domainOptions = []
  }
