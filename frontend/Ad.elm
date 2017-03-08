import Date
import User

type alias Ad =
  {
    heading: String,
    content: String,
    answers: Answers,
    createdBy: User.User,
    createdAt: Date.Date
  }

type Answers = AnswerCount Int | AnswerList (List Answer)

type alias Answer =
  {
    heading: String,
    content: String,
    createdBy: User.User,
    createdAt: Date.Date
  }
