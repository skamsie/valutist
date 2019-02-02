# valutist

'_Ascund dolarii și mărcile să nu-mi facă negre zilele_'

[![Build Status](https://travis-ci.com/skamsie/valutist.svg?branch=master)](https://travis-ci.com/skamsie/valutist/branches)

### Requirements

```
PostgreSQL
Ruby v 2.5.0 (with bundler)
```

### Install & Run

set `FIXER_API_KEY` as an environment variable.

https://fixer.io

A free api key can be used (it is limited to 1000 requests per month). The app does a request to fixer api only if the last update was more than 6 hours ago. 
```
> bundle install
> bundle exec rake db:create db:migrate
> bundle exec puma -p 9293
```

### Usage

Get the latest conversion rates

```
> curl -H "Content-type: application/json" http://localhost:9293/latest

{
  "created_at": "2019-01-20T18:06:02.681Z",
  "base_currency": "EUR",
  "BGN": 1.957438,
  "BRL": 4.268151,
  "BWP": 11.950216,
  "CAD": 1.507594,
  "CHF": 1.132484,
  "DKK": 7.471615,
  "EUR": 1,
  "GBP": 0.882755,
  "RON": 4.707753,
  "INR": 81.034679,
  "ISK": 137.891718,
  "JPY": 124.841529,
  "MXN": 21.701776,
  "NOK": 9.734396,
  "RUB": 75.255283,
  "SAR": 4.267076,
  "SEK": 10.266571,
  "USD": 1.137249
}
```

Convert to one or more currencies

```
> curl -XPOST -H "Content-type: application/json" http://localhost:9293/convert -d'{"from": "eur", "to": "usd, gbp, ron, sek", "amount": 100}'

{
  "from": "EUR",
  "to": [
    "USD",
    "GBP",
    "RON",
    "SEK"
  ],
  "amount": 100,
  "result": {
    "USD": 113.72,
    "GBP": 88.28,
    "RON": 470.78,
    "SEK": 1026.66
  },
  "updated_at": "2019-01-20T18:06:02.681Z"
}
```
