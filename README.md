# Thing

**TODO: Add description**

## Installation

git clone ... thing
cd thing
mix deps.get


## Steps to make this

mix new thing --sup

add functons:

```
  def hello do
      "Hello"
  end
```

then run with  `iex -S mix`

```
Thing.hello
```

Then add with parameter:

```
 def hello(name) do
    "Hello, " <> name
  end
```

TO DO:  explain modifying app with cowboy / plug
http://codouken.com/articles/basic-http-server-with-elixir

call our own Thing.hello from `get "/" do`

### add Twitter

https://hex.pm/packages/extwitter

TODO: explain Twitter config

* https://github.com/parroty/extwitter
* make secret.twitter.exs from https://apps.twitter.com
* check in a example.twitter.exs

experiment in iex (learn about Enum!):

```
ExTwitter.search("elixir-lang", [count: 5]) |>
   Enum.map(fn(tweet) -> tweet.text end) |>
   Enum.join("\n-----\n") |>
   IO.puts
```




