module Constants exposing (..)


ssoBaseUrl : String
ssoBaseUrl =
    "https://tunnistus.avoine.fi/sso-login/?service=tradenomiitti&return="


footerSocialIcons : List { faIcon : String, url : String }
footerSocialIcons =
    [ { url = "https://www.facebook.com/tradenomiliitto"
      , faIcon = "facebook"
      }
    , { url = "https://twitter.com/Tradenomiliitto"
      , faIcon = "twitter"
      }
    , { url = "https://www.instagram.com/tradenomiliitto/"
      , faIcon = "instagram"
      }
    , { url = "http://www.linkedin.com/groups/Tradenomiliitto-TRAL-ry-2854058/about"
      , faIcon = "linkedin"
      }
    , { url = "https://github.com/tradenomiliitto/tradenomiitti"
      , faIcon = "github"
      }
    ]
