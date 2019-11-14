# gerai [![Build Status](https://travis-ci.org/boonious/gerai.svg?branch=master)](https://travis-ci.org/boonious/gerai) [![Coverage Status](https://coveralls.io/repos/github/boonious/gerai/badge.svg)](https://coveralls.io/github/boonious/gerai)

Gerai ("store" in Malay) is an [OTP-compliant](http://blog.plataformatec.com.br/2018/04/elixir-processes-and-this-thing-called-otp/) JSON object cache for Elixir.

## Usage

Gerai currently provides a single-process in-memory cache server for storing JSON objects.
Storage functions (CRUD) are available through both functional and HTTP interfaces.

### Example - functional interface

Start the server up through Elixir interactive shell `iex -S mix`

```elixir
  iex> Gerai.put("tt1454468", "{\"name\":\"Gravity\",\"id\":\"tt1454468\"}")
  :ok

  iex> Gerai.get("tt1454468")
  {:ok, "{\"name\":\"Gravity\",\"id\":\"tt1454468\"}"}

  iex> Gerai.put("tt1316540", "{\"name\":\"The Turin Horse\",\"id\":\"tt1316540\"}")
  :ok

  iex> Gerai.get(:all)
  {:ok,
   ["{\"name\":\"The Turin Horse\",\"id\":\"tt1316540\"}",
    "{\"name\":\"Gravity\",\"id\":\"tt1454468\"}"]}

  iex> Gerai.delete("tt1454468")
  :ok

  iex> Gerai.get("tt1454468")
  {:error, nil}
```
### Example - HTTP interface

The cache can also be accessed via the `http://localhost:8080/` endpoint, while the application
is running through one of the following ways:

 - `iex -S mix`
 - `mix run --no-halt`

```
  # GET request with ID
  # http://localhost:8080/?id=tt1316540
  GET /?id=tt1316540

  # GET all objects - request without id
  # http://localhost:8080/
  GET /

  # Create and update objects by putting and posting data
  # http://localhost:8080/tt1454468
  POST /tt1454468

  PUT /tt1454468

  # Delete object with ID
  # http://localhost:8080/tt1454468
  DELETE /tt1454468
```

## Note

This software has been developed quickly for the experimentation of OTP.
In particular, the use of [GenServer](https://hexdocs.pm/elixir/GenServer.html) behaviour module
to enable fast implementation of an in-memory storage for JSON serialised objects. 

While OTP can facilitate a very high number of concurrent processes (millions),
only a **single server process** is used in `gerai` as a global cache server with a fixed name
registration. It therefore can be accessed directly from anywhere within the OTP application. The singleton
scenario means the software is non-performant and for demo purposes only, as requests to the cache are handled
one at a time by a single server process.

Future development could involve a larger number of concurrent GenServer cache stores, for example 
a pool of distributed cache servers or personalised storage.

The HTTP interface is put together using [`Plug`](https://github.com/elixir-plug/plug).

