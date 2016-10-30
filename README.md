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

